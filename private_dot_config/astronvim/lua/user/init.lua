return {
    lsp = {
        formatting = {
            format_on_save = false,
            indent_style = "space",
            indent_size = "2",
        },
    },
    polish = function()
        vim.opt.shiftwidth = 2
        vim.opttabstop = 2
    end,
    options = {
        opt = {
            relativenumber = false, -- sets vim.opt.relativenumber
            expandtab = true,
            shiftwidth = 2, -- Number of space inserted for indentation
            tabstop = 2,
        },
    },
}
