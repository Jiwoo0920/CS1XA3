#! /bin/bash
cd ..
echo "Please read README.md for description of the features"
printf "Please select a feature:\n1:TODO Log\n2:Another Feature Coming Soon (Part 2) \nFeature:"
read input

#TODO Log
if [ $input = "1" ]; then
    #Create necessary dir/file; if exist already delete and create again
    if [ -f ~/CS1XA3/Project01/logs/todo.log ]; then
        rm -r ~/CS1XA3/Project01/logs
        mkdir -p ~/CS1XA3/Project01/logs
        touch ~/CS1XA3/Project01/logs/todo.log
    else
        mkdir -p ~/CS1XA3/Project01/logs
        touch ~/CS1XA3/Project01/logs/todo.log
   fi
   #grep lines with #TODO and copy it to todo.log
   grep -rh "#TODO" > ~/CS1XA3/Project01/logs/todo.log
fi
