#!/usr/bin/env python3
import fcntl
import glob
import json
import os
import re
import subprocess
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path

JUPYTER_RUNTIME_DIR = Path("/media/cfs/dengjinqiu/.local/share/jupyter/runtime")
KERNEL_PREFIX = "jinqiu-"
KERNEL_SUFFIX = ".ipynb"
KERNEL_EXEC = "/home/dengjinqiu/.codex_remote_skills/jupyter-spark/jupyter_kernel_exec.py"
PYTHON_BIN = "/opt/conda/bin/python"
LOG_FILE = "/tmp/jinqiu_spark_session_watchdog.log"
LOCK_FILE = "/tmp/jinqiu_spark_session_watchdog.lock"

CHECK_CODE = """
import json
status = "inactive"
try:
    spark_obj = globals().get("spark", None)
    if spark_obj is not None:
        _ = spark_obj.sparkContext.version
        status = "active"
except Exception:
    status = "inactive"
print(json.dumps({"spark_status": status}))
"""


def log(message: str) -> None:
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"[{datetime.now().strftime('%F %T')}] {message}\\n")


def find_jupyter_server_info() -> tuple[str | None, int | None, str | None, str | None]:
    ps = subprocess.run(["ps", "-eo", "args"], capture_output=True, text=True, check=False)
    if ps.returncode != 0:
        log(f"ps failed: {ps.stderr.strip()}")
        return None, None, None

    token = None
    port = None
    host = None
    base_url = None

    for line in ps.stdout.splitlines():
        if "jupyter-lab" not in line and "jupyter-notebook" not in line and "jupyter-labhub" not in line:
            continue
        if "IdentityProvider.token" not in line:
            continue
        token_match = re.search(r"--IdentityProvider\.token=([^\s]+)", line)
        if token_match:
            token = token_match.group(1)
        port_match = re.search(r"--port=(\d+)", line)
        if port_match:
            port = int(port_match.group(1))
        ip_match = re.search(r"--ip=([^\s]+)", line)
        if ip_match:
            host = ip_match.group(1)
        base_url_match = re.search(r"--ServerApp\.base_url=([^\s]+)", line)
        if base_url_match:
            base_url = base_url_match.group(1)
        if token:
            return host or "127.0.0.1", port or 8888, base_url or "/", token

    candidates = sorted(glob.glob(str(JUPYTER_RUNTIME_DIR / "jpserver-*.json")))
    for candidate in reversed(candidates):
        try:
            with open(candidate, "r", encoding="utf-8") as f:
                data = json.load(f)
            token = token or data.get("token")
            port = port or data.get("port")
            if not host and data.get("url"):
                try:
                    parsed = urllib.parse.urlparse(data.get("url"))
                    host = host or parsed.hostname
                except Exception:
                    pass
            if not base_url and data.get("url"):
                try:
                    parsed = urllib.parse.urlparse(data.get("url"))
                    base_url = base_url or (parsed.path or "/")
                except Exception:
                    pass
            if token:
                return host or "127.0.0.1", int(port or 8888), base_url or "/", token
        except Exception:
            continue
    return None, None, None, None


def list_active_jinqiu_sessions(jupyter_host: str, jupyter_port: int, base_url: str, token: str) -> list[tuple[str, str]]:
    base = base_url if base_url.endswith("/") else f"{base_url}/"
    url = f"http://{jupyter_host}:{jupyter_port}{base}api/sessions?token={token}"
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=10) as resp:
        sessions = json.loads(resp.read().decode("utf-8"))

    targets = []
    for session in sessions:
        path = session.get("path") or session.get("name") or ""
        kernel = session.get("kernel") or {}
        kernel_id = kernel.get("id")
        if not kernel_id:
            continue
        base = os.path.basename(path)
        if base.startswith(KERNEL_PREFIX) and base.endswith(KERNEL_SUFFIX):
            targets.append((base, kernel_id))
    return targets


def run_in_kernel(connection_file: str, code: str, timeout_sec: int = 600) -> tuple[int, str, str]:
    cmd = [
        PYTHON_BIN,
        KERNEL_EXEC,
        "--connection-file",
        connection_file,
        "--code",
        code,
    ]
    proc = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout_sec,
        check=False,
    )
    return proc.returncode, proc.stdout or "", proc.stderr or ""


def parse_status(output: str) -> str:
    for line in reversed(output.splitlines()):
        line = line.strip()
        if not line:
            continue
        try:
            payload = json.loads(line)
            if isinstance(payload, dict) and "spark_status" in payload:
                return str(payload["spark_status"]).lower()
        except json.JSONDecodeError:
            continue
    return "unknown"


def ensure_spark(kernel_name: str, connection_id: str) -> None:
    connection_file = JUPYTER_RUNTIME_DIR / f"kernel-{connection_id}.json"
    if not connection_file.exists():
        log(f"{kernel_name}: missing connection file {connection_file}")
        return

    rc, out, err = run_in_kernel(str(connection_file), CHECK_CODE)
    status = parse_status(out)
    if status == "active":
        log(f"{kernel_name}: spark already active")
        return

    log(f"{kernel_name}: spark inactive (status={status}); create new spark session")
    if err.strip():
        log(f"{kernel_name}: check stderr: {err.strip()}")

    create_code = f"""
from pyspark.sql import SparkSession
import json
spark = SparkSession.builder.appName("{kernel_name[:-6]}").getOrCreate()
print(json.dumps({{"spark_status": "active", "app_name": "{kernel_name[:-6]}"}}))
"""
    rc, out, err = run_in_kernel(str(connection_file), create_code)
    status_after = parse_status(out)
    if rc == 0 and status_after == "active":
        log(f"{kernel_name}: spark started")
        return

    log(f"{kernel_name}: failed to start spark (rc={rc})")
    if out.strip():
        log(f"{kernel_name}: create stdout: {out.strip()}")
    if err.strip():
        log(f"{kernel_name}: create stderr: {err.strip()}")


def main() -> None:
    with open(LOCK_FILE, "a", encoding="utf-8") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except OSError:
            log("another watchdog process is already running, skip")
            return

        if not os.path.exists(KERNEL_EXEC):
            log(f"kernel exec script not found: {KERNEL_EXEC}")
            return

        host, port, base_url, token = find_jupyter_server_info()
        if not token or not port:
            log("cannot find running jupyter server token/port")
            return

        try:
            sessions = list_active_jinqiu_sessions(host, port, base_url or "/", token)
        except urllib.error.URLError as e:
            log(f"failed to fetch jupyter sessions: {e}")
            return
        except Exception as e:
            log(f"error loading sessions: {e}")
            return

        if not sessions:
            log("no active jinqiu kernels found")
            return

        for name, kernel_id in sessions:
            ensure_spark(name, kernel_id)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        log(f"UNHANDLED ERROR: {e}")
