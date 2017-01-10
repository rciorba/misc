#!/usr/bin/fish

while python ~/repos/misc/bin/iwatch.py  .
       clear
       py.test -v --capture=no --nomigrations $argv
       if math "$status==0" > /dev/null
            notify-send "TMR" -i ~/Pictures/passing.svg
        else
           notify-send "TMR" -i ~/Pictures/failing.svg
       end
   end
