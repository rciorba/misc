function loop --description "loop"
    while python3 ~/repos/misc/bin/iwatch.py  .
        # clear
        $argv
        if test $status -eq 0
             notify-send "ok" -i ~/Pictures/passing.svg -t 2000
         else
            notify-send "failed" -i ~/Pictures/failing.svg
        end
    end
end
