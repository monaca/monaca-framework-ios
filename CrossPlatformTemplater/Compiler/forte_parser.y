%{
#include <stdio.h>
#include "forte_lexer.h"
	
#import "Token.h"

#import "BlockStatementNode.h"
#import "IncludeStatementNode.h"
#import "ExtendsStatementNode.h"
#import "ParentStatementNode.h"
#import "RawStatementNode.h"
#import "StatementsNode.h"
#import "TopStatementsNode.h"

#import "BinaryOperationNode.h"
#import "ConstantValueNode.h"
#import "EchoStatementNode.h"
#import "IfStatementNode.h"
#import "ShortCircuitBinaryOperationNode.h"
#import "StringValueNode.h"
#import "UnaryOperationNode.h"

#import "TemplateParser.h"

#import "Template.h"

//#define YYSTYPE char*

// --------------------------------------------------
// #define YYDEBUG          1
// #define YYERROR_VERBOSE  1
// int yydebug = 1;

// --------------------------------------------------
void yyerror(TemplateParser *driver, char* str);
%}

%parse-param{ TemplateParser *driver }
%locations

%union {
	int intval;
	double val;
	char* charval;
	id node;
	id token;
}

%token_table

%token T_ERROR
%token <token>T_EXTENDS
%token <token>T_BLOCK
%token <token>T_ENDBLOCK
%token <token>T_INCLUDE
%token <token>T_PARENT
%token <token>T_STRING
%token <token>T_EQUAL
%token <token>T_NOTEQUAL
%token <token>T_IF
%token <token>T_ELSEIF
%token <token>T_ELSE
%token <token>T_ENDIF
%token <token>T_END
%token <token>T_ID
%token <token>T_DOT
%token <token>T_PIPE
%token <token>T_RAW
%token <token>T_ECHO
%token <token>T_OPENPAREN
%token <token>T_CLOSEPAREN
%token <token>T_AND
%token <token>T_OR
%token <token>T_NOT

%type <node>top_statements
%type <node>top_statement
%type <node>statement
%type <node>statements
%type <node>block_statement
%type <node>block_content
%type <node>extends_statement
%type <node>include_statement
%type <node>parent_statement
%type <node>raw_statement

%type <node>echo_statement
%type <node>apply

%type <node>if_statement
%type <node>if_content
%type <node>expression
%type <node>constant
%type <node>binary_operation
%type <node>unary_operation

%type <token>block_end
%type <token>if_end

%right T_NOT
%left T_EQUAL T_NOTEQUAL
%left T_AND T_OR


%start top_statements


// TODO(nhiroki): Support to calculate line number for debug.
// To achive that, we will calculate a number of line feed charactor in action.
%%

top_statements  : top_statements top_statement
                    { $$ = [TopStatementsNode nodeWithNodes:$1 right:$2]; driver.rootNode = $$ }
                | /* empty */
                    { $$ = [[TopStatementsNode alloc] init]; NSLog(@"[DEBUG] root empty."); driver.rootNode = $$ }
				;

top_statement   : extends_statement { $$ = $1; NSLog(@"[DEBUG] extends_stmt") }
                | block_statement { $$ = $1; NSLog(@"[DEBUG] block_stmt") }
                | include_statement { $$ = $1; NSLog(@"[DEBUG] include_stmt") }
                | raw_statement { $$ = $1; NSLog(@"[DEBUG] raw_stmt") }
                | echo_statement { $$ = $1; NSLog(@"[DEBUG] echo_statement") }
                | if_statement { $$ = $1; NSLog(@"[DEBUG] if_statement") }
                ;

statement       : parent_statement { $$ = $1; NSLog(@"[DEBUG] parent_stmt") }
                | block_statement { $$ = $1; NSLog(@"[DEBUG] block_stmt") }
                | include_statement { $$ = $1; NSLog(@"[DEBUG] include_stmt") }
                | raw_statement { $$ = $1; NSLog(@"[DEBUG] raw_stmt") }
                | echo_statement { $$ = $1; NSLog(@"[DEBUG] echo_statement") }
                ;

statements  : statements statement { $$ = [[StatementsNode alloc] initWithNodes:$1 right:$2]; NSLog(@"[DEBUG] STATEMENTS") }
			| /* empty */ { $$ = [[StatementsNode alloc] init]; NSLog(@"[DEBUG] empty") }
            ;

block_statement     : T_BLOCK T_ID block_content { $$ = [[BlockStatementNode alloc] initWithToken:$2 node:$3]; NSLog(@"[DEBUG] BLOCK") };
block_content       : T_STRING { $$ = [StatementsNode nodeWithToken:$1]; NSLog(@"[DEBUG] BLOCK CONTENT") }
                    | statements block_end { $$ = $1; NSLog(@"[DEBUG] BLOCK") }
                    ;
block_end           : T_END | T_ENDBLOCK ;

extends_statement   : T_EXTENDS T_STRING { $$ = [[ExtendsStatementNode alloc] initWithToken:$2]; NSLog(@"[DEBUG] EXTENDS") };
include_statement   : T_INCLUDE T_STRING { $$ = [[IncludeStatementNode alloc] initWithToken:$2]; NSLog(@"[DEBUG] INCLUDE") };
parent_statement    : T_PARENT { $$ = [[ParentStatementNode alloc] init]; NSLog(@"[DEBUG] PARENT") };
raw_statement       : T_RAW { $$ = [[RawStatementNode alloc] initWithToken:$1]; NSLog(@"[DEBUG] RAW") };
echo_statement      : T_ECHO expression apply { $$ = [[EchoStatementNode alloc] initWithNode:$2 apply:$3] };

if_statement    : T_IF expression statements if_content if_end
                    { $$ = [IfStatementNode nodeWithNodes:$2 statements:$3 elseStatement:$4] };

if_content      : T_ELSEIF expression statements if_content
                    { $$ = [IfStatementNode nodeWithNodes:$2 statements:$3 elseStatement:$4] }
                | T_ELSE statements { $$ = $2 }
                | /* empty */ { $$ = [[[StatementsNode alloc] init] autorelease] }
                ;

if_end          : T_END | T_ENDIF ;

expression      : binary_operation { $$ = $1 }
                | unary_operation { $$ = $1 }
                | constant { $$ = $1 }
                | T_STRING { $$ = [StringValueNode nodeWithToken:$1] }
                | T_OPENPAREN expression T_CLOSEPAREN { $$ = $2 }
                ;

constant        : constant T_DOT T_ID { $$ = [ConstantValueNode nodeWithToken:$3 left:$1] }
                | T_ID { $$ = [ConstantValueNode nodeWithToken:$1] }
                ;

apply           : T_PIPE T_ID { $$ = $2 }
                | /* empty */ { $$ = nil }

unary_operation     : T_NOT expression { $$ = [UnaryOperationNode nodeWithNotOperator:$2] };

binary_operation    : expression T_EQUAL expression { $$ = [BinaryOperationNode nodeWithEqualOperator:$1 right:$3] }
                    | expression T_NOTEQUAL expression { $$ = [BinaryOperationNode nodeWithNotEqualOperator:$1 right:$3] }
                    | expression T_AND expression { $$ = [ShortCircuitBinaryOperationNode nodeWithAndOperator:$1 right:$3] }
                    | expression T_OR expression { $$ = [ShortCircuitBinaryOperationNode nodeWithOrOperator:$1 right:$3] }
                    ;

%%



// --------------------------------------------------
void yyerror(TemplateParser *driver, char* str) {
	NSLog(@"[ERROR] %s", str);
}
