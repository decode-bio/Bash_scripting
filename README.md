# Objective
The goal is to learn the various command of the bash to extract or process desired information from sequences(DNA/RNA/Protein).

## Q 1: Write the script to count how many sequences are in the FASTA file?
```
file=Nucleotide_sequence.txt

seq_count=$(grep -c "^>" $file)
echo "---------------------------------------------------"
echo "Number of sequences found in $file are $seq_count."
echo "---------------------------------------------------"
```
<img width="758" height="89" alt="image" src="https://github.com/user-attachments/assets/20b98b67-2a51-40d6-b26c-3cb841a207ba" />


## Q 2: Write a shell script to calculate the length of each sequence and display it as: Sequence_ID   Length
```
file=Nucleotide_sequence.txt
echo "---------------------------------------------------"
echo "Sequnce_id and length are as follows: "
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
```
<img width="690" height="201" alt="image" src="https://github.com/user-attachments/assets/b90607f4-7b7b-4de4-9ba8-ba43eb96f330" />


## Q 3: Write a shell script to identify the longest and shortest sequences in the FASTA file.
```
file=Nucleotide_sequence.txt
echo "---------------------------------------------------"
awk '
  BEGIN {
        longest_len = 0
        shortest_len = -1
        current_seq = ""
        current_header = ""
    }
    
    /^>/ {
        
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
        
        current_header = $0
        current_seq = ""
    }
    
    !/^>/ {
        current_seq = current_seq "" $0
    }
    
    END {
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
        
        print "Longest sequence: " longest_len " bp"
        print "Header: " longest_header
        print ""
        print "Shortest sequence: " shortest_len " bp"
        print "Header: " shortest_header
    }
' "$file"
echo "---------------------------------------------------"
```
<img width="907" height="177" alt="image" src="https://github.com/user-attachments/assets/a14b640a-4620-4230-92f4-220df4773073" />


## Q 4:Write a shell script to calculate the GC content (%) of each sequence.

```
file=Nucleotide_sequence.txt
echo "---------------------------------------------------"
awk '
    BEGIN {
        current_header = ""
        current_seq = ""
    }

    /^>/ {
        if (current_seq != "") {
            gc_count = 0
            len = length(current_seq)
            gc_count += gsub(/[gG]/, "&", current_seq)
            gc_count += gsub(/[cC]/, "&", current_seq)

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
        current_seq = current_seq toupper($0)
    }
    END {
        if (current_seq != "") {
            gc_count = 0
            len = length(current_seq)
            
            gc_count += gsub(/[gG]/, "&", current_seq)
            gc_count += gsub(/[cC]/, "&", current_seq)
            
            if (len > 0) {
                gc_percent = (gc_count / len) * 100
                print current_header "\t" gc_percent "%"
            } else {
                print current_header "\t" "0.00%"
            }
        }
    }' "$file"
echo "---------------------------------------------------"
```
<img width="927" height="178" alt="image" src="https://github.com/user-attachments/assets/cf344dd0-6d9b-4f3c-a20e-556221cb35e6" />

## Q 5: Write a shell script to extract sequences longer than 30 bp and save them into a new FASTA file.
```
INPUT_FILE=Nucleotide_sequence.txt
OUTPUT_FILE="long_sequence.txt"
MIN_LENGTH=30
echo "---------------------------------------------------"
echo "Filtering sequences longer than $MIN_LENGTH bp from $INPUT_FILE..."

awk -v min="$MIN_LENGTH" '
/^>/ {
    if (len != "" && len > min) {
        print prev_header;
        print prev_sequence;
    }
    prev_header = $0;     # Save the current header line
    prev_sequence = "";   # Reset the sequence string
    len = 0;              # Reset the length count
    next;                 # Skip to the next line of input
}

/^$/ { 
    next;
}

{
    len += length($0);
    prev_sequence = prev_sequence $0;
}

END {
    if (len > min) {
        print prev_header;
        print prev_sequence;
    }
}' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Filtering complete."
echo "Results saved to '$OUTPUT_FILE'."
echo "Sequences found: $(grep -c "^>" "$OUTPUT_FILE")"
echo "---------------------------------------------------"
```
<img width="929" height="147" alt="image" src="https://github.com/user-attachments/assets/7092bc6d-be9f-4c8a-b5f9-e01fe377ac9b" />


## Q 6: Write a shell script to search for a given motif (ATG, TATA, CGC) inside all sequences and count how many times it occurs. 

```
INPUT_FILE=Nucleotide_sequence.txt
MOTIFS=("ATG" "TATA" "CGC") 

echo "--- Motif Search Results ---"
echo "Searching in $INPUT_FILE for: ${MOTIFS[*]}"
echo "------------------------------"

cleaned_sequence=$(grep -v '^>' "$INPUT_FILE" | tr -d '\n')

if [ -z "$cleaned_sequence" ]; then
    echo "No sequence data found to search."
    exit 0
fi

for motif in "${MOTIFS[@]}"; do
    count=$(echo "$cleaned_sequence" | grep -o -i -E "$motif" | wc -l)
    
    printf "Motif: %s\tCount: %d\n" "$motif" "$count"
done

echo "------------------------------"
```
<img width="768" height="175" alt="image" src="https://github.com/user-attachments/assets/7d908def-f13f-4c37-94f5-9ebded7e4ef4" />

## Q 7: Write a shell script that:
## -Reads each sequence from the FASTA file.
## -Calculates its length and GC content

```
INPUT_FILE=Nucleotide_sequence.txt

echo "Calculating length and GC content for each sequence..."
echo "--------------------------------------------------------"
awk '
    BEGIN {
        OFS="\t";
    }

    /^>/ {
       
        if (seq_id != "") {
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
```
<img width="1040" height="198" alt="image" src="https://github.com/user-attachments/assets/097cd1f6-3966-4ebc-bdd4-afec951ffdc3" />



