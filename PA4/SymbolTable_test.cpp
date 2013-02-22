#include <stdlib.h>
#include <stdio.h>
#include "/home/administrator/cool/include/PA4/symtab.h"
#include "/home/administrator/cool/include/PA4/stringtab.h"

int main()
{
    SymbolTable<Symbol, int> *test = new SymbolTable<Symbol, int>();
    Symbol s = idtable.add_string("1");
    int ss = 10;
    test->addid(s, ss);
}
