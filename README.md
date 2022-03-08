# CustomLevels
Utility for loading custom levels.

The level loading supports levels of any size up to 8x15, which is the max Spelunky 2 can support.

Each room must be created as a setroom template with the format `setroomy_x`. This is slightly different from the `setroomy-x` that the game uses for setrooms.

The level file must be loaded in the ON.PRE_LOAD_LEVEL_FILES via the `load_level_custom_theme` function, or the legacy `load_level()` function, with the PRE_LOAD_LEVEL_FILES context passed in as a parameter.

When loading a level that should not be overridden, such as the base camp, `unload_level()` can be called to clear the loaded level state.

Example:

```
set_callback(function(ctx)
    if state.screen ~= SCREEN.LEVEL then
        custom_levels.unload_level()
    else
        local width, height = 4, 6
        local theme_properties = {
            theme = THEME.COSMIC_OCEAN,
            subtheme = THEME.JUNGLE,
        }
        custom_levels.load_level_custom_theme(ctx, 'cool_level.lvl', theme_properties)
    end
end, ON.PRE_LOAD_LEVEL_FILES)
```

## CustomTheme

The theme parameter of the `load_level_custom_themes` can be either a CustomTheme object or a table of properties that will be used to configure a new CustomTheme.

The theming table supports the following properties:

* `theme` THEME \
The base theme to load the level. This is the only required field, and everything else will revert to default values.
* `subtheme` THEME \
Subtheme to be used when the theme is COSMIC_OCEAN.
* `border_type` BORDER_THEME \
Enum value that configures what type of border to use.
* `growable_spawn_types` GROWABLE_SPAWN_TYPE \
Enum bitmask of the types of growables that will spawn.
* `background_theme` THEME \
Customize the background to look like the background of `background_theme`.
* `floor_theme` THEME \
Customize the floor textures to look like the floors of `floor_theme`.
* `post_configure` function(CustomTheme, Subtheme) \
Function that allows additional configuration of the CustomTheme that was created from the properties.

Additional theming:
* `border_theme` THEME \
Allows more fine-grained theming compared to what `border_type` allows, theming the border to match the theme.
* `border_entity_theme` THEME \
Allows more fine-grained theming compared to what `border_type` allows, theming the entity of the border to match the theme.
* `background_texture_theme` THEME \
Allows more fine-grained theming of the background texture.
* `background_texture` TEXTURE \
Even more fine-grained than `background_texture_theme`, only overriding the texture itself.
* `floor_texture_theme` THEME \
Themes the floor texture without also affecting some other things that `floor_theme` affects.
* `floor_texture` TEXTURE \
Override the floor textures with a specific texture.


Additional fields:
* `dont_spawn_effects` Bool \
Some spawn effects for the base theme may be undesired, so this will disable them.
* `dont_init` Bool \
Some initialization properties for the base theme may be undesired, so this will disable them.
* `dont_spawn_growables` Bool \
Like using `growable_spawn_types = GROWABLE_SPAWN_TYPE.NONE`, except also will not spawn sliding doors under slidingdoor_ceiling.
* `dont_loop` Bool \
This will allow cosmic ocean themes not to loop. (Untested)
* `loop` Bool \
This will allow non-cosmic ocean themes to loop. (Untested)
* `dont_adjust_camera_focus` Bool \
The camera normally focuses on the player at the start of the level. This disables that for customizable behavior.
* `dont_adjust_camera_bounds` Bool \
The camera bounds are normally changed for cosmic ocean themes. This disables that for customizable behavior.
* `camera_bounds` AABB \
Custom camera bounds to initialize the level with.

### BORDER_THEME

The BORDER_THEME enum configures both the type of border and the border entity.

* `DEFAULT` \
Defaults to the preferred border properties of the base theme.
* `HARD_FLOOR` \
Normal border as found in most themes.
* `SUNKEN_CITY` \
Normal border but with sunken city themed texture.
* `NEO_BABYLON` \
Normal border but with neo babylon themed texture.
* `ICE_CAVES` \
Border on top and both edges, but not on bottom, as found in the Ice Caves.
* `ICE_SUNKEN` \
Ice caves border, but with sunken city themed texture.
* `ICE_BABY` \
Ice caves border, but with neo babylon themed texture.
* `DUAT` \
Duat fog borders on sides with invisible border on top and bottom.
* `TIAMAT` \
Neo babylon themed borders with lasers embeded, as found in Tiamat's Throne.
* `COSMIC_OCEAN` \
Looping border, as found in Cosmic Ocean.
* `NONE` \
No border, the player may die when leaving the bounds.

### GROWABLE_SPAWN_TYPE

The GROWABLE_SPAWN_TYPE enum configures which growables will grow. Others will be left with just the root objects spawned.

Growables are growable_vines, growable_poles, chain_ceiling, and chain_and_blocks_ceiling.

* `NONE` \
Do not spawn any growables.
* `CHAINS` \
Spawn chains from chain_ceiling and chains and blocks from chain_and_blocks_ceiling.
* `TIDE_POOL_POLES` \
Spawn poles up from growable_poles.
* `VINES` \
Spawn vines down from growable_vines.

The GROWABLE_SPAWN_TYPE is a bitmask, so multiple spawn types can be chained, such as:
GROWABLE_SPAWN_TYPE.CHAINS | GROWABLE_SPAWN_TYPE.VINES.

The default, GROWABLE_SPAWN_TYPE.ALL, spawns all growables.

Note: Due to technical limitations, chains and tide pool poles cannot be spawned without also spawning vines.

## Entrance Doors

By default, entrance doors are hidden since they can look strange in many custom levels. This can be configured by calling the
set_hide_entrance methods.

```
-- Hide the entrances.
custom_levels.set_hide_entrance(true)

-- Do not hide the entrances.
custom_levels.set_hide_entrance(false)
```

## Procedural Spawns

Random spawns such as crates, rocks, webs, gold, and embedded items, are removed by default so that only
manually spawned items exist. For some of these items, this means that tile codes that add the item will not spawn the item.

It should work to create a custom tile code to spawn in the entity and manually spawn it in the script.

The following entities may need to be forced to spawn during level generation:
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
- `PROCEDURAL_ENEMIES` (Enemies that spawn procedurally, such as)

This will allow all spawns except for gold and gems embedded in the wall:
```
    local allowed_spawns = set_flag(0, custom_levels.ALLOW_SPAWN_TYPE.PROCEDURAL)
    allowed_spawns = set_flag(allowed_spawns, custom_levels.ALLOW_SPAWN_TYPE.EMBEDDED_ITEMS)
    allowed_spawns = set_flag(allowed_spawns, custom_levels.ALLOW_SPAWN_TYPE.PROCEDURAL_ENEMIES)
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

Spawning growables in the CO sometimes causes crashes.

CO levels must have an exit door.

CO levels must be at least 3x3.