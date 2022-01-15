local naughty = require('naughty')

function debug(msg)
  naughty.notify({ title = "Achtung!", text = msg, timeout = 0 })
end

