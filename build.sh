#!/bin/bash
rm -rf build
mkdir build
zip -r build/nepali-calendar.plasmoid package/
echo "Build created at build/nepali-calendar.plasmoid"
