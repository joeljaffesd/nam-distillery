#!/bin/bash

# Check if the correct argument is provided
if [ "$#" -ne 1 ] || [[ "$1" != *.nam ]]; then
	echo "Usage: $0 <model.nam>"
	exit 1
fi

echo "Reamping..."

NeuralAmpModelerReamping/build/tools/reamp "$1" input.wav output.wav

# Check if the output file was created
if [ ! -f output.wav ]; then
  echo "Reamping Error!"
  exit 1
fi

echo "Reamping Complete."

echo "Distilling..."

# Create the nam_output directory if it doesn't exist
if [ ! -d "nam_output" ]; then
  mkdir nam_output
fi

nam-full nam_full_config/data.json nam_full_config/model.json nam_full_config/learn.json nam_output

if [ $? -ne 0 ]; then
  echo "Training Error!"
  echo "Please make sure you have NAM installed and nam-full in your PATH."
  exit 1
fi

rm output.wav
find nam_output -type f -name "*.nam" -exec cp {} . \;

if [ $? -ne 0 ]; then
  echo "Find Error!"
  echo "See model.nam in nam_output."
  exit 1
fi

echo "Distillation Complete."
echo "See model.nam in the current directory."
