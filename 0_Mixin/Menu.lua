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
Set_Specialization


GetDragonriding()
]]
local maxMenuButton= 35

WoWTools_MenuMixin={}

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
        if f.bit then
            f.Text:SetText(tonumber(format(f.bit, va)))
        else
            f.Text:SetText(math.ceil(va))
        end

        f.Low:ClearAllPoints()
        f.Low:SetPoint('TOPLEFT', 0, 8)
        f.Low:SetText(desc.data.name or '')

        f.High:SetText('')

        f:SetScript('OnValueChanged', function(s, value)
            if s.bit then
                value= tonumber(format(s.bit, value))
            else
                value= math.ceil(value)
            end
            s.setValue(value, s)
            s.Text:SetText(value)
            local t= type(desc.data.tooltip)
            if t=='function' then
                MenuUtil.ShowTooltip(f, desc.data.tooltip, desc)
            elseif t=='string' then
                MenuUtil.ShowTooltip(f, function(tooltip)
				    GameTooltip_SetTitle(tooltip, desc.data.tooltip)
			    end, desc)
            end
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
            s.getValue=nil
            s.setValue=nil
            s.minValue=nil
            s.maxValue=nil
            s.step=nil
            s.bit=nil
            s.elapsed=nil
            s:SetScript('OnMouseWheel', nil)
            s:SetScript('OnValueChanged', nil)
            s:SetScript('OnHide', nil)
            s:SetScript('OnUpdate', nil)
        end)

        WoWTools_TextureMixin:SetNineSlice(f, 1)
        WoWTools_TextureMixin:SetAlphaColor(f.Thumb, true)
    end)


    sub:SetTooltip(function(tooltip, desc)
        local t= type(desc.data.tooltip)
        if t=='string' then
            tooltip:AddLine(desc.data.tooltip)
        elseif t=='function' then
            desc.data.tooltip(tooltip)
        elseif t=='table' then
            for text in pairs(desc.data.tooltip) do
                tooltip:AddLine(text)
            end
        end
    end)

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
    name=WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
    minValue=1,
    maxValue=10,
    step=1,
    bit='%.2f',
    tooltip=function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '间隔' or 'Interval')
    end
   
})
sub:CreateSpacer()
]]





--缩放, 单行
function WoWTools_MenuMixin:ScaleRoot(frame, root, GetValue, SetValue, ResetValue)
    local sub
    if  not frame:CanChangeAttribute() then
        sub=root:CreateButton('|cff828282'..WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE,function() end)
        sub:SetEnabled(false)
        return
    end
    root:CreateSpacer()
    sub= self:CreateSlider(root, {
        getValue=GetValue,
        setValue=SetValue,
        name= WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE,
        minValue=0.2,
        maxValue=4,
        step=0.05,
        bit='%0.2f',
        tooltip=function(tooltip) tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE) end,
    })
    root:CreateSpacer()

    sub=root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
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
        tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..': 1')
    end)

    return sub
end




--[[缩放, 加check
function WoWTools_MenuMixin:ScaleCheck(frame, root, GetValue, SetValue, ResetValue, checkGetValue, checkSetValue)
    local sub
    if not frame:CanChangeAttribute() then
        sub=root:CreateButton('|cff828282'..WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE,function() end)
        sub:SetEnabled(false)
        return
    end
    sub= root:CreateCheckbox(
        '|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE),
        checkGetValue,
        checkSetValue,
        {checkGetValue=checkGetValue}
    )
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_TextMixin:GetEnabeleDisable(nil, true))
    end)

    local sub2= self:ScaleRoot(frame, sub, GetValue, SetValue, ResetValue)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_TextMixin:GetEnabeleDisable(nil, true))
    end)
    return sub2, sub
end]]


--缩放
function WoWTools_MenuMixin:Scale(frame, root, GetValue, SetValue, ResetValue)
    local sub
    if not frame:CanChangeAttribute() then
        sub=root:CreateButton('|cff828282'..WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE, function() end)
        sub:SetEnabled(false)
        return
    end
    sub= root:CreateButton(
        '|A:common-icon-zoomin:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE),
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
            r = colorInfo.r or WoWTools_DataMixin.Player.r,
            g = colorInfo.g or WoWTools_DataMixin.Player.g,
            b = colorInfo.b or WoWTools_DataMixin.Player.b,
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
    local sub=root:CreateButton('|A:Garr_SwapIcon:0:0:|a'..(WoWTools_DataMixin.onlyChinese and '框架层' or 'Strata'), function()
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
        ..(WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER),
        GetValue,
        SetValue)
end

--背景, 透明度
function WoWTools_MenuMixin:BgAplha(root, GetValue, SetValue, RestFunc, onlyRoot)
    local sub, sub2
    if onlyRoot then
        sub=root
    else
        sub= root:CreateButton(
            '|A:MonkUI-LightOrb:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '背景' or BACKGROUND),
        function()
            return MenuResponse.Open
        end)
    end

    sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=GetValue,
        setValue=SetValue,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY ,
        minValue=0,
        maxValue=1,
        step=0.01,
        bit='%.2f',
    })
    sub:CreateSpacer()

    if not onlyRoot then
        sub:CreateButton(
            '|A:characterundelete-RestoreButton:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        function(data)
            data.SetValue(0.5)
            if data.RestFunc then
                data.RestFunc()
            end
            return MenuResponse.Refresh
        end, {SetValue=SetValue, RestFunc=RestFunc})
    end
    return sub, sub2
end
--背景, 透明度
--[[
WoWTools_MenuMixin:BgAplha(sub,
function()--GetValue
end, function()--SetValue
end, function()--RestFunc
end, false)--onlyRoot
]]





--显示背景
function WoWTools_MenuMixin:ShowBackground(root, GetValue, SetValue, GetAlphaValue, SetAplhaValue)
    local sub2
    local sub= root:CreateCheckbox(
        '|A:MonkUI-LightOrb:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND),
        GetValue,
        SetValue
    )
    if GetAlphaValue and SetAplhaValue then
--透明度
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=GetAlphaValue,
            setValue=SetAplhaValue,
            name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY ,
            minValue=0,
            maxValue=1,
            step=0.01,
            bit='%.2f',
        })
        sub:CreateSpacer()
    end
    return sub, sub2
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
        ..(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION),
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
    return root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
    function()
        StaticPopup_Show('WoWTools_RestData', name, nil, SetValue)
        return MenuResponse.Open
    end)
end

--重新加载UI
function WoWTools_MenuMixin:Reload(root, isControlKeyDown)
    local sub=root:CreateButton(
        '|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t'
        ..(InCombatLockdown() and IsInInstance() and '|cff9e9e9e' or '')--e.IsEncouter_Start
        ..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI),
    function(data)
        if data and IsControlKeyDown() or not data then
            WoWTools_DataMixin:Reload()
        end
    end, isControlKeyDown)
    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(SLASH_RELOAD1, desc.data and '|cnGREEN_FONT_COLOR:Ctrl+|r'..WoWTools_DataMixin.Icon.left)
    end)
    return sub
end
--[[
--重新加载UI
    WoWTools_MenuMixin:Reload(root)
]]








function WoWTools_MenuMixin:ToTop(root, tab)
    local sub=root:CreateCheckbox(
        (tab.name or ('|A:bags-greenarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION))),
        --('|A:editmode-up-arrow:16:11:0:3|a'..(WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP))),
        tab.GetValue,
        tab.SetValue,
        {isReload=tab.isReload, tooltip=tab.tooltip}
    )
    sub:SetTooltip(function(tooltip, description)
        if description.data.tooltip~=false then
            tooltip:AddLine(
                description.data.tooltip or
                (WoWTools_DataMixin.onlyChinese and '收起选项 |A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
            )
        end
        if description.data.isReload then
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
                ..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
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
        (tab.icon or '|A:OptionsIcon-Brown:0:0|a')..(tab.name or (WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS)),
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
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '打开战团藏品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, COLLECTIONS), "TOGGLECOLLECTIONS"))
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
        tab.name or ('|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '天赋和法术书' or PLAYERSPELLS_BUTTON)),
    function()
        if SettingsPanel:IsShown() and not WoWTools_FrameMixin:IsLocked(SettingsPanel) then--ToggleGameMenu()
            SettingsPanel:Close()
        end
        if tab.index== PlayerSpellsUtil.FrameTabs.ClassSpecializations then--1
            PlayerSpellsUtil.OpenToClassSpecializationsTab()

        elseif tab.index== PlayerSpellsUtil.FrameTabs.ClassTalents then--2
            PlayerSpellsUtil.OpenToClassTalentsTab()

        elseif tab.index== PlayerSpellsUtil.FrameTabs.SpellBook then--3
            PlayerSpellsUtil.OpenToSpellBookTab()
        end

        return MenuResponse.Refresh
    end, tab)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '天赋和法术书' or PLAYERSPELLS_BUTTON, "TOGGLETALENTS"))
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
            ..(WoWTools_DataMixin.onlyChinese and '驭空术' or GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE)
            ..(self:GetDragonriding() or ''),
        function()
            WoWTools_LoadUIMixin:GenericTraitUI(--加载，Trait，UI
                Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID,
                Constants.MountDynamicFlightConsts.TREE_ID
            )
            return MenuResponse.Refresh
        end,
        {widgetSetID=uiWidgetSetID, tooltip=WoWTools_DataMixin.onlyChinese and '巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TITLE}
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
    showText= showText and showText..'|A:OptionsIcon-Brown:0:0|a' or ('|A:OptionsIcon-Brown:0:0|a'..(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS))

    local sub=root:CreateButton(
        (WoWTools_FrameMixin:IsLocked(SettingsPanel) and '|cff828282' or '')
        ..showText,
    function(data)
        if WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            return
        elseif SettingsPanel:IsVisible() then--ToggleGameMenu()
            SettingsPanel:Close()
        end
        WoWTools_PanelMixin:Open(data.category, data.name)
        return MenuResponse.Open
    end, {name=name, category=category, tooltip=tab.tooltip})

    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddDoubleLine(desc.data.name or WoWTools_DataMixin.addName, desc.data.name2)
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI')
        )
        local isType= type(desc.data.tooltip)
        if isType=='string' then
            tooltip:AddLine(' ')
            tooltip:AddLine(desc.data.tooltip)
        elseif isType=='function' then
            desc.data.tooltip(tooltip)
        end
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
end,
category=,
tooltip=,
})


]]






function WoWTools_MenuMixin:ClearAll(root, SetValue)
    return root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        --nil,
    function(data)
        StaticPopup_Show('WoWTools_OK',
            '|A:bags-button-autosort-up:32:32|a|n'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)..'|n|n',
            nil,
            {SetValue=data.SetValue}
        )
        return MenuResponse.Refresh
    end, {SetValue=SetValue})
end
--[[
--全部清除
    WoWTools_MenuMixin:ClearAll(sub, function() 

    end)
]]





function WoWTools_MenuMixin:Set_Specialization(root)
    local numSpec= GetNumSpecializations(false, false) or 0
    if not C_SpecializationInfo.IsInitialized() or numSpec==0 then
		return
	end

    local sub, specID, name, icon, _
    local isInCombat= InCombatLockdown()
    local curSpecIndex= GetSpecialization() or 0--当前，专精
    local sex= WoWTools_DataMixin.Player.Sex

    for specIndex=1, numSpec, 1 do
        specID, name, _, icon= GetSpecializationInfo(specIndex, false, false, nil, sex)

        sub=root:CreateRadio(
            '|T'..(icon or 0)..':0|t'
            ..'|A:'..(GetMicroIconForRoleEnum(GetSpecializationRoleEnum(specIndex, false, false)) or '')..':0:0|a'
            ..(isInCombat and '|cff828282' or (curSpecIndex==specIndex and '|cnGREEN_FONT_COLOR:') or '')
            ..WoWTools_TextMixin:CN(name),
        function(data)
            return data.specID== PlayerUtil.GetCurrentSpecID()
        end, function(data)
            if C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
                C_SpecializationInfo.SetSpecialization(data.specIndex)
            end
            return MenuResponse.Refresh
        end, {
            specIndex=specIndex,
            specID= specID,
            tooltip= function(tooltip, data2)
                local canSpecsBeActivated, failureReason = C_SpecializationInfo.CanPlayerUseTalentSpecUI()
                tooltip:AddLine(' ')
                if GetSpecialization(nil, false, 1)==data2.specIndex then
                    GameTooltip_AddInstructionLine(tooltip, WoWTools_DataMixin.onlyChinese and '已激活' or COVENANT_SANCTUM_UPGRADE_ACTIVE)

                elseif canSpecsBeActivated then
                    tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '激活' or SPEC_ACTIVE)..WoWTools_DataMixin.Icon.left)

                elseif failureReason and failureReason~='' then
                    GameTooltip_AddErrorLine(tooltip, WoWTools_TextMixin:CN(failureReason), true)
                end
            end}
        )

        sub:AddInitializer(function(btn, desc, menu)
            local rightTexture= btn:AttachTexture()
            rightTexture:SetPoint('RIGHT', -12, 0)
            rightTexture:SetSize(20,20)
            rightTexture:SetAtlas('VignetteLoot')

            function btn:set_loot()
                local lootID= GetLootSpecialization()
                local show
                if lootID==0 then
                    show= GetSpecialization(nil, false, 1)==desc.data.specIndex
                else
                    show= lootID==desc.data.specID
                end
                rightTexture:SetShown(show)
            end
            btn:set_loot()

            btn:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
            btn:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')

            btn:SetScript('OnEvent', function(s, event)
                if event=='ACTIVE_PLAYER_SPECIALIZATION_CHANGED' then
                    WoWTools_DataMixin:Call(menu.ReinitializeAll, menu)
                end
                s:set_loot()
            end)
            btn:SetScript('OnHide', function(s)
                s:UnregisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
                s:UnregisterEvent('PLAYER_LOOT_SPEC_UPDATED')
                s:SetScript('OnHide', nil)
                s.set_loot=nil
            end)
        end)
        WoWTools_SetTooltipMixin:Set_Menu(sub)

        sub:CreateButton(
            '|T'..(icon or 0)..':0|t'
            ..'|A:VignetteLoot:0:0|a'..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION),
        function(data)
            SetLootSpecialization(data.specID)
            return MenuResponse.Open
        end, {specID= specID})


        sub:CreateDivider()
        sub:CreateButton(
            --'|T'..(PlayerUtil.GetSpecIconBySpecID(GetSpecializationInfo(curSpecIndex), sex) or 0)..':0|t'
            WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT,
        function()
            SetLootSpecialization(0)
            return MenuResponse.Open
        end)
    end

    sub= root:CreateCheckbox(
        ((C_PvP.ArePvpTalentsUnlocked() and C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired())) and '' or '|cff828282')
        ..'|A:pvptalents-warmode-swords:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE),
    function()
        return C_PvP.IsWarModeDesired()
    end,function()
        --C_PvP.ToggleWarMode()
        WoWTools_LoadUIMixin:SpellBook(2)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE)
        if not C_PvP.ArePvpTalentsUnlocked() then
			GameTooltip_AddErrorLine(
                GameTooltip,
                format(
                    WoWTools_DataMixin.onlyChinese and '在%d级解锁' or PVP_TALENT_SLOT_LOCKED,
                    C_PvP.GetPvpTalentsUnlockedLevel()
                ),
            true)

        elseif not C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired()) then
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE, 1,0,0)
		end
    end)

    sub:AddInitializer(function(btn, _, menu)
        btn:RegisterEvent('PLAYER_FLAGS_CHANGED')
        btn:SetScript('OnEvent', function()
            WoWTools_DataMixin:Call(menu.ReinitializeAll, menu)
        end)
        btn:SetScript('OnHide', function(s)
            s:UnregisterEvent('PLAYER_FLAGS_CHANGED')
            s:SetScript('OnHide', nil)
        end)
    end)

    return true
end



function WoWTools_MenuMixin:SetGridMode(sub, num)
    if num and num>maxMenuButton then
        sub:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(num/maxMenuButton))
    end
end
--[[
--SetGridMode
WoWTools_MenuMixin:SetGridMode(sub, num)
]]

--SetScrollMode UIParent:GetHeight()
function WoWTools_MenuMixin:SetScrollMode(root)
    root:SetScrollMode(math.max(20*35,  GetScreenHeight()-70))
end
--[[
--SetScrollMod
WoWTools_MenuMixin:SetScrollMode(root)

--全部清除
    WoWTools_MenuMixin:ClearAll(sub, function() 

    end)
]]
