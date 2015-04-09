#!/bin/bash
# todo ffmpeg


# sakuli --run (pfad zur Suite) --sahi_home (Sahi install dir) -h -d --sakuli_home (opt. anderes Sak. Home) 

# sakuli --encrypt (secret) --interface eth0

# ARG1 = suitename
# 
VNC_RESOLUTION="1024x768"
VNC_COL_DEPTH=24
VNC_DISPLAY=1

INCLUDE_FOLDER=$SAKULI_HOME/_include
SAKULI_JARS=$SAKULI_HOME/libs/java
ROBOTIC_ICON=$SAKULI_HOME/bin/resources/robotic1.png

options=$@
arguments=($options)
index=0

die_usage() {
	cat <<USAGE
Generic Sakuli test starter.
2015 - The Sakuli team.
 Usage: $0 [options]
USAGE
	sakuli_usage
	cat <<HERE
 -V,--vnc			    start in headless (xVNC11) mode
 -D,--display			    display number in headless mode (default: 1)
HERE
	exit 1
}

sakuli_usage() {
	java -classpath $SAKULI_JARS/sakuli.jar:$SAKULI_JARS/* org.sakuli.starter.SakuliStarter -help | grep -v "usage: sakuli"
}

exec_test() {
	java -classpath $SAKULI_JARS/sakuli.jar:$SAKULI_JARS/* org.sakuli.starter.SakuliStarter $@
}

vnc_kill() {
	[[ ! $HEADLESS ]] && return
	vncserver -kill $DISPLAY
}

notify() {
	if [[ -x $(which notify-send) ]]; then 
		notify-send -t 10 -u low -i "$ROBOTIC_ICON" "$1"
	fi
}

init_vnc() {
	[[ ! $HEADLESS ]] && return
	if [[ ! -x $(which vncserver) ]]; then
		echo "Cannot start in headless mode: can't locate vncserver."
		exit 1
	fi
	PORT="590"$VNC_DISPLAY
	notify "Sakuli test '$SUITE' starting now on display $VNC_DISPLAY (localhost:$PORT)."
	DISPLAY=:$VNC_DISPLAY
	vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION &
}

let lastindex=${#arguments[@]}-1
i=0
while [ $i -le $lastindex ]; do
	case ${arguments[$i]} in
		"-h")
			die_usage
			;;
		"--help")
			die_usage
			;;
		"-?")
			die_usage
			;;
		"-V" | "--vnc" )
			HEADLESS=true
			let "i=$i+1"
			;;
		"-D" | "--display" )
			let "j=$i+1"
			VNC_DISPLAY=${arguments[$j]}
			let "i=$i+2"		
			;;
		*)
			sakuli_args="$sakuli_args ${arguments[$i]}"
			let "i=$i+1"		
			;;
	esac
done

init_vnc
exec_test $sakuli_args
vnc_kill

