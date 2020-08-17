# rsgit v3

tested with macOS, adjust install path for other OS types 

## Install
```
git clone https://github.com/maxiroellplenty/rsgit.git
```
```
cd rsgit
```
```
chmod +x rsgit
```

```
./rsgit.sh --install
```

## Config

* Open the `/usr/local/bin/rsgit` file
* Add you repositories to the array in line 5
    * repositoryPath=branchName
    * repositoryPath is the path for the repo
    * [Optional] branchName is the branch for the reset function
    * example `/path/to/rsgit=master`
* Edit basePath in line 9
    * example `/` or `/workspace`


## How to use
* Start new shell and type `rsgit`
```
   ___  ___________________
  / _ \/ __/ ___/  _/_  __/
 / , _/\ \/ (_ // /  / /
/_/|_/___/\___/___/ /_/  v3 by roelldev

[1]  Pull repositories
[2]  List repositories
[3]  Reset repositories to base branch
[4]  Help
[99] Exit
-----------------------------------------------
Enter option:
```

* [1] Pulls all defined repositories and stashes changes.
* [2] Lists all defined repositories.
* [3] Resets all repositories to the defined branch.

## Options
* --install
* --uninstall

## Bugs
* Report bugs by creating an issue at this repo.

