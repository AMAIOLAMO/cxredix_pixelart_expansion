-- appended to data/scripts/gun/gun.lua

dofile_once("mods/cxredix_pixelart_expansion/cx_action_parse_utils.lua")
local cx_deck_sync = dofile_once("mods/cxredix_pixelart_expansion/cx_deck_sync.lua")

local cx_pxa_old_add_card_to_deck = _add_card_to_deck


function _add_card_to_deck(action_id, inventoryitem_id, uses_remaining, is_identified)

    if cx_deck_sync.should_sync() then
        local raw_deck_str = cx_deck_sync.consume_sync()

        GamePrint("Received Sync!")
        GamePrint("Clearing Deck...")
        _clear_deck(false)

        GamePrint("deck cleared, loading...")

        local deck_action_ids = cx_deserialize_to_action_ids(raw_deck_str)
            
        -- can be easily optimized by manually remembering the spells instead of linear search each time,
        -- but that's for another day :)
        for _, deck_action_id in ipairs(deck_action_ids) do
            cx_pxa_old_add_card_to_deck(deck_action_id, inventoryitem_id, -1, is_identified)
        end

        cx_deck_sync.mark_sync_complete_flag()

        GamePrint("Load finished!")

        GlobalsSetValue("cx_pxa_sync_deck_actions", "")
        GlobalsSetValue("cx_pxa_sync_complete_flag", "true")

        return
    end

    cx_pxa_old_add_card_to_deck(action_id, inventoryitem_id, uses_remaining, is_identified)
end

