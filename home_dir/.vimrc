"set all -- zobrazi vsechny nastavene volby
"set volba? -- ukaze hodnotu prisluse volby
if &term=="rxvt" || &term=="screen.rxvt"
	" Initial state
	let MODE="Command"

	function InsertState()
	" prefix g: to acces global variable
	  if g:MODE == "Insert"
		 let g:MODE = "Replace"
		 startreplace
	  elseif g:MODE == "Replace"
		 let g:MODE = "Insert"
		 startinsert
	  endif
	endfunction

	" Entering Insert mode from Command
	map <c-t> :let MODE="Insert" \| :startinsert<CR>

	" Pressing Insert in insert-mode swithes between Insert/Replace
	" <C-o> + :command does not move cursor left, like pressing <Esc>.
	imap <c-t> <C-O>:call InsertState()<CR>
	map <ESC>[F    <End>
	map <ESC>[H    <Home>
	imap <ESC>[F    <End>
	imap <ESC>[H    <Home>
endif

"if $lang=="cs_CZ.iso-8859-2"
"    set encoding=iso-8859-2
"	colorscheme bruxy
"else
"    set encoding=utf-8
"	colorscheme bruxy " je v $HOME/.vim/colors
"endif

set encoding=utf-8
colorscheme bruxy

set nocompatible
set undolevels=1000
set tabstop=4     " Pocet zobrazenych mezer pri stisku <TAB>
set expandtab
set softtabstop=4
set shiftwidth=4  " Odsazovani v zdrojacich 4 mezery
set backspace=indent,eol,start
set nojoinspaces
set autowrite     " automaticke ukladani
set showcmd
set showmatch
set showmode
set hlsearch
set confirm " Dotaz na ulozeni souboru
set incsearch
set smartcase     " Pokud se hledany vyraz napise malymi pismeny je
                  " hledan string bez ohledu na velka ci mala pismena
set background=dark
set viminfo='20,\"100    " read/write a .viminfo file, don't store more
                         " than 50 lines of registers
set history=100
 "Obarvuje syntaxe
syntax on
set display=lastline
set scrolloff=5
set modeline

set nobackup
"set paste " Pokud je treba vkladat z clipboardu je treba zapnout aby ViM
           " neprovedl automaticke formatovani (vypnout :set nopaste)
set ruler
"set showbreak=+ " U dlouhych radku nastavi na zacatku zlomu + aby bylo videt
"set linebreak   " Rozdeli radek v mezere a ne uprostred slova/
set wildignore=*~,*.o,*.aux,*.dvi " Tyhle soubory se pri automatickem
                                        " doplnovani budou ignorovat
set wildchar=<Tab>
set wildmenu
set wildmode=longest:full,full

"set langmap=?2,?3,?4,?5,?6,?7,?8,?9,?0,\":,-/,_?

" Nastaveni pro GViM
set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-120-*-*-m-*-iso10646-1

"set fileencodings=iso-8859-2,utf-8 " Kodovani souboru
set fileencodings=utf-8
"set fileencoding=iso-8859-2 " Kodovani souboru

"Status line:
"set statusline=Soubor:\ \"%f\ -\ %Y\"\ Status:\[%m%M%r%R\]\ X:\ %c\ Y:\[\ %l\ /\ %L\ \]\ Byte:\(\%o\ /\ \)\ \ Char:\ %b\ 0x%B
set laststatus=2 " 2 = Ukazuje status line vzdy (0 nikdy, 1 pri min. dvou oknech)
set titlestring=ViM\ -\ %t%m%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
set title
set statusline=%<\"%f\"\ %Y%m%r\ X:\ %2c\ Y:\[\ %l\ /\ %L\ \]\ %p%%%=\ Byte:\ %o\ Char:\ %3(%b%)\ %4(0x%B%)\ \ 

" zobrazeni pretecenych mezer a pisme
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/
" without this extra spaces are added when copying from vim:
highlight Normal ctermbg=NONE
"highlight ExtraLongLine   ctermbg=gray guibg=gray
"match ExtraLongLine /\(^.\{80\}.*\)\@<=./

" Show tabs
set list
set showbreak=↪\
set listchars=trail:█,tab:>·,precedes:←,extends:→,nbsp:␣


" Kontrola pravopisu pro ViM 7
" http://ftp.linux.cz/pub/localization/OpenOffice.org/devel/Czech/spell_checking/cs_CZ.zip
" unzip -x cs_CZ.zip cs_CZ.aff cs_CZ.dic
" vim -e -s << EOF
" :mkspell cs cs_cz
" :!cp cs.utf-8.spl $VIMRUNTIME/spell
" EOF
set spelllang=cs
"autocmd FileType asm, nasm : set nospell

" Formatovaci vyfikundace
" -----------------------
"setlocal fo+=r    " chci, aby se pridaval komentar, kdyz zmacknu enter
setlocal fo+=t    " zalamovani kodu a komentaru podle textwidth
setlocal fo+=q    " inteligentni formatovani komentaru
setlocal fo+=c    " kdyz zalomis komentar, pridej jeho uvozeni

"autocmd BufRead,BufNewFile * : colorscheme bruxy

" Vyjimky pro ruzne typy souboru
" ------------------------------

" maily
autocmd FileType mail : set textwidth=64
autocmd FileType mail : set wrap
autocmd FileType mail : set spell spelllang=en,cs

" obycejny text
autocmd BufRead,BufNewFile *.txt : set filetype=TXT
autocmd FileType TXT : set spelllang=cs,en
autocmd FileType TXT : set textwidth=70 smartindent wrap spell

" Markdown
autocmd BufRead,BufFilePre,BufNewFile *.md : set filetype=markdown.pandoc
autocmd FileType markdown : set spell spelllang=cs,en
autocmd FileType markdown : set syntax=markdown.pandoc
autocmd FileType markdown : set textwidth=70 smartindent wrap

" ConTeXt
autocmd BufRead,BufNewFile *.ctex : set filetype=ctex
autocmd FileType ctex : set makeprg=context\ %
"autocmd FileType ctex : set makeprg=texexec\ %
autocmd FileType ctex : set syntax=context
autocmd FileType ctex : syn spell toplevel
autocmd FileType ctex : set spell spelllang=cs,en
autocmd FileType ctex : map <F9> :!(evince `basename % .ctex`.pdf &)
autocmd FileType ctex : set wildignore=*.aux,*.bbl,*.blg,*.log,*.pdf,*.tuc,*.top

" Assembler
" NASM/YASM
autocmd BufRead,BufNewFile *.asm : set filetype=nasm
autocmd FileType nasm : set cindent autoindent number
" GAS
autocmd BufRead,BufNewFile *.s : set filetype=asm
autocmd FileType asm : set cindent autoindent number
autocmd FileType asm : syn match asmComment "#.*"

" METAPOST
let helpmp="!(xpdf /usr/local/TeX/texmf-dist/doc/metapost/base/mpman.pdf &)"
" autocmd FileType mp : set makeprg=(mptopdf\ --makefun\ %\)
autocmd FileType mp : map <F10> :!(mptopdf --metafun %)<CR>
autocmd FileType mp : set number
autocmd FileType mp : map <F9> :!(evince `basename % .mp`-1.pdf &)
"autocmd FileType mp : map <F1>  :execute helpmp

" gnuplot
autocmd BufRead,BufNewFile *.plot : set filetype=gnuplot 
" autocmd FileType gnuplot : set fileencodings=iso-8859-2 encoding=iso-8859-2
autocmd FileType gnuplot : set makeprg=gnuplot\ -persist\ %\ 

" C-like programovaci jazyky
autocmd FileType c,cpp,php,php3,php4 : set cindent autoindent number
autocmd FileType c : map <F10> :!(make `basename % .c`)<cr>
autocmd FileType c : map <F9> :!(f=`basename % .c`; eval ./$f)<CR>
"autocmd FileType cpp : map <F10> :!(make `basename % .cpp`)<cr>
autocmd FileType cpp : map <F10> :!(g++ -ggdb3 -o `basename % .cpp` %)<cr>
autocmd FileType cpp : map <F9> :!(f=`basename % .cpp`; eval ./$f)<CR>

autocmd FileType perl : map <F10> :!(./% \| less)<CR>

" DOT, jazyk pro popis grafu GraphViz
autocmd FileType dot : map <F10> :!(dot -Tsvg -O %)<CR>

" Makefile
autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

" Python
autocmd FileType python : filetype plugin indent on
" Enable vim-indent-guides plugin
" https://github.com/nathanaelkane/vim-indent-guides/blob/master/README.markdown
autocmd FileType python : let g:indent_guides_guide_size = 1|IndentGuidesToggle
autocmd FileType python : set autoindent smarttab expandtab smartindent
"autocmd FileType python : match ExtraLongLine /\(^.\{72\}.*\)\@<=./

" Ruby
:autocmd Filetype ruby set softtabstop=2
:autocmd Filetype ruby set sw=2
:autocmd Filetype ruby set ts=2

" Prikaz Go provede ulozeni souboru a nasledne zpracovani make
"                           set shellpipe=2>&1 >' \
"fileencoding=iso-8859-2,
" LaTeX
autocmd FileType tex : set textwidth=70 smartindent wrap spell
autocmd FileType tex : set syntax=tex
autocmd FileType tex : map <F9> :!(evince `basename % .tex`.pdf &)<CR>
" autocmd FileType tex : set makeprg=pdfcslatex\ -interaction=nonstopmode\ %\ 

"set shellpipe=2>&1\ >

"autocmd FileType html,htm : set fileencoding=iso-8859-2,textwidth=80,smartindent
autocmd BufRead,BufNewFile *.html : set filetype=HTML
autocmd FileType HTML : set textwidth=80 smartindent
autocmd FileType HTML : set spell spelllang=cs,en syntax=html

autocmd FileType log : set autoread " Pokud je soubor upraven mimo ViM je
                                    " znovu automaticky nacten bez drzkovani

"autocmd BufRead,BufNewFile *.yml : set filetype=YAML
autocmd FileType yaml : set cursorcolumn syntax=yaml ts=2

autocmd FileType SH : map <F10>  :!./%<cr>
autocmd FileType SH : imap <F10> :!./%<cr>
autocmd FileType SH : !echo "AAAAA"; sleep 1

" barevne logy ke commitum
au! BufReadPost {COMMIT_EDITMSG,*/COMMIT_EDITMSG} set ft=gitcommit noml | norm 1G

" sablony k souborum
au BufNewFile *.c    0r $HOME/.vim/mustr.c
au BufNewFile *.sh    0r $HOME/.vim/mustr.sh
au BufNewFile *.cpp  0r $HOME/.vim/mustr.cpp
au BufNewFile *.tex  0r $HOME/.vim/mustr.tex
au BufNewFile *.html 0r $HOME/.vim/mustr.html
au BufNewFile *.php3 0r $HOME/.vim/mustr.php
au BufNewFile *.ctex 0r $HOME/.vim/mustr.ctex
au BufNewFile *.mp   0r $HOME/.vim/mustr.mp
au BufNewFile *.plot 0r $HOME/.vim/mustr.plot
au BufNewFile *.asm  0r $HOME/.vim/mustr.asm
au BufNewFile *.s,*.S 0r $HOME/.vim/mustr.s
au BufNewFile Makefile 0r $HOME/.vim/mustr.make
au BufNewFile *.py 0r $HOME/.vim/mustr.py
au BufNewFile *.rb 0r $HOME/.vim/mustr.rb

autocmd FileType xml,gan : set fileencodings=utf-8,textwidth=80,smartindent

autocmd BufNewFile,BufRead *.job.jinja set syntax=hcl

" vim -b : edit binary using xxd-format!
" augroup Binary
"  au!
"  au BufReadPre  *.exe let &bin=1
"  au BufReadPost *.exe if &bin | %!xxd
"  au BufReadPost *.exe set ft=xxd | endif
"  au BufWritePre *.exe if &bin | %!xxd -r
"  au BufWritePre *.exe endif
"  au BufWritePost *.exe if &bin | %!xxd
"  au BufWritePost *.exe set nomod | endif
"augroup END


" Prikazy
" -------------------------------

" Uloz a zpracuj pomoci makeprg
command Go write | make 
map <F10> :Go<CR>
imap <F10> <Esc>:Go<CR>

" Zruseni zvyrazneni po hledani a restart barveni syntaxe
map <F12> :nohlsearch<CR><Esc>:syntax sync fromstart<CR>

" zvetseni okna
map <C-Up> <C-W>1+
map <C-Down> <C-W>1-

" Pohyb mezi taby
map <A-Left> :tabprevious<CR>
map <A-Right> :tabnext<CR>
map <A-Insert> :tabe<CR>

" Zmena kodovani souboru na UTF-8
map <C-f> :set fileencodings=iso-8859-2<CR>:e! %<CR>
"map ns : set nospell<CR>

" <C-R><C-W>
"
"
"let g:langpair="en|cz"

" Function muster
imap Ifunc <Esc>:r ~/.vim/func_muster.txt<CR>/:<CR>a<Space>

" Jump to the last position when " reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

if &diff
    colorscheme bruxy
endif
