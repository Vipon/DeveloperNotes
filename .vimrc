" Select color for syntax style
colorscheme peachpuff

" Enable syntax highlighting
syntax on

" 'hidden' option allows to hide old files insted of close them, when you open
" new file in the same window. It permits to return to the old file after it
" and undo some changes.
set hidden

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" enable filetype detection:
filetype on
filetype plugin on
filetype indent on " file type based indentation

" Indentation settings for using 4 spaces instead of tabs.
autocmd FileType c,cpp,java,txt set shiftwidth=4 softtabstop=4 expandtab

" Show tabs and spaces.
set listchars=tab:>-,nbsp:·,space:·
set list

" Aout removing useless whitespaces at the end of lines.
autocmd BufWritePre * %s/\s\+$//e
