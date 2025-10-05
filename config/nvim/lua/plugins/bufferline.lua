-- lua/plugins/bufferline.lua
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- opcional para íconos
  opts = {
    options = {
      mode = "buffers",           -- pestañas = buffers abiertos
      diagnostics = "nvim_lsp",   -- muestra diagnósticos si usas LSP
      separator_style = "slant",  -- "slant" | "thick" | "thin"
      always_show_bufferline = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      numbers = "ordinal",        -- muestra índice 1..n
      offsets = {
        { filetype = "NvimTree", text = "Explorer", text_align = "left", separator = true },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)

    -- Navegación rápida entre buffers/pestañas
    local map = vim.keymap.set
    map("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { silent = true })
    map("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { silent = true })

    -- Ir directo a la pestaña N
    for i = 1, 9 do
      map("n", ("<Leader>%d"):format(i), ("<Cmd>BufferLineGoToBuffer %d<CR>"):format(i), { silent = true })
    end

    -- Cerrar/mover
    map("n", "<Leader>bc", "<Cmd>bdelete<CR>", { silent = true })            -- cerrar buffer actual
    map("n", "<Leader>bp", "<Cmd>BufferLinePick<CR>", { silent = true })     -- elegir con “pick”
    map("n", "<Leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { silent = true })
    map("n", "<Leader>br", "<Cmd>BufferLineCloseRight<CR>", { silent = true })
  end,
}
