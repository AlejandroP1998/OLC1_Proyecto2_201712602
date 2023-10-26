import { Instruction } from "../abstract/Instruction";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";
import { Node } from "../abstract/Node.js";
import { Table } from "./Table.js";

export class Select implements Instruction {
  public tabla: Table;
  public instruction: String;
  public row: number;
  public column: number;
  constructor(tabla: Table, instruction: String, row: number, column: number) {
    this.tabla = tabla;
    this.instruction = instruction;
    this.row = row;
    this.column = column;
  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {

    if (this.tabla instanceof Exception) {
      // Semantic Error
      tree.errors.push(this.tabla);
      tree.updateConsole('No se logro crear la tabla');
    }

    tree.updateConsole(`${this.instruction}`);
  }

  getAST(): Node {

    let node: Node = new Node("Select");
    let n1: Node = new Node(`${this.tabla.name}`);
    node.addChildsNode(n1);
    return node;

  }
}