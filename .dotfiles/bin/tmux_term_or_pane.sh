#!/usr/bin/bash
# THIS SCRIPT ASSUMES YOU HAVE 'tmux_update_focus.sh' in your $PATH! 
#
# * Options:
# Max number of panes in each tmux window, minus one:
MAXNUM=3

# Your prefered term, window title must be the same for wmctrl to be
# able to # select the window:
TERM_CLIENT="termite" 

# The option that tells your term you want to execute a command within
# it:
TERM_LAUNCH_OPTION="-e"

# * Code: 
if test $(wmctrl -l | grep $TERM_CLIENT 2>&1 | wc -l) -eq 1; then
    a=$(tmux list-panes | wc -l)

    if [ "$a" -gt $MAXNUM ]; then # Too many windows, do nothing.
	tmux_update_focus.sh
	wmctrl -vR $TERM_CLIENT;
	exit
    fi

    # otherwise, create a window and alternate between vertical/horz:

    if [ $((a%2)) -eq 0 ]; then
	tmux split-window -v;
    else
	tmux split-window -h;
    fi

    tmux_update_focus.sh
    wmctrl -vR $TERM_CLIENT; 

else
    tmux new-session -d -s 'manage'

    workspaces=$(wmctrl -d | cut -d ' ' -f 13-)
    idex=0

    for i in $workspaces; do
	tmux new-window -t manage:$idex -n $i
	let idex=${idex}+1
    done

    tmux_update_focus.sh
    
    $TERM_CLIENT $TERM_LAUNCH_OPTION 'tmux attach -t manage';

fi