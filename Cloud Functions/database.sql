-- Auto Generated From Supabase

DROP TABLE IF EXISTS BirdShape;
DROP TABLE IF EXISTS Traits;
DROP TABLE IF EXISTS Diet;
DROP TABLE IF EXISTS Nest;
DROP TABLE IF EXISTS Log;
DROP TABLE IF EXISTS BirdLabels;
DROP TABLE IF EXISTS BlacklistedLabels;

DROP TABLE IF EXISTS Sound;
DROP TABLE IF EXISTS FamilyToShape;
DROP TABLE IF EXISTS SystemMessages;
DROP TABLE IF EXISTS BirdSpecies;


CREATE TABLE BirdShape (
    "BirdShapeId" uuid not null default gen_random_uuid (),
    "BirdShapeName" character varying not null default ''::character varying,
    "BirdShapeTemplateUrl" character varying not null default ''::character varying,
    "BirdShapeTemplateJson" jsonb not null default '{}'::jsonb,
    "BirdShapeAnimationTemplate" jsonb null default '{"animation": {}, "amountOfFrames": 0}'::jsonb,
    "BirdShapeSize" real not null default '1'::real,
	CONSTRAINT birdshape_pkey PRIMARY KEY ("BirdShapeId")
);

CREATE TABLE Traits (
    "traitId" uuid not null default gen_random_uuid (),
    "traitName" character varying not null default ''::character varying,
    constraint Traits_pkey primary key ("traitId")
);

CREATE TABLE Diet (
	"DietId" uuid NOT NULL DEFAULT gen_random_uuid(),
	"DietName" varchar NOT NULL DEFAULT ''::character varying,
	CONSTRAINT diet_pkey PRIMARY KEY ("DietId")
);

CREATE TABLE Nest (
    "Id" uuid not null default gen_random_uuid (),
    "Type" text not null default ''::text,
    constraint Nest_pkey primary key ("Id")
);

CREATE TABLE Sound (
    "Id" uuid not null default gen_random_uuid (),
    "Name" text not null default ''::text,
    constraint Sound_pkey primary key ("Id")
);

CREATE TABLE Log (
    "Id" uuid not null default gen_random_uuid (),
    "Function" text not null,
    "CreatedAt" timestamp with time zone not null default now(),
    "Request" jsonb not null,
    "IsError" boolean not null,
    "Error" jsonb null,
    constraint Log_pkey primary key ("Id")
);

CREATE TABLE BirdLabels (
    "Label" text not null,
    "IsSpecific" boolean not null default false,
    "DefaultBird" character varying null default ''::character varying,
    constraint BirdLabels_pkey primary key ("Label"),
    constraint BirdLabels_Label_key unique ("Label")
);

CREATE TABLE BlacklistedLabels (
    "Label" character varying not null,
    constraint BlacklistedLabels_pkey primary key ("Label"),
    constraint BlacklistedLabels_Label_key unique ("Label")
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
    "birdId" uuid not null default gen_random_uuid (),
    "birdName" character varying not null default ''::character varying,
    "birdDescription" text not null default ''::text,
    "birdScientificName" character varying not null default ''::character varying,
    "birdFamily" character varying not null default ''::character varying,
    "birdShapeId" uuid not null,
    "dietId" uuid not null,
    "createdAt" timestamp without time zone not null default now(),
    version real not null default '0'::real,
    "birdSimulationInfo" jsonb not null default '{}'::jsonb,
    "birdUnisex" boolean null default true,
    "birdImages" jsonb null default '{}'::jsonb,
    "birdColourMap" jsonb null,
    "birdSound" uuid null,
    "birdNest" uuid null,
    "isPredator" boolean not null default false,
    constraint BirdSpecies_pkey primary key ("birdId"),
    constraint BirdSpecies_birdShapeId_fkey foreign key ("birdShapeId") references "BirdShape" ("BirdShapeId") on update cascade on delete cascade,
    constraint BirdSpecies_dietId_fkey foreign key ("dietId") references "Diet" ("DietId") on update cascade on delete cascade,
    constraint public_BirdSpecies_birdNest_fkey foreign key ("birdNest") references "Nest" ("Id") on update cascade on delete set null,
    constraint public_BirdSpecies_birdSound_fkey foreign key ("birdSound") references "Sound" ("Id") on update cascade on delete set null
);