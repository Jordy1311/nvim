return { "stevearc/conform.nvim",
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
}

