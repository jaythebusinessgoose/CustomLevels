--- Load in custom levels with static level gen.
-- @module CustomLevels

local custom_level_params = {
    hide_entrance = true,
}

local custom_level_state = {
    active = false,
    file_name = nil,
    width = nil,
    height = nil,
    room_generation_callback = nil,
    procedural_spawn_callback = nil,
    embedded_currency_callback = nil,
    embedded_item_callback = nil,
    floor_spread_callback = nil,
    bat_callback = nil,
    allowed_spawn_types = 0,

    entrance_tc = nil,
    entrance_remove_callback = nil,

    custom_theme_id = 4000,
    custom_theme = nil,
}

-- Create a bunch of room templates that can be used in lvl files to create rooms. The maximum
-- level size is 8x15, so we only create that many templates.
local room_templates = {}
for x = 0, 7 do
	local room_templates_x = {}
	for y = 0, 14 do
		local room_template = define_room_template("setroom" .. y .. "_" .. x, ROOM_TEMPLATE_TYPE.NONE)
		room_templates_x[y] = room_template
	end
	room_templates[x] = room_templates_x
end

local removed_procedural_spawns = {
	ENT_TYPE.MONS_PET_DOG,
	ENT_TYPE.ITEM_BONES,
	ENT_TYPE.EMBED_GOLD,
	ENT_TYPE.EMBED_GOLD_BIG,
	ENT_TYPE.ITEM_POT,
	ENT_TYPE.ITEM_NUGGET,
	ENT_TYPE.ITEM_NUGGET_SMALL,
	ENT_TYPE.ITEM_SKULL,
	ENT_TYPE.ITEM_CHEST,
	ENT_TYPE.ITEM_CRATE,
	ENT_TYPE.MONS_PET_CAT,
	ENT_TYPE.MONS_PET_HAMSTER,
	ENT_TYPE.ITEM_ROCK,
	ENT_TYPE.ITEM_RUBY,
	ENT_TYPE.ITEM_CURSEDPOT,
	ENT_TYPE.ITEM_SAPPHIRE,
	ENT_TYPE.ITEM_EMERALD,
	ENT_TYPE.ITEM_WALLTORCH,
    ENT_TYPE.ITEM_LITWALLTORCH,
	ENT_TYPE.MONS_SCARAB,
	ENT_TYPE.ITEM_AUTOWALLTORCH,
	ENT_TYPE.ITEM_WEB,
	ENT_TYPE.ITEM_GOLDBAR,
	ENT_TYPE.ITEM_GOLDBARS,
	ENT_TYPE.ITEM_SKULL,
	ENT_TYPE.MONS_SKELETON,
	ENT_TYPE.ITEM_POTOFGOLD,
	ENT_TYPE.MONS_LEPRECHAUN,
	ENT_TYPE.DECORATION_POTOFGOLD_RAINBOW,
}

local removed_embedded_currencies = {
    ENT_TYPE.EMBED_GOLD,
    ENT_TYPE.EMBED_GOLD_BIG,
    ENT_TYPE.ITEM_RUBY,
    ENT_TYPE.ITEM_SAPPHIRE,
    ENT_TYPE.ITEM_EMERALD,
}

local removed_embedded_items = {
    ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE,
    ENT_TYPE.ITEM_PICKUP_ROPEPILE,
    ENT_TYPE.ITEM_PICKUP_BOMBBAG,
    ENT_TYPE.ITEM_PICKUP_BOMBBOX,
    ENT_TYPE.ITEM_PICKUP_SPECTACLES,
    ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES,
    ENT_TYPE.ITEM_PICKUP_PITCHERSMITT,
    ENT_TYPE.ITEM_PICKUP_SPRINGSHOES,
    ENT_TYPE.ITEM_PICKUP_SPIKESHOES,
    ENT_TYPE.ITEM_PICKUP_PASTE,
    ENT_TYPE.ITEM_PICKUP_COMPASS,
    ENT_TYPE.ITEM_PICKUP_PARACHUTE,
    ENT_TYPE.ITEM_CAPE,
    ENT_TYPE.ITEM_JETPACK,
    ENT_TYPE.ITEM_TELEPORTER_BACKPACK,
    ENT_TYPE.ITEM_HOVERPACK,
    ENT_TYPE.ITEM_POWERPACK,
    ENT_TYPE.ITEM_WEBGUN,
    ENT_TYPE.ITEM_SHOTGUN,
    ENT_TYPE.ITEM_FREEZERAY,
    ENT_TYPE.ITEM_CROSSBOW,
    ENT_TYPE.ITEM_CAMERA,
    ENT_TYPE.ITEM_TELEPORTER,
    ENT_TYPE.ITEM_MATTOCK,
    ENT_TYPE.ITEM_BOOMERANG,
    ENT_TYPE.ITEM_MACHETE,
	ENT_TYPE.ITEM_POTOFGOLD,
}

local procedural_enemies = {
    ENT_TYPE.MONS_BAT,
    ENT_TYPE.MONS_HERMITCRAB,
    ENT_TYPE.TADPOLE,
}

local ALLOW_SPAWN_TYPE = {
    PROCEDURAL = 1,
    EMBEDDED_CURRENCY = 2,
    EMBEDDED_ITEMS = 3,
    PROCEDURAL_ENEMIES = 4,
}
-- Keep old name in case it's being used.
ALLOW_SPAWN_TYPE.BACKLAYER_BATS = ALLOW_SPAWN_TYPE.PROCEDURAL_ENEMIES

local function set_hide_entrance(hide_entrance)
    custom_level_params.hide_entrance = hide_entrance
end

-- Resets the state to remove references to the loaded file and removes callbacks that alter the level.
local function unload_level()
    if not custom_level_state.active then return end
    custom_level_state.allowed_spawn_types = 0
    custom_level_state.active = false
    custom_level_state.file_name = nil
    custom_level_state.width = nil
    custom_level_state.height = nil
    custom_level_state.custom_theme = nil
    if custom_level_state.room_generation_callback then
        clear_callback(custom_level_state.room_generation_callback)
    end
    custom_level_state.room_generation_callback = nil
    if custom_level_state.procedural_spawn_callback then
        clear_callback(custom_level_state.procedural_spawn_callback)
    end
    custom_level_state.procedural_spawn_callback = nil
    if custom_level_state.embedded_currency_callback then
        clear_callback(custom_level_state.embedded_currency_callback)
    end
    custom_level_state.embedded_currency_callback = nil
    if custom_level_state.embedded_item_callback then
        clear_callback(custom_level_state.embedded_item_callback)
    end
    custom_level_state.embedded_item_callback = nil
    if custom_level_state.floor_spread_callback then
        clear_callback(custom_level_state.floor_spread_callback)
    end
    custom_level_state.floor_spread_callback = nil
    if custom_level_state.bat_callback then
        clear_callback(custom_level_state.bat_callback)
    end
    custom_level_state.bat_callback = nil
    if custom_level_state.entrance_tc then
        clear_callback(custom_level_state.entrance_tc)
    end
    custom_level_state.entrance_tc = nil
    if custom_level_state.entrance_remove_callback then
        clear_callback(custom_level_state.entrance_remove_callback)
    end
    custom_level_state.entrance_remove_callback = nil
end

local function load_level(load_level_ctx, file_name, custom_theme, allowed_spawn_types, width, height)
    allowed_spawn_types = allowed_spawn_types or 0

    unload_level()
    custom_level_state.active = true
    custom_level_state.file_name = file_name
    custom_level_state.width = width
    custom_level_state.height = height
    custom_level_state.allowed_spawn_types = allowed_spawn_types
    custom_level_state.custom_theme = custom_theme

    function override_level(ctx)
        local level_files = {
            file_name,
        }
        ctx:override_level_files(level_files)
    end
    if load_level_ctx then
        override_level(load_level_ctx)
    end
    if custom_theme then
        force_custom_theme(custom_theme)
    end
    custom_level_state.room_generation_callback = set_callback(function(ctx)
        if width and height then
            state.height = height
            state.width = width
        end
        for x = 0, state.width - 1 do
            for y = 0, state.height - 1 do
                ctx:set_room_template(x, y, LAYER.FRONT, room_templates[x][y])
            end
        end
    end, ON.POST_ROOM_GENERATION)

    ----------------------------
    ---- HIDE ENTRANCE DOOR ----
    ----------------------------

    local entranceX
    local entranceY
    local entranceLayer

    custom_level_state.entrance_tc = set_pre_tile_code_callback(function(x, y, layer)
        if state.screen == 13 then return end
        entranceX = math.floor(x)
        entranceY = math.floor(y)
        entranceLayer = layer
        return false
    end, "entrance")

    custom_level_state.entrance_remove_callback = set_post_entity_spawn(function (entity)
        if not entranceX or not entranceY or not entranceLayer then return end
        if not custom_level_params.hide_entrance then return end
        local px, py, pl = get_position(entity.uid)
        if math.abs(px - entranceX) < 1 and math.abs(py - entranceY) < 1 and pl == entranceLayer then
            kill_entity(entity.uid)
        end
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.BG_DOOR)

    -----------------------------
    ---- /HIDE ENTRANCE DOOR ----
    -----------------------------

    custom_level_state.procedural_spawn_callback = set_post_entity_spawn(function(entity, spawn_flags)
        if test_flag(custom_level_state.allowed_spawn_types, ALLOW_SPAWN_TYPE.PROCEDURAL) then return end
        -- Do not remove spawns from a script.
        if spawn_flags & SPAWN_TYPE.SCRIPT ~= 0 then return end
        entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
        entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
        move_entity(entity.uid, 1000, 0, 0, 0)
        entity:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_GENERAL | SPAWN_TYPE.LEVEL_GEN_PROCEDURAL, 0, removed_procedural_spawns)

    custom_level_state.embedded_currency_callback = set_post_entity_spawn(function(entity, spawn_flags)
        if test_flag(custom_level_state.allowed_spawn_types, ALLOW_SPAWN_TYPE.EMBEDDED_CURRENCY) then return end
        -- Do not remove spawns from a script.
        if spawn_flags & SPAWN_TYPE.SCRIPT ~= 0 then return end
        entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
        entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
        move_entity(entity.uid, 1000, 0, 0, 0)
        entity:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, removed_embedded_currencies)

    custom_level_state.embedded_item_callback = set_post_entity_spawn(function(entity, spawn_flags)
        if test_flag(custom_level_state.allowed_spawn_types, ALLOW_SPAWN_TYPE.EMBEDDED_ITEMS) then return end
        -- Do not remove spawns from a script.
        if spawn_flags & SPAWN_TYPE.SCRIPT ~= 0 then return end
        -- Only remove entities with an overlay, these should be the ones embeded in a crust.
        if not entity.overlay then return end
        entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
        entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
        move_entity(entity.uid, 1000, 0, 0, 0)
        entity:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, removed_embedded_items)

    custom_level_state.bat_callback = set_post_entity_spawn(function(entity, spawn_type)
        if test_flag(custom_level_state.allowed_spawn_types, ALLOW_SPAWN_TYPE.PROCEDURAL_ENEMIES) then return end
        -- Do not remove spawns from a script.
        if spawn_type & SPAWN_TYPE.SCRIPT ~= 0 then return end
        entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
        entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
        entity:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_GENERAL, 0, procedural_enemies)

    custom_level_state.floor_spread_callback = set_post_entity_spawn(function(entity)
        entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
        move_entity(entity.uid, 1000, 0, 0, 0)
        entity:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_FLOOR_SPREADING, 0)
end


--- Load in a level file.
-- @param file_name name/path to the file to load.
-- @param width Width of the level in the file.
-- @param height Height of the level in the file.
-- @param load_level_ctx ON.PRE_LOAD_LEVEL_FILES context to load the level file into.
-- @param allowed_spawn_types Optional spawn types flags to allow certain types of procedural spawns to spawn without being eliminated.
--
-- Note: This must be called in ON.PRE_LOAD_LEVEL_FILES with the load_level_ctx from that callback.
local function load_level_legacy(file_name, width, height, load_level_ctx, allowed_spawn_types)
    return load_level(load_level_ctx, file_name, nil, allowed_spawn_types, width, height)
end

local BORDER_THEME = {
    DEFAULT = 1,
    HARD_FLOOR = 2,
    SUNKEN_CITY = 3,
    NEO_BABYLON = 4,
    ICE_CAVES = 5,
    ICE_SUNKEN = 6,
    ICE_BABY = 7,
    DUAT = 8,
    NONE = 9,
    COSMIC_OCEAN = 10,
    TIAMAT = 11,
}
local GROWABLE_SPAWN_TYPE = {
    NONE = 0,
    CHAINS = 1,
    TIDE_POOL_POLES = 2,
    VINES = 4,
}
GROWABLE_SPAWN_TYPE.ALL = GROWABLE_SPAWN_TYPE.CHAINS | GROWABLE_SPAWN_TYPE.TIDE_POOL_POLES | GROWABLE_SPAWN_TYPE.VINES

local function theme_for_border_theme(border_theme)
    if border_theme == BORDER_THEME.DEFAULT or border_theme == BORDER_THEME.NONE then
        return nil
    elseif border_theme == BORDER_THEME.HARD_FLOOR then
        return THEME.DWELLING
    elseif border_theme == BORDER_THEME.SUNKEN_CITY then
        return THEME.SUNKEN_CITY
    elseif border_theme == BORDER_THEME.NEO_BABYLON then
        return THEME.NEO_BABYLON
    elseif border_theme == BORDER_THEME.ICE_CAVES or border_theme == BORDER_THEME.ICE_SUNKEN or border_theme == BORDER_THEME.ICE_BABY then
        return THEME.ICE_CAVES
    elseif border_theme == BORDER_THEME.DUAT then
        return THEME.DUAT
    elseif border_theme == BORDER_THEME.TIAMAT then
        return THEME.TIAMAT
    elseif border_theme == BORDER_THEME.COSMIC_OCEAN then
        return THEME.COSMIC_OCEAN
    end
end
local function entity_theme_for_border_theme(border_theme)
    if border_theme == BORDER_THEME.ICE_SUNKEN then
        return THEME.SUNKEN_CITY
    elseif border_theme == BORDER_THEME.ICE_BABY then
        return THEME.NEO_BABYLON
    end
    return theme_for_border_theme(border_theme)
end
local function background_texture_for_theme(theme)
    if theme == THEME.DWELLING or theme == THEME.BASE_CAMP or theme == THEME.COSMIC_OCEAN then
        return TEXTURE.DATA_TEXTURES_BG_CAVE_0
    elseif theme == THEME.VOLCANA then
        return TEXTURE.DATA_TEXTURES_BG_VOLCANO_0
    elseif theme == THEME.JUNGLE then
        return TEXTURE.DATA_TEXTURES_BG_JUNGLE_0
    elseif theme == THEME.OLMEC then
        return TEXTURE.DATA_TEXTURES_BG_STONE_0
    elseif theme == THEME.TIDE_POOL or theme == THEME.ABZU or theme == THEME.TIAMAT then
        return TEXTURE.DATA_TEXTURES_BG_TIDEPOOL_0
    elseif theme == THEME.TEMPLE or theme == THEME.DUAT then
        return TEXTURE.DATA_TEXTURES_BG_TEMPLE_0
    elseif theme == THEME.CITY_OF_GOLD then
        return TEXTURE.DATA_TEXTURES_BG_GOLD_0
    elseif theme == THEME.ICE_CAVES then
        return TEXTURE.DATA_TEXTURES_BG_ICE_0
    elseif theme == THEME.NEO_BABYLON then
        return TEXTURE.DATA_TEXTURES_BG_BABYLON_0
    elseif theme == THEME.SUNKEN_CITY or theme == THEME.HUNDUN then
        return TEXTURE.DATA_TEXTURES_BG_SUNKEN_0
    elseif theme == THEME.EGGPLANT_WORLD then
        return TEXTURE.DATA_TEXTURES_BG_EGGPLANT_0
    end
end

local function floor_texture_for_theme(theme)
    if theme == THEME.DWELLING then
        return TEXTURE.DATA_TEXTURES_FLOOR_CAVE_0
    elseif theme == THEME.BASE_CAMP then
        return TEXTURE.DATA_TEXTURES_FLOOR_SURFACE_0
    elseif theme == THEME.VOLCANA then
        return TEXTURE.DATA_TEXTURES_FLOOR_VOLCANO_0
    elseif theme == THEME.JUNGLE or theme == THEME.OLMEC then
        return TEXTURE.DATA_TEXTURES_FLOOR_JUNGLE_0
    elseif theme == THEME.TIDE_POOL or theme == THEME.TIAMAT or theme == THEME.ABZU then
        return TEXTURE.DATA_TEXTURES_FLOOR_TIDEPOOL_0
    elseif theme == THEME.TEMPLE or theme == THEME.DUAT or theme == THEME.CITY_OF_GOLD then
        return TEXTURE.DATA_TEXTURES_FLOOR_TEMPLE_0
    elseif theme == THEME.ICE_CAVES then
        return TEXTURE.DATA_TEXTURES_FLOOR_ICE_0
    elseif theme == THEME.NEO_BABYLON then
        return TEXTURE.DATA_TEXTURES_FLOOR_BABYLON_0
    elseif theme == THEME.SUNKEN_CITY or theme == THEME.HUNDUN then
        return TEXTURE.DATA_TEXTURES_FLOOR_SUNKEN_0
    elseif theme == THEME.EGGPLANT_WORLD then
        return TEXTURE.DATA_TEXTURES_FLOOR_EGGPLANT_0
    end
    return TEXTURE.DATA_TEXTURES_FLOOR_CAVE_0
end
local aaab = false
local function create_custom_theme(theme_properties, level_file)
    local theme = theme_properties.theme
    local subtheme = theme_properties.subtheme or theme_properties.co_subtheme
    local border_theme = theme_properties.theme
    local border_entity_theme = theme_properties.theme
    local border = theme_properties.border_type or theme_properties.border
    if border then
        if border == BORDER_THEME.NONE then
            border_theme = false
            border_entity_theme = false
        else
            border_theme = theme_for_border_theme(border) or border_theme
            border_entity_theme = entity_theme_for_border_theme(border) or border_entity_theme
        end
    end
    border_theme = theme_properties.border_theme or border_theme
    border_entity_theme = theme_properties.border_entity_theme or border_entity_theme

    local custom_theme = CustomTheme:new(custom_level_state.custom_theme_id, theme)
    custom_level_state.custom_theme_id = custom_level_state.custom_theme_id + 1
    -- Spawning effects does things like changing the camera bounds in ice caves and spawning the duat bosses.
    if not theme_properties.dont_spawn_effects then
        custom_theme:override(THEME_OVERRIDE.SPAWN_EFFECTS, theme)
    end
    custom_theme:override(THEME_OVERRIDE.SPAWN_BORDER, border_theme)
    custom_theme:override(THEME_OVERRIDE.ENT_BORDER, border_entity_theme)
    -- The INIT_LEVEL is required for some effects like duat fog to look proper, but it could do other things that may be
    -- undesired, so it can be disabled.
    if not theme_properties.dont_init then
        custom_theme:override(THEME_OVERRIDE.INIT_LEVEL, border_theme)
    end
    if (border_theme == THEME.COSMIC_OCEAN and not theme_properties.dont_loop) or theme_properties.loop then
        custom_theme:override(THEME_OVERRIDE.LOOP, THEME.COSMIC_OCEAN)
    end
    -- Some themes, such as cosmic ocean, do not get the level size from the level file, so it must be manually configured.
    if theme_properties.width or theme_properties.height then
        custom_theme:post(THEME_OVERRIDE.INIT_LEVEL, function()
            if theme_properties.width then state.width = theme_properties.width end
            if theme_properties.height then state.height = theme_properties.height end
        end)
    end
    custom_theme:post(THEME_OVERRIDE.SPAWN_LEVEL, function()
        if theme_properties.dont_spawn_growables then return end
        local growables = theme_properties.growables or theme_properties.enabled_growables or theme_properties.growable_spawn_types or GROWABLE_SPAWN_TYPE.ALL
        local poles = growables & GROWABLE_SPAWN_TYPE.TIDE_POOL_POLES == GROWABLE_SPAWN_TYPE.TIDE_POOL_POLES
        local chains = growables & GROWABLE_SPAWN_TYPE.CHAINS == GROWABLE_SPAWN_TYPE.CHAINS
        local vines = growables & GROWABLE_SPAWN_TYPE.VINES == GROWABLE_SPAWN_TYPE.VINES
        if (poles and chains and vines) or (poles and chains) then
            -- state.level_gen.themes[THEME.BASE_CAMP]:spawn_traps() -- Spawn chains and vines.
            state.level_gen.themes[THEME.TIDE_POOL]:spawn_traps() -- Spawn tide poles and sliding doors.
            state.level_gen.themes[THEME.DUAT]:spawn_traps() -- Spawn chains.
            state.level_gen.themes[THEME.JUNGLE]:spawn_traps() -- Spawn vines.
        elseif poles and chains then
            state.level_gen.themes[THEME.TIDE_POOL]:spawn_traps() -- Spawn tide poles and sliding doors.
            state.level_gen.themes[THEME.DUAT]:spawn_traps() -- Spawn chains.
        elseif chains and vines then
            state.level_gen.themes[THEME.VOLCANA]:spawn_traps() -- Spawn chains and sliding doors.
            state.level_gen.themes[THEME.JUNGLE]:spawn_traps() -- Spawn vines.
        elseif vines and poles then
            state.level_gen.themes[THEME.TIDE_POOL]:spawn_traps() -- Spawn tide poles and sliding doors.
            state.level_gen.themes[THEME.JUNGLE]:spawn_traps() -- Spawn vines.
        elseif vines then
            state.level_gen.themes[THEME.EGGPLANT_WORLD]:spawn_traps() -- Spawn vines and sliding doors.
        elseif poles then
            state.level_gen.themes[THEME.TIDE_POOL]:spawn_traps() -- Spawn tide poles and sliding doors.
        elseif chains then
            state.level_gen.themes[THEME.VOLCANA]:spawn_traps() -- Spawn chains and sliding doors.
        else
            state.level_gen.themes[THEME.CITY_OF_GOLD]:spawn_traps() -- Spawn sliding doors.
        end
    end)
    custom_theme:post(THEME_OVERRIDE.SPAWN_EFFECTS, function()
        if state.screen ~= SCREEN.LEVEL then return end
        -- Adjust the camera focus at the start of the level so it does not jump.
        if not theme_properties.dont_adjust_camera_focus then
            state.camera.adjusted_focus_x = state.level_gen.spawn_x
            state.camera.adjusted_focus_y = state.level_gen.spawn_y + 0.05
        end
        -- If a camera bounds property exists, set the camera bounds to those bounds. Otherwise, leave them alone except for
        -- in a cosmic ocean theme, where the camera bounds should be set to the max distance.
        if theme_properties.camera_bounds then
            state.camera.bounds_left = theme_properties.camera_bounds.left
            state.camera.bounds_right = theme_properties.camera_bounds.right
            state.camera.bounds_top = theme_properties.camera_bounds.top
            state.camera.bounds_bottom = theme_properties.camera_bounds.bottom
        elseif not theme_properties.dont_adjust_camera_bounds then
            if border_theme == THEME.COSMIC_OCEAN then
                state.camera.bounds_left = -math.huge
                state.camera.bounds_top = math.huge
                state.camera.bounds_right = math.huge
                state.camera.bounds_bottom = -math.huge
            end
        end
    end)

    if theme_properties.background_theme then
        custom_theme.textures[DYNAMIC_TEXTURE.BACKGROUND] = background_texture_for_theme(theme_properties.background_theme) or TEXTURE.DATA_TEXTURES_BG_CAVE_0

        custom_theme:override(THEME_OVERRIDE.ENT_BACKWALL, theme_properties.background_theme)
        custom_theme:override(THEME_OVERRIDE.SPAWN_BACKGROUND, theme_properties.background_theme)
    end

    if theme_properties.background_texture_theme then
        custom_theme.textures[DYNAMIC_TEXTURE.BACKGROUND] = background_texture_for_theme(theme_properties.background_texture_theme) or TEXTURE.DATA_TEXTURES_BG_CAVE_0
        custom_theme:override(THEME_OVERRIDE.ENT_BACKWALL, theme_properties.background_texture_theme)
    end

    if theme_properties.background_texture then
        custom_theme.textures[DYNAMIC_TEXTURE.BACKGROUND] = theme_properties.background_texture
    end

    if theme_properties.floor_theme then
        custom_theme.textures[DYNAMIC_TEXTURE.FLOOR] = floor_texture_for_theme(theme_properties.floor_theme)
        -- Spawns extra theme elements over the floor.
        custom_theme:override(THEME_OVERRIDE.SPAWN_PROCEDURAL, theme_properties.floor_theme)
    end
    if theme_properties.floor_texture_theme then
        custom_theme.textures[DYNAMIC_TEXTURE.FLOOR] = floor_texture_for_theme(theme_properties.floor_texture_theme)
    end
    if theme_properties.floor_texture then
        custom_theme.textures[DYNAMIC_TEXTURE.FLOOR] = theme_properties.floor_texture
    end
    custom_theme.theme = theme_properties.theme
    custom_theme.level_file = level_file

    if theme_properties.post_configure then
        theme_properties.post_configure(custom_theme, subtheme, theme_properties)
    end
    return custom_theme, subtheme
end

--- Load in a level file.
-- @param load_level_ctx ON.PRE_LOAD_LEVEL_FILES context to load the level file into.
-- @param file_name name/path to the file to load.
-- @param custom_theme Either a CustomTheme object or a table of parameters to configure a new CustomTheme.
-- @param allowed_spawn_types Optional spawn types flags to allow certain types of procedural spawns to spawn without being eliminated.
--
-- Note: This must be called in ON.PRE_LOAD_LEVEL_FILES with the load_level_ctx from that callback.
local function load_level_custom_theme(load_level_ctx, file_name, custom_theme, allowed_spawn_types)
    local actual_custom_theme = nil
    if custom_theme then
        if type(custom_theme) == "userdata" and getmetatable(custom_theme).__type.name == "CustomTheme" then
            actual_custom_theme = custom_theme
        else
            actual_custom_theme, subtheme = create_custom_theme(custom_theme, file_name)
            if subtheme then force_custom_subtheme(subtheme) end
            width = width or custom_theme.width
            height = height or custom_theme.height
        end
    end

    load_level(load_level_ctx, file_name, actual_custom_theme, allowed_spawn_types)
end


return {
    state = custom_level_state,
    load_level = load_level_legacy,
    load_level_custom_theme = load_level_custom_theme,
    unload_level = unload_level,
    ALLOW_SPAWN_TYPE = ALLOW_SPAWN_TYPE,
    set_hide_entrance = set_hide_entrance,
    BORDER_THEME = BORDER_THEME,
    GROWABLE_SPAWN_TYPE = GROWABLE_SPAWN_TYPE,
}
