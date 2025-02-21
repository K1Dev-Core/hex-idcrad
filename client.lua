local display = false
local show = false
local InAction = false
local OpenToggleUI
local OpenToggleUIMp
local BordPrompts = GetRandomIntInRange(0, 0xffffff)

Citizen.CreateThread(function()


	str = 'Open Menu ID Crad '
	OpenToggleUI = PromptRegisterBegin()
	PromptSetControlAction(OpenToggleUI, K1Dev['ปุ่มสำหรับเปิด'] )
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(OpenToggleUI, str)
	PromptSetEnabled(OpenToggleUI, true)
	PromptSetVisible(OpenToggleUI, true)
	PromptSetStandardMode(OpenToggleUI, 1)
	PromptSetGroup(OpenToggleUI, BordPrompts)
	PromptRegisterEnd(OpenToggleUI)
    PromptSetStandardizedHoldMode(OpenToggleUI, GetHashKey("MEDIUM_TIMED_EVENT"))


end)


RegisterNetEvent("vorp_idcard:UseItem")
AddEventHandler("vorp_idcard:UseItem", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    TriggerEvent("vorp_inventory:CloseInv") 
    TriggerServerEvent("vorp_idcard:showID", coords)
    RequestAnimDict("mech_butcher")
    while not HasAnimDictLoaded("mech_butcher") do
        Citizen.Wait(100)
    end

    TaskPlayAnim(PlayerPedId(), "mech_butcher", "medium_fish_give_player", 1.0,
        1.0, 2500, 0, 0, false, false, false)
end)


-- Handle NUI Callbacks
RegisterNUICallback("loaded", function(data, cb)
    cb('ok')
end)
RegisterNUICallback("closeModal", function(data, cb)
    SetNuiFocus(false, false)
    InAction = false 
    ClearPedSecondaryTask(PlayerPedId())
    ClearPedTasks(PlayerPedId())
    ClearPedTasksImmediately(PlayerPedId())
end)



RegisterNUICallback("submitPhoto", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("vorp_idcard:updatePhoto", data.photoUrl)

    InAction = false 
    ClearPedSecondaryTask(PlayerPedId())
    ClearPedTasks(PlayerPedId())
    ClearPedTasksImmediately(PlayerPedId())
    cb('ok')
end)

RegisterNUICallback("closeUI", function(_, cb)
    SetNuiFocus(false, false)
    InAction = false 
    ClearPedSecondaryTask(PlayerPedId())
    ClearPedTasks(PlayerPedId())
    ClearPedTasksImmediately(PlayerPedId())
    cb('ok')
end)



RegisterNetEvent('getPlayerInfoById')
AddEventHandler('getPlayerInfoById', function(id)
    print(id)
    if LocalPlayer.state.Character.Job == 'doctor' or LocalPlayer.state.Character.Job == 'lawman' then 
        if show then return end
        TriggerServerEvent("vorp_idcard:viewOtherID",id)
    end
   
end)


RegisterNetEvent("vorp_idcard:showIDNearby")
AddEventHandler("vorp_idcard:showIDNearby", function(playerData, photoUrl)
    if show then return end
    show = true
    SendNUIMessage({
        type = "showID",
        name = playerData.name,
        photo = photoUrl
    })
    
    Citizen.SetTimeout(10000, function()
        show = false
        SendNUIMessage({
            type = "hideID"
        })
    end)
end)


RegisterNetEvent("vorp_idcard:showOtherID")
AddEventHandler("vorp_idcard:showOtherID", function(playerData)
    if show then return end
    show = true
    
    SendNUIMessage({
        type = "showID",
        name = playerData.name,
        photo = playerData.photo
    })
    
    Citizen.SetTimeout(10000, function()
        show = false
        SendNUIMessage({
            type = "hideID"
        })
    end)
end)


Citizen.CreateThread(function() --
	while true do
		local t = 4
        local canwait = true
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
            for k,v in pairs(K1Dev['จุด']) do
                local dist = GetDistanceBetweenCoords(coords, v, 1)
                if dist < K1Dev['ระยะในการกดเปิดเมนู'] and not InAction then
                    local label = CreateVarString(10, 'LITERAL_STRING',  '~o~ ID Crad  ~q~  ')
                    PromptSetActiveGroupThisFrame(BordPrompts, label)
                    if PromptHasHoldModeCompleted(OpenToggleUI)  and not IsPedOnMount(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId())   then
                        SetNuiFocus(true, true)
                        SendNUIMessage({
                            type = "openPhotoUpdate",
                            name = LocalPlayer.state.Character.FirstName..' '..LocalPlayer.state.Character.LastName,
                            
                        })
                        DisablePlayerFiring(PlayerPedId(), true)
                        ClearPedSecondaryTask(PlayerPedId())
                        ClearPedTasks(PlayerPedId())
                        ClearPedTasksImmediately(PlayerPedId())
                        TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_WRITE_NOTEBOOK'), -1, true, false, false, false)
                        InAction = true 
                        Wait(1000)
                    end
               
                   

                    
                end

            end
        Citizen.Wait(t)
    end
end)
