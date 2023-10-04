import { type } from "./Type"

export default class ReturnType {


  public type: type;
  public value: string | number | boolean;

  constructor(type: type, value: string | number | boolean) {
    this.type = type;
    this.value = value;
  }

  public toString(): string | number | boolean {
    return this.value;
  }

}