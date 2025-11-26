# WoWTools Copilot Instructions

## Project Overview
WoWTools is a comprehensive World of Warcraft AddOn written in Lua that enhances game functionality across four major modules:
- **WoWPlus**: System UI enhancements
- **GamePlus**: Common gameplay features  
- **Tools**: Utility tools collection
- **ChatButton**: Chat-integrated buttons and utilities

The addon is localized (Chinese-first) and supports multiple WoW versions (Retail, Classic, Cataclysm).

## Architecture Patterns

### Directory Structure & Load Order
File load order is **critical** - defined in `WoWTools.toc` and must be maintained:

1. **Source/Libs/** - External libraries (LibStub, CallbackHandler, LibDataBroker)
2. **0_Data/** - Core data structures and mixins (must load first)
   - `1_DataMixin.lua` - Global WoWTools_DataMixin table (plugin metadata, player state)
   - `2_DataMixin_WoW.lua` - WoW API data structures (units, items, guilds, keystones)
   - `3_DataMixn_Func.lua` - Utility functions (Hook, Call, Load methods)
   - Files with `z_` prefix load last within 0_Data
3. **1_Mixin/** - Reusable UI/Framework mixins (Button, Frame, Menu, etc.)
4. **Plus_*** modules - Optional feature modules with independent UI enhancements
5. **ChatButton*** modules - Chat integration features
6. **Tools_*** modules - Tool-specific implementations
7. **Z_Other/** - Miscellaneous optional features

### Data Persistence Pattern
All addon state uses three main SavedVariables (defined in .toc):
- `WoWToolsSave` - Primary settings table (keyed by module name: `WoWToolsSave['ChatButton']`, `WoWToolsSave['Other_VoiceTalking']`)
- `WoWTools_WoWDate` - Character-specific data (indexed by GUID, per-character storage)
- `WoWTools_PlayerDate` - Player-specific state

**Access pattern**: Modules define a `Save()` function returning `WoWToolsSave['ModuleName'] or {}`

### Mixin System Architecture
The addon heavily uses Lua mixins for code organization:

**Global Mixins** (loaded in 1_Mixin/):
- `WoWTools_DataMixin` - Core data management (Hook, Call, Load)
- `WoWTools_ButtonMixin` - Button creation & styling (AddMask, Cbtn)
- `WoWTools_FrameMixin` - Frame utilities (IsLocked, IsInSchermo)
- `WoWTools_MenuMixin` - Context menu handling
- `WoWTools_ChatMixin` - Chat button management

**Module-specific Mixins**: Plus/Tools modules extend base mixins (e.g., `WoWTools_BagMixin:GetItem_WoW_Num()`)

### Button/UI Creation Pattern
Buttons use a declarative table format passed to `Cbtn()` or `CreateMenu()`:
```lua
local btn = Cbtn(parent, {
    name = 'MyButtonName',
    size = 24,
    template = 'ItemButton',
    tooltip = 'Button tooltip text',
    texture = 'Interface\\Icons\\...',
    OnClick = function(self) end,
})
```

Menus use `AnchorMenuTab` for positioning (TOPLEFT, BOTTOMLEFT, etc.) with corresponding `AnchorTooltip` settings.

### Event Handling & Hooks Pattern
Use `WoWTools_DataMixin:Hook()` for secure function hooking:
```lua
WoWTools_DataMixin:Hook(btnObj, 'OnMenuOpened', function(self)
    self:SetButtonState('PUSHED')
end)
```

This wraps `hooksecurefunc` with error handling for protected/forbidden objects.

## Critical Developer Workflows

### Adding a New Module
1. Create `Plus_NewFeature/` or `Tools_NewFeature/` directory
2. Create `1_Init.lua` with initialization logic
3. Add to `WoWTools.toc` in load order (after 0_Data/1_Mixin)
4. Implement `Save()` function pattern returning module settings
5. Register settings options in module initialization

### Working with Protected Code
Use `WoWTools_DataMixin:Hook()` instead of direct `hooksecurefunc`:
- Automatically handles `IsForbidden()` checks
- Falls back to `hooksecurefunc` for non-protected code
- Logs warnings if user is `Player.husandro` (debugging)

### Loading Game Data Asynchronously
Use `WoWTools_DataMixin:Load(id, loadType)` for:
- `'quest'` - Quest data via `C_QuestLog.RequestLoadQuestByID()`
- `'spell'` - Spell data via `C_Spell.RequestLoadSpellData()`
- `'item'` - Item data via `C_Item.RequestLoadItemDataByID()`
- `'challengeMap'` - M+ data via `C_ChallengeMode.RequestLeaders()`

## Code Conventions

### Naming
- **Global tables**: `WoWTools_[Category]Mixin` or `WoWTools_[Feature]`
- **Local functions**: `PascalCase` for framework functions, `snake_case` for helpers
- **Settings**: `WoWToolsSave['ModuleKey']` with kebab-case module names
- **Methods**: Lua object methods use `:` notation in definitions and calls

### Localization
- `LOCALE_zhCN` - Detect Chinese locale
- `onlyChinese = LOCALE_zhCN and true or false` - Set in DataMixin
- Use ternary for locale-specific logic

### UI Styling
- **Masks**: Use `UI-HUD-CoolDownManager-Mask` (square) or `TempPortraitAlphaMask` (circular)
- **Button templates**: DropdownButton (23px), ItemButton (36px), CheckButton (26px)
- **Colors**: Use `GetClassColor(baseClass)` returning `r, g, b, hex`

### Protected Code & Combat Lockdown
Check before modifying protected frames:
```lua
local isProtected, isExplicit = frame:IsProtected()
local disabled = isProtected and InCombatLockdown()
if disabled then return end  -- Can't modify in combat
```

## Integration Points

### WoW API Dependencies
- **Retail/Classic version branching**: Use `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE` checks
- **LibStub libraries**: LibDataBroker for minimap integration, LibRangeCheck for distance checking
- **C_* namespaced APIs**: Modern WoW API (UI, Spell, Item, QuestLog, etc.)

### Cross-Module Communication
- **No direct dependencies** between modules (use global WoWToolsSave)
- **Event-based**: Use WoW EventRegistry for inter-module communication
- **Callback pattern**: Modules register callbacks to core DataMixin

## File Naming Conventions
- **0_** prefix - Must load first
- **z_** prefix - Load last within directory
- **1_, 2_, 3_** prefix - Load order priority
- Numbers ensure deterministic load order without alphabetical reliance

## Quick Reference: Key Files
- `0_Data/1_DataMixin.lua` - Core globals, player metadata
- `1_Mixin/Button.lua` - Button creation/styling utilities
- `1_Mixin/Frame.lua` - Frame management (locking, visibility)
- `1_Mixin/Menu.lua` - Context menu building
- `ChatButton/2_Buttons.lua` - Chat button button creation pattern
- `.toc` file - Authoritative load order (source of truth)
