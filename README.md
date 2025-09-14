# Objective
The goal is to learn the various command of the bash to extract or process desired information from sequences(DNA/RNA/Protein).

## Q 1: Write the script to count how many sequences are in the FASTA file?
```
file=Nucleotide_sequence.txt

seq_count=$(grep -c "^>" $file)

# Printing the result in one go 
echo "Number of sequences found in $file are $seq_count."
```
<img width="845" height="46" alt="image" src="https://github.com/user-attachments/assets/fec88376-d5e1-4451-9b0f-0713545825df" />

## Q 2: Write a shell script to calculate the length of each sequence and display it as: Sequence_ID   Length
```
file=Nucleotide_sequence.txt
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
```
<img width="655" height="170" alt="image" src="https://github.com/user-attachments/assets/9c5eba40-8846-4306-bde1-3e568c221000" />


