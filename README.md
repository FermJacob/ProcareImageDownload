# Procare Image Download Tool

This tool was made to easily bulk download all the images from the procare website for children.  Since the UI is limited, there is not a good way to download all files.

## Setup
1. In order to grab the bearer token, open the procare website, login, and find any GET request in the Dev Tools Network window.  There will be an "Authorization" header with the bearer token value. Paste this into the powershell script.
2. Grab the kidId from the dev tools for each child activity view and populate the kid array
3. Setup the extract folder path inside the powershell script.  NOTE: This folder path will fail the script if it is not created

## Running the script

1. Open VSCode 
2. Open powershell file
3. Populate the data
4. Press F5 to open the debug runner and allow the script to run