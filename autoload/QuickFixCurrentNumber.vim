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
"	003	11-Feb-2013	Factor out common checks and errors to
"				s:CheckAndGetNumber().
"	002	09-Feb-2013	Split off autoload script and documentation.
"				Keep the existing (numbered) order when one item
"				doesn't have a line, or when there's equality in
"				columns.
"	001	08-Feb-2013	file creation

function! s:KeepOrder( i1, i2 )
    return a:i1.number > a:i2.number ? 1 : -1
endfunction
function! s:QflistSort( i1, i2 )
    if a:i1.lnum == 0 || a:i2.lnum == 0
	" One doesn't have a line, keep existing order.
	return s:KeepOrder(a:i1, a:i2)
    elseif a:i1.lnum == a:i2.lnum
	" Same line, compare columns.
	if a:i1.col == 0 || a:i2.col == 0
	    " One doesn't have a column, keep existing order.
	    return s:KeepOrder(a:i1, a:i2)
	elseif a:i1.vcol == a:i2.vcol
	    " Same column type, compare.
	    return a:i1.col == a:i2.col ? s:KeepOrder(a:i1, a:i2) : a:i1.col > a:i2.col ? 1 : -1
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
		return l:translatedCol == a:i2.col ? s:KeepOrder(a:i1, a:i2) : l:translatedCol > a:i2.col ? 1 : -1
	    else
		return a:i1.col == l:translatedCol ? s:KeepOrder(a:i1, a:i2) : a:i1.col > l:translatedCol ? 1 : -1
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

function! s:CheckAndGetNumber( isLocationList )
    if &l:buftype ==# 'quickfix'
	call ingo#msg#ErrorMsg('Already in quickfix')
	return 0
    endif

    let l:nr = QuickFixCurrentNumber#GetNumber(a:isLocationList ? getloclist(0) : getqflist())
    if l:nr == -1
	call ingo#msg#ErrorMsg(l:isLocationList ? 'No location list' : 'No Errors')
	return 0
    elseif l:nr == 0
	call ingo#msg#ErrorMsg('No more items')
	return 0
    endif

    return l:nr
endfunction
function! QuickFixCurrentNumber#Print( isLocationList )
    let l:nr = s:CheckAndGetNumber(a:isLocationList)
    if l:nr != 0
	let l:qflist = (a:isLocationList ? getloclist(0) : getqflist())
	echomsg printf('(%d of %d): %s', l:nr, len(l:qflist), get(l:qflist[l:nr - 1], 'text', ''))
    endif
endfunction

function! QuickFixCurrentNumber#Go( ... )
    let l:isLocationList = (a:0 ? a:1 : ! empty(getloclist(0)))
    let l:cmdPrefix = (l:isLocationList ? 'l' : 'c')
    let l:nr = s:CheckAndGetNumber(l:isLocationList)
    if l:nr == 0
	return
    endif

    let l:save_view = winsaveview()
    execute l:cmdPrefix . 'open'

    execute l:nr . l:cmdPrefix . 'first'
    " Above command jumps back to the buffer, and the selected error location. Restore the original position.
    call winrestview(l:save_view)

    execute l:cmdPrefix . 'open'
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
