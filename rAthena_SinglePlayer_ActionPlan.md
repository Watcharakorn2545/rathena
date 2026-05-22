# rAthena Offline Single-Player Server — Complete Action Plan

> **Goal:** Build a stable, enjoyable, story-rich solo Ragnarok Online private server using rAthena.
> **Mode:** Offline / Single Player
> **Approach:** Implement in phases — foundation first, then gameplay tuning, then content enrichment.

---

## Overview of Phases

| Phase | Focus | Priority |
|-------|-------|----------|
| Phase 1 | Installation & Foundation | 🔴 Critical |
| Phase 2 | Database & Account Setup | 🔴 Critical |
| Phase 3 | Server Rate Tuning | 🟠 High |
| Phase 4 | Monster & MVP Balancing | 🟠 High |
| Phase 5 | Solo Instance & Party Config | 🟠 High |
| Phase 6 | Item & Economy Setup | 🟡 Medium |
| Phase 7 | Custom QoL NPCs | 🟡 Medium |
| Phase 8 | Story & Quest Experience | 🟡 Medium |
| Phase 9 | Class, Skill & AI Tuning | 🟢 Enhancement |
| Phase 10 | GM Tools & Admin Setup | 🟢 Enhancement |
| Phase 11 | Maintenance & Backup System | 🔵 Ongoing |

---

## Phase 1 — Installation & Foundation

### 1.1 Prerequisites
- [ ] Install **Git** (to clone rAthena)
- [ ] Install **MySQL 8.x or MariaDB 10.x**
- [ ] Install a MySQL client (phpMyAdmin, DBeaver, or MySQL Workbench)
- [ ] Install **Visual Studio 2019/2022** (Windows) or **GCC/CMake** (Linux) for compilation
- [ ] Download a compatible **Ragnarok Online client** (recommended: 2018–2022 client)
- [ ] Download **NEMO patcher** or **OpenSetup** for client patching

### 1.2 Clone & Compile rAthena
```bash
git clone https://github.com/rathena/rathena.git
cd rathena
```
- [ ] Compile all three servers: `login-server`, `char-server`, `map-server`
- [ ] Confirm no build errors before proceeding

### 1.3 Decide Game Mode
- [ ] Choose between **Pre-Renewal** or **Renewal** — edit `src/config/renewal.hpp` before compiling
- [ ] Choose a **client version** that matches your downloaded RO client
- [ ] Document your chosen mode and client date for future reference

### 1.4 Core Config Files — Initial Setup

**File: `conf/login_athena.conf`**
```
bind_ip: 127.0.0.1
login_port: 6900
```

**File: `conf/char_athena.conf`**
```
bind_ip: 127.0.0.1
char_ip: 127.0.0.1
char_port: 6121
```

**File: `conf/map_athena.conf`**
```
bind_ip: 127.0.0.1
map_ip: 127.0.0.1
map_port: 5121
```

**File: `conf/inter_server.conf`**
```
sql.db_hostname: 127.0.0.1
sql.db_port: 3306
sql.db_username: ragnarok
sql.db_password: your_password
sql.db_database: ragnarok
```

- [ ] Confirm all IP/port bindings are `127.0.0.1` (loopback only — safe for offline)
- [ ] Test that all three servers start without errors

---

## Phase 2 — Database & Account Setup

### 2.1 Create the Database
```sql
CREATE DATABASE ragnarok;
CREATE USER 'ragnarok'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON ragnarok.* TO 'ragnarok'@'localhost';
FLUSH PRIVILEGES;
```

### 2.2 Import Base SQL Schemas
```bash
mysql -u ragnarok -p ragnarok < sql-files/main.sql
mysql -u ragnarok -p ragnarok < sql-files/logs.sql
```

### 2.3 Create Your Player Account
```sql
INSERT INTO login (userid, user_pass, sex, email, group_id, state)
VALUES ('YourUsername', MD5('YourPassword'), 'M', 'admin@localhost', 99, 0);
```
- [ ] Set `group_id: 99` for full GM access
- [ ] Confirm login works via the RO client

### 2.4 Configure `conf/groups.conf` for GM Group 99
```
99: {
  name: "Admin"
  inherit: ("Player")
  level: 99
  commands: {
    // Grant all @commands
    all: true
  }
  permissions: {
    can_trade: true
    can_party: true
    all_skill: false     // Keep false unless testing builds
    all_equipment: false
    super_novice_skills: false
    skill_unconditional: false
    use_check: true
    use_changemaptype: true
    all_permission: true
  }
}
```

---

## Phase 3 — Server Rate Tuning

> **File:** `conf/map_athena.conf` and `conf/battle/exp.conf`

### 3.1 EXP Rates — Recommended Solo Values

```
base_exp_rate: 1500      // 15x base EXP
job_exp_rate:  1500      // 15x job EXP
```

> Adjust between 500 (5x) and 5000 (50x) based on preferred grind level.

### 3.2 Drop Rates — Recommended Solo Values

**File: `conf/battle/drops.conf`**
```
item_rate_common:       500    // 5x common drops
item_rate_common_boss:  500
item_rate_card:         200    // 2x card rate (still rare but findable)
item_rate_card_mvp:     100    // 1x MVP cards (keep special)
item_rate_equip:        500
item_rate_equip_boss:   500
item_rate_mvp:          500    // 5x MVP drop
item_rate_heal:         1000   // 10x healing items
item_rate_use:          1000
item_rate_treasure:     1000
```

### 3.3 Zeny & Death Penalty

**File: `conf/battle/player.conf`**
```
zeny_from_kill: 1          // Mobs drop zeny
death_penalty_type: 0      // No EXP loss on death (solo-friendly)
death_penalty_base: 0
death_penalty_job: 0
```

### 3.4 Max Level Cap

**File: `conf/map_athena.conf`**
```
max_base_level: 175        // or 99 for Pre-Renewal
max_job_level:  70         // or 50 for Pre-Renewal
max_baby_level: 99
max_novice_base_level: 10
max_novice_job_level: 10
```

---

## Phase 4 — Monster & MVP Balancing

### 4.1 Global Monster HP Reduction (Optional)
**File: `conf/battle/monster.conf`**
```
monster_hp_rate:    70     // MVPs have 70% of their normal HP
monster_max_aspd:  199     // Prevent monsters from being unhittably fast
monster_ai:        0x000   // Default AI — increase for challenge
```

### 4.2 MVP Respawn Timers
**File: `db/mob_db.yml`** — find MVP entries and adjust:
```yaml
- Id: 1511   # Eddga
  Respawn:
    MinDelay: 3600000     # 1 hour minimum (default is much longer)
    MaxDelay: 7200000     # 2 hour maximum
```
- [ ] Reduce MVP respawn to **1–2 hours** for accessible solo farming
- [ ] Identify the top 10 MVPs you want to farm and adjust each

### 4.3 Instance-Specific Mob Tweaks
- [ ] For instance mobs that are too strong solo, create a **custom mob override** in `db/import/mob_db.yml`
- [ ] Never directly edit the base `mob_db.yml` — always use the `import/` override folder

```yaml
# db/import/mob_db.yml example
- Id: 2841    # Instance boss
  Hp: 500000  # Reduce from default
```

---

## Phase 5 — Solo Instance & Party Config

### 5.1 Remove Minimum Party Requirement for Instances
**File: `db/instance_db.yml`** — for each instance:
```yaml
- Id: 1       # Endless Tower
  Name: Endless Tower
  Enter:
    Map: 1etur01
    X: 150
    Y: 15
  MinPlayers: 1    # Change from 2+ to 1
  MaxPlayers: 1
  TimeLimit: 3600
```
- [ ] Set `MinPlayers: 1` for all instances you want to run solo
- [ ] Key instances to prioritize: Endless Tower, Orc's Memory, Buwaya Cave, Faceworm Nest, Old Glast Heim

### 5.2 Extend Instance Time Limits
```yaml
TimeLimit: 7200    # 2 hours for complex instances
```

### 5.3 Party Config for Solo Play
**File: `conf/battle/party.conf`**
```
party_share_type:   1     // Item share: random
party_share_item:   1     // Share items
exp_share_type:     0     // EXP to whoever kills (no split solo)
```

---

## Phase 6 — Item & Economy Setup

### 6.1 Disable Player-Based Economy Features
**File: `conf/battle/misc.conf`**
```
auction_feeperhour: 0     // Disable auction (no other players)
vending_tax: 0
```
**File: `conf/map_athena.conf`**
```
enable_auction: 0
```

### 6.2 Add a Custom All-Items NPC Shop
**File: `npc/custom/solo_item_shop.txt`**
```c
prontera,155,185,5  shop  Solo_Equipment_Shop  4_F_KAFRA1,
  501:100,        // Red Potion
  502:200,        // Orange Potion
  2301:50000,     // Knife (example weapon)
  // Add more items as needed
```

### 6.3 Create a Zeny-Giving NPC (Optional)
```c
prontera,160,185,5  script  Zeny_Shop  4_M_BANKER,{
  mes "How much zeny do you need?";
  menu "10,000z", L_10k, "100,000z", L_100k, "1,000,000z", L_1m;
  L_10k: Zeny += 10000; close;
  L_100k: Zeny += 100000; close;
  L_1m: Zeny += 1000000; close;
}
```

### 6.4 Kafra & Storage
- [ ] Confirm Kafra storage is available in all towns
- [ ] Set storage capacity to a comfortable solo size

**File: `conf/battle/misc.conf`**
```
max_storage:    600    // Up from default 300
max_cart:       100
```

---

## Phase 7 — Custom QoL NPCs

> All custom NPC files go in `npc/custom/` and must be registered in `npc/scripts_custom.conf`

### 7.1 Global Warper NPC
```c
prontera,155,190,5  script  Global_Warper  4_F_TELEPORTER,{
  mes "[Global Warper]";
  mes "Where would you like to go?";
  menu
    "Towns", L_towns,
    "Dungeons", L_dungeons,
    "MVP Maps", L_mvp,
    "Instances", L_instances;

  L_towns:
    menu
      "Prontera", L_pront,
      "Morroc", L_morroc,
      "Geffen", L_geffen;
    L_pront: warp "prontera",155,185; end;
    L_morroc: warp "morocc",160,95; end;
    L_geffen: warp "geffen",119,59; end;

  L_dungeons:
    // Add dungeon warps here
    end;
  L_mvp:
    // Add MVP map warps
    end;
  L_instances:
    // Add instance entrances
    end;
}
```

### 7.2 Free Healer NPC
```c
prontera,152,185,5  script  Healer  4_F_NURSE,{
  mes "[Nurse Luna]";
  mes "Let me heal you fully!";
  percentheal 100,100;
  close;
}
```

### 7.3 Free Buffer NPC
```c
prontera,152,190,5  script  Buffer  4_M_WIZARD,{
  mes "[Magic Buffer]";
  mes "Let me cast support skills on you!";
  sc_start SC_BLESSING,600000,10;
  sc_start SC_INCREASEAGI,600000,10;
  sc_start SC_GLORIA,600000,5;
  sc_start SC_MAGNIFICAT,600000,5;
  sc_start SC_IMPOSITIO,600000,5;
  mes "Buffs applied for 10 minutes!";
  close;
}
```

### 7.4 Job Changer NPC
```c
prontera,158,185,5  script  Job_Changer  4_M_KNIGHT,{
  mes "[Job Instructor]";
  mes "Which job class do you want?";
  // Use callfunc or a full job-change script
  // Reference: npc/official/job_changer templates
  close;
}
```

### 7.5 Stat/Skill Reset NPC
```c
prontera,162,185,5  script  Reset_NPC  4_M_SAGE,{
  mes "[Skill Master]";
  menu
    "Reset Stats", L_stat,
    "Reset Skills", L_skill,
    "Reset Both", L_both;
  L_stat: resetstatus; mes "Stats reset!"; close;
  L_skill: resetskill; mes "Skills reset!"; close;
  L_both: resetstatus; resetskill; mes "Full reset done!"; close;
}
```

### 7.6 Register All Custom NPCs
**File: `npc/scripts_custom.conf`** — add:
```
npc: npc/custom/solo_item_shop.txt
npc: npc/custom/global_warper.txt
npc: npc/custom/healer.txt
npc: npc/custom/buffer.txt
npc: npc/custom/job_changer.txt
npc: npc/custom/reset_npc.txt
```

---

## Phase 8 — Story & Quest Experience

### 8.1 Enable All Story NPC Scripts
- [ ] Confirm the following NPC categories are active in `npc/scripts_main.conf`:
  - `npc/quests/` — main quest lines
  - `npc/eden/` — Eden Group quests
  - `npc/kafras/` — Kafra services
  - `npc/cities/` — Town NPCs with dialogue
  - `npc/re/` — Renewal content (if using Renewal mode)

### 8.2 Recommended Quest Lines for Solo Story
| Quest Line | Location | Notes |
|---|---|---|
| New World / Ash Vacuum | `npc/quests/kro/` | Main Renewal story arc |
| Eden Group Missions | `npc/eden/` | Excellent solo content |
| Rachel Sanctuary | `npc/quests/` | Rich lore |
| Nameless Island | `npc/quests/` | Story-driven dungeon |
| Nightmare Clock Tower | Instance | Adjust for solo |
| Old Glast Heim | Instance | Must-do storyline |

### 8.3 Instance Prerequisite Quests
- [ ] Check if story instances require prerequisite quests in `db/instance_db.yml`
- [ ] For solo play, you may optionally set `NeedsQuest: false` to bypass gates

### 8.4 Enable Cutscene & Cinematic NPCs
- [ ] Do not disable NPC scripts in populated towns — many contain hidden story dialogue
- [ ] Enable `npc/re/cities/` for Renewal city stories

---

## Phase 9 — Class, Skill & AI Tuning

### 9.1 Homunculus AI (Alchemist Companion)
**File: `conf/battle/skill.conf`**
```
homunculus_friendly_rate: 100    // Max friendly rate to player
```
- [ ] Use custom Homunculus AI scripts in `AI/` folder
- [ ] Recommended: **HAMI or Zetsu AI** for smarter behavior
- [ ] Homunculus becomes your primary partner — invest in its leveling

### 9.2 Mercenary Improvements
```
// conf/battle/skill.conf
mercenary_hp_rate: 150          // 150% HP for tankier mercenaries
mercenary_sp_rate: 150
```

### 9.3 Skill Adjustments for Solo Viability
**File: `db/import/skill_db.yml`** — example overrides:
```yaml
- Id: 83      # Heal
  MaxLevel: 10
  Cooldown: 0   # Remove cooldown for solo quality-of-life
```
- [ ] Review skills that are party-only and consider enabling them solo
- [ ] Adjust SP costs for long-duration solo grinding builds

### 9.4 Stat & Build Freedom
- [ ] Set high `max_parameter` values for freedom of experimentation

**File: `conf/battle/player.conf`**
```
max_parameter: 130          // Base stat cap (default 99)
max_third_parameter: 130    // Third job stat cap
```

---

## Phase 10 — GM Tools & Admin Setup

### 10.1 Essential @Commands for Solo Play

| Command | Purpose |
|---|---|
| `@go [town]` | Warp to any town |
| `@warp [map] [x] [y]` | Warp to exact coordinates |
| `@item [id] [amount]` | Spawn items |
| `@monster [id]` | Spawn a monster |
| `@heal` | Full HP/SP restore |
| `@speed [0-1000]` | Adjust move speed |
| `@job [id]` | Change job class instantly |
| `@blvl [level]` | Set base level |
| `@jlvl [level]` | Set job level |
| `@reloadscript` | Reload NPC scripts without restart |
| `@reloaditemdb` | Reload item database |
| `@mobinfo [id]` | View mob stats/drops |
| `@iteminfo [id]` | View item details |
| `@npc [name]` | Interact with NPC by name |

### 10.2 Configure `conf/atcommands.conf`
```
// Confirm all commands are enabled for group 99
// Most are on by default for high-level groups
```

### 10.3 Server Console Commands
- `reloadscript` — reload all NPC scripts live
- `reloadmobdb` — reload monster DB
- `reloaditemdb` — reload item DB
- `loadnpc [path]` — load a specific NPC file

---

## Phase 11 — Maintenance & Backup System

### 11.1 Daily Backup Script (Windows)
**File: `backup_ragnarok.bat`**
```bat
@echo off
set BACKUP_DIR=C:\RO_Backups\%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%
mkdir "%BACKUP_DIR%"
mysqldump -u ragnarok -pyour_password ragnarok > "%BACKUP_DIR%\ragnarok_db.sql"
xcopy /E /I "C:\rathena\conf" "%BACKUP_DIR%\conf"
xcopy /E /I "C:\rathena\npc\custom" "%BACKUP_DIR%\npc_custom"
xcopy /E /I "C:\rathena\db\import" "%BACKUP_DIR%\db_import"
echo Backup complete: %BACKUP_DIR%
```

### 11.2 Version Control Your Customizations
```bash
cd rathena
git init                          # If not already a git repo
echo "npc/custom/" >> .gitignore  # Or track it — your choice
git add conf/ npc/custom/ db/import/
git commit -m "Initial solo config"
```
- [ ] Create a `solo-config` branch to keep your changes separate from upstream

### 11.3 Updating rAthena Without Losing Custom Files
```bash
# Pull latest rAthena updates
git fetch origin
git merge origin/master

# If conflicts occur in conf/ or db/ files, resolve them manually
# Your npc/custom/ and db/import/ files are NEVER touched by updates
```

### 11.4 Key Files to Never Directly Edit (Use Import Override Instead)
| Original File | Override Location |
|---|---|
| `db/mob_db.yml` | `db/import/mob_db.yml` |
| `db/item_db.yml` | `db/import/item_db.yml` |
| `db/skill_db.yml` | `db/import/skill_db.yml` |
| `db/instance_db.yml` | `db/import/instance_db.yml` |

### 11.5 Server Health Checklist (Run Weekly)
- [ ] Check `log/` folder for errors and warnings
- [ ] Confirm all three servers are running (login, char, map)
- [ ] Verify DB backup completed successfully
- [ ] Test login from client
- [ ] Check for new rAthena commits for security fixes

---

## Quick Reference — File Map

```
rathena/
├── conf/
│   ├── login_athena.conf       # Phase 1
│   ├── char_athena.conf        # Phase 1
│   ├── map_athena.conf         # Phase 1, 3
│   ├── inter_server.conf       # Phase 1, 2
│   ├── groups.conf             # Phase 2, 10
│   ├── atcommands.conf         # Phase 10
│   └── battle/
│       ├── exp.conf            # Phase 3
│       ├── drops.conf          # Phase 3
│       ├── monster.conf        # Phase 4
│       ├── party.conf          # Phase 5
│       ├── player.conf         # Phase 3, 9
│       ├── skill.conf          # Phase 9
│       └── misc.conf           # Phase 6
├── db/
│   ├── mob_db.yml              # Phase 4 (READ ONLY)
│   ├── instance_db.yml         # Phase 5 (READ ONLY)
│   ├── skill_db.yml            # Phase 9 (READ ONLY)
│   └── import/                 # ✅ EDIT HERE — safe from updates
│       ├── mob_db.yml
│       ├── item_db.yml
│       ├── skill_db.yml
│       └── instance_db.yml
├── npc/
│   ├── scripts_main.conf       # Phase 8
│   ├── scripts_custom.conf     # Phase 7
│   └── custom/                 # ✅ ALL your custom NPCs go here
│       ├── global_warper.txt
│       ├── healer.txt
│       ├── buffer.txt
│       ├── job_changer.txt
│       ├── reset_npc.txt
│       └── solo_item_shop.txt
└── sql-files/                  # Phase 2 (initial DB setup)
```

---

## Implementation Order Summary

```
[Week 1]  Phase 1 → Phase 2 → Phase 10 (get server running + GM access)
[Week 1]  Phase 3 → Phase 4             (make it fun and survivable)
[Week 2]  Phase 5 → Phase 7             (solo instances + QoL NPCs)
[Week 2]  Phase 6 → Phase 8             (economy + story content)
[Week 3]  Phase 9 → Phase 11            (fine-tuning + backup habits)
[Ongoing] Adjust rates/balance as you play — solo tuning is personal!
```

---

*Generated for rAthena offline single-player setup | Last updated: 2025*
*Always test changes on a backup before applying to your main server.*
