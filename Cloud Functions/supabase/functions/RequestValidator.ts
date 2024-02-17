const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };

export type BirdRequest = {
    birdSpecies: string
}

export class RequestValidator {
    private readonly _request: Request;
    private _body!: BirdRequest;
  
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
        return new Response(
          JSON.stringify({
            error: "Request must be a POST"
          }),
          { headers: HEADERS,
            status: 400 },
        );
      }
      if (!(await this.validateBodyRequest())) {
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
  }

export default { RequestValidator }