# Ragnarok Online Private Server — Progress Tracker

> **Last Updated**: 2026-05-26  
> **Reference Guide**: `D:\Project_ROS\rAthena_Renewal_Agent_Guide.md`  
> **Reference Log**: `D:\Project_ROS\rathena\Running The rAthena Server.md`

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Completed |
| ⚠️ | Completed but differs from guide / has notes |
| ❌ | Not done yet |
| 🧑‍💻 | **YOU do this manually** (GUI tool, no agent needed) |
| 🤖 | Agent can do this for you |

---

## Section 1 — System Overview (§1)
**Status: ✅ Understood**

| Item | Guide Says | Actual |
|------|-----------|--------|
| Server type | Renewal (RE) | ✅ Renewal |
| PACKETVER | 20220406 | ✅ 20220406 |
| Ports | 6900 / 6121 / 5121 | ✅ Confirmed working |

---

## Section 2 — Known Environment (§2)
**Status: ⚠️ Differences from guide**

| Item | Guide Says | Actual | Status |
|------|-----------|--------|--------|
| OS | Windows (Thai locale) | Windows | ✅ |
| Visual Studio | VS Community 2026 (v18.6) | ✅ Used for build | ✅ |
| CMake | 3.32+ | `D:\Project_ROS\cmake-3.31.12` | ✅ |
| rAthena Path | `D:\Project_ROS\rathena\` | Same | ✅ |
| MySQL | Laragon → MySQL 8.4.3 | ⚠️ **Docker MariaDB 11.8** instead | ⚠️ Different |
| MySQL Creds | `ragnarok` user | ⚠️ `root` / `QWer!@34` | ⚠️ Different |
| Client Path | `D:\rag_offline\RO_Renewal\3_Client` | ⚠️ `D:\Project_ROS\Gravity\Ragnarok\` | ⚠️ Different |
| libmysql.dll source | `laragon\bin\heidisql\` | ⚠️ Already in rathena root | ✅ |

---

## Section 3 — Prerequisites (§3)
**Status: ✅ All installed**

| Software | Required | Installed | Location |
|----------|----------|-----------|----------|
| Git | ✅ | ✅ | System PATH |
| Visual Studio | ✅ | ✅ | `D:\Programs\Microsoft\18\VisualStudio` |
| CMake | ✅ | ✅ | `D:\Project_ROS\cmake-3.31.12` |
| Laragon | ✅ | ✅ | `D:\Project_ROS\laragon\` (but using Docker MariaDB) |
| kRO Client | ✅ | ✅ | `D:\Project_ROS\Gravity\Ragnarok\` |
| NEMO Patcher | ✅ | ✅ | `D:\Project_ROS\Nemo\` |
| GRF Editor | ✅ | ✅ | `D:\Project_ROS\GRF\` |
| ROenglishRE | ✅ | ✅ | `D:\Project_ROS\ROenglishRE\` |

---

## Section 4 — Build Process (§4)
**Status: ✅ Complete**

- [x] Step 1 — Clone rAthena repo
- [x] Step 2 — Configure with CMake (`PACKETVER=20220406`)
- [x] Step 3 — Build All (Release)
- [x] Step 4 — Verify success (all .exe files present)
- [x] Step 5 — Copy EXEs to server root

---

## Section 5 — Common Build Errors (§5)
**Status: ✅ Resolved**

- [x] CMake generator issue — resolved with correct VS18 generator
- [x] C4819 warning (code page) — ignored (cosmetic)

---

## Section 6 — Required DLL Files (§6)
**Status: ✅ Complete**

| DLL | Required | Present in `rathena\` |
|-----|----------|----------------------|
| `libmysql.dll` | ✅ | ✅ |
| `pcre8.dll` | ✅ | ✅ (copied from `3rdparty\pcre\lib\x64\`) |
| `libcrypto-3-x64.dll` | ✅ | ✅ |
| `libssl-3-x64.dll` | ✅ | ✅ |

---

## Section 7 — Server Configuration (§7)
**Status: ✅ Complete (heavily customized for solo play)**

All config done via `conf/import/` files (safe from git updates):

| Config File | Guide Setting | Our Setting | Status |
|-------------|--------------|-------------|--------|
| `inter_conf.txt` | DB: `ragnarok` user | DB: `root` / `QWer!@34` | ⚠️ Different user |
| `login_conf.txt` | `bind_ip: 127.0.0.1` | Same + `console: on` | ✅ |
| `char_conf.txt` | `char_ip: 127.0.0.1` | Same + `login_ip` + `console: on` | ✅ |
| `map_conf.txt` | `map_ip: 127.0.0.1` | Same + `char_ip` + `console: on` | ✅ |
| `battle_conf.txt` | Basic rates | ✅ Full solo config (15x EXP, 5x drops, MVP HP 70%, etc.) | ✅ |

### Solo Play Additions (beyond the guide)
- [x] 15x EXP / 5x drops / 2x cards
- [x] Death penalty disabled
- [x] MVP HP 70% + 10 custom MVP HP overrides in `db/import/mob_db.yml`
- [x] Instance time extensions in `db/import/instance_db.yml`
- [x] Party share level 150 in `inter_conf.txt`
- [x] Auction disabled, vending tax 0
- [x] Max parameter 130, homunculus friendly 100
- [x] Item auto-pickup, mob HP bars

---

## Section 8 — Database Setup (§8)
**Status: ✅ Complete**

| Step | Guide Says | Actual | Status |
|------|-----------|--------|--------|
| Create `ragnarok` DB | HeidiSQL / phpMyAdmin | ✅ Done via Docker | ✅ |
| Import `main.sql` | HeidiSQL | ✅ Already imported | ✅ |
| Import `logs.sql` | HeidiSQL | ✅ Already imported | ✅ |
| MySQL running | Laragon | ⚠️ Docker MariaDB 11.8 | ⚠️ |
| SSL disabled | Not in guide | ✅ Had to disable (Docker SSL issue) | ✅ |

> **NOTE**: Docker MariaDB has `skip-ssl` in `/etc/mysql/conf.d/disable-ssl.cnf`.  
> If you `docker-compose down/up`, you may need to re-add it or put `command: --skip-ssl` in `docker-compose.yml`.

---

## Section 9 — Starting the Server (§9)
**Status: ✅ Complete & Verified**

- [x] login-server → port 6900 ✅
- [x] char-server → port 6121 ✅
- [x] map-server → port 5121 ✅
- [x] All 3 interconnected (char→login, map→char)
- [x] `start-server.bat` created
- [x] `backup_ragnarok.bat` created

### Remaining Warnings (harmless, safe to ignore)
| Warning | Why It's OK |
|---------|------------|
| `s1/p1 default password` | Standard rAthena notice; inter-server account, not player-facing |
| `mesitemicon requires newer PACKETVER` | Feature auto-disabled; our PACKETVER is 20220406 |
| `map_index.txt not found` | Optional import file, not needed |
| `roulette_db filling with Apples` | Roulette system not configured, harmless |

---

## Section 10 — Client Setup (§10)
**Status: ❌ NOT DONE — This is the next major phase**

### 10a. Patch Ragexe.exe with NEMO
**Status: ✅ COMPLETE**  
**Who: 🤖 Agent (automated copy)**

Completed: Since the official client was packed with Themida and could not be patched, we copied your pre-patched, unpacked client executable (`Ragnarok.exe` from `D:\rag_offline\RO_Renewal\3_Client\`) to `D:\Project_ROS\Gravity\Ragnarok\Ragexe.exe`. We then reconfigured and recompiled the rAthena server to match its packet version (`20211103`).


### 10b. Create `clientinfo.xml`
**Status: ✅ COMPLETE**  
**Who: 🤖 Agent**

Completed: The file was copied from the ROenglishRE translation folder into `D:\Project_ROS\Gravity\Ragnarok\data\clientinfo.xml` and is pre-configured to point to `127.0.0.1:6900`.

### 10c. Create `DATA.INI`
**Status: ✅ COMPLETE**  
**Who: 🤖 Agent**

Completed: Created `D:\Project_ROS\Gravity\Ragnarok\DATA.INI` pointing to `data.grf` (`0=data.grf`) to resolve the missing `rdata.grf` issue.

### 10d. Apply English Translation (ROenglishRE)
**Status: ✅ COMPLETE**  
**Who: 🤖 Agent**

Completed: The agent has automated this step:
- Merged the translation `data\` and `SystemEN\` files into `D:\Project_ROS\Gravity\Ragnarok\data\` and `D:\Project_ROS\Gravity\Ragnarok\System\`.
- Copied `cps.dll` and `tipoftheday.txt` to the client root directory.


### 10e. Test Connection
**Status: ✅ COMPLETE**  
**Who: 🧑‍💻 YOU & 🤖 Agent**

Completed: Launched the servers and client, successfully logged in using `admin` / `admin`, verified character creation and map server connectivity.


---

## Section 11 — Account & GM Setup (§11)
**Status: ✅ Complete**

| Account | Password | Group ID | Role |
|---------|----------|----------|------|
| `admin` | `admin` | 99 | Super Admin |
| `player` | `player` | 0 | Normal Player |

---

## Section 12 — Battle Configuration (§12)
**Status: ✅ Complete (exceeds guide recommendations)**

See `conf/import/battle_conf.txt` for full details. All settings applied via import file.

---

## Section 13 — NPC Scripting (§13)
**Status: ✅ Complete**

| NPC | File | Registered in `scripts_custom.conf` |
|-----|------|--------------------------------------|
| Solo Supply Shop | `npc/custom/solo_item_shop.txt` | ✅ |
| Zeny Banker | `npc/custom/zeny_shop.txt` | ✅ |
| Magic Buffer | `npc/custom/buffer.txt` | ✅ |
| Warper (built-in) | `npc/custom/warper.txt` | ✅ |
| Healer (built-in) | `npc/custom/healer.txt` | ✅ |
| Job Master (built-in) | `npc/custom/jobmaster.txt` | ✅ |
| Platinum Skills (built-in) | `npc/custom/platinum_skills.txt` | ✅ |
| Stylist (built-in) | `npc/custom/stylist.txt` | ✅ |
| Reset NPC (built-in) | `npc/custom/resetnpc.txt` | ✅ |
| Card Remover (built-in) | `npc/custom/card_remover.txt` | ✅ |
| Breeder (built-in) | `npc/custom/breeder.txt` | ✅ |
| MVP Room | `npc/custom/etc/mvp_room.txt` | ✅ |
| MVP Arena | `npc/custom/etc/mvp_arena.txt` | ✅ |
| Hunting Missions | `npc/custom/quests/hunting_missions.txt` | ✅ |
| Quest Shop | `npc/custom/quests/quest_shop.txt` | ✅ |
| Quest Board | `npc/custom/quests/questboard.txt` | ✅ |

---

## Section 14 — Database Files (§14)
**Status: ✅ Complete**

- [x] All `db/import/*.yml` placeholder files created
- [x] Version headers updated to match current engine
- [x] `db/import/mob_db.yml` — 10 custom MVP HP overrides
- [x] `db/import/instance_db.yml` — 10 instance time extensions
- [x] `db/import/map_cache.dat` — copied from template

---

## Section 15 — Troubleshooting (§15)
**Status: ✅ All issues resolved**

| Issue | Resolution |
|-------|-----------|
| SSL error with Docker MariaDB | Disabled SSL in container |
| `pcre8.dll` missing | Copied from `3rdparty/pcre/lib/x64/` |
| `db/import/` files missing | Created all ~50 placeholder files |
| Instance DB duplicate name errors | Removed `Name:` field from overrides |
| NPC sprite warnings (`4_M_WIZARD`, `4_M_BANKER`) | Replaced with numeric sprite IDs |
| Shop price exploit warnings | Changed to `-1` (use DB prices) |
| DB version outdated warnings | Updated all YAML version headers |
| Char/Map connecting to Docker network IP | Added explicit `login_ip`/`char_ip` to import configs |

---

## Section 16 — File Path Reference (§16)
**Status: ✅ For reference only — no action needed**

---

## Section 17 — Online Resources (§17)
**Status: ✅ For reference only — no action needed**

---

## Quick Action Summary

### What YOU need to do (manual/GUI steps):
1. 🧑‍💻 **Patch Ragexe.exe with NEMO** — Open NEMO.exe, load Ragexe.exe, select patches, apply
2. 🧑‍💻 **Deploy ROenglishRE translation** — Copy translation files to client folder
3. 🧑‍💻 **Handle rdata.grf** — Check if you need it or adjust DATA.INI
4. 🧑‍💻 **Test the game** — Launch patched client, login, create character

### What the Agent can do for you:
1. 🤖 Create `clientinfo.xml` in `data\` folder
2. 🤖 Create `DATA.INI` in client folder
3. 🤖 Any further config file tweaks
4. 🤖 Troubleshoot connection issues after you test

---

*Progress saved: 2026-05-26*
