vim.cmd([[set mouse=]])
vim.cmd([[set noswapfile]])
vim.opt.winborder = "rounded"
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.signcolumn = "yes"

local map = vim.keymap.set
vim.g.mapleader = " "
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map('n', '<C-f>', ':Open .<CR>')
map('n', '<leader>v', ':e $MYVIMRC<CR>')
map('n', '<leader>z', ':e ~/.config/zsh/.zshrc<CR>')
map('n', '<leader>s', ':e #<CR>')
map('n', '<leader>S', ':bot sf #<CR>')
map({ 'n', 'v' }, '<leader>n', ':norm ')
map({ 'n', 'v' }, '<leader>y', '"+y')
map({ 'n', 'v' }, '<leader>d', '"+d')
map({ 'n', 'v' }, '<leader>c', '1z=')
map({ 'n', 'v' }, '<leader>o', ':update<CR> :source<CR>')

-- =========================================
-- Custom plugin manager with pack/*/start
-- =========================================
local function ensure(repo)
  local name = repo:match("[^/]+$")
  local dir = string.format("%s/site/pack/bundle/start/%s", vim.fn.stdpath("data"), name)
  local installed = vim.fn.isdirectory(dir) == 1
  if not installed then
    vim.notify("Cloning " .. repo .. " ...", vim.log.levels.INFO)
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. repo, dir })
  end
  return dir, not installed
end

-- =========================================
-- Plugins (bufferline + devicons added)
-- =========================================
local plugins = {
  "vague2k/vague.nvim",
  "stevearc/oil.nvim",
  "echasnovski/mini.pick",
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "chomosuke/typst-preview.nvim",
  "neovim/nvim-lspconfig",
  "mason-org/mason.nvim",
  "L3MON4D3/LuaSnip",
  "SylvanFranklin/pear",
  "williamboman/mason-lspconfig.nvim",

  -- added for tabs
  "akinsho/bufferline.nvim",
  "nvim-tree/nvim-web-devicons",
}

local freshly_installed = {}
for _, repo in ipairs(plugins) do
  local dir, just_cloned = ensure(repo)
  if just_cloned then
    table.insert(freshly_installed, (repo:match("[^/]+$")))
  end
end

if #freshly_installed > 0 then
  for _, name in ipairs(freshly_installed) do
    pcall(vim.cmd, "packadd " .. name)
  end
  vim.schedule(function()
    pcall(vim.cmd, "TSUpdate")
  end)
end

-- =========================================
-- Mason / LSP / Pickers / Oil
-- =========================================
require("mason").setup()
pcall(require, "lsp.python")
require("mini.pick").setup({
  mappings = {
    choose_marked = "<C-G>"
  }
})
require("oil").setup()

map('n', '<leader>f', ":Pick files<CR>")
map('n', '<leader>b', function() require("pear").jump_pair() end)
map('n', '<leader>h', ":Pick help<CR>")
map('n', '<leader>e', ":Oil<CR>")
map('i', '<c-e>', function() vim.lsp.completion.get() end)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

map('t', '', "")
map('t', '', "")
map('n', '<leader>lf', vim.lsp.buf.format)
vim.cmd [[set completeopt+=menuone,noselect,popup]]

vim.lsp.enable({
  "lua_ls",
  "svelte",
  "tinymist",
  "emmetls",
  "rust_analyzer",
  "clangd",
  "ruff",
  "glsl_analyzer"
})

require("vague").setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

require("luasnip").setup({ enable_autosnippets = true })
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
local ls = require("luasnip")
map("i", "<C-e>", function() ls.expand_or_jump(1) end, { silent = true })
map({ "i", "s" }, "<C-J>", function() ls.jump(1) end, { silent = true })
map({ "i", "s" }, "<C-K>", function() ls.jump(-1) end, { silent = true })

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

require('nvim-treesitter.configs').setup {
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["if"] = "@function.inner",
        ["af"] = "@function.outer",
        ["im"] = "@math.inner",
        ["am"] = "@math.outer",
        ["ar"] = "@return.outer",
        ["ir"] = "@return.inner",
        ["ac"] = "@class.outer",
      },
    },
  },
}

-- =========================================
-- Bufferline (Tabs) Setup + Keymaps
-- =========================================
pcall(function()
  require("bufferline").setup({
    options = {
      mode = "buffers",             -- "buffers" for buffer tabs, "tabs" for tabpages
      diagnostics = "nvim_lsp",     -- show LSP diagnostics on tabs
      separator_style = "slant",    -- style of separators
      numbers = "ordinal",          -- show index 1..n
      always_show_bufferline = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      offsets = {
        { filetype = "oil", text = "Oil", text_align = "left", separator = true },
      },
    },
  })

  -- Navigation between tabs
  map("n", "<Tab>",     "<Cmd>BufferLineCycleNext<CR>", { silent = true })
  map("n", "<S-Tab>",   "<Cmd>BufferLineCyclePrev<CR>", { silent = true })

  -- Direct jump to tab by index with <leader>1..9
  for i = 1, 9 do
    map("n", ("<Leader>%d"):format(i), ("<Cmd>BufferLineGoToBuffer %d<CR>"):format(i), { silent = true })
  end

  -- Useful tab actions
  map("n", "<Leader>bc", "<Cmd>bdelete<CR>", { silent = true })               -- close current buffer
  map("n", "<Leader>bp", "<Cmd>BufferLinePick<CR>", { silent = true })        -- pick tab by letter
  map("n", "<Leader>bl", "<Cmd>BufferLineCloseLeft<CR>",  { silent = true })  -- close tabs to the left
  map("n", "<Leader>br", "<Cmd>BufferLineCloseRight<CR>", { silent = true })  -- close tabs to the right
end)
