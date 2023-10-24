/*
    2023 SEGUNDO SEMESTRE
    PROYECTO 2 CURSO COMPILADORES 1 SECCION C
    JOSUE ALEJANDRO PEREZ BENITO
    201712602
    2995019300101@ingenieria.usac.edu.gt
*/

%{
    //Importaciones
    import { type, arithmeticOperator, relationalOperator } from "./tools/Type.js";
    import { Arithmetic } from './expressions/Arithmetic.js';
    import { Relational } from './expressions/Relational.js';
    import Primitive from './expressions/Primitive.js';
    import { Identifier } from './expressions/Identifier.js';
    //Funciones nativas
    import { Print } from './instructions/Print.js';
    import { Lower } from './instructions/Lower.js';
    import { Upper } from './instructions/Upper.js';
    import { Round } from './instructions/Round.js';
    import { Len } from './instructions/Len.js';
    import { Truncate } from './instructions/Truncate.js';
    import { Typeof } from './instructions/Typeof.js';
    //Manejo de variables
    import { Declarations } from './instructions/Declarations.js';
    //Sentencias de control
    import { If } from './instructions/If.js';
    import { Case } from './instructions/Case.js';
    import { Cases } from './instructions/Cases.js';
    //Sentencias ciclicas
    import { While } from './instructions/While.js';
    import { For } from './instructions/For.js';
    //funciones
    //metodos
    //DDL
    import { Table } from './instructions/Table.js'
    import { AlterTable } from './instructions/AlterTable.js'
    import { DropTable } from './instructions/DropTable.js'
    // Errores
    import fs from 'fs';
%}

%{

    // Variables definition and functions

    let globals, db = [];

    const nombreArchivo = 'erroresLexicos.txt';

    export const clean = () => {
        try {
            fs.writeFile(nombreArchivo, mensaje, (err) => { });
        } catch (error) {}
        globals = [];
        db = [];
        mensaje = "";
    }


    let a,b,c,d,condicion, incremento, mensaje;

    function Errores(messages) {
        if(messages===undefined){}else{
        mensaje += messages + '\n'
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
"boolean"                   return "res_boolean";
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
[0-9]+(-[0-9]{2}){2}        return 'DATE';
\"[^\"]*\"                  { yytext = yytext.substr(1, yyleng-2); return 'VARCHAR'; }
\'[^\']*\'                  { yytext = yytext.substr(1, yyleng-2); return 'VARCHAR'; }


<<EOF>>                     return 'EOF';

.                           { Errores(`Lexical error -> ${yytext} in [${yylloc.first_line}, ${yylloc.first_column}]`); }

/lex

/*------------------------ Operators Precedence ------------------------*/
//nivel 1
%left   'tk_div' 'tk_mult' 'tk_mod'
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
        | error tk_semicolon                                        { Errores(`Sintactic error -> ${yytext} in [${this._$.first_line}, ${this._$.first_column}]`); $$ = null; }
    ;


    /* encapsular : 
        res_begin reglas res_end tk_semicolon                 { $$ = $2; }
    ; */

    reglas : 
        funcionesNativas                                            { $$ = $1; }
        | res_declare declaraciones tk_semicolon                    { $$ = new Declarations($2,@1.first_line,@1.first_column); }
        | asignacion tk_semicolon                                   { $$ = $1; }
        | sentenciasGenerales                                       { $$ = $1; }
        | methodsDDL                                                { $$ = $1; }
        | methodsDML                                                { $$ = $1; }
    ;
// DATA DEFINITION LENGUAGE
    methodsDDL :
        createDDL                                                   { $$ = $1; db.push($1); }
        | alterDDL                                                  { $$ = $1; }
        | dropDDL                                                   { $$ = $1; }
    ;
// CREAR TABLA
    createDDL :
        res_create res_table expression tk_par_left columns tk_par_right tk_semicolon
        { 
            $3.id ? a = $3.id : a = $3.value
            $$ =  new Table(a,$5,@1.first_line,@1.first_column);
        }
    ;

    columns :
        columns tk_coma column      { $1.push($3); $$ = $1;}
        | column                    { $$ = $1 === null ? [] : [$1];}
    ;

    column :
        expression tipos            
        {
            if($2 === "int"){
                $1.type = type.INT;
                $$ = $1;
            }
            else if($2 === "double"){
                $1.type = type.DOUBLE;
                $$ = $1;
            }
            else if($2 === "date"){
                $1.type = type.DATE;
                $$ = $1;
            }
            else if($2 === "varchar"){
                $1.type = type.VARCHAR;
                $$ = $1;
            }
            else if($2 === "boolean"){
                $1.type = type.BOOLEAN;
                $$ = $1;
            }
            else if($2 === "null"){
                $1.type = type.NULL;
                $$ = $1;
            }
        }
    ;

// MODIFICAR TABLA
    alterDDL :
        res_alter res_table expression alterations tk_semicolon     { $$ = $4; }
    ;

    alterations :
        addColumn                                                   { $$ = $1; }
        | dropColumn                                                { $$ = $1; }
        | renameTable                                               { $$ = $1; }
        | renameColumn                                              { $$ = $1; }
    ;
// AÑADIR UNA COLUMNA A UNA TABLA
    addColumn :
        res_add column
        {
            if(db.some(vari => vari.name === d.name)){
                let a = db.find(vari => vari.name === d.name);
                a.instructions.push($2);
                $$ = new AlterTable(d,`Se añadio la columna ${$2.id} a ${d.name}`,@1.first_line,@1.first_column);
            }
        }
    ;
// ELIMINAR UNA COLUMNA DE UNA TABLA
    dropColumn :
        res_drop res_column expression
        {
            if(db.some(vari => vari.name === d.name)){
                let a = db.find(vari => vari.name === d.name);
                const index = a.instructions.findIndex(objeto => objeto.id === $3.id);
                const nombre = a.instructions.find(objeto => objeto.id === $3.id);
                a.instructions.splice(index,1);
                $$ = new AlterTable(d,`Se elimino la columna ${nombre.id} de ${d.name}`,@1.first_line,@1.first_column);
            }
        }
    ;
// RENOMBRAR UNA TABLA
    renameTable :
        res_rename res_to expression
        {
            if(db.some(vari => vari.name === d.name)){
                let a = db.find(vari => vari.name === d.name);
                const name = a.name
                a.name = $3.id;
                $$ = new AlterTable(d,`Se cambio el nombre ${name} a ${a.name}`,@1.first_line,@1.first_column);
            }
        }
    ;
// RENOMBRAR UNA COLUMNA DE UNA TABLA
    renameColumn :
        res_rename res_column expression res_to expression
        {
            if(db.some(vari => vari.name === d.name)){
                let a = db.find(vari => vari.name === d.name);
                const index = a.instructions.findIndex(objeto => objeto.id === $3.id);
                b = a.instructions[index].id;
                a.instructions[index].id = $5.id;
                $$ = new AlterTable(d,`Se cambio el nombre de la columna ${b} a ${$5.id}`,@1.first_line,@1.first_column);
            }
        }
    ;

// ELIMINAR TABLA
    dropDDL :
        res_drop res_table expression tk_semicolon
        {
            const nombre = db.find(vari => vari.name === d.name);
            if(db.some(vari => vari.name === d.name)){
                const index = db.findIndex(vari => vari.name === d.name);
                db.splice(index,1);
            }
            $$ = new DropTable(nombre.name,@1.first_line,@1.first_column);
        }
    ;


// DATA MANIPULATION LANGUAGE
    methodsDML :
        insertDML
        | selectDML
        | updateDML
        | truncateDML
        | deleteDML
    ;
//INSERTAR
    insertDML :
        res_insert res_into expression tk_par_left parametros tk_par_right res_values tk_par_left parametros tk_par_right tk_semicolon
        {
            
            $$ = $3;
        }
    ;
// PARAMETROS
    parametros :
        parametros expression    
        {
            $2.id ? a = $2.id : a = $2.value
            $1.push(a); $$ = $1; 
        }
        | expression             
        { 
            $1.id ? a = $1.id : a = $1.value
            $$ = $1 === null ? [] : [$1]; 
        }
    ;


// SENTENCIAS CONDICIONALES Y CICLOS
    sentenciasGenerales :
        if                          { $$ = $1; }
        | case                      { $$ = $1; }
        | while                     { $$ = $1; }
        | for                       { $$ = $1; }
                   
    ;
// CONDICIONALES
    if :
        res_if expression res_then res_begin instructions res_end tk_semicolon 
            {
                $$ = new If($2, $5, undefined, undefined, @1.first_line, @1.first_column); 
            }
        | res_if expression res_then instructions res_else instructions res_end res_if tk_semicolon 
            { 
                $$ = new If($2, $4, $6, undefined, @1.first_line, @1.first_column); 
            }
    ;

    case :
        res_case expression cases res_end tk_semicolon              { $$ = new Cases($3,@1.first_line,@1.first_column); }
        | res_case cases res_end tk_semicolon                       { $$ = new Cases($2,@1.first_line,@1.first_column); }
    ;

    cases :
        cases caseI                                                 { $1.push($2); $$ = $1; }
        | caseI                                                     { $$ = $1 === null ? [] : [$1]; }
        
    ;

    caseI :
        res_when expression res_then expression                   
        {   
            if($2.type){
                a = new Relational(c.value, $2, relationalOperator.EQ, @1.first_line, @1.first_column);
                $$ = new Case(a,$4,@1.first_line,@1.first_column);
            } 
            else
            {
                $$ = new Case($2,$4,@1.first_line,@1.first_column);
            }
        }
        | res_else expression                                     
        {
            a = new Relational($2, $2, relationalOperator.EQ, @1.first_line, @1.first_column); 
            $$ = new Case(a,$2,@1.first_line,@1.first_column); 
        }
    ;

// CICLOS
    while :
        res_while expression res_begin instructions res_end tk_semicolon 
        {
            condicion = $2;

            $$ = new While(condicion,incremento,$2,$4,@1.first_line,@1.first_column);

        }
    ;

    for :
        res_for expression res_in expression tk_coma expression res_begin instructions res_end tk_semicolon
        {
            $$ = new For($2,$4.value,$6.value,$8,@1.first_line,@1.first_column);
        }
    ;


// FUNCIONES
    funciones :
        res_create res_function IDENTIFIER tk_par_left parametrosEntrada tk_par_right
    ;

// METODOS
    metodos :
        res_create res_procedure IDENTIFIER parametrosEntrada res_as encapsular
    ;
// LLAMADAS
    llamadas :
        res_select IDENTIFIER tk_par_left parametros tk_par_right
        | res_set tk_arroba IDENTIFIER tk_eq IDENTIFIER tk_par_left parametros tk_par_right
    ;
    
// DECLARACION DE VARIABLES GLOBALES
    declaraciones :
        declaraciones tk_coma declaracion                           { $1.push($3); $$ = $1; }
        | declaracion                                               { $$ = $1 === null ? [] : [$1]; }
    ;

    declaracion : 
        tk_arroba expression tipos                                  { globals.push($2); $$ = $2;}
        | tk_arroba expression tipos res_default expression         { a = $2; a.value = $5;  globals.push(a); /* console.log("globals -> ",globals,"a -> ",a); */ $$ = a;}
    ;
// ASIGNACION DE VALORES A VARIABLES GLOBALES
    asignacion :
        res_set tk_arroba expression tk_assign expression           
        {
            incremento = $5;
            for (let i = 0; i < globals.length; i++) {
                 if (globals[i].id === $3.id) {
                    //console.log("entro al set -> $5",$5);
                    globals[i].value = $5;
                    a = globals[i];
                    break;
                }
            }
            $$ = a;
        }
    ;


// FUNCIONES NATIVAS DEL LENGUAJE
    funcionesNativas:
        print tk_semicolon                                          { $$ = $1; }
        | lower tk_semicolon                                        { $$ = $1; }
        | upper tk_semicolon                                        { $$ = $1; }
        | round tk_semicolon                                        { $$ = $1; }
        | length tk_semicolon                                       { $$ = $1; }
        | truncate tk_semicolon                                     { $$ = $1; }
        | typeof tk_semicolon                                       { $$ = $1; }
    ;
// IMPRIMIR
    print : 
        res_print expression                                        
        {
            $2.id ? a = $2.value : a = $2; 
            $$ = new Print(a, @1.first_line, @1.first_column); 
        }
    ;
// TRANSFORMAR A MINUSCULAS
    lower :
        res_select res_lower tk_par_left expression tk_par_right       
        { 
            $4.id ? a = $4.value : a = $4;
            $$ = new Lower(a, @1.first_line, @1.first_column); 
        }
    ;
// TRANSFORMAR A MAYUSCULAS
    upper :
        res_select res_upper tk_par_left expression tk_par_right       
        {
            $4.id ? a = $4.value : a = $4; 
            $$ = new Upper(a, @1.first_line, @1.first_column); 
        }
    ;
// REDONDEAR UN NUMERO
    round :
        res_select res_round tk_par_left expression tk_coma INTEGER tk_par_right    
        { 
            $4.id ? a = $4.value : a = $4;
            $6.id ? b = $6.value : b = $6;
            $$ = new Round(a,b, @1.first_line, @1.first_column); 
        }
    ;
// TAMAÑO DE LA CADENA DE TEXTO
    length :
        res_select res_length tk_par_left expression tk_par_right   
        {
            $4.id ? a = $4.value : a = $4; 
            $$ = new Len(a, @1.first_line, @1.first_column); 
        }
    ;
// REDUCIR UN NUMERO
    truncate :
        res_select res_truncate tk_par_left expression tk_coma INTEGER tk_par_right
        {
            $4.id ? a = $4.value : a = $4;
            $6.id ? b = $6.value : b = $6;
            $$ = new Truncate(a,b, @1.first_line, @1.first_column); 
        }
    ;
// CONOCER EL TIPO DE DATO DE UN ELEMENTO
    typeof :
        res_select res_typeof tk_par_left expression tk_par_right   
        { 
            $4.id ? a = $4.value : a = $4;
            $$ = new Typeof(a, @1.first_line, @1.first_column); 
        }
    ;
// TIPOS DE DATOS
    tipos :
        res_int                                                     { $$ = $1; }
        | res_double                                                { $$ = $1; }
        | res_date                                                  { $$ = $1; }
        | res_varchar                                               { $$ = $1; }
        | res_boolean                                               { $$ = $1; }
        | res_null                                                  { $$ = $1; }
    ;

// EXPRESIONES GENERALES (TIPOS DE DATOS, OPERACIONES ARITMETICAS Y RELACIONALES)
    expression : 
        expression tk_plus expression                          
        { 
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.PLUS, @1.first_line, @1.first_column); 
        }
        | expression tk_minus expression                         
        { 
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.MINUS, @1.first_line, @1.first_column); 
        }
        | expression tk_mult expression                          
        {
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.MULT, @1.first_line, @1.first_column); 
        }
        | expression tk_div expression                           
        { 
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.DIV, @1.first_line, @1.first_column); 
        }
        | expression tk_mod expression                           
        { 
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.MOD, @1.first_line, @1.first_column); 
        }
        | expression tk_eq expression                                 
        {   
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Relational(a, b, relationalOperator.EQ, @1.first_line, @1.first_column); 
        }
        | expression tk_neq expression                              
        {
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            $$ = new Relational(a, b, relationalOperator.NEQ, @1.first_line, @1.first_column); 
        }
        | expression tk_lte expression                              
        { 
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Relational(a, b, relationalOperator.LTE, @1.first_line, @1.first_column); 
        }
        | expression tk_gte expression                              
        {
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            $$ = new Relational(a, b, relationalOperator.GTE, @1.first_line, @1.first_column); 
        }
        | expression tk_lt expression                               
        {   
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            $$ = new Relational(a, b, relationalOperator.LT, @1.first_line, @1.first_column); 
        }
        | expression tk_gt expression                               
        {   
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            $$ = new Relational(a, b, relationalOperator.GT, @1.first_line, @1.first_column); 
        }
        | IDENTIFIER                                                
        {
            if(globals.some(vari => vari.id === $1)){
                a = globals.find(vari => vari.id === $1);
                c = a;
                $$ = a;
            }else if(db.some(vari => vari.name === $1)){
                d = db.find(vari => vari.name === $1);
                //console.log("busco -> ",d);
                $$ = d;
            }
            else{
                $$ = new Identifier($1, @1.first_line, @1.first_column); 
            }
        }
        | VARCHAR                                                   { $$ = new Primitive($1, type.VARCHAR, @1.first_line, @1.first_column); }
        | INTEGER                                                   { $$ = new Primitive($1, type.INT, @1.first_line, @1.first_column); }
        | INTEGER tk_punto INTEGER                                  { $$ = new Primitive(parseFloat($1+$2+$3), type.DOUBLE, @1.first_line, @1.first_column); }
        | DATE                                                      { $$ = new Primitive(parseDate($1), type.DATE, @1.first_line, @1.first_column); }
        | res_null                                                  { $$ = new Primitive($1, type.NULL, @1.first_line, @1.first_column); }
        | booleans                                                  { $$ = $1; }
        | res_cast tk_par_left expression res_as tipos tk_par_right
        {
            $3.id? a = $3.value.value : a = $3.value
            if($5 === "int"){
                if($3.id){
                    for (let i = 0; i < globals.length; i++) {
                        if (globals[i].id === $3.id) {
                            globals[i].value = new Primitive(a, type.INT, @1.first_line, @1.first_column);
                            break;
                        }
                    }
                }
                $$ = new Primitive(a, type.INT, @1.first_line, @1.first_column);
            }
            else if($5 === "double"){
                if($3.id){
                    for (let i = 0; i < globals.length; i++) {
                        if (globals[i].id === $3.id) {
                            globals[i].value = new Primitive(a, type.DOUBLE, @1.first_line, @1.first_column);
                            break;
                        }
                    }
                }
                $$ = new Primitive(a, type.DOUBLE, @1.first_line, @1.first_column);
            }
            else if($5 === "date"){
                if($3.id){
                    for (let i = 0; i < globals.length; i++) {
                        if (globals[i].id === $3.id) {
                            globals[i].value = new Primitive(a, type.DATE, @1.first_line, @1.first_column);
                            break;
                        }
                    }
                }
                $$ = new Primitive(a, type.DATE, @1.first_line, @1.first_column);
            }
            else if($5 === "varchar"){
                if($3.id){
                    for (let i = 0; i < globals.length; i++) {
                        if (globals[i].id === $3.id) {
                            globals[i].value = new Primitive(a, type.VARCHAR, @1.first_line, @1.first_column);
                            break;
                        }
                    }
                }
                $$ = new Primitive(a, type.VARCHAR, @1.first_line, @1.first_column);
            }
            else if($5 === "boolean"){
                if($3.id){
                    for (let i = 0; i < globals.length; i++) {
                        if (globals[i].id === $3.id) {
                            globals[i].value = new Primitive(a, type.BOOLEAN, @1.first_line, @1.first_column);
                            break;
                        }
                    }
                }
                $$ = new Primitive(a, type.BOOLEAN, @1.first_line, @1.first_column);
            }
            else if($5 === "null"){
                if($3.id){
                    for (let i = 0; i < globals.length; i++) {
                        if (globals[i].id === $3.id) {
                            globals[i].value = new Primitive(a, type.NULL, @1.first_line, @1.first_column);
                            break;
                        }
                    }
                }
                $$ = new Primitive(a, type.NULL, @1.first_line, @1.first_column);
            }
        }
        | tk_par_left expression tk_par_right                       { $$ = $2; }
    ;

    booleans :
        res_true                                                    { $$ = new Primitive($1, type.BOOLEAN, @1.first_line, @1.first_column); }
        | res_false                                                 { $$ = new Primitive($1, type.BOOLEAN, @1.first_line, @1.first_column); }
    ;