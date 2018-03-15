#!/bin/bash
. tui.sh

clear
NAME='unknown'
FIELD='         '
POSITION_X=0
POSITION_Y=1
HEIGHT=$(tput lines)
WIDTH=$(tput cols)
HEIGHT_BLOCK=0
WIDTH_BLOCK=0
CHARACTER="X"
OTHER="0"
TURN=1


inital_variables () {
	bold=$(tput bold)
	underline=$(tput smul)
	not_underline=$(tput rmul)
	civis=$(tput civis)
	blink=$(tput blink)
	offattr=$(tput sgr0)
}

print_name_enemy () { # ${1}-name
	tput sc
	string_enemy=" You play with: ${bold}${underline}${1}${offattr} "
	tput cup 0 $(($WIDTH-${#1}-16))
	tput el1
	echo ${string_enemy}
	tput rs
}

calculate_size_field () {
	width_block=1
	height_block=2
	if [[ $HEIGHT -gt 22 && $WIDTH -gt 35 ]];
	then 
		width_block=5
		height_block=10
	fi  
	if [[ $HEIGHT -gt 52 && $WIDTH -gt 116 ]];
	then 
		width_block=15
		height_block=37
	fi  

	echo $width_block $height_block
}

past_symbol_in_field () { # $1-(x or 0)
	position=$((POSITION_X+POSITION_Y*3))
	curent_state=${FIELD:$position:1}
	if [[ $curent_state = " " ]];
	then
	  	beg=$((position+1))
		end=$((9 - ${beg}))
		FIELD="${FIELD:0:$position}$1${FIELD:$beg:$end}"
	else
		clear_main_row_and_write "This cell alrady used, try yet!"
		print_cross_or_zero $curent_state
		chose_position
	fi
}

print_cross_or_zero () { # $1-(0 or x) $2 - style
		line=$((POSITION_Y*HEIGHT_BLOCK+3+POSITION_Y))
		col=$((POSITION_X*WIDTH_BLOCK+3+POSITION_X)) 
		if [[ $1 = "X" ]]; 
			then print_x $line $col $HEIGHT_BLOCK "$2"
			else
				if [[ $1 = "0" ]]; 
					then print_0 $line $col $HEIGHT_BLOCK "$2"
					else print_empty $line $col $HEIGHT_BLOCK
				fi
		fi
}

read_name () {
	enemy_name=$(cat f)
	print_name_enemy $enemy_name
}

write_name () { #1
	echo $NAME > f
}

read_f() { # ${2}-my_name
	clear_main_row_and_write "$2 >: Wait "
	enemy=($(echo $(cat f)))
	POSITION_X=${enemy[0]}
	POSITION_Y=${enemy[1]}
	past_symbol_in_field $OTHER
	print_cross_or_zero $OTHER
}

write_f() { # ${1} -cross or zero
	clear_main_row_and_write "$NAME >: "
	chose_position
	echo $POSITION_X $POSITION_Y > f
}

chose_position() {
	POSITION_X=0
	POSITION_Y=0
	print_cross_or_zero $CHARACTER "${blink}"
	find_position=""
	while [[ $find_position != "found"  ]]; do
		read -r -sn1 key
		position=$((POSITION_Y*3+POSITION_X))
		print_cross_or_zero ${FIELD:${position}:1}
		case $key in
			"A") POSITION_Y=$((($POSITION_Y+2) % 3));;
			"B") POSITION_Y=$((($POSITION_Y+1) % 3));;
			"C") POSITION_X=$((($POSITION_X+1) % 3));;
			"D") POSITION_X=$((($POSITION_X+2) % 3));;
			"") find_position="found";;
		esac
		print_cross_or_zero $CHARACTER "${blink}"
	done
	past_symbol_in_field $CHARACTER
	print_cross_or_zero $CHARACTER
}

clear_main_row_and_write () { # ${1}-string
	tput cup $(($HEIGHT - 2)) 0
	tput el
	echo -e -n "$bold$1"
}

check_the_end() {
	rows=(${FIELD:0:3} ${FIELD:3:3} ${FIELD:6:3})
	columns=("${FIELD:0:1}${FIELD:3:1}${FIELD:6:1}" "${FIELD:1:1}${FIELD:4:1}${FIELD:7:1}" "${FIELD:2:1}${FIELD:5:1}${FIELD:8:1}")
	diagonal=("${FIELD:0:1}${FIELD:4:1}${FIELD:8:1}" "${FIELD:2:1}${FIELD:4:1}${FIELD:6:1}")
	# echo $rows $columns $diagonal 
	if [[ " ${rows[@]} " =~ "XXX" || " ${columns[@]} " =~ "XXX" || " ${diagonal[@]} " =~ "XXX" ]]; 
	then echo X
    else
    	if [[ " ${rows[@]} " =~ "000" || " ${columns[@]} " =~ "000" || " ${diagonal[@]} " =~ "000" ]]; 
		then echo 0
	    else
	    	if [[ $FIELD =~ ' ' ]]; 
	    		then echo -
				else echo draw
			fi
		fi
	fi
}

init() {
	echo -n "Type your name: "
	read NAME
	trap "stty echo" EXIT
	stty -echo
	trap "rm f &>/dev/null" EXIT
	mkfifo f 2>/dev/null
	if [[ $? == 1 ]]; then
		CHARACTER="0"
		OTHER="X"
		TURN=-1
		read_name
		write_name
	else {
		write_name
		read_name
	}
	fi
}

begin_play() { # $1 - my_name
	inital_variables
	size_block=(`calculate_size_field`)
	HEIGHT_BLOCK=${size_block[0]}
	WIDTH_BLOCK=${size_block[1]}
	print_border $HEIGHT_BLOCK $WIDTH_BLOCK

	while true ; do
		if [[ "$TURN" -eq 1 ]];
			then write_f
			else read_f
		fi
		TURN=$(( $TURN * -1 ))
		win=`check_the_end`
		if [[ $win = "X" || $win = "0" ||  $win = "draw" ]];
		then
			if [[ $win = $CHARACTER ]]; 
				then clear_main_row_and_write "You win!!! \n"
				else
					if [[ $win = $OTHER ]]; 
						then clear_main_row_and_write "You lose!!! \n"
						else clear_main_row_and_write "Draw! \n"
					fi
			fi
			rm f 2>/dev/null
			trap "stty echo" EXIT
			exit 1
		fi
	done
}

init
begin_play