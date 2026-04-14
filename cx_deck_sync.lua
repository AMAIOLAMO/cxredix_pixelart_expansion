local M = {}

function M.consume_sync()
    local deck_actions = GlobalsGetValue("cx_pxa_sync_deck_actions")
    GlobalsSetValue("cx_pxa_sync_deck_actions", "")

    return deck_actions
end

function M.should_sync()
    local deck_actions = GlobalsGetValue("cx_pxa_sync_deck_actions")

    return deck_actions ~= ""
end

function M.mark_sync_complete()
    GlobalsSetValue("cx_pxa_sync_complete_flag", "true")
end

function M.is_sync_complete()
    return GlobalsGetValue("cx_pxa_sync_complete_flag") == "true"
end

function M.clear_sync_complete_flag()
    GlobalsSetValue("cx_pxa_sync_complete_flag", "")
end

return M
