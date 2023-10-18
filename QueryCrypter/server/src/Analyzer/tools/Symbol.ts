import { type } from "./Type";

export default class Symbol {

    public id: string;
    public type: type;
    public value: any;
    public row: number;
    public column: number;
    public environment: string | undefined;

    
    constructor(id: string, type: type, value: any, row: number, column: number, environment?: string) {
        this.id = id;
        this.type = type;
        this.value = value;
        this.row = row;
        this.column = column;
        this.environment= environment;
    }
}