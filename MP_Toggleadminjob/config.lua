Config = {}

--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              TOGGLE ADMIN JOB - CONFIG                   ║
    ╚══════════════════════════════════════════════════════════╝

    Add the CitizenIDs of players who are allowed to use
    the /toggleadminjob command below.
]]

-- ✅ Whitelisted CitizenIDs — only these can use /toggleadminjob
Config.AllowedCitizenIDs = {
    'O78190J9',   -- Snow
    'XYZ98765',   -- Example: Another admin
    -- Add more below...
}

-- The unemployed job name as it is defined in your QBox framework
-- Default in QBox is 'unemployed' — change only if yours differs
Config.UnemployedJob   = 'unemployed'
Config.UnemployedGrade = 0

-- SQL table name — you can leave this as-is
Config.TableName = 'toggleadminjob_saved'
