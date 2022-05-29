#!/usr/bin/fish

while python ~/repos/misc/bin/iwatch.py  .
       clear
       pytest -v --capture=no $argv
       if test $status -eq 0
            notify-send "OK" -i ~/Pictures/passing.svg
        else
           notify-send "FAIL" -i ~/Pictures/failing.svg
       end
   end
