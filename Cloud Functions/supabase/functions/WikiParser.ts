import { CheerioAPI, Cheerio, Element, load } from "npm:cheerio";
import { WikiPageRequest } from "./WikiPageRequest.ts";

// Facade pattern
export class WikiParser {
    private readonly $page: CheerioAPI;

    constructor (wikiPage: string) {
        this.$page = load(wikiPage);
    }

    private getInfoBox(): Cheerio<Element> {
        return this.$page(".infobox.biota");
    }

    public static replaceCitations(section: string): string {
        return section.replaceAll(/\[[0-9]+\]/g, "");
    }

    public getPageTitle(): string {
        const pageTitle = this.$page(".mw-page-title-main");
        if (pageTitle.length == 0) {
            throw new Error("The wiki page doesn't have a title");
        }
        return pageTitle.text();
    }

    public getSummary(): string {
        const summary = this.$page("#content h2:first").prevAll('p');
        if (summary.length == 0) {
            throw new Error(`The wiki page doesn't have a summary`);
        }
        return WikiParser.replaceCitations(summary.text().replaceAll("\n",""));
    }

    public getSection(section: string): string {
        const sectionContent = this.$page(`#content .mw-headline:contains(\"${section}\")`).parent()
            .nextUntil("h2:first, h3:first")
            .filter("p, ul, ol, table");
        if (sectionContent.length == 0) {
                throw new Error(`The wiki page doesn't have a ${section} section`);
            }
        return sectionContent.text();
    }

    public getFullSection(section: string): string {
        const sectionContent = this.$page(`#content h2:contains(\"${section}\")`)
            .nextUntil("h2:first")
            .filter("p, ul, ol, table");
        if (sectionContent.length == 0) {
                throw new Error(`The wiki page doesn't have a ${section} full section`);
            }
        return sectionContent.text();
    }

    public getBinomialName(): string {
        const binomialName = this.getInfoBox().find(`.binomial`);
        if (binomialName.length == 0) {
            throw new Error(`The wiki page infobox doesn't have a binomial name`);
        }
        return binomialName.text();
    }

    public getInfoBoxProperty(property: string): string {
        const propertyContent = this.getInfoBox().find(`td:contains(\"${property}\") + td`);
        if (propertyContent.length == 0) {
            throw new Error(`The wiki page infobox doesn't have a ${property} property`);
        }
        return propertyContent.text();
    }

    public getInfoBoxImageText(): string {
        const imageText = this.getInfoBox().find(`tr:has(img):first`)
            .nextAll("tr:not(:has(img)):first");
        return imageText.text();
    }

    public getNumberOfSections(): number {
        return 0;
    }

    public getLinksFromSection(section: string): string[] {
        const sectionContent = this.$page(`#content .mw-headline:contains(\"${section}\")`).parent()
            .nextUntil("h2:first, h3:first")
            .filter("p, ul, ol, table");
        const links: string[] = [];
        sectionContent.find("a").each((_, element) => {
            links.push(WikiPageRequest.wikiUrl + element.attribs["href"])
        })
        return links;
    }

    public hasInfoBoxProperty(property: string): boolean {
        const propertyContent = this.getInfoBox().find(`td:contains(\"${property}\") + td`);
        return (propertyContent.length > 0)? true : false;
    }

    public hasSection(section: string): boolean {
        const sectionContent = this.$page(`#content .mw-headline:contains(\"${section}\")`).parent()
            .nextUntil("h2:first, h3:first")
            .filter("p, ul, ol, table");
        return (sectionContent.length > 0)? true : false;
    }

    public hasFullSection(section: string): boolean {
        const sectionContent = this.$page(`#content h2:contains(\"${section}\")`)
            .nextUntil("h2:first")
            .filter("p, ul, ol, table");
        return (sectionContent.length > 0)? true : false;
    }
}

export default { WikiParser };