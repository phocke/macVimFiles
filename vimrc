"I want to try to work without matchit for now
"let loaded_matchit = 1
let g:loaded_unimpaired = 1
set imd 
set noimdisable 
set t_Co=256
"necessary on some Linux distros for pathogen to properly load bundles
filetype off

"load pathogen managed plugins
call pathogen#runtime_append_all_bundles()

"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set number      "add line numbers
set showbreak=...
set wrap linebreak nolist

"mapping for command key to map navigation thru display lines instead
"of just numbered lines
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

"add some line space for easy reading
set linespace=4

"disable visual bell
set visualbell t_vb=

"try to make possible to navigate within lines of wrapped lines
nmap <Down> gj
nmap <Up> gk
set fo=l

"statusline setup
set statusline=%f       "tail of the filename

"Git
set statusline+=[%{GitBranch()}]

"RVM
set statusline+=%{exists('g:loaded_rvm')?rvm#statusline():''}

set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"turn off needless toolbar on gvim/mvim
set guioptions-=T

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"indent settings
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing


set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"hide buffers when not displayed
set hidden

"Command-T configuration
let g:CommandTMaxHeight=10
let g:CommandTMatchWindowAtTop=1

if has("gui_running")
    "tell the term has 256 colors
    set t_Co=256

    "colorscheme cobalt
    set guitablabel=%M%t
    set lines=40
    set columns=125

    if has("gui_gnome")
        set term=gnome-256color
        colorscheme molokai
        set guifont=Monospace\ Bold\ 14
    endif

    if has("gui_mac") || has("gui_macvim")
        set guifont=Menlo:h15
        " key binding for Command-T to behave properly
        " uncomment to replace the Mac Command-T key to Command-T plugin
        "macmenu &File.New\ Tab key=<nop>
        "map <D-t> :CommandT<CR>
        " make Mac's Option key behave as the Meta key
        set invmmta
        try
          set transparency=15
        catch
        endtry
    endif

    if has("gui_win32") || has("gui_win32s")
        set guifont=Consolas:h12
        set enc=utf-8
    endif
else
    "dont load csapprox if there is no gui support - silences an annoying warning
    let g:CSApprox_loaded = 1

    "set railscasts colorscheme when running vim in gnome terminal
    if $COLORTERM == 'gnome-terminal'
        set term=gnome-256color
        colorscheme molokai
    else
      colorscheme molokai
    endif
endif

" PeepOpen uses <Leader>p as well so you will need to redefine it so something
" else in your ~/.vimrc file, such as:
" nmap <silent> <Leader>q <Plug>PeepOpen

silent! nmap <silent> <C-f> :NERDTreeToggle<CR>

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
map <m-l> <esc>:nohlsearch<CR>
inoremap <C-L> <C-O>:nohls<CR>

"map to bufexplorer
silent! nnoremap <leader>b :BufExplorerHorizontalSplit<cr>
silent! nnoremap <space>b :BufExplorerHorizontalSplit<cr>
silent! nnoremap <c-b> :BufExplorerHorizontalSplit<cr>

"map to CommandT TextMate style finder
silent! nnoremap <leader>t :CommandT<CR>
silent! nnoremap <space>t :CommandT<CR>
silent! nnoremap <c-t> :CommandT<CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"bindings for ragtag
inoremap <M-o>       <Esc>o
inoremap <C-j>       <Down>
let g:ragtag_global_maps = 1

"mark syntax errors with :signs
let g:syntastic_enable_signs=1

"snipmate setup
try
  source ~/.vim/snippets/support_functions.vim
catch
  source ~/vimfiles/snippets/support_functions.vim
endtry
autocmd vimenter * call s:SetupSnippets()
function! s:SetupSnippets()

    "if we're in a rails env then read in the rails snippets
    if filereadable("./config/environment.rb")
      try
        call ExtractSnips("~/.vim/snippets/ruby-rails", "ruby")
        call ExtractSnips("~/.vim/snippets/eruby-rails", "eruby")
      catch
        call ExtractSnips("~/vimfiles/snippets/ruby-rails", "ruby")
        call ExtractSnips("~/vimfiles/snippets/eruby-rails", "eruby")
      endtry
    endif

    try
      call ExtractSnips("~/.vim/snippets/html", "eruby")
      call ExtractSnips("~/.vim/snippets/html", "xhtml")
      call ExtractSnips("~/.vim/snippets/html", "php")
    catch
      call ExtractSnips("~/vimfiles/snippets/html", "eruby")
      call ExtractSnips("~/vimfiles/snippets/html", "xhtml")
      call ExtractSnips("~/vimfiles/snippets/html", "php")
    endtry
endfunction

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"key mapping for window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

"key mapping for saving file
nmap <C-s> :w<CR>

"key mapping for tab navigation
nmap <Tab> gt
nmap <S-Tab> gT

"Key mapping for textmate-like indentation
nmap <D-[> <<
nmap <D-]> >>
vmap <D-[> <gv
vmap <D-]> >gv

let ScreenShot = {'Icon':0, 'Credits':0, 'force_background':'#FFFFFF'}

"""""" from old vim 

"Wrapped lines up and down works
map <Down> gj
map <Up> gk
set fo=l
set list
set listchars=tab:\ \ ,extends:>,precedes:<

"Toggle nerdtree
silent! map <silent> <C-f> :NERDTreeToggle<CR>
silent! vmap <silent> <C-f> <esc>:NERDTreeToggle<CR>

"Navigating buffers
imap <silent> <c-left> <esc>:bprevious<c>
map <silent> <c-left> :bprevious<cr>
vmap <silent> <c-left> <esc>:bprevious<cr>

imap <silent> <c-right> <esc>:bnext<cr>
map <silent> <c-right> :bnext<cr>
vmap <silent> <c-right> <esc>:bnext<cr>

"Pastemode
nnoremap <f3> :set invpaste paste?<cr>
set pastetoggle=<f3>
set showmode

"Higlight search
nnoremap <F4> :set hlsearch! hlsearch?<CR> 

"Reload vimrc
map <F5> :source $MYVIMRC<CR>:echoe "Vimrc Reloaded!!!"<CR>

"Set to auto read when a file is changed from the outside
set autoread
set switchbuf=usetab
set autoindent
set smartindent
set ignorecase
set smartcase
set cursorline
set nocursorcolumn

"Search around
set wrapscan

"Toggle comments
map <silent>c<space> <esc>:call NERDComment(0, "toggle")<cr>
vmap <silent>c<space> <esc>:call NERDComment(1, "toggle")<cr>
imap <silent>c<space> <esc>:call NERDComment(0, "toggle")<cr>i

"Backspace inserts editing mode
nmap <silent> <backspace> i<backspace>
vmap <silent> <backspace> d

"Shift + arrows make a selection like in traditional editors
imap <s-right> <esc>v<right>
imap <s-left> <esc>v<left>
map <s-right> <esc>v<right>
map <s-left> <esc>v<left>
vmap <s-left> <left>
vmap <s-right> <right>

imap <s-up> <esc>V
imap <s-down> <esc>V
map <s-up> <esc>V
map <s-down> <esc>V
vmap <s-down> <down>
vmap <s-up> <up>

"Go to given tab
imap <D-1> <Esc>1gt
imap <D-2> <Esc>2gt
imap <D-3> <Esc>3gt
imap <D-4> <Esc>4gt
imap <D-5> <Esc>5gt
imap <D-6> <Esc>6gt
imap <D-7> <Esc>7gt
imap <D-8> <Esc>8gt
imap <D-9> <Esc>9gt

vmap <D-1> 1gt
vmap <D-2> 2gt
vmap <D-3> 3gt
vmap <D-4> 4gt
vmap <D-5> 5gt
vmap <D-6> 6gt
vmap <D-7> 7gt
vmap <D-8> 8gt
vmap <D-9> 9gt

map <D-1> <Esc>1gt
map <D-2> <Esc>2gt
map <D-3> <Esc>3gt
map <D-4> <Esc>4gt
map <D-5> <Esc>5gt
map <D-6> <Esc>6gt
map <D-7> <Esc>7gt
map <D-8> <Esc>8gt
map <D-9> <Esc>9gt

" Bubble single lines
nmap <C-Up> ddkP
nmap <C-Down> ddp

" Bubble multiple lines
vmap <C-Up> xkP`[V`]
vmap <C-Down> xp`[V`]

nmap // <Esc>:Ack!<space>

"highlight whitespace
set list

"set list listchars=tab:→\ ,trail:·,eol:¬
set list listchars=tab:→\ ,trail:·

" PARENTHESIS, SQUARE BRACKET, BRACE, QUOTE EXPANDING
" ;<open bracket or quote> or ;<close bracket> wraps the visual-mode higlighted 
" block in a bracket or quote pair.  Using an opening bracket or quote leaves the 
" cursor at the start of the block, where a closing bracket leaves it at the end 
" of the block. Works for: (, [, {, " and '.

vnoremap ( <esc>`>a)<esc>`<i(<esc>
vnoremap ) <esc>`<i(<esc>`>a)<esc>
vnoremap [ <esc>`>a]<esc>`<i[<esc>
vnoremap ] <esc>`<i[<esc>`>a]<esc>
vnoremap { <esc>`>a}<esc>`<i{<esc>
vnoremap } <esc>`<i{<esc>`>a}<esc>
vnoremap " <esc>`>a"<esc>`<i"<esc>
vnoremap ' <esc>`>a'<esc>`<i'<esc>

"for text formatting
map <a-f> gg=G

"shortcut for search and replace
vmap <D-r> <esc>:'<,'>s///g
nmap <D-r> <esc>:%s///gc
imap <D-r> <esc>:%s///gc

"for switching between tabs like in google chrome :)
map <D-A-Right> <esc>gt
map <D-A-Left> <esc>gT

"so it removes buffers when they're being hidden
set bufhidden=unload
set switchbuf=useopen
