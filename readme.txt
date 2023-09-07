//編譯指令
#compile bison
bison -d -o y.tab.c mini_LISP.y
gcc -c -g -I.. y.tab.c
#compile flex
flex -o lex.yy.c mini_LISP.l
gcc -c -g -I.. lex.yy.c
#compile and link bison and flex
gcc -o mini_LISP y.tab.o lex.yy.o -ll

執行方式:
./mini_LISP < 01_1.lsp
或是
./mini_LISP 後直接輸入

此程式只完成 1~6 feature