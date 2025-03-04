local QBCore = exports['qb-core']:GetCoreObject()

local function CreateLog(src, info)
    local Player = QBCore.Functions.GetPlayer(src)
    local license = Player and Player.PlayerData.license or "Console"
    local text = info.text or ""

    local embed = {
        ["color"] = 65280, 
        ["title"] = "kyro Tebex Logs",
        ["description"] = text,
        ["thumbnail"] = {
            ["url"] = 'https://raw.githubusercontent.com/kyro-renn/kyro-assets/main/kyro_header.png'
        },
        ["footer"] = {
            ["text"] = "Kyro Renn Developments - " .. os.date("%c") .. " (Server Time)",
            ["icon_url"] = 'https://raw.githubusercontent.com/kyro-renn/kyro-assets/main/kyro_header.png'
        },
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "Kyro Renn developments", avatar_url = 'https://dunb17ur4ymx4.cloudfront.net/webstore/logos/99ba5cd28611a60446c9390fa960b896dd889899.png', embeds = {embed}}), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('kyro_tebex:balance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local license = Player.PlayerData.license
    local existingCredits = MySQL.query.await('SELECT * FROM kyro_credits WHERE license = ?', {license})
    local balance = existingCredits[1] and existingCredits[1].credits or 0
    TriggerClientEvent('kyro_tebex:sendBalance', src, balance)
end)

RegisterNetEvent('kyro_tebex:ReedemCode', function(code)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local firstname = player.PlayerData.charinfo.firstname
    local lastname = player.PlayerData.charinfo.lastname
    local license = player.PlayerData.license

    -- Query the database for the provided code
    local result = MySQL.query.await('SELECT * FROM kyro_codes WHERE code = ?', {code})

    if not result or not result[1] then
        TriggerClientEvent('QBCore:Notify', source, "Code is currently invalid. If you have just purchased, please try again in a few minutes.", "error")
        return
    end

    -- Extract package details
    local packageName = result[1].packagename
    local credits = result[1].credits or 0

    -- Get previous balance
    local existingCredits = MySQL.query.await('SELECT * FROM kyro_credits WHERE license = ?', {license})
    local previousBalance = existingCredits[1] and existingCredits[1].credits or 0

    -- Handle credits
    if credits > 0 then
        if existingCredits[1] then
            MySQL.query.await('UPDATE kyro_credits SET credits = credits + ? WHERE license = ?', {credits, license})
        else
            MySQL.query.await('INSERT INTO kyro_credits (license, credits) VALUES (?, ?)', {license, credits})
        end

        TriggerClientEvent('QBCore:Notify', source, "You have received " .. credits .. " credits.", "success")
      
    end


    if packageName and packageName ~= "" and packageName ~= "[\"\"]" then
        if type(packageName) == "string" then
            local decodedPackage = json.decode(packageName)
            if type(decodedPackage) == "table" and #decodedPackage > 0 then
                packageName = decodedPackage[1]
            end
        end

        TriggerClientEvent('QBCore:Notify', source, "The " .. packageName .. " Membership Claimed", "success")

 
        local membershipDuration = 31 
        local existingMembership = MySQL.query.await('SELECT expire_date FROM kyro_memberships WHERE license = ? AND member = ?', {license, packageName})
        local currentTime = os.date("%Y-%m-%d %H:%M:%S")
        if existingMembership[1] then
       
            MySQL.query.await('UPDATE kyro_memberships SET expire_date = DATE_ADD(expire_date, INTERVAL ? DAY) WHERE license = ? AND member = ?', {membershipDuration, license, packageName})
            TriggerClientEvent('QBCore:Notify', source, "Membership has been extended.", "success")
        else
      
            MySQL.query.await('INSERT INTO kyro_memberships (license, member, expire_date) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? DAY))', {license, packageName, membershipDuration})
            TriggerClientEvent('QBCore:Notify', source, "Membership has been added.", "success")
        end
    end


    local logText = string.format("Player with license %s claimed code %s for %d credits and %s membership. Their previous balance was %d credits.", license, code, credits, packageName, previousBalance)
    CreateLog(source, {text = logText})


    MySQL.query.await('DELETE FROM kyro_codes WHERE code = ?', {code})
end)

RegisterCommand('purchase_package_tebex', function(source, args)
    if source == 0 then
        local dec = json.decode(args[1])
        local tbxid = dec.transid
        local packTab = {}
        local credits = dec.credits or 0
        local logText = string.format('id: ' .. tbxid .. ' Package: ' .. dec.packagename .. " Credits: " .. credits)
        CreateLog(source, {text = logText})

        while inProgress do
            Wait(1000)
        end
        inProgress = true

        MySQL.query('SELECT * FROM kyro_codes WHERE code = ?', { tbxid }, function(result)
            if result[1] then
           
                local packagetable = json.decode(result[1].packagename)
                packagetable[#packagetable + 1] = dec.packagename
                MySQL.update('UPDATE kyro_codes SET packagename = ?, credits = credits + ? WHERE code = ?', {
                    json.encode(packagetable), credits, tbxid
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        print("Updated package successfully.")
                    else
                        print("Failed to update package.")
                    end
                end)
            else
          
                packTab[#packTab + 1] = dec.packagename
                MySQL.insert("INSERT INTO kyro_codes (code, packagename, credits) VALUES (?, ?, ?)", {
                    tbxid, json.encode(packTab), credits
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        print("Inserted package successfully.")
                    else
                        print("Failed to insert package.")
                    end
                end)
            end
            inProgress = false
        end)

    end
end, false)


exports('GetBalance', function(license)
    local existingCredits = MySQL.query.await('SELECT * FROM kyro_credits WHERE license = ?', {license})
    return existingCredits[1] and existingCredits[1].credits or 0
end)

exports('GetMembership', function(license)
    local memberships = MySQL.query.await('SELECT * FROM kyro_memberships WHERE license = ?', {license})
    return memberships
end)

exports('RemoveCredits', function(license, amount)
    local existingCredits = MySQL.query.await('SELECT * FROM kyro_credits WHERE license = ?', {license})
    if existingCredits[1] and existingCredits[1].credits >= amount then
        MySQL.query.await('UPDATE kyro_credits SET credits = credits - ? WHERE license = ?', {amount, license})

        local logText = string.format("Removed %d credits from license %s. New balance: %d credits.", amount, license, existingCredits[1].credits - amount)
        CreateLog(0, {text = logText})
        return true
    else
        return false
    end
end)

exports('AddCredits', function(license, amount)
    local existingCredits = MySQL.query.await('SELECT * FROM kyro_credits WHERE license = ?', {license})
    if existingCredits[1] then
        MySQL.query.await('UPDATE kyro_credits SET credits = credits + ? WHERE license = ?', {amount, license})
    else
        MySQL.query.await('INSERT INTO kyro_credits (license, credits) VALUES (?, ?)', {license, amount})
    end

    local logText = string.format("Added %d credits to license %s. New balance: %d credits.", amount, license, existingCredits[1] and existingCredits[1].credits + amount or amount)
    CreateLog(0, {text = logText})
    return true
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS kyro_credits (
                id INT AUTO_INCREMENT PRIMARY KEY,
                license VARCHAR(50) NOT NULL,
                credits INT NOT NULL
            )
        ]])

        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS kyro_codes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                code VARCHAR(50) NOT NULL,
                packagename TEXT NOT NULL,
                credits INT NOT NULL
            )
        ]])

        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS kyro_memberships (
                id INT AUTO_INCREMENT PRIMARY KEY,
                license VARCHAR(50) NOT NULL,
                member VARCHAR(50) NOT NULL,
                expire_date DATETIME NOT NULL
            )
        ]])


        RemoveExpiredMemberships()
    end
end)

local function RemoveExpiredMemberships()
    local expiredMembers = MySQL.query.await('SELECT license FROM kyro_memberships WHERE expire_date < NOW()')

    if expiredMembers and #expiredMembers > 0 then
        for _, member in ipairs(expiredMembers) do
            local playerData = MySQL.query.await('SELECT name, citizenid FROM players WHERE license = ?', { member.license })

            if playerData and #playerData > 0 then
                local player = playerData[1] 
                local logText = string.format(player.name .. " (" .. player.citizenid .. ") membership expired.")
                CreateLog(source, {text = logText})
            end
        end

    
        MySQL.Async.execute('DELETE FROM kyro_memberships WHERE expire_date < NOW()')
    end
end