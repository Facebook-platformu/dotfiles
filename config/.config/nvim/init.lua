-----------------------------------
-- Editor
-----------------------------------
vim.opt.updatetime = 2000

-- edit
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.wrap = false

-- completion
vim.opt.completeopt = 'menu,menuone,noselect'

-- show whitespace chars
vim.opt.list      = true
vim.opt.listchars = 'tab:»-,trail:_,eol:↲,extends:»,precedes:«,nbsp:･'

-- search
vim.opt.ignorecase = true
vim.opt.smartcase  = true
vim.opt.incsearch  = true
vim.opt.hlsearch   = true

-- clipboard
vim.opt.clipboard = 'unnamedplus'

-- indent
vim.opt.autoindent  = true
vim.opt.smartindent = true
vim.opt.expandtab   = true
vim.opt.tabstop     = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth  = 2
vim.opt.shiftround  = true

-- split
vim.opt.splitbelow = true
vim.opt.splitright = true

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- sign
vim.opt.signcolumn = 'yes';

-----------------------------------
-- Keymaps
-----------------------------------
vim.g.mapleader = ' '
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>',
  { noremap = true, desc = 'Search: Clear Search Highlight' })

-----------------------------------
-- Plugins
-----------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Libraries
  {
    'nvim-tree/nvim-web-devicons', -- required by lualine and nvim-tree.lua
    lazy = true,
    config = function()
      require('nvim-web-devicons').setup()
    end,
  },
  {
    'mortepau/codicons.nvim', -- required by config function for nvim-dap
    lazy = true,
  },
  -- LSP
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    config = function()
      -- https://github.com/neovim/nvim-lspconfig/tree/v0.1.5#suggested-configuration
      local on_attach_lsp = function(client, bufnr)
        local telescope_builtin = require('telescope.builtin')

        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gt', telescope_builtin.lsp_type_definitions,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to Type Definitions' }))
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to Declarations' }))
        vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to Definitions' }))
        vim.keymap.set('n', 'K', require('lspsaga.hover').render_hover_doc,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Show Hover Card' }))
        vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to Implementations' }))
        vim.keymap.set('n', 'gs', telescope_builtin.lsp_document_symbols,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to Symbols in Document' }))
        vim.keymap.set('n', 'gS', telescope_builtin.lsp_dynamic_workspace_symbols,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Search Symbols in Workspace' }))
        vim.keymap.set({ 'n', 'i' }, '<C-k>', require('lspsaga.signaturehelp').signature_help,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Show Signature Help' }))
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
        vim.keymap.set('n', '<space>D', telescope_builtin.lsp_type_definitions,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to Type Definitions' }))
        vim.keymap.set('n', '<space>rn', require('lspsaga.rename').rename,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Rename Symbol' }))
        vim.keymap.set('n', '<space>.', require('lspsaga.codeaction').code_action,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Code Action', }))
        vim.keymap.set('v', '<space>.', require('lspsaga.codeaction').range_code_action,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Code Action', }))
        vim.keymap.set('n', 'gr', telescope_builtin.lsp_references,
          vim.tbl_extend('keep', bufopts, { desc = "LSP: Go to References" }))
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Format Document' }))
        vim.keymap.set('n', '<space>e', telescope_builtin.diagnostics,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Show Workspace Diagnostics' }))
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to prev Diagnostic' }))
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Go to next Diagnostic' }))
        vim.keymap.set('n', '<space>q', function() telescope_builtin.diagnostics({ bufnr = 0 }) end,
          vim.tbl_extend('keep', bufopts, { desc = 'LSP: Show diagnostics in Document' }))

        -- autocmds
        local augroup = vim.api.nvim_create_augroup("LspAutoCmds", { clear = true })
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

        local cursor_diagnostics_timer = vim.loop.new_timer()
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          group = augroup,
          callback = function()
            cursor_diagnostics_timer:stop()
            cursor_diagnostics_timer:start(1000, 0, vim.schedule_wrap(function()
              require('lspsaga.diagnostic').show_line_diagnostics()
            end))
          end,
        })
      end

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = { '*.go', '*.rs' },
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = { '*.go' },
        callback = function()
          -- https://github.com/golang/tools/blob/gopls/v0.11.0/gopls/doc/vim.md#imports
          local params = vim.lsp.util.make_range_params()
          params.context = { only = { 'source.organizeImports' } }
          local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
        end,
      })

      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = {
          '*.js', '*.jsx', '*.cjs', '*.mjs',
          '*.ts', '*.tsx', '*.cts', '*.mts',
          '*.vue'
        },
        callback = function()
          vim.cmd('EslintFixAll')
          vim.lsp.buf.format({ name = 'null-ls', async = false })
        end,
      })

      local lspconfig = require('lspconfig')
      local mason_lspconfig = require('mason-lspconfig')

      mason_lspconfig.setup({
        ensure_installed = {
          'bashls',
          'bufls',
          'dockerls',
          'graphql',
          'rust_analyzer',
          -- Ruby
          'solargraph',
          -- JS
          'eslint',
          'tsserver',
          'volar',
          -- Go
          'gopls',
          'golangci_lint_ls',
          -- Lua
          'sumneko_lua',
        },
        automatic_installation = true,
      })
      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach_lsp,
            capabilities = require('cmp_nvim_lsp').default_capabilities(),
          })
        end,
      })
    end,
  },
  {
    'kkharji/lspsaga.nvim',
    -- FIXME: workaround. should setup lspsaga before set colorscheme.
    -- lazy = true,
    config = function()
      require('lspsaga').setup()
      vim.keymap.set({ 'n' }, '<Plug>(lsp)n', require('lspsaga.diagnostic').navigate('next'))
      vim.keymap.set({ 'n' }, '<Plug>(lsp)p', require('lspsaga.diagnostic').navigate('prev'))
    end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = { null_ls.builtins.formatting.prettier },
      })
    end,
  },
  {
    'jayp0521/mason-null-ls.nvim',
    config = function()
      require('mason-null-ls').setup({
        ensure_installed = { 'prettier' },
        automatic_installation = true,
      })
    end,
  },
  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim'
    },
    config = function()
      local cmp = require('cmp')

      cmp.setup({
        enabled = true,
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp_signature_help' },
          { name = 'nvim_lsp' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          format = require('lspkind').cmp_format()
        }
      })

      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' }
            }
          }
        })
      })

      -- for nvim-autopairs
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    event = "BufReadPost",
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        config = function()
          require('treesitter-context').setup()
        end,
      },
      'nvim-treesitter/nvim-treesitter-textobjects', -- required by nvim-surround
      'JoosepAlviste/nvim-ts-context-commentstring',
      'mrjones2014/nvim-ts-rainbow',
      {
        'haringsrob/nvim_context_vt',
        config = function()
          require('nvim_context_vt').setup({
            min_rows = 3,
          })
        end,
      },
      'windwp/nvim-ts-autotag',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash',
          'css',
          'dockerfile',
          'gitignore',
          'go',
          'gomod',
          'gowork',
          'graphql',
          'html',
          'javascript',
          'json',
          'json5',
          'lua',
          'markdown',
          'proto',
          'ruby',
          'rust',
          'scss',
          'sql',
          'terraform',
          'toml',
          'typescript',
          'tsx',
          'vim',
          'vue',
          'yaml',
        },
        -- indent = {
        --   enable = true,
        -- },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = 1500,
          colors = {
            "#e27878", -- red
            "#e2a478", -- yellow
            "#b4be82", -- green
            "#84a0c6", -- blue
          }, -- table of hex strings
          termcolors = {
            'Red',
            'Yellow',
            'Green',
            'Blue',
          }
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        matchup = {
          enable = true,
        },
        autotag = {
          enable = true,
        }
      })
    end
  },
  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'otavioschwanck/telescope-alternate.nvim',
      'stevearc/aerial.nvim',
      'nvim-telescope/telescope-dap.nvim',
    },
    cmd = 'Telescope',
    keys = {
      {
        '<leader><leader>', function() require('telescope.builtin').find_files() end,
        mode = 'n', noremap = true, desc = "File: Go to ...",
      },
      {
        '<leader>gg', function() require('telescope.builtin').live_grep() end,
        mode = 'n', noremap = true, desc = "File: Grep",
      },
      {
        '<leader>gs', function() require('telescope.builtin').git_status() end,
        mode = 'n', noremap = true, desc = "File: Git Suatus",
      },
      {
        '<leader>gu', function() require('telescope.builtin').git_files({
            git_command = { "git", "diff", "--name-only", "--diff-filter=U" },
          })
        end,
        mode = 'n', noremap = true, desc = "File: Git Unmerged Files",
      },
      {
        '<leader>gb', function() require('telescope.builtin').buffers() end,
        mode = 'n', noremap = true, desc = "File: Buffers",
      },
      {
        '<leader>ga', function() require('telescope').extensions['telescope-alternate'].alternate_file() end,
        mode = 'n', noremap = true, desc = "File: Alternate",
      },
      {
        '<leader>gf',
        function() require('telescope').extensions['aerial'].aerial({ filter_kind = { 'Function', 'Method' }, }) end,
        mode = 'n', noremap = true, desc = "LSP: Functions and Methods",
      },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          layout_strategy = 'vertical',
          layout_config = {
          },
          mappings = {
            i = {
              ['<esc>'] = require('telescope.actions').close,
              ['<C-u>'] = false
            },
          },
          winblend = 20,
        },
        extensions = {
          ["telescope-alternate"] = {
            mappings = {
              -- go
              { "(.*).go", {
                { "[1]_test.go", "Test", false },
              } },
              { "(.*)_test.go", {
                { "[1].go", "Source", false },
              } },
              -- js, ts
              { "(.*)/([^!]*).([cm]?[tj]s)(x?)", {
                { "[1]/[2].test.[3][4]", "Test", false },
                { "[1]/[2].spec.[3][4]", "Test", false },
                { "[1]/[2].stories.[3][4]", "Storybook", false },
                { "[1]/[2].test.[3]", "Test", false },
                { "[1]/[2].spec.[3]", "Test", false },
                { "[1]/[2].stories.[3]", "Storybook", false },
                { "[1]/index.[3]", "Index", false },
              } },
              { "(.*)/([^!]*).(?:(test|spec)).([cm]?[tj]s)(x?)", {
                { "[1]/[2].[3][4]", "Source", false },
                { "[1]/[2].stories.[3][4]", "Source Storybook", false },
                { "[1]/[2].[3]", "Source", false },
                { "[1]/[2].stories.[3]", "Source Storybook", false },
              } },
              { "(.*)/([^!]*).stories.([cm]?[tj]s)(x?)", {
                { "[1]/[2].[3][4]", "Source", false },
                { "[1]/[2].test.[3][4]", "Source Test", false },
                { "[1]/[2].spec.[3][4]", "Source Test", false },
                { "[1]/[2].[3]", "Source", false },
                { "[1]/[2].test.[3]", "Source Test", false },
                { "[1]/[2].spec.[3]", "Source Test", false },
              } },
            },
          },
        },
      })
      telescope.load_extension('telescope-alternate')
      telescope.load_extension('aerial')
      telescope.load_extension('dap')
    end
  },
  -- Debugger
  {
    'mfussenegger/nvim-dap',
    cond = not vim.g.vscode,
    dependencies = {
      {
        'leoluz/nvim-dap-go',
        ft = 'go',
        config = function()
          require('dap-go').setup {
            dap_configurations = {
              {
                type = "go",
                name = "Attach remote",
                mode = "remote",
                request = "attach",
              },
            },
            delve = {
              initialize_timeout_sec = 20,
              port = "${port}"
            },
          }
        end
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        config = function()
          require("nvim-dap-virtual-text").setup()
        end
      }
    },
    keys = {
      { "<Leader>dc", function() require('dap').continue() end, mode = "n", silent = true, noremap = true,
        desc = 'Debug: Continue' },
      { "<Leader>dsv", function() require('dap').step_over() end, mode = "n", silent = true, noremap = true,
        desc = 'Debug: Step over' },
      { "<Leader>dsi", function() require('dap').step_into() end, mode = "n", silent = true, noremap = true,
        desc = 'Debug: Step into' },
      { "<Leader>dso", function() require('dap').step_out() end, mode = "n", silent = true, noremap = true,
        desc = 'Debug: Step out' },
      { "<Leader>b", function() require('dap').toggle_breakpoint() end, mode = "n", silent = true, noremap = true,
        desc = 'Debug: Toggle breakpoint' },
      { "<Leader>B", function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, mode = "n",
        silent = true, noremap = true, desc = 'Debug: Add conditional breakpoint' },
      { "<Leader>lp", function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
        mode = "n", silent = true, noremap = true, desc = 'Debug: Add Logpoint' },
      { "<Leader>dr", function() require('dap').repl.open() end, mode = "n", silent = true, noremap = true,
        desc = 'Debug: Open REPL' },
      { "<Leader>dl", function() require('dap').run_last() end, mode = "n", silent = true, noremap = true,
        desc = 'Debug: Re-run the last debug adapter' },
      { "<Leader>dv", function() require('telescope').extensions['dap'].variables() end, mode = "n", silent = true,
        noremap = true, desc = 'Debug: Show variables' },
      { "<Leader>df", function() require('telescope').extensions['dap'].frames() end, mode = "n", silent = true,
        noremap = true, desc = 'Debug: Show frames' },
      { "<Leader>d<space>", function() require('telescope').extensions['dap'].commands() end, mode = "n", silent = true,
        noremap = true, desc = 'Debug: Show commands' },
    },
    config = function()
      local codicons = require('codicons')
      vim.fn.sign_define('DapBreakpoint',
        { text = codicons.get('circle-filled'), texthl = 'Error', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition',
        { text = codicons.get('debug-breakpoint-conditional'), texthl = 'Error', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint',
        { text = codicons.get('debug-breakpoint-log'), texthl = 'Error', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = codicons.get('stop-circle'), texthl = 'Error', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected',
        { text = codicons.get('debug-breakpoint-unsupported'), texthl = 'Error', linehl = '', numhl = '' })
    end
  },
  -- Appearance
  { 'cocopon/iceberg.vim', cond = not vim.g.vscode },
  {
    'nvim-tree/nvim-tree.lua',
    cond = not vim.g.vscode,
    keys = {
      { "<C-h>", ":NvimTreeFindFileToggle<cr>", mode = "n", desc = "File: Tree", silent = true, noremap = true },
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = 'case_sensitive',
        view = {
          adaptive_size = true,
          float = {
            enable = true,
          }
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
          custom = { "^.git$" },
        },
      })
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    cond = not vim.g.vscode,
    dependencies = {
      'arkav/lualine-lsp-progress',
    },
    config = function()
      local codicons = require('codicons')
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'iceberg',
        },
        sections = {
          lualine_a = {
            'mode',
            {
              function() return require('dap').status() end,
              icon = { codicons.get('debug') },
              cond = function()
                return package.loaded['dap'] ~= nil and #(require('dap').status()) > 0
              end,
              color = { fg = '#b4be82', bg = '#1e2132' }
            },
          },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = {
            'filename',
            { "aerial", sep = '  ', dence = true }, -- the same as copmonent separator
            { 'lsp_progress' }
          },
          lualine_x = { 'encoding' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      })
    end
  },
  {
    'stevearc/aerial.nvim',
    lazy = true,
    config = function()
      require('aerial').setup()
    end,
  },
  {
    'petertriho/nvim-scrollbar',
    cond = not vim.g.vscode,
    event = "BufReadPost",
    config = function()
      require('scrollbar').setup({
        marks = {
          Search = { color_nr = '3', color = '#c57339' },
          Error = { color_nr = '9', color = '#cc3768' },
          Warn = { color_nr = '11', color = '#b6662d' },
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = true,
          handle = true,
          search = true,
        }
      })
    end
  },
  {
    'kevinhwang91/nvim-hlslens',
    cond = not vim.g.vscode,
    event = "BufReadPost",
    init = function()
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight link HlSearchLens DiagnosticHint',
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight link HlSearchLensNear DiagnosticHint',
      })
    end,
    config = function()
      require('scrollbar.handlers.search').setup({})
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    cond = not vim.g.vscode,
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight SignColumn ctermbg=none guibg=none'
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight GitGutterAdd ctermbg=none guibg=none'
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight GitGutterChange ctermbg=none guibg=none'
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight GitGutterDelete ctermbg=none guibg=none'
      })
    end,
    config = function()
      require('gitsigns').setup()
      require('scrollbar.handlers.gitsigns').setup()
    end,
  },
  {
    "folke/which-key.nvim",
    cond = not vim.g.vscode,
    config = function()
      require("which-key").setup()
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    cond = not vim.g.vscode,
    config = function()
      require('indent_blankline').setup()
    end
  },
  {
    'zbirenbaum/neodim',
    cond = not vim.g.vscode,
    event = 'LspAttach',
    config = function()
      require('neodim').setup()
    end
  },
  -- Editor
  { 'andymass/vim-matchup' },
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },
  {
    'numToStr/Comment.nvim',
    keys = { { '<Leader>/', mode = { 'n', 'v' } } },
    config = function()
      require('Comment').setup({
        toggler = {
          line = '<Leader>/',
        },
        opleader = {
          line = '<Leader>/',
        },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
  {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup()
    end,
  },
  {
    'folke/todo-comments.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'nvim-lua/plenary.nvim', },
    config = function()
      require('todo-comments').setup({
        highlight = { after = "" }
      })
    end,
  },
  {
    'RRethy/vim-illuminate',
    cond = not vim.g.vscode,
    event = { 'CursorMoved', 'CursorMovedI' },
    init = function()
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight IlluminatedWordText ctermbg=238 guibg=#33374c'
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight IlluminatedWordRead ctermbg=238 guibg=#33374c'
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight IlluminatedWordWrite ctermbg=238 guibg=#33374c'
      })
    end,
    config = function()
      require('illuminate').configure()
    end,
  },
  {
    "ntpeters/vim-better-whitespace",
    cond = not vim.g.vscode,
    config = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.strip_whitespace_on_save = 1
      vim.g.strip_whitespace_confirm = 0
    end
  },
  {
    "dinhhuy258/git.nvim",
    keys = {
      { '<Leader>go', desc = 'Git: Open in GitHub' },
      { '<Leader>gp', desc = 'Git: Open Pull Request Page' },
    },
    config = function()
      require('git').setup()
    end
  },
  {
    'monaqa/dial.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', },
    keys = function()
      local switch_groups = {
        go = 'switch_go',
        javascript = 'switch_js',
        javascriptreact = 'switch_js',
        typescript = 'switch_js',
        typescriptreact = 'switch_js',
      }
      local function get_switch_group()
        return switch_groups[vim.bo.filetype] or 'switch'
      end

      return {
        { "<C-a>", function() return require("dial.map").inc_normal() end, mode = "n", expr = true,
          noremap = true,
          desc = "Edit: Increment" },
        { "<C-x>", function() return require("dial.map").dec_normal() end, mode = "n", expr = true,
          noremap = true,
          desc = "Edit: Decrement" },
        { "<C-a>", function() return require("dial.map").inc_visual() end, mode = "v", expr = true,
          noremap = true,
          desc = "Edit: Increment" },
        { "<C-x>", function() return require("dial.map").dec_visual() end, mode = "v", expr = true,
          noremap = true,
          desc = "Edit: Decrement" },
        { "g<C-a>", function() return require("dial.map").inc_gvisual() end, mode = "v", expr = true,
          noremap = true,
          desc = "Edit: Increment" },
        { "g<C-x>", function() return require("dial.map").dec_gvisual() end, mode = "v", expr = true,
          noremap = true,
          desc = "Edit: Decrement" },
        { "<leader>a", function() return require("dial.map").inc_normal(get_switch_group()) end, mode = "n", expr = true,
          noremap = true,
          desc = "Edit: Switch prev" },
        { "<leader>x", function() return require("dial.map").dec_normal(get_switch_group()) end, mode = "n", expr = true,
          noremap = true,
          desc = "Edit: Switch next" },
      }
    end,
    config = function()
      local augend = require("dial.augend")
      local switch_common = {
        augend.constant.alias.bool,
        augend.constant.new({ elements = { '&&', '||' }, word = false, cyclic = true }),
        augend.constant.new({ elements = { '==', '!=' }, word = false, cyclic = true }),
        augend.case.new({
          types = { "camelCase", "snake_case" },
          cyclic = true,
        }),
        augend.case.new({
          types = { "PascalCase", "SCREAMING_SNAKE_CASE" },
          cyclic = true,
        }),
      }
      require('dial.config').augends:register_group({
        switch = switch_common,
        switch_go = vim.list_extend({
          augend.constant.new({ elements = { "=", ":=" }, word = false, cyclic = true }),
          augend.constant.new({ elements = { "var", "const" }, cyclic = true }),
        }, switch_common),
        switch_js = vim.list_extend({
          augend.constant.new({ elements = { "let", "const" }, cyclic = true }),
        }, switch_common),
      })
    end
  },
  -- lang
  {
    "vuki656/package-info.nvim",
    event = 'VimEnter',
    dependencies = { "MunifTanjim/nui.nvim" },
    cond = not vim.g.vscode,
    init = function()
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight link PackageInfoOutdatedVersion DiagnosticHint'
      })
      vim.api.nvim_create_autocmd('Colorscheme', {
        pattern = '*',
        command = 'highlight link PackageInfoUpToDateVersion DiagnosticHint'
      })
    end,
    config = function()
      require('package-info').setup({
        autostart = true,
        hide_up_to_date = true,
        hide_unstable_version = true,
      })
      require('package-info').show()
    end
  },
  -- misc
  {
    'alexghergh/nvim-tmux-navigation',
    cond = not vim.g.vscode,
    keys = {
      { '<C-w>h', function() require('nvim-tmux-navigation').NvimTmuxNavigateLeft() end, mode = "n", noremap = true },
      { '<C-w>j', function() require('nvim-tmux-navigation').NvimTmuxNavigateDown() end, mode = "n", noremap = true },
      { '<C-w>k', function() require('nvim-tmux-navigation').NvimTmuxNavigateUp() end, mode = "n", noremap = true },
      { '<C-w>l', function() require('nvim-tmux-navigation').NvimTmuxNavigateRight() end, mode = "n", noremap = true },
      { '<C-w>\\', function() require('nvim-tmux-navigation').NvimTmuxNavigateLastActive() end, mode = "n",
        noremap = true },
      { '<C-w>Space', function() require('nvim-tmux-navigation').NvimTmuxNavigateNext() end, mode = "n", noremap = true },
    },
    config = function()
      require('nvim-tmux-navigation').setup({ disable_when_zoomed = true })
    end,
  },
})

-----------------------------------
-- Appearance
-----------------------------------
if not vim.g.vscode then
  -- clear bg
  vim.api.nvim_create_autocmd('Colorscheme', {
    pattern = '*',
    command = 'highlight Normal ctermbg=none guibg=none'
  })
  vim.api.nvim_create_autocmd('Colorscheme', {
    pattern = '*',
    command = 'highlight NonText ctermbg=none guibg=none'
  })
  vim.api.nvim_create_autocmd('Colorscheme', {
    pattern = '*',
    command = 'highlight LineNr ctermbg=none guibg=none'
  })
  vim.api.nvim_create_autocmd('Colorscheme', {
    pattern = '*',
    command = 'highlight Folded ctermbg=none guibg=none'
  })
  vim.api.nvim_create_autocmd('Colorscheme', {
    pattern = '*',
    command = 'highlight EndOfBuffer ctermbg=none guibg=none'
  })
  vim.opt.termguicolors = true
  vim.opt.winblend = 20
  vim.opt.pumblend = 20
  vim.cmd.colorscheme('iceberg')
end