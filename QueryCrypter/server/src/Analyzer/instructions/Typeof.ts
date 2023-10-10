import { Instruction } from "../abstract/Instruction.js";
import { Node } from "../abstract/Node.js";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";

export class Typeof implements Instruction {

  public expression: Instruction;
  public row: number;
  public column: number;

  constructor(expression: Instruction, row: number, column: number) {
    this.expression = expression;
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
    let tipo = value.type
    value.value = tipo;
    if (value instanceof Exception) {
      // Semantic error
      return value;
    }

    tree.updateConsole(`${value}`);
  }

  getCST(): Node {
    let node: Node = new Node("Typeof");
    node.addChild("typeof");
    node.addChild("(");
    node.addChildsNode(this.expression.getCST());
    node.addChild(")");

    return node;
  }

  getAST(): Node {
    let node: Node = new Node("Typeof");
    node.addChildsNode(this.expression.getAST());

    return node;
  }
} 