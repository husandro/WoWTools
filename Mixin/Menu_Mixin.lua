--[[
CreateSlider(root, tab)
Scale(root, GetValue, SetValue, checkGetValue, checkSetValue)
ShowBackground(root, GetValue, SetValue)
FrameStrata(root, GetValue, SetValue)
RestPoint(root, point, SetValue)
RestData(root, name, SetValue)
Reload(root, isControlKeyDown)
ToTop(root, tab)
OpenJournal(root, tab)
OpenSpellBook(root, tab)--天赋和法术书
OpenDragonriding(root)
SetNumButton(sub, num)
SetScrollButton(root, maxCharacters)

GetDragonriding()
]]

local e= select(2, ...)
WoWTools_MenuMixin={
    maxMenuButton=35,
}

function WoWTools_MenuMixin:CreateSlider(root, tab)
    local sub=root:CreateTemplate("OptionsSliderTemplate")
    sub:SetTooltip(tab.tooltip)
    sub:SetData(tab)

    sub:AddInitializer(function(f, desc)--, description, menu)
        f.getValue=desc.data.getValue
        f.setValue=desc.data.setValue
        f.minValue=desc.data.minValue or 0
        f.maxValue=desc.data.maxValue or 100
        f.step=desc.data.step or 1
        f.bit=desc.data.bit

        local va= desc.data.getValue() or 1
        f:SetValueStep(f.step or 1)
        f:SetMinMaxValues(f.minValue, f.maxValue)
        f:SetValue(va)

        f.Text:ClearAllPoints()
        f.Text:SetPoint('TOPRIGHT', 0,6)
        f.Text:SetText(va or 1)

        f.High:SetText(desc.data.name or '')
        f.Low:SetText('')

        f:SetScript('OnValueChanged', function(s, value)
            if s.bit then
                value= tonumber(format(s.bit, value))
            else
                value= math.ceil(value)
            end
            s.setValue(value)
            s.Text:SetText(value)
        end)

        f:EnableMouseWheel(true)
        f:SetScript('OnMouseWheel', function(s, d)
            local value= s.getValue()
            if d== 1 then
                value= value- s.step
            elseif d==-1 then
                value= value+ s.step
            end
            value= value> s.maxValue and s.maxValue or value
            value= value< s.minValue and s.minValue or value
            s:SetValue(value)
        end)
        f:SetScript('OnHide', function(s)
            s.SetValue=nil
            s.minValue=nil
            s.maxValue=nil
            s.step=nil
            s.bit=nil
            f:SetScript('OnMouseWheel', nil)
            f:SetScript('OnValueChanged', nil)
        end)
    end)
    return sub
end
--[[
sub2:CreateSpacer()
WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save.mountShowTime
    end, setValue=function(value)
        Save.mountShowTime=value
    end,
    name=e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
    minValue=1,
    maxValue=10,
    step=1,
    bit=nil,
    tooltip=function(tooltip)
        tooltip:AddLine(e.onlyChinese and '间隔' or 'Interval')
    end
})
sub2:CreateSpacer()
]]


--缩放
function WoWTools_MenuMixin:Scale(root, GetValue, SetValue, checkGetValue, checkSetValue)
    local sub
    if checkGetValue and checkSetValue then
        sub= root:CreateCheckbox(e.onlyChinese and '缩放' or UI_SCALE, checkGetValue, checkSetValue)
    else
        sub= root:CreateButton(e.onlyChinese and '缩放' or UI_SCALE, function()
            return MenuResponse.Open
        end)
    end

    local sub2=self:CreateSlider(sub, {
        getValue=GetValue,
        setValue=SetValue,
        name=nil,
        minValue=0.4,
        maxValue=4,
        step=0.05,
        bit='%0.2f',
        tooltip=function(tooltip)
            tooltip:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, UnitAffectingCombat('player') and ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)))
        end
    })

    return sub2, sub
end
--[[
WoWTools_MenuMixin:Scale(root, function()
    return Save.scale
end, function(value)
    Save.scale= value
    self:set_scale()
end)
]]





--FrameStrata
function WoWTools_MenuMixin:FrameStrata(root, GetValue, SetValue)
    local sub=root:CreateButton('FrameStrata', function() return MenuResponse.Open end)

    for _, strata in pairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        sub:CreateCheckbox((strata=='MEDIUM' and '|cnGREEN_FONT_COLOR:' or '')..strata, GetValue, SetValue, strata)
    end
    return sub
end
--[[
sub2=select(2, WoWTools_MenuMixin:FrameStrata(sub, function(data)
    return self:GetFrameStrata()==data
end, function(data)
    Save.strata= data
    self:set_strata()
end))
if isInCombat then
    sub2:SetEnabled(false)
end
]]



--显示背景
function WoWTools_MenuMixin:ShowBackground(root, GetValue, SetValue)
    return root:CreateCheckbox(
        '|A:MonkUI-LightOrb:0:0|a'
        ..(e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND),
        GetValue,
        SetValue)
end
--[[
--显示背景
WoWTools_MenuMixin:ShowBackground(sub,
function()
end, function()
end)
]]




--重置位置
function WoWTools_MenuMixin:RestPoint(root, point, SetValue)
    return root:CreateButton((point and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), SetValue)
end


--重置数据
function WoWTools_MenuMixin:RestData(root, name, SetValue)
    return root:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT), function(data)

        StaticPopup_Show('WoWTools_RestData',data.name, nil, data.SetValue)
        return MenuResponse.Open
    end, {name=name, SetValue=SetValue})
end

--重新加载UI
function WoWTools_MenuMixin:Reload(root, isControlKeyDown)
    local sub=root:CreateButton(
        '|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t'
        ..((UnitAffectingCombat('player') or e.IsEncouter_Start) and IsInInstance() and '|cff9e9e9e' or '')
        ..(e.onlyChinese and '重新加载UI' or RELOADUI),
    function(data)
        if data and IsControlKeyDown() or not data then
            e.Reload()
        end
    end, isControlKeyDown)
    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(SLASH_RELOAD1, desc.data and '|cnGREEN_FONT_COLOR:Ctrl+|r'..e.Icon.left)
    end)
    return sub
end









--位于上方
function WoWTools_MenuMixin:ToTop(root, tab)
    local sub=root:CreateCheckbox(
        (tab.name or (
            '|A:editmode-up-arrow:16:11:0:3|a'..(e.onlyChinese and '位于上方' or QUESTLINE_LOCATED_ABOVE))),
        tab.GetValue,
        tab.SetValue,
        tab
    )
    sub:SetTooltip(function(tooltip, data)
        tooltip:AddLine(
            data.tooltip or
            (e.onlyChinese and '收起选项 |A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
        )
        if data.isReload then
            tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    end)
    if tab.isReload then--重新加载UI
        WoWTools_MenuMixin:Reload(sub)--重新加载UI
    end
end
--[[
WoWTools_MenuMixin:ToTop(root, {--位于上方
    name=nil,
    GetValue=function()
        return Save.toFrame
    end,
    SetValue=function()
        Save.toFrame = not Save.toFrame and true or nil
    end,
    tooltip=nil,
    isReload=true,--重新加载UI
})
]]














--战团藏品
function WoWTools_MenuMixin:OpenJournal(root, tab)
    local sub=root:CreateButton(
        (tab.icon or '|A:common-icon-zoomin:0:0|a')..(tab.name or (e.onlyChinese and '战团藏品' or COLLECTIONS)),
    function(data)
        if SettingsPanel:IsShown() then--ToggleGameMenu()
            SettingsPanel:Close()
        end
        WoWTools_LoadUIMixin:Journal(data.index)

        if data.moutID then
            local name= C_MountJournal.GetMountInfoByID(data.moutID)
            if name then
                MountJournalSearchBox:SetText(name)
            end
        end

        return MenuResponse.Open
    end, tab)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
    end)
end
--[[
WoWTools_MenuMixin:OpenJournal(root, {--战团藏品
    name=,
    index=1,
    moutID=mountID,
})
]]



--PlayerSpellsUtil.lua
function WoWTools_MenuMixin:OpenSpellBook(root, tab)--天赋和法术书
    local sub=root:CreateButton(
        tab.name or ('|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '天赋和法术书' or PLAYERSPELLS_BUTTON)),
    function(data)
        if SettingsPanel:IsShown() then--ToggleGameMenu()
            SettingsPanel:Close()
        end
        if tab.index== PlayerSpellsUtil.FrameTabs.ClassSpecializations then--1
            PlayerSpellsUtil.OpenToClassSpecializationsTab()

        elseif tab.index== PlayerSpellsUtil.FrameTabs.ClassTalents then--2
            PlayerSpellsUtil.OpenToClassTalentsTab()

        elseif tab.index== PlayerSpellsUtil.FrameTabs.SpellBook then--3
            if data.spellBookCategory then
                PlayerSpellsUtil:OpenToSpellBookTabAtCategory(data.spellBookCategory)
            end

            if tab.spellID then
                PlayerSpellsUtil.OpenToSpellBookTabAtSpell(data.spellID)-- PlayerSpellsUtil.OpenToSpellBookTabAtSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
            else
                PlayerSpellsUtil.OpenToSpellBookTab()
            end
        end

        return MenuResponse.Open
    end, tab)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '天赋和法术书' or PLAYERSPELLS_BUTTON, "TOGGLETALENTS"))
    end)
end



--驭空术，return 名称，点数
function WoWTools_MenuMixin:GetDragonriding()
    local dragonridingConfigID = C_Traits.GetConfigIDBySystemID(1);
    if dragonridingConfigID then
        local treeCurrencies = C_Traits.GetTreeCurrencyInfo(dragonridingConfigID, 672, false) or {}
        local num= treeCurrencies[1] and treeCurrencies[1].quantity
        if num and num>=0 then
            return '|T'..(select(4, C_Traits.GetTraitCurrencyInfo(2563)) or 4728198)..':0|t'
                ..(num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..num..'|r',

                num
        end
    end

end

--驭空术
function WoWTools_MenuMixin:OpenDragonriding(root)
    local configID = C_Traits.GetConfigIDByTreeID(Constants.MountDynamicFlightConsts.TREE_ID);
    local uiWidgetSetID = configID and C_Traits.GetTraitSystemWidgetSetID(configID) or nil

    local sub= root:CreateButton(
            '|A:dragonriding-barbershop-icon-protodrake:0:0|a'
            ..(UnitAffectingCombat('player') and '|cff9e9e9e' or '')
            ..(e.onlyChinese and '驭空术' or GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE)
            ..(self:GetDragonriding() or ''),
        function()
            WoWTools_LoadUIMixin:GenericTraitUI(--加载，Trait，UI
                Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID,
                Constants.MountDynamicFlightConsts.TREE_ID
            )
            return MenuResponse.Open
        end,
        {widgetSetID=uiWidgetSetID, tooltip=e.onlyChinese and '巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TITLE}
    )
    WoWTools_TooltipMixin:SetTooltip(nil, nil, sub)--设置，物品，提示

    return sub
end



--SetGridMode
function WoWTools_MenuMixin:SetNumButton(sub, num)
    if num and num>self.maxMenuButton then
        sub:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(num/self.maxMenuButton))
    end
end

function WoWTools_MenuMixin:SetScrollButton(root, maxCharacters)
   root:SetScrollMode(20 * (maxCharacters or self.maxMenuButton))
end

