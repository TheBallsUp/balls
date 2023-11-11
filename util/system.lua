--- Convenience wrapper for `vim.system()`.
--- It sets `text = true` by default and `vim.schedule_wrap`s the callback.
--- The callback itself is also part of the second argument to prevent situations like
---
---   vim.system({ "some", "command" }, nil, function(result)
---     ...
---   end)
---
--- To instead have something like this:
---
---   system({ "some", "command" }, {
---     on_exit = function(result)
---       ...
---     end,
---   })
---
--- Feel free to add more defaults that you commonly set.
---
--- Maintainer: AlphaKeks <alphakeks@dawn.sh>
--- License: GPL-v3.0 <https://www.gnu.org/licenses/gpl-3.0>
--- Version: v0.10.0-dev-ba6761e

---@class SystemOptions : SystemOpts
---
---@field on_exit? fun(result: vim.SystemCompleted)

--- Runs a shell command.
---
--- @param command string[] arguments
--- @param options SystemOptions
---
--- @return vim.SystemObj result
function system(command, options)
	options = vim.F.if_nil(options, {})
	options.text = vim.F.if_nil(options.text, true)

	local on_exit = options.on_exit

	if on_exit == nil then
		return vim.system(command, options):wait()
	end

	options.on_exit = nil

	return vim.system(command, options, vim.schedule_wrap(on_exit))
end
