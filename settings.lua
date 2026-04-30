dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "cxredix_pixelart_expansion"
mod_settings_version = 1
mod_settings = {
    {
        id = "white_tint_firebomb",
        ui_name = "White Tint Firebomb",
        ui_description = "Makes Firebombs white tinted, very useful for pixelart.",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
    },
    {
        id = "firebomb_remove_particles",
        ui_name = "Firebomb remove particles",
        ui_description = "Removes firebomb's fire ParticleEmitterComponent",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME_RESTART,
    },
}

function ModSettingsUpdate(init_scope)
	mod_settings_update(mod_id, mod_settings, init_scope)
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
	mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end

