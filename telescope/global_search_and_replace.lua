--- Custom mapping for `:Telescope live_grep` to replace all results with some text.
---
--- 1. run `:Telescope live_grep` or use the Lua API
--- 2. search for something
--- 3. hit CTRL+R
--- 4. type some text you want to replace the results with
--- 5. hit enter
--- 6. confirm / deny each result
---
--- Maintainer: AlphaKeks <alphakeks@dawn.sh>
--- License: GPL-v3.0 <https://www.gnu.org/licenses/gpl-3.0>
--- Version: v0.10.0-dev-ac353e8

require("telescope").setup({
	pickers = {
		live_grep = {
			attach_mappings = function(_, map)
				map("i", "<C-r>", function(buffer)
					local search = require("telescope.actions.state").get_current_line()

					require("telescope.actions").send_to_qflist(buffer)

					vim.ui.input({ prompt = "Replace with: " }, function(replace)
						if replace ~= nil and #replace > 0 then
							vim.cmd("cdo s/" .. search .. "/" .. replace .. "/gc")
						end
					end)
				end)

				return true
			end,
		},
	},
})
