local awful = require('awful');
local config = require('helpers.config');
local gears = require('gears');
local naughty = require('naughty');
local bling = require("bling")

-- MODKEY
modkey = 'Mod4'
alt = 'Mod1'

local vol_timer = nil

local bar_visibility = {};
awful.screen.connect_for_each_screen(function(s) bar_visibility[s.index] = true end);

local function init_vol_timer()
  vol_timer = gears.timer {
    timeout   = 2,
    autostart = true,
    single_shot  = true,
    callback  = function()
      local media_view = root.elements.hub_views[6]
      media_view.view.left = config.global.m
      media_view.view.right = config.global.m

      media_view.view:get_children_by_id("view_background_role")[1].spacing = config.global.m

      media_view.view.title.visible = true
      media_view.view.close.visible = true
      root.elements.hub.nav.visible = true
      root.elements.hub.width = config.hub.w
      root.elements.hub.height = config.hub.h
      root.elements.hub.bg = config.colors.f
      root.elements.hub.close()
    end
  }
end

local function vol()
  local media_view = root.elements.hub_views[6]
  media_view.view.refresh()
  media_view.view.left = 0
  media_view.view.right = 0

  media_view.view:get_children_by_id("view_background_role")[1].spacing = 4

  media_view.view.title.visible = false
  media_view.view.close.visible = false
  root.elements.hub.nav.visible = false
  root.elements.hub.width = config.hub.w - config.hub.nw
  root.elements.hub.height = 357
  root.elements.hub.bg = config.colors.t
  root.elements.hub.enable_view_by_index(6, mouse.screen, 'vol')
  if vol_timer ~= nil then vol_timer:again() else init_vol_timer() end
end

function reset_fullscreen()
  for _, c in ipairs(client.get()) do
    if c.fullscreen and c.fake_full == false then c:emit_signal("reset_fullscreen") end
  end
end

--GLOBAL KEYBINDS/BUTTONS
local key_bindings = gears.table.join({
  awful.key({ modkey }, "Return", function() awful.spawn(config.commands.terminal) end),
  awful.key({ modkey }, "c", function() awful.spawn(config.commands.editor) end),
  awful.key({ modkey, alt }, "b", function() awful.spawn(config.commands.browser) end),
  awful.key({ modkey }, "b", function() awful.spawn(config.commands.browser .. " --incognito") end),
  awful.key({ modkey }, "f", function() awful.spawn(config.commands.files) end),
  awful.key({ modkey }, "n", function() awful.spawn(config.commands.nvidia) end),
  awful.key({ modkey }, "space", function() awful.spawn(config.commands.rofi) end),

  awful.key({ modkey, "Shift" }, "q", function() if root.elements.powermenu then root.elements.powermenu.show() end end),
  awful.key({ modkey, "Control" }, "q", function() awesome.quit() end),
  awful.key({ modkey, "Shift" }, "l", function() if root.elements.powermenu then root.elements.powermenu.lock() end end),
  -- awful.key({ modkey, "Shift" }, "r", function() if root.elements.powermenu then root.elements.powermenu.lock(awesome.restart) end end),
  awful.key({ modkey, "Shift" }, "r", awesome.restart),

  awful.key({ modkey, "Shift"}, "b", function()
    local screen_idx = awful.screen.focused().index

    if bar_visibility[screen_idx] == true then
      root.elements.topbar.hide(screen_idx)
      bar_visibility[screen_idx] = false
    else
      root.elements.topbar.show(screen_idx)
      bar_visibility[screen_idx] = true
    end
  end),

  awful.key({ modkey }, "j", function()
    reset_fullscreen()
    awful.client.focus.byidx(-1)
  end),
  awful.key({ modkey }, "k", function()
    reset_fullscreen()
    awful.client.focus.byidx(1)
  end),

  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),

  -- toggle client stack order
  awful.key({ modkey, "Shift" }, "s", function() bottom = not bottom end),
  awful.key({ modkey, "Shift" }, "Return", function() awful.client.setmaster(client.focus) end),

  -- Resize
  awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end),
  awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(1) end),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(-1) end),

  awful.key({ modkey }, "m", function() awful.layout.set(awful.layout.suit.max) end),
  awful.key({ modkey }, "t", function() awful.layout.set(awful.layout.suit.tile) end),
  awful.key({ modkey }, "a", function() awful.spawn("instantassist") end),
  awful.key({ modkey }, "v", function() root.elements.hub.enable_view_by_index(5, mouse.screen) end),

  -- Save / Restore
  awful.key({ modkey }, "s", function()
    naughty.notify({ title = "Persistance", text = "Saved Layout" })
    bling.module.persistent:save()
  end),
  awful.key({ modkey }, "o", function()
    naughty.notify({ title = "Persistance", text = "Restored Layout" })

    local args = args or {}
    args.create_clients = args.create_clients == nil and true or args.create_clients
    bling.module.persistent:restore(args)
  end),

  -- Screenshot
  awful.key({ modkey }, "Print", function() awful.spawn.with_shell(config.commands.scrotclip) end),
  awful.key({ modkey, "Shift" }, "Print", function() awful.spawn.with_shell(config.commands.scrot) end),
  awful.key({ modkey, "Control" }, "Print", function() awful.spawn.with_shell(config.commands.scrotclipsave) end),

  awful.key {
    modifiers = { modkey, "Shift" },
    keygroup    = "numrow",
    description = "move focused client to tag",
    group       = "tag",
    on_press    = function (index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  },

  awful.key({}, "XF86AudioRaiseVolume", function ()
    awful.spawn.easy_async(config.commands.volup, vol);
  end),
  awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn.easy_async(config.commands.voldown, vol);
  end),
  awful.key({modkey, "Shift" }, "Up", function ()
    awful.spawn.easy_async(config.commands.volup, vol);
  end),
  awful.key({modkey, "Shift" }, "Down", function ()
    awful.spawn.easy_async(config.commands.voldown, vol);
  end),

  awful.key({}, "XF86AudioMute", function()
      awful.util.spawn(config.commands.mute) end),
  awful.key({modkey, "Shift", "Control"}, "d", function() awful.spawn.easy_async(config.commands.voldown, vol) end),
  awful.key({modkey, "Shift", "Control"}, "u", function() awful.spawn.easy_async(config.commands.volup, vol) end),

  awful.key({modkey, "Shift"}, "s", function() awful.spawn.with_shell(config.commands.switch_inputs) end),
})

return key_bindings

