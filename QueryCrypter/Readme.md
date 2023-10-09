Comando para actualizar jison
jison C:\\Users\\1998j\\OneDrive\\Desktop\\compi1\\proyecto2\\QueryCrypter\\server\\src\\Analyzer\\grammar.jison

Correccion de importaciones y exportaciones
// Importations
import { type, arithmeticOperator, relationalOperator } from "./tools/Type.js";
import { Arithmetic } from './expressions/Arithmetic.js';
import { Relational } from './expressions/Relational.js';
import Primitive from './expressions/Primitive.js';
import { Identifier } from './expressions/Identifier.js';
import { Print } from './instructions/Print.js';
import { Declaration } from './instructions/Declaration.js';
import { If } from './instructions/If.js';


// Variables definition and functions

export let errors = [];

export const clean_errors = () => {
    errors = [];
}

export var grammar = (function(){