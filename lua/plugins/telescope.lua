return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
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
        path_display = { "filename_first","smart" },
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
  opts = { lazy = true },
}

