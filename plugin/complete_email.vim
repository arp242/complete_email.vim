" complete_email.vim: completion of email addresses.
"
" http://code.arp242.net/complete_email.vim
"
" See the bottom of this file for copyright & license information.


"##########################################################
" Initialize some stuff
scriptencoding utf-8
if exists('g:loaded_complete_email') | finish | endif
let g:loaded_complete_email = 1
let s:save_cpo = &cpo
set cpo&vim


"##########################################################
" Options
if !exists('g:complete_email_file')
	let g:complete_email_file = expand('~/.mutt/address')
endif

if !exists('g:complete_email_addresses')
	let g:complete_email_addresses = []
endif


"##########################################################
" Mappings

if !exists('g:search_highlight_no_map') || empty(g:search_highlight_no_map)
	inoremap <silent> <Plug>(complete-email-complete) <C-r>=complete_email#complete()<CR>
	imap <C-x><C-m> <Plug>(complete-email-complete)

	" Make subsequent <C-m> presses after <C-x><C-m> go to the next entry (just like
	" other <C-x>* mappings)
	inoremap <expr> <C-m> pumvisible() ?  "\<C-n>" : "\<C-m>"
endif


"##########################################################
" Commands
command! AddEmailAddress :call s:add_address()


"##########################################################
" Functions

" Read database file
fun! complete_email#read_db() abort
	return map(readfile(g:complete_email_file), 'split(v:val, "")')
endfun


" Complete function for addresses; we match the name & address
fun! complete_email#complete() abort
	" Locate the start of the word
    let l:line = getline('.')
    let l:start = col('.') - 1
	while l:start > 0 && l:line[l:start - 1] =~ '\a'
        let l:start -= 1
    endwhile
    let l:base = l:line[l:start : col('.')-1]

	" Load database, if not initialized
	if empty(g:complete_email_addresses)
		let g:complete_email_addresses = complete_email#read_db()
	endif

	" Find matches
	let l:res = []
	for m in g:complete_email_addresses
		if l:m[0] !~? '^' . l:base && l:m[1] !~? '^' . l:base | continue | endif

		call add(l:res, {
			\ 'icase': 1,
			\ 'word': l:m[0] . ' <' . l:m[1] . '>, ',
			\ 'abbr': l:m[0],
			\ 'menu': l:m[1],
			\ 'info': len(l:m) > 2 ? join(l:m[2:], "\n") : '',
		\ })
	endfor

    call complete(l:start + 1, l:res)
	return ''
endfun


" Add a new address
" TODO: Could be smarter, eg. when selecting "Martin <martin@arp242.net>"
fun! s:add_address() abort
	let l:word = expand('<cWORD>')
	let l:default_email = ''

	" The current word looks like an email address
	if l:word =~ '@'
		" Remove non-word characters from the start & end
		let l:default_email = substitute(l:word, '^[^\w]\{-}\(\w.*\w\)[^\w]\{-}$', '\1', '')
	endif

	if l:default_email != ''
		let l:email = input('Email (enter for ' . l:default_email . '): ')
		if l:email == '' | let l:email = l:default_email | endif
	else
		let l:email = ''
		while 1
			let l:email = input('Email: ')
			if l:email =~ '@'
				break
			else
				echo "\nThat doesn't look like a valid address. Try again, or hit <C-c> to abort."
			endif
		endwhile
	endif

	let l:name = input('Name (optional): ')

	call complete_email#add_address(l:email, l:name, '')
endfun


fun! complete_email#add_address(email, name, other) abort
	call writefile([a:email . '' . a:name], g:complete_email_file, 'a')
	let g:complete_email_addresses = complete_email#read_db()
endfun


let &cpo = s:save_cpo
unlet s:save_cpo


" The MIT License (MIT)
"
" Copyright © 2015 Martin Tournoij
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" The software is provided "as is", without warranty of any kind, express or
" implied, including but not limited to the warranties of merchantability,
" fitness for a particular purpose and noninfringement. In no event shall the
" authors or copyright holders be liable for any claim, damages or other
" liability, whether in an action of contract, tort or otherwise, arising
" from, out of or in connection with the software or the use or other dealings
" in the software.
