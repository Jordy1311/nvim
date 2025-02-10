return {
  "folke/which-key.nvim",
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
}

