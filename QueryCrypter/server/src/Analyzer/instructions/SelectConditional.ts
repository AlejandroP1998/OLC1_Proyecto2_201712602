import { Instruction } from "../abstract/Instruction";
import Environment from "../tools/Environment.js";
import Exception from "../tools/Exception.js";
import ReturnType from "../tools/ReturnType.js";
import Tree from "../tools/Tree.js";
import { type } from "../tools/Type.js";
import { Node } from "../abstract/Node.js";
import { Table } from "./Table.js";
import { Relational } from "../expressions/Relational.js";

export class SelectConditional implements Instruction {
  public tabla: Table;
  public instruction: Relational;
  public parametros: Array<any>;
  public e1: any;
  public e2: any;
  public row: number;
  public column: number;
  public astms: String;
  constructor(tabla: Table, instruction: Relational, parametros: Array<any>, e1: any, e2: any, row: number, column: number) {
    this.tabla = tabla;
    this.instruction = instruction;
    this.parametros = parametros;
    this.e1 = e1;
    this.e2 = e2;
    this.row = row;
    this.column = column;
    this.astms = "";
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
    this.instruction.exp1 ? this.instruction.exp1 : this.instruction.exp1 = this.e1;
    this.instruction.exp2 ? this.instruction.exp2 : this.instruction.exp2 = this.e2;
    //@ts-ignore
    let ms = `Valores de la tabla que complen con la condicion ${this.instruction.exp1} ${this.instruction.operator} ${this.instruction.exp2.value} \n`;
    //@ts-ignore
    this.astms = `${this.instruction.exp1} ${this.instruction.operator} ${this.instruction.exp2.value}`
    const instO = this.instruction.exp1;
    let flag: ReturnType;
    this.tabla.rows.forEach(row => {
      // @ts-ignore
      let a = row.find((item) => item.id === this.instruction.exp1)
      this.instruction.exp1 = a.value;
      flag = this.instruction.getValue(tree, table);
      if (flag.value === 'true') {
        //@ts-ignore
        row.forEach(item => {
          if (this.parametros.includes(item.id)) {
            ms += `El valor de ${item.id} es ${item.value.value}\n`
          }
        })
      }
      this.instruction.exp1 = instO;
    })
    tree.updateConsole(`${ms}`);
  }

  getAST(): Node {

    let node: Node = new Node("Select");
    let n1: Node = new Node(`${this.tabla.name}`);
    node.addChildsNode(n1);
    let n2: Node = new Node("Where");
    n1.addChildsNode(n2);
    let n3: Node = new Node(this.astms.toString());
    n2.addChildsNode(n3);
    return node;

  }
}