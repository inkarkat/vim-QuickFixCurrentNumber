" QuickFixCurrentNumber.vim: Locate the quickfix entry at the cursor position.
"
" DEPENDENCIES:
"
" Copyright: (C) 2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	09-Feb-2013	Split off autoload script and documentation.
"	001	08-Feb-2013	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_QuickFixCurrentNumber') || (v:version < 700)
    finish
endif
let g:loaded_QuickFixCurrentNumber = 1

"- commands --------------------------------------------------------------------

command! -bar Cnr call QuickFixCurrentNumber#Print(0)
command! -bar Lnr call QuickFixCurrentNumber#Print(1)


"- mappings --------------------------------------------------------------------

nnoremap <silent> <Plug>(QuickFixCurrentNumberGo) :<C-u>call QuickFixCurrentNumber#Go()<CR>
if ! hasmapto('<Plug>(QuickFixCurrentNumberGo)', 'n')
    nmap g<C-q> <Plug>(QuickFixCurrentNumberGo)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
