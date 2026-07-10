-- DAP (Debug Adapter Protocol) Configuration
return function()
	local dap = require("dap")
	local dapui = require("dapui")

	---------------------- DAP UI Setup ---------------------
	dapui.setup({
		icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
		layouts = {
			{
				elements = {
					{ id = "scopes", size = 0.25 },
					{ id = "breakpoints", size = 0.25 },
					{ id = "stacks", size = 0.25 },
					{ id = "watches", size = 0.25 },
				},
				size = 40,
				position = "left",
			},
			{
				elements = {
					{ id = "repl", size = 0.5 },
					{ id = "console", size = 0.5 },
				},
				size = 10,
				position = "bottom",
			},
		},
	})

	---------------------- DAP Virtual Text ---------------------
	require("nvim-dap-virtual-text").setup({
		enabled = true,
		enabled_commands = true,
		highlight_changed_variables = true,
		highlight_new_as_changed = false,
		show_stop_reason = true,
		commented = false,
		only_first_definition = true,
		all_references = false,
	})

	---------------------- Auto-open/close DAP UI ---------------------
	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		dapui.close()
	end

	---------------------- Breakpoint Signs Configuration ---------------------
	-- Set breakpoint icons
	vim.fn.sign_define("DapBreakpoint", {
		text = "●",
		texthl = "DapBreakpoint",
		linehl = "",
		numhl = "",
	})
	vim.fn.sign_define("DapStopped", {
		text = "▶",
		texthl = "DapStopped",
		linehl = "debugPC",
		numhl = "",
	})

	---------------------- JVM Debugger Configuration ---------------------
	-- Helper to run Gradle task with debug and attach DAP
	local function launch_with_debug(gradle_task, extra_args)
		extra_args = extra_args or ""
		local project_root = vim.fn.getcwd()

		-- Run Gradle task with debug JVM in background
		local cmd = string.format("cd %s && ./gradlew %s %s --debug-jvm", project_root, gradle_task, extra_args)

		-- Start Gradle in background using jobstart
		vim.fn.jobstart(cmd, {
			on_stdout = function(_, data)
				if data then
					for _, line in ipairs(data) do
						if line ~= "" then
							vim.notify(line, vim.log.levels.INFO)
						end
					end
				end
			end,
			on_stderr = function(_, data)
				if data then
					for _, line in ipairs(data) do
						if line ~= "" then
							vim.notify(line, vim.log.levels.WARN)
						end
					end
				end
			end,
			on_exit = function(_, exit_code)
				if exit_code ~= 0 then
					vim.notify("Gradle task exited with code: " .. exit_code, vim.log.levels.ERROR)
				end
			end,
		})

		-- Wait for JVM to start listening, then attach
		vim.defer_fn(function()
			dap.continue()
		end, 3000) -- 3 second delay for JVM to start
	end

	-- Helper to debug a specific test class or method
	local function debug_test_at_cursor()
		local bufname = vim.fn.expand("%:p")
		local project_root = vim.fn.getcwd()

		-- Extract package and class name from file
		local relative_path = bufname:gsub(project_root .. "/", "")
		-- Convert path like app/src/test/kotlin/org/example/AppTest.kt to org.example.AppTest
		local test_class = relative_path
			:gsub("app/src/test/kotlin/", "")
			:gsub("app/src/test/java/", "")
			:gsub("/", ".")
			:gsub("%.kt$", "")
			:gsub("%.java$", "")

		if test_class == "" then
			vim.notify("Could not determine test class from file path", vim.log.levels.ERROR)
			return
		end

		launch_with_debug("test", "--tests " .. test_class)
	end

	dap.configurations.kotlin = {
		{
			type = "kotlin",
			request = "attach",
			name = "Attach - Remote JVM (port 5005)",
			port = 5005,
			args = {},
			projectRoot = vim.fn.getcwd,
			hostName = "localhost",
			timeout = 2000,
		},
	}

	dap.adapters.kotlin = {
		type = "executable",
		command = "kotlin-debug-adapter",
		options = { auto_continue_if_many_stopped = false },
	}

	---------------------- Telescope DAP Extension ---------------------
	require("telescope").load_extension("dap")

	---------------------- Keymaps ---------------------
	-- Breakpoint management
	vim.keymap.set("n", "<leader>bb", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
	vim.keymap.set("n", "<leader>bc", dap.clear_breakpoints, { desc = "Clear all breakpoints" })
	vim.keymap.set("n", "<leader>B", ":Telescope dap list_breakpoints<CR>", { desc = "List all breakpoints" })

	-- Debug execution - streamlined for attach workflow
	vim.keymap.set("n", "<leader>dD", dapui.toggle, { desc = "Toggle DAP UI" })
	vim.keymap.set("n", "<leader>da", dap.continue, { desc = "Attach/Continue debugging" })
	vim.keymap.set("n", "<leader>dd", function()
		launch_with_debug("run")
	end, { desc = "Debug: Launch app (gradle run)" })
	vim.keymap.set("n", "<leader>dT", function()
		launch_with_debug("test")
	end, { desc = "Debug: Run all tests" })
	vim.keymap.set("n", "<leader>df", function()
		debug_test_at_cursor()
	end, { desc = "Debug: Test current file" })

	-- Additional debug controls
	vim.keymap.set("n", "<leader>dj", dap.step_over, { desc = "Step over" })
	vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
	vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step out" })
	vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
end
