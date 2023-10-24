import { Instruction } from "../abstract/Instruction";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";
import { Node } from "../abstract/Node.js";


export class DropTable implements Instruction{
  public tabla: String;
  public row: number;
  public column: number;
  constructor(tabla:String, row: number, column: number) {
    this.tabla = tabla;
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
    tree.updateConsole(`se elimino la tabla ${this.tabla}`);

  }

  getAST(): Node {

    let node: Node = new Node("Eliminar tabla");
    let insTrue: Node = new Node(`${this.tabla}`);
    node.addChildsNode(insTrue);

    return node;

  }

  
}

