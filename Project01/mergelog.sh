#! /bin/bash
cd ..
echo "Please read README.md for description of the features"
printf "Please select a feature:\n1:TODO Log\n2:Compile Error Log\n3:(Custom) chmod converter \nFeature:"
read input

if [ $input = "2" ]; then
    touch ~/CS1XA3/Project01/gitlog.txt
    git log --oneline >> ~/CS1XA3/Project01/gitlog.txt
    grep "merge" ~/CS1XA3/Project01/gitlog.txt >> ~/CS1XA3/Project01/logs/merge.log
fi
