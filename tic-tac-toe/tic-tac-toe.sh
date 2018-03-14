#!/bin/bash
. tui.sh

clear
FIELD='         '

inital_variables () {
	width=$(tput cols)
	height=$(tput lines)
	bold=$(tput bold)
	underline=$(tput smul)
	not_underline=$(tput rmul)
	blink=$(tput blink)
	offattr=$(tput sgr0)
	cross_color=$(tput setaf 1)
	zero_color=$(tput setaf 4)
	background_color=$(tput setab 6)
}

print_name_enemy () { # ${1}-name
	tput sc
	string_enemy=" You play with: ${bold}${underline}${1}${offattr} "
	tput cup 0 $((width-${#1}-16))
	echo ${string_enemy}
	tput rs
}

calculate_size_field () {
	cur_h=$((height - 4))
	cur_w=$(( (width - 2 ) /2))
	(( size_block =  ${cur_w} < ${cur_h} ? ${cur_w} : ${cur_h} ))
	size_block=$((size_block / 3))
}

past_symbol_in_field () { # ${1} - x  ${2} - y ${3}-symbol
	x2=$((${1} - 1))
	y2=$((${2} - 1))
	position=$((${x2} + ${y2} * 3))
	curent_state=${FIELD:${position}:1}
	if [[ $curent_state = " " ]];
	then
	  	beg=$((${position}+1))
		end=$((9 - ${beg}))
		FIELD="${FIELD:0:${position}}${3}${FIELD:${beg}:${end}}"
	else
		clear_main_row_and_write "This cell alrady used, try yet: "
		read x y
		past_symbol_in_field ${x} ${y} ${3}
	fi
}

check_coord () {  # ${1} - x  ${2} - y
	is_correct_coord=$((1 <= ${1} && ${1} <= 3 && 1 <= ${2} && ${2} <= 3))

	if [ "$is_correct_coord" -eq "0" ];  
	then  
		clear_main_row_and_write "${underline}${blink}uncorrect x or y, try yet ${offattr}${bold}[1 <= x, y <= 3] (x, y):"
	 	read x y
		check_coord ${x} ${y}
	fi
}

print_cross_or_zero () { # ${1} - x  ${2} - y ${3} - height_block ${4} - width_block ${5}-cross or zero
		x1=$((${1} - 1))
		y1=$((${2} - 1))
		tput cup $((3 + ${y1} + ${y1} * ${3})) $((3 + ${x1} + ${x1} * ${4})) 
		if [[ $5 = "X" ]]; 
			then
				echo X
			else 
				echo 0
		fi
}

set_name() { #${1} - my-name
	this_player="X"
	trap "rm f &>/dev/null" EXIT
	mkfifo f 2>/dev/null
	if [[ $? == 1 ]]; then
		this_player="0"
		read_name
		write_name ${1}
	else {
		write_name ${1}
		read_name
	}
	fi

	begin_play ${this_player}  ${1}
}

read_name () {
	enemy_name=$(cat f)
	print_name_enemy ${enemy_name}
}

write_name () { #1
	echo ${1} > f
}

read_f() { # ${1} -cross or zero ${2}-my_name
	clear_main_row_and_write "${2} >: Wait "
	enemy=($(echo $(cat f)))
	past_symbol_in_field ${enemy[0]} ${enemy[1]} ${1}
	print_cross_or_zero ${enemy[0]} ${enemy[1]}  ${height_block} ${width_block} ${1}
}

write_f() { # ${1} -cross or zero ${2}-my_name
	clear_main_row_and_write "${2} >: "
	read x y
	check_coord ${x} ${y}
	past_symbol_in_field ${x} ${y} ${1}
	print_cross_or_zero ${x} ${y} ${height_block} ${width_block} ${1}
	echo ${x} ${y} > f
}

clear_main_row_and_write () { # ${1}-string
	tput cup $((${height} - 2)) 0
	tput el
	echo -n -e "${bold}${1}"
}

check_the_end() {
	rows=(${FIELD:0:3} ${FIELD:3:3} ${FIELD:6:3})
	columns=("${FIELD:0:1}${FIELD:3:1}${FIELD:6:1}" "${FIELD:1:1}${FIELD:4:1}${FIELD:7:1}" "${FIELD:2:1}${FIELD:5:1}${FIELD:8:1}")
	diagonal=("${FIELD:0:1}${FIELD:4:1}${FIELD:8:1}" "${FIELD:2:1}${FIELD:4:1}${FIELD:6:1}")
	if [[ " ${rows[@]} " =~ "XXX" || " ${columns[@]} " =~ "XXX" || " ${diagonal[@]} " =~ "XXX" ]]; 
	then
    	echo X
    else
    	if [[ " ${rows[@]} " =~ "000" || " ${columns[@]} " =~ "000" || " ${diagonal[@]} " =~ "000" ]]; 
		then
	    	echo 0
	    else
	    	echo -
		fi
	fi
}

begin_play() { #${1} - cross or zero ${2}-my_name
	inital_variables
	# print_name_enemy ${1}
	# calculate_size_field
	width_block=12
	height_block=5
	print_border ${height_block} ${width_block}
	if [[ ${1} = "X" ]]; 
		then other="0" turn=1
		else other="X" turn=-1
	fi
	while true ; do
		if [[ "$turn" -eq 1 ]];
		then
			write_f ${1} ${2} ${height_block} ${width_block}
		else 
			read_f ${other} ${2} ${height_block} ${width_block}
		fi
		turn=$(( ${turn} * -1 ))
		win=`check_the_end`
		if [[ $win = "X" || $win = "0" ]]; then
			if [[ $win = ${1} ]]; then
				clear_main_row_and_write "You win!!! \n"
			else
				clear_main_row_and_write "You lose!!! \n"
			fi
			rm f 2>/dev/null
			exit 1
		fi
	done

}

echo -n "Type your name: "
read name
set_name ${name}
