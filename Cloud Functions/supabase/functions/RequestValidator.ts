const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };

export type BirdRequest = {
    birdSpecies: string,
    hashMap?: object,
}

export class RequestValidator {
    private readonly _request: Request;
    private _body!: BirdRequest;
    private _error!: string;

    constructor (request: Request) {
      this._request = request;
    }
  
    private validatePostRequest(): boolean {
      return (this._request.method == "POST");
    }
    
    private async validateBodyRequest(): Promise<boolean> {
      this._body = await this._request.json() as BirdRequest;
      return Object.hasOwn(this._body, "birdSpecies");
    }
     
    public async validate(): Promise<Response | null> {
      if (!this.validatePostRequest()) {
        this._error = "Request must be a POST";
        return new Response(
          JSON.stringify({
            error: "Request must be a POST"
          }),
          { headers: HEADERS,
            status: 400 },
        );
      }
      if (!(await this.validateBodyRequest())) {
        this._error = "Missing birdSpecies in request body";
        return new Response(
          JSON.stringify({
            error: "Missing birdSpecies in request body"
          }),
          { headers: HEADERS,
            status: 400 },
        );
      }
      return null;
    }
  
    public get body(): BirdRequest {
      return this._body;
    }

    public get error(): string {
      return this._error;
    }
  }

export default { RequestValidator }
