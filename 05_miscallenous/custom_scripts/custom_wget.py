import os

def custom_wget(input_script, output_script, download_dir):
    """
    Reads a shell script containing wget commands, extracts the URLs,
    and writes a new script that downloads them to 'download_dir'.
    """
    
    # 1. Open the input file to read and the output file to write
    with open(input_script, "r") as f_in, open(output_script, "w") as f_out:
        
        # 2. Iterate through the file line by line
        for line in f_in:
            line = line.strip()
            
            # Skip empty lines or comments (preserve them in output if you want)
            if not line or line.startswith("#"):
                f_out.write(line + "\n")
                continue
            
            # 3. Find the URL in the line safely
            # We look for a string containing "://" (like http:// or ftp://)
            parts = line.split()
            url = None
            for part in parts:
                if "://" in part:
                    url = part
                    break
            
            # 4. Write the new command if a URL was found
            if url:
                new_command = f"wget -P {download_dir} {url}\n"
                f_out.write(new_command)
            else:
                # If no URL found, just copy the original line (optional)
                f_out.write(line + "\n")

    print(f"Successfully created {output_script}")

# --- Example Usage ---
custom_wget("../../03_analysis-pipelines/pre-processing/ena-file-download-read_run-PRJNA603669-fastq_ftp-20251208-2251.sh",
             "../../03_analysis-pipelines/pre-processing/00_PRJNA603669_raw_fastq.sh", "../../02_data")