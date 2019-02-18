#! /bin/bash
cd ..
echo "Please read README.md for description of the features"
printf "Please select a feature:\n1:TODO Log\n2:Another Feature\n3: Another Feature \n4:Compile Error Log\n5:(Custom) chmod converter \nFeature:"
read input

#1) TODO Log----------------------------------------------------------------------------------------------
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

#2) Compile Error Log---------------------------------------------------------------------------------------------
elif [ $input = "4" ]; then
    #Create compile_fail.log
    if [ -f ~/CS1XA3/Project01/logs/compile_fail.log ]; then 
        rm ~/CS1XA3/Project01/logs/compile_fail.log
        touch ~/CS1XA3/Project01/logs/compile_fail.log
    else
        touch ~/CS1XA3/Project01/logs/compile_fail.log
    fi

    #Find python files that failed to compile
    find ~/CS1XA3/Project01 -iname "*.py" -type f -print0 | while IFS= read -d $'\0' files; do 
        python -B -m py_compile $files
        if [ $? -ne 0 ]; then
            echo $files >> ~/CS1XA3/Project01/logs/compile_fail.log 
        else
            rm $files"c"
        fi
        done

    #Find haskell files that failed to compile
    find ~/CS1XA3/Project01 -iname "*.hs" -type f -print0 | while IFS= read -d $'\0' files; do
        ghc -o $files
        if [ $? -ne 0 ]; then
            echo $files >> ~/CS1XA3/Project01/logs/compile_fail.log
        fi
        done

#3) (Custom) chmod converter------------------------------------------------------------------------------
elif [ $input = "5" ]; then

    printf "Path of the directory:"
    read dirPath
    printf "Extension:"
    read extension
    printf "Chmod:"
    read chmodNum
    for item in $extension; do
        find $dirPath -iname "*.${item}" -type f -print0 | while IFS= read -d $'\0' files ; do
            chmod $chmodNum $files
            done
        done


fi
