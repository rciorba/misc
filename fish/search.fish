
function feo --description "fuzzy search emacs open"
         ag $argv | fzf --bind "enter:execute(eo {})" --exact --bind ctrl-k:kill-line
end

function fco --description "fuzzy search vscode open"
         ag $argv | fzf --bind "enter:execute(echo {} | grep -o -E '.*:[0-9]+' | xargs code -r -g)" --exact --bind ctrl-k:kill-line
end


function fnd --description "fuzzy find emacs open"
         find -iname $argv | fzf --bind "enter:execute(eo {})" --exact --bind ctrl-k:kill-line
end
