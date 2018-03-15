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

print_x() { #${1}-line ${2}-col ${3} - height ${4}-style
	cross_color=$(tput setaf 4)
	case "$3" in
		"1")  symbol=('x');;
		"5")  symbol=('xxx   xxx' ' xxx xxx ' '   xxx   ' ' xxx xxx ' 'xxx   xxx') ;;
		"15") symbol=(
			'xxxxxxxxxxx             xxxxxxxxxxx'
			' xxxxxxxxxxx           xxxxxxxxxxx '
			'  xxxxxxxxxxx         xxxxxxxxxxx  '
			'   xxxxxxxxxxx       xxxxxxxxxxx   '
			'    xxxxxxxxxxx     xxxxxxxxxxx    '
			'     xxxxxxxxxxx   xxxxxxxxxxx     '
			'      xxxxxxxxxxx xxxxxxxxxxx      '
			'        xxxxxxxxxxxxxxxxxxx        '
			'      xxxxxxxxxxx xxxxxxxxxxx      '
			'     xxxxxxxxxxx   xxxxxxxxxxx     '
			'    xxxxxxxxxxx     xxxxxxxxxxx    '
			'   xxxxxxxxxxx       xxxxxxxxxxx   '
			'  xxxxxxxxxxx         xxxxxxxxxxx  '
			' xxxxxxxxxxx           xxxxxxxxxxx '
			'xxxxxxxxxxx             xxxxxxxxxxx'
		) ;;
	esac
	for (( i=0; i < $3; i++ )) do
		print_row_symbol $(($1 + $i)) $2 "$civis$cross_color$4${symbol[$i]}$offattr"
	done
}

print_0 () { #${1}-line ${2}-col ${3} - height ${4}-style
	zero_color=$(tput setaf 3)
	case "$3" in
		"1")  symbol=('0');;
		"5")  symbol=(' 0000000 ' '000   000' '00     00' '000   000' ' 0000000 ') ;;
		"15") symbol=(                           
			'          00000000000000           '
			'        000000000000000000         '
			'      0000000000000000000000       '
			'    000000000         000000000    ' 
			'   00000000             00000000   ' 
			'   0000000               0000000   ' 
			'   0000000               0000000   ' 
			'   0000000               0000000   ' 
			'   0000000               0000000   ' 
			'   0000000               0000000   ' 
			'   00000000             00000000   ' 
			'    000000000         000000000    ' 
			'      0000000000000000000000       '
			'        000000000000000000         '
			'          00000000000000           '
		) ;;
	esac

	for (( i=0; i < $3; i++ )) do
		print_row_symbol $(($1 + $i)) $2 "$civis$4$zero_color${symbol[$i]}$offattr"
	done
}

print_empty () { #${1}-line ${2}-col ${3} - height
	case "$3" in
		"1")  symbol=(' ');;
		"5")  symbol=('         ' '         ' '         ' '         ' '         ') ;;
		"15") symbol=(                           
			'                                   '
			'                                   '
			'                                   '
			'                                   ' 
			'                                   ' 
			'                                   ' 
			'                                   ' 
			'                                   ' 
			'                                   ' 
			'                                   ' 
			'                                   ' 
			'                                   ' 
			'                                   '
			'                                   '
			'                                   '
		) ;;
	esac

	for (( i=0; i < $3; i++ )) do
		print_row_symbol $(($1 + $i)) $2 "$civis${symbol[$i]}"
	done
}

print_row_symbol() { #${1}-line ${2}-col  ${3}-string
	tput cup $1 $2
	echo -n "$3" 
}

