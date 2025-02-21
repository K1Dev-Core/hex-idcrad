local Core        = exports.vorp_core:GetCore()
local savedPhotos = {}

function GetPlayerFromId(src)
    local user = Core.getUser(src) --[[@as User]]
    if not user then return false end -- is player in session?
    local character = user.getUsedCharacter --[[@as Character]]
    if not character then return false end
    return {
        source = src,
        identifier = character.identifier,
        name = (character.firstname or "กำลังสร้างตัวละคร..") .. "  " .. (character.lastname or " "),
        job = character.job,
        jobGrade = character.jobGrade or 0,
        jobLabel = character.jobLabel,
        money = character.money,
        group = character.group,
        gold = character.gold

    }
end

function Currency(data)
    local user = Core.getUser(data.src)
    if not user then return end 
    local character = user.getUsedCharacter
    local currencyType = data.currency
    local amount = data.amount

    if data.type == "add" then   
        character.addCurrency(currencyType, amount)
    elseif data.type == "remove" then
        character.removeCurrency(currencyType, amount)
    end
end


Citizen.CreateThread(function()
    local fileContent = LoadResourceFile(GetCurrentResourceName(), "photos.json")
    if fileContent then
        savedPhotos = json.decode(fileContent)
    end
end)

local function SavePhotos()
    SaveResourceFile(GetCurrentResourceName(), "photos.json", json.encode(savedPhotos), -1)
end



exports.vorp_inventory:registerUsableItem(K1Dev['ไอเทมบัตร'], function(data)
    TriggerClientEvent("vorp_idcard:UseItem",data.source)
   
end)

RegisterServerEvent("vorp_idcard:showID")
AddEventHandler("vorp_idcard:showID", function(coords)
    local _source = source
    local player = GetPlayerFromId(_source)
    if not player then return end

    local photoUrl = savedPhotos[player.identifier] or ""
    
    -- Show ID to nearby players
    local players = GetPlayers()
    for _, playerID in ipairs(players) do
        local targetPed = GetPlayerPed(playerID)
        local targetCoords = GetEntityCoords(targetPed)
        
        if #(coords - targetCoords) < 3.0 then -- 3 meter radius
            TriggerClientEvent("vorp_idcard:showIDNearby", playerID, player, photoUrl)
        end
    end
end)

RegisterServerEvent("vorp_idcard:updatePhoto")
AddEventHandler("vorp_idcard:updatePhoto", function(photoUrl)
    local _source = source
    local player = GetPlayerFromId(_source)
    if not player then return end
    exports.vorp_inventory:getItemCount(_source, function(count)
        if count < 1 then 
            exports.vorp_inventory:addItem(_source, K1Dev['ไอเทมบัตร'],1)
            Currency({ src = _source, type = "remove", currency = 0, amount = 50 })
        end
    end, K1Dev['ไอเทมบัตร'])
    
    savedPhotos[player.identifier] = photoUrl
    SavePhotos()
    TriggerClientEvent("vorp:NotifyLeft", _source, "บัตรประชาชน", "สำเร็จ!", "generic_textures", "tick", 4000)
   
end)
function GetPlayerPhoto(identifier)
    if not identifier then return nil end
    if not savedPhotos[identifier] then return nil end
    local photoUrl = savedPhotos[identifier]
    if photoUrl == "" then return nil end
    
    return photoUrl
end

RegisterServerEvent("vorp_idcard:viewOtherID")
AddEventHandler("vorp_idcard:viewOtherID", function(targetId)
    local _source = source
    
    -- ตรวจสอบว่า targetId มีตัวตนจริง
    local targetPlayer = GetPlayerFromId(targetId)
    if not targetPlayer then 
        TriggerClientEvent("vorp:TipBottom", _source, "ไม่พบผู้เล่นที่ระบุ", 4000)
        return 
    end

    local photoUrl = GetPlayerPhoto(targetPlayer.identifier)

    if not photoUrl then 
        TriggerClientEvent("vorp:TipBottom", _source, "ไม่พบข้อมูล...", 4000)
        return 
    end
    TriggerClientEvent("vorp:TipBottom", targetId, "ท่านโดนตรวจบัตรประชาชน", 4000)
    -- ส่งข้อมูลบัตรกลับไปที่ผู้ขอดู
    TriggerClientEvent("vorp_idcard:showOtherID", _source, {
        name = targetPlayer.name,
        photo = photoUrl
    })
end)



exports('GetPlayerPhoto', GetPlayerPhoto)