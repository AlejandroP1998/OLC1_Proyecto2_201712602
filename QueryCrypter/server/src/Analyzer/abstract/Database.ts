import { Table } from "./Table";

export class Database {
  private tables: Record<string, Table> = {};

  createTable(tableName: string, columns: string[]) {
    if (!this.tables[tableName]) {
      this.tables[tableName] = new Table(tableName, columns);
      // Implementar lógica para crear la tabla en una estructura de datos real si es necesario.
    }
  }

  alterTable(tableName: string, columnsToAdd: string[]) {
    if (this.tables[tableName]) {
      // Implementar lógica para modificar la estructura de la tabla (agregar columnas, etc.).
    }
  }

  dropTable(tableName: string) {
    if (this.tables[tableName]) {
      delete this.tables[tableName];
      // Implementar lógica para eliminar la tabla de la estructura de datos real si es necesario.
    }
  }
}

const myDatabase = new Database();
