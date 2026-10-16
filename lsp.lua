-- ============================================================
-- Tree-sitter
-- ============================================================

-- nvim-treesitter main is a rewrite for Neovim 0.12+.
-- It no longer uses require("nvim-treesitter.configs").

require("nvim-treesitter").setup({
	-- Parsers and queries are installed here.
	install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Languages whose parsers we want installed.
--
-- This is asynchronous and requires the tree-sitter CLI,
-- curl, tar, and a C compiler.
require("nvim-treesitter").install({
	"lua",
	"vim",
	"vimdoc",
	"c",
	"cpp",
	"javascript",
	"typescript",
	"java",
	"python",
	"markdown",
	"markdown_inline",
})

-- Enable Tree-sitter highlighting for supported filetypes.
--
-- vim.treesitter.start() is now provided by Neovim itself.
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lua",
		"vim",
		"vimdoc",
		"c",
		"cpp",
		"javascript",
		"typescript",
		"java",
		"python",
		"markdown",
		"markdown_inline",
	},
	callback = function() vim.treesitter.start() end,
})

-- Tree-sitter indentation.
--
-- This is still considered experimental by nvim-treesitter.
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lua",
		"vim",
		"vimdoc",
		"c",
		"cpp",
		"javascript",
		"typescript",
		"java",
		"python",
		"markdown",
		"markdown_inline",
	},
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})


-- ============================================================
-- Mason
-- ============================================================

require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"bashls",
		"pylsp",
		"clangd",
		-- "ltex",
		"ltex_plus",
		"docker_language_server",
		"dockerls",
		"gopls",
		"quick_lint_js",
		"texlab",
		"ts_ls",
	},
})


-- ============================================================
-- LSP capabilities
-- ============================================================

-- Configure cmp capabilities globally for all LSP clients.
--
-- This replaces the old:
--
-- require("lspconfig").util.default_config.capabilities = ...
--
-- and avoids the deprecated offsetEncoding configuration.
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("*", {
	capabilities = capabilities,
})


-- ============================================================
-- Language server configuration
-- ============================================================

-- Lua
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})


-- LTeX
local ltex_settings = {
	settings = {
		ltex = {
			language = "en-GB",
			completionEnabled = true,
			disabledRules = {
				["en-GB"] = { "WHITESPACE_RULE" },
			},
		},
	},
}

-- vim.lsp.config("ltex", ltex_settings)
vim.lsp.config("ltex_plus", ltex_settings)




-- clangd
--
-- No offsetEncoding configuration here.
-- Modern Neovim/clangd negotiate the standard position encoding.
vim.lsp.config("clangd", {
	cmd = { "clangd" },
})


-- ============================================================
-- LSP keymaps
-- ============================================================

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and (client.name == "ltex" or client.name == "ltex_plus") then
			require("ltex_extra").setup({
				load_langs = { "en-GB" },
				path = vim.fn.stdpath("config") .. "/ltex", -- where dictionary files are stored
			})
		end

		vim.keymap.set(
			"n",
			"K",
			vim.lsp.buf.hover,
			opts
		)

		vim.keymap.set(
			"n",
			"gd",
			vim.lsp.buf.definition,
			opts
		)

		vim.keymap.set(
			"n",
			"gD",
			vim.lsp.buf.declaration,
			opts
		)

		vim.keymap.set(
			"n",
			"gi",
			vim.lsp.buf.implementation,
			opts
		)

		vim.keymap.set(
			"n",
			"go",
			vim.lsp.buf.type_definition,
			opts
		)

		vim.keymap.set(
			"n",
			"gr",
			vim.lsp.buf.references,
			opts
		)

		vim.keymap.set(
			"n",
			"gs",
			vim.lsp.buf.signature_help,
			opts
		)

		vim.keymap.set(
			"n",
			"<F2>",
			vim.lsp.buf.rename,
			opts
		)

		vim.keymap.set(
			{ "n", "x" },
			"<F3>",
			function()
				vim.lsp.buf.format({
					async = true,
					formatting_options = {
						tabSize = 4,
						insertSpaces = false,
					},
				})
			end,
			opts
		)

		vim.keymap.set(
			"n",
			"<F4>",
			vim.lsp.buf.code_action,
			opts
		)
	end,
})

local clients = vim.lsp.get_clients({ bufnr = 0, name = "ltex_plus" })
if clients[1] then
	vim.lsp.buf_execute_command(clients[1], {
		command = "_ltex.addToDictionary",
		arguments = { { word = { [lang] = { word } } } },
	})
end

-- ============================================================
-- Diagnostics
-- ============================================================

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false,
	underline = true,
	float = true,
})


-- ============================================================
-- nvim-cmp
-- ============================================================

local cmp = require("cmp")

cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
		{
			name = "buffer",
			option = {
				keyword_length = 1,
			},
		},
	},

	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),

		["<CR>"] = cmp.mapping.confirm({
			select = true,
		}),
	}),
})


-- Use buffer source for / and ?
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),

	sources = {
		{ name = "buffer" },
	},
})


-- Use path + command-line sources for :
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),

	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),

	matching = {
		disallow_symbol_nonprefix_matching = false,
	},
})


-- ============================================================
-- Comment.nvim
-- ============================================================

require("Comment").setup({
	ignore = "^$",

	extra = {
		above = "gck",
		below = "gcj",
	},
})
