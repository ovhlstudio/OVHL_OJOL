#!/bin/bash

echo "🔍 OVHL PROJECT AUDIT TOOL"
echo "=========================="

# Buat folder Tools/Dev jika belum ada
mkdir -p Tools/Dev

echo "📁 Generating project_structure.txt..."
echo "=== OVHL PROJECT STRUCTURE ===" > Tools/Dev/project_structure.txt
echo "Generated on: $(date)" >> Tools/Dev/project_structure.txt
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')" >> Tools/Dev/project_structure.txt
echo "==============================" >> Tools/Dev/project_structure.txt
echo "" >> Tools/Dev/project_structure.txt

# List semua file .lua dengan struktur folder yang lebih rapi
echo "📂 PROJECT STRUCTURE:" >> Tools/Dev/project_structure.txt
find Source/ -name "*.lua" -type f | sort | sed 's|^Source/||' >> Tools/Dev/project_structure.txt

echo "" >> Tools/Dev/project_structure.txt
echo "=== SUMMARY ===" >> Tools/Dev/project_structure.txt
echo "Total Lua files: $(find Source/ -name "*.lua" -type f | wc -l)" >> Tools/Dev/project_structure.txt
echo "Total folders: $(find Source/ -type d | wc -l)" >> Tools/Dev/project_structure.txt

# File 2: Detailed File Contents
echo "📄 Generating file_contents.txt..."
echo "=== OVHL FILE CONTENTS ===" > Tools/Dev/file_contents.txt
echo "Generated on: $(date)" >> Tools/Dev/file_contents.txt
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')" >> Tools/Dev/file_contents.txt
echo "==========================" >> Tools/Dev/file_contents.txt
echo "" >> Tools/Dev/file_contents.txt

# Loop melalui semua file .lua dan tambahkan content-nya dengan format yang lebih clean
find Source/ -name "*.lua" -type f | sort | while read file; do
    echo "〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️" >> Tools/Dev/file_contents.txt
    echo "📄 FILE: $(echo $file | sed 's|^Source/||')" >> Tools/Dev/file_contents.txt
    echo "〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️" >> Tools/Dev/file_contents.txt
    echo "" >> Tools/Dev/file_contents.txt
    cat "$file" >> Tools/Dev/file_contents.txt
    echo -e "\n\n" >> Tools/Dev/file_contents.txt
done

echo "✅ AUDIT COMPLETE!"
echo "📁 Files saved to:"
echo "   - Tools/Dev/project_structure.txt"
echo "   - Tools/Dev/file_contents.txt"
echo ""
echo "📊 SUMMARY:"
echo "   - $(find Source/ -name "*.lua" -type f | wc -l) Lua files audited"
echo "   - Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo ""
echo "🎯 Untuk share ke AI, cukup kirim 2 file tersebut!"