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
  public elseInstructions: Array<Instruction> | undefined;
  public elseIf: Instruction | undefined;
  public row: number;
  public column: number;


  constructor(expression: Instruction, instructions: Array<Instruction>, elseInstructions: Array<Instruction> | undefined, row: number, column: number) {
    this.expression = expression;
    this.instructions = instructions;
    this.elseInstructions = elseInstructions;
    this.row = row;
    this.column = column;
    //console.log('expressionIf -> ',this.expression);
    //console.log('instructionsIf -> ',this.instructions);
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

        let newTable = new Environment(table, `If-${this.row}-${this.column}`);
        let instruction: any;

        for (let item of this.instructions) {
          //console.log("🚀 ~ file: If.ts:51 ~ If ~ interpret ~ item:", item)

          instruction = item.interpret(tree, newTable);


          if (instruction instanceof Exception) {
            // Semantic Error
            tree.errors.push(instruction);
            tree.updateConsole(instruction.toString());
          }
        }
      } else if (this.elseInstructions !== undefined) {
        let newTable = new Environment(table, `Else-${this.row}-${this.column}`);
        let instruction: any;

        for (let item of this.elseInstructions) {
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

    let node: Node = new Node("If");
    node.addChildsNode(this.expression.getAST());

    let insTrue: Node = new Node("true");
    for (let item of this.instructions) {
      insTrue.addChildsNode(item.getAST());
    }

    node.addChildsNode(insTrue);

    if (this.elseInstructions !== undefined) {
      let insFalse: Node = new Node("false");

      for (let item of this.elseInstructions) {
        insFalse.addChildsNode(item.getAST());
      }

      node.addChildsNode(insFalse);
    }


    return node;

  }

}