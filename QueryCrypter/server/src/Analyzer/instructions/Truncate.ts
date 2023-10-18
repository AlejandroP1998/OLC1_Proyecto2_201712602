import { Instruction } from "../abstract/Instruction.js";
import { Node } from "../abstract/Node.js";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";

function truncate(numero: number, decimales: number) {
  const factor = 10 ** decimales;
  return Math.trunc(numero * factor) / factor;
}

export class Truncate implements Instruction {

  public expression: Instruction;
  public decimales: number;
  public row: number;
  public column: number;

  constructor(expression: Instruction, decimales: number, row: number, column: number) {
    this.expression = expression;
    this.decimales = decimales;
    this.row = row;
    this.column = column;
    /* console.log(this.expression);
    console.log(this.row);
    console.log(this.column); */
  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {
    let value: any = this.expression.getValue(tree, table);
    let trun = truncate(value.value, this.decimales);
    value.value = trun;
    if (value instanceof Exception) {
      // Semantic error
      return value;
    }

    tree.updateConsole(`${value}`);
  }


  getAST(): Node {
    let node: Node = new Node("Truncate");
    node.addChildsNode(this.expression.getAST());

    return node;
  }
} 