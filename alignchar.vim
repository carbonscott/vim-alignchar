" Copyright (c) 2020 Cong Wang
" 
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
" 
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


" If already loaded, we're done...
if exists("loaded_AlignChar")
    finish
endif
let loaded_AlignChar = 1

let s:cpo_save = &cpo
set cpo&vim


" [[[ Implementation ]]]

function! AlignChar()
    " Set the char to align to...
    let s:dialog   = "which char to align: "
    let s:the_char = input(s:dialog, "")
    if empty(s:the_char) 
        let s:the_char = '#'
    endif

    " Fig out line numbers of interested lines...
    let s:l_start        = line("'<")
    let s:l_end          = line("'>")
    let s:l_ids          = sort([s:l_start, s:l_end],"f")  " numerical sort...
    let s:interest_lines = range(s:l_ids[0],s:l_ids[1],1)
    
    " Give a starting point of matching... [working here]
    let s:current_pos = getpos('.')
    echo s:current_pos
    let s:match_start = s:current_pos[2] - 1 

    "[debug]
    let g:l_ids = s:l_ids
    let g:interest_lines = s:interest_lines

    " Read interesting lines...
    let s:yank_text = []
    for line in s:interest_lines
        call add(s:yank_text,getline(line))
    endfor
    let s:data_text = deepcopy(s:yank_text)

    let g:data_text = s:data_text

    " Find where comments are...
    let s:comment_positions = []
    for each_one in s:data_text
        call add(s:comment_positions, match(each_one, s:the_char, s:match_start) + 1) " match gives the position offset by 1...
    endfor

    " [debug]
    let g:comment_positions = s:comment_positions

    " Align lines to the rightmost...
    let s:col_algin = max(s:comment_positions)
    for i in range(0,len(s:interest_lines)-1)
        " only reposition the token when the line has it...
        if s:comment_positions[i] > 0        
            call setpos('.',[0,s:interest_lines[i],s:comment_positions[i],0])
            execute "normal! i".repeat(" ",s:col_algin-s:comment_positions[i])
        endif
    endfor

    redraw
    return
endfunction

command! -nargs=0 AlignChar call AlignChar()

" Don't add silent if there will be a prompt
vnoremap [a :<c-u>AlignChar<cr>


let &cpo = s:cpo_save
unlet s:cpo_save

finish
