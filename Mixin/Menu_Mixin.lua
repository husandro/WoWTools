local e= select(2, ...)

WoWTools_MenuMixin={}

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
            tooltip:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE)
        end
    })

    return sub2, sub
end
    --[[sub2 = sub:CreateTemplate("OptionsSliderTemplate");

    sub2:AddInitializer(function(f)--, description, menu)
        f.func= SetValue

        local va= GetValue()
        f:SetValueStep(0.01)
        f:SetMinMaxValues(0.4, 4)
        f:SetValue(va or 1)

        f.Text:ClearAllPoints()
        f.Text:SetPoint('TOPRIGHT',0,6)
        f.Text:SetText(va or 1)

        f.High:SetText(e.onlyChinese and '缩放' or UI_SCALE)
        f.Low:SetText('')

        f:SetScript('OnValueChanged', function(frame, value)
            value= tonumber(format('%0.2f', value))
            frame.func(value)
            frame.Text:SetText(value)
        end)

        f:EnableMouseWheel(true)
        f:SetScript('OnMouseWheel', function(s, d)
            local value= s:GetValue()
            if d== 1 then
                value= value- 0.01
            elseif d==-1 then
                value= value+ 0.01
            end
            value= value> 4 and 4 or value
            value= value< 0.4 and 0.4 or value
            s:SetValue(value)
        end)
    end)]]


--FrameStrata
function WoWTools_MenuMixin:FrameStrata(root, GetValue, SetValue)
    local sub=root:CreateButton('FrameStrata', function() return MenuResponse.Open end)

    for _, strata in pairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        sub:CreateCheckbox((strata=='HIGH' and '|cnGREEN_FONT_COLOR:' or '')..strata, GetValue, SetValue, strata)
    end
    return sub
end

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
    local sub=root:CreateButton('|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t'..(UnitAffectingCombat('player') and '|cff9e9e9e' or '')..(e.onlyChinese and '重新加载UI' or RELOADUI),
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

--快捷键
function WoWTools_MenuMixin:SetKey(root, tab)
    local sub=root:CreateCheckbox(
        (tab.icon or '')
        ..(UnitAffectingCombat('player') and '|cff9e9e9e' or '')
        ..(tab.key or (e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)),
    function(data)
        return data.key
    end, function(data)
        StaticPopup_Show('WoWTools_EditText',
            (data.name and data.name..' ' or '')..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
            ..'|n|n"|cnGREEN_FONT_COLOR:Q|r", "|cnGREEN_FONT_COLOR:ALT-Q|r","|cnGREEN_FONT_COLOR:BUTTON5|r"|n"|cnGREEN_FONT_COLOR:ALT-CTRL-SHIFT-Q|r"',
            nil,
            {
                text=data.key,
                key=data.key,
                OnShow=function(s, tab2)
                    if not tab2.key then
                        s.editBox:SetText('BUTTON5')
                    end
                end,
                SetValue=data.SetValue,
                OnAlt=data.OnAlt,
            }
        )
    end, tab)
    sub:SetTooltip(function(tooltip, data)
        tooltip:AddLine(e.onlyChinese and '设置' or SETTINGS)
        tooltip:AddDoubleLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, data.key)
    end)
    return sub
end
--[[
WoWTools_MenuMixin:SetKey(sub, {
    icon='',
    name=addName,
    text=,
    key=,
    SetValue=function(s, data)
    end,
    OnAlt=function(s, data)
    end,
})
]]
























--[[打开界面, 收藏, 坐骑
local function set_ToggleCollectionsJournal(mountID, type, showNotCollected)
    WoWTools_LoadUIMixin:Journal(1)

    C_MountJournal.SetDefaultFilters()
    if not showNotCollected then
        C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, false)
    end
    if mountID then
        local name= C_MountJournal.GetMountInfoByID(mountID)
        if name then
            MountJournalSearchBox:SetText(name)
            --C_MountJournal.SetSearch(name)
            return --不, 过滤, 类型
        end
    end
    local tab={--过滤, 类型, Blizzard_MountCollection.lua
        [MOUNT_JOURNAL_FILTER_GROUND]= Enum.MountType.Ground,
        [MOUNT_JOURNAL_FILTER_AQUATIC]= Enum.MountType.Aquatic,
        [MOUNT_JOURNAL_FILTER_FLYING]=Enum.MountType.Flying,
        [MOUNT_JOURNAL_FILTER_DRAGONRIDING]= Enum.MountType.Dragonriding,
    }
    MountJournalSearchBox:SetText('')
    if type and tab[type] then
        for i=0, Enum.MountTypeMeta.NumValues do
            C_MountJournal.SetTypeFilter(i, i==tab[type]+1)
        end
    end
    return MenuResponse.Open
end

local Mount_Journal_Filter={--过滤, 类型, Blizzard_MountCollection.lua
    [MOUNT_JOURNAL_FILTER_GROUND]= Enum.MountType.Ground,
    [MOUNT_JOURNAL_FILTER_AQUATIC]= Enum.MountType.Aquatic,
    [MOUNT_JOURNAL_FILTER_FLYING]=Enum.MountType.Flying,
    [MOUNT_JOURNAL_FILTER_DRAGONRIDING]= Enum.MountType.Dragonriding,
}
]]



function WoWTools_MenuMixin:OpenJournal(root, tab)--战团藏品
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




function WoWTools_MenuMixin:GetDragonriding()--驭空术，return 名称，点数
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


function WoWTools_MenuMixin:OpenDragonriding(root)--驭空术
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
    WoWTools_SpellItemMixin:SetTooltip(nil, nil, sub)--设置，物品，提示
    
    return sub
end


