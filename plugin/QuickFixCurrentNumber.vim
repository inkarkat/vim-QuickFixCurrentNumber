" QuickFixCurrentNumber.vim: Locate the quickfix item at the cursor position.
"
" DEPENDENCIES:
"   - QuickFixCurrentNumber.vim autoload script
"
" Copyright: (C) 2013-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.11.006	11-Mar-2015	:Cgo and :Lgo take [!] to behave like g<C-Q>,
"				i.e. jump back to the last error instead of
"				aborting. This is helpful because g<C-Q> only
"				crudely distinguishes between location and
"				quickfix list, and both may be in use. Thanks to
"				Enno Nagel for the suggestion.
"				Allow to disable all default mappings via
"				g:no_QuickFixCurrentNumber_maps.
"   1.10.005	08-Mar-2015	QuickFixCurrentNumber#Go() takes another
"				a:isFallbackToLast argument to support g<C-Q>
"				jumping back to the last error.
"   1.00.004	19-Feb-2013	Don't print errors for g<C-q> mapping.
"   1.00.003	11-Feb-2013	Implement moving to next / previous error in
"				current buffer with ]q etc.
"				Add :Cgo / :Lgo command alternative to g<C-Q>
"				mapping.
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

command! -bar -bang Cgo call QuickFixCurrentNumber#Go(1, <bang>0, 0)
command! -bar -bang Lgo call QuickFixCurrentNumber#Go(1, <bang>0, 1)


"- mappings --------------------------------------------------------------------

nnoremap <silent> <Plug>(QuickFixCurrentNumberGo) :<C-u>if ! QuickFixCurrentNumber#Go(0, 1)<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>endif<CR>

nnoremap <silent> <Plug>(QuickFixCurrentNumberQNext)  :<C-u>call QuickFixCurrentNumber#Next(v:count1, 0, 0)<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberQPrev)  :<C-u>call QuickFixCurrentNumber#Next(v:count1, 0, 1)<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLNext)  :<C-u>call QuickFixCurrentNumber#Next(v:count1, 1, 0)<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLPrev)  :<C-u>call QuickFixCurrentNumber#Next(v:count1, 1, 1)<CR>

nnoremap <silent> <Plug>(QuickFixCurrentNumberQFirst) :<C-u>call QuickFixCurrentNumber#Border(v:count1, 0, 0)<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberQLast)  :<C-u>call QuickFixCurrentNumber#Border(v:count1, 0, 1)<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLFirst) :<C-u>call QuickFixCurrentNumber#Border(v:count1, 1, 0)<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLLast)  :<C-u>call QuickFixCurrentNumber#Border(v:count1, 1, 1)<CR>


if ! exists('g:no_QuickFixCurrentNumber_maps')
if ! hasmapto('<Plug>(QuickFixCurrentNumberGo)', 'n')
    nmap g<C-q> <Plug>(QuickFixCurrentNumberGo)
endif

if ! hasmapto('<Plug>(QuickFixCurrentNumberQNext)', 'n')
    nmap ]q <Plug>(QuickFixCurrentNumberQNext)
endif
if ! hasmapto('<Plug>(QuickFixCurrentNumberQPrev)', 'n')
    nmap [q <Plug>(QuickFixCurrentNumberQPrev)
endif
if ! hasmapto('<Plug>(QuickFixCurrentNumberLNext)', 'n')
    nmap ]l <Plug>(QuickFixCurrentNumberLNext)
endif
if ! hasmapto('<Plug>(QuickFixCurrentNumberLPrev)', 'n')
    nmap [l <Plug>(QuickFixCurrentNumberLPrev)
endif

if ! hasmapto('<Plug>(QuickFixCurrentNumberQFirst)', 'n')
    nmap g[q <Plug>(QuickFixCurrentNumberQFirst)
endif
if ! hasmapto('<Plug>(QuickFixCurrentNumberQLast)', 'n')
    nmap g]q <Plug>(QuickFixCurrentNumberQLast)
endif
if ! hasmapto('<Plug>(QuickFixCurrentNumberLFirst)', 'n')
    nmap g[l <Plug>(QuickFixCurrentNumberLFirst)
endif
if ! hasmapto('<Plug>(QuickFixCurrentNumberLLast)', 'n')
    nmap g]l <Plug>(QuickFixCurrentNumberLLast)
endif
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
