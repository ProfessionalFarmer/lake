#!/bin/sh

# https://stackoverflow.com/questions/32183333/what-is-a-neat-command-line-equivalent-to-rstudios-knit-html 

### Test usage; if incorrect, output correct usage and exit
if [ "$#" -gt 2  -o  "$#" -lt 2 ]; then
    echo "********************************************************************"
    echo "*                        Knitter version 1.0                       *"
    echo "********************************************************************"
    echo -e "The 'knitter' script converts Rmd files into HTML or PDFs. \n"
    echo -e "usage: knitter file.Rmd file.{pdf,html} \n"
    echo -e "Spaces in the filename or directory name may cause failure. \n"
    exit
fi
# Stem and extension of file
extension1=`echo $1 | cut -f2 -d.`
extension2=`echo $2 | cut -f2 -d.`

### Test if file exist
if [[ ! -r $1 ]]; then
    echo -e "\n File does not exist, or option mispecified \n"
    exit
fi

### Test file extension
if [[ $extension1 != Rmd ]]; then
    echo -e "\n Invalid input file, must be a Rmd-file \n"
    exit
fi

# Create temporary script
# Use user-defined 'TMPDIR' if possible; else, use /tmp
if [[ -n $TMPDIR ]]; then
    pathy=$TMPDIR
else
    pathy=/tmp
fi
# Tempfile for the script
tempscript=`mktemp $pathy/tempscript.XXXXXX` || exit 1

if [[ $extension2 == "pdf" ]]; then
    echo "library(rmarkdown); rmarkdown::render('"${1}"', 'pdf_document')" >> $tempscript
    Rscript $tempscript
fi
if [[ $extension2 == "html" ]]; then
    echo "library(rmarkdown); rmarkdown::render('"${1}"', 'html_document')" >> $tempscript
    Rscript $tempscript
fi
