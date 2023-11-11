--- Function for running eslint_d on the current buffer (asynchronously).
---
--- This requires `eslint_d` to be installed on your system:
---   <https://github.com/mantoni/eslint_d.js.git>
---
--- Maintainer: AlphaKeks <alphakeks@dawn.sh>
--- License: GPL-v3.0 <https://www.gnu.org/licenses/gpl-3.0>
--- Version: v0.10.0-dev-ba6761e

--- Namespace to keep diagnostics in.
---
--- See `:help namespace`
local namespace = vim.api.nvim_create_namespace("eslint_on_save")

--- List of files that might be read as configuration.
---
--- ESLint does not play nice if you try to use it in a project that is not configured to use ESLint.
--- This is why we want to be able to filter out files in projects that aren't supposed to be linted
--- by ESLint.
local patterns = {
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.yaml",
	".eslintrc.yml",
	".eslintrc.json",
	"eslint.config.js",
}

--- The diagnostic severities supported by ESLint
local severities = {
	vim.diagnostic.severity.WARN,
	vim.diagnostic.severity.ERROR,
}

--- Lints the given `buffer` with eslint_d.
---
--- @param buffer integer
--- @param opts? { diagnostics?: boolean, quickfix?: boolean }
local function invoke(buffer, opts)
	local config_files = vim.fs.find(patterns, { upward = true })

	-- We did not find any ESLint config file, so our project is not configured to use it.
	if vim.tbl_isempty(config_files) then
		return
	end

	-- Clear previous diagnostics.
	vim.diagnostic.reset(namespace, buffer)

	opts = vim.F.if_nil(opts, {})
	opts.diagnostics = vim.F.if_nil(opts.diagnostics, true)
	opts.quickfix = vim.F.if_nil(opts.quickfix, true)

	local command = { "eslint_d", "--stdin", "--format", "json" }
	local system_opts = {
		text = true,
		stdin = vim.api.nvim_buf_get_lines(buffer, 0, -1, false),
	}

	vim.system(command, system_opts, vim.schedule_wrap(function(result)
		if #result.stdout == 0 then
			return
		end

		-- Parse ESLint output.
		local ok, data = pcall(vim.json.decode, result.stdout)

		if not ok then
			vim.notify("Failed to decode ESLint output: " .. vim.inspect(result), vim.log.levels.ERROR)
		end

		local diagnostics = vim.tbl_map(function(diagnostic)
			vim.print(diagnostic)
			return {
				bufnr = buffer,
				lnum = vim.F.if_nil(diagnostic.line, 1) - 1,
				col = vim.F.if_nil(diagnostic.column, 1),
				severity = severities[diagnostic.severity],
				message = diagnostic.message,
				source = "ESLint",
			}
		end, data[1].messages)

		if opts.diagnostics then
			vim.diagnostic.set(namespace, buffer, diagnostics)

			if opts.quickfix then
				vim.diagnostic.setqflist({ namespace = namespace, title = "ESLint" })
			end
		elseif opts.quickfix then
			vim.fn.setqflist({}, "r", vim.diagnostic.toqflist(diagnostics))
		end
	end))
end

--- Sets up linting on save with eslint_d.
---
--- @param buffer integer
--- @param opts? { diagnostics?: boolean, quickfix?: boolean }
---
--- @return integer autocmd_id
local function on_save(buffer, opts)
	local augroup_name = "eslint_d_on_save_b_" .. tostring(buffer)
	local group = vim.api.nvim_create_augroup(augroup_name, { clear = true })

	return vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		buffer = buffer,
		callback = function(event)
			invoke(event.buf, opts)
		end,
	})
end

return { namespace = namespace, invoke = invoke, on_save = on_save }
