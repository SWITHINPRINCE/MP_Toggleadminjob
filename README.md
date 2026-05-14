# 🔧 toggleadminjob

> A QBox FiveM resource that lets whitelisted admins seamlessly toggle between their real job and `unemployed` — with job state saved to SQL so it persists across restarts and reconnects.

---

## ✨ Features

- `/toggleadminjob` command restricted to specific **CitizenIDs** only
- Unauthorized players see an **ox_lib error notification** — *"You do not have permission"*
- Toggle **any job → unemployed** with one command
- Toggle back and your **exact previous job + grade is restored**
- State is saved to **MySQL** — survives server restarts and player reconnects
- Uses **upsert** so toggling multiple times never creates duplicate rows
- Clean **server console logs** for every action (blocked / toggled / restored)
- SQL table is **auto-created** on resource start — zero manual DB setup needed (optional `.sql` file also included)

---

## 📦 File Structure

```
toggleadminjob/
├── fxmanifest.lua          — Resource manifest
├── config.lua              — Whitelisted CitizenIDs & settings
├── toggleadminjob.sql      — Optional manual SQL install file
├── README.md               — This file
├── client/
│   └── main.lua            — Command registration + ox_lib notify receiver
└── server/
    └── main.lua            — Permission check, SQL logic, job toggle
```

---

## 🔗 Dependencies

| Dependency | Purpose |
|---|---|
| [`qbx_core`](https://github.com/Qbox-project/qbx_core) | Player data & SetJob |
| [`ox_lib`](https://github.com/overextended/ox_lib) | Notifications |
| [`oxmysql`](https://github.com/overextended/oxmysql) | Async SQL queries |

All three are standard in a QBox server setup.

---

## ⚙️ Installation

### 1. Drop the resource
Place the `toggleadminjob` folder into your `resources/` directory:
```
resources/
└── [custom]/
    └── toggleadminjob/
```

### 2. Add to server.cfg
```cfg
ensure toggleadminjob
```
Make sure it starts **after** `qbx_core`, `ox_lib`, and `oxmysql`.

### 3. Configure CitizenIDs
Open `config.lua` and add your admin CitizenIDs:
```lua
Config.AllowedCitizenIDs = {
    'ABC12345',   -- Your CitizenID
    'XYZ98765',   -- Another admin
}
```

> **How to find a CitizenID:**
> Check your database → `players` table → `citizenid` column.
> Or ask the player to run a `/myid` command if you have one set up.

### 4. Database (automatic)
The SQL table is **auto-created** when the resource starts. You don't need to do anything.

If you prefer to create it manually, run the included `toggleadminjob.sql` file in HeidiSQL, phpMyAdmin, or TablePlus.

---

## 🎮 Usage

| Situation | Command | Result |
|---|---|---|
| You are a **Mechanic** (or any job) | `/toggleadminjob` | Job saved to DB → Set to **Unemployed** |
| You are **Unemployed** (after toggle) | `/toggleadminjob` | Previous job restored from DB → **Mechanic** again |
| **Unauthorized** player uses command | `/toggleadminjob` | 🔴 ox_lib error: *"You do not have permission"* |

---

## 🗄️ Database Schema

```sql
CREATE TABLE `toggleadminjob_saved` (
    `citizenid`   VARCHAR(50)  NOT NULL,   -- QBox CitizenID
    `saved_job`   VARCHAR(50)  NOT NULL,   -- e.g. 'mechanic'
    `saved_grade` INT          NOT NULL,   -- e.g. 2
    `saved_label` VARCHAR(100) NOT NULL,   -- e.g. 'Mechanic'
    `toggled_at`  TIMESTAMP    NOT NULL,   -- Last toggle time
    PRIMARY KEY (`citizenid`)
);
```

One row per player. The row is **deleted automatically** once the job is restored — so the table stays clean.

---

## 🖥️ Server Console Output

```
[toggleadminjob] Database table verified/created successfully.
[toggleadminjob] TOGGLED   — PlayerName (ABC12345) | Saved: mechanic (Grade 2) → Set to unemployed
[toggleadminjob] RESTORED  — PlayerName (ABC12345) → Job: mechanic | Grade: 2
[toggleadminjob] BLOCKED   — PlayerName (QQQ99999) tried to use /toggleadminjob without permission.
```

---

## 🔧 Config Reference

```lua
-- config.lua

Config.AllowedCitizenIDs = {
    'ABC12345',  -- Add CitizenIDs here
}

Config.UnemployedJob   = 'unemployed'  -- Unemployed job name in your framework
Config.UnemployedGrade = 0             -- Grade for unemployed

Config.TableName = 'toggleadminjob_saved'  -- SQL table name (don't change unless needed)
```

---

## ❓ FAQ

**Q: What if I restart the server while toggled to unemployed?**
The saved job stays in the database. When you log back in and run `/toggleadminjob`, it will restore your previous job correctly.

**Q: What if I change my job in-game while toggled to unemployed?**
The next `/toggleadminjob` will still restore the job that was saved at the time of the original toggle. The DB row is only deleted on a successful restore.

**Q: Can I add more than 2 CitizenIDs?**
Yes — add as many as you need to the `Config.AllowedCitizenIDs` table in `config.lua`.

**Q: Does this work with QBCore (not QBox)?**
It is built for **QBox** (`qbx_core`). For QBCore, replace `exports.qbx_core:GetPlayer(src)` with `QBCore.Functions.GetPlayer(src)`.

---

## 📄 License

Free to use and modify for personal / private server use.
