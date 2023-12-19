#!/bin/bash

set -e

# Activate virtual environment or set up your Python environment as needed

# Run the Jupyter Notebook using nbconvert
jupyter nbconvert --execute --to notebook --inplace data-analysis.ipynb
