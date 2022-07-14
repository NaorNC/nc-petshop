local QBCore = exports['qb-core']:GetCoreObject()
local pet, bowlObj, activePet, illness
local petHealth, petFood = 100, 300
local petMoving, stay, feeding, ballThrown, chasing, searching = false, false, false, false, false, false
local petSpeed = 8.0
local attacking = false
local petShopSpawned, vetSpawned = false, false
local petShopNPC, vet
local petName = 'Pet'

PlayerJob = {}

Citizen.CreateThread(function()
    while QBCore.Functions.GetPlayerData() == nil do
        Citizen.Wait(10)
    end

    PlayerData = QBCore.Functions.GetPlayerData()

    
end)

CreateThread(function()
    local blip1 = AddBlipForCoord(563.76, 2753.27, 41.88)
    SetBlipSprite(blip1, 273)
    SetBlipScale(blip1, 0.5)
    SetBlipColour(blip1, 48)
    SetBlipAsShortRange(blip1, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Pet Shop')
    EndTextCommandSetBlipName(blip1)

    local blip2 = AddBlipForCoord(-1406.1, -437.41, 35.56)
    SetBlipSprite(blip2, 537)
    SetBlipScale(blip2, 0.5)
    SetBlipColour(blip2, 48)
    SetBlipAsShortRange(blip2, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Pet Clinic')
    EndTextCommandSetBlipName(blip2)
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(response)
    PlayerJob = response
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

-- On player spawn, set relationship to all pets
AddEventHandler('playerSpawned', function()
    local Player = PlayerPedId()
    AddRelationshipGroup('OWNER')
    SetPedRelationshipGroupHash(Player, GetHashKey('OWNER'))
end)

-- Spawn NPC When you get close, delete when you leave
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local pedCoords = GetEntityCoords(PlayerPedId())
        local spawnCoords = vector3(563.76, 2753.27, 41.88)
        local dst = #(spawnCoords - pedCoords)

        if dst < 100 and petShopSpawned == false then
            TriggerEvent('nc-petshop:spawnPed', spawnCoords, 178.33)
            petShopSpawned = true
        end
        if dst >= 101 then
            petShopSpawned = false
            DeleteEntity(petShopNPC)
        end
    end
end)
-- Spawn NPC
RegisterNetEvent('nc-petshop:spawnPed')
AddEventHandler('nc-petshop:spawnPed', function(coords, heading)
    local hash = GetHashKey('a_f_y_soucent_03')
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    petShopNPC = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(petShopNPC, true)
    SetEntityInvincible(petShopNPC, true)
    SetBlockingOfNonTemporaryEvents(petShopNPC, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qb-target']:AddEntityZone('petShopNPC', petShopNPC, {
        name = "petShopNPC",
        debugPoly = false,
        eading = GetEntityHeading(petShopNPC)
    }, {
        options = {{
            type = "client",
            event = "nc-petshop:petStore",
            icon = "fa fa-circle",
            label = "Open Shop"
        }},
        distance = 2.5
    })

end)

-- Spawn VET NPC When you get close, delete when you leave
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local pedCoords = GetEntityCoords(PlayerPedId())
        local spawnCoords = vector3(-1406.05, -431.21, 35.55)
        local dst = #(spawnCoords - pedCoords)

        if dst < 100 and vetSpawned == false then
            TriggerEvent('nc-petshop:spawnVet', spawnCoords, 32.84)
            vetSpawned = true
        end
        if dst >= 101 then
            vetSpawned = false
            DeleteEntity(vet)
        end
    end
end)

-- Spawn NPC
RegisterNetEvent('nc-petshop:spawnVet')
AddEventHandler('nc-petshop:spawnVet', function(coords, heading)
    local hash = GetHashKey('s_f_y_sweatshop_01')
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    vet = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(vet, true)
    SetEntityInvincible(vet, true)
    SetBlockingOfNonTemporaryEvents(vet, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qb-target']:AddEntityZone('vet', vet, {
        name = "vet",
        debugPoly = false,
        heading = GetEntityHeading(vet)
    }, {
        options = {{
            type = "client",
            event = "nc-petshop:healPet",
            icon = "fa fa-circle",
            label = "Heal Pet"
        }, {
            type = "client",
            event = "nc-petshop:removePet",
            icon = "fa fa-circle",
            label = "Abandon Your Pet"
        }},
        distance = 2.5
    })

end)

Citizen.CreateThread(function()
    RegisterCommand('petmenu', PetMenu, false)
    RegisterCommand('petattack', k9Attack, false)
    RegisterCommand('petsearch', k9Search, false)
end)

local aiming, entity

function k9Search()
    if PlayerJob.name == 'police' then
        if DoesEntityExist(pet) then
            attacking = true
            if IsPlayerFreeAiming(PlayerId()) then
                aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if (aiming) then
                    if IsEntityAPed(entity) then
                        TaskGoToEntity(pet, entity, -1, 2.0, petSpeed, 1073741824.0, 0)
                        searching = true
                        return entity
                    end
                end
            end
        end
    end

end

function k9Attack()
    if PlayerJob.name == 'police' then
        if DoesEntityExist(pet) then
            attacking = true
            if IsPlayerFreeAiming(PlayerId()) then
                aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if (aiming) then
                    if IsEntityAPed(entity) then
                        SetCanAttackFriendly(pet, true, false)
                        SetPedRelationshipGroupDefaultHash(entity, GetHashKey("CIVMALE"))
                        SetPedRelationshipGroupHash(pet, GetHashKey('COUGAR'))
                        TaskPutPedDirectlyIntoMelee(pet, entity, 0.0, -1.0, 0.0, 0)
                        return entity
                    end
                end
            end
        end
    end

end

RegisterNetEvent('nc-petshop:spawnPet')
AddEventHandler('nc-petshop:spawnPet', function(modelname)

    if DoesEntityExist(pet) then

        DeleteEntity(pet)

    else

        local playerCoords = GetEntityCoords(PlayerPedId())
        local hash = modelname
        local playerPed = PlayerPedId()
        local playerGroup = GetPedGroupIndex(playerPed)
        if not HasModelLoaded(hash) then
            RequestModel(hash)
            Wait(10)
        end
        while not HasModelLoaded(hash) do
            Wait(10)
        end
        pet = CreatePed(28, hash, playerCoords.x + 1, playerCoords.y + 1, playerCoords.z - 1, 1, 1)
        SetModelAsNoLongerNeeded(hash)
        AddRelationshipGroup('PET')
        AddRelationshipGroup('OWNER')
        SetPedRelationshipGroupHash(pet, GetHashKey('PET'))
        SetPedRelationshipGroupHash(playerPed, GetHashKey('OWNER'))
        SetRelationshipBetweenGroups(0, GetHashKey("PET"), GetHashKey('OWNER'))
        petOut()
        petSickness()
        local petModel = GetEntityModel(pet)
        if petModel == GetHashKey('a_c_pug') or petModel == GetHashKey('a_c_poodle') then
            SitDict = "creatures@pug@amb@world_dog_sitting@idle_a"
            SitAnim = "idle_b"
            BarkDict = "creatures@pug@amb@world_dog_barking@idle_a"
            BarkAnim = "idle_a"
            SleepDict = nil
            SleepAnim = nil
        elseif petModel == GetHashKey('a_c_rottweiler') or petModel == GetHashKey('a_c_husky') or petModel ==
            GetHashKey('a_c_retriever') or petModel == GetHashKey('a_c_shepherd') then
            SitDict = "creatures@retriever@amb@world_dog_sitting@idle_a"
            SitAnim = "idle_b"
            BarkDict = "creatures@rottweiler@amb@world_dog_barking@idle_a"
            BarkAnim = "idle_a"
            SleepDict = "creatures@rottweiler@amb@sleep_in_kennel@"
            SleepAnim = "sleep_in_kennel"
        elseif petModel == GetHashKey('a_c_cat_01') then
            SitDict = "creatures@cat@amb@world_cat_sleeping_ground@base"
            SitAnim = "base"
            BarkDict = nil
            BarkAnim = nil
            SleepDict = "creatures@cat@amb@world_cat_sleeping_ground@base"
            SleepAnim = "base"
        elseif petModel == GetHashKey('a_c_rabbit_01') then
            SitDict = nil
            SitAnim = nil
            BarkDict = "creatures@rabbit@amb@world_rabbit_eating@base"
            BarkAnim = "base"
            SleepDict = nil
            SleepAnim = nil
        elseif petModel == GetHashKey('a_c_mtlion') then
            SitDict = "creatures@cougar@amb@world_cougar_rest@base"
            SitAnim = "base"
            BarkDict = nil
            BarkAnim = nil
            SleepDict = nil
            SleepAnim = nil
        elseif petModel == GetHashKey('a_c_hen') then
            SitDict = "creatures@hen@amb@world_hen_standing@idle_a"
            SitAnim = "idle_a"
            BarkDict = "creatures@hen@amb@world_hen_pecking@base"
            BarkAnim = "base"
            SleepDict = nil
            SleepAnim = nil
        elseif petModel == GetHashKey('a_c_westy') then
            SitDict = nil
            SitAnim = nil
            BarkDict = nil
            BarkAnim = nil
            SleepDict = nil
            SleepAnim = nil
        elseif petModel == GetHashKey('a_c_pig') then
            SitDict = nil
            SitAnim = nil
            BarkDict = "creatures@pig@amb@world_pig_grazing@base"
            BarkAnim = "base"
            SleepDict = nil
            SleepAnim = nil

        end
    end

end)

RegisterNetEvent('nc-petshop:removePet')
AddEventHandler('nc-petshop:removePet', function()
    QBCore.Functions.Notify('We have taken your pet from you. Monster.') 
    TriggerServerEvent('nc-petshop:removePet')
end)

RegisterNetEvent('nc-petshop:useTennisBall')
AddEventHandler('nc-petshop:useTennisBall', function()

    local hash = 'prop_tennis_ball'
    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, -1.0))
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end
    ballObj = CreateObjectNoOffset(hash, x, y, z, true, false)
    SetModelAsNoLongerNeeded(hash)
    AttachEntityToEntity(ballObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.15, 0, 0, 0, 270.0, 60.0,
        true, true, false, true, 1, true) -- object is attached to right hand 
    local forwardVector = GetEntityForwardVector(PlayerPedId())
    local force = 50.0
    local animDict = "melee@unarmed@streamed_variations"
    local anim = "plyr_takedown_front_slap"
    ClearPedTasks(PlayerPedId())
    while (not HasAnimDictLoaded(animDict)) do
        RequestAnimDict(animDict)
        Citizen.Wait(5)
    end
    TaskPlayAnim(PlayerPedId(), animDict, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
    Wait(500)
    DetachEntity(ballObj)
    ApplyForceToEntity(ballObj, 1, forwardVector.x * force, forwardVector.y * force + 5.0, forwardVector.z, 0, 0, 0, 0,
        false, true, true, false, true)
    ballID = ObjToNet(ballObj)
    SetNetworkIdExistsOnAllMachines(ballObj, true)
    ballThrown = true
    chasing = true
    TriggerServerEvent('nc-petshop:removeBall')
end)

RegisterNetEvent('nc-petshop:petGetIn')
AddEventHandler('nc-petshop:petGetIn', function()
    vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    TaskWarpPedIntoVehicle(pet, vehicle, -2)

end)

RegisterNetEvent('nc-petshop:petGetOut')
AddEventHandler('nc-petshop:petGetOut', function()
    vehicle = GetVehiclePedIsIn(pet, false)
    TaskLeaveVehicle(pet, vehicle, 16)
end)

RegisterNetEvent('nc-petshop:healPet')
AddEventHandler('nc-petshop:healPet', function()
    local illnessFee = 0

    if DoesEntityExist(pet) then

        SetEntityCoords(pet, -1409.14, -431.09, 35.32)
        stay = true
        FreezeEntityPosition(pet, true)
        if SleepDict == nil then

        else
            LoadAnimDict(SleepDict)
            TaskPlayAnim(pet, SleepDict, SleepAnim, 8.0, -8, -1, 1, 0, false, false, false)
        end
        QBCore.Functions.Notify('Your pet is being treated in the other room.')
        Wait(15000)
        stay = false
        SetEntityCoords(pet, -1404.83, -428.12, 35.45)
        FreezeEntityPosition(pet, false)
        ClearPedTasks(pet)
        if petHealth < 100 or petSpeed ~= 10.0 then
            if illness == 'fatigue' then
                QBCore.Functions.Notify('Your pet was treated for ' .. illness)
                SetEntityHealth(pet, 200)
                illness = 'none'
                illnessFee = 100
                petSpeed = 10.0
            elseif illness == 'kennelcough' then
                QBCore.Functions.Notify('Your pet was healed and treated for ' .. 'Kennel Cough')
                illness = 'none'
                SetEntityHealth(pet, 200)
                illnessFee = 300
                petHealth = 100
            end
            TriggerServerEvent('nc-petshop:chargeABitch', illnessFee)
        end

    else
        QBCore.Functions.Notify('Where is your pet? I cant treat people')
    end
end)

function petSickness()

    Citizen.CreateThread(function()
        while true do

            if DoesEntityExist(pet) then
                if illness == 'none' then
                    local chance = math.random(1, 100)
                    if chance <= Config.IllnessChance then
                        local pick = math.random(1, 2)
                        if pick == 1 then
                            illness = 'fatigue'
                        else
                            illness = 'kennelcough'
                        end
                    end
                end

            else
                break
            end
            Wait(600000)
        end
    end)

end

RegisterNetEvent('nc-petshop:k9ItemCheck')
AddEventHandler('nc-petshop:k9ItemCheck', function(ItemCheck)
    print('nc checking trigger...')
    local found = ItemCheck

    print(found)
    if found then
        QBCore.Functions.Notify(Config.K9Message) 
        LoadAnimDict(BarkDict)
        TaskPlayAnim(pet, BarkDict, BarkAnim, 8.0, -8, -1, 1, 0, false, false, false)
        Wait(5000)
        ClearPedTasks(pet)
    else
    end

end)

-- Main Pet Loop

function petOut()

    Citizen.CreateThread(function()
        while true do

            if DoesEntityExist(pet) then

                -- Search a Person
                if searching then
                    local dst = #(GetEntityCoords(pet) - GetEntityCoords(entity))
                    if dst < 4 then

                        local player, distance = QBCore.Functions.GetClosestPlayer()
                        if distance ~= -1 and distance <= 3.0 then
                            Wait(5000)
                            searching = false
                            TriggerServerEvent('nc-petshop:k9Search', GetPlayerServerId(PlayerId()),
                                GetPlayerServerId(player))

                        end

                    end
                end

                -- K9 is Attacking
                if attacking then
                    if DoesEntityExist(entity) then
                        local entityHealth = GetEntityHealth(entity)
                        if entityHealth <= 140 then
                            attacking = false
                            entity = nil
                            local chance = math.random(1, 100)
                            if chance <= Config.IllnessChance then
                                local pick = math.random(1, 2)
                                if pick == 1 then
                                    illness = 'fatigue'
                                else
                                    illness = 'kennelcough'
                                end
                            end
                            SetPedRelationshipGroupHash(pet, GetHashKey('PET'))
                        end

                    end

                end

                -- Chase ball if it was thrown
                if ballThrown then
                    local speed = GetEntitySpeed(pet)
                    local dst3 = #(GetEntityCoords(pet) - GetEntityCoords(ballObj))
                    if speed <= 0 then
                        TaskGoToEntity(pet, ballObj, -1, 2.0, petSpeed, 1073741824.0, 0)
                        stay = false
                        feeding = false
                        if dst3 < 2 then
                            DeleteEntity(ballObj)
                            ballThrown = false
                            petMoving = false
                            chasing = false
                            returnBall = true
                        end
                    end
                end

                -- If pet has an illness, lower health or other things
                if illness == "fatigue" then
                    petSpeed = 1.0
                elseif illness == "kennelcough" then
                    petHealth = petHealth - .3
                end

                -- If Health less/equal to 0 then kill pet
                if petHealth <= 0 then
                    SetEntityInvincible(pet, false)
                    SetEntityHealth(pet, 0)
                end

                -- If Pet is Alive, Take Food Away
                if petHealth > 0 then
                    if petFood > 0 then
                        petFood = petFood - .5
                        -- print(petFood)
                    else
                        -- If Food is less then 0, Take Health away
                        petHealth = petHealth - .5
                        -- print(petHealth)
                    end
                end

                -- Feeding & Moving to Bowl
                if feeding and not petMoving then
                    petMoving = true
                    stay = false
                    TaskGoToEntity(pet, bowlObj, -1, 2.0, petSpeed, 1073741824.0, 0)
                    local dst2 = #(GetEntityCoords(pet) - GetEntityCoords(bowlObj))
                    if dst2 < 4 then
                        if BarkDict == nil then

                        else
                            LoadAnimDict(BarkDict)
                            TaskPlayAnim(pet, BarkDict, BarkAnim, 8.0, -8, -1, 1, 0, false, false, false)
                        end
                        Wait(5000)
                        DeleteEntity(bowlObj)
                        petFood = 300
                        feeding = false
                        petMoving = false
                        ClearPedTasks(pet)
                    end
                end

                -- Move & Stay
                local dst = #(GetEntityCoords(pet) - GetEntityCoords(PlayerPedId()))
                if dst > 5 and not petMoving and not stay and not feeding and not chasing and not attacking and
                    not searching then
                    petMoving = true
                    TaskGoToEntity(pet, PlayerPedId(), -1, 1.0, petSpeed, 1073741824.0, 0)
                elseif dst < 5 then
                    petMoving = false
                    if returnBall then
                        TriggerServerEvent('nc-petshop:returnBall')
                        returnBall = false
                    end
                end

            else
                break
            end
            Wait(2000)
        end
    end)

end

RegisterNetEvent('nc-petshop:getOwnedPet')
AddEventHandler('nc-petshop:getOwnedPet', function()
    QBCore.Functions.TriggerCallback("nc-petshop:getPetSQL", function(cb)
        petInfo = table.unpack(cb)
        print(petInfo)
        if petInfo ~= nil then
            activePet = petInfo.modelname
            petHealth = petInfo.health
            illness = petInfo.illnesses
            petName = petInfo.name
            if activePet then
                TriggerEvent('nc-petshop:spawnPet', activePet)
            end
        end
    end)
end)

RegisterNetEvent('nc-petshop:feedPet')
AddEventHandler('nc-petshop:feedPet', function()
    QBCore.Functions.TriggerCallback("nc-petshop:feedPetCallback", function(result)
        if result then
            if not DoesEntityExist(bowlObj) then
                bendAnimation()
                local hash = 'prop_bowl_crisps'
                local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, -1.0))
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Citizen.Wait(0)
                end
                bowlObj = CreateObjectNoOffset(hash, x, y, z, true, false)
                PlaceObjectOnGroundProperly(bowlObj)
                SetModelAsNoLongerNeeded(hash)
                feeding = true
            end
        else
            QBCore.Functions.Notify("You don't have pet foods. Buy more from Petshop", "error")
        end
    end)

    
end)

RegisterNetEvent('nc-petshop:stay')
RegisterNetEvent('nc-petshop:follow')

AddEventHandler('nc-petshop:follow', function()
    stay = false
    attacking = false
    entity = nil
    ClearPedTasks(pet)
end)

AddEventHandler('nc-petshop:stay', function()
    stay = true
    attacking = false
    entity = nil
    ClearPedTasks(pet)
    LoadAnimDict(SitDict)
    TaskPlayAnim(pet, SitDict, SitAnim, 8.0, -8, -1, 1, 0, false, false, false)

end)

RegisterNetEvent('nc-petshop:petStore')
AddEventHandler('nc-petshop:petStore', function()
    local petMenu = {{
        isMenuHeader = true,
        header = "Pet Shop"
    }, {
        header = "Pet Food",
        txt = "Buy Pet Food" .. " for $" .. Config.FoodPrice,
        params = {
            event = 'nc-petshop:buyFood'
        }
    },
    {
        header = "Tennis Ball",
        txt = "Buy Pet Food" .. " for $" .. Config.TennisBallPrice,
        params = {
            event = 'nc-petshop:buyTennisBall'
        }
    }, {
        header = "Purchase #1",
        txt = Config.Pet1Label .. " for $" .. Config.Pet1Price,
        params = {
            event = 'nc-petshop:buyPet1'
        }
    }, {
        header = "Purchase #2",
        txt = Config.Pet2Label .. " for $" .. Config.Pet2Price,
        params = {
            event = 'nc-petshop:buyPet2'
        }
    }, {
        header = "Purchase #3",
        txt = Config.Pet3Label .. " for $" .. Config.Pet3Price,
        params = {
            event = 'nc-petshop:buyPet3'
        }
    }, {
        header = "Purchase #4",
        txt = Config.Pet4Label .. " for $" .. Config.Pet4Price,
        params = {
            event = 'nc-petshop:buyPet4'
        }
    }, {
        header = "Purchase #5",
        txt = Config.Pet5Label .. " for $" .. Config.Pet5Price,
        params = {
            event = 'nc-petshop:buyPet5'
        }
    }, {
        header = "Purchase #6",
        txt = Config.Pet6Label .. " for $" .. Config.Pet6Price,
        params = {
            event = 'nc-petshop:buyPet6'
        }
    }, {
        header = "Purchase #7",
        txt = Config.Pet7Label .. " for $" .. Config.Pet7Price,
        params = {
            event = 'nc-petshop:buyPet7'
        }
    }, {
        header = "Purchase #8",
        txt = Config.Pet8Label .. " for $" .. Config.Pet8Price,
        params = {
            event = 'nc-petshop:buyPet8'
        }
    }, {
        header = "Purchase #9",
        txt = Config.Pet9Label .. " for $" .. Config.Pet9Price,
        params = {
            event = 'nc-petshop:buyPet9'
        }
    }, {
        header = "Purchase #10",
        txt = Config.Pet10Label .. " for $" .. Config.Pet10Price,
        params = {
            event = 'nc-petshop:buyPet10'
        }
    }, {
        header = "Purchase #11",
        txt = Config.Pet11Label .. " for $" .. Config.Pet11Price,
        params = {
            event = 'nc-petshop:buyPet11'
        }
    }}

    exports['qb-menu']:openMenu(petMenu)

end)

RegisterNetEvent('nc-petshop:buyFood')
AddEventHandler('nc-petshop:buyFood', function()
    TriggerServerEvent('nc-petshop:buyFood', Config.FoodPrice)
end)
RegisterNetEvent('nc-petshop:buyTennisBall')
AddEventHandler('nc-petshop:buyTennisBall', function()
    TriggerServerEvent('nc-petshop:buyTennisBall', Config.TennisBallPrice)
end)
RegisterNetEvent('nc-petshop:buyPet1')
AddEventHandler('nc-petshop:buyPet1', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet1, Config.Pet1Price)
end)
RegisterNetEvent('nc-petshop:buyPet2')
AddEventHandler('nc-petshop:buyPet2', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet2, Config.Pet2Price)
end)
RegisterNetEvent('nc-petshop:buyPet3')
AddEventHandler('nc-petshop:buyPet3', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet3, Config.Pet3Price)
end)
RegisterNetEvent('nc-petshop:buyPet4')
AddEventHandler('nc-petshop:buyPet4', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet4, Config.Pet4Price)
end)
RegisterNetEvent('nc-petshop:buyPet5')
AddEventHandler('nc-petshop:buyPet5', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet5, Config.Pet5Price)
end)

RegisterNetEvent('nc-petshop:buyPet6')
AddEventHandler('nc-petshop:buyPet6', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet6, Config.Pet6Price)
end)

RegisterNetEvent('nc-petshop:buyPet7')
AddEventHandler('nc-petshop:buyPet7', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet7, Config.Pet7Price)
end)
RegisterNetEvent('nc-petshop:buyPet8')
AddEventHandler('nc-petshop:buyPet8', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet8, Config.Pet8Price)
end)

RegisterNetEvent('nc-petshop:buyPet9')
AddEventHandler('nc-petshop:buyPet9', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet9, Config.Pet9Price)
end)

RegisterNetEvent('nc-petshop:buyPet10')
AddEventHandler('nc-petshop:buyPet10', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet10, Config.Pet10Price)
end)

RegisterNetEvent('nc-petshop:buyPet11')
AddEventHandler('nc-petshop:buyPet11', function()
    TriggerServerEvent('nc-petshop:buyPet', Config.Pet11, Config.Pet11Price)
end)

RegisterNetEvent('nc-petshop:namePet')
AddEventHandler('nc-petshop:namePet', function()
    local keyboard = exports['qb-input']:ShowInput({
        header = "Name Your Pet",
        submitText = "Rename",
        inputs = {{
            text = "Name", 
            name = "petname",
            type = "text",
            isRequired = true 
        }}
    })

    if keyboard ~= nil then
        TriggerServerEvent('nc-petshop:updatePetName', keyboard.petname)
        petName = keyboard.petname
    end
end)

function PetMenu()

    TriggerEvent('nc-petshop:petMenu')

end

RegisterNetEvent('nc-petshop:petMenu')
AddEventHandler('nc-petshop:petMenu', function()

    local petCommands = {{
        isMenuHeader = true,
        header = "Pet Menu"
    }, {
        header = "Call Pet",
        txt = "Call your pet",
        params = {
            event = 'nc-petshop:getOwnedPet'
        }
    }, {
        header = "Dismiss Pet",
        txt = "Send your pet home",
        params = {
            event = "nc-petshop:dismissPet"
        }
    }, {
        header = "Commands",
        txt = "Pet Commands",
        params = {
            event = 'nc-petshop:petCommands'
        }
    }, {
        header = "Status",
        txt = petName .. "'s Status",
        params = {
            event = 'nc-petshop:petStatus'
        }
    }}

    exports['qb-menu']:openMenu(petCommands)

end)

RegisterNetEvent('nc-petshop:petStatus')
AddEventHandler('nc-petshop:petStatus', function()

    local petStatus = {{
        header = petName .. "'s Status",
        txt = "Go Back",
        params = {
            event = 'nc-petshop:petMenu'
        }
    }, {
        header = "Health",
        txt = petHealth
    }, {
        header = "Food",
        txt = petFood
    }, {
        header = "Illnesses",
        txt = illness
    }, {
        header = petName,
        txt = 'Rename Your Pet',
        params = {
            event = 'nc-petshop:namePet'
        }
    }}

    exports['qb-menu']:openMenu(petStatus)

end)

RegisterNetEvent('nc-petshop:petCommands')
AddEventHandler('nc-petshop:petCommands', function()

    local petCommands = {{
        header = "Pet Menu",
        txt = "Back",
        params = {
            event = 'nc-petshop:petMenu'
        }
    }, {
        header = "Follow",
        txt = "Follow me",
        params = {
            event = 'nc-petshop:follow'
        }
    }, {
        header = "Stay",
        txt = "Stay over there",
        params = {
            event = "nc-petshop:stay"
        }
    }, {
        header = "Feed",
        txt = "Give foods to your pet",
        params = {
            event = "nc-petshop:feedPet"
        }
    }, {
        header = "Get In Vehicle",
        txt = "Get in the car pal",
        params = {
            event = "nc-petshop:petGetIn"
        }
    }, {
        header = "Get Out Vehicle",
        txt = "Get Out the car pal",
        params = {
            event = "nc-petshop:petGetOut"
        }
    }}

    exports['qb-menu']:openMenu(petCommands)

end)

RegisterNetEvent('nc-petshop:dismissPet')
AddEventHandler('nc-petshop:dismissPet', function()

    if DoesEntityExist(pet) then
        TaskWanderStandard(pet, 10.0, 10)
        SetPedAsNoLongerNeeded(pet)
        Wait(5000)
        DeleteEntity(pet)
        feeding = false
        stay = false
        TriggerServerEvent('nc-petshop:updatePet', petHealth, illness)
    end

end)

function bendAnimation()
    LoadAnimDict('amb@medic@standing@kneel@base')
    LoadAnimDict('anim@gangops@facility@servers@bodysearch@')
    TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, -1, 48, 0,
        false, false, false)
    Citizen.Wait(5000)
    ClearPedTasksImmediately(PlayerPedId())
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

addBlip = function(coords, sprite, size, colour, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, size)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end