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

  { "lewis6991/gitsigns.nvim",
    opts = {
      signs = { add = { text = "+" }, change = { text = "C" }, delete = { text = "D" } },
      current_line_blame = true,
      lazy = true
    },
  },

  { "folke/which-key.nvim",
    event = "VimEnter",
    config = function()
      require("which-key").setup()
      require("which-key").add({
        { "<leader>c", group = "[c]ode..." },
        { "<leader>d", group = "[d]ocument..." },
        { "<leader>f", group = "[f]ormat..." },
        { "<leader>h", group = "Git [h]unk...", mode = { "n", "v" } },
        { "<leader>l", group = "[l]azygit..." },
        { "<leader>r", group = "[r]ename..." },
        { "<leader>s", group = "[s]earch..." },
        { "<leader>t", group = "[t]oggle..." },
        { "<leader>w", group = "[w]orkspace..." },
        { "<leader>x", group = "[x] Close..." },
      })
    end,
  },

  { "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = global.have_nerd_font },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")

      telescope.setup({
        defaults = {
          path_display = { "filename_first", "smart" },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          live_grep_args = {
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob  **" }),
              },
            },
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
      pcall(telescope.load_extension, "live_grep_args")

      local builtin = require("telescope.builtin")
      keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search [h]elp" })
      keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search [k]eymaps" })
      keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search [f]iles" })
      keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search cursor [w]ord" })
      keymap.set("n", "<leader>sg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = "Search by [g]rep" })
      -- keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search by [g]rep" })
      keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search [d]iagnostics" })
      keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search [r]esume" })
      keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "Search recent files ([.] for repeat)" })
      keymap.set("n", "<leader><leader>", builtin.buffers, { desc = " Find existing buffers" })

      keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = " Fuzzily search in current buffer" })

      keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Search by grep in Open Files",
        })
      end, { desc = "Search by grep in Open Files" })
    end,
    opts = { lazy = true },
  },

  { "neovim/nvim-lspconfig",
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
      { "j-hui/fidget.nvim", opts = {} },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "williamboman/mason.nvim", config = true },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
          lazy = true,
        },
      },
    },

    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "goto [d]efinition")
          map("gr", require("telescope.builtin").lsp_references, "goto [r]eferences")
          map("<leader>rn", vim.lsp.buf.rename, "Re[n]ame")
          map("<leader>a", vim.lsp.buf.code_action, "Code [a]ction")

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle Inlay [h]ints")
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      require("mason").setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { "stylua", "typescript-language-server", "angular-language-server", "prettierd", "prettier" })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
    opts = { lazy = true },
  },

  { "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
      },
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<S-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "lazydev", group_index = 0 },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        },
      })
    end,
    opts = { lazy = true },
  },

  { "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false, lazy = true },
  },

  { "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })

      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = global.have_nerd_font })

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },

  { "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "angular", "bash", "css", "diff", "dockerfile", "git_config", "gitignore", "html", "javascript", "json", "lua", "luadoc", "markdown", "markdown_inline", "query", "regex", "scss", "svelte", "typescript", "vim", "vimdoc", "yaml" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-Space>",
          node_incremental = "<C-Space>",
        },
      },
    },

    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  { "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  { "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  { "norcalli/nvim-colorizer.lua",
    opts = {
      "*",
      css = { rgb_fn = true },
      html = { names = false },
      js = { names = false },
      ts = { names = false },
    },
  },

  { "stevearc/conform.nvim",
    event = { "BufWritePre", "BufNewFile" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fb",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format [b]uffer",
      },
      {
        "<leader>fc",
        function()
          local ignore_filetypes = {}
          local hunks = require("gitsigns").get_hunks({ type = {"add", "modify"} })
          if hunks == nil then
            return
          end

          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.notify("Formatting for " .. vim.bo.filetype .. " has been disabled in Conform config")
            return
          end

          local format = require("conform").format
          local function format_hunk()
            if next(hunks) == nil then
              vim.notify("Done formatting git hunks")
              return
            end

            local hunk = table.remove(hunks)

            if hunk ~= nil then
              local start = hunk.added.start
              local last = start + hunk.added.count
              -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
              local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
              local range = { start = { start, 0 }, ["end"] = { last - 1, last_hunk_line:len() - 1 } }

              format({ range = range, async = true, lsp_fallback = true }, function()
                vim.defer_fn(function()
                  format_hunk()
                end, 1)
              end)
            end
          end

          format_hunk()
        end,
        mode = "",
        desc = "Format [c]hanges",
      },
    },

    opts = {
      notify_on_error = true,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
      },
      lazy = true,
    },
  },

  { "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    keys = { { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
    lazy = true,
  },

  { "nvim-treesitter/nvim-treesitter-context",
    opts = {
      max_lines = 3,
      line_numbers = true,
      separator = "-",
      trim_scope = "outer",
    },
  },
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
