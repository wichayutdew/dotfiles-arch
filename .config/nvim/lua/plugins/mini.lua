-- Mini.nvim Plugins Configuration
return function()
	require("mini.icons").setup()
	require("mini.ai").setup()
	require("mini.surround").setup()
	require("mini.files").setup()
	require("mini.pairs").setup()
	require("mini.cursorword").setup()
	require("mini.jump").setup()
	require("mini.jump2d").setup()

	-- Mini.diff
	require("mini.diff").setup({
		view = {
			style = "sign",
		},
		mappings = {
			reset = "<leader>zz",
		},
	})
	vim.keymap.set("n", "<leader>zo", ":lua MiniDiff.toggle_overlay()<CR>", { desc = "see all diff" })

	-- Mini.clue
	require("mini.clue").setup({
		triggers = {
			{ mode = "n", keys = "<Leader>" },
			{ mode = "x", keys = "<Leader>" },
		},
		clues = {
			require("mini.clue").gen_clues.builtin_completion(),
		},
		window = {
			delay = 100,
		},
	})

	-- Mini.files keymaps
	local minifiles = require("mini.files")
	vim.keymap.set("n", "<leader>e", function()
		if not minifiles.close() then
			minifiles.open(vim.api.nvim_buf_get_name(0), false)
		end
	end, { desc = "Open file tree" })
end
