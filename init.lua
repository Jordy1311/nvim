----------- installs lazy package manager if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local global = vim.g
local option = vim.opt
local keymap = vim.keymap

---------- global options
global.mapleader = " "
global.maplocalleader = " "
global.have_nerd_font = true

---------- visual options
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

---------- behavioural options
option.clipboard = "unnamedplus"
option.autoread = true
option.mouse = "a"
option.undofile = true
option.ignorecase = true
option.smartcase = true
option.updatetime = 200
option.timeoutlen = 200
option.splitright = true
option.inccommand = "split"

---------- key re-maps
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

---------- import packages with lazy
require("lazy").setup({
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 100,
    config = function()
      vim.cmd([[colorscheme onedark]])
    end
  },

  {
    "tpope/vim-sleuth"
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "folke/which-key.nvim",
    lazy = true,
    event = "VimEnter",
    config = function()
      require("which-key").setup()
      require("which-key").add({
        { "<leader>f", group = "[f]ormat..." },
        { "<leader>l", group = "[l]azygit..." },
        { "<leader>r", group = "[r]ename..." },
        { "<leader>s", group = "[s]earch..." },
        { "<leader>t", group = "[t]oggle..." },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
      { "j-hui/fidget.nvim", opts = {} },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "williamboman/mason.nvim" },
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
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
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
  },

  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", cond = vim.g.have_nerd_font },
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
      local builtin = require("telescope.builtin")
      local lga_actions = require("telescope-live-grep-args.actions")

      telescope.setup({
        defaults = {
          scroll_stratagey = "limit",
          path_display = function(_, path)
            local tail = vim.fs.basename(path)
            local dir = vim.fs.dirname(path)

            if dir == '.' then return tail end

            local win_width = vim.api.nvim_win_get_width(0)
            local max_dir_len = win_width - #tail - 10

            if #dir > max_dir_len then
              local parts = vim.split(dir, '/')
              for i = #parts, 1, -1 do
                repeat
                  parts[i] = parts[i]:sub(1, -2)
                  dir = table.concat(parts, '/')
                until #dir <= max_dir_len or #parts[i] == 1
              end
            end

            local padding = win_width - (#tail + #dir) - 5
            if padding < 0 then padding = 0 end

            return tail .. string.rep(' ', padding) .. dir
          end,
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          live_grep_args = {
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob  **" }),
              },
            },
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
      pcall(telescope.load_extension, "live_grep_args")

      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search [h]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search [k]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search [f]iles" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search cursor [w]ord" })
      vim.keymap.set("n", "<leader>sg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = "Search by [g]rep" })
      -- vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search by [g]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search [d]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search [r]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "Search recent files ([.] for repeat)" })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = " Find existing buffers" })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = " Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Search by grep in Open Files",
        })
      end, { desc = "Search by grep in Open Files" })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    lazy = true,
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
          ["<Return>"] = cmp.mapping.confirm({ select = true }),
          ["<S-Return>"] = cmp.mapping.complete(),
          ["<Esc>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "lazydev", group_index = 0 },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "angular",
        "bash",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "gitignore",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "regex",
        "scss",
        "svelte",
        "typescript",
        "vim",
        "vimdoc",
        "yaml"
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },

    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = true,
    event = "BufWinEnter",
    opts = {
      max_lines = 3,
      line_numbers = true,
      separator = "-",
      trim_scope = "outer",
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = true,
    cmd = "Neotree",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "\\", ":Neotree focus filesystem float toggle reveal<CR>", desc = "NeoTree reveal" },
    },
  },

  {
    "stevearc/conform.nvim",
    lazy = true,
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
    },
  },

  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    keys = { { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
  },

  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = "BufWinEnter",
    opts = {
      signs = { add = { text = "+" }, change = { text = "C" }, delete = { text = "D" } },
      current_line_blame = true,
    },
  },

  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })

      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = vim.g.have_nerd_font })

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
    end,
  },

  {
    "windwp/nvim-autopairs",
    lazy = true,
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  {
    "norcalli/nvim-colorizer.lua",
    lazy = true,
    event = "BufWinEnter",
    opts = {
      "*",
      css = { rgb_fn = true },
      html = { names = false },
      js = { names = false },
      ts = { names = false },
    },
  },

  {
    "folke/todo-comments.nvim",
    lazy = true,
    event = "BufWinEnter",
    opts = {},
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

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  desc = "Open jade files as pug files",
  pattern = { "*.jade" },
  command = "setlocal filetype=pug",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  desc = "Enables text wrapping on markdown files",
  pattern = { "*.md" },
  command = "setlocal textwidth=80",
})
