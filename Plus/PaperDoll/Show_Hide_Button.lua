--显示，隐藏，按钮
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end



















local function Settings()
    WoWTools_PaperDollMixin:Set_Duration()--装备, 总耐久度
    WoWTools_PaperDollMixin:Init_ServerInfo()--显示服务器名称
    WoWTools_PaperDollMixin:Settings_Tab2()--头衔数量
    WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    WoWTools_PaperDollMixin:Settings_Tab3()--标签, 内容,提示

    WoWTools_PaperDollMixin:TrackButton_Settings()--添加装备管理框

    WoWTools_PaperDollMixin:Init_Status_Plus()--属性，增强

    WoWTools_DataMixin:Call('PaperDollFrame_SetLevel')
    WoWTools_DataMixin:Call('PaperDollFrame_UpdateStats')

    for _, slot in pairs(WoWTools_PaperDollMixin.ItemButtons) do
        local btn2= _G[slot]
        if btn2 then
            WoWTools_DataMixin:Call('PaperDollItemSlotButton_Update', btn2)
        end
    end

    if InspectFrame and InspectLevelText.set_font_size then
        InspectLevelText:set_font_size()
        InspectFrame:set_status_label()--目标，属性
        InspectFrame.ShowHideButton:settings()
        if InspectFrame:IsShown() then
            WoWTools_DataMixin:Call('InspectPaperDollFrame_UpdateButtons')--InspectPaperDollFrame.lua
            WoWTools_DataMixin:Call('InspectPaperDollFrame_SetLevel')--目标,天赋 装等
        end
    end
    PaperDollItemsFrame.ShowHideButton:settings()
end











local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
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

    local btn= WoWTools_ButtonMixin:Menu(frame, {size=22, icon='hide'})
    btn:SetPoint('LEFT', title, 0,-2)
    btn:SetFrameStrata(title:GetFrameStrata())
    btn:SetFrameLevel(title:GetFrameLevel()+1)

    btn:SetupMenu(Init_Menu)

    function btn:settings()
        self:SetAlpha(self:IsMouseOver() and 1 or 0.3)
        if Save().hide then
            self:SetNormalAtlas('talents-button-reset')
        else
            self:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        end
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:settings()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_PaperDollMixin.addName)

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)

        GameTooltip:Show()
        self:settings()
    end)
    btn:settings()

    frame.ShowHideButton= btn
end













function WoWTools_PaperDollMixin:Init_ShowHideButton(frame)
    Init(frame)
end
