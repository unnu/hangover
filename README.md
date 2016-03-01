Hangover
========

Hangover is **time travel** (except the future) **for your source code** directory. Some call it the unlimited undo. It tracks every single file change in a git repository (`.hangover`). Hangover runs in the background. The file changes get committed to the next parent hangover repository. You can restore any state of your files from the moment on you started hangover.


Usage
-----

Start hangover in the directory from which you want to track all changes.

`hangover start`

Create a hangover repository in the same directory.

`hangover create`

All changes within this directory and it's subdirectories go into this repository.


Commands
--------

    hangover <command> [options]
  
    Commands:
    
    start  - Tracks all file changes within current directory and it's subdirectories.
    stop   - Stops hangover.
    status - Shows if hangover is running and which directory is tracked.
    create - Creates a hangover repository in current directory.
    git    - Tunnels git commands to the hangover repository.
    gitk   - Starts gitk for the hangover repository.


Restoring files
---------------

Given you want to restore your project directory like it was half an hour ago. Open gitk by running `hangover gitk` and find the wanted commit. Then checkout the commit by running `hangover git checkout <commit_hash>`. If you are done  run `hangover git reset --hard HEAD` to get back to your latest files.


Multiple hangover repositories
------------------------------

The hangover repositories are stored in a `.hangover` directory. You can create multiple repositories in subdirectories to separate projects. 

    projects
     \_ .hangover
        homepage 
        customer_website
         \_ .hangover
            images
            stylesheets

In this example all changes in the `homepage` directory got to the `.hangover` repository directly under `projects`. All changes in `customer_website` and it's subdirectories get tracked in it's own repository.
