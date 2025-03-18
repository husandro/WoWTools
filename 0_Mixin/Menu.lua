--[[
CreateSlider(root, tab)
ScaleRoot
ScaleCheck
Scale(

ShowTexture(root, GetValue, SetValue)
ShowBackground(root, GetValue, SetValue)
FrameStrata(root, GetValue, SetValue)
Color(root,OnClick, ColorInfo)
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
        f.Text:SetPoint('TOPRIGHT', 0,8)
        --f.Text:SetText('RIGHT')
        f.Text:SetText(va or 1)

        f.Low:ClearAllPoints()
        f.Low:SetPoint('TOPLEFT', 0, 8)
        f.Low:SetText(desc.data.name or '')

        f.High:SetText('')

        --[[if desc.data.isColor then
            f.High:SetTextColor(1,0,1)
            f.Text:SetTextColor(1,0,1)
        end]]

        f:SetScript('OnValueChanged', function(s, value,...)
            if s.bit then
                value= tonumber(format(s.bit, value))
            else
                value= math.ceil(value)
            end
            s.setValue(value, s)
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
            s:SetValue(value, s)
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
            f:SetScript('OnHide', nil)
        end)
    end)

    if tab.tooltip then
        sub:SetTooltip(tab.tooltip)
    --[[elseif tab.name and tab.name~='' then
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.name)
        end)]]
    end

    return sub
end
--[[
sub:CreateSpacer()
WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().mountShowTime
    end, setValue=function(value)
        Save().mountShowTime=value
    end,
    name=e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
    minValue=1,
    maxValue=10,
    step=1,
    bit='%.2f',
    tooltip=function(tooltip)
        tooltip:AddLine(e.onlyChinese and '间隔' or 'Interval')
    end
   
})
sub:CreateSpacer()
]]





--缩放, 单行
function WoWTools_MenuMixin:ScaleRoot(frame, root, GetValue, SetValue, ResetValue)
    local sub
    if  not frame:CanChangeAttribute() then
        sub=root:CreateButton('|cff828282'..e.onlyChinese and '缩放' or UI_SCALE,function() end)
        sub:SetEnabled(false)
        return
    end
    root:CreateSpacer()
    sub= self:CreateSlider(root, {
        getValue=GetValue,
        setValue=SetValue,
        name= nil,
        minValue=0.4,
        maxValue=4,
        step=0.05,
        bit='%0.2f',
        tooltip=function(tooltip) tooltip:AddLine(e.onlyChinese and '缩放' or UI_SCALE) end,
    })
    root:CreateSpacer()

    sub=root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'..(e.onlyChinese and '重置' or RESET),
    function(data)
        if data.setValue then
            data.setValue(1)
        end
        if data.resetValue then
            data.resetValue()
        end
        return MenuResponse.Refresh
    end, {setValue=SetValue, resetValue=ResetValue})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((e.onlyChinese and '缩放' or UI_SCALE)..': 1')
    end)

    return sub
end




--[[缩放, 加check
function WoWTools_MenuMixin:ScaleCheck(frame, root, GetValue, SetValue, ResetValue, checkGetValue, checkSetValue)
    local sub
    if not frame:CanChangeAttribute() then
        sub=root:CreateButton('|cff828282'..e.onlyChinese and '缩放' or UI_SCALE,function() end)
        sub:SetEnabled(false)
        return
    end
    sub= root:CreateCheckbox(
        '|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE),
        checkGetValue,
        checkSetValue,
        {checkGetValue=checkGetValue}
    )
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.GetEnabeleDisable(nil, true))
    end)

    local sub2= self:ScaleRoot(frame, sub, GetValue, SetValue, ResetValue)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.GetEnabeleDisable(nil, true))
    end)
    return sub2, sub
end]]


--缩放
function WoWTools_MenuMixin:Scale(frame, root, GetValue, SetValue, ResetValue)
    local sub
    if not frame:CanChangeAttribute() then
        sub=root:CreateButton('|cff828282'..e.onlyChinese and '缩放' or UI_SCALE, function() end)
        sub:SetEnabled(false)
        return
    end
    sub= root:CreateButton(
        '|A:common-icon-zoomin:0:0|a'
        ..(e.onlyChinese and '缩放' or UI_SCALE),
    function()
        return MenuResponse.Open
    end)

    local sub2= self:ScaleRoot(frame, sub, GetValue, SetValue, ResetValue)
    return sub, sub2
end
--[[
--缩放
WoWTools_MenuMixin:Scale(self, root, function()
    return Save.scale
end, function(value)
    Save.scale= value
    self:set_scale()
end)
]]
--[[
function WoWTools_MenuMixin:Color(root, text, onClick, colorInfo, data)
    return root:CreateColorSwatch(
        text,
        onClick or function()end,
        {
            r = colorInfo.r or e.Player.r,
            g = colorInfo.g or e.Player.g,
            b = colorInfo.b or e.Player.b,
            opacity = colorInfo.opacity or colorInfo.a or 1,
            swatchFunc = colorInfo.opacity or function()end,
            opacityFunc = colorInfo.opacityFunc or function()end,
            cancelFunc = colorInfo.cancelFunc or function()end,
            hasOpacity = (colorInfo.opacity or colorInfo.a) and true or false,
        },
        data
    )
end

--颜色选择器
WoWTools_MenuMixin:Color(root,
    text,
function()

end, {
    r= r,
    g= g,
    b= b,
    opacity= 1,
    swatchFunc= function()

    end,
    opacityFunc= function()

    end,
    cancelFunc= function()

    end,
})
]]



--FrameStrata
function WoWTools_MenuMixin:FrameStrata(root, GetValue, SetValue)
    local sub=root:CreateButton('|A:Garr_SwapIcon:0:0:|a'..(e.onlyChinese and '框架层' or 'Strata'), function()
        return MenuResponse.Refresh
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


--材质 WoWTools_MenuMixin:ShowTexture(
function WoWTools_MenuMixin:ShowTexture(root, GetValue, SetValue)
    return root:CreateCheckbox(
        '|A:AnimCreate_Icon_Texture:0:0|a'
        ..(e.onlyChinese and '材质' or TEXTURES_SUBHEADER),
        GetValue,
        SetValue)
end



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
function WoWTools_MenuMixin:RestPoint(frame, root, point, SetValue)
    local sub= root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'
        ..(point and '' or '|cff9e9e9e')
        ..(e.onlyChinese and '重置位置' or RESET_POSITION),
        SetValue
    )
    sub:SetEnabled(frame:CanChangeAttribute())
    return sub
end
--[[
--重置位置
WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
    Save().point=nil
    self:ClearAllPoints()
    self:set_point()
    return MenuResponse.Open
end)
]]


--重置数据
function WoWTools_MenuMixin:RestData(root, name, SetValue)
    return root:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT), function(data)

        StaticPopup_Show('WoWTools_RestData',data.name, nil, data.SetValue)
        return MenuResponse.Refresh
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
        (tab.name or ('|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION))),
        --('|A:editmode-up-arrow:16:11:0:3|a'..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP))),
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
    if InCombatLockdown() then
        if not root then
            return true
        else
            return root:CreateTitle(
                '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'
                ..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
            )
        end
    end
end
--[[
--战斗中
    if WoWTools_MenuMixin:CheckInCombat(root) then
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

        return MenuResponse.Refresh
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
            --[[if data.spellBookCategory then
                PlayerSpellsUtil:OpenToSpellBookTabAtCategory(data.spellBookCategory)
            end]]

            --if tab.spellID then--bug
                --PlayerSpellsUtil.OpenToSpellBookTabAtSpell(data.spellID)-- PlayerSpellsUtil.OpenToSpellBookTabAtSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
            --else
                PlayerSpellsUtil.OpenToSpellBookTab()
            --end
        end

        return MenuResponse.Refresh
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
            return MenuResponse.Refresh
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

    local category= tab.GetCategory and tab.GetCategory() or tab.category

    local showText= name2 or name
    showText= showText and showText..'|A:OptionsIcon-Brown:0:0|a' or ('|A:OptionsIcon-Brown:0:0|a'..(e.onlyChinese and '选项' or OPTIONS))

    local sub=root:CreateButton(showText, function(data)
        if SettingsPanel:IsVisible() and not e.LockFrame(SettingsPanel) then--ToggleGameMenu()
            SettingsPanel:Close()
        end
        e.OpenPanelOpting(data.category, data.name)
        return MenuResponse.Open
    end, {name=name, category=category})

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddDoubleLine(description.data.name or WoWTools_Mixin.addName, description.data.name2)
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
    root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
        --nil,
    function(data)
        StaticPopup_Show('WoWTools_OK',
            '|A:bags-button-autosort-up:32:32|a|n'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|n|n',
            nil,
            {SetValue=data.SetValue}
        )
        return MenuResponse.Refresh
    end, {SetValue=SetValue})


    --root:CreateButton('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL), SetValue)
end
--[[
--全部清除
    WoWTools_MenuMixin:ClearAll(sub, function() end)
]]





function WoWTools_MenuMixin:Set_Specialization(root)
    local numSpec= GetNumSpecializations(false, false) or 0
    if not C_SpecializationInfo.IsInitialized() or numSpec==0 then
        return
    end

    local sex= UnitSex("player")

    local curSpecIndex= GetSpecialization() or 0--当前，专精
    local specID, name, description, icon, role, primaryStat= GetSpecializationInfo(curSpecIndex, false, false, nil, sex)
    if not specID or not name then
        return
    end

    local curSpecID= specID

    local roleIcon= GetMicroIconForRoleEnum(GetSpecializationRoleEnum(curSpecIndex, false, false))
    local sub= root:CreateButton(
        '|T'..(icon or 0)..':0|t'..'|A:'..(roleIcon or '')..':0:0|a'..e.cn(name),
    function(data)
        WoWTools_LoadUIMixin:SpellBook(2, nil)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText('天赋和法术书', "TOGGLETALENTS"))
    end)

    for specIndex=1, numSpec do
        specID, name, _, icon= GetSpecializationInfo(specIndex, false, false, nil, sex)
        if specID and name and specID~=curSpecID then
            roleIcon= GetMicroIconForRoleEnum(GetSpecializationRoleEnum(specIndex, false, false))

            local sub2= sub:CreateButton(
                '|T'..(icon or 0)..':0|t'..'|A:'..(roleIcon or '')..':0:0|a'..e.cn(name),
            function(data)
                if GetSpecialization(nil, false, 1)~=data.specIndex
                    and not InCombatLockdown()
                    --and not(PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame:IsCommitInProgress())
                then
                    C_SpecializationInfo.SetSpecialization(data.specIndex)
                end
                return MenuResponse.Open
            end, {
                specIndex=specIndex,
                tooltip= function(tooltip, data2)
                    tooltip:AddLine(' ')
                    tooltip:AddLine(
                        ((UnitAffectingCombat('player') or GetSpecialization(nil, false, 1)==data2.specIndex) and '|cff828282' or '')
                        ..(e.onlyChinese and '激活' or SPEC_ACTIVE)
                        ..e.Icon.left)
                end}
            )

            WoWTools_SetTooltipMixin:Set_Menu(sub2)
        end
    end
end





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
--[[
--SetScrollMod
WoWTools_MenuMixin:SetScrollMode(root, nil)
]]