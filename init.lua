vim.loader.enable()

local global = vim.g
local option = vim.opt
local keymap = vim.keymap

global.mapleader = " "
global.maplocalleader = " "
global.have_nerd_font = true

option.number = true
option.relativenumber = true
option.background = "dark"
option.termguicolors = true
option.showmode = false
option.wrap = true
option.breakindent = true
option.list = true
option.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
option.cursorline = true
option.scrolloff = 10
option.hlsearch = true

option.clipboard = "unnamedplus"
option.autoread = true
option.mouse = "a"
option.undofile = true
option.ignorecase = true
option.smartcase = true
option.updatetime = 250
option.timeoutlen = 300
option.splitright = true
option.inccommand = "split"

keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = " Open diagnostic [q]uickfix list" })
keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move [d]own. Keep cursor in middle" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move [u]p. Keep cursor in middle" })
keymap.set("n", "n", "nzzzv", { desc = "Next search instance. Keep cursor in middle" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search instance. Keep cursor in middle" })
keymap.set("n", "<leader>x", ":bd<CR>:bn<CR>", { desc = "Close current buffer safely" })
keymap.set("n", "<leader>X", ":bd!<CR>:bn<CR>", { desc = "Close current buffer forcefully" })
keymap.set("n", "<tab>", ":bnext<enter>", { desc = "Go to next buffer" })
keymap.set("n", "<S-Tab>", ":bprev<enter>", { desc = "Go to previous buffer" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected text down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected text up" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath, })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "olimorris/onedarkpro.nvim", priority = 1000 },
  { "tpope/vim-sleuth" },

  require("plugins.bufferline"),
  require("plugins.which-key"),
  require("plugins.lspconfig"),
  require("plugins.telescope"),
  require("plugins.nvim-cmp"),
  require("plugins.treesitter"),
  require("plugins.treesitter-context"),
  require("plugins.neo-tree"),
  require("plugins.conform"),
  require("plugins.lazygit"),
  require("plugins.gitsigns"),
  require("plugins.mini"),
  require("plugins.autopairs"),
  require("plugins.colorizer"),
  require("plugins.todo-comments"),
}, {
    ui = {
      icons = global.have_nerd_font and {} or {
        cmd = "⌘",
        config = "🛠",
        event = "📅",
        ft = "📂",
        init = "⚙",
        keys = "🗝",
        plugin = "🔌",
        runtime = "💻",
        require = "🌙",
        source = "📄",
        start = "🚀",
        task = "📌",
        lazy = "💤 ",
      },
    },
})

vim.cmd("colorscheme onedark")

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

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
