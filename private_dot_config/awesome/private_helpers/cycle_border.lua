local awful = require('awful');
local gears = require('gears');
local naughty = require('naughty');

-- Animate active borders
-- Gradient generator, adapted from https://krazydad.com/tutorials/makecolors.php
-- based on: https://www.reddit.com/r/awesomewm/comments/mmt4ms/colour_cycling_active_window_border_snippet/
border_animate_colours = {}
function make_color_gradient(frequency1, frequency2, frequency3, phase1, phase2, phase3, center, width, len)
  if center == nil   then center = 128 end
  if width == nil    then width = 127 end
  if len == nil      then len = 120 end
  gen_loop = 0

  while gen_loop < len do
    red = string.format("%02x", (math.floor(math.sin(frequency1*gen_loop + phase1) * width + center)))
    grn = string.format("%02x", (math.floor(math.sin(frequency2*gen_loop + phase2) * width + center)))
    blu = string.format("%02x", (math.floor(math.sin(frequency3*gen_loop + phase3) * width + center)))
    border_animate_colours[gen_loop] = "#"..red..grn..blu
    gen_loop = gen_loop + 1
  end
end

red_frequency = .11
green_frequency = .13
blue_frequency = .17

phase1 = 0
phase2 = 10
phase3 = 30

center = 180
width = 40
len = 80

make_color_gradient(red_frequency,green_frequency,blue_frequency,phase1,phase2,phase3,center,width,len)

border_loop = 1
border_animation_timer = gears.timer {
  timeout   = 0.05,
  call_now  = true,
  autostart = true,
  callback  = function()
    local c = client.focus

    if c then
      local tags = c.screen.tags

      for _, t in ipairs(tags) do
        if t.selected then
          local clients = t:clients()
          clients_count = #clients

          if clients_count > 1 and c then
            c.border_color = border_animate_colours[border_loop]
            if not border_loop_reverse then
              border_loop = border_loop + 1
              if border_loop >= len then border_loop_reverse = true end
            end
            if border_loop_reverse then
              border_loop = border_loop - 1
              if border_loop <= 1 then border_loop_reverse = false end
            end
          end

          return
        end
      end
    end
  end
}

