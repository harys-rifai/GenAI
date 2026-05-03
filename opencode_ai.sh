#!/bin/bash
# Script to collect project source code for AI context
# Usage: sh opencode_ai.sh

OUTPUT_FILE="project_context_ai.txt"

echo "🔍 Collecting code context for AI..."
echo "Project: GenAI WhatsApp Bot" > $OUTPUT_FILE
echo "Generated on: $(date)" >> $OUTPUT_FILE
echo "========================================" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 1. Project Structure
echo "## 📂 Project Structure" >> $OUTPUT_FILE
echo '```' >> $OUTPUT_FILE
tree -a -I '.git|venv|node_modules|__pycache__|db.sqlite3|*.log|auth_info|service.pid' >> $OUTPUT_FILE
echo '```' >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# 2. File Contents
echo "## 📄 File Contents" >> $OUTPUT_FILE

# List of files to exclude
EXCLUDE_PATTERN="\.git|venv|node_modules|__pycache__|db\.sqlite3|.*\.log|auth_info|service\.pid|project_context_ai\.txt|.*\.png|.*\.jpg|.*\.pdf"

# Find all files and append their content
git ls-files | while read -r file; do
    # Check if file matches exclude pattern
    if [[ $file =~ $EXCLUDE_PATTERN ]]; then
        continue
    fi

    # Check if file is text (not binary)
    if file "$file" | grep -q "text"; then
        echo "Adding: $file"
        echo "----------------------------------------" >> $OUTPUT_FILE
        echo "File: $file" >> $OUTPUT_FILE
        echo "----------------------------------------" >> $OUTPUT_FILE
        echo '```' >> $OUTPUT_FILE
        cat "$file" >> $OUTPUT_FILE
        echo "" >> $OUTPUT_FILE
        echo '```' >> $OUTPUT_FILE
        echo "" >> $OUTPUT_FILE
    fi
done

echo "✅ Context collected in $OUTPUT_FILE"
echo "You can now share this file with any AI model."
