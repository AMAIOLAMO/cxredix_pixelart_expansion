dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")

local root_path = "mods/cxredix_pixelart_expansion/"

local cx_deck_sync = dofile_once(root_path .. "cx_deck_sync.lua")
dofile_once(root_path .. "cx_action_parse_utils.lua")

-- @module profile_timer
local ProfileTimer = dofile_once(root_path .. "profile_timer.lua")

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

function lerpf(a, b, t)
    return a + (b - a) * t
end

-- use imgui when the function exists
if load_imgui ~= nil then
    function wand_loader_log_info(msg)
        GamePrint("[Pixelart wandloader]" .. msg)
    end

    local imgui = load_imgui({version="1.21.0", mod="CxRedixPixelartExpansion"})

    function imgui_cautious_btn(id)
        imgui.PushStyleColor(imgui.Col.Button, 0.8, 0.45, 0.45)
        imgui.PushStyleColor(imgui.Col.ButtonHovered, 1, 0.6, 0.6)
        imgui.PushStyleColor(imgui.Col.ButtonActive, 0.7, 0.45, 0.45)

        local ret_value = imgui.Button(id)

        imgui.PopStyleColor(3)

        return ret_value
    end


    local actions_input_str = ""
    local prev_action_count = -1

    local load_wand_timer = ProfileTimer.new()

    function OnWorldPostUpdate()
        imgui.SetNextWindowSize(800, 400, imgui.Cond.Once)

        if cx_deck_sync.is_sync_complete_flag_marked() then
            cx_deck_sync.clear_sync_complete_flag()

            load_wand_timer:end_append()
        end

        if ModSettingGet("cxredix_pixelart_expansion.enable_wand_loader") and imgui.Begin("Wand Loader") then
            local animated_str = ""

            local animated_char_count = 45

            local sin_value = animated_char_count * (math.sin(GameGetRealWorldTimeSinceStarted() * 1.3) * 0.5 + 0.5)

            -- rounding and shift by 1
            sin_value = math.floor(sin_value + 0.5) + 1

            for i = 1, animated_char_count do
                if i == sin_value then
                    animated_str = animated_str .. "^"
                end

                animated_str = animated_str .. "."
            end


            imgui.Text("Put your wand string below " .. animated_str)

            _, actions_input_str = imgui.InputTextMultiline(
                "##Input", actions_input_str,
                -5 * 3, 5 * 50, -- hardcoded size and line height
                imgui.InputTextFlags.EnterReturnsTrue
            )

            if actions_input_str ~= '' and imgui.Button("Direct sync to wand") then
                wand_loader_log_info("Trying to sync")
                
                load_wand_timer:clear()
                load_wand_timer:begin_append()

                -- we need to add 1 dummy spell if the wand is empty,
                -- this is due to the fact that if the wand has 0 card actions
                -- as entities in the game, refreshing the wand will not happen.
                
                local held_wand_id = get_held_wand_id(get_player())

                wand_clear_all_actions(held_wand_id)
                wand_append_action_str(held_wand_id, "MANA_REDUCE")


                cx_deck_sync.set_sync_actions(actions_input_str)

                -- TODO: instead of deserializing it, we simply let the wand parse utils to be able to parse
                -- count. counting the number of , then returning the amount of spells :) + 1 (there is an issue)
                -- where it might assume ",," as 1 spell, but that's trivial for now
                local action_ids = cx_deserialize_to_action_ids(actions_input_str)

                prev_action_count = #action_ids

                wand_loader_log_info("Sync Notified, forcing wand refresh...")

                all_wand_force_refresh(get_player())

                wand_loader_log_info("Wand refresh complete :)")
            end

            imgui.SameLine()
            if actions_input_str ~= '' and imgui.Button("Load on held wand") then
                local held_wand = get_held_wand_id(get_player())

                if held_wand ~= nil then
                    wand_loader_log_info("Loading held wand")

                    load_wand_timer:clear()
                    load_wand_timer:begin_append()

                    wand_clear_all_actions(held_wand)

                    prev_action_count = wand_append_action_str(held_wand, actions_input_str)

                    all_wand_force_refresh(get_player())

                    load_wand_timer:end_append()

                    wand_loader_log_info(
                        "Wand Load complete, it took: " ..
                        tostring(load_wand_timer:get_total_secs())
                    )
                end
            end



            imgui.SameLine()
            if actions_input_str ~= '' and imgui_cautious_btn("Clear") then
                actions_input_str = ''
            end


            -- METRICS --
            
            local should_render_wand_timer = load_wand_timer:get_total_secs() > 0
            local should_render_action_count = prev_action_count > 0

            local should_render_metrics = should_render_action_count or should_render_action_count

            if should_render_metrics then
                imgui.Text("Wand Load Metrics")
            end

            if load_wand_timer:get_total_secs() > 0 then
                imgui.Text(string.format(
                    "\t -> Loaded in %.4f seconds", load_wand_timer:get_total_secs()
                ))
            end

            if prev_action_count > 0 then
                imgui.Text(string.format(
                    "\t -> Loaded %d spell actions", prev_action_count)
                )
            end

            imgui.End()
        end
    end
end

