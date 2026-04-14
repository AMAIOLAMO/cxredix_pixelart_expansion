function cx_deserialize_to_action_names(raw_str)
    local action_names = {}

    -- ignore newlines, spaces, and commas. That would mean Spaces inbetween spell id's are NOT
    -- allowed: TEST_ABC cannot be TEST _ABC
    for str in raw_str:gmatch("([^\n ,]+)") do
        table.insert(action_names, str)
    end

    return action_names
end

