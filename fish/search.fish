
function feo --description "fuzzy search emacs open"
         ag $argv | fzf --bind "enter:execute(eo {})" --exact --bind ctrl-k:kill-line
end

function fnd --description "fuzzy find emacs open"
         find -iname $argv | fzf --bind "enter:execute(eo {})" --exact --bind ctrl-k:kill-line
end
