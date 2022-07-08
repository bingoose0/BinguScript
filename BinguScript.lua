util.keep_running()
util.require_natives(1651208000)

local joaat = util.joaat
local busHash = joaat("bus")

local function requestModel(hash)
    local attempts = 0
    while attempts < 50 and not STREAMING.HAS_MODEL_LOADED(hash) do
        STREAMING.REQUEST_MODEL(hash)
        attempts += 1
        util.yield()
    end

    if attempts == 50 and not STREAMING.HAS_MODEL_LOADED(hash) then
        util.toast("Couldn't load model " .. util.reverse_joaat(hash))
        return false
    end

    return true
end

local function getPlayerPos(pid)
    local ped = PLAYER.GET_PLAYER_PED(pid)
    return ENTITY.GET_ENTITY_COORDS(ped)
end

local function handlePlayer(playerId)
    local root = menu.player_root(playerId)
    local name = players.get_name(playerId)
    menu.divider(root, "BinguScript")

    menu.action(root, "Drop Bus", {"dropveh", "dropbus"}, "drops a bus on " .. name, function ()
        if not requestModel(busHash) then return end

        local pos = getPlayerPos(playerId)
        pos.z += 20

        local veh = entities.create_vehicle(busHash, pos, 0)
        local pointer = entities.handle_to_pointer(veh)

        entities.set_gravity(pointer, 50)
        util.yield(5000)
        entities.delete_by_pointer(pointer)
    end)

    menu.action(root, "Bus Attacc", {"buatt", "busattacc", "busattack"}, "Attacks " .. name .. " with a bus full of peds", function()
        if not requestModel(busHash) then return end

        local pPed = PLAYER.GET_PLAYER_PED(playerId)
        local busPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pPed, math.random(-20, 20), math.random(-20, 20), 0)

        local veh = entities.create_vehicle(busHash, busPos, 0)

        for i = -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(veh) - 1 do
            local ped = PED.CREATE_RANDOM_PED(busPos.x, busPos.y, busPos.z)

            PED.SET_PED_AS_COP(ped, true)
            WEAPON.GIVE_WEAPON_TO_PED(ped, -1121678507)

            TASK.TASK_WARP_PED_INTO_VEHICLE(ped, vehicle, i)

            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(ped, pPed)
            else
                TASK.TASK_COMBAT_PED(ped, pPed)
            end
        end

    end)
end

players.on_join(handlePlayer)
players.dispatch_on_join()
