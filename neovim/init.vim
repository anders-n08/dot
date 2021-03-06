" -----------------------------------------------------------------------------
"   -- General stuff --
" -----------------------------------------------------------------------------

filetype on 
filetype plugin indent on

set hidden              " Retain buffer when abandoned.
" set number
" set relativenumber
set nonumber
set showcmd
set wildmenu            " Visual autocomplete for command menu.
set showmatch           " Highlight matching brace.
set laststatus=2        " Window will always have a status line.
set nobackup
set noswapfile

set incsearch
set hlsearch
set ignorecase
set smartcase

" set autoindent
" set copyindent

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set mouse=a

" Persistant undo.
set undodir=~/.vim/undodir
set undofile

" Copy/Paste To/From global buffer.
set clipboard+=unnamedplus

" Automatically reload file if changed outside of vim.
set autoread
au FocusGained * :checktime

let mapleader=","   " leader is comma

set shell=/bin/bash

nnoremap Y y$

" -----------------------------------------------------------------------------
"   -- Navigation --
" -----------------------------------------------------------------------------

" Simple escape from terminal mode.
tnoremap <Esc> <C-\><C-n>

" Select buffer. Moved to barbar.
" nnoremap <tab> :bn<CR>
" nnoremap <s-tab> :bp<CR>

" Split navigation.
" nnoremap <c-j> <c-w><c-j>
" nnoremap <c-k> <c-w><c-k>
" nnoremap <c-l> <c-w><c-l>
" nnoremap <c-h> <c-w><c-h>

" -----------------------------------------------------------------------------
"   -- Plugins --
" -----------------------------------------------------------------------------

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Treesitter. 
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'

" LSP.
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim'

" Show function signature when you type (LSP thingy).
Plug 'ray-x/lsp_signature.nvim'

" Auto-complete.
Plug 'hrsh7th/nvim-compe'

" Telescope.
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Base2Tone colors.
Plug 'k-takata/minpac', {'type': 'opt'}
Plug 'atelierbram/Base2Tone-vim'

" Flutter tools.
Plug 'nvim-lua/plenary.nvim'
Plug 'akinsho/flutter-tools.nvim'

" Editor-config.
Plug 'editorconfig/editorconfig-vim'

" Handle code comments.
Plug 'b3nj5m1n/kommentary'

" Navigate between vim and tmux.
Plug 'christoomey/vim-tmux-navigator'

" Snip editor - only install this to shutup warnings from nvim-compe at the
" moment (I'll maybe revisit snippets later).
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

" Tab-bar plugin.
Plug 'romgrk/barbar.nvim'

" Support for zig programming (format, build etc).
Plug 'ziglang/zig.vim'

" DAP debug protocol.
Plug 'mfussenegger/nvim-dap'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'rcarriga/nvim-dap-ui'

" Rust 
Plug 'rust-lang/rust.vim'

" Git Worktree
Plug 'ThePrimeagen/git-worktree.nvim'

call plug#end()

" -----------------------------------------------------------------------------
"   -- Airline --
" -----------------------------------------------------------------------------

let g:airline_theme='minimalist'

" -----------------------------------------------------------------------------
"   -- LSP --
" -----------------------------------------------------------------------------

sign define LspDiagnosticsSignError text=!
sign define LspDiagnosticsSignWarning text=?
" sign define LspDiagnosticsSignInformation text=i
" sign define LspDiagnosticsSignHint text=h

lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys 
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.cmd("nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>")
    vim.cmd("nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>")
    vim.cmd("nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>")
    vim.cmd("nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>")
    vim.cmd("nnoremap <silent> ca :Lspsaga code_action<CR>")
    vim.cmd("nnoremap <silent> K :Lspsaga hover_doc<CR>")
    -- vim.cmd('nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>')
    vim.cmd("nnoremap <silent> <C-p> :Lspsaga diagnostic_jump_prev<CR>")
    vim.cmd("nnoremap <silent> <C-n> :Lspsaga diagnostic_jump_next<CR>")
    -- scroll down hover doc or scroll in definition preview
    vim.cmd("nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>")
    -- scroll up hover doc
    vim.cmd("nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>")
    vim.cmd('command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()')

    require "lsp_signature".on_attach({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
            border = "single",
            use_lspsaga = true
        }
    })

end

require'lspsaga'.init_lsp_saga()

-- Zig
require'lspconfig'.zls.setup{}

-- Pyright
require'lspconfig'.pyright.setup{}

-- Note - phpactor is currently installed in /Users/anders/Projects/a00n08/lsp/phpactor
-- and linked from ~/.local/bin. Without phpactor available globally the LSP
-- for PHP will silently not work. 

require'lspconfig'.phpactor.setup{}

-- Rust
require'lspconfig'.rust_analyzer.setup{}

-- Clangd (C/C++)
require'lspconfig'.clangd.setup{}

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "zls", "pyright", "phpactor", "rust_analyzer", "clangd" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end

EOF

" Do prevent 'jumping' let's always show the sign column.
set signcolumn=yes

" -----------------------------------------------------------------------------
"   -- Treesitter --
" -----------------------------------------------------------------------------

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "c",
  highlight = {
    enable = true, 
  },
  indent = {
    enable = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}
EOF

" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()

" -----------------------------------------------------------------------------
"   -- Telescope --
" -----------------------------------------------------------------------------

nnoremap <leader>f <cmd>Telescope find_files<cr>
nnoremap <leader>s <cmd>Telescope live_grep<cr>
nnoremap <leader>b <cmd>Telescope buffers<cr>
nnoremap <leader>h <cmd>Telescope help_tags<cr>
nnoremap <leader>t <cmd>Telescope treesitter<cr>
nnoremap <leader>q <cmd>Telescope quickfix<cr>
nnoremap <leader>r <cmd>Telescope registers<cr>

lua <<EOF
    require("telescope").load_extension("flutter")
    require("telescope").load_extension("git_worktree")
EOF

" -----------------------------------------------------------------------------
"   -- Auto-complete (nvim-compe) --
" -----------------------------------------------------------------------------

set completeopt=menuone,noselect

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 1
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.resolve_timeout = 800
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.vsnip = v:true
let g:compe.source.ultisnips = v:true

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" This entire section just to get tab and stab to navigate
" the completion windows. Copied from nvim-compe github page.

lua <<EOF
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
EOF

" --------------------------------------------------------------------------------
"  -- Base 2 tone colors --
" --------------------------------------------------------------------------------
set termguicolors
colorscheme Base2Tone_LakeDark
let g:airline_theme='Base2Tone_LakeDark'

" --------------------------------------------------------------------------------
"  -- Flutter tools -- 
" --------------------------------------------------------------------------------

lua << EOF
  require("flutter-tools").setup{
    widget_guides = {
        enabled = false,
    },
    closing_tags = {
        highlight = "ErrorMsg", 
        prefix = ">",
        enabled = true,
      }
  }
EOF

" --------------------------------------------------------------------------------
"  -- Barbar tab-bar -- 
" --------------------------------------------------------------------------------

" This plugin has a lot more to offer, but this is a clean look.

let bufferline = get(g:, 'bufferline', {})
let bufferline.icons = v:false

let bufferline.icon_separator_active = ''
let bufferline.icon_separator_inactive = ''
let bufferline.icon_close_tab = ''
let bufferline.icon_close_tab_modified = ''

nnoremap <silent>    <s-tab> :BufferPrevious<CR>
nnoremap <silent>    <tab> :BufferNext<CR>

" --------------------------------------------------------------------------------
"  -- DAP debug protocol -- 
" --------------------------------------------------------------------------------

lua<<EOF

local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/local/opt/llvm/bin/lldb-vscode',
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},

    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    runInTerminal = false,
  },
}

-- If you want to use this for rust and c, add something like this:

dap.configurations.c = dap.configurations.cpp
dap.configurations.zig = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

EOF

" --------------------------------------------------------------------------------
"  -- DAP virtual text -- 
" --------------------------------------------------------------------------------

lua<<EOF
vim.g.dap_virtual_text = true
EOF

" --------------------------------------------------------------------------------
"  -- DAP UI -- 
" --------------------------------------------------------------------------------

lua<<EOF

require("dapui").setup({
  icons = { expanded = "???", collapsed = "???" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
  },
  sidebar = {
    open_on_start = true,
    -- You can change the order of elements in the sidebar
    elements = {
      -- Provide as ID strings or tables with "id" and "size" keys
      {
        id = "scopes",
        size = 0.25, -- Can be float or integer > 1
      },
      { id = "breakpoints", size = 0.25 },
      { id = "stacks", size = 0.25 },
      { id = "watches", size = 00.25 },
    },
    width = 40,
    position = "left", -- Can be "left" or "right"
  },
  tray = {
    open_on_start = true,
    elements = { "repl" },
    height = 10,
    position = "bottom", -- Can be "bottom" or "top"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
})

EOF

" --------------------------------------------------------------------------------
"  -- Rust -- 
" --------------------------------------------------------------------------------

let g:rustfmt_autosave = 1

" --------------------------------------------------------------------------------
"  -- Kommentary -- 
" --------------------------------------------------------------------------------

lua << EOF
require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
})
EOF

" --------------------------------------------------------------------------------
"  -- Git Worktree -- 
" --------------------------------------------------------------------------------

lua << EOF
    vim.cmd("nnoremap <leader> w <cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>")
EOF
