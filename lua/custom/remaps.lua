vim.opt.wrap = true
vim.opt.autoread = true

-- moves selected text up or down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected text down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected text up" })

-- keeps moved to line or search term in middle of screen
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move [d]own. Keep cursor in middle" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move [u]p. Keep cursor in middle" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search instance. Keep cursor in middle" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search instance. Keep cursor in middle" })

-- prevents jumping into Q reg
vim.keymap.set("n", "Q", "<nop>", { desc = "Prevents default behaviour" })

-- buffer management
vim.keymap.set("n", "<leader>xs", ":bd<CR>:bn<CR>", { desc = "Close current buffer [s]afely" })
vim.keymap.set("n", "<leader>xu", ":bd!<CR>:bn<CR>", { desc = "Close current buffer [u]nsafely" })
vim.keymap.set("n", "<tab>", ":bnext<enter>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprev<enter>", { desc = "Go to previous buffer" })

-- open jade files as pug
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = { "*.jade" },
  command = "setlocal filetype=pug",
})

-- Enables text wrapping on markdown files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.md" },
  command = "setlocal textwidth=80",
})

