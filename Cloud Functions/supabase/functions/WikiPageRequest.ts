// Facade pattern
export class WikiPageRequest {
    public static readonly wikiApi: string = "https://en.wikipedia.org/w/api.php";
    private readonly _wikiPageName: string;
    private readonly _searchRequest: URL;  
    private _request: URL | undefined;  

    constructor(wikiPageName: string) {
        this._wikiPageName = wikiPageName;
        this._searchRequest = new URL(WikiPageRequest.wikiApi);
        this.prepareSearchRequest();
    }

    private prepareSearchRequest(): void {
        this._searchRequest.searchParams.append("origin", "*");
        this._searchRequest.searchParams.append("action", "opensearch");
        this._searchRequest.searchParams.append("search", this._wikiPageName);
        this._searchRequest.searchParams.append("limit", "1");
        this._searchRequest.searchParams.append("namespace", "0");
        this._searchRequest.searchParams.append("format", "json");
    }

    public async search(): Promise<void> {
        // Prevent multiple calls to search
        if (this._request != undefined) return;
        const searchRequest = await fetch(this._searchRequest);
        const searchBody =  await searchRequest.json();
        const urls: string[] = searchBody[3];
        if (urls.length == 0)  {
            throw new Error("No search results found");
        }
        this._request = new URL(urls[0]);
    }

    public async fetch(): Promise<string> {
        if (this._request == undefined) {
            throw new Error("Must search for the wiki before the content can be fetched");
        }
        const wikiPageResponse = await fetch(this._request);
        return await wikiPageResponse.text();
    }  
}

export default { WikiPageRequest };