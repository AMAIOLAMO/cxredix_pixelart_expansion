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

    local result_content = firebomb_xml:gsub(
        original_firebomb, new_firebomb
    )

    ModTextFileSetContent("data/entities/projectiles/deck/firebomb.xml", result_content)

    GamePrint("[Pixel art expansion] Loaded white tinted firebomb")
end

local player

function get_held_wand()
    if player == nil then
        player = EntityGetWithTag("player_unit")[1]
    end

    if player == nil then
        return nil
    end

    local wands
    for _, child_id in ipairs(EntityGetAllChildren(player) or {}) do
        if EntityGetName(child_id) == "inventory_quick" then
            wands = EntityGetAllChildren(child_id, "wand")
        end
    end

    if wands == nil or #wands <= 0 then
        return nil
    end

    local sec_inv = EntityGetFirstComponent(player, "Inventory2Component")
    local active_item = ComponentGetValue2(sec_inv, "mActiveItem")

    for _, wand_id in ipairs(wands) do
        if wand_id == active_item then
            return wand_id
        end
    end
    
    return nil
end

function wand_clear_all_actions(wand_id)
    local children = EntityGetAllChildren(wand_id, "card_action") or {}
    
    for _, child_id in ipairs(children) do
        EntityRemoveFromParent(child_id)
        EntityKill(child_id)
    end
end

function wand_is_action_count_greater_than(wand_id, threshold)
    local children = EntityGetAllChildren(wand_id, "card_action") or {}

    local count = 0

    for _, child_id in ipairs(children) do
        count = count + 1

        if count > threshold then
            return true
        end
    end

    return false
end

-- use imgui when the function exists
if load_imgui ~= nil then
    local imgui = load_imgui({version="1.21.0", mod="CxRedixPixelartExpansion"})

    local should_clear_next_frame = false

    local wand_raw_text = ""

    function deserialize_to_action_names(raw_str)
        local action_names = {}

        -- ignore newlines, spaces, and commas. That would mean Spaces inbetween spell id's are NOT
        -- allowed: TEST_ABC cannot be TEST _ABC
        for str in raw_str:gmatch("([^\n ,]+)") do
            table.insert(action_names, str)
        end

        return action_names
    end

    function wand_set_deck_cap(wand_id, cap)
        local ability = EntityGetFirstComponentIncludingDisabled( wand_id, "AbilityComponent" )

        if ability then
            ComponentObjectSetValue2( ability, "gun_config", "deck_capacity", cap)
        else
            GamePrint("Error, ability component not found!")
        end
    end

    function all_wand_force_refresh()
        if player == nil then
            return 
        end
        -- else

        local sec_inv = EntityGetFirstComponent(player, "Inventory2Component")

        if sec_inv == nil then
            return
        end
        -- else

        ComponentSetValue2(sec_inv, "mForceRefresh", true)
        ComponentSetValue2(sec_inv, "mActualActiveItem", 0)
        ComponentSetValue2(sec_inv, "mDontLogNextItemEquip", true)
    end

    function wand_load_action_str(wand_id, raw_str)
        local action_names = deserialize_to_action_names(raw_str)

        for idx, action_name in ipairs(action_names) do
            if action_name == nil or action_name == '' then
                goto continue
            end

            local action_entity = CreateItemActionEntity(action_name, 0, 0)
            EntityAddChild(wand_id, action_entity)

            local item_comp = EntityGetFirstComponentIncludingDisabled(action_entity, "ItemComponent")
            local _, item_y_pos = ComponentGetValue2(item_comp, "inventory_slot")
            ComponentSetValue2(item_comp, "inventory_slot", idx - 1, item_y_pos)

            EntitySetComponentsWithTagEnabled(action_entity, "enabled_in_world", false)

            -- This does not work, tha game seems to load the particle emitter differently.
            -- local particle_emitter = EntityGetFirstComponentIncludingDisabled(action_entity, "ParticleEmitterComponent")
            -- EntityRemoveComponent(action_entity, particle_emitter)

            ::continue::
        end

        wand_set_deck_cap(wand_id, #action_names)

        all_wand_force_refresh()
    end

    local prev_wand_start_load_time_sec = -1
    local prev_time_load_sec = -1

    function OnWorldPostUpdate()
        imgui.SetNextWindowSize(800, 400, imgui.Cond.Once)

        if should_clear_next_frame == true then
            wand_clear_all_actions(get_held_wand())

            prev_time_load_sec = GameGetRealWorldTimeSinceStarted() - prev_wand_start_load_time_sec

            GamePrint("Cleared wand")
            GamePrint("[Pixelart wand loader] Wand Load complete, it took: " .. tostring(prev_time_load_sec))

            should_clear_next_frame = false
        end

        if ModSettingGet("cxredix_pixelart_expansion.enable_wand_loader") and imgui.Begin("Wand Loader") then
            imgui.Text("Put your wand string below")
            _, wand_raw_text = imgui.InputText("", wand_raw_text)

            if wand_raw_text ~= '' and imgui.Button("Load on held wand and clear") then
                local held_wand = get_held_wand()

                if held_wand ~= nil then
                    GamePrint("[Pixelart wand loader] Loading held wand")
                    prev_wand_start_load_time_sec = GameGetRealWorldTimeSinceStarted()

                    wand_clear_all_actions(held_wand)
                    wand_load_action_str(held_wand, wand_raw_text)
                    should_clear_next_frame = true
                end
            end

            if wand_raw_text ~= '' and imgui.Button("Load on held wand") then
                local held_wand = get_held_wand()

                if held_wand ~= nil then
                    GamePrint("[Pixelart wand loader] Loading held wand")
                    prev_wand_start_load_time_sec = GameGetRealWorldTimeSinceStarted()
                    
                    wand_clear_all_actions(held_wand)
                    wand_load_action_str(held_wand, wand_raw_text)
                    prev_time_load_sec = GameGetRealWorldTimeSinceStarted() - prev_wand_start_load_time_sec

                    GamePrint("[Pixelart wand loader] Wand Load complete, it took: " .. tostring(prev_time_load_sec))
                end
            end

            if prev_time_load_sec > 0 then
                imgui.Text(string.format("Loaded previous wand in: %.4f seconds", prev_time_load_sec))
            end

            imgui.End()
        end
    end
end

