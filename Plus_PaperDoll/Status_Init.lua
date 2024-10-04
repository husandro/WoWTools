
--属性，增强 PaperDollFrame.lua
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end
local StatusPlusButton







local function Init_Button()
    if StatusPlusButton or Save().hide then
        if StatusPlusButton then
            StatusPlusButton:SetShown(not Save().hide)
        end
        return
    end

    --CharacterStatsPane
    --StatusPlusButton= WoWTools_ButtonMixin:Cbtn(PaperDollFrame, {size={20,20}, icon='hide'})--显示/隐藏装备管理框选项
    StatusPlusButton= WoWTools_ButtonMixin:CreateMenu(PaperDollFrame, {size=20, name='WoWTools_PlsuPaperDollStatusButton', hideIcon=true})

    StatusPlusButton:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -22, 0)
    StatusPlusButton:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    StatusPlusButton:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    function StatusPlusButton:set_alpha(min)
        self:SetAlpha(min and 0.3 or 1)
    end
    function StatusPlusButton:set_texture()
        self:SetNormalAtlas(
            Save().notStatusPlus
            and e.Icon.disabled
            or format('charactercreate-gendericon-%s-selected', e.Player.sex==3 and 'Female' or 'male'))
    end

    function StatusPlusButton:show_menu()
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 40, 0)--主菜单
    end
    function StatusPlusButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_TOPLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        e.tips:Show()
        self:set_alpha(false)
    end
    StatusPlusButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:set_alpha(true)
    end)
    StatusPlusButton:SetScript('OnEnter', StatusPlusButton.set_tooltips)

    StatusPlusButton.Menu= CreateFrame("Frame", nil, StatusPlusButton, "UIDropDownMenuTemplate")

    StatusPlusButton:SetScript("OnClick", StatusPlusButton.show_menu)

    StatusPlusButton:set_texture()
    StatusPlusButton:set_alpha(true)



    function StatusPlusButton:set_enabel_disable()
        Save().notStatusPlus= not Save().notStatusPlus and true or nil
        self:set_texture()
        --print(e.addName, WoWTools_PaperDollMixin.addName, e.GetEnabeleDisable(not Save().notStatusPlus), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end

    StatusPlusButton.addName= '|A:loottoast-arrow-orange:0:0|a'..(e.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES)

    if Save().notStatusPlus then
        StatusPlusButton:SetupMenu(function(self, root)
            local sub= root:CreateCheckbox(
                e.onlyChinese and '启用' or ENABLE,
            function()
                return not Save().notStatusPlus
            end, function ()
                self:set_enabel_disable()
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            root:CreateDivider()
            root:CreateTitle(self.addName)
--打开选项界面
            WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName,})
            root:CreateDivider()
            WoWTools_MenuMixin:Reload(root)
        end)
    else

        if Save().PAPERDOLL_STATCATEGORIES then--加载，数据
            PAPERDOLL_STATCATEGORIES= Save().PAPERDOLL_STATCATEGORIES
        end
        WoWTools_PaperDollMixin:Init_Status_Func()
        WoWTools_PaperDollMixin:Init_AttributesCategory_Menu()
        WoWTools_PaperDollMixin:Init_Status_Menu(StatusPlusButton)
    end


end







--属性，增强 PaperDollFrame.lua
function WoWTools_PaperDollMixin:Init_Status_Plus()
    Init_Button()

end
