" QuickFixCurrentNumber.vim: Locate the quickfix item at the cursor position.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_QuickFixCurrentNumber') || (v:version < 700)
    finish
endif
let g:loaded_QuickFixCurrentNumber = 1

"- commands --------------------------------------------------------------------

command! -bar Cnr if ! QuickFixCurrentNumber#Print(0) | echoerr ingo#err#Get() | endif
command! -bar Lnr if ! QuickFixCurrentNumber#Print(1) | echoerr ingo#err#Get() | endif

command! -bar -bang -count=1 Cgo if ! QuickFixCurrentNumber#Go(<count>, 1, <bang>0, 0) | echoerr ingo#err#Get() | endif
command! -bar -bang -count=1 Lgo if ! QuickFixCurrentNumber#Go(<count>, 1, <bang>0, 1) | echoerr ingo#err#Get() | endif


"- mappings --------------------------------------------------------------------

nnoremap <silent> <Plug>(QuickFixCurrentNumberGo) :<C-u>if QuickFixCurrentNumber#Go(v:count1, 0, 1)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>

nnoremap <silent> <Plug>(QuickFixCurrentNumberQNext)  :<C-u>if QuickFixCurrentNumber#Next(v:count1, 0, 0)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberQPrev)  :<C-u>if QuickFixCurrentNumber#Next(v:count1, 0, 1)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLNext)  :<C-u>if QuickFixCurrentNumber#Next(v:count1, 1, 0)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLPrev)  :<C-u>if QuickFixCurrentNumber#Next(v:count1, 1, 1)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>

nnoremap <silent> <Plug>(QuickFixCurrentNumberQFirst) :<C-u>if QuickFixCurrentNumber#Border(v:count1, 0, 0)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberQLast)  :<C-u>if QuickFixCurrentNumber#Border(v:count1, 0, 1)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLFirst) :<C-u>if QuickFixCurrentNumber#Border(v:count1, 1, 0)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>
nnoremap <silent> <Plug>(QuickFixCurrentNumberLLast)  :<C-u>if QuickFixCurrentNumber#Border(v:count1, 1, 1)<Bar>execute 'normal! zv'<Bar>else<Bar>execute "normal! \<lt>C-\>\<lt>C-n>\<lt>Esc>"<Bar>if ingo#err#IsSet()<Bar>echoerr ingo#err#Get()<Bar>endif<Bar>endif<CR>


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
