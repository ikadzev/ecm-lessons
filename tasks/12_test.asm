.include "testLib.asm"

FUNC strchr, "strchr"
OK 0 "abcde" 'a'
OK 3 "fffwwqw" 'w'
OK 2 "abcde" 'a'
NONE "abcdef" 'Q'
NONE "" '?'
NONE "abcde" 'e'
DONE
