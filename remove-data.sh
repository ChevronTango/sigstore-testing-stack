#!/bin/bash

cd ./data

cd ./dex
find . -type f -not -name '.gitignore' -print0 | xargs -0  -I {} sudo rm -v {}
cd ..

cd ./rekor
find . -type f -not -name '.gitignore' -print0 | xargs -0  -I {} sudo rm -v {}
cd ..

cd ./fulcio
find . -type f -not -name '.gitignore' -print0 | xargs -0  -I {} sudo rm -v {}
cd ..

cd ./ctfe
find . -type f -not -name '.gitignore' -print0 | xargs -0  -I {} sudo rm -v {}
cd ..

cd ./tuf
sudo rm -R keys
sudo rm -R repository
sudo rm -R staged
cd ..