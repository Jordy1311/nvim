return {
  "stevearc/conform.nvim",
  event = { "BufWritePre", "BufNewFile" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fb",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "[f]ormat buffer",
    },
    {
      "<leader>fc",
      function()
        local ignore_filetypes = { "lua" }
        if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
          vim.notify("Formatting for " .. vim.bo.filetype .. " has been prevented in Conform config")
          return
        end

        local hunks = require("gitsigns").get_hunks()
        if hunks == nil then
          return
        end

        local format = require("conform").format

        local function format_hunk()
          if next(hunks) == nil then
            vim.notify("Done formatting git hunks")
            return
          end
          local hunk = nil
          while next(hunks) ~= nil and (hunk == nil or hunk.type == "delete") do
            hunk = table.remove(hunks)
          end

          if hunk ~= nil and hunk.type ~= "delete" then
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
      desc = "[f]ormat changes",
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
}
