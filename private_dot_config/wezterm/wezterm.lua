local wezterm = require 'wezterm'

return {
    font = wezterm.font 'Fira Code Nerd Font Mono',
    font_size = 11.0,
    default_prog = { '/bin/zsh' },
    window_background_opacity = 0.9,
    color_scheme = 'Abernathy',
    warn_about_missing_glyphs = false,
    colors = {
        background = '#3c3d4b'
    },
    window_padding = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4,
    },
    max_fps = 60,
    hide_tab_bar_if_only_one_tab = true,
    ssh_domains = {
        {
            name = 'nas',
            username = 'admin',
            multiplexing = 'None',
            remote_address = '10.0.0.5',
            ssh_option = {
                identityfile = '~/.ssh/nas',
            },
        },
    },
}
