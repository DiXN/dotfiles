local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local rounded = require('helpers.rounded');
local beautiful = require('beautiful');
local xrdb = beautiful.xresources.get_current_theme();
local config = require('helpers.config');
local awful = require('awful');

function toggle_tag_switcher()
  awful.screen.connect_for_each_screen(function(screen)
    screen.tagswitch.visible = not screen.tagswitch.visible;
    screen.taskpop.visible = not screen.taskpop.visible
  end);

  for _, c in ipairs(client.get()) do
    if c.fullscreen and c.fake_full == false then c:emit_signal("reset_fullscreen") end
  end
end

function add_new_tag()
  local total = root.tags();

  if(#total >= 10) then return end;

  awful.tag.add(#total+1, {
    screen = awful.screen.focused(),
    layout = awful.screen.focused().selected_tag.layout,
  });

  local stags = awful.screen.focused().tags;
  local switcher = awful.screen.focused().tagswitch;
  switcher.width = ((100+config.global.m) * (#stags+1)) + config.global.m;
  switcher.x = switcher.x - 55;
end

function delete_tag(t)
  t:delete();
  local stags = awful.screen.focused().tags;
  local switcher = awful.screen.focused().tagswitch;
  switcher.width = ((100+config.global.m) * (#stags+1)) + config.global.m;
  if(#stags == 1) then return end;
  switcher.x = switcher.x + 55;
end

function popup(s)
  local pop = awful.popup {
    screen = s,
    widget = awful.widget.tasklist {
      screen   = s,
      filter   = awful.widget.tasklist.filter.currenttags,
      buttons  = tasklist_buttons,
      style    = {
        shape = gears.shape.rounded_rect,
      },
      layout   = {
        spacing = 10,
        layout = wibox.layout.grid.horizontal
      },
      widget_template = {
        {
          {
            id     = 'clienticon',
            widget = awful.widget.clienticon,
          },
          margins = 20,
          widget  = wibox.container.margin,
        },
        id              = 'background_role',
        forced_width    = 128,
        forced_height   = 128,
        bg     = '#ff00ff',
        widget          = wibox.container.background,
        create_callback = function(self, c, index, objects) --luacheck: no unused
          self:get_children_by_id('clienticon')[1].client = c
        end,
      },
    },
    border_width = 0,
    ontop        = true,
    placement    = awful.placement.centered,
    shape        = gears.shape.rounded_rect,
    bg     = config.colors.t,
    visible = false
  }

  return pop
end

function make_taglist(s)
  local w = ((100+config.global.m) * (#s.tags+1)) + config.global.m;
  local container = wibox({
    height = config.tagswitcher.h,
    width = w,
    type = "toolbar",
    screen = s,
    ontop = true,
    visible = false,
    bg = config.colors.f,
    fg = config.colors.xf,
  });

  local buttons = gears.table.join(
    awful.button({ 'Mod4' }, 1, function(t) t:view_only() end),
    awful.button({ 'Mod4' }, 3, delete_tag)
  );

  local taglist = awful.widget.taglist({
    screen = s,
    buttons = buttons,
    filter = awful.widget.taglist.filter.all,
    style = {
      fg_focus = config.colors.w,
      bg_focus = config.colors.x4,
      shape_focus = rounded(),
    },
    widget_template = {
      layout = wibox.container.margin,
      right = config.global.m,
      {
        id = "background_role",
        layout = wibox.container.background,
        bg = config.colors.f,
        shape = rounded(),
        forced_width = 100,
        forced_height = 100,
        {
          id = "text_role",
          widget = wibox.widget.textbox,
          font = config.fonts.t.." Bold 30",
          align = 'center',
          valign = 'center',
        }
      }
    }
  });

  local add = wibox.container.background();
  add.bg = config.colors.f;
  add.forced_height = 100;
  add.forced_width = 100;
  add.shape = rounded();
  add:buttons(gears.table.join(
    awful.button({ 'Mod4' }, 1, add_new_tag)
  ));

  add:setup {
    widget = wibox.widget.textbox,
    text = "󱇬",
    font = "MaterialDesignIconsDesktop 15",
    align = 'center',
    valign = 'center',
  }

  container.x = ((s.workarea.width / 2) - w/2) + s.workarea.x;
  container.y = s.workarea.height - (config.tagswitcher.h+config.global.m);
  container.shape = rounded();

  container:setup {
    layout = wibox.container.margin,
    top = config.global.m, bottom = config.global.m, left = config.global.m,
    {
      layout = wibox.layout.fixed.horizontal,
      taglist,
      add,
    }
  }

  return container;
end

return function()
  awful.screen.connect_for_each_screen(function(screen)
    screen.tagswitch = make_taglist(screen);
    screen.taskpop = popup(screen)
  end);

  awful.keygrabber {
    keybindings = {
      {{'Mod4'}, 'Tab', function() awful.tag.viewnext(awful.screen.focused()) end},
      {{'Mod4', 'Shift'}, 'Tab', function() awful.tag.viewprev(awful.screen.focused()) end}
    },
    stop_key = 'Mod4',
    stop_event = 'release',
    export_keybindings = true,
    start_callback = toggle_tag_switcher,
    stop_callback = toggle_tag_switcher,
  }
end
