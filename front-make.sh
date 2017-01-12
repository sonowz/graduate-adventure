#!bin/bash
# Simple build script for Elm
# Output file will be ignored by .gitignore

SrcDir="frontend/src/elm/"
SrcName="main.elm"
OutDir="./"
OutName="Elm-debug.html"

elm-make $SrcDir$SrcName --output=$OutDir$OutName
