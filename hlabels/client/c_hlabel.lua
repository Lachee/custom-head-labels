                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    --[[
---------------------------------------------------
HEAD LABELS (C_HLABELS.LUA) by MrDaGree | Edited by Zeemah
---------------------------------------------------
Last revision: JUN 26 2020
---------------------------------------------------
NOTES 

---------------------------------------------------
]]

-- Spawn ESX Process
ESX = nil
Citizen.CreateThread(function()
    while not ESX do
        TriggerEvent("esx:getSharedObject", function(library)
            ESX = library
        end)
        Citizen.Wait(0)
    end
end)

local comicSans = false
local disPlayerNames = 15
local nameCache = {}

-- Gets the player name
function getCacheName(playerId)
	-- Cache the name
	if nameCache[playerId] then
		return nameCache[playerId]
	end

	-- Added request to cache the name
	ESX.TriggerServerCallback("esx_playerlabels:requestName", function(playerName)
		nameCache[playerId] = playerName
	end, playerId)

	-- Gets the current player name
	return 'OOC ' .. GetPlayerName(playerId)
end

RegisterFontFile("comic")
fontId = RegisterFontId("Comic Sans MS")

RegisterNetEvent('setHeadLabelDistance')
AddEventHandler('setHeadLabelDistance', function(distance)
	disPlayerNames = distance
	TriggerServerEvent("onClientHeadLabelRangeChange", distance)
end)

local LocalPlayer = {
	Ped = {
		Handle = 0
	}
}
CreateThread(function()
	while true do

		LocalPlayer.Ped.Handle = PlayerPedId()
		Wait(500)
	end
end)

function DrawText3D(x, y, z, text)
	local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
	local dist = #(GetGameplayCamCoords() - vec(x, y, z))

	local scale = (4.00001 / dist) * 0.3
	if scale > 0.2 then
		scale = 0.2
	elseif scale < 0.15 then
		scale = 0.15
	end

	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov

	if onScreen then
		SetTextFont(comicSans and fontId or 4)
		SetTextScale(scale, scale)
		SetTextProportional(true)
		SetTextColour(210, 210, 210, 180)
		SetTextCentre(true)
		SetTextDropshadow(50, 210, 210, 210, 255)
		SetTextOutline()
		SetTextEntry("STRING")
		AddTextComponentString(text)
		DrawText(_x, _y - 0.025)
	end
end

function ManageHeadLabels()
	for _, i in pairs(GetActivePlayers()) do
		if NetworkIsPlayerActive(i) then

			local iPed = GetPlayerPed(i)
			local lPlayer = PlayerId()
			if iPed ~= LocalPlayer.Ped.Handle then
				if DoesEntityExist(iPed) then
					local headLabelId = CreateMpGamerTag(iPed, " ", 0, 0, " ", 0)
										SetMpGamerTagName(headLabelId, " ")
										SetMpGamerTagVisibility(headLabelId, 0, false)
										RemoveMpGamerTag(headLabelId) 

					distance = #(GetEntityCoords(LocalPlayer.Ped.Handle) - GetEntityCoords(iPed))
					if distance < disPlayerNames then
						DrawText3D(GetEntityCoords(iPed)["x"], GetEntityCoords(iPed)["y"], GetEntityCoords(iPed)["z"]+1, GetPlayerServerId(i) .. "  |  " .. getCacheName(i) .. (NetworkIsPlayerTalking(i) and "~n~~g~Talking..." or ""))
					end
				end
			end
		end
	end
end

Citizen.CreateThread(function()
	while true do
		ManageHeadLabels()
		Citizen.Wait(0)
	end
end)