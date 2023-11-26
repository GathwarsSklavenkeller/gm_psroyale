include("sh_enums.lua")
include("sh_deathmessages.lua")
include("sh_net.lua")

GM.Name = "PietSmiet Royale"
GM.Author = "DasDarki & Pythagorion"
GM.Email = "N/A"
GM.Website = "N/A"

team.SetUp(TeamID.SPECTATOR, "Zuschauer", Color(150, 150, 150))
team.SetUp(TeamID.PLAYER, "Spieler", Color(0, 0, 255))

SetGlobalInt("PSR_GameState", RoundState.NOT_STARTED)

WEAPON_MAPPING = {
    ["cw_ar15"] = "LONG_WEAPONS",
    ["cw_ak74"] = "LONG_WEAPONS",
    ["cw_g3a3"] = "LONG_WEAPONS",
    ["cw_l115"] = "LONG_WEAPONS",
    ["cw_mr96"] = "SHORT_WEAPONS",
    ["cw_deagle"] = "SHORT_WEAPONS",
    ["cw_mp5"] = "SHORT_WEAPONS",
    ["cw_frag_grenade"] = "GRENADES"
}

function GM:Initialize()

end