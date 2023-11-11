--- Set of 2 functions for throwing text at the end / start of a line from normal mode
--- It doesn't move you from your current position and doesn't populate Vim marks
---
--- Usage: It accepts both single and multi-char inputs, including spaces.
--- vim.keymap.set("n", "<leader>,", put_at_end(","))
--- vim.keymap.set("n", "<leader>-", put_at_beginning("- "))
--- vim.keymap.set("n", "<leader>{", put_at_beginning("{"))
--- vim.keymap.set("n", "<leader>}", put_at_end("]"))
--- BEWARE: If the input is already present, it will remove it (works like a toggle)
---
--- Maintainer: Juan Mañanes <mrsandman.h4sh@gmail.com>
--- License: MIT License <https://mit-license.org>
--- Version: v0.10.0-dev-1496+g4c8fdc018 (>= 0.10.0)

--- Put the `char` variable at the end of the line. If present, remove it
---@param chars string
local function put_at_beginning(chars)
	---@diagnostic disable-next-line: param-type-mismatch
	local cline = vim.fn.getline(".")
	---@diagnostic disable-next-line: param-type-mismatch
	-- vim.api.nvim_set_current_line(cline:sub(1, cline:len()-1))
	local pos = vim.api.nvim_win_get_cursor(0)
	local row = pos[1] - 1
	local col = 0
	local entry_length = string.len(chars)
	---@diagnostic disable-next-line: param-type-mismatch
	local start_chars = string.sub(vim.fn.getline("."), 0, entry_length)
	if start_chars ~= chars then
		vim.api.nvim_buf_set_text(0, row, col, row, col, { chars })
	else
		---@diagnostic disable-next-line: param-type-mismatch
		vim.api.nvim_set_current_line(cline:sub((entry_length + 1), cline:len()))
	end
end

--- Put the `char` variable at the beginning of the line. If present, remove it
---@param chars string
local function put_at_end(chars)
	local pos = vim.api.nvim_win_get_cursor(0)
	local row = pos[1] - 1
	local current_line = vim.api.nvim_get_current_line()
	local col = #current_line
	---@diagnostic disable-next-line: param-type-mismatch
	local cline = vim.fn.getline(".")
	---@diagnostic disable-next-line: param-type-mismatch
	local endchar = vim.fn.getline("."):sub(-1)
	if endchar == chars then
		---@diagnostic disable-next-line: param-type-mismatch
		vim.api.nvim_set_current_line(cline:sub(1, cline:len() - 1))
	else
		vim.api.nvim_buf_set_text(0, row, col, row, col, { chars })
	end
end
