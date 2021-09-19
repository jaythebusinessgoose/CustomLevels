
local custom_level_state = {
    active = false,
    file_name = nil,
    width = nil,
    height = nil,
    room_generation_callback = nil,
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

function unload_level()
    if not custom_level_state.active then return end
    custom_level_state.active = false
    custom_level_state.file_name = nil
    custom_level_state.width = nil
    custom_level_state.height = nil
    if custom_level_state.load_files_callback then
        clear_callback(custom_level_state.load_files_callback)
    end
    if custom_level_state.room_generation_callback then
        clear_callback(custom_level_state.room_generation_callback)
    end

    custom_level_state.load_files_callback = nil
    custom_level_state.room_generation_callback = nil
end

function load_level(file_name, width, height, load_level_ctx)
    unload_level()
    custom_level_state.active = true
    custom_level_state.file_name = file_name
    custom_level_state.width = width
    custom_level_state.height = height

    function override_level(ctx)
        local level_files = {
            file_name,
            '../../CustomLevels/empty_rooms.lvl',
            '../../CustomLevels/icecavesarea.lvl'
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
end

return {
    state = custom_level_state,
    load_level = load_level,
    unload_level = unload_level,
}