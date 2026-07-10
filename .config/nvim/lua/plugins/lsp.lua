-- LSP, Mason, Treesitter, and Formatter Configuration
return function()
	---------------------- Mason ---------------------
	require("mason").setup()
	require("mason-tool-installer").setup({
		ensure_installed = {
			"lua-language-server",
			"stylua",
			"rust-analyzer",
			"markdownlint",
			"marksman",
			"json-lsp",
			"jq",
			"kotlin-lsp",
			"ktfmt",
			"kotlin-debug-adapter",
			"detekt",
		},
	})

	---------------------- LSP Server Configuration ---------------------
	local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()

	local servers = {
		lua_ls = {
			cmd = { "lua-language-server" },
			capabilities = lsp_capabilities,
			filetypes = { "lua" },
		},
		rust_analyzer = {
			cmd = { "rust-analyzer" },
			capabilities = lsp_capabilities,
			filetypes = { "rust" },
			root_markers = { "Cargo.toml", "Cargo.lock" },
			settings = { ["rust-analyzer"] = {} },
		},
		marksman = {
			cmd = { "marksman", "server" },
			capabilities = lsp_capabilities,
			filetypes = { "markdown" },
		},
		jsonls = {
			cmd = { "vscode-json-language-server", "--stdio" },
			capabilities = lsp_capabilities,
			filetypes = { "json" },
		},
		kotlin_lsp = {
			cmd = { "intellij-server", "--stdio" },
			capabilities = lsp_capabilities,
			filetypes = { "kotlin" },
			root_markers = {
				"build.gradle",
				"build.gradle.kts",
				"settings.gradle",
				"settings.gradle.kts",
				"pom.xml",
			},
		},
	}

	for server, config in pairs(servers) do
		vim.lsp.config(server, config)
	end

	vim.lsp.enable({
		"lua_ls",
		"rust_analyzer",
		"marksman",
		"jsonls",
		"kotlin_lsp",
	})

	---------------------- Treesitter ---------------------
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			require("nvim-treesitter").install({
				"lua",
				"rust",
				"markdown",
				"json",
				"kotlin",
				"html",
			})
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "*" },
		callback = function(args)
			local ft = vim.bo[args.buf].filetype
			local lang = vim.treesitter.language.get_lang(ft)
			if lang and pcall(vim.treesitter.language.add, lang) then
				pcall(vim.treesitter.start, args.buf, lang)
			end
		end,
	})

	---------------------- Formatter ---------------------
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			rust = { "rustfmt" },
			markdown = { "markdownlint" },
			json = { "jq" },
			cucumber = { "reformat-gherkin" },
			kotlin = { "ktfmt" },
		},
	})

	---------------------- Linter ---------------------
	require("lint").linters_by_ft = {
		kotlin = { "detekt" },
	}

	---------------------- Diagnostic Signs ---------------------
	vim.diagnostic.config({
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "✘",
				[vim.diagnostic.severity.WARN] = "▲",
				[vim.diagnostic.severity.HINT] = "⚑",
				[vim.diagnostic.severity.INFO] = "»",
			},
		},
		virtual_text = true,
		severity_sort = true,
		float = {
			border = "rounded",
			source = true,
		},
	})

	--------------------- FOLDING ---------------------
	require("ufo").setup({
		provider_selector = function()
			return { "treesitter", "indent" }
		end,
	})

	vim.keymap.set("n", "fd", "za", { desc = "Toggle fold" })
	vim.keymap.set("n", "fa", "zA", { desc = "Toggle all folds recursively" })
end
