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

### Configuration

Due to the way level files are loaded in, some extra configuration is required if the CustomLevels package is relocated. If it is anywhere other than the root directory of the mod, or has a name other than CustomLevels, `set_directory` must be called, passing the path to the directory within the mod folder including the directory name. Eg, for `MyCoolMod/SweetFolder/CustomLevels/custom_levels.lua` call `custom_levels.set_directory('SweetFolder/CustomLevels')`.

## Procedural Spawns

Random spawns such as crates, rocks, webs, gold, and embedded items, are removed by default so that only
manually spawned items exist. For some of these items, this means that tile codes that add the item will not spawn the item.

It should work to create a custom tile code to spawn in the entity and manually spawn it in the script.

The following entities must be forced to spawn during level generation:
- ENT_TYPE.EMBED_GOLD
- ENT_TYPE.EMBED_GOLD_BIG
- ENT_TYPE.ITEM_RUBY
- ENT_TYPE.ITEM_SAPPHIRE
- ENT_TYPE.ITEM_EMERALD
- ENT_TYPE.ITEM_ALIVE_EMBEDDED_ON_ICE
- ENT_TYPE.ITEM_PICKUP_ROPEPILE
- ENT_TYPE.ITEM_PICKUP_BOMBBAG
- ENT_TYPE.ITEM_PICKUP_BOMBBOX
- ENT_TYPE.ITEM_PICKUP_SPECTACLES
- ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES
- ENT_TYPE.ITEM_PICKUP_PITCHERSMITT
- ENT_TYPE.ITEM_PICKUP_SPRINGSHOES
- ENT_TYPE.ITEM_PICKUP_SPIKESHOES
- ENT_TYPE.ITEM_PICKUP_PASTE
- ENT_TYPE.ITEM_PICKUP_COMPASS
- ENT_TYPE.ITEM_PICKUP_PARACHUTE
- ENT_TYPE.ITEM_CAPE
- ENT_TYPE.ITEM_JETPACK
- ENT_TYPE.ITEM_TELEPORTER_BACKPACK
- ENT_TYPE.ITEM_HOVERPACK
- ENT_TYPE.ITEM_POWERPACK
- ENT_TYPE.ITEM_WEBGUN
- ENT_TYPE.ITEM_SHOTGUN
- ENT_TYPE.ITEM_FREEZERAY
- ENT_TYPE.ITEM_CROSSBOW
- ENT_TYPE.ITEM_CAMERA
- ENT_TYPE.ITEM_TELEPORTER
- ENT_TYPE.ITEM_MATTOCK
- ENT_TYPE.ITEM_BOOMERANG
- ENT_TYPE.ITEM_MACHETE

When loading a level, there is an optional last parameter that can be set to allow the game to do its spawns during generation. There are three types of spawns that can be separately configured via a bitmask `ALLOW_SPAWN_TYPE`:
- `PROCEDURAL` (Items in the level, such as gold, pots, crates, ghost pot, etc)
- `EMBEDDED_CURRENCY` (Gold and gems embedded in the wall)
- `EMBEDDED_ITEMS` (Items such as backpacks, weapons, and powerups embedded in the wall)

This will allow all spawns except for gold and gems embedded in the wall:
```
    local allowed_spawns = set_flag(0, custom_levels.ALLOW_SPAWN_TYPE.PROCEDURAL)
    allowed_spawns = set_flag(allowed_spawns, custom_levels.ALLOW_SPAWN_TYPE.EMBEDDED_ITEMS)
    custom_levels.load_level(file_name, width, height, ctx, allowed_spawns)
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