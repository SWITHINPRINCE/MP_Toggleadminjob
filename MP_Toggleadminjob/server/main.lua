-- ╔══════════════════════════════════════════════════════════╗
-- ║           TOGGLE ADMIN JOB — SERVER                      ║
-- ╚══════════════════════════════════════════════════════════╝

---------------------------------------------------
-- Utility: Send ox_lib notify to a player client
---------------------------------------------------
---@param src    number  Server ID
---@param type   string  'success' | 'error' | 'inform'
---@param title  string  Notification title
---@param msg    string  Notification body
local function notify(src, type, title, msg)
    TriggerClientEvent('toggleadminjob:client:notify', src, type, title, msg)
end

---------------------------------------------------
-- Utility: Check if a CitizenID is whitelisted
---------------------------------------------------
---@param citizenid string
---@return boolean
local function isAllowed(citizenid)
    for _, id in ipairs(Config.AllowedCitizenIDs) do
        if id == citizenid then
            return true
        end
    end
    return false
end

---------------------------------------------------
-- Bootstrap: Create SQL table on resource start
---------------------------------------------------
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `toggleadminjob_saved` (
            `citizenid`   VARCHAR(50)  NOT NULL,
            `saved_job`   VARCHAR(50)  NOT NULL DEFAULT 'unemployed',
            `saved_grade` INT          NOT NULL DEFAULT 0,
            `saved_label` VARCHAR(100) NOT NULL DEFAULT 'Unemployed',
            `toggled_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]], {})
    print('^2[toggleadminjob]^7 Database table verified/created successfully.')
end)

---------------------------------------------------
-- Main Toggle Event
---------------------------------------------------
RegisterNetEvent('toggleadminjob:server:toggle', function()
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)

    -- Validate player data
    if not Player then
        notify(src, 'error', 'Admin Job Toggle', 'Could not retrieve your player data. Please try again.')
        return
    end

    local citizenid  = Player.PlayerData.citizenid
    local playerName = GetPlayerName(src)
    local currentJob = Player.PlayerData.job

    -- ── Permission Gate ───────────────────────────────────────────
    if not isAllowed(citizenid) then
        notify(src, 'error', 'Access Denied', 'You do not have permission to use this command.')
        print(('[toggleadminjob] ^1BLOCKED^7 — %s (%s) tried to use /toggleadminjob without permission.'):format(
            playerName, citizenid
        ))
        return
    end

    local isCurrentlyUnemployed = (currentJob.name == Config.UnemployedJob)

    -- ── CASE 1: Player is unemployed → Restore saved job ─────────
    if isCurrentlyUnemployed then
        local row = MySQL.single.await(
            'SELECT saved_job, saved_grade, saved_label FROM ?? WHERE citizenid = ?',
            { Config.TableName, citizenid }
        )

        if not row then
            notify(src, 'inform', 'Admin Job Toggle',
                'No previous job found to restore. You were already unemployed when the resource started.')
            return
        end

        -- Restore the saved job
        Player.Functions.SetJob(row.saved_job, row.saved_grade)

        -- Clean up the saved row now that it's been restored
        MySQL.query.await(
            'DELETE FROM ?? WHERE citizenid = ?',
            { Config.TableName, citizenid }
        )

        notify(src, 'success', 'Job Restored ✓',
            ('Your previous job has been restored: %s (Grade %s)'):format(row.saved_label, row.saved_grade)
        )

        print(('[toggleadminjob] ^2RESTORED^7 — %s (%s) → Job: %s | Grade: %s'):format(
            playerName, citizenid, row.saved_job, row.saved_grade
        ))

    -- ── CASE 2: Player has a real job → Save it, set unemployed ──
    else
        -- Upsert current job into SQL
        MySQL.query.await([[
            INSERT INTO ?? (citizenid, saved_job, saved_grade, saved_label)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                saved_job   = VALUES(saved_job),
                saved_grade = VALUES(saved_grade),
                saved_label = VALUES(saved_label),
                toggled_at  = CURRENT_TIMESTAMP
        ]], {
            Config.TableName,
            citizenid,
            currentJob.name,
            currentJob.grade.level,
            currentJob.label
        })

        -- Set player to unemployed
        Player.Functions.SetJob(Config.UnemployedJob, Config.UnemployedGrade)

        notify(src, 'success', 'Job Toggled ✓',
            ('Previous job saved: %s. You are now Unemployed. Run /toggleadminjob again to restore.'):format(currentJob.label)
        )

        print(('[toggleadminjob] ^3TOGGLED^7 — %s (%s) | Saved: %s (Grade %s) → Set to unemployed'):format(
            playerName, citizenid, currentJob.name, currentJob.grade.level
        ))
    end
end)
