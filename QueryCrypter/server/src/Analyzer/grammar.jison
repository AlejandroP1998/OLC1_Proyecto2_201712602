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
    import { Lower } from './instructions/Lower.js';
    import { Upper } from './instructions/Upper.js';
    import { Round } from './instructions/Round.js';
    import { Len } from './instructions/Len.js';
    import { Truncate } from './instructions/Truncate.js';
    import { Typeof } from './instructions/Typeof.js';
    import { Declaration } from './instructions/Declaration.js';
    import { If } from './instructions/If.js';

%}

%{
    // Variables definition and functions

    export let errors = [];

    export const clean_errors = () => {
        errors = [];
    }

    let globals = [];

    let a;

    function varG(nombre, tipo, valor) {
        this.nombre = nombre;
        this.tipo = tipo;
        this.valor = valor===null?"":valor;
    }

    function searchG(nombre,valor){
        const b = globals.find( vari => vari.nombre === nombre);
        if(b){
            b.valor = valor;
        }
    }

    function parseDate(dateString) {
        const [year, month, day] = dateString.split('-').map(Number);
        return new Date(year, month - 1, day); // Meses en JavaScript comienzan desde 0 (enero).
    }

%}

/*------------------------ Lexical Definition ------------------------*/

%lex 
%options case-insensitive

%%

// elementos a ignorar
\s+                                 // espacios
[ \t\r\n\f]                         /* Ignorar espacios en blanco */
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
"default"                   return "res_default";


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
"len"                       return "res_length";
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
","                         return "tk_coma";
"."                         return "tk_punto";

[ \r\t]+                    {}
\n                          {}


[0-9]+\b                    return 'INTEGER';
[a-zA-Z][a-zA-Z0-9]*        return 'IDENTIFIER';
\"[^\"]*\"                  { yytext = yytext.substr(1, yyleng-2); return 'VARCHAR'; }
\'[^\']*\'                  { yytext = yytext.substr(1, yyleng-2); return 'VARCHAR'; }

<<EOF>>                     return 'EOF';

.                           { console.log(`Lexical error ${yytext} in [${yylloc.first_line}, ${yylloc.first_column}]`); }

/lex

/*------------------------ Operators Precedence ------------------------*/
//nivel 1
%left   'tk_div' 'tk_mult'
//nivel 2
%left   'tk_plus' 'tk_minus'
//nivel 3
%left   'tk_eq' 'tk_neq' 'tk_lt' 'tk_lte' 'tk_gt' 'tk_gte'
//nivel 4
%right  'tk_not'
//nivel 5
%left   'tk_and'
//nivel 6
%left   'tk_or'


/*------------------------ Grammar Definition ------------------------*/

%start ini

%%

    ini : 
        instructions EOF                                            { return $1; }
    ;

    instructions : 
        instructions instruction                                    { $1.push($2); $$ = $1; }
        | instruction                                               { $$ = $1 === null ? [] : [$1]; }
    ;

    instruction : 
        reglas                                                      { $$ = $1; }
        | error tk_semicolon                                        { errors.push(`Sintactic error ${yytext} in [${this._$.first_line}, ${this._$.first_column}]`); $$ = null; }
    ;

    reglas : 
        encapsular                                                  { $$ = $1; }
        | regla                                                     { $$ = $1; }
    ;

    encapsular : 
        res_begin regla res_end tk_semicolon                        { $$ = $2; }
    ;

    regla : 
        funcionesNativas                                            { $$ = $1; }
        | res_declare declaraciones tk_semicolon                    { $$ = $2; }
        | asignacion tk_semicolon                                   { $$ = $1; }
    ;

    methodsDDL :
        createDDL
        | alterDDL
        | dropDDL
    ;

    methodsDML :
        insertDML
        | selectDML
        | updateDML
        | truncateDML
        | deleteDML
    ;

    casteos :
    ;

    sentenciasGenerales :
        if
        | case
        | while
        | for
    ;

    funciones :

    ;

    metodos :
    ;

    llamadas :
    ;
    

    declaraciones :
        declaraciones tk_coma declaracion                           { $1.push($3); $$ = $1; }
        | declaracion                                               { $$ = $1 === null ? [] : [$1]; }
    ;

    declaracion : 
        tk_arroba IDENTIFIER tipos                                  { $$ = $2; a = new varG($2, $3,null); globals.push(a);}
        | tk_arroba IDENTIFIER tipos res_default expression         { $$ = $2; a = new varG($2, $3, $5);  globals.push(a);}
    ;

    asignacion :
        res_set tk_arroba IDENTIFIER tk_assign expression           { $$ = $3; searchG($3,$5); }
    ;

    funcionesNativas:
        print tk_semicolon                                          { $$ = $1; }
        | lower tk_semicolon                                        { $$ = $1; }
        | upper tk_semicolon                                        { $$ = $1; }
        | round tk_semicolon                                        { $$ = $1; }
        | length tk_semicolon                                       { $$ = $1; }
        | truncate tk_semicolon                                     { $$ = $1; }
        | typeof tk_semicolon                                       { $$ = $1; }
    ;

    print : 
        res_print expression                                        { $$ = new Print($2, @1.first_line, @1.first_column); }
    ;

    lower :
        res_select res_lower tk_par_left expression tk_par_right       
                                                                    { $$ = new Lower($4, @1.first_line, @1.first_column); }
    ;

    upper :
        res_select res_upper tk_par_left expression tk_par_right       
                                                                    { $$ = new Upper($4, @1.first_line, @1.first_column); }
    ;

    round :
        res_select res_round tk_par_left expression tk_coma INTEGER tk_par_right    
                                                                    { $$ = new Round($4,$6, @1.first_line, @1.first_column); }
    ;

    length :
        res_select res_length tk_par_left expression tk_par_right   { $$ = new Len($4, @1.first_line, @1.first_column); }
    ;

    truncate :
        res_select res_truncate tk_par_left expression tk_coma INTEGER tk_par_right
                                                                    { $$ = new Truncate($4,$6, @1.first_line, @1.first_column); }
    ;

    typeof :
        res_select res_typeof tk_par_left expression tk_par_right   { $$ = new Typeof($4, @1.first_line, @1.first_column); }
    ;

    tipos :
        res_int                                                     { $$ = $1; }
        | res_double                                                { $$ = $1; }
        | res_date                                                  { $$ = $1; }
        | res_varchar                                               { $$ = $1; }
        | res_boolean                                               { $$ = $1; }
        | res_null                                                  { $$ = $1; }
    ;

    expression : 
        IDENTIFIER                                                  { $$ = new Identifier($1, @1.first_line, @1.first_column); }
        | VARCHAR                                                   { $$ = new Primitive($1, type.VARCHAR, @1.first_line, @1.first_column); }
        | INTEGER                                                   { $$ = new Primitive($1, type.INT, @1.first_line, @1.first_column); }
        | INTEGER tk_punto INTEGER                                  { $$ = new Primitive(parseFloat($1+$2+$3), type.DOUBLE, @1.first_line, @1.first_column); }
        | INTEGER tk_minus INTEGER tk_minus INTEGER                 { $$ = new Primitive(parseDate($1+$2+$3+$4+$5), type.DATE, @1.first_line, @1.first_column); }
        | tk_par_left expression tk_par_right                       { $$ = $2; }
    ;