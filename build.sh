#!/bin/bash

# Script to compile LaTeX files in daily-exercises/ that don't start with _
# PDFs go to daily-exercises/pdf, auxiliary files go to daily-exercises/aux

EXERCISES_DIR="daily-exercises"
PDF_DIR="${EXERCISES_DIR}/pdf"
AUX_DIR="${EXERCISES_DIR}/aux"

# Create output directories if they don't exist
mkdir -p "${PDF_DIR}"
mkdir -p "${AUX_DIR}"

# Change to exercises directory to handle \input commands correctly
cd "${EXERCISES_DIR}" || exit 1

# Find changed .tex files since last commit
changed_tex_files=$(git status --porcelain -- "*.tex" | awk '{print $NF}')

if [ -z "${changed_tex_files}" ]; then
    echo "No changed .tex files to compile."
    exit 0
fi

for filepath in ${changed_tex_files}; do
    texfile="$(basename "${filepath}")"
    # Skip files starting with _
    if [[ "${texfile}" =~ ^_ ]]; then
        continue
    fi
    
    # Get base name without extension
    basename="${texfile%.tex}"
    
    echo "Compiling ${texfile}..."
    
    # Compile LaTeX file, output all files to aux directory
    pdflatex -interaction=nonstopmode -output-directory=aux "${texfile}" > /dev/null 2>&1
    
    # Run again for references (cross-references, bibliography, etc.)
    pdflatex -interaction=nonstopmode -output-directory=aux "${texfile}" > /dev/null 2>&1
    
    # Move PDF from aux to pdf directory
    if [ -f "aux/${basename}.pdf" ]; then
        mv "aux/${basename}.pdf" "pdf/${basename}.pdf"
        echo "  ✓ PDF saved to pdf/${basename}.pdf"
    else
        echo "  ✗ Error: PDF not generated for ${texfile}"
    fi
done

echo "Compilation complete!"
