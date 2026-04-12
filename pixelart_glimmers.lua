
function make_glimmer_material(name, material_id, ultrabright)
    return {
        name       = name,
        desc       = "for pixel art, utilizes material: " .. material_id,
        materials  = {material_id},
        mod_prefix = "CX",
        trail_mods = {
            count_min = "2",
            count_max = "5",
            trail_gap = "4",
            lifetime_min="8.0",
            lifetime_max="9.0",
            render_ultrabright="0",
        },
        author     = "CxRedix",
    }
end


local glimmer_appends = {
    -- EXAMPLE APPENDING OF GLIMMER
    -- {
    --     name            = "Vomit", -- The glimmer's name (i.e. "Vomit Glimmer"). Will also be used in the ID if `spellid_suffix` is not specified (i.e. "GLIMMERS_EXPANDED_COLOUR_VOMIT")
    --     desc            = "Gives a projectile a sickeningly sparkly trail", -- The glimmer's description
    --     materials       = {"vomit"}, -- The material(s) involved. The first one will color the glimmer, and the rest are used in glimmer alchemy.
    --     mod_prefix      = "CX", -- Will be used in the ID (i.e. "GLIMMERS_EXPANDED_EXAMPLE_COLOUR_VOMIT")
    --     author = "CxRedix",
    --
    --     -- image           = "mods/GlimmersExpanded/files/gfx/ui_gfx/colour_vomit.png", -- The filepath to the spell icon
    --     -- cast_delay      = 15, -- The cast delay reduction
    --     -- spawn_tiers     = "1,2", -- The spell tiers this spawns in
    --     -- sort_after      = 4.21, -- Where this is sorted in the progress menu
    --     -- spellid_suffix = "VOMIT", -- Will be used in the ID in place of `name` (i.e. "GLIMMERS_EXPANDED_EXAMPLE_COLOUR_THE_VOMIT_TESTING_THINGY")
    --     -- is_rare         = false, -- Determines whether the glimmer shows up in the glimmer lab
    --     -- custom_action   = function() -- A custom action, if you'd like to specify one
    --     --     c.fire_rate_wait = c.fire_rate_wait - 45
    --     --     current_reload_time = current_reload_time - 20
    --     --     c.speed_multiplier = c.speed_multiplier * 2.5
    --     -- end,
    --     -- -- Is a table of any value a ParticleEmitterComponent has. Check https://noita.wiki.gg/wiki/Documentation:_ParticleEmitterComponent for more details!
    --     -- trail_mods = {
    --     --     count_min = "2",
    --     --     count_max = "5",
    --     --     trail_gap = "4",
    --     --     lifetime_min="8.0",
    --     --     lifetime_max="9.0",
    --     --     render_ultrabright="1",
    --     -- },
    -- },
    make_glimmer_material("Vomit", "vomit"),
    make_glimmer_material("Wood", "wood"),
    make_glimmer_material("Brick", "brick"),
    make_glimmer_material("Red Brick", "templebrick_red"),
    make_glimmer_material("Odd Brick", "wizardstone"),
    make_glimmer_material("Diamond Brick", "templebrick_diamond_static"),
    make_glimmer_material("Altar Glowing Stone", "glowstone_altar"),
    make_glimmer_material("Holy Matter", "fuse_holy"),
    make_glimmer_material("Gold", "gold_b2"),
    make_glimmer_material("Fungus Red", "fungus_loose"),
    make_glimmer_material("Fungus Green", "fungus_loose_green"),
    make_glimmer_material("Bone", "bone_box2d"),
    make_glimmer_material("Fuse Dark", "fuse"),
    make_glimmer_material("Fuse Bright", "fuse_bright"),
    make_glimmer_material("Thick Blood", "blood_thick"),
    make_glimmer_material("Cement", "cement"),
    make_glimmer_material("Hearty Porrige", "porridge"),
    make_glimmer_material("Creepy Liquid", "creepy_liquid"),
    make_glimmer_material("Milk", "milk"),
    make_glimmer_material("Midas Precursor", "midas_precursor"),
    make_glimmer_material("Draught of Midas", "midas"),
    make_glimmer_material("Invisiblium", "magic_liquid_invisibility"),
    make_glimmer_material("Conc Mana", "magic_liquid_mana_regeneration"),
    make_glimmer_material("Acceleratium", "magic_liquid_movement_faster"),
    make_glimmer_material("Ambrosia", "magic_liquid_protection_all"),
    make_glimmer_material("Hastium", "magic_liquid_faster_levitation_and_movement"),
    make_glimmer_material("Chaotic Poly", "magic_liquid_random_polymorph"),
    make_glimmer_material("Australium", "static_magic_material"),
    make_glimmer_material("Deathium", "just_death"),
    make_glimmer_material("Pus", "pus"),
    make_glimmer_material("Hell Slime", "endslime_static"),
    make_glimmer_material("Radioactive Ice", "ice_radioactive_static"),
    make_glimmer_material("Frozen Slime", "ice_slime_static"),
    make_glimmer_material("Frozen Blood", "ice_blood_static"),
    make_glimmer_material("Unstable Teleportatium", "magic_liquid_unstable_teleportation"),
    make_glimmer_material("Teleportatium", "magic_liquid_teleportation"),
    make_glimmer_material("Water", "water"),
    make_glimmer_material("Urine", "urine"),
    make_glimmer_material("Swamp", "swamp"),
    make_glimmer_material("Cheese", "cheese_static"),
    make_glimmer_material("Fungus Blood", "blood_fungi"),
    make_glimmer_material("Juhannussima Brown", "juhannussima"),
    make_glimmer_material("Plasma Green", "plasma_fading_green"),
    make_glimmer_material("Plasma Pink", "plasma_fading_pink"),
    make_glimmer_material("Weak Liquid Fire", "liquid_fire_weak"),
    make_glimmer_material("Liquid Fire", "liquid_fire"),
    make_glimmer_material("Greed Cursed Liquid", "cursed_liquid"),
    make_glimmer_material("Molten Plastic Gray", "plastic_grey_molten"),
    make_glimmer_material("Molten Plastic Red", "plastic_red_molten"),
    make_glimmer_material("Molten Gold", "gold_molten"),
    make_glimmer_material("Molten Glass", "glass_molten"),
    make_glimmer_material("Molten Brass", "brass_molten"),
    make_glimmer_material("Molten Copper", "copper_molten"),
    make_glimmer_material("Molten Silver", "silver_molten"),
    make_glimmer_material("Molten Metal", "metal_molten"),
    make_glimmer_material("Molten Wax", "wax_molten"),
}

for _,entry in ipairs(glimmer_appends) do
    table.insert(glimmer_data, entry)
end
