--显示，隐藏，按钮
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end








local Slot = {
    [1]	 = "CharacterHeadSlot",
    [2]	 = "CharacterNeckSlot",
    [3]	 = "CharacterShoulderSlot",
    [4]	 = "CharacterShirtSlot",
    [5]	 = "CharacterChestSlot",
    [6]	 = "CharacterWaistSlot",
    [7]	 = "CharacterLegsSlot",
    [8]	 = "CharacterFeetSlot",
    [9]	 = "CharacterWristSlot",
    [10] = "CharacterHandsSlot",
    [11] = "CharacterFinger0Slot",
    [12] = "CharacterFinger1Slot",
    [13] = "CharacterTrinket0Slot",
    [14] = "CharacterTrinket1Slot",
    [15] = "CharacterBackSlot",
    [16] = "CharacterMainHandSlot",
    [17] = "CharacterSecondaryHandSlot",
}











local function Settings()
    WoWTools_PaperDollMixin:Set_Duration()--装备, 总耐久度
    WoWTools_PaperDollMixin:Settings_ServerInfo()--显示服务器名称
    WoWTools_PaperDollMixin:Settings_Tab2()--头衔数量
    WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    WoWTools_PaperDollMixin:Settings_Tab3()--标签, 内容,提示

    WoWTools_PaperDollMixin:TrackButton_Settings()--添加装备管理框

    WoWTools_PaperDollMixin:Init_Status_Plus()--属性，增强

    WoWTools_Mixin:Call(PaperDollFrame_SetLevel)
    WoWTools_Mixin:Call(PaperDollFrame_UpdateStats)

    for _, slot in pairs(Slot) do
        local btn2= _G[slot]
        if btn2 then
            WoWTools_Mixin:Call(PaperDollItemSlotButton_Update, btn2)
        end
    end

    if InspectFrame then
        InspectLevelText:set_font_size()
        InspectFrame:set_status_label()--目标，属性
        InspectFrame.ShowHideButton:SetNormalAtlas(Save().hide and WoWTools_DataMixin.Icon.disabled or WoWTools_DataMixin.Icon.icon)
        if InspectFrame:IsShown() then
            WoWTools_Mixin:Call(InspectPaperDollFrame_UpdateButtons)--InspectPaperDollFrame.lua
            WoWTools_Mixin:Call(InspectPaperDollFrame_SetLevel)--目标,天赋 装等
        end
    end
    PaperDollItemsFrame.ShowHideButton:SetNormalAtlas(Save().hide and WoWTools_DataMixin.Icon.disabled or WoWTools_DataMixin.Icon.icon)
end











local function Init_Menu(_, root)
    root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '启用' or ENABLE,
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        Settings()
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName})
end








local function Init(frame)
    if not frame or frame.ShowHideButton then
        return
    end

    local title= frame==PaperDollItemsFrame and CharacterFrame.TitleContainer or frame.TitleContainer

    local btn= WoWTools_ButtonMixin:Cbtn(frame, {size=22, atlas= not Save().hide and WoWTools_DataMixin.Icon.icon or WoWTools_DataMixin.Icon.disabled})
    btn:SetPoint('LEFT', title)
    btn:SetFrameStrata(title:GetFrameStrata())
    btn:SetFrameLevel(title:GetFrameLevel()+1)

    btn:SetScript('OnClick', function(self, d)
        MenuUtil.CreateContextMenu(self, Init_Menu)

        --[[if d=='RightButton' then
            WoWTools_PanelMixin:Open(nil, WoWTools_PaperDollMixin.addName)
        else
            Save().hide= not Save().hide and true or nil
            Settings()
        end]]
    end)
    function btn:set_alpha(isEnter)
        if isEnter then
            self:SetAlpha(1)
        else
            self:SetAlpha(0.5)
        end
    end
    btn:set_alpha(false)

    btn:SetScript('OnLeave', function(self) GameTooltip_Hide() self:set_alpha(false) end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_PaperDollMixin.addName)
        
        --GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(not Save().hide), WoWTools_DataMixin.Icon.left)

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        --GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '选项' or SETTINGS_TITLE, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:set_alpha(true)
    end)

    frame.ShowHideButton= btn
end













function WoWTools_PaperDollMixin:Init_ShowHideButton(frame)
    Init(frame)
end
