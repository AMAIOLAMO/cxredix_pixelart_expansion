dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")


local root_path = "mods/cxredix_pixelart_expansion/"

local cx_deck_sync = dofile_once(root_path .. "cx_deck_sync.lua")
dofile_once(root_path .. "cx_action_parse_utils.lua")

-- @module wand_utils
dofile_once(root_path .. "wand_utils.lua")

if ModIsEnabled("GlimmersExpanded") then
    ModLuaFileAppend("mods/GlimmersExpanded/files/lib/glimmer_data.lua", root_path .. "pixelart_glimmers.lua")
end

local original_firebomb = "data/projectiles_gfx/grenade_scavenger_small.xml"
local new_firebomb = root_path .. "vendor/white_tinted_firebomb.xml"

-- replace image for firebomb
if ModSettingGet("cxredix_pixelart_expansion.white_tint_firebomb") then
    local firebomb_xml = ModTextFileGetContent("data/entities/projectiles/deck/firebomb.xml")

    new_content = firebomb_xml:gsub(
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


ModLuaFileAppend("data/scripts/gun/gun.lua", root_path .. "gun_deck_handler.lua")

-- clear any previous un-synced actions
cx_deck_sync.consume_sync()
cx_deck_sync.clear_sync_complete_flag()

local player

function get_player()
    if player == nil then
        player = EntityGetWithTag("player_unit")[1]
    end

    if player == nil then
        return nil
    end

    return player
end

-- use imgui when the function exists
local should_clear_next_frame = false

if load_imgui ~= nil then
    local imgui = load_imgui({version="1.21.0", mod="CxRedixPixelartExpansion"})

    local prev_wand_start_load_time_sec = -1
    local prev_time_load_sec = -1

    local actions_raw_str = ""
    local prev_action_count = -1

    function OnWorldPostUpdate()
        imgui.SetNextWindowSize(800, 400, imgui.Cond.Once)

        if cx_deck_sync.is_sync_complete_flag_marked() then
            prev_time_load_sec = GameGetRealWorldTimeSinceStarted() - prev_wand_start_load_time_sec
            
            cx_deck_sync.clear_sync_complete_flag()
        end

        if should_clear_next_frame == true then
            wand_clear_all_actions(get_held_wand_id(get_player()))

            prev_time_load_sec = GameGetRealWorldTimeSinceStarted() - prev_wand_start_load_time_sec

            GamePrint("Cleared wand")
            GamePrint("[Pixelart wand loader] Wand Load complete, it took: " .. tostring(prev_time_load_sec))

            should_clear_next_frame = false
        end

        if ModSettingGet("cxredix_pixelart_expansion.enable_wand_loader") and imgui.Begin("Wand Loader") then
            imgui.Text("Put your wand string below <3")

            _, actions_raw_str = imgui.InputTextMultiline(
                "##Input", actions_raw_str,
                -5 * 3, 5 * 50, -- hardcoded size and line height
                imgui.InputTextFlags.EnterReturnsTrue
            )

            if actions_raw_str ~= '' and imgui.Button("Direct sync to wand") then
                GamePrint("Trying to sync")

                prev_wand_start_load_time_sec = GameGetRealWorldTimeSinceStarted()
                cx_deck_sync.set_sync_actions(actions_raw_str)

                -- TODO: instead of deserializing it, we simply let the wand parse utils to be able to parse
                -- count. counting the number of , then returning the amount of spells :) + 1 (there is an issue)
                -- where it might assume ",," as 1 spell, but that's trivial for now
                local action_ids = cx_deserialize_to_action_ids(actions_raw_str)

                prev_action_count = #action_ids

                GamePrint("Sync Notified, forcing wand refresh...")

                all_wand_force_refresh(get_player())

                GamePrint("Wand refresh complete :)")
            end

            -- TODO: rewrite this so that it's much easier to read and modify
            if actions_raw_str ~= '' and imgui.Button("Load on held wand and clear(OBSOLETE)") then
                local held_wand = get_held_wand_id(get_player())

                if held_wand ~= nil then
                    GamePrint("[Pixelart wand loader] Loading held wand")
                    prev_wand_start_load_time_sec = GameGetRealWorldTimeSinceStarted()

                    wand_clear_all_actions(held_wand)
                    prev_action_count = wand_load_action_str(held_wand, actions_raw_str)

                    all_wand_force_refresh(player)

                    should_clear_next_frame = true
                end
            end

            imgui.SameLine()
            if actions_raw_str ~= '' and imgui.Button("Load on held wand") then
                local held_wand = get_held_wand_id(get_player())

                if held_wand ~= nil then
                    GamePrint("[Pixelart wand loader] Loading held wand")
                    prev_wand_start_load_time_sec = GameGetRealWorldTimeSinceStarted()
                    
                    wand_clear_all_actions(held_wand)
                    prev_action_count = wand_load_action_str(held_wand, actions_raw_str)

                    all_wand_force_refresh(player)

                    prev_time_load_sec = GameGetRealWorldTimeSinceStarted() - prev_wand_start_load_time_sec

                    GamePrint("[Pixelart wand loader] Wand Load complete, it took: " .. tostring(prev_time_load_sec))
                end
            end

            imgui.SameLine()
            if actions_raw_str ~= '' and imgui.Button("Clear Input Text") then
                actions_raw_str = ''
            end

            if prev_time_load_sec > 0 then
                imgui.Text(string.format("Loaded previous wand in: %.4f seconds", prev_time_load_sec))
            end

            if prev_action_count > 0 then
                imgui.Text(string.format("Previous wand had: %d spells actions", prev_action_count))
            end

            imgui.End()
        end
    end
end

