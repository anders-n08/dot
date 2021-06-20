" -----------------------------------------------------------------------------
"   -- General stuff --
" -----------------------------------------------------------------------------

filetype on 
filetype plugin indent on

set hidden              " Retain buffer when abandoned.
set number
set relativenumber
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

" -----------------------------------------------------------------------------
"   -- Navigation --
" -----------------------------------------------------------------------------

" Simple escape from terminal mode.
tnoremap <Esc> <C-\><C-n>

" Select buffer.
nnoremap <tab> :bn<CR>
nnoremap <s-tab> :bp<CR>

" Split navigation.
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

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
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap("n", "<leader>F", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "zls" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end
EOF

" -- Zig

lua <<EOF
require'lspconfig'.zls.setup{}
EOF

" -- Pyright (python)

lua <<EOF
require'lspconfig'.pyright.setup{}
EOF

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

lua <<EOF
    require("telescope").load_extension("flutter")
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

