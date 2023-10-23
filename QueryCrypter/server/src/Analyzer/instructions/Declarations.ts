import { Instruction } from "../abstract/Instruction.js";
import { Node } from "../abstract/Node.js";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";

export class Declarations implements Instruction {

  public instructions: Array<Instruction>;
  public row: number;
  public column: number;


  constructor(instructions: Array<Instruction>, row: number, column: number) {
    this.instructions = instructions;
    this.row = row;
    this.column = column;
  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {

    let newTable = new Environment(table, `Declarations-${this.row}-${this.column}`);
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


  getAST(): Node {

    let node: Node = new Node("Declare");
    let insTrue: Node = new Node("declaration");
    for (let item of this.instructions) {
      insTrue.addChildsNode(item.getAST());
    }

    node.addChildsNode(insTrue);

    return node;

  }

}