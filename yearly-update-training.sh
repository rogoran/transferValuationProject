#!/bin/bash

set -e

# Run the Jupyter Notebook using nbconvert
jupyter nbconvert --execute --to notebook --inplace training-pipeline.ipynb