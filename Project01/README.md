# Overview
**Name:** Jiwoo Lee  
**MacID:** leej229

**Last Update:** Feb 15, 2019 (10:38 AM)  
**Status:** Finished Part 1

# Description
This project is designed to make an interactive bash script that takes user input to perform specific features in a repository.

For more information about this project, please refer to [this link](https://mac1xa3.ca/Projects/Project01.pdf).

# Basic Commands/Execution
This script initializes when the user writes the following command in ~CS1XA3/Project01 directory:
```
./project_analyze.sh
```

Then, the user will be given a set of options to choose which feature of the script he/she wishes to execute.
As of right now (Friday, Feb 15, 2019), there is only one working feature in this script, which is _**TODO Log**_.
By Tuesday Feb 26, 2019, the user will have a set of at least 3 features to choose from.

The following lines are what the user will see when he/she first executes the script:
```
Please select a feature:
1) TODO Log
2) Another Feature Coming Soon (Part 2)
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
* Creates the directory **~/CS1XA3/Project01/logs** and file **~/CS1XA3/Project01/logs/todo.log**
    * If they already exist, the script deletes both the **log** directory and **todo.log** file, and creates them again
* Puts each line of every file in your repo with the tag **#TODO** into the file **todo.log**
* To execute this feature, simply input the following and hit enter (there are no further steps needed)
    ```
    Feature: 1
    ```
* Once it is successfully executed, the script will terminate, and the user will now be able to access **todo.log** in **~/CS1XA3/Project01** directory that contains each line of every file in the repo with the tag **#TODO** on it 















