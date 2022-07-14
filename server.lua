local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('nc-petshop:buyPet')
AddEventHandler('nc-petshop:buyPet', function(petType,price)
	local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)


	exports.oxmysql:execute('SELECT * FROM pets WHERE owner = ?', {
		xPlayer.PlayerData.citizenid,
	}, function (result)
		local ifOwner = table.unpack(result)
		if ifOwner ~= nil then
			TriggerClientEvent('QBCore:Notify', _source, 'You already own a Pet!', 'error')
			print('You already own a Pet!') -- Add notification here
		else
			if xPlayer.PlayerData.money.cash > price then
				TriggerClientEvent('QBCore:Notify', _source, 'You purchased a Pet!', 'success')
				print('You purchased a Pet!') -- Add notification here
				xPlayer.Functions.RemoveMoney('cash', price)
				exports.oxmysql:execute('INSERT INTO pets (owner, modelname) VALUES (?, ?)',
				{
					xPlayer.PlayerData.citizenid,
					petType,
				}, function (rowsChanged)

				end)
			else
				TriggerClientEvent('QBCore:Notify', _source, 'You cannot afford this pet', 'error')
				print('You cannot afford this pet') -- Add notification here
			end
		end
	end)
end)


RegisterServerEvent('nc-petshop:buyFood')
AddEventHandler('nc-petshop:buyFood', function(price)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer.PlayerData.money.cash >= price then
		xPlayer.Functions.RemoveMoney('cash', price)
		xPlayer.Functions.AddItem(Config.FoodItem,1)
		TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.FoodItem], "add")
	end
end)

RegisterServerEvent('nc-petshop:buyTennisBall')
AddEventHandler('nc-petshop:buyTennisBall', function(price)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer.PlayerData.money.cash >= price then
		xPlayer.Functions.RemoveMoney('cash', price)
		xPlayer.Functions.AddItem("tennisball",1)
		TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["tennisball"], "add")
	end
end)


RegisterServerEvent('nc-petshop:getOwnedPet')
AddEventHandler('nc-petshop:getOwnedPet',function()

	local xPlayer = QBCore.Functions.GetPlayer(source)

	exports.oxmysql:execute('SELECT * FROM pets WHERE owner = ?', {
		xPlayer.PlayerData.citizenid
	}, function (result)
		TriggerClientEvent('nc-petshop:spawnPet',modelname,health,illness)
	end)

end)

RegisterServerEvent('nc-petshop:chargeABitch')
AddEventHandler('nc-petshop:chargeABitch',function(fee)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer.PlayerData.money.cash >= (Config.HealPrice + fee) then
		xPlayer.Functions.RemoveMoney("cash", (Config.HealPrice + fee))
	end
end)

RegisterServerEvent('nc-petshop:returnBall')
AddEventHandler('nc-petshop:returnBall',function()
	local xPlayer = QBCore.Functions.GetPlayer(source)
	xPlayer.Functions.AddItem('tennisball',1)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["tennisball"], "add")
end)

RegisterServerEvent('nc-petshop:removeBall')
AddEventHandler('nc-petshop:removeBall',function()
	local xPlayer = QBCore.Functions.GetPlayer(source)
	xPlayer.Functions.RemoveItem('tennisball',1)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["tennisball"], "remove")
end)

QBCore.Functions.CreateUseableItem("tennisball", function(source)
	local xPlayer = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent('nc-petshop:useTennisBall', source)
	xPlayer.Functions.RemoveItem('tennisball', 1)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["tennisball"], "add")
    -- print('usado')
end)



function getPet(citizenid)

	exports.oxmysql:execute('SELECT * FROM pets WHERE owner = ?', {
		citizenid,
	}, function (result)
		id = result[1].id
		owner = result[1].owner
		modelname = result[1].modelname
		health = result[1].health
		illnesses = result[1].illnesses
		cb(id,owner,modelname,health,illnesses)
	end)


end

QBCore.Functions.CreateCallback("nc-petshop:getPetSQL", function(source, cb)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    --cb(getPet(xPlayer.PlayerData.citizenid))
	exports.oxmysql:execute('SELECT * FROM pets WHERE owner = ?', {
		xPlayer.PlayerData.citizenid,
	}, function (result)
		cb(result)
	end)
end)

QBCore.Functions.CreateCallback("nc-petshop:feedPetCallback", function(source, cb)
	local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(Config.FoodItem, 1) then
		TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.FoodItem], "remove")
		cb(true)
	else
		cb(false)
	end
end)


RegisterServerEvent('nc-petshop:updatePet')
AddEventHandler('nc-petshop:updatePet',function(health,illness)
    local xPlayer = QBCore.Functions.GetPlayer(source)

	exports.oxmysql:execute('UPDATE pets SET health = ?, illnesses = ? WHERE owner = ?', {
		health,
		illness,				
		xPlayer.PlayerData.citizenid,
	}, function(rowsChanged)

	end)

end)

RegisterServerEvent('nc-petshop:updatePetName')
AddEventHandler('nc-petshop:updatePetName',function(name)
    local xPlayer = QBCore.Functions.GetPlayer(source)

	exports.oxmysql:execute('UPDATE pets SET name = ? WHERE owner = ?', {
		name,		
		xPlayer.PlayerData.citizenid,
	}, function(rowsChanged)

	end)

end)



RegisterServerEvent('nc-petshop:removePet')
AddEventHandler('nc-petshop:removePet',function()
	local xPlayer = QBCore.Functions.GetPlayer(source)
	exports.oxmysql:execute('DELETE FROM pets WHERE owner = ?', {
		xPlayer.PlayerData.citizenid
	})

end)


RegisterNetEvent('nc-petshop:k9Search')
AddEventHandler('nc-petshop:k9Search',function(ID,targetID)
	print('nc checking..')
	local itemFound = false
	local source = source
	local targetPlayer = QBCore.Functions.GetPlayer(targetID)
	        for k, v in pairs(Config.SearchableItems.IllegalItems) do
            	if targetPlayer.Functions.GetItemByName(k).count >= v then
            		itemFound = true
            	end
        	end

		TriggerClientEvent('nc-petshop:k9ItemCheck', source, itemFound)

end)
