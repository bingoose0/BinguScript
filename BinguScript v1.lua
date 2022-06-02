util.keep_running()
util.require_natives(1651208000)

local name = "BinguScript"

local root = menu.root()
local joaat = menu.joaat
local wait = menu.yield

LANG = {
    ["en-us"] = {
        ["started_up"] = "Hello from " .. name .. "!"
    }
}

local langEnglish = LANG['en-us']

util.toast(langEnglish['started_up'])

local pedAttacks = menu.list(root, "Ped Attacks", {"pedattacks", "pattacks"}, "Attacks from a ped")
