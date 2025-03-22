
--属性，增强 PaperDollFrame.lua
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end
local Button







local function Init_Button()
    if Button or Save().hide then
        if Button then
            Button:SetShown(not Save().hide)
        end
        return
    end

    --CharacterStatsPane
--显示/隐藏装备管理框选项
    Button= WoWTools_ButtonMixin:Menu(PaperDollFrame, {
        size=20,
        name='WoWTools_PlsuPaperDollStatusButton',
        icon='hide',
    })
    WoWTools_PaperDollMixin.StatusPlusButton= Button

    Button:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -22, 0)
    Button:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    Button:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    function Button:set_alpha(min)
        self:SetAlpha(min and 0.3 or 1)
    end
    function Button:set_texture()
        self:SetNormalAtlas(
            Save().notStatusPlus
            and WoWTools_DataMixin.Icon.disabled
            or 'loottoast-arrow-orange')
    end


    function Button:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_PaperDollMixin.addName, self.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
        self:set_alpha(false)
    end
    Button:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:set_alpha(true)
    end)
    Button:SetScript('OnEnter', Button.set_tooltips)

    Button:set_texture()
    Button:set_alpha(true)



    function Button:set_enabel_disable()
        Save().notStatusPlus= not Save().notStatusPlus and true or nil
        self:set_texture()
        --print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().notStatusPlus), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end

    Button.addName= '|A:loottoast-arrow-orange:0:0|a'..(WoWTools_Mixin.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES)

    if Save().notStatusPlus then
        Button:SetupMenu(function(self, root)
            local sub= root:CreateCheckbox(
                WoWTools_Mixin.onlyChinese and '启用' or ENABLE,
            function()
                return not Save().notStatusPlus
            end, function ()
                self:set_enabel_disable()
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(self.addName)
                tooltip:AddLine(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
--/reload
            WoWTools_MenuMixin:Reload(sub)

            root:CreateDivider()
--打开选项界面
            WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName,})
        end)
    else

        if Save().PAPERDOLL_STATCATEGORIES then--加载，数据
            PAPERDOLL_STATCATEGORIES= Save().PAPERDOLL_STATCATEGORIES
        end
        WoWTools_PaperDollMixin:Init_Status_Func()
        WoWTools_PaperDollMixin:Init_AttributesCategory_Menu()
        WoWTools_PaperDollMixin:Init_Status_Menu(Button)
    end


end







--属性，增强 PaperDollFrame.lua
function WoWTools_PaperDollMixin:Init_Status_Plus()
    Init_Button()

end
