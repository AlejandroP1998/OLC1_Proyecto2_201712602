/*
    JISON COMPILER
*/

%{
    // Importations
    import { type, arithmeticOperator, relationalOperator } from "./tools/Type.js";
    import { Arithmetic } from './expressions/Arithmetic.js';
    import { Relational } from './expressions/Relational.js';
    import Primitive from './expressions/Primitive.js';
    import { Identifier } from './expressions/Identifier.js';
    import { Print } from './instructions/Print.js';
    import { Declaration } from './instructions/Declaration.js';
    import { If } from './instructions/If.js';

%}

%{
    // Variables definition and functions

    let errors = [];

    const clean_errors = () => {
        errors = [];
    }
%}

/*------------------------ Lexical Definition ------------------------*/

%lex 
%options case-insensitive

%%

// elementos a ignorar
\s+                                 // espacios
"--".*                              // comentario de una linea
\/\*[^*]*\*+([^/*][^*]*\*+)*\/      // comentario de varias líneas

/*------------------------ Reserved Words ------------------------*/

// tipos de datos
"int"                       return "res_int";
"double"                    return "res_double";
"date"                      return "res_date";
"varchar"                   return "res_varchar";
"true"                      return "res_true";
"false"                     return "res_false";
"null"                      return "res_null";


// encapsular sentencias
"begin"                     return "res_begin";
"end"                       return "res_end";

// declarar variables
"declare"                   return "res_declare";

// asignar valor de variable
"set"                       return "res_set";


/*------------------------ DDL ------------------------*/
"table"                     return "res_table";
"create"                    return "res_create";
"alter"                     return "res_alter";
"add"                       return "res_add";
"drop"                      return "res_drop";
"column"                    return "res_column";
"rename"                    return "res_rename";
"to"                        return "res_to";


/*------------------------ DML ------------------------*/
"insert"                    return "res_insert";
"into"                      return "res_into";
"values"                    return "res_values";
"select"                    return "res_select";
"from"                      return "res_from";
"where"                     return "res_where";
"as"                        return "res_as";
"update"                    return "res_update";
"truncate"                  return "res_truncate";
"delete"                    return "res_delete";

/*------------------------ Casteo de datos ------------------------*/
"cast"                      return "res_cast";

/*------------------------ Sentencias de control ------------------------*/
//if
"if"                        return "res_if";
"else"                      return "res_else";
//case
"case"                      return "res_case";
"when"                      return "res_when";
"then"                      return "res_then";
/*------------------------ Sentencias ciclicas ------------------------*/
//while
"while"                     return "res_while";
//for
"for"                       return "res_for";
"in"                        return "res_in";
/*------------------------ Sentencias de transferencia ------------------------*/
"break"                     return "res_break";
"continue"                  return "res_continue";

/*------------------------ funciones ------------------------*/
"function"                  return "res_function";
"returns"                   return "res_returns";
"return"                    return "res_return";
/*------------------------ Metodos ------------------------*/
"procedure"                 return "res_procedure";

/*------------------------ funciones nativas ------------------------*/
"print"                     return "res_print";
"lower"                     return "res_lower";
"upper"                     return "res_upper";
"round"                     return "res_round";
"length"                    return "res_length";
"truncate"                  return "res_truncate";
"typeof"                    return "res_typeof";

/*------------------------ Tokens ------------------------*/

// signos de agrupacion
"("                         return "tk_par_left";
")"                         return "tk_par_right";
"{"                         return "tk_bra_left";
"}"                         return "tk_bra_right";
";"                         return "tk_semicolon";

// operadores aritmeticos
"+"                         return "tk_plus";
"-"                         return "tk_minus";
"*"                         return "tk_mult";
"/"                         return "tk_div";
"%"                         return "tk_mod";

// operadores relacionales
"=="                        return "tk_eq";
"!="                        return "tk_neq";
"<="                        return "tk_lte";
">="                        return "tk_gte";
"<"                         return "tk_lt";
">"                         return "tk_gt";
"="                         return "tk_assign";

//operadores logicos
"AND"                       return "tk_and";
"OR"                        return "tk_or";
"NOT"                       return "tk_not";

//asignacion de variables
"@"                         return "tk_arroba";

[ \r\t]+                    {}
\n                          {}

\"[^\"]*\"                  { yytext = yytext.substr(1, yyleng-2); return 'VARCHAR'; }

[0-9]+\b                    return 'INTEGER';
[a-zA-Z][a-zA-Z0-9]*        return 'IDENTIFIER';

<<EOF>>                     return 'EOF';

.                           { console.log(`Lexical error ${yytext} in [${yylloc.first_line}, ${yylloc.first_column}]`); }

/lex

/*------------------------ Operators Precedence ------------------------*/
%left   'tk_div' 'tk_mult'
%left   'tk_plus' 'tk_minus'
%left   'tk_eq' 'tk_neq' 'tk_lt' 'tk_lte' 'tk_gt' 'tk_gte'
%right  'tk_not'
%left   'tk_and'
%left   'tk_or'


/*------------------------ Grammar Definition ------------------------*/

%start ini

%%

    ini : instructions EOF                                              { return $1; }
    ;

    instructions : instructions instruction                             { $1.push($2); $$ = $1; }
                 | instruction                                          { $$ = $1 === null ? [] : [$1]; }
    ;

    instruction : print tk_semicolon                                    { $$ = $1; }
                | error tk_semicolon                                    { errors.push(`Sintactic error ${yytext} in [${this._$.first_line}, ${this._$.first_column}]`); $$ = null; }
    ;

    
    print : res_print expression                                        { $$ = new Print($2, @1.first_line, @1.first_column); }
    ;

    expression : IDENTIFIER                                             { $$ = new Identifier($1, @1.first_line, @1.first_column); }
               | VARCHAR                                                { $$ = new Primitive($1, type.VARCHAR, @1.first_line, @1.first_column); }
               | INTEGER                                                { $$ = new Primitive($1, type.INT, @1.first_line, @1.first_column); }
               | tk_par_left expression tk_par_right                    { $$ = $2; }
    ;