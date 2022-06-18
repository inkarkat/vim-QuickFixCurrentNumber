QUICK FIX CURRENT NUMBER
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

You can navigate through the errors in the quickfix list with the built-in
:cfirst, :cnext, etc. commands. The quickfix and location lists have a
notion of "current item" (the highlighted one), and you can easily jump back
to it or others. But there's no built-in way to find out which error is at or
after the current cursor position, and you cannot limit the navigation to
errors in the current buffer.

This plugin provides additional quickfix commands like :Cnr and :Cgo to
print / go to the item at or after the cursor position, and motions like ]q
to go to previous / next errors in the current buffer, based on the cursor
position.

### SOURCE

- [Inspiration for this plugin](http://stackoverflow.com/questions/14778612/jump-to-the-errors-in-the-quickfix-or-location-list-for-the-current-line-in-vim)

USAGE
------------------------------------------------------------------------------

    :Cnr, :Lnr              Print the number(s) of the item(s) in the quickfix /
                            location list for the current cursor position (or the
                            next item after the cursor).

    :[N]Cgo[!], :[N]Lgo[!]  Go to the [N]'th item in the quickfix / location list
    [N]g<C-Q>               for the current cursor position (or the next item
                            after the cursor). g<C-Q> (and the commands when [!]
                            is given) also jump to the last item if the cursor is
                            after all errors; without [!], the commands then abort
                            with an error.

    [q / ]q                 Go to [count] previous / next start of an error in the
                            current buffer.
    g[q / g]q               Go to [count] first / last error in the current
                            buffer.

    [l / ]l                 Go to [count] previous / next start of a location list
                            item in the current buffer.
    g[l / g]l               Go to [count] first / last location list item in the
                            current buffer.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-QuickFixCurrentNumber
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim QuickFixCurrentNumber*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.023 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

If you want to use different mappings, map your keys to the
&lt;Plug&gt;(QuickFixCurrentNumber...) mapping targets _before_ sourcing the script
(e.g. in your vimrc):

    nmap g<C-q> <Plug>(QuickFixCurrentNumberGo)
    nmap ]q     <Plug>(QuickFixCurrentNumberQNext)
    nmap [q     <Plug>(QuickFixCurrentNumberQPrev)
    nmap ]l     <Plug>(QuickFixCurrentNumberLNext)
    nmap [l     <Plug>(QuickFixCurrentNumberLPrev)
    nmap g[q    <Plug>(QuickFixCurrentNumberQFirst)
    nmap g]q    <Plug>(QuickFixCurrentNumberQLast)
    nmap g[l    <Plug>(QuickFixCurrentNumberLFirst)
    nmap g]l    <Plug>(QuickFixCurrentNumberLLast)

If you want no or only a few of the available mappings, you can completely
turn off the creation of the default mappings via:

    :let g:no_QuickFixCurrentNumber_maps = 1

This saves you from mapping dummy keys to all unwanted mapping targets.

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-QuickFixCurrentNumber/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.20    RELEASEME
- BUG: [q / ]q get stuck if there are multiple errors at one position.
- :[CL]nr now reports number ranges if there are multiple items at the cursor
  position.
- :[CL]go allows [count] to go to following items at the cursor position
- Robustness: Limit the reported item column to the actual line length to
  avoid that iteration with [q / ]q gets stuck.
- FIX: Iteration with reported virtual columns throws "E117: Unknown function:
  vcol"

##### 1.11    11-Mar-2015
- :Cgo and :Lgo take [!] to behave like g&lt;C-Q&gt;, i.e. jump back to the last
  error instead of aborting. This is helpful because g&lt;C-Q&gt; only crudely
  distinguishes between location and quickfix list, and both may be in use.
  Thanks to Enno Nagel for the suggestion.
- Allow to disable all default mappings via g:no\_QuickFixCurrentNumber\_maps.
  Some users may prefer straightforward navigation through quickfix errors
  with ]q (e.g. as provided by the unimpaired.vim plugin).
- BUG: Script errors when jump mappings like ]q are executed in a quickfix /
  location list. Need to populate the bufferQflist property in the returned
  result and tweak the check in QuickFixCurrentNumber#Next(). Thanks to Enno
  Nagel for reporting this.
- Use ingo/err.vim for error reporting.

##### 1.10    08-Mar-2015
- g&lt;C-Q&gt; now also jumps to the last item if the cursor is after all errors;
  the commands continue to abort with a "No more items" error. This allows to
  jump to the next / closest error position, regardless of the cursor
  position. Thanks to Enno Nagel for the suggestion.
- Factor out ingo#window#quickfix#TranslateVirtualColToByteCount() into
  ingo-library.

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433))
  version 1.023!__

##### 1.00    19-Feb-2013
- First published version.

##### 0.01    08-Feb-2013
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2013-2022 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
