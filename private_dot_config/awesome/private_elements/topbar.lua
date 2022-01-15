local awful = require('awful');
local wibox = require('wibox');
local gears = require('gears');
local naughty = require('naughty');
local beautiful = require('beautiful');
local config = require('helpers.config');
local rounded = require('helpers.rounded');
local gfs = require('gears.filesystem')
local themes_path = gfs.get_themes_dir()
local xrdb = beautiful.xresources.get_current_theme();

root.elements = root.elements or {};

local capi = {
  awesome = awesome,
  screen = screen
}

function make_launcher(s)
  local launcher = wibox({
    screen = s,
    type = 'menu',
    visible = false,
    width = config.topbar.w,
    height = config.topbar.h,
  });

  launcher:setup {
    layout = wibox.container.margin,
    forced_width = config.topbar.w,
    forced_height = config.topbar.h,
    {
      layout = wibox.container.background,
      bg = config.colors.x4,
      fg = config.colors.w,
      {
        layout = wibox.container.place,
        {
          widget = wibox.widget.textbox,
          text = config.icons.arch,
          font = config.fonts.im,
        }
      }
    }
  }

  launcher:struts({ top = config.topbar.h + config.global.m });
  launcher.x = s.workarea.x + config.global.m;
  launcher.y = config.global.m;
  launcher:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.spawn(config.commands.rofi2);
    end)
  ));

  root.elements.launcher = root.elements.launcher or {};
  root.elements.launcher[s.index] = launcher;
end

function make_power(s)
  local power = wibox({
    screen = s,
    type = 'menu',
    visible = false,
    width = config.topbar.w,
    height = config.topbar.h,
  });

  power:setup {
    layout = wibox.container.margin,
    forced_width = config.topbar.w,
    forced_height = config.topbar.h,
    {
      layout = wibox.container.background,
      bg = config.colors.x9,
      fg = config.colors.w,
      {
        layout = wibox.container.place,
        {
          widget = wibox.widget.textbox,
          text = config.icons.power,
          font = config.fonts.im,
        }
      }
    }
  }

  power:struts({ top = config.topbar.h + config.global.m });
  power.x = (s.workarea.width - (config.topbar.w + config.global.m)) + s.workarea.x;
  power.y = config.global.m;
  power:buttons(gears.table.join(
    awful.button({}, 1, function()
      if root.elements.powermenu.show then root.elements.powermenu.show() end
    end)
  ));

  root.elements.power = root.elements.power or {};
  root.elements.power[s.index] = power;
end

function make_date(s)
  local date = wibox({
    screen = s,
    type = "dock",
    visible = false,
    bg = config.colors.t,
    height = config.topbar.h,
    width = config.topbar.dw,
  });

  date:setup {
    layout = wibox.container.place,
    valign = "center",
    {
      widget = wibox.widget.textclock,
      font = config.fonts.tlb;
      refresh = 1,
      format = config.icons.date..' %a, %b %-d  <span font="'..config.fonts.tll..'">'..config.icons.time..' %-H:%M:%S </span>';
    },
  };

  date.x = ((s.workarea.width - (config.topbar.w + (config.global.m*2))) + s.workarea.x) - config.topbar.dw;
  date.y = config.global.m;
  date:buttons(gears.table.join(awful.button({ }, 1, function()
    if not root.elements.hub then return end;
    root.elements.hub.enable_view_by_index(2, mouse.screen, "right");
  end)));

  root.elements.date = root.elements.date or {};
  root.elements.date[s.index] = date;
end

function make_layoutbox(s)
  local l = awful.widget.layoutbox {
    screen  = s,
    buttons = {
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc(-1) end),
      awful.button({ }, 4, function () awful.layout.inc(-1) end),
      awful.button({ }, 5, function () awful.layout.inc( 1) end),
    }
  }

  beautiful.layout_fairh = themes_path.."default/layouts/fairhw.png"
  beautiful.layout_fairv = themes_path.."default/layouts/fairvw.png"
  beautiful.layout_floating  = themes_path.."default/layouts/floatingw.png"
  beautiful.layout_max = themes_path.."default/layouts/maxw.png"
  beautiful.layout_tile = themes_path.."default/layouts/tilew.png"
  beautiful.layout_spiral  = themes_path.."default/layouts/spiralw.png"
  beautiful.layout_dwindle = themes_path.."default/layouts/dwindlew.png"

  local layout = wibox({
    screen = s,
    type = 'dock',
    height = config.topbar.h,
    width = config.topbar.h,
    bg = config.colors.t,
    shape = rounded(),
    shape_clip = true,
    widget = l,
  })

  layout:struts({ top = config.topbar.h + config.global.m });
  layout.x = ((s.workarea.width - (config.topbar.w + (config.global.m*2))) + s.workarea.x) - config.topbar.dw - 40;
  layout.y = config.global.m;

  root.elements.layout = root.elements.layout or {};
  root.elements.layout[s.index] = layout;
end

-- Scale task list width/spaces form the ultra-wide reference implementation.
local function uw_scaling_factor(s) return (3440 / s.workarea.width - 1) * 50 end

function make_tray(s)
  local t = wibox.widget.systray();
  t.visible = true;
  t:set_reverse(true);

  beautiful.bg_systray = config.colors.b;

  local syst = wibox.widget {
    {
      layout = wibox.container.place,
      valign = "center",
      halign = "right",
      {
        t,
        left   = 5,
        top    = 2,
        bottom = 2,
        right  = 5,
        widget = wibox.container.margin,
      }
    },
    widget = wibox.container.background,
  }

  local tray = wibox({
    screen = s,
    type = 'dock',
    height = config.topbar.h,
    width = 1,
    bg = config.colors.b,
    shape = rounded(),
    shape_clip = true,
    widget = syst,
  })

  t:connect_signal("widget::redraw_needed", function()
    -- local ctx = { screen = s }
    -- local tray_size, _ = t:fit(ctx, config.topbar.hm, config.topbar.h)
    -- tray.width = tray_size
    local num_entries = capi.awesome.systray()
    local width = 1

    if num_entries == 1 then beautiful.systray_icon_spacing = 0  else beautiful.systray_icon_spacing = 5 end
    if num_entries >= 1 then width = num_entries * 32 end

    tray.width = width
    tray:struts({ top = config.topbar.h + config.global.m });

    tray.x = ((s.workarea.width - (config.topbar.w + (config.global.m*2))) + s.workarea.x)
      - config.topbar.dw - 10 - tray.width - 40;

    tray.y = config.global.m;

    -- Update tasklist_r width
    local width_r = (s.workarea.width / 2) - 310
      - (s.workarea.width - root.elements.layout[s.index].x + s.workarea.x) - num_entries * 32 + (uw_scaling_factor(s) * 2);

    root.elements.tasklist[s.index][2].width = width_r
  end)

  root.elements.tray = root.elements.tray or {};
  root.elements.tray[s.index] = tray;
end

function make_icon(i)
  local icon = wibox.widget.textbox(i);
  icon.forced_width = config.topbar.w;
  icon.font = config.fonts.is;

  local container = wibox.widget {
    layout = wibox.container.background,
    bg = config.colors.t,
    fg = config.colors.w,
    icon
  };

  icon.update = function(t,c) icon.markup = '<span color="'..c..'">'..t..'</span>' end;

  return icon;
end

function make_utilities(s)
  local uw = config.global.m-4;
  for _,v in pairs(config.topbar.utilities) do if v then uw = uw + config.topbar.w end end
  if config.topbar.utilities.mem or config.topbar.utilities.pac or config.topbar.utilities.bat or config.topbar.utilities.note then uw = uw + 20 end

  local utilities = wibox({
    screen = s,
    width = uw,
    visible = false,
    type = "utility",
    bg = config.colors.f,
    height = config.topbar.h,
  });

  local layout = wibox.layout.fixed.horizontal();

  if config.topbar.utilities.wifi then
    root.elements.wifi_icons = root.elements.wifi_icons or {};
    root.elements.wifi_icons[s.index] = make_icon(config.icons.wifi);
    layout:add(root.elements.wifi_icons[s.index]);
  end

  if config.topbar.utilities.bt then
    root.elements.bt_icons = root.elements.bt_icons or {};
    root.elements.bt_icons[s.index] = make_icon(config.icons.bt);
    layout:add(root.elements.bt_icons[s.index]);
  end

  if config.topbar.utilities.lan then
    root.elements.lan_icons = root.elements.lan_icons or {};
    root.elements.lan_icons[s.index] = make_icon(config.icons.lan);
    layout:add(root.elements.lan_icons[s.index]);
  end

  if config.topbar.utilities.vol then
    root.elements.vol_icons = root.elements.vol_icons or {};
    root.elements.vol_icons[s.index] = make_icon(config.icons.vol_3);
    layout:add(root.elements.vol_icons[s.index]);
  end

  if config.topbar.utilities.mem or config.topbar.utilities.pac or config.topbar.utilities.bat or config.topbar.utilities.note then
    local sep = wibox.widget.textbox('|');
    sep.opacity = 0.2;
    sep.forced_width = 20;
    sep.font = config.fonts.m..' 14';
    sep.forced_height = config.topbar.h;
    layout:add(sep);;
  end

  if config.topbar.utilities.mem then
    root.elements.mem_icons = root.elements.mem_icons or {};
    root.elements.mem_icons[s.index] = make_icon(config.icons.mem);
    layout:add(root.elements.mem_icons[s.index]);
  end

  if config.topbar.utilities.pac then
    root.elements.pac_icons = root.elements.pac_icons or {};
    root.elements.pac_icons[s.index] = make_icon(config.icons.pac);
    layout:add(root.elements.pac_icons[s.index]);
  end

  if config.topbar.utilities.note then
    root.elements.note_icons = root.elements.note_icons or {};
    root.elements.note_icons[s.index] = make_icon(config.icons.note);
    layout:add(root.elements.note_icons[s.index]);
  end

  if config.topbar.utilities.bat then
    root.elements.bat_icons = root.elements.bat_icons or {};
    root.elements.bat_icons[s.index] = make_icon(config.icons.bat);
    layout:add(root.elements.bat_icons[s.index]);
  end

  utilities:struts({ top = config.topbar.h + config.global.m });
  utilities.y = config.global.m;
  utilities.x = ((s.workarea.width / 2) - (uw/2)) + s.workarea.x;

  utilities:setup {
    layout = wibox.container.margin,
    right = config.global.m,
    left = config.global.m,
    layout
  }

  root.elements.utilities = root.elements.utilities or {};
  root.elements.utilities[s.index] = utilities;
end

function make_taglist(s)
  local taglist = wibox({
    screen = s,
    visible = false,
    type = "utility",
    bg = config.colors.f,
    fg = config.colors.xf,
    width = config.topbar.w,
    height = config.topbar.h,
  });

  taglist:struts({ top = config.topbar.h + config.global.m });
  taglist.x = s.workarea.x + (config.topbar.w + (config.global.m*2));
  taglist.y = config.global.m;

  local tags = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.selected,
    widget_template = {
      layout = wibox.container.margin,
      {
        id = "text_role",
        widget = wibox.widget.textbox,
        font = config.fonts.tmb,
      }
    }
  });

  taglist:setup {
    layout = wibox.container.place,
    valign = "center",
    tags
  }

  root.elements.taglist = root.elements.taglist or {};
  root.elements.taglist[s.index] = taglist;
end

-- based on: https://github.com/awesomeWM/awesome/blob/master/lib/awful/widget/tasklist.lua#L710
local function filter_internals(c, s, condition)
  scr = s
  -- Only print client on the same screen as this widget
  if c.screen ~= scr then return false end

  local tags = scr.tags
  for _, t in ipairs(tags) do
    if t.selected then
      local ctags = c:tags()
      local tag_clients = t:clients()

      -- Hide if there is only 1 client that is not minimized.
      if #tag_clients == 1 and not c.minimized then return false end

      local tags_div = math.floor(#tag_clients / 2)
      local l_clients = #tag_clients - tags_div

      for _, v in ipairs(ctags) do
        if v == t then
          for i, tag_c in ipairs(tag_clients) do
            if tag_c == c and condition(i, l_clients) then
              return true
            end
          end
        else
          return false
        end
      end
    end
  end

  return false
end

function awful.widget.tasklist.filter.client_filter_l(c, s)
  return filter_internals(c, s, function(i, l_clients)
    return i <= l_clients
  end)
end


function awful.widget.tasklist.filter.client_filter_r(c, s)
  return filter_internals(c, s, function(i, l_clients)
    return i > l_clients
  end)
end


function make_tasklist(s)
  local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal("request::activate", "tasklist",
        {raise = true}
      )

      c.above = true
      c.ontop = true
    end
    end),
    awful.button({ }, 4, function ()
      awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
      awful.client.focus.byidx(-1)
    end)
  )


  local uw = config.global.m-4;
  local width = (s.workarea.width / 2) - (config.topbar.w) - uw / 2 - config.global.m * 36 + (uw_scaling_factor(s) * 2);

  local tasklist = wibox({
    screen = s,
    visible = false,
    type = "utility",
    bg = config.colors.t,
    fg = config.colors.xf,
    width = width,
    height = config.topbar.h,
    font = config.fonts.ttl
  });

  -- Create layoutbox already to get offset
  make_layoutbox(s)

  local width_r = (s.workarea.width / 2) - 310
    - (s.workarea.width - root.elements.layout[s.index].x + s.workarea.x) + (uw_scaling_factor(s) * 2);

  local tasklist_r = wibox({
    screen = s,
    visible = false,
    type = "utility",
    bg = config.colors.t,
    fg = config.colors.xf,
    width = width_r,
    height = config.topbar.h,
    font = config.fonts.ttl
  });

  -- tasklist:connect_signal("mouse::leave", function(t) t.visible = false end)

  tasklist:struts({ top = config.topbar.h + config.global.m });
  tasklist.x = s.workarea.x + (config.topbar.w * 2) + config.global.m * 12 - uw_scaling_factor(s);
  tasklist.y = config.global.m;

  tasklist_r:struts({ top = config.topbar.h + config.global.m });
  tasklist_r.x = s.workarea.x + (s.workarea.width / 2) + (config.topbar.dw) - config.topbar.w * 2 - config.global.m - uw_scaling_factor(s);
  tasklist_r.y = config.global.m;

  beautiful.tasklist_bg_normal = config.colors.w .. '60';
  beautiful.tasklist_fg_normal = config.colors.b;
  beautiful.tasklist_bg_minimize = config.colors.b ..'90';
  beautiful.tasklist_fg_minimize = config.colors.w;
  beautiful.tasklist_font = config.fonts.tll;

  local tasklist_widget_tempate = {
    {
      {
        {
          {
            id     = 'icon_role',
            widget = wibox.widget.imagebox,
          },
          margins = 5,
          widget  = wibox.container.margin,
        },
        {
          id     = 'text_role',
          widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
      },
      left  = 5,
      right = 5,
      widget = wibox.container.margin
    },
    id     = 'background_role',
    widget = wibox.container.background,
  }

  tasklist:setup {
    layout = wibox.container.place,
    halign = 'left',
    content_fill_horizontal = true,
    width = width,
    awful.widget.tasklist {
      screen  = s,
      filter  = awful.widget.tasklist.filter.client_filter_l,
      buttons = tasklist_buttons,
      layout = {
        spacing = 10,
        layout  = wibox.layout.flex.horizontal
      },
      widget_template = tasklist_widget_tempate,
      id = 'tasklist_internal'
    },
    id = 'tasklist_base'
  }

  tasklist_r:setup {
    layout = wibox.container.place,
    halign = 'left',
    content_fill_horizontal = true,
    width = width,
    awful.widget.tasklist {
      screen  = s,
      filter  = awful.widget.tasklist.filter.client_filter_r,
      buttons = tasklist_buttons,
      layout = {
        spacing = 10,
        layout  = wibox.layout.flex.horizontal
      },
      widget_template = tasklist_widget_tempate,
      id = 'tasklist_internal'
    },
    id = 'tasklist_base'
  }

  root.elements.tasklist = root.elements.tasklist or {};
  root.elements.tasklist[s.index] = {}
  root.elements.tasklist[s.index][1] = tasklist;
  root.elements.tasklist[s.index][2] = tasklist_r;
end

function get_tasklist()
  return root.elements.tasklist
end

function construct_elements(s)
  if not root.elements.utilities or not root.elements.utilities[s.index] then make_utilities(s) end;
  if not root.elements.launcher or not root.elements.launcher[s.index] then make_launcher(s) end;
  if not root.elements.taglist or not root.elements.taglist[s.index] then make_taglist(s) end;
  if not root.elements.tasklist or not root.elements.tasklist[s.index] then make_tasklist(s) end;
  if not root.elements.power or not root.elements.power[s.index] then make_power(s) end;
  if s == capi.screen.primary then if not root.elements.tray or not root.elements.tray[s.index] then make_tray(s) end end;
  if not root.elements.date or not root.elements.date[s.index] then make_date(s) end;
  if not root.elements.layout or not root.elements.layout[s.index] then make_layoutbox(s) end;
end

function setup_bar()
  awful.screen.connect_for_each_screen(function(screen) construct_elements(screen) end);

  for _, i in pairs(gears.table.join(root.elements.wifi_icons, root.elements.bt_icons, root.elements.lan_icons)) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(3, mouse.screen);
    end)));
  end

  for _, i in pairs(root.elements.vol_icons) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(6, mouse.screen);
    end)));
  end

  for _, i in pairs(gears.table.join(root.elements.pac_icons, root.elements.mem_icons, root.elements.bat_icons)) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(4, mouse.screen);
    end)));
  end

  for _, i in pairs(root.elements.note_icons) do
    i:buttons(gears.table.join(awful.button({ }, 1, function()
      if not root.elements.hub then return end;
      root.elements.hub.enable_view_by_index(1, mouse.screen);
    end)));
  end

  root.elements.topbar = {
    show = show,
    hide = hide
  }
end

function show(idx)
  for i in pairs(root.elements.utilities) do root.elements.utilities[idx or i].visible = true end;
  for i in pairs(root.elements.launcher) do root.elements.launcher[idx or i].visible = true end;
  for i in pairs(root.elements.taglist) do root.elements.taglist[idx or i].visible = true end;
  for i in pairs(root.elements.tasklist) do root.elements.tasklist[idx or i][1].visible = true end;
  for i in pairs(root.elements.tasklist) do root.elements.tasklist[idx or i][2].visible = true end;
  for i in pairs(root.elements.power) do root.elements.power[idx or i].visible = true end;
  for i in pairs(root.elements.tray) do if root.elements.tray[idx or i] then root.elements.tray[idx or i].visible = true end end;
  for i in pairs(root.elements.date) do root.elements.date[idx or i].visible = true end;
  for i in pairs(root.elements.date) do root.elements.layout[idx or i].visible = true end;
end

function hide(idx)
  for i in pairs(root.elements.utilities) do root.elements.utilities[idx or i].visible = false end;
  for i in pairs(root.elements.launcher) do root.elements.launcher[idx or i].visible = false end;
  for i in pairs(root.elements.taglist) do root.elements.taglist[idx or i].visible = false end;
  for i in pairs(root.elements.tasklist) do root.elements.tasklist[idx or i][1].visible = false end;
  for i in pairs(root.elements.tasklist) do root.elements.tasklist[idx or i][2].visible = false end;
  for i in pairs(root.elements.power) do root.elements.power[idx or i].visible = false end;
  for i in pairs(root.elements.tray) do if root.elements.tray[idx or i] then root.elements.tray[idx or i].visible = false end end;
  for i in pairs(root.elements.date) do root.elements.date[idx or i].visible = false end;
  for i in pairs(root.elements.date) do root.elements.layout[idx or i].visible = false end;
end

return function()
  setup_bar()

  screen.connect_signal("added", function(scr) awesome.restart() end)

  root.elements.topbar.tasklist = get_tasklist;
  root.elements.topbar.show = show;
  root.elements.topbar.hide = hide;
end

