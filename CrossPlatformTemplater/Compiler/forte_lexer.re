#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "forte_lexer.h"
#include "forte_parser.h"

@implementation TemplateScanner
@synthesize cursor = cursor_, marker = marker_, limit = limit_;
@synthesize token = token_, token_name = token_name_, state = state_, line = line_;

// Initializer.
- (id)init:(NSString *)text {
    self = [super init];
    if (self != nil) {
        int length = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;	
        char *str = (char *)malloc(sizeof(char) * length);
        [text getCString:str maxLength:length encoding:NSUTF8StringEncoding];

        cursor_ = str;
        limit_ = str;
        marker_ = 0;
        YYSETSTATE(STATE(RAW));
        line_ = 1;
    }
    return self;
}

// Sets current token name.
- (void)setTokenName:(NSString *)name {
	token_name_ = name;
}

// Gets next token name. Returns nil if next token does not exist.
- (NSString *)next {
	return yylex() != 0 ? token_name_ : nil;
}

@end


static char* get_text() { 
  int len = scanner.cursor - scanner.token;
  char *val = (char *)malloc(sizeof(char) * (len + 1));
  memcpy(val, scanner.token, len);
  val[len] = '\0';
  return val;
}

static void inc_line_number() {
    char *str = get_text();
    int i = 0, line = 0;
    for (i = 0; i < strlen(str); i++)
        if (str[i] == '\n') line++;
    scanner.line += line;
}

static inline int t_echo() {
	[scanner setTokenName:@"T_ECHO"];
	return T_ECHO;
}

static inline int t_raw() {
	[scanner setTokenName:@"T_RAW"];
	NSString *text = [NSString stringWithCString:get_text()
										encoding:NSUTF8StringEncoding];
    inc_line_number();
	yylval.token = [Token tokenWithSymbol:T_RAW lineNumber:scanner.line value:text];
	return T_RAW;
}

static inline int t_extends() {
	[scanner setTokenName:@"T_EXTENDS"];
	yylval.token = [Token tokenWithSymbol:T_EXTENDS lineNumber:scanner.line value:@"extends"];
	return T_EXTENDS;
}

static inline int t_block() {
	[scanner setTokenName:@"T_BLOCK"];
	yylval.token = [Token tokenWithSymbol:T_BLOCK lineNumber:scanner.line value:@"block"];
	return T_BLOCK;
}

static inline int t_endblock() {
	[scanner setTokenName:@"T_ENDBLOCK"];
	yylval.token = [Token tokenWithSymbol:T_ENDBLOCK lineNumber:scanner.line value:@"endblock"];
	return T_ENDBLOCK;
}

static inline int t_parent() {
	[scanner setTokenName:@"T_PARENT"];
	yylval.token = [Token tokenWithSymbol:T_PARENT lineNumber:scanner.line value:@"parent"];
	return T_PARENT;
}

static inline int t_include() {
	[scanner setTokenName:@"T_INCLUDE"];
	yylval.token = [Token tokenWithSymbol:T_INCLUDE lineNumber:scanner.line value:@"include"];
	return T_INCLUDE;
}

static inline int t_and() {
    [scanner setTokenName:@"T_AND"];
    yylval.token = [Token tokenWithSymbol:T_AND lineNumber:scanner.line value:@"and"];
    return T_AND;
}

static inline int t_or() {
    [scanner setTokenName:@"T_OR"];
    yylval.token = [Token tokenWithSymbol:T_OR lineNumber:scanner.line value:@"or"];
    return T_OR;
}

static inline int t_not() {
    [scanner setTokenName:@"T_NOT"];
    yylval.token = [Token tokenWithSymbol:T_NOT lineNumber:scanner.line value:@"not"];
    return T_NOT;
}

static inline int t_openparen() {
    [scanner setTokenName:@"T_OPENPAREN"];
    yylval.token = [Token tokenWithSymbol:T_OPENPAREN lineNumber:scanner.line value:@"("];
    return T_OPENPAREN;
}

static inline int t_closeparen() {
    [scanner setTokenName:@"T_CLOSEPAREN"];
    yylval.token = [Token tokenWithSymbol:T_CLOSEPAREN lineNumber:scanner.line value:@")"];
    return T_CLOSEPAREN;
}

static inline int t_double_string() {
	// Remove double-quotations.
	scanner.token++;
	scanner.cursor--;

    NSString *value = [NSString stringWithCString: get_text() encoding:NSUTF8StringEncoding];
    unichar *buffer = (unichar *)malloc(sizeof(unichar) * [value length]);
    unsigned long buf_idx = 0;

    for (unsigned long idx = 0; idx < [value length]; idx++) {
        unichar ch = [value characterAtIndex:idx];
        if (ch == '\\' && idx + 1 < [value length]) {
            unichar next = [value characterAtIndex:++idx];
            if (next == 't') {
                buffer[buf_idx++] = (unichar)'\t';
            } else if (next == 'r') {
                buffer[buf_idx++] = (unichar)'\r';
            } else if (next == 'n') {
                buffer[buf_idx++] = (unichar)'\n';
            } else if (next == '\\') {
                buffer[buf_idx++] = (unichar)'\\';
            } else if (next == '"') {
                buffer[buf_idx++] = (unichar)'"';
            } else {
                // String Escape Anything.
                buffer[buf_idx++] = next;
            }
        } else {
            buffer[buf_idx++] = ch;
        }
    }
    value = [NSString stringWithCharacters:buffer length:buf_idx];
    free(buffer);

	yylval.token = [Token tokenWithSymbol:T_STRING lineNumber:scanner.line value:value];
	scanner.cursor++;

	[scanner setTokenName:@"T_STRING"];
	return T_STRING;
}

static inline int t_single_string() {
    // Remove single-quotations.
    scanner.token++;
    scanner.cursor--;

    NSString *value = [NSString stringWithCString: get_text() encoding:NSUTF8StringEncoding];
    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    value = [value stringByReplacingOccurrencesOfString:@"\\\'" withString:@"'"];

    yylval.token = [Token tokenWithSymbol:T_STRING lineNumber:scanner.line value:value];
    scanner.cursor++;

    [scanner setTokenName:@"T_STRING"];
    return T_STRING;
}

static inline int t_equal() {
	[scanner setTokenName:@"T_EQUAL"];
	yylval.token = [Token tokenWithSymbol:T_EQUAL lineNumber:scanner.line value:@"=="];
	return T_EQUAL;
}

static inline int t_notequal() {
	[scanner setTokenName:@"T_NOTEQUAL"];
	yylval.token = [Token tokenWithSymbol:T_NOTEQUAL lineNumber:scanner.line value:@"!="];
	return T_NOTEQUAL;
}

static inline int t_if() {
	[scanner setTokenName:@"T_IF"];
	yylval.token = [Token tokenWithSymbol:T_IF lineNumber:scanner.line value:@"if"];
	return T_IF;
}

static inline int t_elseif() {
	[scanner setTokenName:@"T_ELSEIF"];
	yylval.token = [Token tokenWithSymbol:T_ELSEIF lineNumber:scanner.line value:@"elseif"];
	return T_ELSEIF;
}

static inline int t_else() {
	[scanner setTokenName:@"T_ELSE"];
	yylval.token = [Token tokenWithSymbol:T_ELSE lineNumber:scanner.line value:@"else"];
	return T_ELSE;
}

static inline int t_endif() {
	[scanner setTokenName:@"T_ENDIF"];
	yylval.token = [Token tokenWithSymbol:T_ENDIF lineNumber:scanner.line value:@"endif"];
	return T_ENDIF;
}

static inline int t_end() {
	[scanner setTokenName:@"T_END"];
	yylval.token = [Token tokenWithSymbol:T_END lineNumber:scanner.line value:@"end"];
	return T_END;
}

static inline int t_dot() {
	[scanner setTokenName:@"T_DOT"];
	yylval.token = [Token tokenWithSymbol:T_DOT lineNumber:scanner.line value:@"."];
	return T_DOT;
}

static inline int t_pipe() {
    [scanner setTokenName:@"T_PIPE"];
    yylval.token = [Token tokenWithSymbol:T_PIPE lineNumber:scanner.line value:@"|"];
    return T_PIPE;
}

static inline int t_id() {
	[scanner setTokenName:@"T_ID"];
    yylval.token = [Token tokenWithSymbol:T_ID lineNumber:scanner.line value:[NSString stringWithCString: get_text() encoding:NSUTF8StringEncoding]];
	return T_ID;
}

// TODO(nhiroki): Not implement.
/*
int yyfill(int n) {
	scanner.cursor = [text UTF8String];
	scanner.limit = [text UTF8String];
	scanner.marker = 0;
	YYSETSTATE(STATE(RAW));
			
	//while (*++scanner.cursor && n--) ;
	//*scanner.limit = scanner.cursor;
	//return n <= 0 ? 1 : 0;
}
*/

// Shows re2c debug information. |state| means lexer state number.
// |ch| means current character.
static void yydebug(int state, char ch) {
#if 0
	NSLog(@"[DEBUG] %c (yy%d)", ch, state);
	return;
#endif
}

int yylex()
{
	NSCParameterAssert(scanner.cursor != NULL);

/*!re2c
	re2c:yyfill:enable = 0;
	re2c:indent:top = 1;
	re2c:define:YYCONDTYPE = YYCONDTYPE;
	re2c:define:YYSETCONDITION = YYSETSTATE;
	re2c:define:YYGETCONDITION = YYGETSTATE;
	re2c:cond:goto = "goto start;";

	RAW			        = ([^{\000]|"{"[^%#{])*;
	
	DOUBLE_QUOTE_STRING = "\""([^\"\\]|"\\".)*"\"";
	SINGLE_QUOTE_STRING = "'"([^'\\]|"\\".)*"'";
	STRING              = DOUBLE_QUOTE_STRING | SINGLE_QUOTE_STRING;
	MULTILINE_COMMENT   = "/\*"([^*]|"\*"[^/])*"\*/";
	
	ID                  = [a-zA-Z_][a-zA-Z0-9_]*;
	WHITESPACE          = [\t ]+;
    NEWLINE             = [\r\n];
	END                 = [\000];
*/

start:
	scanner.token = scanner.cursor;

/*!re2c
	/* State transition. */
	<RAW>"{%" :=> STATEMENT
	<RAW>"{#" :=> COMMENT
	<RAW>"{{" => ECHO { return t_echo(); }
	<STATEMENT>"%}" :=> RAW
	<COMMENT>"#}" :=> RAW
	<ECHO>"}}" :=> RAW

	<RAW>RAW { return t_raw(); }
	<RAW>END { return 0; }

	<STATEMENT, ECHO>"extends"  { return t_extends(); }
	<STATEMENT, ECHO>"block"    { return t_block(); }
	<STATEMENT, ECHO>"endblock" { return t_endblock(); }
	<STATEMENT, ECHO>"parent"   { return t_parent(); }
	<STATEMENT, ECHO>"include"  { return t_include(); }

    <STATEMENT, ECHO>"and"      { return t_and(); }
    <STATEMENT, ECHO>"or"       { return t_or(); }
    <STATEMENT, ECHO>"not"      { return t_not(); }

    <STATEMENT, ECHO>"("        { return t_openparen(); }
    <STATEMENT, ECHO>")"        { return t_closeparen(); }

	<STATEMENT, ECHO>DOUBLE_QUOTE_STRING     { return t_double_string(); }
	<STATEMENT, ECHO>SINGLE_QUOTE_STRING     { return t_single_string(); }
	<STATEMENT, ECHO>"=="       { return t_equal(); }
	<STATEMENT, ECHO>"!="       { return t_notequal(); }
	<STATEMENT, ECHO>"if"       { return t_if(); }
	<STATEMENT, ECHO>"elseif"   { return t_elseif(); }
	<STATEMENT, ECHO>"else"     { return t_else(); }
	<STATEMENT, ECHO>"endif"    { return t_endif(); }
	<STATEMENT, ECHO>"end"      { return t_end(); }
	<STATEMENT, ECHO>ID         { return t_id(); }

	<STATEMENT, ECHO>"\."       { return t_dot(); }
    <STATEMENT, ECHO>"\|"       { return t_pipe(); }

    <STATEMENT, ECHO>WHITESPACE { goto start; }
	<STATEMENT, ECHO>MULTILINE_COMMENT {
        inc_line_number();
        goto start;
    }

	<COMMENT>. { goto start; }
    <COMMENT>NEWLINE {
        scanner.line++;
        goto start;
    }

    <STATEMENT, ECHO, COMMENT>END
        { [NSException raise:@"LexerException" format:@"Reached the end of file in invalid state."]; }
*/
}

