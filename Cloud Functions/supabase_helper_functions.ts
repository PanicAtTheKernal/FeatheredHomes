import { crypto } from "https://deno.land/std@0.202.0/crypto/crypto.ts";

export class BirdSpeciesTable {
    private _birdId: string;
    private _birdName: string;
    private _birdDescription: string;
    private _birdScientificName: string;
    private _birdFamily: string;
    private _birdShapeId: string;
    private _dietId: string;
    private _birdImageUrl: string;
    private _createdAt: string;
    private _version: string;
    
    constructor() {
        this._birdId = crypto.randomUUID()
        this._birdName = "";
        this._birdDescription = "";
        this._birdScientificName = "";
        this._birdFamily = "";
        this._birdShapeId = "";
        this._dietId = "";
        this._birdImageUrl = "";
        this._createdAt = "";
        this._version = "0.0";
    }

    public get birdId() {
        return this._birdId;
    }

    public get birdName() {
        return this._birdName;
    }

    public set birdName(value) {
        this._birdName = value;
    }

    public get birdDescription() {
      return this._birdDescription;
    }

    public set birdDescription(value) {
        this._birdDescription = value;
    }

    public get birdScientificName() {
        return this._birdScientificName;
    }

    public set birdScientificName(value) {
        this._birdScientificName = value;
    }

    public get birdFamily() {
        return this._birdFamily;
    }

    public set birdFamily(value) {
        this._birdFamily = value;
    }
    
    public get birdShapeId() {
        return this._birdShapeId;
    }

    public set birdShapeId(value) {
        this._birdShapeId = value;
    }

    public get dietId() {
        return this._dietId;
    }

    public set dietId(value) {
        this._dietId = value;
    }

    public get birdImageUrl() {
        return this._birdImageUrl;
    }

    public set birdImageUrl(value) {
        this._birdImageUrl = value;
    }

    public get createdAt() {
        return this._createdAt;
    }

    public set createdAt(value) {
        this._createdAt = value;
    }

    public get version() {
        return this._version;
    }

    public set version(value) {
        this._version = value;
    }
}

export class BirdWikiPage {
    public birdName = "";
    public birdScientificName = "";
    public birdFamily = "";
    public birdDescription = "";
    public birdDiet = "";
    public birdSummary = "";
}