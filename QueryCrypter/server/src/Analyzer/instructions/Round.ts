import { Instruction } from "../abstract/Instruction.js";
import { Node } from "../abstract/Node.js";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";

function roundToDecimal(number: number, decimalPlaces: number) {
  const factor = 10 ** decimalPlaces;
  return Math.round(number * factor) / factor;
}

export class Round implements Instruction {

  public expression: Instruction;
  public decimal: number;
  public row: number;
  public column: number;

  constructor(expression: Instruction,decimal: number, row: number, column: number) {
    this.expression = expression;
    this.decimal = decimal;
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
    let round = roundToDecimal(value.value,this.decimal);
    value.value = round;
    if (value instanceof Exception) {
      // Semantic error
      return value;
    }

    tree.updateConsole(`${value}`);
  }

  getCST(): Node {
    let node: Node = new Node("Round");
    node.addChild("round");
    node.addChild("(");
    node.addChildsNode(this.expression.getCST());
    node.addChild(")");

    return node;
  }

  getAST(): Node {
    let node: Node = new Node("Round");
    node.addChildsNode(this.expression.getAST());

    return node;
  }
} 