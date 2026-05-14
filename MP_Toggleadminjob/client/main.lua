-- ╔══════════════════════════════════════════════════════════╗
-- ║           TOGGLE ADMIN JOB — CLIENT                      ║
-- ╚══════════════════════════════════════════════════════════╝

-- Register the command on client side (triggers server-side logic)
RegisterCommand('toggleadminjob', function()
    TriggerServerEvent('toggleadminjob:server:toggle')
end, false)

-- Receive notification from server and display via ox_lib
RegisterNetEvent('toggleadminjob:client:notify', function(type, title, message)
    lib.notify({
        title       = title,
        description = message,
        type        = type,       -- 'success' | 'error' | 'inform'
        duration    = 6000,
        position    = 'top-right',
        icon        = 'briefcase',
    })
end)
