export class Table {
  public data: Array<any>;
  constructor(public name: string, public columns: string[]) {
    this.data = [];
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
}

const myTable = new Table("MiTabla", ["columna1", "columna2"]);
