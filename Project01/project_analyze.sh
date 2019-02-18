#! /bin/bash
cd ..
echo "Please read README.md for description of the features"
printf "Please select a feature:\n1:TODO Log\n2:Merge Log\n3:File Type Count\n4:Compile Error Log\n5:(Custom) chmod converter \nFeature:"
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



#2) Merge Log---------------------------------------------------------------------------------------------------
elif [ $input = "2" ]; then
    if [ -f ~/CS1XA3/Project01/logs/merge.log ]; then
        rm ~/CS1XA3/Project01/logs/merge.log
        touch ~/CS1XA3/Project01/logs/merge.log
    else
        touch ~/CS1XA3/Project01/logs/merge.log
    fi

    tmpFile1=$(mktemp)
    tmpFile2=$(mktemp)
    git log --oneline >> $tmpFile1
    grep -i "merge" $tmpFile1 > $tmpFile2
    cut -d " " -f 1 $tmpFile2 >> ~/CS1XA3/Project01/logs/merge.log



#3) File Type Count---------------------------------------------------------------------------------------------------
elif [ $input = "3" ]; then 
    result=()
    #HTML----------------------------------------------------------------------------------------
    html=$(mktemp)
    find ~/CS1XA3/Project01 -iname "*.html" -type f -print0 | while IFS= read -d $'\0' files; do
        echo $files >> $html
        done
    if [ -s $html ]; then 
        result1=$(wc -l $html | cut -d " " -f 1)
        result+=($result1)
    else
        result+=(0)
    fi 
    #Javascript------------------------------------------------------------------------------------
    javascript=$(mktemp)
    find ~/CS1XA3/Project01 -iname "*.js" -type f -print0 | while IFS= read -d $'\0' files; do
        echo $files >> $javascript
        done 
    if [ -s $javascript ]; then
        result2=$(wc -l $javascript | cut -d " " -f 1)
        result+=($result2)
    else
        result+=(0)
    fi
    #css------------------------------------------------------------------------------------
    css=$(mktemp)
    find ~/CS1XA3/Project01 -iname "*.css" -type f -print0 | while IFS= read -d $'\0' files; do
        echo $files >> $css  
        done
    if [ -s $css ]; then
        result3=$(wc -l $css | cut -d " " -f 1)
        result+=($result3)
    else
        result+=(0)
    fi 
    #python------------------------------------------------------------------------------------
    python=$(mktemp)
    find ~/CS1XA3/Project01 -iname "*.py" -type f -print0 | while IFS= read -d $'\0' files; do
        echo $files >> $python
        done
    if [ -s $python ]; then
        result4=$(wc -l $python | cut -d " " -f 1)
        result+=($result4)
    else
        result+=(0)
    fi
    #haskell------------------------------------------------------------------------------------
    haskell=$(mktemp)
    find ~/CS1XA3/Project01 -iname "*.hs" -type f -print0 | while IFS= read -d $'\0' files; do
        echo $files >> $haskell
        done
    if [ -s $haskell ]; then
        result5=$(wc -l $haskell | cut -d " " -f 1)
        result+=($result5)
    else
        result+=(0)
    fi     
    #bash------------------------------------------------------------------------------------
    bash=$(mktemp)
    find ~/CS1XA3/Project01 -iname "*.sh" -type f -print0 | while IFS= read -d $'\0' files; do
        echo $files >> $bash 
        done
    if [ -s $bash ]; then
        result6=$(wc -l $bash | cut -d " " -f 1)
        result+=($result6)
    else
        result+=(0)
    fi     
    #result------------------------------------------------------------------------------------
    echo "HTML:${result[0]}, Javascript:${result[1]}, CSS:${result[2]}, Python:${result[3]}, Haskell:${result[4]}, Bash Script:${result[5]}"



#4) Compile Error Log---------------------------------------------------------------------------------------------
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



#5) (Custom) chmod converter------------------------------------------------------------------------------
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
