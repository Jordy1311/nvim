return {
  "neovim/nvim-lspconfig",
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
  opts = { lazy = true },
}

