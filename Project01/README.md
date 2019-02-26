# Overview
**Name:** Jiwoo Lee  
**MacID:** leej229

**Last Update:** Feb 25, 2019  
**Status:** Finished Part 2

# Description
This project is designed to make an interactive bash script that takes user input to perform specific features in a repository.

For more information about this project, please refer to [this link](https://mac1xa3.ca/Projects/Project01.pdf).

# Basic Commands/Execution
This script initializes when the user writes the following command in ~CS1XA3/Project01 directory:
```
./project_analyze.sh
```

Then, the user will be given a set of options to choose which feature of the script he/she wishes to execute. The following lines are what the user will see when he/she first executes the script:
```
Please select a feature:
1) TODO Log
2) Merge Log
3) File Type Count
4) Compile Error Log
5) Delete Temporary Files
6) (Custom) chmod Converter
7) (Custom) chmod Friendly Reminder
Feature:
```

The user is to input the corresponding number of the feature he/she wishes to execute on the same line as:
```
Feature:
```

For example, if the user wants to execute _**TODO Log**_ feature, he/she would input 1
```
Feature: 1
```
and hit enter.

# Description of Features
### 1) TODO Log
* Creates the file **~/CS1XA3/Project01/logs/todo.log**
    * If it already exists, the script deletes **todo.log** file, and creates it again
* Puts each line of every file in your repo with the tag **#TODO** into the file **todo.log**
* To execute this feature, simply input the following and hit enter (no further steps needed)
    ```
    Feature: 1
    ```
* Once it is successfully executed, the script will terminate, and the user will now be able to access **todo.log** in **~/CS1XA3/Project01/logs** directory that contains each line of every file in the repo with the tag **#TODO** on it

### 2) Merge Log
* Creates the file **~/CS1XA3/Project01/logs/merge.log**
    * If it already exists, the script deletes **merge.log** file, and creates it again
* Find all the commit hashes where merge is mentioned in the commit message and put them in a file **merge.log**
* To execute this feature, simply input the following and hit enter (no further steps needed)
    ```
    Feature: 2
    ```
* Once it is successfully executed, the script will terminate, and the user will now be able to access **merge.log** in **~/CS1XA3/Project01/logs** directory with all the commit hashes where merge is mentioned in the commit message

### 3) File Type Count
* For each HTML, Javascript, CSS, Python, Haskell and Bash Script file, the script outputs a file count for how many of each exist
* To execute this feautre, simply input the following and hit enter (no further steps needed)
    ```
    Feature: 3
    ```
* Once it is successfully executed, the script will terminate, and the user will now able to see a file count on the command line. An example output would be something like:
    ```
    HTML: 4, Javascript: 1, CSS: 0, Python: 5, Haskell: 2, Bash Script: 1
    ```

### 4) Compile Error Log
* Creates the file **~/CS1XA3/Project01/logs/compile_fail.log**
    * If it already exists, the script deletes **compile_fail.log** file, and creates it again
* Finds Haskell and Python files in your repo that fail to compile (i.e have syntax errors) and put them in a file **compile_fail.log**
* To execute this feautre, imply input the following and hit enter (no further steps needed)
    ```
    Feature: 4
    ```
* Once it is successfully executed, the script will terminate, and the user will now able to access **compile_fail.log** in **~/CS1XA3/Project01/logs** directory with all the **.py** and **.hs** files that failed to compile

### 5) Delete Temporary Files
* Finds and deletes all **untracked** files ending in the extension **.tmp**
*  To execute this feautre, simply input the following and hit enter (no further steps needed)
    ```
    Feature: 5
    ```
* Once it is successfully executed, all untracked files in your repo with the extension **.tmp** will be removed 
* **Note:** you can generate a list of all untracked files from the current directory by typing the following in the command line:
    ```
    git ls-files . --exclude-standard --others
    ```

### 6) (Custom 1) chmod Converter
* This feature allows user to change permissions based on extension of the files in a specific directory
* The following lines are what the user will see when he/she first executes this feature: 
    ```
    Path of Directory:
    Extension:
    chmod:
    ```
* The user is to input the desired directory, extension, and chmod number
* For example, if the user wants to change permission of all python files in **~/CS1XA3** directory to give full rwx permission to only the user, input:
    ```
    Path of Directory: ~/CS1XA3
    Extension: py
    chmod: 700
    ```
* You can also change permissions of multiple extensions. For example, if you want to change permissions of all python and haskell files in in **~/CS1XA3** directory to give full rwx permission to everyone, input:
    ```
    Path of Directory: ~/CS1XA3
    Extension: .py .hs
    chmod: 777
    ```
    * The two extensions must be separated by a space in between
* To execute this feautre, simply input the following and hit enter
    ```
    Feature: 6
    ```
* Once it is successfully executed, the script will terminate, and the permissions of the desired files will be converted to the desired chmod number (type ls -la on the command line to check permissions)

### 7) (Custom 2) chmod Friendly Reminder
* In case the user have forgotten (or is too lazy to calculate) the chmod number, this feature takes the **letter version** of chmod (ie. rwx) and converts to its corresponding **chmod number**
* The following lines are what the user will see when he/she first executes this feature: 
    ```
    User:
    Group:
    Everyone Else:
    ```
* The user is to input any of the followings as input:
    ```
    rwx 
    rw_ 
    r_x 
    r__ 
    _wx 
    _w_ 
    __x 
    ___
    ```
* For example, if the user inputs:
    ```
    User: rwx
    Group: rw_ 
    Everyone Else: __x
    ```
* It will output the following in command line:
    ```
    chmod = 761
    ```
* This feature is to be used alongside with feature #6
* To execute this feautre, simply input the following and hit enter
    ```
    Feature: 7
    ```
* Once it is successfully executed, the script will terminate, and the corresponding chmod number will be outputted to command line
