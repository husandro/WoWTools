--[[
GameTooltip_AddQuest(self, questIDArg)
local questID = self.questID or questIDArg;

GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
GameTooltip_AddInstructionLine(tooltip, "Test Tooltip Instruction");
GameTooltip_AddNormalLine(tooltip, "Test Tooltip Normal Line");
GameTooltip_AddErrorLine(tooltip, "Test Tooltip Colored Line");
GameTooltip_AddBlankLineToTooltip(tooltip);

SharedTooltipTemplates.lua
securecallfunction(GameTooltip_AddQuest, self, questID)
GameTooltip_SetDefaultAnchor(GameTooltip, self);
GameTooltip_Hide()
GameTooltip_AddColoredLine(GameTooltip, '', NORMAL_FONT_COLOR, true);

BattlePetToolTip_ShowLink(itemKeyInfo.battlePetLink);


GetMouseFocus() == self
GameTooltip:GetOwner()
if GameTooltip:IsOwned(self) then
	button:GetScript("OnEnter")(self);
end

]]
