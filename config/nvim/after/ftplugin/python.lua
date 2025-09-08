vim.cmd([[
	setlocal makeprg=python3\ %
]])

vim.keymap.set("n", "<leader>r", ":w<CR>:!python3 %<CR>", { buffer = true })
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

