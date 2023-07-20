# Usage instructions

In ~/.bash_aliases or wherever, add the following lines:
```bash
export BS_LOCATION="<REPO ROOT>/bash"
source "${BS_LOCATION}/_init.sh"
```
where `<REPO ROOT>` should be where this repo was pulled to. For example, if it is in /mnt/c/git/devenv, then the first line should be:
```bash
export BS_LOCATION="/mnt/c/git/devenv/bash"
```

## Config stuff
### local
When you need to define something thats only relevant to your local environment, put the files in the `local` folder. You can also define an `_init.sh` in said folder, which will be evaluated before anything else.

### Keys
`CCLEAR_REMINDER` can be defined to non-empty in order for reminders to be printed when calling `cclear` (or `c`)  
`REMINDER_LOCATION` can be defined to change the location of the reminder file (default: `<REPO ROOT>/bash/reminder/.reminders`)  
`NOTES_LOCATION` can be defined to change the location of the notes file (default: `<REPO ROOT>/bash/notes/.notes`)  
`SCT_LOCATION` can be defined to change the location of the sct folder (default: `<REPO ROOT>/bash/sct/.sct/`)  