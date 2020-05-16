local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData              = {}
ESX                           = nil


Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end

  while ESX.GetPlayerData().job == nil do
    Citizen.Wait(10)
  end

  PlayerData = ESX.GetPlayerData()
end)

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Ordinateur", "~b~Ordinateur de police")
_menuPool:Add(mainMenu)

function computer(menu)
  local citizenCheck = NativeUI.CreateItem("Obtenir infos citoyen","Requiert un prénom et un nom")
  local plateCheck = NativeUI.CreateItem("Obtenir infos plaque","Requiert une plaque") 
  menu:AddItem(citizenCheck)
  menu:AddItem(plateCheck)
  menu.OnItemSelect = function(sender, item, index)
    if item == citizenCheck then
      DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 600)
      while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
      end
      if (GetOnscreenKeyboardResult()) then
        local msg = GetOnscreenKeyboardResult()
        if msg ~= nil and msg ~= '' then
          ESX.TriggerServerCallback('esx_policecomputer:citizenCheck', function(finalmatch) 
            Citizen.Wait(1500)
            if finalmatch == nil then
              ESX.ShowNotification('err')
                ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~Erreur', "Aucun résultat pour ~y~"..msg, 'CHAR_CHAT_CALL', 2, true, false, 60)
            else
                  local thesex
                  if finalmatch[1].sexe == 'm' then
                    thesex = 'Homme'
                  else
                    thesex = 'Femme'
                  end
                  ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~'..string.upper(msg),
                  "~b~• Téléphone: ~y~"..finalmatch[1].phone.."~n~"..
                  "~b~• Sexe: ~y~"..thesex.."~n~"..
                  "~b~• Né le: ~y~"..finalmatch[1].naissance
                  , 'CHAR_CHAT_CALL', 2, true, false, 60)
                  ESX.TriggerServerCallback('esx_policecomputer:licensesCheck', function(id)
                    ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~PERMIS',
                  id[1].d1.."~n~"..id[1].d2.."~n~"..id[1].d3.."~n~"..id[1].d4
                  , 'CHAR_CHAT_CALL', 2, true, false, 60)
                  end, finalmatch[1].identifier)
            end
          end, msg)
        else
          ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~Erreur', "Vous devez indiquer un prénom et un nom !", 'CHAR_CHAT_CALL', 2, true, false, 60)
        end
      end
    end



    if item == plateCheck then
      DisplayOnscreenKeyboard(1, "", "", "", "", "", "", 600)
      while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
      end
      if (GetOnscreenKeyboardResult()) then
        local msg = GetOnscreenKeyboardResult()
        if msg ~= nil and msg ~= '' then
          ESX.TriggerServerCallback('esx_policecomputer:plateCheck', function(finalmatch) 
            if finalmatch[1].found == true then
              ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~STATUT', "~y~Ce véhicule est enregistré !~n~~n~Obtention des informations du propriétaire...", 'CHAR_CHAT_CALL', 2, true, false, 60)
              ESX.TriggerServerCallback('esx_policecomputer:ownerCheck', function(ownerinfos)
                  local thesex
                  if ownerinfos[1].sex == 'm' then
                    thesex = 'Homme'
                  else
                    thesex = 'Femme'
                  end 
                Citizen.Wait(1000)
                ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~PROPRIÉTAIRE', "~g~"..ownerinfos[1].fullname.."~n~~b~• Téléphone: ~y~"..ownerinfos[1].phone.."~n~"..
                  "~b~• Sexe: ~y~"..thesex, 'CHAR_CHAT_CALL', 2, true, false, 60)
                ESX.TriggerServerCallback('esx_policecomputer:licensesCheck', function(id)
                    ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~PERMIS',
                  id[1].d1.."~n~"..id[1].d2.."~n~"..id[1].d3.."~n~"..id[1].d4
                  , 'CHAR_CHAT_CALL', 2, true, false, 60)
                  end, finalmatch[1].owner)
              end, finalmatch[1].owner)
            else
              ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~STATUT', "~y~Ce véhicule n'est pas enregistré.", 'CHAR_CHAT_CALL', 2, true, false, 60)
            end
          end, msg)
        else
          ESX.ShowAdvancedNotification('~b~Ordinateur de police', '~r~Erreur', "Vous devez indiquer un prénom et un nom !", 'CHAR_CHAT_CALL', 2, true, false, 60)
        end
      end
    end
  end 
end



function vehicleType(using)
  local cars = Config.Vehicles
  for i=1, #cars, 1 do
    if IsVehicleModel(using, GetHashKey(cars[i])) then
      return true
    end
  end
end


computer(mainMenu)
_menuPool:RefreshIndex()
_menuPool:MouseControlsEnabled(false)
_menuPool:ControlDisablingEnabled(false)



Citizen.CreateThread(function()
    while true do
    Citizen.Wait(1)
      _menuPool:ProcessMenus()
        if vehicleType(GetVehiclePedIsUsing(GetPlayerPed(-1))) then
          if PlayerData.job ~= nil and PlayerData.job.name == 'police' then
            if GetPedInVehicleSeat(GetVehiclePedIsUsing(GetPlayerPed(-1)), -1) == GetPlayerPed(-1) or GetPedInVehicleSeat(GetVehiclePedIsUsing(GetPlayerPed(-1)), 0) == GetPlayerPed(-1) then
              ESX.ShowHelpNotification("Appuyez sur ~INPUT_MAP_POI~ pour ouvrir l'ordinateur de police")
                if IsControlJustPressed(1,348) then
                    mainMenu:Visible(not mainMenu:Visible())
                end
            end
          end
        end
    
    end
end)