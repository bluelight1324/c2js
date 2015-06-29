/* c2js bison flie */
%{
#include <iostream>
#include <fstream>
using namespace std;
#define YYSTYPE string

extern "C"
{
    void yyerror(const char* s);
    extern int yylex(void);
    ofstream outfile("out.js", ios::out);
}

int tabNum = 0;

%}

%token IDENTIFIER CONST STRING_LITERAL
%token INC_OP DEC_OP AND_OP OR_OP LE_OP GE_OP EQ_OP NE_OP
%token VOID CHAR INT FLOAT DOUBLE
%token LEFT_OP RIGHT_OP

%token IF ELSE FOR RETURN WHILE COMMENT COMMENTLONG CONTINUE BREAK
%token INCLUDE
%start program

%%

program
    : {$$ = "";}
    | program program_unit {outfile << $2 << "\n";}
    ;

program_unit
    : include_declaration  {$$ = $1;}
    | function_declaration {$$ = $1;}
    | variable_declaration {$$ = $1;}
    | comment              {$$ = $1;}
    ;

include_declaration
    : INCLUDE '<' IDENTIFIER '.' IDENTIFIER '>' {$$ = "";}
    | INCLUDE '<' IDENTIFIER '>'                {$$ = "";}
    ;

comment
    : COMMENT string {$$ = $1 + $2;}
    ;

string
    : primary_expression            {$$ = $1}
    | primary_expression string     {$$ = $1 + " " + $2}
    ;

function_declaration
    : type_specifier function_declarator compound_statement {$$ = "function" + $2 + $3; cout << $$ << endl;}
    ;

type_specifier
    : VOID  {$$ = "var";}
    | CHAR  {$$ = "var";}
    | INT   {$$ = "var";}
    | FLOAT {$$ = "var";}
    ;

declarator
    : identifier_list {$$ = $1;}
    | declarator '[' ']' {$$ = $1;}
    | declarator '[' constant_expression ']' {$$ = $1 + " = new Array(" + $3 + ")";}
    ;

function_declarator
    : IDENTIFIER '(' parameter_list ')' {$$ = $1 + $2 + $3 + $4;}
    | IDENTIFIER '(' ')' {$$ = $1 + $2 + $3;}
    ;

identifier_list
    : IDENTIFIER {$$ = $1;}
    | identifier_list ',' IDENTIFIER {$$ = $1 + $2 + $3;}
    ;

constant_expression
    : conditional_expression {$$ = $1;}
    ;

parameter_list
    : parameter_declaration {$$ = $1;}
    | parameter_list ',' parameter_declaration {$$ = $1 + $2 + $3;}
    ;

parameter_declaration
    : type_specifier declarator {$$ = $2;}
    ;

compound_statement
    : '{' '}' {$$ = $1 + $2; cout << "---------$$---------\n" << $$ << endl;}
    | '{' statement_list '}' {$$ = $1 + $2 + $3; cout << "---------$$---------\n" << $$ << endl;}
    | '{' variable_declarations statement_list '}' {$$ = $1 + $2 + $3 + $4; cout << "---------$$---------\n" << $$ << endl;}
    ;

variable_declarations
    : variable_declaration {$$ = $1;}
    | variable_declarations variable_declaration {$$ = $1 + $2;}

variable_declaration
    : type_specifier variable_declaration_list ';' {$$ = $1 + $2 + $3 + "\n";}
    ;

variable_declaration_list
    : init_declarator {$$ = $1;}
    | variable_declaration_list ',' init_declarator {$$ = $1 + $2 + $3;}
    ;

init_declarator
    : declarator {$$ = $1;}
    | declarator '=' initializer {$$ = $1 + $2 + $3;}
    ;

initializer
    : assignment_expression {$$ = $1;}
    | '{' initializer_list '}' {$$ = "[" + $2 + "]";}
    ;

initializer_list
    : initializer {$$ = $1;}
    | initializer_list ',' initializer {$$ = $1 + $2 + $3;}
    ;

expression
    : assignment_expression {$$ = $1;}
    | expression ',' assignment_expression {$$ = $1 + $2 + $3;}

assignment_expression
    : conditional_expression {$$ = $1;}
    | unary_expression assignment_operator assignment_expression {$$ = $1 + $2 + $3;}
    ;

conditional_expression
    : logical_or_expression {$$ = $1;}
    | logical_or_expression '?' expression ':' conditional_expression {$$ = $1 + $2 + $3 + $4 + $5;}
    ;

logical_or_expression
    : logical_and_expression {$$ = $1;}
    | logical_or_expression OR_OP logical_and_expression {$$ = $1 + $2 + $3;}
    ;

logical_and_expression
    : inclusive_or_expression {$$ = $1;}
    | logical_and_expression AND_OP inclusive_or_expression {$$ = $1 + $2 + $3;}
    ;

inclusive_or_expression
    : exclusive_or_expression {$$ = $1;}
    | inclusive_or_expression '|' exclusive_or_expression {$$ = $1 + $2 + $3;}
    ;

exclusive_or_expression
    : and_expression {$$ = $1;}
    | exclusive_or_expression '^' and_expression {$$ = $1 + $2 + $3;}
    ;

and_expression
    : equality_expression {$$ = $1;}
    | and_expression '&' equality_expression {$$ = $1 + $2 + $3;}
    ;

equality_expression
    : relational_expression {$$ = $1;}
    | equality_expression EQ_OP relational_expression {$$ = $1 + $2 + $3;}
    | equality_expression NE_OP relational_expression {$$ = $1 + $2 + $3;}
    ;

relational_expression
    : shift_expression {$$ = $1;}
    | relational_expression '<' shift_expression {$$ = $1 + $2 + $3;}
    | relational_expression '>' shift_expression {$$ = $1 + $2 + $3;}
    | relational_expression LE_OP shift_expression {$$ = $1 + $2 + $3;}
    | relational_expression GE_OP shift_expression {$$ = $1 + $2 + $3;}
    ;

shift_expression
    : additive_expression {$$ = $1;}
    | shift_expression LEFT_OP additive_expression {$$ = $1 + $2 + $3;}
    | shift_expression RIGHT_OP additive_expression {$$ = $1 + $2 + $3;}
    ;

additive_expression
    : multiplicative_expression {$$ = $1;}
    | additive_expression '+' multiplicative_expression {$$ = $1 + $2 + $3;}
    | additive_expression '-' multiplicative_expression {$$ = $1 + $2 + $3;}
    ;

multiplicative_expression
    : cast_expression {$$ = $1;}
    | multiplicative_expression '*' cast_expression {$$ = $1 + $2 + $3;}
    | multiplicative_expression '/' cast_expression {$$ = $1 + $2 + $3;}
    | multiplicative_expression '%' cast_expression {$$ = $1 + $2 + $3;}
    ;

cast_expression
    : unary_expression {$$ = $1;}
    | '(' type_specifier ')' cast_expression {$$ = $4;}
    ;

unary_expression
    : postfix_expression {$$ = $1;}
    | INC_OP unary_expression {$$ = $1 + $2;}
    | DEC_OP unary_expression {$$ = $1 + $2;}
    | unary_operator cast_expression {$$ = $1 + $2;}
    ;

postfix_expression
    : primary_expression {$$ = $1;}
    | postfix_expression '[' expression ']'
    | postfix_expression '(' ')' {$$ = $1 + $2 + $3;}
    | postfix_expression '(' argument_expression_list ')'
    | postfix_expression '.' IDENTIFIER {$$ = $1 + $2 + $3;}
    | postfix_expression INC_OP {$$ = $1 + $2;}
    | postfix_expression DEC_OP {$$ = $1 + $2;}
    ;

assignment_operator
    : '=' {$$ = $1;}
    | '+' {$$ = $1;}
    | '-' {$$ = $1;}
    | '*' {$$ = $1;}
    | '/' {$$ = $1;}
    | '%' {$$ = $1;}
    ;

primary_expression
    : IDENTIFIER {
        if ($1 == "printf") {
            $$ = "console.log";
        } else {
            $$ = $1;
        }
    }
    | CONST {$$ = $1;}
    | STRING_LITERAL {$$ = $1;}
    | '(' expression ')' {$$ = $1 + $2 + $3;}
    ;

argument_expression_list
    : assignment_expression {$$ = $1;}
    | argument_expression_list ',' assignment_expression {$$ = $1 + $2 + $3;}
    ;

unary_operator
    : '&' {$$ = $1;}
    | '*' {$$ = $1;}
    | '+' {$$ = $1;}
    | '-' {$$ = $1;}
    | '~' {$$ = $1;}
    | '!' {$$ = $1;}
    ;

statement_list
    : statement {$$ = $1;}
    | statement_list statement {$$ = $1 +  $2;}

statement
    : compound_statement {$$ = $1; cout << "----- COMPOUND -----\n"}
    | expression_statement {$$ = $1;}
    | selection_statement {$$ = $1;}
    | iteration_statement {$$ = $1;}
    | jump_statement {$$ = $1;}
    ;

expression_statement
    : ';' {$$ = $1;}
    | expression ';' {$$ = $1;}
    ;

selection_statement
    : IF '(' expression ')' statement {$$ = $1 + $2 + $3 + $4;}
    | IF '(' expression ')' statement ELSE statement {$$ = $1 + $2 + $3 + $4 + $5 + $6 + $7;}
    ;

iteration_statement
    : WHILE '(' expression ')' statement {$$ = $1 + $2 + $3 + $4 + $5;}
    | FOR '(' expression_statement expression_statement ')' statement {$$ = $1 + $2 + $3 + $4 + $5 + $6;}
    | FOR '(' expression_statement expression_statement expression ')' statement {$$ = $1 + $2 + $3 + $4 + $5 + $6 + $7;}
    ;

jump_statement
    : CONTINUE ';' {$$ = $1 + $2;}
    | BREAK ';' {$$ = $1 + $2;}
    | RETURN ';' {$$ = $1 + $2;}
    | RETURN expression ';' {$$ = $1 + $2 + $3;}
    ;

%%

void yyerror(const char* str)
{
    cout << "ERROR: " << str << endl;
}

extern FILE *yyin;
int main(int argc, char* argv[])
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
    }
    else
    {
        cout << "ERROR: Please enter the file name\n";
        return 0;
    }

    if (yyin == NULL)
    {
        cout << "ERROR: Can't open file\n";
        return 0;
    }

    cout << "------------ BEGIN ------------\n";

    yyparse();

    outfile.close();

    fclose(yyin);

    cout << "------------- END -------------\n";
}

















