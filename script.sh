#!/bin/bash

#---------------------------------------------------------------------------
# Q1: Write the script to count how many sequences are in the FASTA file?
#---------------------------------------------------------------------------
file=Nucleotide_sequence.txt

seq_count=$(grep -c "^>" $file)
echo "---------------------------------------------------" 
echo "Number of sequences found in $file are $seq_count."
echo "---------------------------------------------------" 
#--------------------------------------------------------------------------------
# Q2.Write a shell script to calculate the length of each sequence and display it #as: Sequence_ID   Length
#--------------------------------------------------------------------------------

file=Nucleotide_sequence.txt
echo "---------------------------------------------------" 
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

echo "---------------------------------------------------" 
#------------------------------------------------------------------------------
# Q3: Write a shell script to identify the longest and shortest sequences in the FASTA file.
#------------------------------------------------------------------------------

file=Nucleotide_sequence.txt
echo "---------------------------------------------------" 
# Use awk to process the file and calculate sequence lengths
awk '
  BEGIN {
        # Initialize variables
        longest_len = 0
        shortest_len = -1
        current_seq = ""
        current_header = ""
    }
    
    /^>/ {
        # This is a header line
        # Process the previous sequence if one existed
        if (current_seq != "") {
            len = length(current_seq)
            if (len > longest_len) {
                longest_len = len
                longest_header = current_header
            }
            if (shortest_len == -1 || len < shortest_len) {
                shortest_len = len
                shortest_header = current_header
            }
        }
        
        # Reset for the new sequence
        current_header = $0
        current_seq = ""
    }
    
    !/^>/ {
        # This is a sequence line, append it to the current sequence
        # Remove any whitespace before adding
        current_seq = current_seq "" $0
    }
    
    END {
        # Process the last sequence in the file
        if (current_seq != "") {
            len = length(current_seq)
            if (len > longest_len) {
                longest_len = len
                longest_header = current_header
            }
            if (shortest_len == -1 || len < shortest_len) {
                shortest_len = len
                shortest_header = current_header
            }
        }
        
        # Print the results
        print "Longest sequence: " longest_len " bp"
        print "Header: " longest_header
        print ""
        print "Shortest sequence: " shortest_len " bp"
        print "Header: " shortest_header
    }
' "$file" 
echo "---------------------------------------------------" 
#------------------------------------------------------------------------------
# Q4. Write a shell script to calculate the GC content (%) of each sequence.
#-------------------------------------------------------------------------------
echo "---------------------------------------------------" 


file="Nucleotide_sequence.txt"

# Using awk to process the file and calculate GC content
echo "---------------------------------------------------" 
awk '
    BEGIN {
        # Initializing variables
        current_header = ""
        current_seq = ""
    }

    /^>/ {
        if (current_seq != "") {
            gc_count = 0
            len = length(current_seq)
            
            # Count G and C bases
            gc_count += gsub(/[gG]/, "&", current_seq)
            gc_count += gsub(/[cC]/, "&", current_seq)
            
            # Calculate GC percentage
            if (len > 0) {
                gc_percent = (gc_count / len) * 100
                print current_header "\t" gc_percent "%"
            } else {
                print current_header "\t" "0.00%"
            }
        }
        
        current_header = $0
        current_seq = ""
    }

    !/^>/ {
        # This is a sequence line
        # Convert to uppercase and append to the current sequence
        current_seq = current_seq toupper($0)
    }

    END {
        # Process the last sequence in the file
        if (current_seq != "") {
            gc_count = 0
            len = length(current_seq)
            
            # Count G and C bases
            gc_count += gsub(/[gG]/, "&", current_seq)
            gc_count += gsub(/[cC]/, "&", current_seq)
            
            # Calculate GC percentage
            if (len > 0) {
                gc_percent = (gc_count / len) * 100
                print current_header "\t" gc_percent "%"
            } else {
                print current_header "\t" "0.00%"
            }
        }
    }' "$file"
echo "---------------------------------------------------" 
#--------------------------------------------------------------------------------------------------------
# 5.	Write a shell script to extract sequences longer than 30 bp and save them into a new FASTA file.
#------------------------------------------------------------------------------------------------------


INPUT_FILE=Nucleotide_sequence.txt
OUTPUT_FILE="long_sequence.txt"
MIN_LENGTH=30

echo "---------------------------------------------------" 
echo "Filtering sequences longer than $MIN_LENGTH bp from $INPUT_FILE..."

# --- AWK Logic for Filtering ---
awk -v min="$MIN_LENGTH" '
/^>/ {
    # 1. On finding a new header, check the length of the PREVIOUS sequence.
    # We check (len != "") to prevent printing before the first sequence is processed.
    if (len != "" && len > min) {
        print prev_header;
        print prev_sequence;
    }
    
    # 2. Reset variables for the new sequence
    prev_header = $0;     # Save the current header line
    prev_sequence = "";   # Reset the sequence string
    len = 0;              # Reset the length count
    next;                 # Skip to the next line of input
}

# Skip any blank lines that might be present in the FASTA file
/^$/ { 
    next;
}

{
    # 3. For all other lines (sequence lines):
    # Add the line length to the running total
    len += length($0);
    
    # Append the sequence content to the saved sequence string
    prev_sequence = prev_sequence $0;
}

END {
    # 4. Check the length of the LAST sequence after all lines are processed.
    if (len > min) {
        print prev_header;
        print prev_sequence;
    }
}' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Filtering complete."
echo "Results saved to '$OUTPUT_FILE'."
# Show the count of sequences saved (by counting lines starting with '>')
echo "Sequences found: $(grep -c "^>" "$OUTPUT_FILE")"
echo "---------------------------------------------------" 
#-------------------------------------------------------------------------
# Q6.	Write a shell script to search for a given motif (ATG, TATA, CGC) inside all sequences and count how many times it occurs. 
#--------------------------------------------------------------------------


INPUT_FILE=Nucleotide_sequence.txt
MOTIFS=("ATG" "TATA" "CGC") # The motifs to search for

# --- Error Checking ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

echo "--- Motif Search Results ---"
echo "Searching in $INPUT_FILE for: ${MOTIFS[*]}"
echo "------------------------------"

# 1. Clean the FASTA file into a single, continuous sequence string.
# grep -v '^>' : Excludes all header lines (lines starting with >).
# tr -d '\n'  : Deletes all newline characters, concatenating the sequences.
cleaned_sequence=$(grep -v '^>' "$INPUT_FILE" | tr -d '\n')

# Check if any sequence data was found
if [ -z "$cleaned_sequence" ]; then
    echo "No sequence data found to search."
    exit 0
fi

# 2. Loop through each motif and count its occurrences.
for motif in "${MOTIFS[@]}"; do
    # Pipe the continuous sequence string to grep.
    # -o : Prints ONLY the match, putting each match on a new line.
    # -i : Performs a case-insensitive search (good practice for motifs).
    # wc -l: Counts the number of lines, which equals the number of matches.
    
    count=$(echo "$cleaned_sequence" | grep -o -i -E "$motif" | wc -l)
    
    # Print the result using printf for clean, formatted output
    printf "Motif: %s\tCount: %d\n" "$motif" "$count"
done

echo "------------------------------"

#----------------------------------------------------------------------
#7.	Write a shell script that:
# -Reads each sequence from the FASTA file
# -Calculates its length and GC content
#----------------------------------------------------------------------



INPUT_FILE=Nucleotide_sequence.txt

echo "Calculating length and GC content for each sequence..."
echo "--------------------------------------------------------"


awk '
    BEGIN {
        OFS="\t";
    }

    /^>/ {
        # If not the first header line, process the previous sequence.
        if (seq_id != "") {
            # Fix: The calculation is now safe.
            # Get the total length before counting.
            total_length = length(sequence);
            
            # Count Gs and Cs by checking against the full string.
            # This is non-destructive.
            g_count = gsub(/[Gg]/,"",sequence);
            c_count = gsub(/[Cc]/,"",sequence);
            gc_count = g_count + c_count;
            
            if (total_length > 0) {
                gc_content = (gc_count / total_length) * 100;
                printf "%s\t%d\t%.2f%%\n", seq_id, total_length, gc_content;
            } else {
                printf "%s\t%d\t0%%\n", seq_id, total_length;
            }
        }
        
        # Reseting variables for the new sequence
        seq_id = substr($0, 2);
        sequence = "";
        next;
    }
    
    {
        gsub(/[ \t\r\n]/, "", $0);
        sequence = sequence $0;
    }
    
    END {
       
        total_length = length(sequence);
        g_count = gsub(/[Gg]/,"",sequence);
        c_count = gsub(/[Cc]/,"",sequence);
        gc_count = g_count + c_count;

        if (total_length > 0) {
            gc_content = (gc_count / total_length) * 100;
            printf "%s\t%d\t%.2f%%\n", seq_id, total_length, gc_content;
        } else {
            printf "%s\t%d\t0%%\n", seq_id, total_length;
        }
    }
' "$INPUT_FILE"

echo "--------------------------------------------------------"
