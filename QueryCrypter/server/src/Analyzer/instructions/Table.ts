import { Instruction } from "../abstract/Instruction";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";
import { Node } from "../abstract/Node.js";

export class Table implements Instruction{
  public name: string;
  public instructions: Array<Instruction>;
  public row: number;
  public column: number;
  constructor(name: string, instructions: Array<Instruction>, row: number, column: number) {
    this.name = name;
    this.instructions = instructions;
    this.row = row;
    this.column = column;
  }

  insertRow(rowData: any[]) {
    // Implementar la lógica para insertar una fila en la tabla.
  }

  select(columns: string[], condition?: string) {
    // Implementar la lógica para seleccionar datos de la tabla.
  }

  update(column: string, newValue: any, condition: string) {
    // Implementar la lógica para actualizar datos en la tabla.
  }

  truncate() {
    // Implementar la lógica para truncar la tabla (eliminar todos los datos).
  }

  delete(condition: string) {
    // Implementar la lógica para eliminar filas que cumplan con una condición.
  }

  getValue(tree: Tree, table: Environment): ReturnType {
    return new ReturnType(type.INT, undefined);
  }

  interpret(tree: Tree, table: Environment) {

    let newTable = new Environment(table, `Table-${this.row}-${this.column}`);
    let instruction: any;

    for (let item of this.instructions) {
      instruction = item.interpret(tree, newTable);

      if (instruction instanceof Exception) {
        // Semantic Error
        tree.errors.push(instruction);
        tree.updateConsole('No se logro crear la tabla');
      }
      
    }
    //tree.updateConsole(`se creo la tabla ${this.name}`);

  }

  getAST(): Node {

    let node: Node = new Node(`${this.name}`);
    let insTrue: Node = new Node("Columns");
    for (let item of this.instructions) {
      insTrue.addChildsNode(item.getAST());
    }

    node.addChildsNode(insTrue);

    return node;

  }

  
}

