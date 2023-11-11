--- Function for running prettierd on the current buffer.
---
--- This requires `prettierd` to be installed on your system:
---   <https://github.com/fsouza/prettierd.git>
---
--- Maintainer: AlphaKeks <alphakeks@dawn.sh>
--- License: GPL-v3.0 <https://www.gnu.org/licenses/gpl-3.0>
--- Version: v0.10.0-dev-ba6761e

--- Path to a fallback config for prettierd.
--- If this is left empty, prettierd is going to use its default settings.
local PRETTIERD_DEFAULT_CONFIG = vim.fs.joinpath(DOTFILES(), "tools", "prettier", ".prettierrc.js")

--- Formats the given `buffer` with prettierd.
---
--- @param buffer integer
---
--- @return boolean success
local function invoke(buffer)
	local filename = vim.api.nvim_buf_get_name(buffer)
	local command = { "prettierd", filename }
	local opts = {
		text = true,
		stdin = vim.api.nvim_buf_get_lines(buffer, 0, -1, false),
		env = { PRETTIERD_DEFAULT_CONFIG = PRETTIERD_DEFAULT_CONFIG },
	}

	local result = vim.system(command, opts):wait()

	if result.code ~= 0 then
		return false
	end

	local lines = vim.split(result.stdout, "\n", { trimempty = true })

	return pcall(vim.api.nvim_buf_set_lines, buffer, 0, -1, false, lines)
end

--- Sets up formatting on save with prettierd.
---
--- @param buffer integer
---
--- @return integer autocmd_id
local function on_save(buffer)
	local augroup_name = "prettier_on_save_b_" .. tostring(buffer)
	local group = vim.api.nvim_create_augroup(augroup_name, { clear = true })

	return vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		buffer = buffer,
		callback = function(event)
			invoke(event.buf)
		end,
	})
end

return { invoke = invoke, on_save = on_save }
