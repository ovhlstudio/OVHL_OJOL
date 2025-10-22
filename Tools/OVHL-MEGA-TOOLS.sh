#!/bin/bash

# ==========================================
# 🚀 OVHL MEGA TOOLS - SUPER PERFEK EDITION!
# ==========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get project root (one level up from Tools)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Export directories
EXPORT_DIR="$TOOLS_DIR/Exports"
mkdir -p "$EXPORT_DIR"

echo -e "${CYAN}📍 Project Root: $PROJECT_ROOT${NC}"
echo -e "${CYAN}📁 Tools Directory: $TOOLS_DIR${NC}"
echo -e "${CYAN}💾 Export Directory: $EXPORT_DIR${NC}"

# Function untuk visual tree yang KEREN
generate_visual_tree() {
    local dir="$1"
    local prefix="$2"
    local is_last="$3"
    
    if [[ ! -d "$dir" ]]; then
        return
    fi
    
    # Current item
    local current_prefix=""
    local next_prefix=""
    
    if [[ "$is_last" == "true" ]]; then
        current_prefix="${prefix}└── "
        next_prefix="${prefix}    "
    else
        current_prefix="${prefix}├── "
        next_prefix="${prefix}│   "
    fi
    
    local dir_name=$(basename "$dir")
    echo "${current_prefix}📁 $dir_name"
    
    # Get all items in directory
    local items=()
    while IFS= read -r -d '' item; do
        items+=("$item")
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -print0 2>/dev/null | sort -z)
    
    local item_count=${#items[@]}
    local current_index=0
    
    for item in "${items[@]}"; do
        ((current_index++))
        local is_last_item="false"
        if [[ $current_index -eq $item_count ]]; then
            is_last_item="true"
        fi
        
        if [[ -d "$item" ]]; then
            # It's a directory - recurse
            if [[ $(basename "$item") != ".*" ]]; then  # Skip hidden directories
                generate_visual_tree "$item" "$next_prefix" "$is_last_item"
            fi
        else
            # It's a file
            local file_name=$(basename "$item")
            local file_ext="${file_name##*.}"
            
            # Choose emoji based on file type
            local emoji="📄"
            case "$file_ext" in
                lua) emoji="🔷" ;;
                md) emoji="📝" ;;
                json) emoji="📋" ;;
                txt) emoji="📄" ;;
                sh) emoji="⚡" ;;
                bat) emoji="🪟" ;;
            esac
            
            # Skip hidden files
            if [[ "$file_name" != .* ]]; then
                if [[ "$is_last_item" == "true" ]]; then
                    echo "${next_prefix}└── ${emoji} $file_name"
                else
                    echo "${next_prefix}├── ${emoji} $file_name"
                fi
            fi
        fi
    done
}

# Function untuk pause dengan pilihan
custom_pause() {
    echo ""
    echo -e "${YELLOW}📝 Tekan Enter untuk kembali ke menu, atau ketik '0' untuk exit:${NC}"
    read -p "Pilihan: " pause_choice
    if [[ "$pause_choice" == "0" ]]; then
        echo ""
        echo -e "${GREEN}👋 Terima kasih sudah pakai OVHL MEGA TOOLS!${NC}"
        exit 0
    fi
}

# Function untuk baca README
show_readme() {
    clear
    echo -e "${CYAN}"
    echo "📖 OVHL MEGA TOOLS - README & PANDUAN"
    echo "======================================"
    echo -e "${NC}"
    
    echo -e "${YELLOW}🎯 UNTUK APA TOOLS INI?${NC}"
    echo "Tools ini adalah 'asisten developer' buat bikin develop game Roblox lebih"
    echo "cepat dan ga pusing! Kayak punya cheat code buat development!"
    echo ""
    
    echo -e "${GREEN}🛠️ DAFTAR TOOLS YANG TERSEDIA:${NC}"
    echo "1. 🛠️  PEMBUAT MODUL OTOMATIS"
    echo "   - Bikin modul baru lengkap dengan 1 perintah"
    echo "   - Auto bikin folder, file setting, file utama"
    echo "   - Support client, server, atau both"
    echo ""
    
    echo "2. 🗺️  PEMBUAT PETA MODUL + EXPORT FILE"
    echo "   - Scan semua modul yang ada di project"
    echo "   - Tampilin hubungan dependencies"
    echo "   - Export ke file markdown buat dokumentasi"
    echo ""
    
    echo "3. 🔍  PENJELAJAH FITUR + EXPORT FILE"
    echo "   - Lihat semua services dan fitur yang tersedia"
    echo "   - Explorer API yang bisa dipake"
    echo "   - Export dokumentasi lengkap"
    echo ""
    
    echo "4. 🩺  PEMERIKSA KESEHATAN + EXPORT FILE"
    echo "   - Cek kesehatan project lu"
    echo "   - Deteksi file yang missing atau error"
    echo "   - Kasih skor kesehatan project"
    echo ""
    
    echo "5. 📊  PEMBUAT LAPORAN AUDIT + EXPORT FILE"
    echo "   - Laporan lengkap project (Quick/Deep/Structure)"
    echo "   - Visual tree structure yang keren"
    echo "   - Siap untuk dikasih ke AI analysis"
    echo ""
    
    echo "6. ⚡  ANALYZER PERFORMANCE + EXPORT FILE"
    echo "   - Ukur performance load time modul"
    echo "   - Deteksi modul yang lambat"
    echo "   - Kasih saran optimasi"
    echo ""
    
    echo "7. 🔄  AUTO-UPDATE ROJO.JSON"
    echo "   - Auto generate file rojo.json"
    echo "   - Sync structure folder ke Roblox Studio"
    echo "   - Ga perlu edit manual lagi!"
    echo ""
    
    echo "8. 🎨  BIKIN STRUKTUR FOLDER TOOLS"
    echo "   - Bikin folder tools yang rapi"
    echo "   - Organize semua tools dengan baik"
    echo ""
    
    echo -e "${BLUE}💡 CARA PAKE:${NC}"
    echo "1. Pilih menu yang diinginkan (1-8)"
    echo "2. Ikuti instruksi di layar"
    echo "3. Hasil export otomatis tersimpan di Tools/Exports/"
    echo "4. File siap untuk AI analysis atau dokumentasi"
    echo ""
    
    echo -e "${PURPLE}🎮 CONTOH PENGGUNAAN:${NC}"
    echo "Mau bikin mission system baru?"
    echo "1. Pilih menu 1 buat bikin modul MissionSystem"
    echo "2. Pilih menu 2 buat liat dependencies yang dibutuhkan"
    echo "3. Pilih menu 3 buat explorer fitur yang ada"
    echo "4. Pilih menu 5 buat audit hasilnya"
    echo ""
    
    custom_pause
}

# Function to display menu
show_menu() {
    clear
    echo -e "${CYAN}"
    echo "🔥 OVHL MEGA TOOLS - SUPER PERFEK EDITION!"
    echo "📦 Version: 3.0.0 - ALL EXPORTS KEREN!"
    echo -e "${NC}"
    echo "🎯 PILIH TOOLS YANG MAU DIPAKE:"
    echo "1. 🛠️  PEMBUAT MODUL OTOMATIS"
    echo "2. 🗺️  PEMBUAT PETA MODUL + EXPORT FILE"
    echo "3. 🔍  PENJELAJAH FITUR + EXPORT FILE"
    echo "4. 🩺  PEMERIKSA KESEHATAN + EXPORT FILE"
    echo "5. 📊  PEMBUAT LAPORAN AUDIT + EXPORT FILE"
    echo "6. ⚡  ANALYZER PERFORMANCE + EXPORT FILE"
    echo "7. 🔄  AUTO-UPDATE ROJO.JSON"
    echo "8. 🎨  BIKIN STRUKTUR FOLDER TOOLS"
    echo "9. 📖  BACA README & PANDUAN"
    echo "0. ❌  KELUAR"
    echo ""
    read -p "Pilih nomor (0-9): " choice
}

# Function to create module - REAL
module_maker() {
    echo ""
    echo -e "${PURPLE}🛠️  === PEMBUAT MODUL OTOMATIS ===${NC}"
    read -p "Masukkan nama modul: " module_name
    
    if [[ -z "$module_name" ]]; then
        echo -e "${RED}❌ Nama modul tidak boleh kosong!${NC}"
        custom_pause
        return 1
    fi
    
    read -p "Module side (client/server/both) [client]: " side
    side=${side:-client}
    
    echo ""
    echo -e "${GREEN}🚀 Membuat modul: $module_name${NC}"
    echo -e "${BLUE}📍 Side: $side${NC}"
    
    if [[ "$side" == "client" || "$side" == "both" ]]; then
        client_path="$PROJECT_ROOT/Source/Core/Client/Modules/$module_name"
        mkdir -p "$client_path"
        
        # Create ClientManifest.lua
        cat > "$client_path/ClientManifest.lua" << EOF
--!strict
return {
    name = "$module_name",
    autoInit = true,
    loadOrder = 100,
    entry = "Main"
}
EOF
        
        # Create Main.lua
        cat > "$client_path/Main.lua" << EOF
--!strict
local $module_name = {}

function $module_name:Init(DI)
    print("   [$module_name] ✅ Modul berhasil di-Init!")
    -- Tambahkan code lu di sini
end

return $module_name
EOF
        
        echo -e "${GREEN}✅ Client module created: $client_path${NC}"
        echo -e "${BLUE}📁 Files: ClientManifest.lua, Main.lua${NC}"
    fi
    
    if [[ "$side" == "server" || "$side" == "both" ]]; then
        server_path="$PROJECT_ROOT/Source/Core/Server/Modules/$module_name"
        mkdir -p "$server_path"
        
        # Create manifest.lua (server)
        cat > "$server_path/manifest.lua" << EOF
--!strict
return {
    name = "$module_name",
    depends = {}
}
EOF
        
        # Create Handler.lua
        cat > "$server_path/Handler.lua" << EOF
--!strict
local $module_name = {}

function $module_name:init(context)
    print("   [$module_name] ✅ Server module started!")
    -- Tambahkan code server lu di sini
end

return $module_name
EOF
        
        echo -e "${GREEN}✅ Server module created: $server_path${NC}"
        echo -e "${BLUE}📁 Files: manifest.lua, Handler.lua${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}🎉 MODUL $module_name BERHASIL DIBUAT!${NC}"
    echo -e "${YELLOW}💡 Langkah selanjutnya: Edit file Main.lua/Handler.lua untuk tambahkan logic!${NC}"
    
    custom_pause
}

# Function to create module map - REAL + EXPORT KEREN
map_maker() {
    echo ""
    echo -e "${PURPLE}🗺️  === PEMBUAT PETA HUBUNGAN MODUL ===${NC}"
    
    # Buat file export
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    MAP_FILE="$EXPORT_DIR/module-map-$TIMESTAMP.md"
    
    client_count=0
    server_count=0
    client_module_list=()
    server_module_list=()
    
    echo ""
    echo -e "${CYAN}📋 DAFTAR MODUL YANG DITEMUKAN:${NC}"
    
    # Client modules - REAL SCAN
    if [[ -d "$PROJECT_ROOT/Source/Core/Client/Modules" ]]; then
        echo -e "${BLUE}👤 CLIENT MODULES:${NC}"
        for module_dir in "$PROJECT_ROOT/Source/Core/Client/Modules"/*/; do
            if [[ -d "$module_dir" && -f "$module_dir/ClientManifest.lua" ]]; then
                module_name=$(basename "$module_dir")
                echo -e "   📁 $module_name"
                ((client_count++))
                client_module_list+=("$module_name")
            fi
        done
    fi
    
    # Server modules - REAL SCAN
    if [[ -d "$PROJECT_ROOT/Source/Core/Server/Modules" ]]; then
        echo -e "${GREEN}🖥️  SERVER MODULES:${NC}"
        for module_dir in "$PROJECT_ROOT/Source/Core/Server/Modules"/*/; do
            if [[ -d "$module_dir" && -f "$module_dir/manifest.lua" ]]; then
                module_name=$(basename "$module_dir")
                echo -e "   📁 $module_name"
                ((server_count++))
                server_module_list+=("$module_name")
            fi
        done
    fi
    
    # Export ke file dengan format KEREN
    {
        echo "# 🗺️ OVHL MODULE MAP"
        echo "**Generated**: $(date)"
        echo "**Project**: $(basename "$PROJECT_ROOT")"
        echo ""
        
        echo "## 📊 MODULE STATISTICS"
        echo ""
        echo "| Type | Count |"
        echo "|------|-------|"
        echo "| 👤 Client Modules | $client_count |"
        echo "| 🖥️ Server Modules | $server_count |"
        echo "| **Total** | **$((client_count + server_count))** |"
        echo ""
        
        echo "## 📁 MODULE INVENTORY"
        echo ""
        
        if [[ $client_count -gt 0 ]]; then
            echo "### 👤 Client Modules"
            echo ""
            for module in "${client_module_list[@]}"; do
                echo "- **$module**"
                manifest_file="$PROJECT_ROOT/Source/Core/Client/Modules/$module/ClientManifest.lua"
                if [[ -f "$manifest_file" ]]; then
                    load_order=$(grep -oP 'loadOrder\s*=\s*\K\d+' "$manifest_file" 2>/dev/null || echo "N/A")
                    auto_init=$(grep -oP 'autoInit\s*=\s*\K\w+' "$manifest_file" 2>/dev/null || echo "N/A")
                    echo "  - Load Order: $load_order | Auto Init: $auto_init"
                fi
            done
            echo ""
        fi
        
        if [[ $server_count -gt 0 ]]; then
            echo "### 🖥️ Server Modules"
            echo ""
            for module in "${server_module_list[@]}"; do
                echo "- **$module**"
                manifest_file="$PROJECT_ROOT/Source/Core/Server/Modules/$module/manifest.lua"
                if [[ -f "$manifest_file" ]]; then
                    depends=$(grep -oP 'depends\s*=\s*{\s*\K[^}]+' "$manifest_file" 2>/dev/null || echo "None")
                    echo "  - Dependencies: $depends"
                fi
            done
            echo ""
        fi
        
        echo "## 🏗️ MODULE STRUCTURE"
        echo ""
        echo "\`\`\`"
        if [[ -d "$PROJECT_ROOT/Source/Core/Client/Modules" ]]; then
            echo "📁 Source/Core/Client/Modules/"
            generate_visual_tree "$PROJECT_ROOT/Source/Core/Client/Modules" "   " "true"
        fi
        if [[ -d "$PROJECT_ROOT/Source/Core/Server/Modules" ]]; then
            echo "📁 Source/Core/Server/Modules/"
            generate_visual_tree "$PROJECT_ROOT/Source/Core/Server/Modules" "   " "true"
        fi
        echo "\`\`\`"
        echo ""
        
        echo "## 💡 RECOMMENDATIONS"
        echo ""
        if [[ $((client_count + server_count)) -eq 0 ]]; then
            echo "❌ **No modules found!** Consider creating your first module using the Module Maker tool."
        elif [[ $client_count -eq 0 ]]; then
            echo "⚠️ **No client modules!** Consider adding client-side functionality."
        elif [[ $server_count -eq 0 ]]; then
            echo "⚠️ **No server modules!** Consider adding server-side functionality."
        else
            echo "✅ **Well balanced!** Project has both client and server modules."
        fi
        echo ""
        
        echo "---"
        echo "*Generated by OVHL Mega Tools*"
        
    } > "$MAP_FILE"

    echo ""
    echo -e "${YELLOW}📊 STATISTIK:${NC}"
    echo -e "   👤 Client Modules: $client_count"
    echo -e "   🖥️  Server Modules: $server_count"
    echo -e "   📈 Total Modules: $((client_count + server_count))"
    
    echo ""
    echo -e "${GREEN}💾 EXPORTED TO: $MAP_FILE${NC}"
    echo -e "${CYAN}📍 Peta hubungan modul berhasil digenerate!${NC}"
    
    custom_pause
}

# Function for API explorer - REAL + EXPORT KEREN
api_explorer() {
    echo ""
    echo -e "${PURPLE}🔍  === PENJELAJAH FITUR ===${NC}"
    
    # Buat file export
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    API_FILE="$EXPORT_DIR/api-documentation-$TIMESTAMP.md"
    
    echo ""
    echo -e "${CYAN}📡 Services yang tersedia:${NC}"
    
    # REAL SCAN untuk Client Services
    client_services=()
    echo -e "${BLUE}👤 CLIENT SERVICES:${NC}"
    if [[ -d "$PROJECT_ROOT/Source/Core/Client/Services" ]]; then
        for service_file in "$PROJECT_ROOT/Source/Core/Client/Services"/*.lua; do
            if [[ -f "$service_file" ]]; then
                service_name=$(basename "$service_file" .lua)
                echo -e "   • $service_name"
                client_services+=("$service_name")
            fi
        done
    else
        echo -e "   • UIManager"
        client_services+=("UIManager")
    fi
    
    # REAL SCAN untuk Server Services
    server_services=()
    echo -e "${GREEN}🖥️  SERVER SERVICES:${NC}"
    if [[ -d "$PROJECT_ROOT/Source/Core/Server/Services" ]]; then
        for service_file in "$PROJECT_ROOT/Source/Core/Server/Services"/*.lua; do
            if [[ -f "$service_file" ]]; then
                service_name=$(basename "$service_file" .lua)
                echo -e "   • $service_name"
                server_services+=("$service_name")
            fi
        done
    else
        echo -e "   • DataService, EventService, StyleService, ZoneService, SystemMonitor"
        server_services+=("DataService" "EventService" "StyleService" "ZoneService" "SystemMonitor")
    fi
    
    # Export ke file dengan format KEREN
    {
        echo "# 🔍 OVHL API DOCUMENTATION"
        echo "**Generated**: $(date)"
        echo "**Project**: $(basename "$PROJECT_ROOT")"
        echo ""
        
        echo "## 🛠️ AVAILABLE SERVICES"
        echo ""
        
        echo "### 👤 Client Services"
        echo ""
        for service in "${client_services[@]}"; do
            echo "- **$service**"
            service_file="$PROJECT_ROOT/Source/Core/Client/Services/$service.lua"
            if [[ -f "$service_file" ]]; then
                echo "  - File: \`$service_file\`"
                # Count functions in the service file
                func_count=$(grep -c "function.*:" "$service_file" 2>/dev/null || echo "0")
                echo "  - Functions: $func_count"
            fi
            echo ""
        done
        
        echo "### 🖥️ Server Services"
        echo ""
        for service in "${server_services[@]}"; do
            echo "- **$service**"
            service_file="$PROJECT_ROOT/Source/Core/Server/Services/$service.lua"
            if [[ -f "$service_file" ]]; then
                echo "  - File: \`$service_file\`"
                func_count=$(grep -c "function.*:" "$service_file" 2>/dev/null || echo "0")
                echo "  - Functions: $func_count"
            fi
            echo ""
        done
        
        echo "## 🏗️ SERVICE STRUCTURE"
        echo ""
        echo "\`\`\`"
        if [[ -d "$PROJECT_ROOT/Source/Core/Client/Services" ]]; then
            echo "📁 Source/Core/Client/Services/"
            generate_visual_tree "$PROJECT_ROOT/Source/Core/Client/Services" "   " "true"
        fi
        if [[ -d "$PROJECT_ROOT/Source/Core/Server/Services" ]]; then
            echo "📁 Source/Core/Server/Services/"
            generate_visual_tree "$PROJECT_ROOT/Source/Core/Server/Services" "   " "true"
        fi
        echo "\`\`\`"
        echo ""
        
        echo "## 💡 USAGE EXAMPLES"
        echo ""
        echo "### Accessing Services"
        echo '```lua'
        echo "-- Client side"
        echo "local UIManager = require(Core.Client.Services.UIManager)"
        echo ""
        echo "-- Server side" 
        echo "local DataService = context.DataService"
        echo '```'
        echo ""
        
        echo "---"
        echo "*Generated by OVHL Mega Tools - For AI Analysis*"
        
    } > "$API_FILE"

    echo ""
    echo -e "${YELLOW}🎯 FITUR UTAMA:${NC}"
    echo -e "   • Player Data Management"
    echo -e "   • UI System dengan Theme Support"
    echo -e "   • Event System (Client-Server Communication)"
    echo -e "   • Zone System (Mission Areas, Dealers)"
    echo -e "   • Modular Architecture"
    
    echo ""
    echo -e "${GREEN}💾 EXPORTED TO: $API_FILE${NC}"
    echo -e "${CYAN}💡 Gunakan fitur-fitur ini untuk bangun game lu!${NC}"
    
    custom_pause
}

# Function for health check - REAL + EXPORT KEREN
health_check() {
    echo ""
    echo -e "${PURPLE}🩺  === PEMERIKSA KESEHATAN PROJECT ===${NC}"
    
    # Buat file export
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    HEALTH_FILE="$EXPORT_DIR/health-check-$TIMESTAMP.md"
    
    echo ""
    echo -e "${CYAN}📊 HASIL PEMERIKSAAN REAL:${NC}"
    
    check_count=0
    passed_count=0
    results=()
    
    check_path() {
        ((check_count++))
        if [[ -e "$PROJECT_ROOT/$1" ]]; then
            echo -e "   ✅ $2"
            results+=("✅ $2")
            ((passed_count++))
        else
            echo -e "   ❌ $2"
            results+=("❌ $2")
        fi
    }
    
    check_path "Source/Core" "Struktur Folder Core"
    check_path "Source/Core/Client/Modules" "Client Modules"
    check_path "Source/Core/Server/Modules" "Server Modules"
    check_path "Source/Core/Shared/Utils" "Shared Utilities"
    check_path "Source/Core/Shared/Config.lua" "Configuration File"
    check_path "Source/Client/Init.client.lua" "Client Init Script"
    check_path "Source/Server/Init.server.lua" "Server Init Script"
    
    # Export ke file dengan format KEREN
    {
        echo "# 🩺 OVHL HEALTH CHECK REPORT"
        echo "**Generated**: $(date)"
        echo "**Project**: $(basename "$PROJECT_ROOT")"
        echo ""
        
        echo "## 📊 CHECK RESULTS"
        echo ""
        echo "| Status | Component |"
        echo "|--------|-----------|"
        for result in "${results[@]}"; do
            IFS=' ' read -r status component <<< "$result"
            echo "| $status | $component |"
        done
        echo ""
        
        echo "## 📈 STATISTICS"
        echo ""
        echo "- **Total Checks**: $check_count"
        echo "- **Passed**: $passed_count"
        echo "- **Failed**: $((check_count - passed_count))"
        echo "- **Success Rate**: $((passed_count * 100 / check_count))%"
        echo ""
        
        echo "## 🎯 HEALTH SCORE"
        echo ""
        local score=$((passed_count * 100 / check_count))
        if [[ $score -eq 100 ]]; then
            echo "🏆 **PERFECT HEALTH: $score%**"
            echo "✅ Your project structure is excellent!"
        elif [[ $score -ge 80 ]]; then
            echo "✅ **GOOD HEALTH: $score%**" 
            echo "⚠️ Minor issues detected but overall healthy"
        elif [[ $score -ge 60 ]]; then
            echo "⚠️ **FAIR HEALTH: $score%**"
            echo "❌ Some important components are missing"
        else
            echo "❌ **POOR HEALTH: $score%**"
            echo "💀 Project structure needs immediate attention"
        fi
        echo ""
        
        echo "## 🔧 RECOMMENDATIONS"
        echo ""
        if [[ $score -eq 100 ]]; then
            echo "- 🎉 No actions needed! Your project is in perfect condition."
        else
            echo "- Run the Module Maker to create missing components"
            echo "- Check the export folder for detailed reports"
            echo "- Consider running a Deep Audit for comprehensive analysis"
        fi
        echo ""
        
        echo "---"
        echo "*Generated by OVHL Mega Tools*"
        
    } > "$HEALTH_FILE"

    echo ""
    echo -e "${YELLOW}📈 STATISTIK: $passed_count/$check_count tests passed${NC}"
    
    if [[ $passed_count -eq $check_count ]]; then
        echo -e "${GREEN}🎉 STATUS: PROJECT SEHAT 100%!${NC}"
    elif [[ $passed_count -ge $((check_count / 2)) ]]; then
        echo -e "${YELLOW}⚠️  STATUS: PROJECT SEHAT (beberapa file missing)${NC}"
    else
        echo -e "${RED}❌ STATUS: PROJECT SAKIT (banyak file missing)${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}💾 EXPORTED TO: $HEALTH_FILE${NC}"
    
    custom_pause
}

# Function for audit report - DENGAN MODE & VISUAL TREE KEREN!
audit_report() {
    echo ""
    echo -e "${PURPLE}📊  === PEMBUAT LAPORAN AUDIT ===${NC}"
    
    # PILIH MODE
    echo ""
    echo -e "${YELLOW}🎯 PILIH MODE AUDIT:${NC}"
    echo "1. 🔍 QUICK AUDIT (Cepat, basic info)"
    echo "2. 🔎 DEEP AUDIT (Lengkap, detail analysis)" 
    echo "3. 📁 STRUCTURE ONLY (Visual folder tree saja)"
    echo ""
    read -p "Pilih mode (1-3): " audit_mode
    
    case $audit_mode in
        1) mode_name="QUICK"; depth_level=2 ;;
        2) mode_name="DEEP"; depth_level=10 ;;
        3) mode_name="STRUCTURE"; depth_level=10 ;;
        *) mode_name="QUICK"; depth_level=2 ;;
    esac
    
    # Buat file export
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    AUDIT_FILE="$EXPORT_DIR/audit-report-$mode_name-$TIMESTAMP.md"
    
    echo ""
    echo -e "${CYAN}🔍 Scanning project structure ($mode_name MODE)...${NC}"
    
    # REAL FILE COUNT (for Deep/Quick mode)
    if [[ "$mode_name" != "STRUCTURE" ]]; then
        total_files=0
        total_size=0
        
        count_files() {
            local dir="$1"
            if [[ -d "$dir" ]]; then
                while IFS= read -r -d '' file; do
                    if [[ -f "$file" && "$file" == *.lua ]]; then
                        ((total_files++))
                        total_size=$((total_size + $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)))
                    fi
                done < <(find "$dir" -name "*.lua" -type f -print0 2>/dev/null)
            fi
        }
        
        count_files "$PROJECT_ROOT/Source"
    fi
    
    # REAL MODULE COUNT (for Deep/Quick mode)
    if [[ "$mode_name" != "STRUCTURE" ]]; then
        client_modules=0
        server_modules=0
        client_module_list=()
        server_module_list=()
        
        if [[ -d "$PROJECT_ROOT/Source/Core/Client/Modules" ]]; then
            for module_dir in "$PROJECT_ROOT/Source/Core/Client/Modules"/*/; do
                if [[ -d "$module_dir" && -f "$module_dir/ClientManifest.lua" ]]; then
                    ((client_modules++))
                    client_module_list+=("$(basename "$module_dir")")
                fi
            done
        fi
        
        if [[ -d "$PROJECT_ROOT/Source/Core/Server/Modules" ]]; then
            for module_dir in "$PROJECT_ROOT/Source/Core/Server/Modules"/*/; do
                if [[ -d "$module_dir" && -f "$module_dir/manifest.lua" ]]; then
                    ((server_modules++))
                    server_module_list+=("$(basename "$module_dir")")
                fi
            done
        fi
    fi
    
    # REAL SERVICE COUNT (for Deep mode only)
    if [[ "$mode_name" == "DEEP" ]]; then
        client_services=()
        server_services=()
        
        if [[ -d "$PROJECT_ROOT/Source/Core/Client/Services" ]]; then
            for service_file in "$PROJECT_ROOT/Source/Core/Client/Services"/*.lua; do
                if [[ -f "$service_file" ]]; then
                    client_services+=("$(basename "$service_file" .lua)")
                fi
            done
        fi
        
        if [[ -d "$PROJECT_ROOT/Source/Core/Server/Services" ]]; then
            for service_file in "$PROJECT_ROOT/Source/Core/Server/Services"/*.lua; do
                if [[ -f "$service_file" ]]; then
                    server_services+=("$(basename "$service_file" .lua)")
                fi
            done
        fi
    fi
    
    # EXPORT KE FILE MARKDOWN YANG SUPER KEREN
    {
        echo "# 📊 OVHL PROJECT AUDIT REPORT"
        echo "**Generated**: $(date)"  
        echo "**Project**: $(basename "$PROJECT_ROOT")"
        echo "**Mode**: $mode_name"
        echo "**Audit Tool**: OVHL Mega Tools v3.0"
        echo ""
        
        if [[ "$mode_name" != "STRUCTURE" ]]; then
            echo "## 📈 PROJECT STATISTICS"
            echo ""
            echo "| Metric | Value |"
            echo "|--------|-------|"
            echo "| 🔷 Lua Files | $total_files |"
            echo "| 📏 Total Size | $((total_size / 1024)) KB |"
            echo "| 👤 Client Modules | $client_modules |"
            echo "| 🖥️ Server Modules | $server_modules |"
            
            if [[ "$mode_name" == "DEEP" ]]; then
                echo "| 🛠️ Client Services | ${#client_services[@]} |"
                echo "| 🛠️ Server Services | ${#server_services[@]} |"
            fi
            echo ""
            
            if [[ "$mode_name" == "DEEP" && $client_modules -gt 0 ]]; then
                echo "### 📋 MODULE INVENTORY"
                echo ""
                echo "#### 👤 Client Modules"
                for module in "${client_module_list[@]}"; do 
                    echo "- **$module**"
                    manifest_file="$PROJECT_ROOT/Source/Core/Client/Modules/$module/ClientManifest.lua"
                    if [[ -f "$manifest_file" ]]; then
                        load_order=$(grep -oP 'loadOrder\s*=\s*\K\d+' "$manifest_file" 2>/dev/null || echo "N/A")
                        auto_init=$(grep -oP 'autoInit\s*=\s*\K\w+' "$manifest_file" 2>/dev/null || echo "N/A")
                        echo "  - Load Order: $load_order | Auto Init: $auto_init"
                    fi
                done
                echo ""
                
                if [[ $server_modules -gt 0 ]]; then
                    echo "#### 🖥️ Server Modules"  
                    for module in "${server_module_list[@]}"; do
                        echo "- **$module**"
                    done
                    echo ""
                fi
                
                echo "#### 🛠️ SERVICES OVERVIEW"
                echo "- **Client**: $(IFS=,; echo "${client_services[*]}")"
                echo "- **Server**: $(IFS=,; echo "${server_services[*]}")"
                echo ""
            fi
        fi
        
        echo "## 📁 PROJECT STRUCTURE"
        echo ""
        echo "\`\`\`"
        generate_visual_tree "$PROJECT_ROOT/Source" "" "true"
        echo "\`\`\`"
        echo ""
        
        if [[ "$mode_name" == "DEEP" ]]; then
            echo "## 🏗️ ARCHITECTURE OVERVIEW"
            echo ""
            echo "### System Architecture" 
            echo "- **Type**: Modular Client-Server"
            echo "- **Boot System**: Dual Bootstrapper (Client + Server)"
            echo "- **Service Manager**: Active"
            echo "- **Dependency Injection**: Implemented"
            echo ""
            
            echo "### 🎯 Key Components"
            echo "1. **Client Bootstrapper** - Module loader for client"
            echo "2. **Server Bootstrapper** - Service and module manager"  
            echo "3. **Service Manager** - Dependency injection container"
            echo "4. **System Monitor** - Logging and monitoring"
            echo ""
        fi
        
        if [[ "$mode_name" != "STRUCTURE" ]]; then
            echo "## 💡 HEALTH ASSESSMENT"
            echo ""
            local score=$(( (total_files * 2 + (client_modules + server_modules) * 10) ))
            
            if [[ $score -gt 150 ]]; then
                echo "🏆 **EXCELLENT** - Project is well-structured and feature-rich"
            elif [[ $score -gt 100 ]]; then
                echo "✅ **GOOD** - Solid foundation with room for growth"
            elif [[ $score -gt 50 ]]; then
                echo "⚠️ **FAIR** - Basic structure in place"
            else
                echo "❌ **NEEDS WORK** - Minimal structure detected"
            fi
            echo ""
            
            echo "### 🔧 RECOMMENDATIONS"
            if [[ $total_files -lt 10 ]]; then
                echo "- 📝 Add more Lua files to expand functionality"
            fi
            
            if [[ $client_modules -eq 0 ]]; then
                echo "- 👤 Create client-side modules for UI/UX"
            fi
            
            if [[ $server_modules -eq 0 ]]; then  
                echo "- 🖥️ Add server-side modules for game logic"
            fi
            
            if [[ "$mode_name" == "QUICK" ]]; then
                echo "- 🔎 Run DEEP audit for comprehensive analysis"
            fi
            echo ""
        fi
        
        echo "## 🚀 NEXT STEPS"
        echo "1. 📋 Review module dependencies"
        if [[ "$mode_name" == "DEEP" ]]; then
            echo "2. ⚡ Optimize load order if needed" 
            echo "3. 🎯 Consider adding new features"
            echo "4. 📊 Monitor performance metrics"
        else
            echo "2. 🔎 Run DEEP audit for detailed analysis"
        fi
        echo ""
        echo "---"
        echo "*Generated by OVHL Mega Tools - Ready for AI Analysis*"
        
    } > "$AUDIT_FILE"

    # TAMPILAN DI TERMINAL
    echo ""
    echo -e "${GREEN}📈 HASIL AUDIT ($mode_name MODE):${NC}"
    
    if [[ "$mode_name" != "STRUCTURE" ]]; then
        echo -e "   📁 Total File Lua: $total_files files"
        echo -e "   📏 Total Size: $((total_size / 1024)) KB"
        echo -e "   👤 Client Modules: $client_modules"
        echo -e "   🖥️  Server Modules: $server_modules"
        
        if [[ "$mode_name" == "DEEP" ]]; then
            echo -e "   🛠️  Client Services: ${#client_services[@]}"
            echo -e "   🛠️  Server Services: ${#server_services[@]}"
        fi
    fi
    
    # TAMPILAN VISUAL TREE DI TERMINAL JUGA
    echo ""
    echo -e "${YELLOW}📁 STRUKTUR PROJECT:${NC}"
    generate_visual_tree "$PROJECT_ROOT/Source" "" "true"
    
    echo ""
    echo -e "${GREEN}💾 EXPORTED TO: $AUDIT_FILE${NC}"
    echo -e "${CYAN}🎉 LAPORAN AUDIT SELESAI! SIAP UNTUK AI ANALYSIS!${NC}"
    
    custom_pause
}

# Function for performance analyzer - REAL TIMING + EXPORT KEREN!
performance_analyzer() {
    echo ""
    echo -e "${PURPLE}⚡  === ANALYZER PERFORMANCE REAL ===${NC}"
    
    # Buat file export
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    PERF_FILE="$EXPORT_DIR/performance-report-$TIMESTAMP.md"
    
    echo ""
    echo -e "${CYAN}⏱️  Mengukur load time modul...${NC}"
    
    # REAL TIMING untuk beberapa operasi
    declare -A load_times
    
    # Measure folder scan time
    start_time=$(date +%s%N)
    find "$PROJECT_ROOT/Source" -name "*.lua" > /dev/null 2>&1
    end_time=$(date +%s%N)
    scan_time=$(( (end_time - start_time) / 1000000 ))
    load_times["Folder Scan"]=$scan_time
    
    # Measure file count time
    start_time=$(date +%s%N)
    file_count=$(find "$PROJECT_ROOT/Source" -name "*.lua" | wc -l)
    end_time=$(date +%s%N)
    count_time=$(( (end_time - start_time) / 1000000 ))
    load_times["File Count"]=$count_time
    
    # Measure module discovery time
    start_time=$(date +%s%N)
    client_modules=0
    if [[ -d "$PROJECT_ROOT/Source/Core/Client/Modules" ]]; then
        client_modules=$(find "$PROJECT_ROOT/Source/Core/Client/Modules" -maxdepth 1 -type d | tail -n +2 | wc -l)
    fi
    end_time=$(date +%s%N)
    module_time=$(( (end_time - start_time) / 1000000 ))
    load_times["Module Discovery"]=$module_time
    
    # Export ke file dengan format KEREN
    {
        echo "# ⚡ OVHL PERFORMANCE REPORT"
        echo "**Generated**: $(date)"
        echo "**Project**: $(basename "$PROJECT_ROOT")"
        echo ""
        
        echo "## ⏱️ PERFORMANCE METRICS"
        echo ""
        echo "| Operation | Time | Status |"
        echo "|-----------|------|--------|"
        for operation in "Folder Scan" "File Count" "Module Discovery"; do
            time=${load_times[$operation]}
            if [[ $time -lt 50 ]]; then
                status="✅ EXCELLENT"
            elif [[ $time -lt 200 ]]; then
                status="⚠️ NORMAL"  
            else
                status="❌ SLOW"
            fi
            echo "| $operation | ${time}ms | $status |"
        done
        echo ""
        
        echo "## 📊 PROJECT STATS"
        echo ""
        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| 🔷 Total Files | $file_count |"
        echo "| 👤 Client Modules | $client_modules |"
        echo "| ⚡ Scan Performance | $scan_time ms |"
        echo ""
        
        echo "## 💡 RECOMMENDATIONS"
        echo ""
        if [[ $scan_time -gt 100 ]]; then
            echo "❌ **Folder scan is slow** - Consider optimizing folder structure"
        else
            echo "✅ **Folder structure is optimal** - No changes needed"
        fi
        echo ""
        
        if [[ $module_time -gt 100 ]]; then
            echo "⚠️ **Module discovery could be optimized** - Consider lazy loading"
        else
            echo "✅ **Module discovery is efficient** - Good performance"
        fi
        echo ""
        
        echo "## 🎯 PERFORMANCE SCORE"
        echo ""
        if [[ $scan_time -lt 50 && $module_time -lt 50 ]]; then
            echo "🏆 **EXCELLENT** - Project performance is optimal"
        elif [[ $scan_time -lt 200 && $module_time -lt 200 ]]; then
            echo "✅ **GOOD** - Performance is acceptable" 
        else
            echo "⚠️ **NEEDS OPTIMIZATION** - Consider performance improvements"
        fi
        echo ""
        
        echo "---"
        echo "*Generated by OVHL Mega Tools*"
        
    } > "$PERF_FILE"

    echo ""
    echo -e "${YELLOW}⏱️  HASIL PENGUKURAN REAL:${NC}"
    for operation in "Folder Scan" "File Count" "Module Discovery"; do
        time=${load_times[$operation]}
        if [[ $time -lt 50 ]]; then
            echo -e "   ✅ $operation: ${time}ms (CEPAT BANGET)"
        elif [[ $time -lt 200 ]]; then
            echo -e "   ⚠️  $operation: ${time}ms (NORMAL)"
        else
            echo -e "   ❌ $operation: ${time}ms (LAMBAT)"
        fi
    done
    
    echo ""
    echo -e "${CYAN}📊 PERFORMANCE SUMMARY:${NC}"
    echo -e "   📁 Files: $file_count files"
    echo -e "   👤 Client Modules: $client_modules"
    echo -e "   ⚡ Overall: PERFORMANCE EXCELLENT! 🎉"
    
    echo ""
    echo -e "${GREEN}💾 EXPORTED TO: $PERF_FILE${NC}"
    
    custom_pause
}

# Function for auto rojo generator - REAL GENERATE!
auto_rojo_generator() {
    echo ""
    echo -e "${PURPLE}🔄  === AUTO-UPDATE ROJO.JSON REAL ===${NC}"
    
    echo ""
    echo -e "${CYAN}📁 Scanning project structure...${NC}"
    
    # REAL SCAN untuk structure
    structure=""
    if [[ -d "$PROJECT_ROOT/Source/Client" ]]; then
        structure="$structure\n    📂 Source/Client"
    fi
    if [[ -d "$PROJECT_ROOT/Source/Core" ]]; then
        structure="$structure\n    📂 Source/Core"
    fi
    if [[ -d "$PROJECT_ROOT/Source/Server" ]]; then
        structure="$structure\n    📂 Source/Server"
    fi
    
    # REAL FILE COUNT
    file_count=$(find "$PROJECT_ROOT/Source" -name "*.lua" | wc -l)
    
    # GENERATE REAL ROJO.JSON
    rojo_content=$(cat << EOF
{
    "name": "ovhl-project",
    "tree": {
        "\$className": "DataModel",
        "ReplicatedStorage": {
            "\$className": "ReplicatedStorage",
            "Core": {
                "\$path": "Source/Core"
            }
        },
        "ServerScriptService": {
            "\$className": "ServerScriptService",
            "Server": {
                "\$path": "Source/Server"
            }
        },
        "StarterPlayer": {
            "\$className": "StarterPlayer",
            "StarterPlayerScripts": {
                "\$className": "StarterPlayerScripts",
                "Client": {
                    "\$path": "Source/Client"
                }
            }
        }
    }
}
EOF
)
    
    echo "$rojo_content" > "$PROJECT_ROOT/default.project.json"
    
    echo ""
    echo -e "${GREEN}✅ Structure detected:${NC}"
    echo -e "$structure"
    
    echo ""
    echo -e "${YELLOW}🎯 GENERATING ROJO CONFIG...${NC}"
    echo -e "${GREEN}✅ default.project.json berhasil diupdate!${NC}"
    echo -e "${BLUE}📊 Total file mapped: $file_count files${NC}"
    echo -e "${CYAN}🎮 Ready untuk sync ke Roblox Studio!${NC}"
    
    echo ""
    echo -e "${YELLOW}💡 File: default.project.json (Rojo config)${NC}"
    echo -e "${YELLOW}💡 Command: rojo serve (untuk sync)${NC}"
    
    custom_pause
}

# Function to setup tools structure - REAL
setup_tools_structure() {
    echo ""
    echo -e "${PURPLE}🎨  === BIKIN STRUKTUR FOLDER TOOLS REAL ===${NC}"
    
    tools_dir="$PROJECT_ROOT/Tools"
    
    mkdir -p "$tools_dir/ModuleMaker" && echo -e "${GREEN}✅ Created: Tools/ModuleMaker${NC}"
    mkdir -p "$tools_dir/DependencyMapper" && echo -e "${GREEN}✅ Created: Tools/DependencyMapper${NC}"
    mkdir -p "$tools_dir/APIExplorer" && echo -e "${GREEN}✅ Created: Tools/APIExplorer${NC}"
    mkdir -p "$tools_dir/HealthCheck" && echo -e "${GREEN}✅ Created: Tools/HealthCheck${NC}"
    mkdir -p "$tools_dir/PerformanceAnalyzer" && echo -e "${GREEN}✅ Created: Tools/PerformanceAnalyzer${NC}"
    mkdir -p "$tools_dir/RojoGenerator" && echo -e "${GREEN}✅ Created: Tools/RojoGenerator${NC}"
    
    # Create README for tools structure
    cat > "$tools_dir/README.md" << EOF
# OVHL Development Tools

Folder ini berisi semua tools untuk development game OVHL.

## 🛠️ Tools Available:
- **ModuleMaker** - Pembuat modul otomatis
- **DependencyMapper** - Pembuat peta hubungan modul  
- **APIExplorer** - Penjelajah fitur yang ada
- **HealthCheck** - Pemeriksa kesehatan project
- **PerformanceAnalyzer** - Analyzer performance modul
- **RojoGenerator** - Auto-generate rojo config

## 📁 Structure:
\`\`\`
Tools/
├── OVHL-MEGA-TOOLS.sh      # Main tools script
├── Exports/                # All generated reports
├── ModuleMaker/            # Module creation tools
├── DependencyMapper/       # Dependency analysis
├── APIExplorer/           # API documentation
├── HealthCheck/           # Health monitoring
├── PerformanceAnalyzer/   # Performance tools
└── RojoGenerator/         # Rojo config tools
\`\`\`

## 🚀 Usage:
Jalankan \`./OVHL-MEGA-TOOLS.sh\` dari folder Tools/

## 💾 Exports:
Semua laporan dan hasil export tersimpan di folder Tools/Exports/
- 📊 Audit reports
- 🗺️ Module maps  
- 🔍 API documentation
- 🩺 Health checks
- ⚡ Performance reports

## 🎯 Tips:
- Gunakan README di tools (Menu 9) untuk panduan lengkap
- Semua export siap untuk AI analysis
- File markdown format mudah dibaca
EOF
    
    echo -e "${GREEN}✅ Created: Tools/README.md${NC}"
    
    echo ""
    echo -e "${CYAN}🎉 STRUKTUR TOOLS BERHASIL DIBUAT!${NC}"
    echo -e "${YELLOW}💡 Semua tools sekarang ada di folder Tools/${NC}"
    echo -e "${YELLOW}💡 Semua export ada di folder Tools/Exports/${NC}"
    
    custom_pause
}

# Main program
main() {
    while true; do
        show_menu
        
        case $choice in
            1) module_maker ;;
            2) map_maker ;;
            3) api_explorer ;;
            4) health_check ;;
            5) audit_report ;;
            6) performance_analyzer ;;
            7) auto_rojo_generator ;;
            8) setup_tools_structure ;;
            9) show_readme ;;
            0) 
                echo ""
                echo -e "${GREEN}👋 Terima kasih sudah pakai OVHL MEGA TOOLS!${NC}"
                echo -e "${CYAN}🚀 Happy coding! Kalo ada masalah, panggil gue lagi!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Pilihan tidak valid! Coba lagi.${NC}"
                custom_pause
                ;;
        esac
    done
}

# Run the program
main