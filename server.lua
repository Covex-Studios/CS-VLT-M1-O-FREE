local function PlayerHasRequiredRole(src)
    if not Config.RequiredDiscordRoleId or Config.RequiredDiscordRoleId == "" then
        return true
    end

    local required = tostring(Config.RequiredDiscordRoleId)
    local roles = exports.Badger_Discord_API:GetDiscordRoles(src)
    if not roles or roles == false then
        return false
    end

    for _, roleId in ipairs(roles) do
        if tostring(roleId) == required then
            return true
        end
    end

    return false
end

RegisterNetEvent("csvlt:requestPermission", function()
    local src = source
    local allowed = PlayerHasRequiredRole(src)
    TriggerClientEvent("csvlt:permissionResult", src, allowed)
end)
