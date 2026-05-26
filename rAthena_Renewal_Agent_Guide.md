# rAthena Renewal Local Server — Agent Knowledge Base
> **Purpose**: This document is a structured knowledge base for an AI agent assisting with setup, configuration, troubleshooting, and customization of a Ragnarok Online Renewal private server using rAthena on Windows (offline/single-player).
> **Last Updated**: 2025
> **Scope**: Windows only, Renewal (RE) mode, single-player offline use

---

## AGENT INSTRUCTIONS
- Always ask for the user's exact folder paths before giving copy/move commands
- Always check what Visual Studio version the user has before giving cmake commands
- When user reports an error, ask for the full error text or screenshot before diagnosing
- Prefer PowerShell commands over CMD for file operations
- Remind user to start Laragon/MySQL BEFORE starting any server executable
- Server startup order is always: login-server → char-server → map-server (web-server optional)

---

## TABLE OF CONTENTS
1. [System Overview](#1-system-overview)
2. [Known Environment](#2-known-environment)
3. [Prerequisites](#3-prerequisites)
4. [Build Process](#4-build-process)
5. [Common Build Errors & Fixes](#5-common-build-errors--fixes)
6. [Required DLL Files](#6-required-dll-files)
7. [Server Configuration](#7-server-configuration)
8. [Database Setup](#8-database-setup)
9. [Starting the Server](#9-starting-the-server)
10. [Client Setup](#10-client-setup)
11. [Account & GM Setup](#11-account--gm-setup)
12. [Battle Configuration](#12-battle-configuration)
13. [NPC Scripting](#13-npc-scripting)
14. [Database Files](#14-database-files)
15. [Troubleshooting](#15-troubleshooting)
16. [File Path Reference](#16-file-path-reference)
17. [Online Resources](#17-online-resources)

---

## 1. SYSTEM OVERVIEW

### What is rAthena?
rAthena is an open-source C++ server emulator for Ragnarok Online. It replaces Gravity's proprietary server software and allows running a complete private/offline RO server.

### Server Architecture
rAthena runs as 4 separate processes that must ALL be running simultaneously:

| Process | Port | Role |
|---|---|---|
| login-server | 6900 | Account authentication |
| char-server | 6121 | Character management |
| map-server | 5121 | Core gameplay (maps, monsters, skills, NPCs) |
| web-server | 8080 | Optional web features |

### Game Mode: Renewal (RE)
- Database path: `db/re/`
- Max level: 175/60 (base/job) by default
- Jobs: 1st, 2nd, Transcendent, 3rd, 4th Expanded
- Compile flag: `PACKETVER_RE` must be defined
- Config files: Use `_re` variants of SQL files

---

## 2. KNOWN ENVIRONMENT

> **AGENT NOTE**: This section reflects the confirmed setup of the user this guide was created for. Update as user's environment changes.

| Component | Value |
|---|---|
| OS | Windows (Thai locale/Buddhist calendar — years shown as 256x) |
| Visual Studio | Visual Studio Community **2026** (version 18.6) |
| VS Install Path | `D:\Programs\Microsoft\18\VisualStudio` |
| CMake Generator | `"Visual Studio 18 2026"` |
| rAthena Path | `D:\Project_ROS\rathena\` |
| Laragon Path | `D:\Project_ROS\laragon\` |
| MySQL Version | mysql-8.4.3-winx64 |
| Built EXE Location | `D:\Project_ROS\rathena\Release\` |
| libmysql.dll source | `D:\Project_ROS\laragon\bin\heidisql\libmysql.dll` |
| libcrypto/libssl source | `D:\Project_ROS\laragon\bin\mysql\mysql-8.4.3-winx64\bin\` |
| PACKETVER | 20220406 |

### Project Folder Structure (User's Repo)
```
D:\rag_offline\RO_Renewal\
├── 1_Database\        ← Laragon / MySQL
├── 2_Server\          ← rAthena server files
├── 3_Client\          ← Ragnarok.exe + GRF files
└── 4_Openkore\        ← OpenKore bot (optional)
```

---

## 3. PREREQUISITES

### Required Software
| Software | Purpose | Download |
|---|---|---|
| Git | Clone rAthena repo | https://git-scm.com |
| Visual Studio 2026 (or 2019/2022) | C++ compiler | https://visualstudio.microsoft.com |
| CMake 3.32+ | Build system | https://cmake.org/download |
| Laragon Portable | MySQL + phpMyAdmin bundle | https://laragon.org |
| HeidiSQL | Database GUI | Bundled with Laragon |
| Notepad++ or VS Code | Config/script editing | https://notepad-plus-plus.org |
| kRO RE Client | Game client | Via RO Patcher Lite |
| NEMO Patcher | Client .exe patcher | https://github.com/MStr3am/NEMO |
| GRF Editor | GRF archive editor | https://rathena.org/board/topic/77080 |

### Required VS Workload
In Visual Studio Installer → **Workloads** tab → check:
- ✅ **Desktop development with C++**

This installs: MSVC compiler, Windows SDK, standard headers (stdint.h, cstddef, string, etc.), CMake tools.

### CMake Generator by VS Version
| Visual Studio | Version | CMake Generator String |
|---|---|---|
| VS 2019 | 16 | `"Visual Studio 16 2019"` |
| VS 2022 | 17 | `"Visual Studio 17 2022"` |
| VS 2026 | 18 | `"Visual Studio 18 2026"` |

### How to Detect VS Version
```powershell
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -all
```
Look for `installationVersion` and `displayName` in the output.

---

## 4. BUILD PROCESS

### Step 1 — Clone rAthena
```powershell
git clone https://github.com/rathena/rathena.git
cd rathena
```

### Step 2 — Configure with CMake
```powershell
cd D:\Project_ROS\rathena

# Delete any old build cache first
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

# Configure (replace generator with your VS version)
cmake -G "Visual Studio 18 2026" -A x64 `
  -DCMAKE_GENERATOR_INSTANCE="D:\Programs\Microsoft\18\VisualStudio" `
  -DPACKETVER=20220406 `
  -B build
```

### Step 3 — Build All
```powershell
cmake --build build --config Release 2>&1 | Tee-Object -FilePath D:\build_log.txt
```

### Step 4 — Verify Success
```powershell
Get-Item D:\Project_ROS\rathena\Release\*.exe | Select Name, LastWriteTime
```

### Expected Successful Output
```
Name                LastWriteTime
----                -------------
char-server.exe     [date]
csv2yaml.exe        [date]
login-server.exe    [date]
map-server.exe      [date]
mapcache.exe        [date]
web-server.exe      [date]
yaml2sql.exe        [date]
yamlupgrade.exe     [date]
```
Final line: `Build succeeded.` or `Build: 6 succeeded, 0 failed`

### Step 5 — Copy EXEs to Server Root
```powershell
Copy-Item D:\Project_ROS\rathena\Release\*.exe D:\Project_ROS\rathena\
```

---

## 5. COMMON BUILD ERRORS & FIXES

### Error: CMake cannot find Visual Studio
```
CMake Error: Generator "Visual Studio 17 2022" could not find any instance of Visual Studio
```
**Cause**: Wrong generator version OR VS installed in non-default path.
**Fix**:
```powershell
# Check what VS version you have
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -all

# Use matching generator + explicit path
cmake -G "Visual Studio 18 2026" -A x64 `
  -DCMAKE_GENERATOR_INSTANCE="D:\Programs\Microsoft\18\VisualStudio" `
  -DPACKETVER=20220406 -B build
```

### Error: Generator does not match previous
```
CMake Error: Does not match the generator used previously
```
**Fix**: Delete the old build folder and reconfigure:
```powershell
Remove-Item -Recurse -Force D:\Project_ROS\rathena\build
cmake -G "Visual Studio 18 2026" -A x64 -DPACKETVER=20220406 -B build
```

### Error: Cannot open include file 'stdint.h' / 'cstddef' / 'string'
```
fatal error C1083: Cannot open include file: 'stdint.h': No such file or directory
```
**Cause**: Windows SDK or C++ standard library not installed.
**Fix**: Open Visual Studio Installer → Modify → Workloads → check **"Desktop development with C++"** → Modify.

### Error: CMakeCache.txt not found
```
Error: not a CMake build directory (missing CMakeCache.txt)
```
**Fix**: Find correct build dir:
```powershell
Get-ChildItem -Path D:\Project_ROS\rathena -Name "CMakeCache.txt" -Recurse
```
Then use that exact path with `cmake --build`.

### Warning: C4819 character code page 932
```
warning C4819: The file contains a character that cannot be represented in the current code page (932)
```
**This is safe to ignore.** It's a Japanese Windows locale warning. Does not affect functionality.

### Warning: IPDB not found, fall back to full compilation
**This is safe to ignore.** It just means incremental build cache isn't available.

---

## 6. REQUIRED DLL FILES

The server EXEs need these DLLs in the **same folder** as the EXEs.

### DLLs Required
| DLL File | Source Location (User's System) |
|---|---|
| `libmysql.dll` | `D:\Project_ROS\laragon\bin\heidisql\libmysql.dll` |
| `libcrypto-3-x64.dll` | `D:\Project_ROS\laragon\bin\mysql\mysql-8.4.3-winx64\bin\` |
| `libssl-3-x64.dll` | `D:\Project_ROS\laragon\bin\mysql\mysql-8.4.3-winx64\bin\` |

### Copy Commands (to rAthena root)
```powershell
Copy-Item "D:\Project_ROS\laragon\bin\heidisql\libmysql.dll" "D:\Project_ROS\rathena\"
Copy-Item "D:\Project_ROS\laragon\bin\mysql\mysql-8.4.3-winx64\bin\libcrypto-3-x64.dll" "D:\Project_ROS\rathena\"
Copy-Item "D:\Project_ROS\laragon\bin\mysql\mysql-8.4.3-winx64\bin\libssl-3-x64.dll" "D:\Project_ROS\rathena\"
```

### If More DLLs Are Missing
Search Laragon for the missing file:
```powershell
Get-ChildItem "D:\Project_ROS\laragon\" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*MISSINGFILENAME*" }
```
Then copy the found file to `D:\Project_ROS\rathena\`.

### Finding libmysql.dll if Not in Expected Location
```powershell
Get-ChildItem "D:\Project_ROS\laragon\" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*libmysql*" }
```

---

## 7. SERVER CONFIGURATION

### inter_athena.conf — Database Connection
```
// File: conf/inter_athena.conf
sql.db_hostname: 127.0.0.1
sql.db_port: 3306
sql.db_username: ragnarok
sql.db_password: yourpassword
sql.db_database: ragnarok
sql.codepage:
```

### login_athena.conf — Login Server
```
new_account: yes          // Allow account creation with _M/_F suffix
pass_min_length: 0        // No minimum password length
```

### char_athena.conf — Char Server
```
server_name: MyROServer   // Name shown in client
pincode_enabled: no       // Disable PIN code for solo play
```

### map_athena.conf — Map Server
```
map_ip: 127.0.0.1
map_port: 5121
```

---

## 8. DATABASE SETUP

### Create Database in HeidiSQL/phpMyAdmin
1. Start Laragon → ensure MySQL is running
2. Open HeidiSQL
3. Create new database named: `ragnarok`
4. Create user with full permissions on `ragnarok` database

### Import SQL Files (in this order)
```sql
-- Import these via HeidiSQL File > Run SQL File
sql-files/main.sql
sql-files/logs.sql
-- For Renewal only (do NOT import pre-re versions):
sql-files/item_db_re.sql
sql-files/mob_db_re.sql
```

### Verify MySQL is Running
```powershell
Test-NetConnection -ComputerName 127.0.0.1 -Port 3306
# Should show: TcpTestSucceeded : True
```

---

## 9. STARTING THE SERVER

### Startup Order (CRITICAL)
Always start in this order:
1. Start Laragon MySQL first
2. `login-server.exe`
3. `char-server.exe`
4. `map-server.exe`
5. (Optional) `web-server.exe`

### Run Servers via PowerShell (Keep Window Open)
```powershell
cd D:\Project_ROS\rathena
.\login-server.exe
```

### Capture Server Output to Log
```powershell
cd D:\Project_ROS\rathena
.\login-server.exe 2>&1 | Tee-Object -FilePath D:\login_log.txt
```

### Simple BAT File to Start All Servers
```bat
@echo off
title RO Renewal Server Launcher
echo Starting MySQL...
cd /d D:\Project_ROS\laragon
start "" "laragon.exe" --autorun
timeout /t 5

echo Starting Login Server...
cd /d D:\Project_ROS\rathena
start "Login Server" login-server.exe
timeout /t 3

echo Starting Char Server...
start "Char Server" char-server.exe
timeout /t 3

echo Starting Map Server...
start "Map Server" map-server.exe
timeout /t 5

echo Starting Game Client...
cd /d D:\rag_offline\RO_Renewal\3_Client
start "" "Ragnarok.exe"
echo All servers started!
pause
```

### Verify Server is Listening
```powershell
Test-NetConnection -ComputerName 127.0.0.1 -Port 6900   # Login
Test-NetConnection -ComputerName 127.0.0.1 -Port 6121   # Char
Test-NetConnection -ComputerName 127.0.0.1 -Port 5121   # Map
```

---

## 10. CLIENT SETUP

### clientinfo.xml
Place in client folder or inside a custom GRF:
```xml
<?xml version="1.0" encoding="euc-kr" ?>
<clientinfo>
  <desc>My RO Server</desc>
  <servicetype>korea</servicetype>
  <servertype>primary</servertype>
  <connection>
    <display>MyROServer</display>
    <address>127.0.0.1</address>
    <port>6900</port>
    <version>55</version>
    <langtype>1</langtype>
    <registrationweb>http://127.0.0.1/</registrationweb>
    <yellow>
      <admin>2000000</admin>
    </yellow>
  </connection>
</clientinfo>
```

### data.ini — GRF Priority
```ini
[Data]
1=custom.grf
2=rdata.grf
3=data.grf
```

### Required NEMO Patches
| Patch | Required? |
|---|---|
| Read Data Folder First | ✅ Essential |
| Ignore Missing Palette Error | ✅ Recommended |
| Skip License Screen | ✅ Recommended |
| Enable 4th Job | ✅ For expanded jobs |
| Disable Game Guard | ✅ For offline use |
| Increase Zoom Out | Optional |
| Remove Gravity Logo | Optional |

---

## 11. ACCOUNT & GM SETUP

### Create Account In-Game
- Enable `new_account: yes` in `conf/login_athena.conf`
- Login with username: `myname_M` (male) or `myname_F` (female)
- On next login, use `myname` without suffix

### Create Account via SQL
```sql
INSERT INTO login (userid, user_pass, sex, group_id)
VALUES ('myaccount', MD5('mypassword'), 'M', 99);
```

### Set GM Level via SQL
```sql
UPDATE login SET group_id = 99 WHERE userid = 'myaccount';
```

### GM Group IDs
| Group | Role |
|---|---|
| 0 | Normal player |
| 1 | Support GM |
| 2 | Game Master |
| 10 | Developer |
| 99 | Super Admin (all commands) |

### Essential GM Commands for Solo Play
| Command | Effect |
|---|---|
| `@warp <map> <x> <y>` | Teleport to map |
| `@item <id> <amount>` | Spawn items |
| `@zeny <amount>` | Set Zeny |
| `@job <jobid>` | Change job |
| `@lvup <levels>` | Gain base levels |
| `@joblvup <levels>` | Gain job levels |
| `@speed <0-200>` | Set movement speed |
| `@reloadscript` | Reload all NPC scripts |
| `@reloaditemdb` | Reload item database |
| `@killmonster <map>` | Kill all monsters on map |

---

## 12. BATTLE CONFIGURATION

### File Location
All battle config files are in: `conf/battle/`

### Recommended Solo Play Settings

#### conf/battle/exp.conf
```
base_exp_rate: 500
job_exp_rate: 500
quest_exp_rate: 300
death_penalty_base: 0
death_penalty_job: 0
```

#### conf/battle/drops.conf
```
item_rate_common: 500
item_rate_heal: 300
item_rate_card: 1000
item_rate_equip: 300
item_rate_mvp: 200
```

#### conf/battle/player.conf
```
max_parameter: 200
max_aspd: 193
natural_healhp_interval: 2000
natural_healsp_interval: 2000
restart_hp_rate: 100
restart_sp_rate: 100
max_weight_base: 200000
pk_mode: 0
```

#### conf/battle/skill.conf
```
casting_rate: 50
delay_rate: 50
```

#### conf/battle/monster.conf
```
mvp_hp_rate: 60
monster_hp_rate: 80
```

---

## 13. NPC SCRIPTING

### Script File Loading Chain
```
conf/map_athena.conf
  → npc/re/scripts_athena.conf
    → npc/re/scripts_main.conf
      → individual .txt files
```
**Add custom NPCs to**: `npc/custom/` and reference in `npc/custom/scripts_custom.conf`

### Basic NPC Syntax
```
<map>,<x>,<y>,<dir> script <NPC Name> <sprite_id>,{
  // script body
}
```

### Essential Solo Play NPCs

#### Healer NPC
```
prontera,155,185,4 script Healer 4_F_KAFRA1,{
  mes "[Healer]";
  mes "Do you need healing?";
  menu "Yes please!", L_Heal, "No thanks", L_End;
  L_Heal:
    percentheal 100, 100;
    mes "You are fully restored!";
    close;
  L_End:
    close;
}
```

#### Warper NPC
```
prontera,160,185,4 script Warper 4_F_TELEPORTER,{
  mes "[Warper]";
  mes "Where would you like to go?";
  menu "Geffen", L_Geffen, "Payon", L_Payon;
  L_Geffen: warp "geffen", 120, 120; end;
  L_Payon:  warp "payon", 163, 257; end;
}
```

#### Buffer NPC
```
prontera,165,185,4 script Buffer 4_M_BISHOP,{
  sc_start SC_BLESSING, 120000, 10;
  sc_start SC_INCREASEAGI, 120000, 10;
  sc_start SC_GLORIA, 30000, 1;
  mes "You have been buffed!";
  close;
}
```

#### Job Changer NPC
```
prontera,175,185,4 script JobChanger 4_F_GUILD,{
  mes "[Job Changer]";
  mes "Choose your job:";
  menu "Swordman", L_SW, "Mage", L_MA, "Archer", L_AR;
  L_SW: jobchange Job_Swordman; close;
  L_MA: jobchange Job_Mage; close;
  L_AR: jobchange Job_Archer; close;
}
```

#### Safe Refiner NPC
```
prontera,155,175,4 script SafeRefiner 4_M_OLDMAN,{
  mes "[Safe Refiner]";
  menu "Refine Weapon", L_Weapon, "Refine Armor", L_Armor;
  L_Weapon: successrefitem EQI_HAND_R; close;
  L_Armor:  successrefitem EQI_ARMOR; close;
}
```

### Common Script Commands
| Command | Description |
|---|---|
| `mes "text"` | Display message |
| `next` | Show Next button |
| `close` | Close dialog |
| `menu "opt", Label` | Show choice menu |
| `getitem <id>, <amount>` | Give item to player |
| `getexp <base>, <job>` | Give EXP |
| `jobchange <jobid>` | Change job |
| `warp "<map>", <x>, <y>` | Teleport player |
| `percentheal <hp%>, <sp%>` | Heal by percent |
| `sc_start <effect>, <ms>, <val>` | Apply status effect |
| `successrefitem <slot>` | Safe refine equipment |
| `strcharinfo(0)` | Get character name |

---

## 14. DATABASE FILES

### File Locations (Renewal)
| File | Path |
|---|---|
| Item Database | `db/re/item_db.yml` |
| Monster Database | `db/re/mob_db.yml` |
| Monster Skills | `db/re/mob_skill_db.yml` |
| Skill Database | `db/re/skill_db.yml` |
| Skill Tree | `db/re/skill_tree.yml` |
| Quest Database | `db/re/quest_db.yml` |
| Instance Database | `db/re/instance_db.yml` |
| Map Index | `db/map_index.txt` |

### CRITICAL RULE: Never Edit Core DB Files
Always use the import folder:
```
db/import/item_db.yml      ← custom item overrides
db/import/mob_db.yml       ← custom monster overrides
```

### Custom Item Example (db/import/item_db.yml)
```yaml
Header:
  Type: ITEM_DB
  Version: 1
Body:
  - Id: 50001
    AegisName: Custom_Sword
    Name: Custom Sword
    Type: Weapon
    SubType: 2hSword
    Weight: 1000
    Atk: 500
    Slots: 4
    Refineable: true
    Locations:
      BothHands: true
    Script: |
      bonus bStr, 50;
      bonus bAtk, 100;
```

### Custom Monster Drop Override (db/import/mob_db.yml)
```yaml
Header:
  Type: MOB_DB
  Version: 1
Body:
  - Id: 1002   # Poring
    Drops:
      - Item: Apple
        Rate: 5000    # 50%
      - Item: Jellopy
        Rate: 10000   # 100%
```

---

## 15. TROUBLESHOOTING

### Server Crashes Immediately on Launch
**Step 1** — Capture the error:
```powershell
cd D:\Project_ROS\rathena
.\login-server.exe 2>&1 | Tee-Object -FilePath D:\login_log.txt
Get-Content D:\login_log.txt
```

**Step 2** — Check MySQL is running:
```powershell
Test-NetConnection -ComputerName 127.0.0.1 -Port 3306
```

### Common Runtime Errors

| Error Message | Cause | Fix |
|---|---|---|
| `libmysql.dll was not found` | Missing DLL | Copy from `laragon\bin\heidisql\` |
| `libcrypto-3-x64.dll was not found` | Missing OpenSSL | Copy from `laragon\bin\mysql\mysql-8.4.3-winx64\bin\` |
| `libssl-3-x64.dll was not found` | Missing OpenSSL | Copy from `laragon\bin\mysql\mysql-8.4.3-winx64\bin\` |
| `Could not connect to database` | MySQL not running or wrong credentials | Start Laragon, check inter_athena.conf |
| `Cannot open configuration file` | Wrong working directory | Run server from rAthena root folder |
| `Unknown map` | Map not in map_index.txt | Add map name to `db/map_index.txt` |
| Server closes instantly | Any startup error | Run with `Tee-Object` to capture log |

### Client Cannot Connect
1. Verify `clientinfo.xml` has `<address>127.0.0.1</address>`
2. Verify all 3 servers are running
3. Check firewall allows ports 6900, 6121, 5121
4. Verify client .exe PACKETVER matches server PACKETVER (20220406)

### Build Fails with Missing Headers
```
fatal error C1083: Cannot open include file: 'stdint.h'
```
Fix: Install **"Desktop development with C++"** workload via Visual Studio Installer.

### Find Any Missing DLL
```powershell
# Replace FILENAME with the missing DLL name
Get-ChildItem "D:\Project_ROS\laragon\" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*FILENAME*" }
```

### Check What's Running on a Port
```powershell
netstat -ano | findstr ":6900"
netstat -ano | findstr ":3306"
```

---

## 16. FILE PATH REFERENCE

### Server Config Files
| File | Purpose |
|---|---|
| `conf/inter_athena.conf` | MySQL connection for all servers |
| `conf/login_athena.conf` | Login server settings |
| `conf/char_athena.conf` | Char server, server name |
| `conf/map_athena.conf` | Map server IP/port |
| `conf/groups.conf` | GM permission groups |
| `conf/battle/exp.conf` | EXP rates, level caps |
| `conf/battle/drops.conf` | Drop rate multipliers |
| `conf/battle/player.conf` | Player stats and mechanics |
| `conf/battle/skill.conf` | Cast time and skill delays |
| `conf/battle/monster.conf` | Monster AI and HP rates |
| `conf/battle/misc.conf` | Vending, misc rules |
| `conf/battle/items.conf` | Refine, trade settings |
| `conf/log_athena.conf` | Logging configuration |

### NPC Script Folders
| Folder | Purpose |
|---|---|
| `npc/re/cities/` | Town NPCs |
| `npc/re/mobs/` | Monster spawns |
| `npc/re/warps/` | Warp portals |
| `npc/re/quests/` | Quest scripts |
| `npc/custom/` | YOUR custom NPCs (add here) |

---

## 17. ONLINE RESOURCES

| Resource | URL |
|---|---|
| rAthena GitHub | https://github.com/rathena/rathena |
| rAthena Forums | https://rathena.org/board/ |
| rAthena Wiki | https://github.com/rathena/rathena/wiki |
| rAthena User Guides | https://rathena.github.io/user-guides/ |
| DeepWiki rAthena | https://deepwiki.com/rathena/rathena |
| Script Commands Reference | https://github.com/rathena/rathena/blob/master/doc/script_commands.txt |
| Basic Scripting Guide | https://github.com/rathena/rathena/wiki/Basic-Scripting |
| Single Player Guide (Forum) | https://rathena.org/board/topic/132869 |
| NEMO Client Patcher | https://github.com/MStr3am/NEMO |
| GRF Editor | https://rathena.org/board/topic/77080 |
| ROenglishRE Translation | https://github.com/llchrisll/ROenglishRE |
| Laragon | https://laragon.org |
| CMake Download | https://cmake.org/download |

---

*End of Agent Knowledge Base — rAthena Renewal Local Server*
