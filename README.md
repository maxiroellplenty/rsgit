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
./rsgit --install
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

## Options
* --install
* --uninstall

## Bugs
* Report bugs by creating an issue at this repo.

