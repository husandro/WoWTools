--[[
CreateSlider(root, tab)
ScaleRoot
ScaleCheck
Scale(root, GetValue, SetValue, checkGetValue, checkSetValue)

ShowBackground(root, GetValue, SetValue)
FrameStrata(root, GetValue, SetValue)
RestPoint(root, point, SetValue)
RestData(root, name, SetValue)
Reload(root, isControlKeyDown)

ClearAll()
ToTop(root, tab)

CheckInCombat()

OpenJournal(root, tab)
OpenSpellBook(root, tab)--天赋和法术书
OpenDragonriding(root)
OpenOptions(root, tab)

SetNumButton(sub, num)
SetScrollButton(root, maxCharacters)



GetDragonriding()
]]

local e= select(2, ...)
WoWTools_MenuMixin={
    maxMenuButton=35,
}

function WoWTools_MenuMixin:CloseSettingsPanel()
    if SettingsPanel and SettingsPanel:IsShown() then
        SettingsPanel:Close()
    end
end






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
            local value= s.getValue() or 1
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
            f.getValue=nil
            f.setValue=nil
            f.minValue=nil
            f.maxValue=nil
            f.step=nil
            f.bit=nil
            f:SetScript('OnMouseWheel', nil)
            f:SetScript('OnValueChanged', nil)
        end)
    end)
    return sub
end
--[[
sub:CreateSpacer()
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
sub:CreateSpacer()
]]





--缩放, 单行
function WoWTools_MenuMixin:ScaleRoot(root, GetValue, SetValue)
    root:CreateSpacer()
    local sub= self:CreateSlider(root, {
        getValue=GetValue,
        setValue=SetValue,
        name=nil,
        minValue=0.4,
        maxValue=4,
        step=0.05,
        bit='%0.2f',
        tooltip=function(tooltip)
            tooltip:AddDoubleLine(
                e.onlyChinese and '缩放' or UI_SCALE,

                UnitAffectingCombat('player')
                and ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            )
        end
    })
    root:CreateSpacer()

    root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'..(e.onlyChinese and '重置' or RESET),
    function(data)
        if data.setValue then
            data.setValue(1)
        end
        return MenuResponse.Open
    end, {setValue=SetValue})

    return sub
end




--缩放, 加check
function WoWTools_MenuMixin:ScaleCheck(root, GetValue, SetValue, checkGetValue, checkSetValue)
    local sub= root:CreateCheckbox('|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE), checkGetValue, checkSetValue)

    local sub2= self:ScaleRoot(sub, GetValue, SetValue)

    return sub2, sub
end


--缩放
function WoWTools_MenuMixin:Scale(root, GetValue, SetValue)
    local sub= root:CreateButton('|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE), function()
        return MenuResponse.Open
    end)

    local sub2= self:ScaleRoot(sub, GetValue, SetValue)
    return sub2, sub
end
--[[
--缩放
WoWTools_MenuMixin:Scale(root, function()
    return Save.scale
end, function(value)
    Save.scale= value
    self:set_scale()
end)
]]





--FrameStrata
function WoWTools_MenuMixin:FrameStrata(root, GetValue, SetValue)
    local sub=root:CreateButton('|A:Garr_SwapIcon:0:0:|a'..(e.onlyChinese and '框架层' or 'Strata'), function()
        return MenuResponse.Open
    end)

    for _, strata in pairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        sub:CreateCheckbox(
            (strata=='MEDIUM' and '|cnGREEN_FONT_COLOR:' or '')..strata,
            GetValue,
            SetValue,
            strata
        )
    end
    return sub
end
--[[
--FrameStrata
sub2=WoWTools_MenuMixin:FrameStrata(sub, function(data)
    return self:GetFrameStrata()==data
end, function(data)
    Save.strata= data
    self:set_strata()
end)
sub2:SetEnabled(not isInCombat)


--FrameStrata
    function TrackButton:set_strata()
        local strata= Save().trackButtonStrata
        if strata then
            self:SetFrameStrata(strata)
        end
    end
    TrackButton:set_strata()
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
    --root:CreateDivider()
    return root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'
        ..(point and '' or '|cff9e9e9e')
        ..(e.onlyChinese and '重置位置' or RESET_POSITION),
        SetValue
    )
end
--[[
--重置位置
WoWTools_MenuMixin:RestPoint(sub, Save().point, function()
    Save().point=nil
    self:ClearAllPoints()
    self:set_point()
end)
]]


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
            WoWTools_Mixin:Reload()
        end
    end, isControlKeyDown)
    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(SLASH_RELOAD1, desc.data and '|cnGREEN_FONT_COLOR:Ctrl+|r'..e.Icon.left)
    end)
    return sub
end
--[[
--重新加载UI
    WoWTools_MenuMixin:Reload(root)
]]








function WoWTools_MenuMixin:ToTop(root, tab)
    local sub=root:CreateCheckbox(
        (tab.name or (
            '|A:editmode-up-arrow:16:11:0:3|a'..(e.onlyChinese and '位于上方' or QUESTLINE_LOCATED_ABOVE))),
        tab.GetValue,
        tab.SetValue,
        {isReload=tab.isReload, tooltip=tab.tooltip}
    )
    sub:SetTooltip(function(tooltip, description)
        if description.data.tooltip~=false then
            tooltip:AddLine(
                description.data.tooltip or
                (e.onlyChinese and '收起选项 |A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
            )
        end
        if description.data.isReload then
            tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    end)
    if tab.isReload then--重新加载UI
        WoWTools_MenuMixin:Reload(sub)--重新加载UI
    end
end
--[[
--位于上方
WoWTools_MenuMixin:ToTop(root, {
    name=nil,
    GetValue=function()
        return Save.toFrame
    end,
    SetValue=function()
        Save.toFrame = not Save.toFrame and true or nil
    end,
    tooltip=false,
    isReload=true,--重新加载UI
})
]]







function WoWTools_MenuMixin:CheckInCombat(root)
    if UnitAffectingCombat('player') then
        return root:CreateTitle(
            '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'
            ..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        )
    end
end
--[[
--战斗中
    if WoWTools_MenuMixin:CheckInCombat() then
        return
    end
]]




--战团藏品
function WoWTools_MenuMixin:OpenJournal(root, tab)
    local sub=root:CreateButton(
        (tab.icon or '|A:OptionsIcon-Brown:0:0|a')..(tab.name or (e.onlyChinese and '战团藏品' or COLLECTIONS)),
    function(data)
        self:CloseSettingsPanel()
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
        tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '打开战团藏品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, COLLECTIONS), "TOGGLECOLLECTIONS"))
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
    WoWTools_SetTooltipMixin:Set_Menu(sub)

    return sub
end


function WoWTools_MenuMixin:OpenOptions(root, tab)
    tab= tab or {}

    local name= tab.name
    local name2= tab.name2
    local GetCategory= tab.GetCategory
    local category= tab.category

    local showText= name2 or name
    showText= showText and showText..'|A:OptionsIcon-Brown:0:0|a' or ('|A:OptionsIcon-Brown:0:0|a'..(e.onlyChinese and '选项' or OPTIONS))

    local sub=root:CreateButton(showText, function(data)
        if SettingsPanel:IsShown() then--ToggleGameMenu()
            SettingsPanel:Close()
        else
            do
                if not category and GetCategory then
                    category= GetCategory()
                end
            end
            e.OpenPanelOpting(category, name)
        end
        return MenuResponse.Open
    end, {name=name, name2=name2, GetCategory=GetCategory})

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddDoubleLine(description.data.name or e.addName, description.data.name2)
        tooltip:AddDoubleLine(
            e.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI')
        )
    end)
    return sub
end
--[[
--打开选项界面
WoWTools_MenuMixin:OpenOptions(root, {name=,})
WoWTools_MenuMixin:OpenOptions(root, {
name=,
name2=,
GetCategory=function()
end
})


]]






function WoWTools_MenuMixin:ClearAll(root, SetValue)
    local text= '|A:128-RedButton-Delete:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL)
    return
    
    root:CreateButton(
        text,
    function(data)
        StaticPopup_Show('WoWTools_RestData',data.name, nil, data.SetValue)
        return MenuResponse.Open
    end, {name=text, SetValue=SetValue})


    --root:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL), SetValue)
end
--[[
--全部清除
    WoWTools_MenuMixin:ClearAll(sub, function() end)
]]

function WoWTools_MenuMixin:SetGridMode(sub, num)
    if num and num>self.maxMenuButton then
        sub:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(num/self.maxMenuButton))
    end
end
--[[
--SetGridMode
WoWTools_MenuMixin:SetGridMode(sub, num)
]]

--SetScrollMode
function WoWTools_MenuMixin:SetScrollMode(root, maxCharacters)
   root:SetScrollMode(20 * (maxCharacters or self.maxMenuButton))
end

