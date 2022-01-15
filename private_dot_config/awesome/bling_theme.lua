local config = require('helpers.config');

local theme = {}

-- flash focus
theme.flash_focus_start_opacity = 0.95
theme.flash_focus_step = 0.03

-- tabbar
theme.tabbed_spawn_in_tab = false
theme.tabbar_radius = 5            -- border radius of the tabbar
theme.tabbar_style = "default"     -- style of the tabbar ("default", "boxes" or "modern")
theme.tabbar_font = "Sans 9"      -- font of the tabbar
theme.tabbar_size = 28             -- size of the tabbar
theme.tabbar_position = "top"      -- position of the tabbar
theme.tabbar_bg_focus = config.colors.w .. '60' -- background color of the focused client on the tabbar
theme.tabbar_fg_focus = config.colors.b -- foreground color of the focused client on the tabbar
theme.tabbar_bg_normal  = config.colors.b ..'90' -- background color of unfocused clients on the tabbar
theme.tabbar_fg_normal  = config.colors.w -- foreground color of unfocused

return theme
