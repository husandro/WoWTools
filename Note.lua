--[[
BACKGROUND
BORDER
ARTWORK
OVERLAY
DRAG_MODEL拖曳
QUEST_DASH 任务 -
RANGE_INDICATOR = "●"

UIPanelWindows[]

GetClassColoredTextForUnit(unit, text)
FrameUtil.RegisterFrameForEvents(self, table);
FrameUtil.UnregisterFrameForEvents(self, table);
SetPortraitTexture(textureObject, unitToken [, disableMasking])
SetPortraitToTexture(textureObject, texturePath)
Region:SetVertexColor(colorR, colorG, colorB [, a])
... = securecall(func or functionName, ...)
frame:SetFrameLevel(self:GetFrameLevel() + 5);
UnitPopupSharedMenus.lua
UnitHasVehiclePlayerFrameUI("player")

EditModeManagerFrame:IsEditModeActive()
EditModeManagerFrame:UseRaidStylePartyFrames()

local item = Item:CreateFromItemLink(outputItemInfo.hyperlink)
quality = item:GetItemQuality()

if IsModifiedClick("CHATLINK") then
    local spellLink = GetSpellLink(self:GetSpellID());
    ChatEdit_InsertLink(spellLink);
end

SetItemButtonTextureVertexColor(button, 1.0, 1.0, 1.0);
SetItemButtonNormalTextureVertexColor(button, 1.0, 1.0, 1.0);

Day={0.10, 0.72, 1},--日常 |cff19b7ff  任务颜色
Week={0.02, 1, 0.66},--周长 |cff05ffa8
Legendary={1, 0.49, 0},--传说 |cffff7c00
Calling={1, 0, 0.9},--使命 |cffff00e5

LOCALE_enUS  1  
LOCALE_koKR  2  
LOCALE_frFR  3  
LOCALE_deDE  4  
LOCALE_zhCN  5  
LOCALE_esES  6  
LOCALE_zhTW  7  
LOCALE_esMX  8
LOCALE_ruRU  9
LOCALE_ptBR  10
LOCALE_itIT  11

StaticPopupDialogs
https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

local hasPetUI, isHunterPet = HasPetUI();
Frame:DisableDrawLayer('BACKGROUND')

fileID = GetFileIDFromPath(filePath)--检查,自定义,文件是否存在

InterfaceOptionsFrame_OpenToCategory(id)
CharacterFrameTab_OnClick (self, button)
if ( name == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
elseif ( name == "CharacterFrameTab2" ) then
		ToggleCharacter("ReputationFrame");
elseif ( name == "CharacterFrameTab3" ) then
		CharacterFrame_ToggleTokenFrame();
end
ToggleCollectionsJournal(tabIndex) UIParent.lua

ToggleEncounterJournal()
]]