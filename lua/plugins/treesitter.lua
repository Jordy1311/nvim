return { "nvim-treesitter/nvim-treesitter",
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
}

