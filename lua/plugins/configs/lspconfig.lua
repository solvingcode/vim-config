dofile(vim.g.base46_cache .. "lsp")
require "nvchad.lsp"

local M = {}
local utils = require "core.utils"

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  -- client.server_capabilities.documentFormattingProvider = false
  -- client.server_capabilities.documentRangeFormattingProvider = false

  utils.load_mappings("lspconfig", { buffer = bufnr })

  -- if client.server_capabilities.signatureHelpProvider then
  --   require("nvchad.signature").setup(client)
  -- end

  if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

require("lspconfig").lua_ls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

require("lspconfig").tsserver.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

require("lspconfig").html.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

require("lspconfig").cssls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

require("lspconfig").ccls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

require("lspconfig").terraformls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

require("lspconfig").zls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
}

require("lspconfig").gopls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}

-- local angularcmd = {
-- "/usr/local/bin/ngserver",
-- "--tsProbeLocations","/usr/local/lib/node_modules/",
-- "--ngProbeLocations","/usr/local/lib/node_modules/",
-- "--stdio",
-- }
-- require("lspconfig").angularls.setup {
--   cmd = angularcmd,
--   on_new_config = function(new_config, new_root_dir)
--     new_config.cmd = angularcmd
--   end,
--   on_attach = M.on_attach,
--   capabilities = M.capabilities,
-- }
--
return M
