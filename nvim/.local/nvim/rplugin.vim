" perl plugins


" node plugins


" python3 plugins
call remote#host#RegisterPlugin('python3', '/Users/dengjinqiu/.config/nvim/plugged/nvim-ipy/rplugin/python3/nvim_ipy', [
      \ {'sync': v:false, 'name': 'IPyComplete', 'type': 'function', 'opts': {}},
      \ {'sync': v:true, 'name': 'IPyConnect', 'type': 'function', 'opts': {}},
      \ {'sync': v:false, 'name': 'IPyInterrupt', 'type': 'function', 'opts': {}},
      \ {'sync': v:false, 'name': 'IPyObjInfo', 'type': 'function', 'opts': {}},
      \ {'sync': v:true, 'name': 'IPyOmniFunc', 'type': 'function', 'opts': {}},
      \ {'sync': v:false, 'name': 'IPyRun', 'type': 'function', 'opts': {}},
      \ {'sync': v:false, 'name': 'IPyTerminate', 'type': 'function', 'opts': {}},
      \ {'sync': v:true, 'name': 'IPyDbgWrite', 'type': 'function', 'opts': {}},
     \ ])


" ruby plugins


