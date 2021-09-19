# CustomLevels
Utility for loading custom levels.

The level loading supports levels of any size up to 8x15, which is the max Spelunky 2 can support.

Each room must be created as a setroom template with the format `setroomy_x`. This is slightly different from the `setroomy-x` that the game uses for setrooms.

The level file must be loaded in the ON.PRE_LOAD_LEVEL_FILES via the `load_level()` function, with the PRE_LOAD_LEVEL_FILES context passed in as the last parameter.

When loading a level that should not be overridden, such as the base camp, `unload_level()` can be called to clear the loaded level state.

Example:

```
set_callback(function(ctx)
    if state.theme == THEME.BASE_CAMP or state.theme == 0 then
        custom_levels.unload_level()
    else
        local width, height = 4, 6
        custom_levels.load_level('cool_level.lvl', width, height, ctx)
    end
end, ON.PRE_LOAD_LEVEL_FILES)
```

## Back layers

To set the back layer of a level, mark the template as `\!dual` and include the back layer tiles in line after the front layer tiles.

## Ice Caves

Levels in the Ice Caves themes have some additional restrictions.

The bottom level of rooms will be off-screen, so the level should be one taller than what is expected to be visible to the user.

They must include a `setroomy-x` for some templates. The `setroomy-x` template must have the same content as the `setroomy_x` template for the same room. Otherwise, some rooms will randomly pick one or the other. Following are the rooms that require a `setroomy-x`:
- 4-0, 4-1, and 4-2
- 5-0, 5-1, and 5-2
- 6-0, 6-1, and 6-2
- 7-0, 7-1, and 7-2

They also must include a `setroomy-x` for the _back layer_ of some addional templates. These `setroomy-x` templates must have the same content as the _back layer_ of the `setroomy_x` template for the same room. Following are the rooms that require a back layer `setroomy-x`:
- 10-0, 10-1, 10-2
- 11-0, 11-1, 11-2
- 12-0, 12-1, 12-2
- 13-0, 13-1, 13-2

Even if the level is smaller than the setroomy-x template, the template must be included or the game will crash. The template can be all 0s if the room isn't actually being used.