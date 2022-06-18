" QuickFixCurrentNumber.vim: Locate the quickfix item at the cursor position.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2013-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

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
	    let l:translatedCol = ingo#window#quickfix#TranslateVirtualColToByteCount(a:i1.vcol ? a:i1 : a:i2)
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

function! s:GetBufferQflist( qflist )
    " Though the list is usually sorted, it is not necessarily (e.g. one can use
    " :caddexpr to add entries out-of-band).
    let l:idx = 0
    while l:idx < len(a:qflist)
	let a:qflist[l:idx].number = l:idx + 1
	let l:idx += 1
    endwhile

    return sort(filter(copy(a:qflist), 'v:val.bufnr ==' . bufnr('')), 's:QflistSort')
endfunction
function! s:GetTruncatedItemColAndCurrent( item ) abort
    let [l:referenceValue, l:maxValue] = (a:item.vcol ? [virtcol('.'), virtcol('$') - 1] : [col('.'), col('$') - 1])
    return [min([a:item.col, l:maxValue]), l:referenceValue]
endfunction
function! s:IsCursorOnItem( item ) abort
    let [l:itemColumn, l:cursorColumn] = s:GetTruncatedItemColAndCurrent(a:item)
    return (a:item.lnum == line('.') && l:itemColumn == l:cursorColumn)
endfunction
function! s:IsCursorBeforeItemInThatLine( item ) abort
    let [l:itemColumn, l:cursorColumn] = s:GetTruncatedItemColAndCurrent(a:item)
    return (a:item.lnum == line('.') && l:itemColumn < l:cursorColumn)
endfunction
function! s:GetNumber( qflist, isFallbackToLast )
    let l:bufferQflist = s:GetBufferQflist(a:qflist)
    let l:result = {'isEmpty': len(l:bufferQflist) == 0, 'firstIdx': -1, 'firstNr': 0, 'lastIdx': -1, 'lastNr': 0, 'isOnEntry': 0, 'bufferQflist': l:bufferQflist}

    for l:idx in range(len(l:bufferQflist))
	let l:item = l:bufferQflist[l:idx]
	if l:item.lnum < line('.')
	    continue    " Before current line (or line not specified).
	elseif l:item.lnum == line('.') && l:item.col == 0
	    " The column is not specified. Match entire line; the actual error
	    " could be anywhere.
	    let l:result.firstIdx = l:idx
	    let l:result.firstNr = l:item.number
	    let l:result.isOnEntry = 1
	    return s:GetLastNumber(l:result)
	elseif s:IsCursorBeforeItemInThatLine(l:item)
	    continue    " Before cursor on the current line.
	endif

	let l:result.firstIdx = l:idx
	let l:result.firstNr = l:item.number
	let l:result.isOnEntry = s:IsCursorOnItem(l:item)
	return s:GetLastNumber(l:result)
    endfor

    if a:isFallbackToLast && ! l:result.isEmpty
	let l:result.lastIdx = len(l:bufferQflist) - 1
	let l:result.lastNr = l:bufferQflist[l:result.lastIdx].number
	return s:GetFirstNumber(l:result)
    endif

    return l:result
endfunction
function! s:GetFirstNumber( result ) abort
    for l:idx in range(a:result.lastIdx, 0, -1)
	let l:item = a:result.bufferQflist[l:idx]
	if ! s:IsCursorOnItem(l:item) || l:item.col == 0
	    " Note: Don't include items that don't have a column specified
	    " when going back.
	    break
	endif
    endfor
    let a:result.firstIdx = l:idx
    let a:result.firstNr = a:result.bufferQflist[l:idx].number
    return a:result
endfunction
function! s:GetLastNumber( result ) abort
    for l:idx in range(a:result.firstIdx + 1, len(a:result.bufferQflist) - 1)
	let l:item = a:result.bufferQflist[l:idx]
	if ! (s:IsCursorOnItem(l:item) || (l:item.lnum == line('.') && l:item.col == 0))
	    " Note: Include items that don't have a column specified when going
	    " forward.
	    break
	endif
    endfor
    let a:result.lastIdx = l:idx - 1
    let a:result.lastNr = a:result.bufferQflist[a:result.lastIdx].number
    return a:result
endfunction


function! s:CheckAndGetNumber( isLocationList, isPrintErrors, isFallbackToLast )
    call ingo#err#Clear()

    if &l:buftype ==# 'quickfix'
	call ingo#err#Set('Already in quickfix')
	return {'nr': 0, 'bufferQflist': []}
    endif

    let l:result = s:GetNumber(a:isLocationList ? getloclist(0) : getqflist(), a:isFallbackToLast)
    if ! a:isPrintErrors
	return l:result
    endif

    if l:result.isEmpty
	call ingo#err#Set(a:isLocationList ? 'No location list' : 'No Errors')
    elseif l:result.firstNr == 0
	call ingo#err#Set('No more items')
    endif
    return l:result
endfunction
function! QuickFixCurrentNumber#Print( isLocationList )
    let l:result = s:CheckAndGetNumber(a:isLocationList, 1, 0)
    let l:firstNr = l:result.firstNr
    if l:firstNr <= 0
	return 0
    endif

    let l:qflist = (a:isLocationList ? getloclist(0) : getqflist())
    let l:nrRange = (l:firstNr == l:result.lastNr ? '' : printf('-%d', l:result.lastNr))
    echomsg printf('(%d%s of %d): %s', l:firstNr, l:nrRange, len(l:qflist), get(l:qflist[l:firstNr - 1], 'text', ''))
    return 1
endfunction

function! QuickFixCurrentNumber#Go( count, isPrintErrors, isFallbackToLast, ... )
    let l:isLocationList = (a:0 ? a:1 : ! empty(getloclist(0)))
    let l:cmdPrefix = (l:isLocationList ? 'l' : 'c')
    let l:result = s:CheckAndGetNumber(l:isLocationList, a:isPrintErrors, a:isFallbackToLast)
    let l:nr = l:result.firstNr
    if l:nr <= 0
	return 0
    endif
    if (a:count > 0)
	let l:idx = l:result.firstIdx + a:count - 1
	if l:idx > l:result.lastIdx
	    return 0
	endif
	let l:nr = l:result.bufferQflist[l:idx].number
    endif

    let l:save_view = winsaveview()
    execute l:cmdPrefix . 'open'

    execute l:nr . l:cmdPrefix . 'first'
    " Above command jumps back to the buffer, and the selected error location. Restore the original position.
    call winrestview(l:save_view)

    execute l:cmdPrefix . 'open'
    return 1
endfunction


function! s:GotoIdx( isLocationList, bufferQflist, idx )
    if a:idx < 0 || a:idx >= len(a:bufferQflist)
	return 0
    endif

    let l:cmdPrefix = (a:isLocationList ? 'l' : 'c')
    execute a:bufferQflist[a:idx].number . l:cmdPrefix . 'first'
    return 1
endfunction

function! QuickFixCurrentNumber#Next( count, isLocationList, isBackward )
    for l:count in range(a:count)
	let l:result = s:CheckAndGetNumber(a:isLocationList, 0, 0)
	if l:result.firstNr == 0 && len(l:result.bufferQflist) == 0
	    return 0
	endif

	if a:isBackward
	    if l:result.firstNr == 0
		" There are no more matches after the cursor, so the last match in
		" the buffer must be the one before the cursor.
		let l:idx = len(l:result.bufferQflist) - 1
	    else
		let l:idx = l:result.firstIdx - 1
	    endif
	else
	    let l:idx = (l:result.isOnEntry ? l:result.lastIdx + 1 : l:result.firstIdx)
	endif

	if ! s:GotoIdx(a:isLocationList, l:result.bufferQflist, l:idx)
	    return 0
	endif
    endfor

    if a:count > 1
	" XXX: If multiple items have been iterated over, the QuickFixLine
	" highlighting of previous items persist (in Vim 8.2.4765).
	redraw!
    endif

    return 1
endfunction
function! QuickFixCurrentNumber#Border( count, isLocationList, isEnd )
    if &l:buftype ==# 'quickfix'
	call ingo#err#Set('Already in quickfix')
	return 0
    endif

    let l:bufferQflist = s:GetBufferQflist(a:isLocationList ? getloclist(0) : getqflist())
    let l:idx = (a:isEnd ? len(l:bufferQflist) - a:count : a:count - 1)

    call ingo#err#Clear()
    return s:GotoIdx(a:isLocationList, l:bufferQflist, l:idx)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
