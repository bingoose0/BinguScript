util.keep_running()
util.require_natives(1651208000)

-- Config
local dropVehicHash = 444583674  --- The vehicle hash for dropveh
local pedAttaccHash = 0x5B44892C --- The ped that will attack with "attacc"
local weaponAttaccHash = -1357824103 --- The weapon the ped will use when attaccing
local rainVehicleHash = -2007026063
local rainVehicleRadius = 60

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

menu.text_input(root, "Rain Vehicle", {"rainvehicle", "rvhc"}, "the rain vehicle", function(value)
    rainVehicleHash = util.joaat(value)
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
