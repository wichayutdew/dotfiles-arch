-- Image rendering for markdown (mermaid diagrams + ![alt](img) links) via snacks.image
-- System deps (one-time):  yay -S mmdr-bin && ln -sfn /usr/bin/mmdr ~/.cargo/bin/mmdc
--   snacks.image hardcodes the `mmdc` binary; our shim → mmdr speaks a compatible CLI,
--   so the args below pass through unchanged.
return function()
	require("snacks").setup({
		image = {
			convert = {
				-- Notify on diagram render errors instead of failing silently
				notify = true,
				-- mmdr-compatible args; theme mirrors snacks' default (dark/neutral)
				mermaid = function()
					local theme = vim.o.background == "light" and "neutral" or "dark"
					return { "-i", "{src}", "-o", "{file}", "-e", "png", "-t", theme }
				end,
			},
		},
	})
end