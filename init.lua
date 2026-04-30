dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")

local root_path = "mods/cxredix_pixelart_expansion/"

if ModIsEnabled("GlimmersExpanded") then
    ModLuaFileAppend("mods/GlimmersExpanded/files/lib/glimmer_data.lua", root_path .. "pixelart_glimmers.lua")
end

local original_firebomb = "data/projectiles_gfx/grenade_scavenger_small.xml"
local new_firebomb = root_path .. "vendor/white_tinted_firebomb.xml"

-- replace image for firebomb
if ModSettingGet("cxredix_pixelart_expansion.white_tint_firebomb") then
    local firebomb_xml = ModTextFileGetContent("data/entities/projectiles/deck/firebomb.xml")

    local new_content = firebomb_xml:gsub(
        original_firebomb, new_firebomb
    )

    ModTextFileSetContent("data/entities/projectiles/deck/firebomb.xml", new_content)

    GamePrint("[Pixel art expansion] Loaded white tinted firebomb")
end

if ModSettingGet("cxredix_pixelart_expansion.firebomb_remove_particles") then
    local firebomb_xml = ModTextFileGetContent("data/entities/projectiles/deck/firebomb.xml")

    local new_content = firebomb_xml:gsub("\n", "")

    -- remove the particle emitter component, for test
    new_content = new_content:gsub(
        "<ParticleEmitterComponent.-</ParticleEmitterComponent>", ""
    )

    ModTextFileSetContent("data/entities/projectiles/deck/firebomb.xml", new_content)

    GamePrint("[Pixel art expansion] removed firebomb's fire particles")
end
