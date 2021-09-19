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
- 10-0, 10-1, and 10-2
- 11-0, 11-1, and 11-2
- 12-0, 12-1, and 12-2
- 13-0, 13-1, and 13-2

Even if the level is smaller than the setroomy-x template, the template must be included or the game will crash. The template can be all 0s if the room isn't actually being used.

## Duat

Not much testing has been done in Duat, but it has similar restrictions to Ice Caves, or it will crash:

Duat must include a `setroomy-x` for some templates. The `setroomy-x` template must have the same content as the `setroomy_x` template for the same room. Otherwise, some rooms will randomly pick one or the other. Following are the rooms that require a `setroomy-x`:
- 0-0, 0-1, and 0-2
- 1-0, 1-1, and 1-2
- 2-0, 2-1, and 2-2
- 3-0, 3-1, and 3-2

In addition, the bosses will spawn at the top of the level.

## Abzu

Not much testing has been done in Abzu, but it has similar restrictions to Ice Caves, or it will crash:

Abzu must include a `setroomy-x` for some templates. The `setroomy-x` template must have the same content as the `setroomy_x` template for the same room. Otherwise, some rooms will randomly pick one or the other. Following are the rooms that require a `setroomy-x`:
- 0-0, 0-1, 0-2, and 0-3
- 1-0, 1-1, 1-2, and 1-3
- 2-0, 2-1, 2-2, and 2-3
- 3-0, 3-1, 3-2, and 3-3
- 4-0, 4-1, 4-2, and 4-3
- 5-0, 5-1, 5-2, and 5-3
- 6-0, 6-1, 6-2, and 6-3
- 7-0, 7-1, 7-2, and 7-3
- 8-0, 8-1, 8-2, and 8-3

In addition, rooms 7 and below will have water physics with fake water, with tentacles at the bottom.

Prefer to use TIDE_POOL theme instead of Abzu unless the water physics are desired.

## Tiamat

Not much testing has been done in Tiamat. It also requires several setrooms:
- 0-0, 0-1, and 0-2
- 1-0, 1-1, and 1-2
- 2-0, 2-1, and 2-2
- 3-0, 3-1, and 3-2
- 4-0, 4-1, and 4-2
- 5-0, 5-1, and 5-2
- 6-0, 6-1, and 6-2
- 7-0, 7-1, and 7-2
- 8-0, 8-1, and 8-2
- 9-0, 9-1, and 9-2
- 10-0, 10-1, and 10-2

Tiamat also spawns water at the bottom with tentacles.

The Tiamat level has a cutscene at the beginning, and will crash during the cutscene if there is no Tiamat spawned (has not been tested with a Tiamat spawn).

## Eggplant World

Eggplant world is crashing, and I haven't done any testing to figure out why.

It does have the following setrooms:
- 0-0, 0-1, 0-2, and 0-3
- 1-0, 1-1, 1-2, and 1-3

## Hundun

Hundun requires the following setrooms:
- 0-0, 0-1, and 0-2
- 1-0, 1-1, and 1-2
- 2-0, 2-1, and 2-2
- 10-0, 10-1, and 10-2
- 11-0, 11-1, and 11-2

## Olmec

Olmec requires the following setrooms:
- 0-0, 0-1, 0-2, and 0-3
- 1-0, 1-1, 1-2, and 1-3
- 2-0, 2-1, 2-2, and 2-3
- 3-0, 3-1, 3-2, and 3-3
- 4-0, 4-1, 4-2, and 4-3
- 5-0, 5-1, 5-2, and 5-3
- 6-0, 6-1, 6-2, and 6-3
- 7-0, 7-1, 7-2, and 7-3
- 8-0, 8-1, 8-2, and 8-3

Olmec is also crashing during the cutscene, you may need to spawn Olmec or disable the cutscene to address the crash.

## Cosmic Ocean

Haven't tested much. Loaded a level in and it seems to load fine in any subtheme. There are some weird things that go on if there isn't empty space along the looping edges.