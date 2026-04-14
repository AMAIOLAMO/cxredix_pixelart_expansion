-- appended to data/scripts/gun/gun.lua

dofile_once("mods/cxredix_pixelart_expansion/cx_actions_parser.lua")

local cx_pxa_old_add_card_to_deck = _add_card_to_deck


function _add_card_to_deck(action_id, inventoryitem_id, uses_remaining, is_identified)
    local raw_deck_str = GlobalsGetValue("cx_pxa_sync_deck_actions")

    if raw_deck_str ~= "" then
        GamePrint("Clearing deck")
        _clear_deck(false)

        GamePrint("deck cleared, loading...")

        local init_load_time_sec = GameGetRealWorldTimeSinceStarted()
        local deck_action_ids = cx_deserialize_to_action_ids(raw_deck_str)
            
        -- can be easily optimized by manually remembering the spells instead of linear search each time,
        -- but that's for another day :)
        for _, deck_action_id in ipairs(deck_action_ids) do
            cx_pxa_old_add_card_to_deck(deck_action_id, inventoryitem_id, -1, is_identified)
        end


        local load_time_total_sec = GameGetRealWorldTimeSinceStarted() - init_load_time_sec

        GamePrint("Load finished. Took: " .. tostring(load_time_total_sec) .. " seconds.")

        GlobalsSetValue("cx_pxa_sync_deck_actions", "")
        GlobalsSetValue("cx_pxa_sync_complete_flag", "true")

        return
    end

    cx_pxa_old_add_card_to_deck(action_id, inventoryitem_id, uses_remaining, is_identified)
end

