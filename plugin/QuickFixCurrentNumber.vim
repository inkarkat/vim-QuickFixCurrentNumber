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
"	001	08-Feb-2013	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_QuickFixCurrentNumber') || (v:version < 700)
    finish
endif
let g:loaded_QuickFixCurrentNumber = 1

":Cnr, :Lnr		Print the number of the entry in the quickfix / location
"			list for the current cursor position (or the next entry
"			after the cursor).
function! s:QflistSort( i1, i2 )
    if a:i1.lnum == a:i2.lnum
	" Same line, compare columns.
	if a:i1.col == 0 || a:i2.col == 0
	    " One doesn't have a column, keep existing order.
	    return 0
	elseif a:i1.vcol == a:i2.vcol
	    " Same column type, compare.
	    return a:i1.col == a:i2.col ? 0 : a:i1.col > a:i2.col ? 1 : -1
	else
	    " Different column type, translate the virtual column into the
	    " byte count.
	    let l:translatable = (a:i1.vcol ? a:i1 : a:i2)
	    let l:neededTabstop = getbufvar(l:translatable.bufnr, '&tabstop')
	    if l:neededTabstop != &tabstop
		let l:save_tabstop = &l:tabstop
		let &l:tabstop = l:neededTabstop
	    endif
		let l:translatedCol = len(matchstr(getbufline(l:translatable.bufnr, l:translatable.lnum)[0], '^.*\%<'.(l:translatable.col + 1).'v'))
	    if exists('l:save_tabstop')
		let &l:tabtop = l:save_tabstop
	    endif
	    if a:i1.vcol
		return l:translatedCol == a:i2.col ? 0 : l:translatedCol > a:i2.col ? 1 : -1
	    else
		return a:i1.col == l:translatedCol ? 0 : a:i1.col > l:translatedCol ? 1 : -1
	    endif
	endif
    else
	return a:i1.lnum > a:i2.lnum ? 1 : -1
    endif
endfunction
function! QuickFixCurrentNumber#GetNumber( qflist )
    " Though the list is usually sorted, it is not necessarily (e.g. one can use
    " :caddexpr to add entries out-of-band).
    let l:idx = 0
    while l:idx < len(a:qflist)
	let a:qflist[l:idx].number = l:idx + 1
	let l:idx += 1
    endwhile

    let l:bufferQflist = filter(copy(a:qflist), 'v:val.bufnr ==' . bufnr(''))
"****D echomsg string(map(sort(l:bufferQflist, 's:QflistSort'), 'v:val.text'))
    for l:entry in sort(l:bufferQflist, 's:QflistSort')
	if l:entry.lnum < line('.')
	    continue    " Before current line (or line not specified).
	elseif l:entry.lnum == line('.') && l:entry.col == 0
	    return l:entry.number   " The column is not specified. Match entire line; the actual error could be anywhere.
	elseif l:entry.lnum == line('.') && l:entry.col < (l:entry.vcol ? vcol('.') : col('.'))
	    continue    " Before cursor on the current line.
	endif

	return l:entry.number
    endfor

    return (len(l:bufferQflist) == 0 ? -1 : 0)
endfunction
function! QuickFixCurrentNumber#Print( qflist )
    let l:nr = QuickFixCurrentNumber#GetNumber(a:qflist)
    if l:nr == -1
	call ingo#msg#ErrorMsg('No Errors')
	return
    elseif l:nr == 0
	call ingo#msg#ErrorMsg('No more items')
	return
    endif

    echomsg printf('(%d of %d): %s', l:nr, len(a:qflist), get(a:qflist[l:nr - 1], 'text', ''))
endfunction
command! -bar Cnr call QuickFixCurrentNumber#Print(getqflist())
command! -bar Lnr call QuickFixCurrentNumber#Print(getloclist(0))

"g<C-Q>			Go to the entry in the location / quickfix list for the
"			current cursor position (or the next entry after the
"			cursor).
function! QuickFixCurrentNumber#Go()
    if &l:buftype ==# 'quickfix'
	call ingo#msg#ErrorMsg('Already in quickfix')
	return
    endif

    let l:isLocationList = ! empty(getloclist(0))
    let l:cmdPrefix = (l:isLocationList ? 'l' : 'c')
    let l:nr = QuickFixCurrentNumber#GetNumber(l:isLocationList ? getloclist(0) : getqflist())
    if l:nr == -1
	call ingo#msg#ErrorMsg('No Errors')
	return
    elseif l:nr == 0
	call ingo#msg#ErrorMsg('No more items')
	return
    endif

    let l:save_view = winsaveview()
    execute l:cmdPrefix . 'open'

    execute l:nr . l:cmdPrefix . 'first'
    " Above command jumps back to the buffer, and the selected error location. Restore the original position.
    call winrestview(l:save_view)

    execute l:cmdPrefix . 'open'
endfunction
nnoremap <silent> <Plug>(QuickFixCurrentNumberGo) :<C-u>call QuickFixCurrentNumber#Go()<CR>
if ! hasmapto('<Plug>(QuickFixCurrentNumberGo)', 'n')
    nmap g<C-q> <Plug>(QuickFixCurrentNumberGo)
endif


" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
