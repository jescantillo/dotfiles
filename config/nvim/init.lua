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


local function ensure(repo)
  local name = repo:match("[^/]+$")
  local dir = string.format("%s/site/pack/bundle/start/%s", vim.fn.stdpath("data"), name)
  local installed = vim.fn.isdirectory(dir) == 1
  if not installed then
    vim.notify("Clonando " .. repo .. " ...", vim.log.levels.INFO)
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. repo, dir })
  end
  return dir, not installed
end

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
  "williamboman/mason-lspconfig.nvim"
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
map('i', '<c-e>', function() vim.lsp.completion.get() end)  -- OJO: abajo también mapeas <C-e> para LuaSnip

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