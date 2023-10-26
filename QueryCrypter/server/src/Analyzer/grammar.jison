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
    import { Table } from './instructions/Table.js';
    import { AlterTable } from './instructions/AlterTable.js';
    import { DropTable } from './instructions/DropTable.js';
    //DML
    import { Insert } from './instructions/Insert.js';
    import { Select } from './instructions/Select.js';
    import { SelectConditional } from './instructions/SelectConditional.js';
    import { TruncateTable } from './instructions/TruncateTable.js';
    import { Update } from './instructions/Update.js';
    import { Delete } from './instructions/Delete.js';
    // Errores
    import {jsPDF} from "jspdf";
    import 'jspdf-autotable';
    import { randomUUID } from "crypto";
%}

%{

// VARIABLES, DEFINICIONES Y FUNCIONES

    let globals, db, fn, md , u1, u2 = [];

    let tableErrores = [];
    let tableTokens = [];
    let tableSimb = [];

    function generarTabla(tableData,name){
        // Crear un nuevo documento PDF
        const doc = new jsPDF();
        // Configurar propiedades de la tabla
        const tableConfig = {
            startY: 20,
        };

        // Crear la tabla
        doc.autoTable({
            head: [tableData[0]],
            body: tableData.slice(1),
            startY: tableConfig.startY,
        });

        // Guardar o mostrar el PDF
        doc.save(`${name}_${randomUUID()}.pdf`);
    }

    export const clean = () => {
        
        globals = [];
        db = [];
        fn = [];
        md = [];
        u1 = [];
        u2 = [];
        tableErrores.unshift(['Tipo de error', 'Descripcion', 'Linea','Columna']);
        tableTokens.unshift(['Token','Linea','Columna']);
        tableSimb.unshift(['Identificador','Tipo','Tipo','Entorno','Linea','Columna']);
        generarTabla(tableErrores,"Errores");
        generarTabla(tableTokens,"Tokens");
        generarTabla(tableSimb,"Simbolos");
        tableErrores = [];
        tableTokens = [];
        tableSimb = [];
    }

    let a,b,c,d,e1,condicion, incremento, ms;

    function parseDate(dateString) {
        const [year, month, day] = dateString.split('-').map(Number);
        return new Date(year, month - 1, day); // Meses en JavaScript comienzan desde 0 (enero).
    }


%}

// DEFINICION DE ANALISIS LEXICO
%lex 
%options case-insensitive

%%

// elementos a ignorar
\s+                                 // espacios
[ \t\r\n\f]                         /* Ignorar espacios en blanco */
"--".*                              // comentario de una linea
\/\*[^*]*\*+([^/*][^*]*\*+)*\/      // comentario de varias líneas

// PALABRAS RESERVADAS

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

.                           { tableErrores.push(['Lexical error',`${yytext}`,`${yylloc.first_line}`,`${yylloc.first_column}`]); }

/lex

// OPERADORES DE PRECEDENCIA
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




// DEFINICION DE GRAMATICA
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
        | error tk_semicolon                                        { tableErrores.push(['Sintatic error',`${yytext}`,`${this._$.first_line}`,`${this._$.first_column}`]); $$ = null; }
    ;

// REGLAS
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
            $3.id ? a = $3.id : a = $3.value;

            tableSimb.push([a,"identificador",`${$3.type}`,"Create table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$6}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`]);
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
        res_alter res_table expression alterations tk_semicolon     
        {
            tableSimb.push([`${$3.id}`,"identificador",`${$3.type}`,"Alter table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            $$ = $4; 
        }
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
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
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
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
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
            tableSimb.push([`${$3.id}`,"identificador",`${$3.type}`,"Alter table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
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
            tableSimb.push([`${$3.id}`,"identificador",`${$3.type}`,"Alter table",`${@1.first_line}`,`${@1.first_column}`]);
            tableSimb.push([`${$5.id}`,"identificador",`${$5.type}`,"Alter table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
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
            tableSimb.push([`${$3.id}`,"identificador",`${$3.type}`,"Drop table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
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
        insertDML                                                   { $$ = $1; }        
        | selectDML                                                 { $$ = $1; }
        | updateDML                                                 { $$ = $1; }
        | truncateDML                                               { $$ = $1; }
        | deleteDML                                                 { $$ = $1; }

    ;
// INSERT
    insertDML :
        res_insert res_into expression tk_par_left parametrosT tk_par_right res_values tk_par_left parametrosV tk_par_right tk_semicolon
        {
            tableSimb.push([`${$3.id}`,"identificador",`${$3.type}`,"Insert table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$6}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$8}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$10}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$11}`,`${@1.first_line}`,`${@1.first_column}`])

            ms="";
            if(db.some(vari => vari.name === d.name)){
                a = db.find(vari => vari.name === d.name);
                let contador = 0;
                let i = 0;
                let valor = [];
                let vl;
                while(contador < $5.length){
                    let item = a.instructions.find(vari => vari.id === $5[i])
                    if(item){
                        ms += `En la tabla ${a.name} se inserto ${item.id} con el valor de ${$9[i].value}\n`;
                        vl = new Identifier(item.id, @1.first_line, @1.first_column);
                        vl.value = $9[i]
                        i++
                        contador ++
                        valor.push(vl);
                    }
                }
                a.rows.push(valor);
            }
            $$ = new Insert(d,ms,@1.first_line,@1.first_column);
        }
    ;

// SELECT
    selectDML :
        res_select parametrosT res_from expression tk_semicolon
        {
            tableSimb.push([`${$4.id}`,"identificador",`${$4.type}`,"Select table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            if(db.some(vari => vari.name === d.name)){
                a = db.find(vari => vari.name === d.name);
                ms=`Valores especificados de la tabla ${a.name}\n`;
                a.rows.forEach(row => {
                    let contador = 0;
                    let i = 0;
                    while(contador < $2.length){
                        let item = row.find(vari => vari.id === $2[i])
                        if(item){
                            ms += `El valor de ${item.id} es ${item.value.value}\n`;
                            i++
                            contador ++
                        }
                    }
                    ms += '\n';
                });
                
            }
            $$ = new Select(d,ms, @1.first_line, @1.first_column);
        }
        | res_select tk_mult res_from expression tk_semicolon
        {
            tableSimb.push([`${$4.id}`,"identificador",`${$4.type}`,"Select table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            if(db.some(vari => vari.name === d.name)){
                a = db.find(vari => vari.name === d.name);
                ms=`Todos los valores de la tabla ${a.name}\n`;
                a.rows.forEach(row => {
                    row.forEach(item => {
                        ms += `El valor de ${item.id} es ${item.value.value}\n`
                    })
                    ms+='\n';
                })
            }
            $$ = new Select(d,ms, @1.first_line, @1.first_column);
        }
        | res_select parametrosT res_from expression res_where expression tk_semicolon
        {
            tableSimb.push([`${$4.id}`,"identificador",`${$4.type}`,"Select table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
            if(db.some(vari => vari.name === d.name)){
                e1.id ? e1 = e1.id : e1 = e1.value;
                e2.id ? e2 = e2.id : e2 = e2.value;
                $$ = new SelectConditional(d,$6,$2,e1,e2, @1.first_line, @1.first_column);
            }
        }
    ;

// UPDATE
    updateDML :
        res_update expression res_set sets res_where expression tk_semicolon
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
            if(db.some(vari => vari.name === d.name)){
                a = db.find(vari => vari.name === d.name);
                $$ = new Update(a, @1.first_line, @1.first_column);
            }
        }
    ;
    sets :
        sets tk_coma expression
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            u1.push($3.exp1.value);
            u2.push($3.exp2.value);
            $$ = $3;
        }
        | expression
        {
            u1.push($1.exp1.value);
            u2.push($1.exp2.value);
            $$ = $1;
        }
    ;
// TRUNCATE
    truncateDML :
        res_truncate res_table expression tk_semicolon
        {
            tableSimb.push([`${$3.id}`,"identificador",`${$3.type}`,"Truncate table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
            a = db.find(vari => vari.name === d.name);
            a.rows = [];
            ms = `Los registros de la tabla ${a.name} han sido eliminados`;
            $$ = new TruncateTable(d,ms, @1.first_line, @1.first_column);
        }
    ;
// DELETE
    deleteDML :
        res_delete res_from expression res_where expression tk_semicolon
        {
            tableSimb.push([`${$3.id}`,"identificador",`${$3.type}`,"Delete table",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$6}`,`${@1.first_line}`,`${@1.first_column}`])
            e1.id ? e1 = e1.id : e1 = e1.value;
            let borrar;
            let nuevoArray = [];
            $5.exp1 = e1;
            a = db.find(vari => vari.name === d.name);
            a.rows.forEach(row => {
                let s = row.find((item) => item.id === e1)
                $5.exp1 = s.value;
                let flag = false;
                switch ($5.operator) {
                    case "<":
                        flag = Number($5.exp1.value) < Number($5.exp2.value);
                    break;
                    case ">":
                        flag = Number($5.exp1.value) > Number($5.exp2.value);
                    break;
                    case "<=":
                        flag = Number($5.exp1.value) <= Number($5.exp2.value);
                    break; 
                    case ">=":
                        flag = Number($5.exp1.value) >= Number($5.exp2.value);
                    break;
                    case "!=":
                        flag = Number($5.exp1.value) != Number($5.exp2.value);
                    break;
                    case "==":
                        flag = Number($5.exp1.value) === Number($5.exp2.value);
                    break;
                }
                
                if (flag) {
                    borrar = row;
                }
                if(borrar){
                    nuevoArray = a.rows.filter(row => row != borrar)
                    
                }
            })
            a.rows = nuevoArray
            $$ = new Delete(d, @1.first_line, @1.first_column);
        }
        
    ;

//+ PARAMETROS
    parametrosT :
        parametrosT tk_coma expression    
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            $3.id ? a = $3.id : a = $3.value
            $1.push(a); $$ = $1; 
        }
        | expression             
        { 
            $1.id ? a = $1.id : a = $1.value
            $$ = a === null ? [] : [a]; 
        }
    ;

    parametrosV :
        parametrosV tk_coma expression    
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            $3.id ? a = $3.id.value : a = $3
            $1.push(a); $$ = $1; 
        }
        | expression             
        { 
            $1.id ? a = $1.id.value : a = $1
            $$ = a === null ? [] : [a]; 
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
                tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$6}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
                $$ = new If($2, $5, undefined, undefined, @1.first_line, @1.first_column); 
            }
        | res_if expression res_then instructions res_else instructions res_end res_if tk_semicolon 
            {
                tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$8}`,`${@1.first_line}`,`${@1.first_column}`])
                tableTokens.push([`${$9}`,`${@1.first_line}`,`${@1.first_column}`])
                $$ = new If($2, $4, $6, undefined, @1.first_line, @1.first_column); 
            }
    ;

    case :
        res_case expression cases res_end tk_semicolon              
        { 
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            $$ = new Cases($3,@1.first_line,@1.first_column); 
        }
        | res_case cases res_end tk_semicolon                       
        { 
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
            $$ = new Cases($2,@1.first_line,@1.first_column); 
        }
    ;

    cases :
        cases caseI                                                 { $1.push($2); $$ = $1; }
        | caseI                                                     { $$ = $1 === null ? [] : [$1]; }
        
    ;

    caseI :
        res_when expression res_then expression                   
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
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
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            a = new Relational($2, $2, relationalOperator.EQ, @1.first_line, @1.first_column); 
            $$ = new Case(a,$2,@1.first_line,@1.first_column); 
        }
    ;

// CICLOS
    while :
        res_while expression res_begin instructions res_end tk_semicolon 
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$6}`,`${@1.first_line}`,`${@1.first_column}`])
            condicion = $2;

            $$ = new While(condicion,incremento,$2,$4,@1.first_line,@1.first_column);

        }
    ;

    for :
        res_for expression res_in expression tk_coma expression res_begin instructions res_end tk_semicolon
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$9}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$10}`,`${@1.first_line}`,`${@1.first_column}`])
            $$ = new For($2,$4.value,$6.value,$8,@1.first_line,@1.first_column);
        }
    ;


//* FUNCIONES
    funciones :
        res_create res_function IDENTIFIER tk_par_left parametrosEntrada tk_par_right res_returns instructions
    ;

//* METODOS
    metodos :
        res_create res_procedure IDENTIFIER parametrosEntrada res_as encapsular
    ;
// LLAMADAS
    llamadas :
        res_select IDENTIFIER tk_par_left parametros tk_par_right
        | res_set tk_arroba IDENTIFIER tk_eq IDENTIFIER tk_par_left parametros tk_par_right
    ;
    
//+ DECLARACION DE VARIABLES GLOBALES
    declaraciones :
        declaraciones tk_coma declaracion                           
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            $1.push($3); $$ = $1; 
        }
        | declaracion                                               { $$ = $1 === null ? [] : [$1]; }
    ;

    declaracion : 
        tk_arroba expression tipos                                  
        { 
            tableSimb.push([`${$2.id}`,"variable global",`${$2.type}`,"Declaration",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            globals.push($2); $$ = $2;
        }
        | tk_arroba expression tipos res_default expression         
        { 
            tableSimb.push([`${$2.id}`,"variable global",`${$2.type}`,"Declaration",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
            a = $2; a.value = $5;  globals.push(a); $$ = a;
        }
        | tk_arroba expression tipos tk_eq expression
        {
            tableSimb.push([`${$2.id}`,"variable global",`${$2.type}`,"Declaration",`${@1.first_line}`,`${@1.first_column}`]);

            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`])
            a = $2; a.value = $5;  globals.push(a); $$ = a;
        }
    ;
//+ ASIGNACION DE VALORES A VARIABLES GLOBALES
    asignacion :
        res_set expression tk_assign expression           
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            incremento = $4;
            for (let i = 0; i < globals.length; i++) {
                 if (globals[i].id === $2.id) {
                    //console.log("entro al set -> $5",$5);
                    globals[i].value = $4;
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
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            $2.id ? a = $2.value : a = $2; 
            $$ = new Print(a, @1.first_line, @1.first_column); 
        }
    ;
// TRANSFORMAR A MINUSCULAS
    lower :
        res_select res_lower expression       
        { 
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            $3.id ? a = $3.value : a = $3;
            $$ = new Lower(a, @1.first_line, @1.first_column); 
        }
    ;
// TRANSFORMAR A MAYUSCULAS
    upper :
        res_select res_upper expression       
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            $3.id ? a = $3.value : a = $3; 
            $$ = new Upper(a, @1.first_line, @1.first_column); 
        }
    ;
// REDONDEAR UN NUMERO
    round :
        res_select res_round tk_par_left expression tk_coma INTEGER tk_par_right    
        { 
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
            $4.id ? a = $4.value : a = $4;
            $6.id ? b = $6.value : b = $6;
            $$ = new Round(a,b, @1.first_line, @1.first_column); 
        }
    ;
// TAMAÑO DE LA CADENA DE TEXTO
    length :
        res_select res_length expression   
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            
            $3.id ? a = $3.value : a = $3; 
            $$ = new Len(a, @1.first_line, @1.first_column); 
        }
    ;
// REDUCIR UN NUMERO
    truncate :
        res_select res_truncate tk_par_left expression tk_coma INTEGER tk_par_right
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$5}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$7}`,`${@1.first_line}`,`${@1.first_column}`])
            $4.id ? a = $4.value : a = $4;
            $6.id ? b = $6.value : b = $6;
            $$ = new Truncate(a,b, @1.first_line, @1.first_column); 
        }
    ;
// CONOCER EL TIPO DE DATO DE UN ELEMENTO
    typeof :
        res_select res_typeof expression   
        { 
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`])
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`])
            $3.id ? a = $3.value : a = $3;
            $$ = new Typeof(a, @1.first_line, @1.first_column); 
        }
    ;
// TIPOS DE DATOS
    tipos :
        res_int                                                     { $$ = $1; tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]); }
        | res_double                                                { $$ = $1; tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);}
        | res_date                                                  { $$ = $1; tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);}
        | res_varchar                                               { $$ = $1; tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);}
        | res_boolean                                               { $$ = $1; tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);}
        | res_null                                                  { $$ = $1; tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);}
    ;

//+ EXPRESIONES GENERALES (TIPOS DE DATOS, OPERACIONES ARITMETICAS Y RELACIONALES)
    expression : 
    // ARITMETICAS
        expression tk_plus expression                          
        { 
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.PLUS, @1.first_line, @1.first_column); 
        }
        | expression tk_minus expression                         
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]); 
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.MINUS, @1.first_line, @1.first_column); 
        }
        | expression tk_mult expression                          
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.MULT, @1.first_line, @1.first_column); 
        }
        | expression tk_div expression                           
        { 
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.DIV, @1.first_line, @1.first_column); 
        }
        | expression tk_mod expression                           
        { 
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            $$ = new Arithmetic(a, b, arithmeticOperator.MOD, @1.first_line, @1.first_column); 
        }
    // RELACIONALES
        | expression tk_eq expression                                 
        {  
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]); 
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            e1 = $1;
            $$ = new Relational(a, b, relationalOperator.EQ, @1.first_line, @1.first_column); 
        }
        | expression tk_neq expression                              
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            e1 = $1
            $$ = new Relational(a, b, relationalOperator.NEQ, @1.first_line, @1.first_column); 
        }
        | expression tk_lte expression                              
        { 
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3;
            e1 = $1
            $$ = new Relational(a, b, relationalOperator.LTE, @1.first_line, @1.first_column); 
        }
        | expression tk_gte expression                              
        {
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            e1 = $1
            $$ = new Relational(a, b, relationalOperator.GTE, @1.first_line, @1.first_column); 
        }
        | expression tk_lt expression                               
        {   
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            e1 = $1
            $$ = new Relational(a, b, relationalOperator.LT, @1.first_line, @1.first_column); 
        }
        | expression tk_gt expression                               
        {   
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            $1.id ? a = $1.value : a = $1;
            $3.id ? b = $3.value : b = $3; 
            e1 = $1
            $$ = new Relational(a, b, relationalOperator.GT, @1.first_line, @1.first_column); 
        }
    // DATOS
        | IDENTIFIER                                                
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            if(db.some(vari => vari.name === $1)){
                d = db.find(vari => vari.name === $1);
            }
            $$ = new Identifier($1, @1.first_line, @1.first_column); 
            
        }
        | tk_arroba IDENTIFIER
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            a = globals.find(vari => vari.id === $2);
            c = a;
            $$ = a;
        }
        | VARCHAR                                                   
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = new Primitive($1, type.VARCHAR, @1.first_line, @1.first_column); 
        }
        | INTEGER                                                   
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = new Primitive($1, type.INT, @1.first_line, @1.first_column); 
        }
        | INTEGER tk_punto INTEGER                                  
        { 
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = new Primitive(parseFloat($1+$2+$3), type.DOUBLE, @1.first_line, @1.first_column); 
        }
        | DATE                                                      
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = new Primitive(parseDate($1), type.DATE, @1.first_line, @1.first_column); 
        }
        | res_null                                                  
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = new Primitive($1, type.NULL, @1.first_line, @1.first_column); 
        }
        | booleans                                                  { $$ = $1; }
        | res_cast tk_par_left expression res_as tipos tk_par_right
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$2}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$4}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$6}`,`${@1.first_line}`,`${@1.first_column}`]);
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
        | tk_par_left expression tk_par_right                       
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            tableTokens.push([`${$3}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = $2; 
        }
    ;

    booleans :
        res_true                                                    
        {
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = new Primitive($1, type.BOOLEAN, @1.first_line, @1.first_column); 
        }
        | res_false                                                 
        { 
            tableTokens.push([`${$1}`,`${@1.first_line}`,`${@1.first_column}`]);
            $$ = new Primitive($1, type.BOOLEAN, @1.first_line, @1.first_column); 
        }
    ;