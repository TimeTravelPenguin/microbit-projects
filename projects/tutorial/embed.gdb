target remote :1337
set mem inaccessible-by-default off

set print asm-demangle on
set print pretty on
set style sources off

layout split

break main
# break DefaultHandler
# break HardFault

continue

break 16
break 19
break 22
break 25

monitor reset halt
