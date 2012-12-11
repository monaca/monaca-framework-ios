#ifndef FORTE_LEXER_H_
#define FORTE_LEXER_H_

#import "Node.h"

@class TemplateParser;

int yylex();
int yyparse(TemplateParser *driver);

#define STATE(name) yyc##name
enum YYCONDTYPE {
	yycRAW,
	yycCOMMENT,
	yycSTATEMENT,
	yycECHO
};

#define TzOKEN(name) #name

@interface TemplateScanner : NSObject {
	char *cursor_;			// A current scanner position.
	char *marker_;
	char *limit_;
	char *token_;			// A start position of a current token.
	NSString *token_name_;	// A current token name.
	enum YYCONDTYPE state_; // A state of scanner (RAW, COMMENT or STATEMENT).
    int line_;
}

- (id)init:(NSString *)text;
- (void)setText:(NSString *)text;
- (NSString *)next;

@property char *cursor;
@property char *marker;
@property char *limit;
@property char *token;
@property(assign) NSString *token_name;
@property enum YYCONDTYPE state;
@property int line;
@end

TemplateScanner *scanner;

#define YYGETCONDITION() (scanner.state)
#define YYSETCONDITION(cond) (scanner.state = cond)
#define YYGETSTATE() YYGETCONDITION()
#define YYSETSTATE(name) YYSETCONDITION(name)

#define YYCTYPE  char
#define YYCURSOR scanner.cursor
#define YYMARKER scanner.marker
#define YYLIMIT  scanner.limit
//#define YYFILL(n)   yyfill
#define YYDEBUG(state, ch) yydebug(state, ch)

#endif // FORTE_LEXER_H_