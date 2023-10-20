import { Instruction } from "../abstract/Instruction.js";
import { Node } from "../abstract/Node.js";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";

export class For implements Instruction {

  public expression: Instruction;
  public instructions: Array<Instruction>;
  public inicio: any;
  public fin: any;
  public row: number;
  public column: number;
  public instO: Array<Instruction>;


  constructor(expression: Instruction, inicio: any, fin: any, instructions: Array<Instruction>, row: number, column: number) {
    this.expression = expression;
    this.instructions = instructions;
    this.inicio = parseInt(inicio, 10);
    this.fin = parseInt(fin, 10);
    this.column = column;
    this.row = row;
    this.instO = instructions;
  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {

    let arrayOriginal = this.instructions;

    for (let contador = this.inicio; contador < this.fin; contador++) {
      this.instructions = this.instructions.concat(arrayOriginal);
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

  getAST(): Node {

    let node: Node = new Node("For");
    node.addChildsNode(this.expression.getAST());

    let insTrue: Node = new Node("true");
    for (let item of this.instO) {
      insTrue.addChildsNode(item.getAST());
    }

    node.addChildsNode(insTrue);



    return node;

  }

}