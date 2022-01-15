local os = require('os');
local gears = require('gears');
local awful = require('awful');
local wibox = require('wibox');
local ruled = require('ruled');
local naughty = require('naughty');
local config = require('helpers.config');
local beautiful = require('beautiful');
local key_bindings = require('helpers.keybindings')
local inspect = require('inspect')
require('./errors')();

local beautiful = require("beautiful")
beautiful.init(gears.filesystem.get_configuration_dir() .. '/bling_theme.lua')

local bling = require("bling")
bling.module.flash_focus.enable()

local capi = {
  awesome = awesome,
  screen = screen
}

-- ELEMENT STORE
root.elements = root.elements or {}

-- THEME
beautiful.useless_gap = 3
beautiful.border_width = 3

-- MODKEY
modkey = 'Mod4'
alt = 'Mod1'


-- LAYOUTS
tag.connect_signal('request::default_layouts', function()
  awful.layout.append_default_layouts({
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.fair,
  });
end);

-- TAGS/LAYOUTS
screen.connect_signal('request::desktop_decoration', function(s)
  local tags = {}
  local tag_size = 4

  for i = ((s.index - 1) * tag_size) + 1, s.index * tag_size, 1
  do
    tags[i - ((s.index - 1) * tag_size)] = i
  end

  awful.tag(tags, s, awful.layout.layouts[1])

  s.tags[1]:view_only();
end);

-- ELEMENTS
if not root.elements.hub then require('elements.hub')() end;
if not root.elements.topbar then require('elements.topbar')() end;
if not root.elements.tagswitcher then require('elements.tagswitch')() end;
if not root.elements.powermenu then require('elements.powermenu')() end;

local last_client = nil;
local bottom = true;

for _, key in ipairs(key_bindings) do
  awful.keyboard.append_global_keybinding(key)
end

awful.keygrabber {
  keybindings = {
    {{ modkey }, 'r', function() last_client = client.focus end}
  },
  stop_key           = modkey,
  stop_event         = 'release',
  stop_callback      = function()
    if last_client ~= nil then
      client.focus:swap(last_client)
      client.focus = last_client
    end;
  end,
  export_keybindings = true,
}

local function is_ultra_wide()
  local s = mouse.screen
  return (s.workarea.width - s.workarea.x) / s.geometry.height > 1.7777777777777777
end

local function setup_columns(t)
  local t = awful.screen.focused().selected_tag

  if is_ultra_wide() then
    if t.col_count == nil then t.col_count = 2 end

    if t.layout.name == "tile" and t.col_count < 3 then
      awful.tag.incncol(1, t)
      t.master_width_factor = 0.38
      t.col_count = 3
    end
  end
end

client.connect_signal("unfocus", function(c)
  c.border_color = config.colors.t
end)

tag.connect_signal("property::layout", function() setup_columns() end)

-- TAG KEYBINDS
for i = 0, 9 do
  local spot = i;
  if(spot == 10) then spot = 0 end

  awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, spot, function()
      local tag = root.tags()[i];
      if tag then tag:view_only() end;
    end),
    awful.key({ modkey, 'Shift'}, spot, function()
      local tag = root.tags()[i];
        if tag and client.focus then client.focus:move_to_tag(tag) end;
        tag:view_only();
      end)
    });
  end

  awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
      if root.elements.hub then root.elements.hub.close() end
    end),
    awful.button({}, 3, function()
      root.elements.hub.enable_view_by_index(5, mouse.screen);
    end),
  });

  client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
  end)

  local function get_tab_container()
    local t = awful.screen.focused().selected_tag

    if t ~= nil then
      for _, c in ipairs(t:clients()) do
        if c and c.bling_tabbed then return c.bling_tabbed end
      end
    end

    return nil
  end

  local function reset_mfact()
    local num_clients = count_clients(true)
    local t = awful.screen.focused().selected_tag

    if is_ultra_wide() and num_clients > 2 then
      t.master_width_factor = 0.38
    else
      t.master_width_factor = 0.5
    end
  end

  -- CLIENT KEYBINDS & BUTTONS
  client.connect_signal("request::default_keybindings", function(c)
    awful.keyboard.append_client_keybindings({
      awful.key({ modkey }, "q", function (c) c.kill(c) end),
      awful.key({ modkey, "Control" }, "Right", function(c) c:move_to_screen(c.screen.index+1) end),
      awful.key({ modkey, "Control" }, "Left", function(c) c:move_to_screen(c.screen.index-1) end),
      awful.key({ modkey, "Control" }, "f", function(c) c.fullscreen = not c.fullscreen end),
      awful.key({ modkey, "Shift" }, "f", function(c)
        c.fake_full = not c.fake_full
        if c.fake_full then c.fullscreen = true end
      end),
      awful.key({ modkey }, 'y', function(c) bling.module.tabbed.init(c) end),
      awful.key({ modkey, "Control" }, 'r', function(c)
        bling.module.tabbed.add(c, get_tab_container())
        reset_mfact()
      end),
      awful.key({ modkey, alt }, 'r', function(c)
        bling.module.tabbed.remove(c)
        reset_mfact()
      end),
    });
  end);

  client.connect_signal("request::default_mousebindings", function(c)
    awful.mouse.append_client_mousebindings({
      awful.button({}, 1, function (c)
        if root.elements.hub then root.elements.hub.close() end
        c:activate { context = "mouse_move", raise = true }
      end),
      awful.button({ modkey }, 1, function (c)
        if not c.floating then c.floating = true end
        c:activate { context = "mouse_click", action = "mouse_move" }
      end),
      awful.button({ modkey, "Shift" }, 1, function (c)
        if not c.floating then c.floating = true end
        c.above = true
        c.ontop = true
        c:activate { context = "mouse_click", action = "mouse_move" }
      end),
      awful.button({ modkey, "Shift" }, 3, function (c)
        if not c.minimized then c.minimized = true end
      end),
      awful.button({ modkey }, 3, function (c)
        c:activate { context = "mouse_click", action = "mouse_resize" }
      end),
      awful.button({ modkey }, 2, function (c)
        if c.floating then
          c.floating = false
          c:emit_signal("tiled")
        end
      end),
      awful.button({ modkey, "Shift" }, 4, function()
        awful.client.swap.byidx(1);
      end),
      awful.button({ modkey, "Shift" }, 5, function()
        awful.client.swap.byidx(-1);
      end),
      awful.button({ modkey }, 4, function()
        bling.module.tabbed.iter()
      end),
      awful.button({ modkey }, 5, function()
        bling.module.tabbed.iter()
      end)
    });
  end);

  -- RULES
  ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
      id         = "global",
      rule       = { },
      properties = {
        focus     = awful.client.focus.filter,
        raise     = true,
        screen    = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        fake_full = false
      }
    }

    ruled.client.append_rule {
      rule_any = {
        class = { "brave-browser", "Brave-browser" }
      },
      properties = {
        fake_full = true
      }
    }

    -- Floating clients.
    ruled.client.append_rule {
      id       = "floating",
      rule_any = {
        instance = { "copyq", "pinentry" },
        class    = {
          "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
          "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer",
          "Nautilus", "Pavucontrol"
        },
        name    = {
          "Event Tester",
          "Media viewer"
        },
        role    = {
          "AlarmWindow",
          "ConfigManager",
          "pop-up",
        }
      },
      properties = {
        raise = true,
        floating = true,
        placement = awful.placement.centered
      }
    }

    ruled.client.append_rule {
      rule_any = {
        class = { "csgo_linux64", "love", "steam_app_311210", "mpv", "openrct2", "Parkitect.x86_64" }
      },
      properties = {
        raise = true,
        fullscreen = true,
        hover_focus = false,
        callback = function(c)
          if c.minimized == true then
            c.minimized = false
          end

          awful.spawn.with_shell("easyeffects --gapplication-service");

          function spawn_picom()
            awful.spawn.easy_async_with_shell("pgrep picom", function(o)
              if o == '' then
                awful.spawn.with_shell("$HOME/.config/awesome/scripts/compositor.sh");
              end
            end)
          end

          local fullscreen_timer = gears.timer {
            timeout   = 2,
            autostart = true,
            callback  = function()
              if not c.fullscreen then
                spawn_picom()
              else
                awful.spawn.with_shell("killall picom");
              end
            end
          }

          local time_tracker = gears.timer {
            timeout   = 2,
            single_shot = true,
            autostart = true,
            callback  = function()
              awful.spawn.easy_async_with_shell("~/Documents/time-tracker.vsh --insert " .. c.class, function(stdout, stderr, reason, exit_code)
                naughty.notify({ title = 'TimeTracker', text = stdout, timeout = 0 })
              end)
            end
        }

        client.connect_signal("unmanage", function(c_unmanage)
          if c == c_unmanage then
            fullscreen_timer:stop()
            spawn_picom()
          end
        end)

        end
      }
    }

    ruled.client.append_rule {
      id         = "titlebars",
      rule_any   = { type = { "normal", "dialog" } },
      properties = { titlebars_enabled = true      }
    }
  end);

  -- NOTIFICATIONS
  ruled.notification.connect_signal('request::rules', function()
    ruled.notification.append_rule {
      rule = {},
      properties = { timeout = 0 }
    }
  end);

  function count_clients(consider_floats)
    local n = 0

    local t = awful.screen.focused().selected_tag

    if t ~= nil then
      for _, c in ipairs(t:clients()) do
        if (c.floating == true or c.minimized == true) and consider_floats == true then goto skip end
        n = n + 1
        ::skip::
      end
    end

    return n
  end

  client.connect_signal("manage", function(c)
    if bottom then awful.client.setslave(c) end

    c:emit_signal("client_change")
  end)

  client.connect_signal("unmanage", function(c)
    c:emit_signal("client_change")
  end)

  client.connect_signal("client_change", function()
    reset_mfact()
    setup_columns()

    -- https://www.reddit.com/r/awesomewm/comments/k5otdr/raise_2nd_highest_client_window_on_close/ggjom5n?utm_source=share&utm_medium=web2x&context=3
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c == nil then return end
    awful.client.focus.byidx(0, c)
  end)

  client.disconnect_signal("request::geometry", awful.ewmh.geometry)
  client.connect_signal("request::geometry", function(c, context, ...)
    if context ~= "fullscreen" then
      awful.ewmh.geometry(c, context, ...)
    else
      if c.fake_full then
        local geo = c:geometry()

        c:geometry({
          width = geo.width,
          height = geo.height - 1
        })

        gears.timer {
          timeout   = 0.2,
          autostart = true,
          single_shot = true,
          callback  = function()
            c.fullscreen = false
            geo.height = geo.height + 1
          end
        }
      else
        awful.ewmh.geometry(c, context, ...)
      end
    end
  end)

  client.connect_signal("property::minimized", function(c) reset_mfact() end)

  -- switch to client of other tag
  client.connect_signal("request::activate", function(c)
    if c then
      local client_tag = c.first_tag
      local current_tag = awful.screen.focused().selected_tag

      if client_tag ~= current_tag then
        client_tag:view_only()
      end
    end
  end)

  client.connect_signal("property::floating", function(c)
    if c.floating and c.fake_full ~= false and not c.fullscreen then
      c.above = true
      c.ontop = true
    end

    reset_mfact()
  end)

  client.connect_signal("tiled", function(c)
    c:lower()
    c.above = false
    c.ontop = false
  end)

  client.connect_signal("reset_fullscreen", function(c)
    if c.fake_full == false and c.fullscreen then
      c.fullscreen = not c.fullscreen
      c:emit_signal("tiled")
    end
  end)

  -- SPAWNS
  awful.spawn.with_shell("$HOME/.config/awesome/scripts/screen.sh");
  awful.spawn.with_shell("$HOME/.config/awesome/scripts/wallpaper.sh");
  awful.spawn.with_shell("$HOME/.config/awesome/scripts/compositor.sh");
  awful.spawn.with_shell("nm-applet &");
  awful.spawn.with_shell('instantmouse g && instantmouse s "$(iconf mousespeed)"');
  awful.spawn.with_shell("numlockx");

  -- IDLE
  awful.spawn.with_line_callback(config.commands.idle, {
    stdout = function(o)
      if o == 'lock' and root.elements.powermenu then
        root.elements.powermenu.lock();
      elseif o == 'suspend' then
        awful.spawn(config.commands.suspend);
      end
    end
  });

  os.execute('sleep 0.1');
  if root.elements.topbar then root.elements.topbar.show() end;

  awful.layout.set(awful.layout.suit.max)
  awful.layout.set(awful.layout.suit.tile)
