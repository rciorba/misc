
function refresh-tmux --description "refresh the environment after tmux attach"
    tmux showenv | egrep "^SSH_" | awk -F= '{print "set -x", $1, $2}' | source
end
