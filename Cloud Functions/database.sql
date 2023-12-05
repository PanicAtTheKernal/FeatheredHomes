-- Auto Generated From Supabase

DROP TABLE IF EXISTS BirdShape;
DROP TABLE IF EXISTS Traits;
DROP TABLE IF EXISTS Diet;
DROP TABLE IF EXISTS FamilyToShape;
DROP TABLE IF EXISTS SystemMessages;
DROP TABLE IF EXISTS BirdSpecies;


CREATE TABLE BirdShape (
	"BirdShapeId" uuid NOT NULL DEFAULT gen_random_uuid(),
	"BirdShapeName" varchar NOT NULL DEFAULT ''::character varying,
	"BirdShapeTemplateUrl" varchar NOT NULL DEFAULT ''::character varying,
	"BirdShapeTemplateJson" jsonb NOT NULL DEFAULT '{}'::jsonb,
	"BirdShapeAnimationTemplate" jsonb NULL DEFAULT '{"animation": {}, "amountOfFrames": 0}'::jsonb,
	CONSTRAINT birdshape_pkey PRIMARY KEY ("BirdShapeId")
);

CREATE TABLE Traits (
	"traitId" uuid NOT NULL DEFAULT gen_random_uuid(),
	"traitName" varchar NOT NULL DEFAULT ''::character varying,
	"traitRule" jsonb NULL DEFAULT '{}'::jsonb,
	"traitPattern" jsonb NULL DEFAULT '{}'::jsonb,
	CONSTRAINT traits_pkey PRIMARY KEY ("traitId")
);

CREATE TABLE Diet (
	"DietId" uuid NOT NULL DEFAULT gen_random_uuid(),
	"DietName" varchar NOT NULL DEFAULT ''::character varying,
	CONSTRAINT diet_pkey PRIMARY KEY ("DietId")
);

CREATE TABLE FamilyToShape (
	"BirdFamilyName" varchar NOT NULL,
	"BirdShapeName" uuid NOT NULL,
	CONSTRAINT familytoshape_pkey PRIMARY KEY ("BirdFamilyName"),
	CONSTRAINT familytoshape_birdshapename_fkey FOREIGN KEY ("BirdShapeName") REFERENCES BirdShape("BirdShapeId") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE SystemMessages (
	"SystemMessageId" uuid NOT NULL DEFAULT gen_random_uuid(),
	"SystemMessageName" varchar NOT NULL DEFAULT ''::character varying,
	"SystemMessageContent" text NOT NULL,
	CONSTRAINT systemmessages_pkey PRIMARY KEY ("SystemMessageId")
);

CREATE TABLE BirdSpecies (
	"birdId" uuid NOT NULL DEFAULT gen_random_uuid(),
	"birdName" varchar NOT NULL DEFAULT ''::character varying,
	"birdDescription" text NOT NULL DEFAULT ''::text,
	"birdScientificName" varchar NOT NULL DEFAULT ''::character varying,
	"birdFamily" varchar NOT NULL DEFAULT ''::character varying,
	"birdShapeId" uuid NOT NULL,
	"dietId" uuid NOT NULL,
	"birdImageUrl" varchar NOT NULL DEFAULT ''::character varying,
	"createdAt" timestamp NOT NULL DEFAULT now(),
	"version" float4 NOT NULL DEFAULT '0'::real,
	"birdSimulationInfo" jsonb NOT NULL DEFAULT '{}'::jsonb,
	CONSTRAINT birdspecies_pkey PRIMARY KEY ("birdId"),
	CONSTRAINT birdspecies_birdshapeid_fkey FOREIGN KEY ("birdShapeId") REFERENCES BirdShape("BirdShapeId") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT birdspecies_dietid_fkey FOREIGN KEY ("dietId") REFERENCES Diet("DietId") ON DELETE CASCADE ON UPDATE CASCADE
);