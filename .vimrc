" Dan's .vimrc
" this file lives in ~/dotfiles/.vimrc and is symlinked to ~/.vimrc
" github https://github.com/dakoblas/dotfiles (private repo)

" NOTES TO SELF/TO DO
" {{{
" change it so trailing whitespace is only stripped on certain filetypes liek
" python, c, jave, etc
"
" }}}

" SET OPTIONS
" {{{
set nocompatible    "vim only settings - for plugin compatibility etc
set number	    "line numbers
set ruler	    "show line/column number
set ignorecase	    "ignore case in search
set smartcase	    "except if not all lowercase in certain search cmds
set hlsearch	    "highlight search results
set scrolloff=5     "keep 5 lines above/below cursor
set history=300	    "command history
set noshowmode	    "disable builtin mode display (airline does this)
set noshowcmd	    "disable showcmd
set textwidth=80    "autowrap text 80 char
set softtabstop=2   "2 spaces for tabs
set shiftwidth=2    "indent size
set expandtab	    "tabs insert spaces not tabstops
set autoread        "reread the file if it has changed outside of vim
set foldnestmax=3   "only nest 3 levels of fold
set foldlevel=0     "close folds by default
set foldcolumn=2    "gutter column shows folding heirarchy
filetype on 	    "enable filetype detection. note: see :h ftplugin
" }}}

" AUTOCOMMANDS
" {{{
augroup vimrc
  autocmd!
  " sets fold method based on filetype when opening vim or new (known) file
  autocmd GUIEnter,BufRead,FileReadPost,BufNewFile * call SetFolding()

  " these fix a strange issue I was having with code folding when having multiple
  " buffers viewing the same file, then editing within a fold.
  " sets foldmethod to manual for all buffers when moving out of a window or into insert
  autocmd InsertEnter,WinLeave,BufLeave * set foldmethod=manual
  " sets folding back when leaving insert or entering window, based on filetype
  autocmd InsertLeave,WinEnter,BufEnter * call SetFolding()

  " removes trailing whitespace on write for most filetypes
  autocmd BufWritePre,FileWritePre * call RemoveWhiteSpace()

  " update Last Modified date/time in a file on write
  autocmd BufWritePre,FileWritePre * kc | call LastModified() |'c

  " set .pro files be prolog
  autocmd BufNewFile,BufRead *.pro set filetype=prolog

  " settings for makefiles
  autocmd FileType make call MakeSettings()
  " settings for markdown files
  autocmd FileType markdown call MarkdownSettings()
  " settings for python
  autocmd FileType python call PythonSettings()
augroup END
" }}}

" GLOBAL KEY MAPPINGS
" {{{
" General-Purpose Mappings
" {{{
" moves current line up one line
nnoremap <leader>- ddkP
" moves currnet line down one line
nnoremap <leader>_ ddp
" toggles relative line numbers
nnoremap <leader>rr :set relativenumber!<cr>
" toggles trailing whitespace highlighting
nnoremap <leader>ws :call ToggleWhiteSpace()<cr>
" wraps current word in double quotes
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
" wraps current word in single quotes
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
" toggle search highlighting
nnoremap <leader>hl :set hlsearch!<cr>
" }}}

" Window Layouts
" {{{
" use '\lo#' to load the desired layout
" Note to self: (:h mkview) has different functionality; I want behavior as if I
" make the splits in-session manually.  But automated.
  " layout 1
  " simple vsplit.  I can never seem to type vsplit correctly on the fly.
  nnoremap <leader>lo1 :only<cr>:vsplit<cr>:echo "Layout 1 Loaded"<cr>
  " layout 2
  " vsplit with LHS full size, RHS horizontal split, equal size
  nnoremap <leader>lo2 :only<cr>:vsplit<cr><c-w>l:split<cr><c-w>h:echo "Layout 2 Loaded"<cr>
  " layout 3
  " 2 smaller windows above one main one
  nnoremap <leader>lo3 :only<cr>:15split<cr><c-w>k:vsplit<cr><c-w>j:echo "Layout 3 Loaded"<cr>
  " layout 4
  " 2 smaller windows below one main one
  nnoremap <leader>lo4 :only<cr>:below 15split<cr><c-w>j:vsplit<cr><c-w>k:echo "Layout 4 Loaded"<cr>
  " layout 5
  " split with window of size 20 above main window
  nnoremap <leader>lo5 :only<cr>:20split<cr>:echo "Layout 5 Loaded"<cr>
  " layout 6
  " layout 7
  " layout 8
  " layout 9
  " layout 0
  " my brain tells me that if 1-9 do something, 0 should clear it
  nnoremap <leader>lo0 :only<cr>
" }}}

" Doxygen Abbreviations
" {{{
" these features insert doxygen comment blocks via insert-mode abbreviations.
" functionality relies on the nerdcommenter plugin to comment the block for now.
" as such, if you're not me and you have any of the keys used here mapped to
" something else, you're SOL.
" this is probably not the most elegant way of doing this, but...

" Doxygen File comment block for beginning of file
" {{{
" typing "doxyfilehead " in insert mode will create a doxygen comment block at the
" beginning of the file, regardless of existing text, and place the cursor in
" insert mode after the brief tag.  The "Date Created" just puts in the current
" date and time, so your file will be "officially" created when you insert this
" comment block.
iabbrev doxyfilehead @@dfile
imap @@dfile <esc>:1<cr>i<cr><esc>:call DoxygenFileBlock()<cr>i<cr><esc>:1<cr>7\cs:1<cr>A!<esc>:3<cr>A
function! DoxygenFileBlock()
  let dfile = expand("%")
  let ddatecreated = strftime("%a %d %b %Y %I:%M%p")
  call append(0, [" @file " . dfile, " @brief", " @details", " @author Daniel Koblas", " @date Date Created: " . ddatecreated, " @date Last Modified: " . ddatecreated])
endfunction
" }}}

" Doxygen Function comment block
" {{{
" typing "doxyfunc " in insert mode will create a doxygen comment block at the
" current line, and place the cursor in insert mode after the brief tag.
" recommended usage is to put the comment block on the line right above a
" prototype definition.
iabbrev doxyfunc @@dfunc
imap @@dfunc <esc>O<esc>jmc:call DoxygenFunctionBlock()<cr>5\cs`cddkkddA!<esc>jA
function! DoxygenFunctionBlock()
  call append(line("."), [" @brief", " @details", " @param", " @return"])
endfunction
" }}}

" Doxygen Generic comment block
" {{{
" typing "doxyblock " in insert mode will create a doxygen comment block at the
" current line, and place the cursor in insert mode after the brief tag.
iabbrev doxyblock @@dblock
imap @@dblock <esc>O<esc>jmc:call DoxygenClassBlock()<cr>i<cr><esc><cr>3\cs`cddkA!<esc>jA
function! DoxygenBlock()
  call append(line("."), [" @brief", " @details"])
endfunction
" }}}

" }}}

" UA CSC 120 file header and pydoc abbreviations
" {{{
" the purpose here is to conform with the style guile posted at (http://www2.cs.arizona.edu/classes/cs120/summer17/style/pgm-style.html)

" UA CSC120 File comment block for beginning of file
" {{{
" typing "120filehead " in insert mode will create a pydoc style comment block at the
" beginning of the file, regardless of existing text, and place the cursor in
" insert mode after the Purpose tag.  The "Date Created" just puts in the current
" date and time, so your file will be "officially" created when you insert this
" comment block.
iabbrev 120filehead @@120file
imap @@120file <esc>:1<cr>i<cr><esc>:call CSC120FileBlock()<cr>i<cr><esc>:7<cr>A
function! CSC120FileBlock()
  let dfile = expand("%")
  let ddatecreated = strftime("%a %d %b %Y %I:%M%p")
  call append(0, ["\"\"\"","File: " . dfile, "Author: Daniel Koblas", "Course: CSC 120 002 Summer 2017", "Date Created: " . ddatecreated, "Last Modified: " . ddatecreated, "Purpose: ", "\"\"\""])
endfunction
" }}}

" UA CSC120 Function comment block
" {{{
" typing "120func " in insert mode will create a pydoc style comment block at the
" current line, and place the cursor in insert mode after the first """.
" recommended usage is to put the comment block on the line right below a
" function definition.
iabbrev 120func @@120func
imap @@120func <esc>mc:call CSC120FunctionBlock()<cr>`cdd6>>6>>A
function! CSC120FunctionBlock()
  call append(line("."), ["\"\"\"", "Parameters:", "Returns:", "Precondition:", "Postcondition:", "\"\"\""])
endfunction
" }}}

" }}}

" }}}


" FUNCTIONS
"""""""""""""
" GENERIC FUNCTIONS
" {{{
" SetFolding()
" {{{
" func used in autocmds to set folding for different file types
function! SetFolding()
  if &filetype ==# "vim"
    setlocal foldmethod=marker
  elseif &filetype ==# "python"
    setlocal foldmethod=indent
  elseif &filetype ==# "make"
    setlocal foldmethod=manual
  else
    setlocal foldmethod=syntax
  endif
endfunction
" }}}

" ToggleWhiteSpace()
" {{{
" this function is used by a keymap to toggle trailing whitespace highlighting
let g:whitespace_is_highlighted = 0
function! ToggleWhiteSpace()
  if g:whitespace_is_highlighted
    let g:whitespace_is_highlighted = 0
    match none
  else
    match ErrorMsg '\s\+$'
    let g:whitespace_is_highlighted = 1
  endif
endfunction
" }}}

" RemoveWhiteSpace()
" {{{
" this function is used by an autocmd to remove whitespace on write for certain
" filetypes, and retain it for others
function! RemoveWhiteSpace()
  if &filetype ==# "markdown"
  else
    :silent! %s/[\r \t]\+$//
  endif
endfunction
" }}}

" LastModified()
" {{{
" this function updates the last modified date and time in the file's comment
" block.  this is taken directly from vim's help (:h autocmd-use), look there
" for details on how and what it does.
function! LastModified()
  if line("$") > 20
    let l = 20
  else
    let l = line("$")
  endif
  execute "1," . l . "g/Last Modified: /s/Last Modified: .*/Last Modified: " . strftime("%a %d %b %Y %I:%M%p")
endfunction
" }}}

" }}}

" FILETYPE-SPECIFIC FUNCTIONS
" {{{

" MakeSettings()
" {{{
" this function sets make-specific settings
function! MakeSettings()
  if &filetype ==# "make"
    setlocal noexpandtab    "we actually want the tabstop in makefiles
    setlocal shiftwidth=0   "indent to tabstop value
    setlocal softtabstop=0  "dont insert spaces
  endif
endfunction
" }}}

" MarkdownSettings()
" {{{
" settings for markdown files
function! MarkdownSettings()
  if &filetype ==# "markdown"
    " turn on spellcheck
    setlocal spell spelllang=en_us
    " turn off text autowrap
    setlocal textwidth=0
    " Markdown-Specific Key Mappings, local to the buffer
    " {{{
    " add a header to existing line, if none present
    nnoremap <buffer> <leader>hh 0i#<space><esc>
    " delete existing header
    nnoremap <buffer> <leader>h0 0dw
    " change existing header level
    " note: you can use this directly if it's a fresh line.
    nnoremap <buffer> <leader>h1 0cw#<esc>
    nnoremap <buffer> <leader>h2 0cw##<esc>
    nnoremap <buffer> <leader>h3 0cw###<esc>
    nnoremap <buffer> <leader>h4 0cw####<esc>
    nnoremap <buffer> <leader>h5 0cw#####<esc>
    nnoremap <buffer> <leader>h6 0cw######<esc>

    " note to self: by personal convention I use '_' for italic and '**' for bold
    " bold current word
    nnoremap <buffer> <leader>bw viw<esc>a**<esc>bbi**<esc>ee
    " bold sentence
    nnoremap <buffer> <leader>bs (i**<esc>)ba**<esc>
    " bold line
    nnoremap <buffer> <leader>bl 0i**<esc>A**<esc>
    " bold paragraph
    nnoremap <buffer> <leader>bp {wi**<esc>}ba**<esc>
    " bold visual selection
    vnoremap <buffer> <leader>bv <esc>`>a**<esc>`<i**<esc>

    " italic current word
    nnoremap <buffer> <leader>iw viw<esc>a_<esc>bbi_<esc>ee
    " italic sentence
    nnoremap <buffer> <leader>is (i_<esc>)ba_<esc>
    " italic line
    nnoremap <buffer> <leader>il 0i_<esc>A_<esc>
    " italic paragraph
    nnoremap <buffer> <leader>ip {wi_<esc>}ba_<esc>
    " italic visual selection
    vnoremap <buffer> <leader>iv <esc>`>a_<esc>`<i_<esc>

    " bold and italic current word
    nnoremap <buffer> <leader>bw viw<esc>a_**<esc>bbi**_<esc>ee
    " bold and italic sentence
    nnoremap <buffer> <leader>bs (i**_<esc>)ba_**<esc>
    " bold and italic line
    nnoremap <buffer> <leader>bl 0i**_<esc>A_**<esc>
    " bold and italic paragraph
    nnoremap <buffer> <leader>bp {wi**_<esc>}ba_**<esc>
    " bold and italic visual selection
    vnoremap <buffer> <leader>bv <esc>`>a_**<esc>`<i**_<esc>
    " }}}
  endif
endfunction
" }}}

" PythonSettings()
" {{{
" this function sets up environment for python files
function! PythonSettings()
  if &filetype ==# "python"
    setlocal textwidth=79   "autowrap 79 chars
    setlocal softtabstop=4  "4 spaces for tabs
    setlocal shiftwidth=4   "indent 4 spaces
  endif
endfunction
" }}}


" }}}


" MODS/PLUGINS
""""""""""""""""
" VUNDLE CONFIG
" {{{
" self: I left a bunch of these comments from the doc config for reference.

set shell=bash	"self: Vundle doesnt like fish, so use bash explicitly

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"code completeion for vim, see (http://valloric.github.io/YouCompleteMe/#user-guide)
"
" not to self: YCM instructions were specifically to use Vundle, so I did.  They
" insisted that they be followed exactly for things to work correctly.  This
" might look insane and it probably isn't too complicated to just use Plug with
" a little configuration to do this, but I was too lazy to figure that out, and
" this doesn't seem to cause any problems.
"
Plugin 'Valloric/YouCompleteMe'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" }}}

" VIM-PLUG CONFIG (https://github.com/junegunn/vim-plug)
" {{{
" uses same kinds of commands as vundle but it's PlugInstall instead of
" PluginInstall, etc.
" why the hell do I have 2 plugin managers?  because these were already all set
" up using plug, and I only wanted to use vundle for YCM because it seemed
" really picky about that.  It hasn't caused any conflicts, so i've just been
" too lazy to do whatever is neccessary to consolidate them all into 1 manager.
call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/promptline.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'benmills/vimux'
Plug 'godlygeek/tabular'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'
Plug 'chrisbra/csv.vim'

call plug#end()
" }}}

" GRUVBOX CONFIG (https://github.com/morhetz/gruvbox)
" {{{
colorscheme gruvbox
set background=dark
let g:gruvbox_contrast_dark="soft"
let g:gruvbox_italic=1
" }}}

" AIRLINE CONFIG
" {{{
set ttimeoutlen=10
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline_theme='gruvbox'
" Enable the list of buffers at the top of the screen
let g:airline#extensions#tabline#enabled = 1

" show file path relative to homedir in the tabline(:h filename-modifiers )
"let g:airline#extensions#tabline#fnamemod = ':p:~'
" collapse said ~/path/to/file to ~/p/t/file
"let g:airline#extensions#tabline#fnamecollapse = 1
" show only the filename in the tabline(:h filename-modifiers )
let g:airline#extensions#tabline#fnamemod = ':t'

" show full file path in the statusline. changed: %f (default) to %F - see :h
" statusline for more option info
let g:airline_section_c = '%<%F%m %#__accent_red#%{airline#util#wrap(airline#parts#readonly(),0)}%#__restore__#'
" airline YCM integration
let g:airline#extensions#ycm#enabled = 1
let g:airline#extensions#ycm#error_symbol = 'E:'
let g:airline#extensions#ycm#warning_symbol = 'E:'
" }}}

" PROMPTLINE CONFIG
" {{{
" note to self: to update settings, run:
" :PromptLine
" :PromptlineSnapshot! ~/dotfiles/.promptline.sh
let g:promptline_preset = {
        \'a': [ promptline#slices#host({ 'only_if_ssh': 1  }), promptline#slices#user()  ],
        \'b': [ promptline#slices#cwd({ 'dir_limit': 4  })  ],
        \'c': [ promptline#slices#git_status()  ],
        \'x': [ promptline#slices#git_status()  ],
        \'z': [ promptline#slices#vcs_branch()  ],
        \'warn' : [ promptline#slices#last_exit_code(), promptline#slices#battery({ 'threshold': 20 })  ]}
let g:promptline_theme = 'airline_visual'
" }}}

" TMUXLINE CONFIG
" {{{
" note to self: to update settings, run:
" :TmuxLine
" :TmuxlineSnapshot! ~/dotfiles/.tmuxline.conf
let g:airline#extensions#tmuxline#enabled=0
let g:tmuxline_preset = {
        \ 'a': ['#F:#I','#W'],
        \ 'b': ['Session: #S'],
        \ 'c': ' ',
        \ 'win': ['#I', '#W'],
        \ 'cwin': ['#F:#I', '#W'],
        \ 'z': ['%a', '%Y-%m-%d', '%l:%M%p']}
let g:tmuxline_theme = 'airline_visual'
" }}}

" YOUCOMPLETEME CONFIG
" {{{
let g:ycm_global_ycm_extra_conf = "~/dotfiles/.ycm_extra_conf.py"
let g:ycm_always_populate_location_list = 0
let g:ycm_seed_identifiers_with_syntax = 0
" }}}

" MERLIN CONFIG
" {{{
let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
execute "set rtp+=" . g:opamshare . "/merlin/vim"
" }}}
