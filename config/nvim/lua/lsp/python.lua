local lspconfig = vim.lsp.config

require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "ruff" },
  automatic_installation = true,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

local function on_attach(client, bufnr)
  local map = function(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
  end
  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "K",  vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
  map("n", "<leader>lf", function() vim.lsp.buf.format({ async = false }) end)
end

-- Ruff
lspconfig.ruff.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
})

-- Pyright
lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
