YACC    = bison
LEX     = re2c
MV	= mv

OBJS = forte_lexer.m forte_parser.m

all: $(OBJS)

# Generates lexer source file.
forte_lexer.m: forte_lexer.re forte_parser.m
	$(LEX) -c -d -o forte_lexer.m forte_lexer.re

# Generates parser source file.
forte_parser.m: forte_parser.y
	$(YACC) -l -d -o forte_parser.c forte_parser.y
	$(MV) forte_parser.c forte_parser.m

clean:
	rm -f *.o $(TARGET) forte_lexer.m forte_parser.m forte_parser.h
