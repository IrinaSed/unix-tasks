print_border () { # ${1} - height_block ${2} - width_block
	print_vertical_lines ${1} ${2}
	# перегородки ╋
	print_border_character $((3 + ${1})) $((2 + ${2})) 4
	print_border_character $((4 + 2 * ${1})) $((2 + ${2})) 4
	print_border_character $((3 + ${1})) $((3 + 2 * ${2})) 4
	print_border_character $((4 + 2 * ${1})) $((3 + 2 * ${2})) 4

	# уголочки
	print_border_character 2 1 0
	print_border_character 2 $((4 + 3 * ${2})) 1
	print_border_character $((5 + 3 * ${1})) 1 2
	print_border_character $((5 + 3 * ${1})) $((4 + 3 * ${2})) 3

	# перегородки
	print_border_character 2 $((2 + ${2})) 5
	print_border_character 2 $((3 + 2 * ${2})) 5
	print_border_character $((5 +  3 * ${1})) $((2 + ${2})) 6
	print_border_character $((5 +  3 * ${1})) $((3 + 2 * ${2})) 6
	print_border_character $((3 + ${1})) 1 7
	print_border_character $((4 + 2 * ${1})) 1 7
	print_border_character $((3 + ${1})) $((4 + 3 * ${2})) 8
	print_border_character $((4 + 2 * ${1})) $((4 + 3 * ${2})) 8
}

print_border_character() { # ${3} - character number
	border_character=(┏ ┓ ┗ ┛ ╋ ┳ ┻ ┣ ┫)
	tput cup ${1} ${2}
	echo ${border_character[${3}]}
}

print_horizontal_line() {
	tput cup ${1} ${2}
	seq -s━ ${3}|tr -d '[:digit:]'
}

print_vertical_line() {
	i=${1}
	end=$((${3} + ${1}))
	while (( i < ${end} )); do
		tput cup ${i} ${2}
		echo "┃"
		(( i = i + 1 ))
		done
}

print_vertical_lines () { # ${1} - height_block ${2} - width_block
	height_border=$((${1} * 3 + 4))
	width_border=$((${2} * 3 + 4))
	j=0
	x_pos=1
	y_pos=2
	while ((j < 4)); do
		print_vertical_line 2 $((${x_pos} + j * ${2})) ${height_border}
		print_horizontal_line $((${y_pos} + j * ${1}))  1 ${width_border}
		(( x_pos = x_pos + 1 ))
		(( y_pos = y_pos + 1 ))
		(( j = j + 1 ))
	done
}