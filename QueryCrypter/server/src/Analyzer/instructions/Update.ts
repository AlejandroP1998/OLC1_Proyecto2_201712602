import { Instruction } from "../abstract/Instruction";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";
import { Node } from "../abstract/Node.js";
import { Table } from "./Table.js";
import { Relational } from "../expressions/Relational.js";

export class Update implements Instruction {
  public tabla: Table;
  public row: number;
  public column: number;
  constructor(tabla: Table, row: number, column: number) {
    this.tabla = tabla;
    this.row = row;
    this.column = column;
  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {
    tree.updateConsole(`Se actualizo la tabla ${this.tabla.name}`);
  }

  getAST(): Node {

    let node: Node = new Node("Update");
    let n1: Node = new Node(`${this.tabla.name}`);
    return node;

  }
}