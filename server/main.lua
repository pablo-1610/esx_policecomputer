ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
ESX.RegisterServerCallback('esx_policecomputer:citizenCheck', function(source, cb, name)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local firstname = nil
	local lastname = nil
	local stringCount = 0
	local possibilites = {}
	local sex = nil
	local match = 0
	local arguments = {}
	local matched = {}
	arguments = mysplit(name, " ")
	if arguments[1] == nil or arguments[2] == nil then
		cb(matched)
		return
	end
	if #arguments == 1 or #arguments > 2 then
		cb(matched)
		return
	end
	
	firstname = string.upper(arguments[1])
	lastname = string.upper(arguments[2])


	MySQL.Async.fetchAll('SELECT * FROM users', {}, function(data)
		local finalmatch = {}
		for k,v in pairs(data) do
			local sex = ''
			if string.upper(v.firstname) == firstname then
				if string.upper(v.lastname) == lastname then
					match = match + 1
					if v.sex == m then sex = 'Homme' end
					if v.sex == f then sex = 'Femme' end
					table.insert(finalmatch, {
						fullname = v.firstname.." "..v.lastname,
						phone = v.phone_number,
						sexe = v.sex,
						naissance = v.dateofbirth,
						argentBanque = v.bank,
						identifier = v.identifier
					})
					cb(finalmatch)
				end
			end
		end
	end)
end)


ESX.RegisterServerCallback('esx_policecomputer:plateCheck', function(source, cb, plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local matched = {}
	local finalplate = string.upper(plate)
	local match = false
	if finalplate == nil then
		cb(matched)
		return
	end
	local finalmatch = {}
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles', {}, function(data)
		for k,v in pairs(data) do
			if finalplate == v.plate then
					match = true
					table.insert(finalmatch, {
						found = true,
						owner = v.owner
					})
					return
			end
		end
	end)
	Citizen.Wait(1000)
	if match == false then
		table.insert(finalmatch, {
						found = false
					})
	end
	cb(finalmatch)
	
end)


ESX.RegisterServerCallback('esx_policecomputer:ownerCheck', function(source, cb, identifier)
	local finalmatch = {}
	MySQL.Async.fetchAll('SELECT * FROM users', {}, function(data)
		local finalmatch = {}
		for k,v in pairs(data) do
			if identifier == v.identifier then
					table.insert(finalmatch, {
						fullname = v.firstname.." "..v.lastname,
						phone = v.phone_number,
						sex = v.sex,
						naissance = v.dateofbirth,
						argentBanque = v.bank,
						identifier = v.identifier
					})
					cb(finalmatch)
			end
		end
	end)
end)


ESX.RegisterServerCallback('esx_policecomputer:licensesCheck', function(source, cb, id)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = id

	local dvm
	local drive1
	local drive2
	local drive3

	MySQL.Async.fetchAll('SELECT * FROM user_licenses', {}, function(data)

		local finaldata = {}
		for k,v in pairs(data) do
			local sex = ''
			if v.owner == identifier then
				if v.type == 'dmv' then
					dvm = true
				end 
				if v.type == 'drive' then
					drive1 = true
				end 
				if v.type == 'drive_bike' then
					drive2 = true
				end 
				if v.type == 'drive_truck' then
					drive3 = true
				end 
			end
		end
		table.insert(finaldata, {
			d1 = '~r~Code',
			d2 = '~r~P.Voiture',
			d3 = '~r~P.Moto',
			d4 = '~r~P.Camion'
		})
		if dvm then finaldata[1].d1 = '~g~Code' end
		if drive1 then finaldata[1].d2 = '~g~P.Voiture' end
		if drive2 then finaldata[1].d3 = '~g~P.Moto' end
		if drive3 then finaldata[1].d4 = '~g~P.Camion' end
		cb(finaldata)
	end)
end)

function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end