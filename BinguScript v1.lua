util.keep_running()
util.require_natives(1651208000)

local name = "BinguScript"

local root = menu.my_root()
local joaat = util.joaat
local wait = util.yield

LANG = {
    ["en-us"] = {
        ["started_up"] = "Hello from " .. name .. "!";
    }
}

local langEnglish = LANG['en-us']

util.toast(langEnglish['started_up'])

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
--            Utility functions            -- 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

local function getRandomPositionAroundEntity(entityId, radius) -- Gets a random position around the entity, can be used for attacks n stuff
    local offsetX = math.random(-radius, radius)
    local offsetY = math.random(-radius, radius)

    return ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entityId, offsetX, offsetY, 0)
end

local function loadModel(hash)
    for attempts = 1, 100 do
        if STREAMING.HAS_MODEL_LOADED(hash) then
            break
        end
        STREAMING.REQUEST_MODEL(hash)
    end

    if not STREAMING.HAS_MODEL_LOADED(hash) and attempts == 100 then
        util.toast("Couldn't load model " .. hash .. ", please try again or report this.")
    end
end
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
--          Player-related stuff           -- 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

local function playerActions(pid)
    local playerRoot = menu.player_root(pid)
    menu.divider(playerRoot, name)

    local pedAttacks = menu.list(playerRoot, "Ped Attacks", {"pedattacks", "pattacks"}, "Attacks from a ped")

    menu.action(pedAttacks, "Burger Shot Shooting", {"burgershotattack", "bsattack", "bsat"}, "Attacks a player with ppl in burger shot", function ()
        local burgerStallion = joaat("stalion2")
        local burgerEmployee = joaat("csb_burgerdrug")
        local weapon = 1649403952

        loadModel(burgerEmployee)
        loadModel(burgerStallion)

        local playerPed = PLAYER.GET_PLAYER_PED(pid)

        local vehicleCoords = getRandomPositionAroundEntity(playerPed, 20)
        local vehicle = entities.create_vehicle(burgerStallion, vehicleCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)

        local driver = entities.create_ped(1, burgerEmployee, vehicleCoords, 0)
        local passenger = entities.create_ped(1, burgerEmployee, vehicleCoords, 0)

        PED.SET_PED_AS_COP(driver, true)
        PED.SET_PED_AS_COP(passenger, true)
        
        WEAPON.GIVE_WEAPON_TO_PED(driver, weapon, 300)
        WEAPON.GIVE_WEAPON_TO_PED(passenger, weapon, 300)

        PED.SET_PED_ACCURACY(driver, 100)
        PED.SET_PED_ACCURACY(passenger, 100)
        
        TASK.TASK_WARP_PED_INTO_VEHICLE(driver, vehicle, -1)
        TASK.TASK_WARP_PED_INTO_VEHICLE(passenger, vehicle, 0)

        TASK.TASK_VEHICLE_CHASE(driver, playerPed)
        TASK.TASK_COMBAT_PED(passenger, playerPed)
    end)

    menu.action(pedAttacks, "Bus Attack", {"busattack", "buatt"}, "Attacks people with a bus", function ()
        local busHash = joaat("bus")
        local playerPed = PLAYER.GET_PLAYER_PED(pid)
        local weapon = 1649403952
        loadModel(busHash)
        
        local vehicleCoords = getRandomPositionAroundEntity(playerPed, 30)
        local vehicle = entities.create_vehicle(busHash, vehicleCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)

        for i = -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do
            local ped = PED.CREATE_RANDOM_PED(vehicleCoords['x'], vehicleCoords['y'], vehicleCoords['z'])
            
            PED.SET_PED_AS_COP(ped, true) 
            WEAPON.GIVE_WEAPON_TO_PED(ped, weapon, 500)
            PED.SET_PED_ACCURACY(ped, 100)

            TASK.TASK_WARP_PED_INTO_VEHICLE(ped, vehicle, i)
            
            if i == -1 then
                TASK.TASK_VEHICLE_CHASE(ped, playerPed)
            else
                TASK.TASK_COMBAT_PED(ped, playerPed)
            end
        end

    end)
end

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
--           Registering stuff             -- 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

for i, player in pairs(players.list()) do
    playerActions(player)
end

players.on_join(function (pid)
    playerActions(pid)
end)