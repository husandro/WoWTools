--[[
CreateSlider(root, tab)
ScaleRoot
Scale(

BgAplha

FrameStrata(root, GetValue, SetValue)
RestPoint(root, point, SetValue)
RestData(root, name, SetValue)
Reload(root, isControlKeyDown)

ClearAll()
ToTop(root, tab)

CheckInCombat()

OpenJournal(root, tab)
OpenSpellBook(root, index)--天赋和法术书
OpenDragonriding(root)
OpenOptions(root, tab)

WoWTools_MenuMixin:SetScrollMode(root)
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
    local sub= root:CreateTemplate("OptionsSliderTemplate")

    local getValue= tab.getValue
    local setValue= tab.setValue
    local minValue= tab.minValue or 0
    local maxValue= tab.maxValue or 100
    local step= tab.step or 1
    local bit= tab.bit--'%.1f'

    local name= tab.name or ''
    local tooltip= tab.tooltip--function, string, table

    local tooltipType= type(tooltip)
    local function Get_Value(value)
        value= value or 1
         if bit then
            return tonumber(format(bit, value))
        else
            return math.modf(value)
        end
    end

    local function Get_tooltip()
        local func
        if tooltipType=='function' then
            func= tooltip
        elseif tooltipType=='string' then
            func= function(tip) GameTooltip_SetTitle(tip, tooltip) end
        elseif tooltipType=='table' then
            func= function(tip)
                for text in pairs(tooltip) do
                    tip:AddLine(text)
                end
            end
        end
        return func
    end

    sub:AddInitializer(function(f, desc, menu)--, description, menu)
        local va= getValue(f, desc) or 1
        f:SetValueStep(step or 1)
        f:SetMinMaxValues(minValue, maxValue)
        f:SetValue(va)

        f.Text:ClearAllPoints()
        f.Text:SetPoint('TOPRIGHT', 0,8)
        f.Text:SetText(Get_Value(va))

        f.Low:ClearAllPoints()
        f.Low:SetPoint('TOPLEFT', 0, 8)
        f.Low:SetText(name)

        f.High:SetText('')

        f:SetScript('OnValueChanged', function(s, value)
            value= Get_Value(value)
            setValue(value, s, desc)
            s.Text:SetText(value)
            local func= Get_tooltip()
            if func then
                MenuUtil.ShowTooltip(f, func, desc)
            end
            --menu:ReinitializeAll()
        end)

        f:EnableMouseWheel(true)
        f:SetScript('OnMouseWheel', function(s, d)
            local value= getValue(s, desc) or 1
            if d== 1 then
                value= value- step
            elseif d==-1 then
                value= value+ step
            end
            value= value> maxValue and maxValue or value
            value= value< minValue and minValue or value
            value= Get_Value(value)

            s:SetValue(value, s)

            local func= Get_tooltip()
            if func then
                MenuUtil.ShowTooltip(f, func, desc)
            end
        end)
        f:SetScript('OnHide', function(s)
            s:SetScript('OnMouseWheel', nil)
            s:SetScript('OnValueChanged', nil)
            s:SetScript('OnHide', nil)
        end)

        WoWTools_TextureMixin:SetNineSlice(f, 1)
        WoWTools_TextureMixin:SetAlphaColor(f.Thumb, true)

        local pad = 20;
        local width = pad + f.Text:GetUnboundedStringWidth() + f.Low:GetUnboundedStringWidth()
        width= math.max(150, width)
	    return width, 17
    end)

    if tooltip then
        sub:SetTooltip(Get_tooltip())
    end

    return sub
end

--[[
WoWTools_MenuMixin:CreateSlider(root, {
name= 
getValue=function()
end, setValue=function(value)
end,
minValue=0,
maxValue=100,
step=1,
--bit--='%.1f'
--tooltip--function, string, table
})
]]


--缩放, 单行
function WoWTools_MenuMixin:ScaleRoot(frame, root, GetValue, SetValue, ResetValue)
    local isLocked= WoWTools_FrameMixin:IsLocked(frame)
    root:CreateSpacer()

    local sub= self:CreateSlider(root, {
        getValue=GetValue,
        setValue=SetValue,
        name= WoWTools_DataMixin.onlyChinese and '缩放' or HOUSING_EXPERT_DECOR_SUBMODE_SCALE,
        minValue=0.4,
        maxValue=4,
        step=0.1,
        bit='%0.1f',
        tooltip=function(tooltip) tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '缩放' or HOUSING_EXPERT_DECOR_SUBMODE_SCALE) end,
    })
    sub:SetEnabled(not isLocked)


    if ResetValue then
        root:CreateSpacer()
        sub=root:CreateButton(
            '|A:characterundelete-RestoreButton:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        function(data)
            if not WoWTools_FrameMixin:IsLocked(frame) then
                data.resetValue()
            end
            return MenuResponse.Refresh
        end, {resetValue=ResetValue})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '缩放' or HOUSING_EXPERT_DECOR_SUBMODE_SCALE)..': 1')
        end)
        sub:SetEnabled(not isLocked)
    end

    return sub
end





--缩放
function WoWTools_MenuMixin:Scale(frame, root, GetValue, SetValue, ResetValue)
    local isLocked=  WoWTools_FrameMixin:IsLocked(frame)
    local sub= root:CreateButton(
        (isLocked and '|cff626262' or '')
        ..'|A:common-icon-zoomin:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '缩放' or HOUSING_EXPERT_DECOR_SUBMODE_SCALE),
    function()
        return MenuResponse.Open
    end, {rightText= tonumber(format('%.1f', GetValue() or 1))})
    self:SetRightText(sub)

    if not ResetValue then
        ResetValue= function() SetValue(1) end
    end

    local sub2= self:ScaleRoot(frame, sub, GetValue, SetValue, ResetValue)

    for i=0.5, 4, 0.5 do
        sub2:CreateRadio(
            i,
        function(scale)
            return (GetValue() or 1)==scale
        end, function(scale)
            SetValue(scale)
            return MenuResponse.Refresh
        end, i)
    end

    return sub, sub2
end
--[[
--缩放
WoWTools_MenuMixin:Scale(self, sub,
function()--GetValue
end, function(alpha)--SetValue
end, function()--SetValue
end)
]]


--FrameStrata
function WoWTools_MenuMixin:FrameStrata(frame, root, GetValue, SetValue)
    local enable= WoWTools_FrameMixin:IsLocked(frame)~=true

    local value= GetValue() or 'MEDIUM'

    local sub=root:CreateButton(
        '|A:Garr_SwapIcon:0:0:|a'
        ..(enable and '' or '|cff626262')
        ..(WoWTools_DataMixin.onlyChinese and '框架层' or 'Strata'),
    function()
        return MenuResponse.Refresh
    end, {
        rightText= value=='FULLSCREEN_DIALOG' and 'FD' or WoWTools_TextMixin:sub(value, 1),
        name= value
    })
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(GetValue() or 'MEDIUM')
    end)
    self:SetRightText(sub)

    for _, strata in pairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        local sub2= sub:CreateCheckbox(
            (strata=='MEDIUM' and '|cnGREEN_FONT_COLOR:' or '')..strata,
            GetValue,
            SetValue,
            strata
        )
        sub2:SetEnabled(enable)
    end
    return sub
end
--[[
--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(strata)
        return self:GetFrameStrata()==strata
    end, function(strata)
        Save().strata= strata
        return MenuResponse.Refresh
    end)
]]


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
        end, {rightText= tonumber(format('%.1f', GetValue() or 1))})
        self:SetRightText(sub)
    end

    sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=GetValue,
        setValue=SetValue,
        name=WoWTools_DataMixin.onlyChinese and '背景透明度' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BACKGROUND, HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY),
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%.1f',
    })

    if RestFunc or not onlyRoot then
        sub:CreateSpacer()
        sub2= sub:CreateButton(
            '|A:characterundelete-RestoreButton:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        function()
            if RestFunc then
                RestFunc()
            else
                SetValue(0.5)
            end
            return MenuResponse.Refresh
        end)

        for i=0, 1.0, 0.1 do
            sub2:CreateRadio(
                i,
            function(index)
                SetValue(index)
                return MenuResponse.Refresh
            end, i)
        end
    end
    return sub, sub2
end
--[[
--背景, 透明度
WoWTools_MenuMixin:BgAplha(sub,
function()
    return Save().bgAlpha or 0.5
end, function(value)
    Save().bgAlpha= value
    self:settings()
end, function()
    Save().bgAlpha= nil
    self:settings()
end)
]]








--重置位置
function WoWTools_MenuMixin:RestPoint(frame, root, point, SetValue)
    local sub= root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'
        ..(point and '' or '|cff626262')
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
        ..(InCombatLockdown() and IsInInstance() and '|cff626262' or '')--e.IsEncouter_Start
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








function WoWTools_MenuMixin:ToTop(frame, root, tab)
    local sub=root:CreateCheckbox(
        (WoWTools_FrameMixin:IsLocked(frame) and '|cff626262' or '')
        ..(tab.name or ('|A:bags-greenarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION))),
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
WoWTools_MenuMixin:ToTop(frame, root, {
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
--elseif tab.index== PlayerSpellsUtil.FrameTabs.SpellBook then--3
--if tab.index== PlayerSpellsUtil.FrameTabs.ClassSpecializations then--1
--PlayerSpellsUtil.OpenToSpellBookTab() bug

function WoWTools_MenuMixin:OpenSpellBook(root, index)--天赋和法术书
    index= index or 1
    local isSpellBook= index==3

    local sub= root:CreateButton(
        (isSpellBook and '|cnWARNING_FONT_COLOR:' or '')
        ..MicroButtonTooltipText('天赋和法术书', "TOGGLETALENTS"),
    function()
        WoWTools_LoadUIMixin:SpellBook(index)
        return MenuResponse.Open
    end)
    if isSpellBook then
        sub:SetTooltip(function(tooltip)
            GameTooltip_AddErrorLine(tooltip, 'Bug')
        end)
    end

    return sub
end



--[[
加载，Trait，UI
function WoWTools_LoadUIMixin:GenericTraitUI(systemID, treeID)
    TraitUtil.OpenTraitFrame(treeID)

    --WoWTools_DataMixin:Call('GenericTraitUI_LoadUI')
    --securecallfunction(GenericTraitFrame.SetSystemID, GenericTraitFrame, systemID)
    --securecallfunction(GenericTraitFrame.SetTreeID, GenericTraitFrame, treeID)
    --ToggleFrame(GenericTraitFrame)
end
]]

--驭空术，return 名称，点数 11.2.7 没有了
function WoWTools_MenuMixin:GetDragonriding()
    local dragonridingConfigID = C_Traits.GetConfigIDBySystemID(1);
    if dragonridingConfigID then
        local treeCurrencies = C_Traits.GetTreeCurrencyInfo(dragonridingConfigID, 672, false) or {}
        local num= treeCurrencies[1] and treeCurrencies[1].quantity
        if num and num>0 then
            return '|T'..(select(4, C_Traits.GetTraitCurrencyInfo(2563)) or 4728198)..':0|t'
                ..(num==0 and '|cff626262' or '|cnGREEN_FONT_COLOR:')..num..'|r',

                num
        end
    end
end

--驭空术 TraitUtil.OpenTraitFrame(Constants.MountDynamicFlightConsts.TREE_ID)
function WoWTools_MenuMixin:OpenDragonriding(root)
    local configID = C_Traits.GetConfigIDByTreeID(Constants.MountDynamicFlightConsts.TREE_ID);
    local uiWidgetSetID = configID and C_Traits.GetTraitSystemWidgetSetID(configID) or nil

    local sub= root:CreateButton(
            '|A:dragonriding-barbershop-icon-protodrake:0:0|a'
            ..((InCombatLockdown() or not DragonridingUtil.IsDragonridingUnlocked()) and '|cff626262' or '')
            ..(WoWTools_DataMixin.onlyChinese and '驭空术' or GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE)
            ..(self:GetDragonriding() or ''),
        function()
            if not DragonridingUtil.IsDragonridingTreeOpen() then
                GenericTraitUI_LoadUI()
                if GenericTraitFrame.SetConfigIDBySystemID then--11.2.7才有
                    GenericTraitFrame:SetConfigIDBySystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID)
                    GenericTraitFrame:SetTreeID(Constants.MountDynamicFlightConsts.TREE_ID)
                else
                    securecallfunction(GenericTraitFrame.SetSystemID, GenericTraitFrame, Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID)
                    securecallfunction(GenericTraitFrame.SetTreeID, GenericTraitFrame, Constants.MountDynamicFlightConsts.TREE_ID)
                end
            end
            if GenericTraitFrame then
                ToggleFrame(GenericTraitFrame)
            end
            --[[WoWTools_LoadUIMixin:GenericTraitUI(--加载，Trait，UI
                Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID,
                Constants.MountDynamicFlightConsts.TREE_ID
            )]]
            return MenuResponse.Refresh
        end,
        {widgetSetID=uiWidgetSetID}--, tooltip=WoWTools_DataMixin.onlyChinese and '巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TITLE}
    )
    WoWTools_SetTooltipMixin:Set_Menu(sub)

    return sub
end


function WoWTools_MenuMixin:OpenOptions(root, tab)
    tab= tab or {}

    local name= tab.name
    local name2= tab.name2
    local category= tab.GetCategory and tab.GetCategory() or tab.category
    local tooltip= tab.tooltip

    local sub=root:CreateButton(
        (InCombatLockdown() and '|cff828282' or '')
        ..(name2 or name or (WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS))
        ..'|A:OptionsIcon-Brown:0:0|a',
    function()
        if not InCombatLockdown() then
            if SettingsPanel:IsVisible() then--ToggleGameMenu()
                SettingsPanel:Close()
            end
            WoWTools_PanelMixin:Open(category, name)
        end
        return MenuResponse.Open
    end)

    sub:SetTooltip(function(t)
        t:AddDoubleLine(name and name..WoWTools_DataMixin.Icon.icon2 or WoWTools_DataMixin.addName, name2)
        t:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '打开选项界面'
            or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI')
        )
        local isType= type(tooltip)
        if isType=='string' then
            t:AddLine(' ')
            t:AddLine(tooltip)
        elseif isType=='function' then
            tooltip(t)
        end
    end)
    return sub
end
--[[
--打开选项界面
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


















--文本转语音
function WoWTools_MenuMixin:TTsMenu(root)
    local sub= self:CVar(root, 'textToSpeech', '|A:chatframe-button-icon-TTS:0:0|a'..(WoWTools_DataMixin.onlyChinese and '文本转语音' or TEXT_TO_SPEECH), '/tts')
    if sub then
        sub:CreateButton(
            (ChatConfigFrame:IsShown() and '|cff626262' or '')
            ..(WoWTools_DataMixin.onlyChinese and '文字转语音选项' or TEXT_TO_SPEECH_CONFIG),
        function()
            WoWTools_DataMixin:Call('ToggleTextToSpeechFrame')
        end)
    end
end


--仅支持 0 1
function WoWTools_MenuMixin:CVar(root, name, showName, tooltip, eventFunc)
    local value, defaultValue= C_CVar.GetCVarInfo(name)
    if not value then
        if WoWTools_DataMixin.Player.husandro then
            print('|cnWARNING_FONT_COLOR:CVar|r', '没有发现')
        end
        return
    end

    local sub= root:CreateCheckbox(
        (InCombatLockdown() and '|cff626262' or '')
        ..(showName or name),
    function()
        return C_CVar.GetCVarBool(name)
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar(name, C_CVar.GetCVarBool(name) and '0' or '1')
        end
    end)
    sub:AddInitializer(function(btn)
        btn:RegisterEvent('CVAR_UPDATE')
        btn:SetScript('OnEvent', function(b, _, cvarName)
            if cvarName==name then
                C_Timer.After(0.3, function()
                    local isVale= C_CVar.GetCVarBool(cvarName)
                    if b.leftTexture2 then
                        b.leftTexture2:SetShown(isVale)
                    end
                    if eventFunc then
                        eventFunc(isVale)
                    end
                end)
            end
        end)
        btn:SetScript('OnHide', function(b)
            b:UnregisterEvent('CVAR_UPDATE')
        end)
    end)
    sub:SetTooltip(function(tip)
        tip:AddLine(tooltip, nil, nil, nil, true)
        if defaultValue then
            if tooltip then
                tip:AddLine(' ')
            end
            tip:AddLine((WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)..': '..WoWTools_TextMixin:GetYesNo(tonumber(defaultValue)==1))
        end
    end)
    return sub
end

function WoWTools_MenuMixin:SetRightText(root)
    root:AddInitializer(function(btn, desc)
        local rightText= desc.data and desc.data.rightText
        if not rightText then
            return
        end

        local color= desc.data.rightColor

        local font = btn:AttachFontString()
        local offset = desc:HasElements() and -20 or 0
        font:SetPoint("RIGHT", offset, 0)
        font:SetJustifyH("RIGHT")
        font:SetTextToFit(rightText)
        if color and color.GetRGB then
            font:SetTextColor(color:GetRGB())
        elseif rightText==0 then
            font:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        else
            font:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
        end
    end)
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
    root:SetScrollMode(math.max(20*35, GetScreenHeight()-70))
end
--[[
--SetScrollMod
WoWTools_MenuMixin:SetScrollMode(root)

--全部清除
    WoWTools_MenuMixin:ClearAll(sub, function() 

    end)
]]
