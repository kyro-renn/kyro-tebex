local QBCore = exports['qb-core']:GetCoreObject()

RegisterNUICallback('ReedemCode', function(data, cb)
    print("done")
    TriggerServerEvent('kyro_tebex:ReedemCode', data.code)
    cb('ok')
end)

RegisterCommand(Config.Command, function()
    TriggerServerEvent('kyro_tebex:balance')
end, false)

RegisterNetEvent('kyro_tebex:sendBalance', function(balance)

    local credits = balance or 0
    

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openClaimMenu',
        balance = credits,
        site = Config.Site
    })
end)


RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)