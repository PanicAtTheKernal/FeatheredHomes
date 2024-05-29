# Feathered Homes

Play the web version here: [https://itch.io/embed-upload/10495439?color=333333](https://itch.io/embed-upload/10541332?color=333333)

C20456964 Daniel Kondabarov

Github: https://github.com/PanicAtTheKernal/FinalYearProject

Music and Sound Created by [Ian Cecil Scott](https://www.iancecilscott.com/)

# Notes
- All code files end with .ts or .gd
- .tcsn are scene files for Godot
- The Assets folder only contains images, sound files and resources used for the project

# How to set up

## Requirements
1. An Supabase instance from [Supabase](supabase.com)
    - Get the URL of the instance
    - Get the anon key (API key) from the instance
2. OpenAI API Key 
3. Google Cloud Project with the Vision API enabled ([Guide](https://cloud.google.com/vision/docs/setup))
4. Google Cloud API Key ([Guide](https://cloud.google.com/docs/authentication/api-keys))
5. Install Supabase locally ([Guide](https://supabase.com/docs/guides/cli/getting-started))
6. Install [Godot 4.2](godotengine.org)
7. Clone this repo to your local machine

## Setup storage 
1. On the Supabase dashboard, click on the storage button in the side bar
2. Click "New bucket"
3. Name the bucket "BirdAssets" and make it **public**
4. Click into the bucket created
5. Click on "Create Folder"
6. Name the new folder "Templates"
7. In the repo, navigate to the Cloud Functions/templates folder
8. Upload all the files in the folder to the Templates folder in Supabase 

## Setup the database 
1. On the Supabase dashboard, click on the SQL editor button in the side bar
2. Copy and paste the SQL code from "Cloud Functions/database.sql"
3. Execute the SQL
4. In the repo, navigate to the Cloud Functions/data folder
5. Inside is the data to populate the tables
6. In Supabase, click on the Table Editor button in the side bar 
7. Select any table but the BirdSpecies table. The BirdSpecies doesn't need to be populated
8. Click on insert, then click on import from CSV
9. Drag and drop the csv file for that table and press import
10. Repeat until necessary the tables are populated

## Install the Addons
1. Download the supabase addon from [Github](https://github.com/supabase-community/godot-engine.supabase/releases/tag/LW7)
2. Extract the contents
3. Copy the **addon** folder and place it in the root of the cloned repo
4. Create an .env file in "addons/supabase"
5. Add the lines
```
[supabase/config]

supabaseUrl="<Replace with your Supabase instance url>"
supabaseKey="<Replace with your Supabase service key>"

```
6. Open Godot and load the project
7. Click **Project** in the top
8. Click **Project Settings**
9. Click **Plugins** 
10. Enable the Supabase plugin 
11. Repeat steps, 2-3,6-10 for the following plugins
- [GodotGetImage](https://github.com/Lamelynx/GodotGetImagePlugin-Android)
- [godot debug draw 3d](https://github.com/DmitriySalnikov/godot_debug_draw_3d)

## Deploying the Supabase functions
1. Create an .env file in "Cloud Functions/supabase"
2. Add the lines 
```
OPENAI_API_KEY=<OpenAI API key>
OPENAI_ORG_ID=<Replace with your OpenAI Org ID>
SUPABASE_SERVICE_ROLE_KEY=<Replace with your Supabase service key>
SUPABASE_URL=<Replace with your Supabase instance url>
VERSION=1.0
GOOGLE_CLOUD_API_KEY=<Google Cloud API key>
```
1. Open a terminal and navigate to "Cloud Functions"
2. Follow these [steps](https://supabase.com/docs/guides/functions/deploy) to deploy to your instance

## Setup the game
1. Create an .env file in the root of the project
2. Add the lines
```
[environment]

URL=<Replace with your Supabase instance url>
LOCAL_URL=<Replace with your Supabase local instance url>
IMAGE_ENDPOINT="imageIdentification"
FIND_SPECIES_ENDPOINT="findSpecies"
SEARCH_ENDPOINT="search"
ANON_TOKEN=<Replace with your anon token>
EMAIL=<create a basic user in the Supabase UI and paste username here>
PASSWORD=<password here>
VERSION="1.1"
```
