local custom_level_params = {
    custom_levels_directory = 'CustomLevels',
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
    allowed_spawn_types = 0,

    entrance_tc = nil,
    entrance_remove_callback = nil,
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
	ENT_TYPE.MONS_SCARAB,
	ENT_TYPE.ITEM_AUTOWALLTORCH,
	ENT_TYPE.ITEM_TORCH,
	ENT_TYPE.ITEM_WEB,
	ENT_TYPE.ITEM_GOLDBAR,
	ENT_TYPE.ITEM_GOLDBARS,
	ENT_TYPE.ITEM_SKULL,
	ENT_TYPE.MONS_SKELETON,
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
}

local ALLOW_SPAWN_TYPE = {
    PROCEDURAL = 1,
    EMBEDDED_CURRENCY = 2,
    EMBEDDED_ITEMS = 3,
}

local function set_directory(directory)
    custom_level_params.custom_levels_directory = directory
end

-- Resets the state to remove references to the loaded file and removes callbacks that alter the level.
local function unload_level()
    if not custom_level_state.active then return end
    custom_level_state.allowed_spawn_types = 0
    custom_level_state.active = false
    custom_level_state.file_name = nil
    custom_level_state.width = nil
    custom_level_state.height = nil
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
    if custom_level_state.entrance_tc then
        clear_callback(custom_level_state.entrance_tc)
    end
    custom_level_state.entrance_tc = nil
    if custom_level_state.entrance_remove_callback then
        clear_callback(custom_level_state.entrance_remove_callback)
    end
    custom_level_state.entrance_remove_callback = nil
end

-- Load in a level file.
-- file_name: name/path to the file to load.
-- width: Width of the level in the file.
-- height: Height of the level in the file.
-- load_level_ctx: Context to load the level file into.
--
-- Note: This must be called in ON.PRE_LOAD_LEVEL_FILES with the load_level_ctx from that callback.
local function load_level(file_name, width, height, load_level_ctx, allowed_spawn_types)
    allowed_spawn_types = allowed_spawn_types or 0

    unload_level()
    custom_level_state.active = true
    custom_level_state.file_name = file_name
    custom_level_state.width = width
    custom_level_state.height = height
    custom_level_state.allowed_spawn_types = allowed_spawn_types

    local custom_levels_directory = custom_level_params.custom_levels_directory
    function override_level(ctx)
        local level_files = {
            file_name,
            f'../../{custom_levels_directory}/empty_rooms.lvl',
            f'../../{custom_levels_directory}/icecavesarea.lvl'
        }
        ctx:override_level_files(level_files)
    end
    if load_level_ctx then
        override_level(load_level_ctx)
    end
    custom_level_state.room_generation_callback = set_callback(function(ctx)
        state.height = height
        state.width = width
        for x = 0, width - 1 do
            for y = 0, height - 1 do
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
        entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
        entity.flags = set_flag(entity.flags, ENT_FLAG.DEAD)
        move_entity(entity.uid, 1000, 0, 0, 0)
        entity:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_TILE_CODE, 0, removed_embedded_items)

    custom_level_state.floor_spread_callback = set_post_entity_spawn(function(entity)
        entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
        move_entity(entity.uid, 1000, 0, 0, 0)
        entity:destroy()
    end, SPAWN_TYPE.LEVEL_GEN_FLOOR_SPREADING, 0)
end

return {
    state = custom_level_state,
    load_level = load_level,
    unload_level = unload_level,
    ALLOW_SPAWN_TYPE = ALLOW_SPAWN_TYPE,
    set_directory = set_directory,
}