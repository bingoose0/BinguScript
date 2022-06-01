util.keep_running()
util.require_natives(1640181023)

-- Config
local dropVehicHash = 444583674  --- The vehicle hash for dropveh
local pedAttaccHash = 0x5B44892C --- The ped that will attack with "attacc"
local weaponAttaccHash = -1357824103 --- The weapon the ped will use when attaccing
local rainVehicleHash = -2007026063
local rainVehicleRadius = 60

local burgerAttack = 0x8CDCC057
local burgerAttackVan = util.joaat("stalion2")
local burgerAttackWeapon = -1063057011

local cargobobWeapon = -1063057011
local cargobobPed = 0x81441B71

local busPed = 0x94C2A03F
local busWeapon = -1063057011

-- Config end

local updatePeds = true
local pedsScream = false
local rainingVehicles = false
local rainedVehicles = {}
local root = menu.my_root()

local function loadModel(hash)
    local attempts = 0

    while not STREAMING.HAS_MODEL_LOADED(hash) and attempts < 100 do
        attempts = attempts + 1
        STREAMING.REQUEST_MODEL(hash)
        util.yield(10)
    end

    if not STREAMING.HAS_MODEL_LOADED(hash) then
        util.toast("Error loading model w/ hash " .. tostring(hash) .. " !")
    end
end

local function getRandomSpawnPos(eid, radius)
    return ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(eid, math.random(-radius, radius), -radius, 0.0)
end

local getPlayerPed = PLAYER.GET_PLAYER_PED

local function getPlayerCoords(pid)
    return ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(pid))
end

local function playerFunctions(pid)
    local pRoot = menu.player_root(pid)
    menu.action(pRoot, "Drop vehicle", {"dropvehicle", "dropveh"}, "drops a vehicle on them", function ()
        loadModel(dropVehicHash)
        local coords = getPlayerCoords(pid)
        coords['z'] = coords['z'] + 30
        local veh = entities.create_vehicle(dropVehicHash, coords, 0)
        util.yield(10000)
        entities.delete_by_handle(veh)
    end)

    menu.action(pRoot, "Attacc!", {"attack", "attacc", "pedattack"}, "makes a random ped and attaccs the player!", function ()
        loadModel(pedAttaccHash)
        local pPed = getPlayerPed(pid)
        for _ = 1, 5 do
            local coords = getRandomSpawnPos(pPed, 30)
            local ped = entities.create_ped(26, pedAttaccHash, coords, 0)
            WEAPON.GIVE_WEAPON_TO_PED(ped, weaponAttaccHash, 300)
            TASK.TASK_COMBAT_PED(ped, pPed)
        end

        util.toast("Charge! >:)")
    end)
    
    menu.action(pRoot, "Burger Attack", {"battack", "burgattack", "batt"}, "makes some burger ppl attack a player", function ()
        loadModel(burgerAttackVan)
        loadModel(burgerAttack)
        local playerPed = PLAYER.GET_PLAYER_PED(pid)
        local vehicleCoords = getRandomSpawnPos(playerPed, 20)
        local vehicle = entities.create_vehicle(burgerAttackVan, vehicleCoords, 0)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 100)
        ENTITY.SET_ENTITY_PROOFS(vehicle, true, true, false, true, true)

        for i = -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do -- -1 because for some stupid reason -1 is the driver seat, and subtract 1 because of -1 lol
            local ped = entities.create_ped(1, burgerAttack, vehicleCoords, 0)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, i)
            PED.SET_PED_AS_COP(ped, true)
            WEAPON.GIVE_WEAPON_TO_PED(ped, burgerAttackWeapon, 500)
            if i ~= -1 then
                TASK.TASK_COMBAT_PED(ped, playerPed)
            else
                TASK.TASK_VEHICLE_CHASE(ped, playerPed)
            end
        end
    end)

    menu.action(pRoot, "Cargobob Attack", {"cargobobattack", "cattack", "catt"}, "makes people in a cargobob attack a player", function ()
        local cargobobHash = util.joaat("cargobob")
        loadModel(cargobobHash)
        loadModel(cargobobPed)
        local playerPed = PLAYER.GET_PLAYER_PED(pid)
        local vehicleCoords = getRandomSpawnPos(playerPed, 20)
        local vehicle = entities.create_vehicle(cargobobHash, vehicleCoords, 0)
        ENTITY.SET_ENTITY_PROOFS(vehicle, true, true, false, true, true)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 500)
        for i = -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do -- -1 because for some stupid reason -1 is the driver seat, and subtract 1 because of -1 lol
            local ped = entities.create_ped(1, cargobobPed, vehicleCoords, 0)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, i)
            PED.SET_PED_AS_COP(ped, true)
            WEAPON.GIVE_WEAPON_TO_PED(ped, cargobobWeapon, 500)
            if i ~= -1 then
                TASK.TASK_COMBAT_PED(ped, playerPed)
            else
                TASK.TASK_VEHICLE_CHASE(ped, playerPed)
            end
        end
    end)


    menu.action(pRoot, "Bus Attack", {"busattack", "buattack", "buatt"}, "makes people in a bus attack a player", function ()
        local busHash = util.joaat("bus")
        loadModel(busHash)
        loadModel(busPed)
        local playerPed = PLAYER.GET_PLAYER_PED(pid)
        local vehicleCoords = getRandomSpawnPos(playerPed, 20)
        local vehicle = entities.create_vehicle(busHash, vehicleCoords, 0)
        ENTITY.SET_ENTITY_PROOFS(vehicle, true, true, false, true, true)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 100)
        for i = -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do -- -1 because for some stupid reason -1 is the driver seat, and subtract 1 because of -1 lol
            local ped = entities.create_ped(1, busPed, vehicleCoords, 0)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, i)
            PED.SET_PED_AS_COP(ped, true)
            WEAPON.GIVE_WEAPON_TO_PED(ped, busWeapon, 500)
            if i ~= -1 then
                TASK.TASK_COMBAT_PED(ped, playerPed)
            else
                TASK.TASK_VEHICLE_CHASE(ped, playerPed)
            end
        end
    end)
end

players.on_join(function (pid)
    playerFunctions(pid)
end)

for _, pid in pairs(players.list()) do
    playerFunctions(pid)
end

menu.toggle(root, "Scream", {"scream", "npcscream", "pedscream"}, "aaaaHHHHH (makes peds scream)", function (toggle)
    pedsScream = toggle
    updatePeds = true
end)

menu.toggle(root, "Rain Vehicles", {"rainvehicles", "rain", "rveh"}, "rains vehicles", function (toggle)
    rainingVehicles = toggle
end)

menu.toggle(root, "Riot", {"riot", "npcfight"}, "Makes all nearby NPCs duel", function(toggle)
    MISC.SET_RIOT_MODE_ENABLED(toggle) -- how tf is this actually a thing lmao, thanks NativeDB
end)

menu.text_input(root, "Vehicle for Rain Vehicle", {"rainvehicle", "rvhc"}, "the rain vehicle", function(value)
    rainVehicleHash = util.joaat(value)
end, "handler")

menu.text_input(root, "Vehicle for Drop Vehicle", {"dropvehicleset"}, "the vehicle to use for dropveh", function (value)
    dropVehicHash = util.joaat(value)
    
end, "handler")

util.create_thread(function() -- Ped stuffz
    local peds = nil
    while true do
        if updatePeds then
            updatePeds = false
            peds = entities.get_all_peds_as_handles()
        end
        for _, ped in pairs(peds) do
            if pedsScream then
                AUDIO.PLAY_PAIN(ped, 8) -- 8 is on fire scream
            end
        end
        util.yield()
    end
end)

util.create_thread(function () -- Rain start
    while true do
        if rainingVehicles then
            local userPed = getPlayerPed(players.user())
            local coords = getRandomSpawnPos(userPed, rainVehicleRadius)
            coords['z'] = coords['z'] + 90
            local vehicle = entities.create_vehicle(rainVehicleHash, coords, 0)
            rainedVehicles[#rainedVehicles+1] = vehicle
        end

        util.yield(600)
    end
end)

util.create_thread(function () -- Rain clearing stuff
    while true do
        for i, vehic in pairs(rainedVehicles) do
            entities.delete_by_handle(vehic)
            table.remove(rainedVehicles, i)
        end
        util.yield(20000)
    end
end)
