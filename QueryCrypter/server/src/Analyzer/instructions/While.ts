import { Instruction } from "../abstract/Instruction.js";
import { Node } from "../abstract/Node.js";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";
import { Arithmetic } from "../expressions/Arithmetic.js";
import { Relational } from "../expressions/Relational.js";


export class While implements Instruction {

  public expression: Instruction;
  public instructions: Array<Instruction>;
  public row: number;
  public column: number;
  public condicion: Relational;
  public incremento: Arithmetic;
  public instO: Array<Instruction>;


  constructor(condicion: Relational, incremento: Arithmetic, expression: Instruction, instructions: Array<Instruction>, row: number, column: number) {
    this.expression = expression;
    this.instructions = instructions;
    this.instO = instructions;
    this.row = row;
    this.column = column;
    this.condicion = condicion;
    //console.log("🚀 ~ file: While.ts:29 ~ While ~ constructor ~ this.condicion:", this.condicion);
    this.incremento = incremento;
    //console.log("🚀 ~ file: While.ts:31 ~ While ~ constructor ~ this.incremento:", this.incremento);


  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {
    let flag: ReturnType = this.expression.getValue(tree, table);
    //console.log("flagWhile value -> ",flag.value);


    if (flag.value instanceof Exception) {
      // Semantic error
      return flag;
    }

    if (flag.type === type.BOOLEAN) {
      if (JSON.parse(String(flag.value))) {

        //@ts-ignore
        let contador = parseInt(this.incremento.exp1.value, 10);
        //@ts-ignore
        let incremento = parseInt(this.incremento.exp2.value, 10);
        //@ts-ignore
        let comparador = parseInt(this.condicion.exp2.value, 10);
        let operador = this.condicion.operator;
        let operadorI = this.incremento.operator;
        let arrayOriginal = this.instructions;
        switch (operador) {
          case "<":
            while (contador < comparador) {
              if (operadorI === "+") {
                contador = contador + incremento;
              } else if (operadorI === "-") {
                contador = contador - incremento;
              } else if (operadorI === "/") {
                contador = contador / incremento;
              } else if (operadorI === "*") {
                contador = contador * incremento;
              } else if (operadorI === "%") {
                contador = contador % incremento;
              }
              if (contador < comparador) {
                this.instructions = this.instructions.concat(arrayOriginal);
              }

            }
            break;
          case ">":
            while (contador > comparador) {
              if (operadorI === "+") {
                contador = contador + incremento;
              } else if (operadorI === "-") {
                contador = contador - incremento;
              } else if (operadorI === "/") {
                contador = contador / incremento;
              } else if (operadorI === "*") {
                contador = contador * incremento;
              } else if (operadorI === "%") {
                contador = contador % incremento;
              }
              if (contador > comparador) {
                this.instructions = this.instructions.concat(arrayOriginal);
              }

            }
            break;
          case "<=":
            while (contador <= comparador) {
              if (operadorI === "+") {
                contador = contador + incremento;
              } else if (operadorI === "-") {
                contador = contador - incremento;
              } else if (operadorI === "/") {
                contador = contador / incremento;
              } else if (operadorI === "*") {
                contador = contador * incremento;
              } else if (operadorI === "%") {
                contador = contador % incremento;
              }
              if (contador <= comparador) {
                this.instructions = this.instructions.concat(arrayOriginal);
              }

            }
            break; case ">=":
            while (contador >= comparador) {
              if (operadorI === "+") {
                contador = contador + incremento;
              } else if (operadorI === "-") {
                contador = contador - incremento;
              } else if (operadorI === "/") {
                contador = contador / incremento;
              } else if (operadorI === "*") {
                contador = contador * incremento;
              } else if (operadorI === "%") {
                contador = contador % incremento;
              }
              if (contador >= comparador) {
                this.instructions = this.instructions.concat(arrayOriginal);
              }

            }
            break;
          case "!=":
            while (contador != comparador) {
              if (operadorI === "+") {
                contador = contador + incremento;
              } else if (operadorI === "-") {
                contador = contador - incremento;
              } else if (operadorI === "/") {
                contador = contador / incremento;
              } else if (operadorI === "*") {
                contador = contador * incremento;
              } else if (operadorI === "%") {
                contador = contador % incremento;
              }
              if (contador != comparador) {
                this.instructions = this.instructions.concat(arrayOriginal);
              }

            }
            break;
          case "==":
            while (contador === comparador) {
              if (operadorI === "+") {
                contador = contador + incremento;
              } else if (operadorI === "-") {
                contador = contador - incremento;
              } else if (operadorI === "/") {
                contador = contador / incremento;
              } else if (operadorI === "*") {
                contador = contador * incremento;
              } else if (operadorI === "%") {
                contador = contador % incremento;
              }
              if (contador === comparador) {
                this.instructions = this.instructions.concat(arrayOriginal);
              }

            }
            break;
        }

        let newTable = new Environment(table, `While-${this.row}-${this.column}`);
        let instruction: any;

        for (let item of this.instructions) {

          instruction = item.interpret(tree, newTable);
          if (instruction instanceof Exception) {
            // Semantic Error
            tree.errors.push(instruction);
            tree.updateConsole(instruction.toString());
          }
        }
      }
    } else {
      return new Exception("Semantic", `Expect a boolean type expression. Not ${flag.type}`, this.row, this.column, table.name);
    }
  }

  getAST(): Node {

    let node: Node = new Node("While");
    node.addChildsNode(this.expression.getAST());

    let insTrue: Node = new Node("true");
    for (let item of this.instO) {
      
      insTrue.addChildsNode(item.getAST());
    }

    node.addChildsNode(insTrue);


    return node;

  }

}