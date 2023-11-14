--- Custom LSP handler for `textDocument/publishDiagnostics`.
---
--- This can be used to manipulate the diagnostic messages either globally or coming from
--- a particular language server.
---
--- To override the handler globally, simply put this somewhere in your config:
---
---   vim.lsp.handlers["textDocument/publishDiagnostics"] = diagnostics_handler
---
--- If you want to override it for a specific server, e.g. `tsserver`, do it like this:
---
---   require("lspconfig").tsserver.setup({
---     handlers = {
---       ["textDocument/publishDiagnostics"] = diagnostics_handler,
---     },
---   })
---
--- Maintainer: AlphaKeks <alphakeks@dawn.sh>
--- License: GPL-v3.0 <https://www.gnu.org/licenses/gpl-3.0>
--- Version: v0.10.0-dev-ac353e8

--- @param err lsp.ResponseError
--- @param result lsp.PublishDiagnosticsParams
--- @param ctx lsp.HandlerContext
local function diagnostics_handler(err, result, ctx)
	if err ~= nil then
		error("Failed to request diagnostics: " .. vim.inspect(err))
	end

	if result == nil then
		return
	end

	local buffer = vim.uri_to_bufnr(result.uri)
	local namespace = vim.lsp.diagnostic.get_namespace(ctx.client_id)

	local diagnostics = vim.tbl_map(function(diagnostic)
		return {
			bufnr = buffer,
			lnum = diagnostic.range.start.line,
			end_lnum = diagnostic.range["end"].line,
			col = diagnostic.range.start.character,
			end_col = diagnostic.range["end"].character,
			severity = diagnostic.severity,
			message = "suck my balls | " .. diagnostic.message,
			source = diagnostic.source,
			code = diagnostic.code,
		}
	end, result.diagnostics)

	vim.diagnostic.set(namespace, buffer, diagnostics)
end

return { diagnostics_handler = diagnostics_handler }
