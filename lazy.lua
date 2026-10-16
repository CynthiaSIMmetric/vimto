local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)
local plugins = {
    -- Lazy
    {
        "bcat/abbott.vim",
        priority = 1000, -- Ensure it loads first
    },
    { 'BurntSushi/ripgrep',               name = "ripgrep", priority = 900 },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim'
        }
    },
    {
        'ThePrimeagen/harpoon',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        branch = "main",
        build = ':TSUpdate'
    },
    { 'VonHeikemen/lsp-zero.nvim' },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { 'numToStr/Comment.nvim' },
    {
        'Aasim-A/scrollEOF.nvim',
        event = { 'CursorMoved' },
        opts = {},
    },
    { 'nvim-mini/mini.icons', version = '*' },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
    {
        "atbraz/ghostty-theme-sync.nvim",
        lazy = false,
        config = function()
            require("ghostty-theme-sync").setup()
        end,
    },
    {
        "tiagovla/tokyodark.nvim",
        opts = {
            gamma = 1.50,
            comments = { bold = true, italic = true },
        },
        config = function(_, opts)
            require("tokyodark").setup(opts) -- calling setup is optional
            vim.cmd [[colorscheme tokyodark]]
        end,
    },
    {
        "barreiroleo/ltex_extra.nvim",
        ft = { "markdown", "tex", "gitcommit", "text" },
        dependencies = { "neovim/nvim-lspconfig" },
    },
    {
        "inhesrom/remote-ssh.nvim",
        branch = "master",
        dependencies = {
            "inhesrom/telescope-remote-buffer", --See https://github.com/inhesrom/telescope-remote-buffer for features
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
            -- nvim-notify is recommended, but not necessarily required into order to get notifcations during operations - https://github.com/rcarriga/nvim-notify
            "rcarriga/nvim-notify",
        },
        config = function ()
            require('telescope-remote-buffer').setup(
                -- Default keymaps to open telescope and search open buffers including "remote" open buffers
                --fzf = "<leader>fz",
                --match = "<leader>gb",
                --oldfiles = "<leader>rb"
            )

            -- setup lsp_config here or import from part of neovim config that sets up LSP

            require('remote-ssh').setup({
                on_attach = lsp_config.on_attach,
                capabilities = lsp_config.capabilities,
                filetype_to_server = lsp_config.filetype_to_server
            })
        end
    },
}

-- required for setting up lazy
local opts = {}
require("lazy").setup(plugins, opts)
