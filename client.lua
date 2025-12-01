local DoorBones = {
    [0] = { "window_lf", "door_dside_f" },
    [1] = { "window_rf", "door_pside_f" },
    [2] = { "window_lr", "door_dside_r" },
    [3] = { "window_rr", "door_pside_r" }
}

local hasPermission = nil
local pendingMeasurement = false

local function ShowError(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, false, 2000)
end

local function SendUI(action, data)
    data = data or {}
    data.action = action
    SendNUIMessage(data)
end

local function GetClosestVehicleWithOpenDoor(radius)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    local veh = GetClosestVehicle(pos.x, pos.y, pos.z, radius, 0, 70)
    if veh == 0 or not DoesEntityExist(veh) then return nil end

    local bestDoor, bestDist

    for doorIndex, bones in pairs(DoorBones) do
        local boneIndex = GetEntityBoneIndexByName(veh, bones[1])
        if boneIndex ~= -1 then
            local bonePos = GetWorldPositionOfEntityBone(veh, boneIndex)
            local dist = #(pos - bonePos)

            if dist < radius then
                local ratio = GetVehicleDoorAngleRatio(veh, doorIndex)
                if not Config.RequireDoorOpen or (ratio and ratio > 0.1) then
                    if not bestDist or dist < bestDist then
                        bestDist = dist
                        bestDoor = doorIndex
                    end
                end
            end
        end
    end

    return bestDoor and veh or nil
end

local function CalculateVLT(veh)
    local tint = GetVehicleWindowTint(veh)

    local baseVLT = {
        [0] = 100, -- None
        [4] = 75,  -- Stock
        [3] = 70,  -- Light
        [6] = 55,  -- Green
        [2] = 20,  -- Dark Smoke
        [1] = 5,   -- Pure Black
        [5] = 5    -- Limo
    }

    local vlt = baseVLT[tint] or 100

    if Config.UseWeatherEffects then
        local w = GetPrevWeatherTypeHashName()
        if w == `OVERCAST` or w == `FOGGY` then
            vlt = vlt - 2
        elseif w == `RAIN` or w == `THUNDER` then
            vlt = vlt - 4
        end
    end

    if Config.RandomNoiseRange and Config.RandomNoiseRange > 0 then
        vlt = vlt + math.random(-Config.RandomNoiseRange, Config.RandomNoiseRange)
    end

    if vlt < 1 then vlt = 1 end
    if vlt > 100 then vlt = 100 end

    return math.floor(vlt + 0.5)
end

local function GetLegalStatus(vlt)
    if vlt >= Config.LegalLimit then
        return "LEGAL", "legal"
    elseif vlt >= (Config.LegalLimit - Config.BorderlineMargin) then
        return "BORDERLINE", "borderline"
    else
        return "ILLEGAL", "illegal"
    end
end

local function DoMeasurement()
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        ShowError("Exit the vehicle to measure tint.")
        return
    end

    local veh = GetClosestVehicleWithOpenDoor(Config.VehicleSearchRadius)
    if not veh then
        if Config.RequireDoorOpen then
            ShowError("No nearby open door window detected.")
        else
            ShowError("No nearby vehicle window detected.")
        end
        return
    end

    local vlt = CalculateVLT(veh)
    local status, code = GetLegalStatus(vlt)

    SendUI("show", {
        vlt    = vlt,
        status = status,
        code   = code,
    })

    CreateThread(function()
        Wait(Config.AutoHideTime or 5000)
        SendUI("hide")
    end)
end

RegisterNetEvent("csvlt:permissionResult", function(allowed)
    hasPermission = allowed

    if not allowed then
        ShowError("You do not have the required Discord role to use this.")
        pendingMeasurement = false
        return
    end

    if pendingMeasurement then
        pendingMeasurement = false
        DoMeasurement()
    end
end)

RegisterCommand(Config.MeasureCommand, function()
    if hasPermission == false then
        ShowError("You do not have permission to use this.")
        return
    end
    if hasPermission == nil then
        pendingMeasurement = true
        TriggerServerEvent("csvlt:requestPermission")
        return
    end

    DoMeasurement()
end, false)

CreateThread(function()
    Wait(300)
    SendUI("hide")
end)
