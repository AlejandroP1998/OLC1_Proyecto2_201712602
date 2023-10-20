import { Instruction } from "../abstract/Instruction.js";
import { Node } from "../abstract/Node.js";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";

export class Case implements Instruction {

  public expression: Instruction;
  public instructions: Instruction;
  public row: number;
  public column: number;


  constructor(expression: Instruction, instructions: Instruction, row: number, column: number) {
    this.expression = expression;
    this.instructions = instructions;
    this.row = row;
    this.column = column;
    //console.log('expressionCase -> ', this.expression);
    //console.log('instructionsCase -> ', this.instructions);
  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {
    let flag: ReturnType = this.expression.getValue(tree, table);
    //console.log("flagIf value -> ",flag.value);


    if (flag.value instanceof Exception) {
      // Semantic error
      return flag;
    }

    if (flag.type === type.BOOLEAN) {
      if (JSON.parse(String(flag.value))) {

        let value: any = this.instructions.getValue(tree, table);

        if (value instanceof Exception) {
          // Semantic error
          return value;
        }

        tree.updateConsole(`${value}`);
      }
    } else {
      return new Exception("Semantic", `Expect a boolean type expression. Not ${flag.type}`, this.row, this.column, table.name);
    }
  }


  getAST(): Node {

    let node: Node = new Node("Case");
    node.addChildsNode(this.expression.getAST());

    let insTrue: Node = new Node("true");
    node.addChildsNode(this.instructions.getAST());

    node.addChildsNode(insTrue);

    return node;

  }

}