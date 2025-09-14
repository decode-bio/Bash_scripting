#!/bin/bash

#---------------------------------------------------------------------------
# Q1: Write the script to count how many sequences are in the FASTA file?
#---------------------------------------------------------------------------
#file=Nucleotide_sequence.txt

#seq_count=$(grep -c "^>" $file)

# Printing the result in one go 
#echo "Number of sequences found in $file are $seq_count."

#--------------------------------------------------------------------------------
# Q2.Write a shell script to calculate the length of each sequence and display it #as: Sequence_ID   Length
#--------------------------------------------------------------------------------
file=Nucleotide_sequence.txt
echo "Sequence_id and lenght are as follows: "
awk '/^>/ {
    if (len > 0) print seq_id, len;
    seq_id = substr($1, 2);
    len = 0;
    next;
}
{
    len += length($0);
}
END {
    print seq_id, len;
}' "$file"
