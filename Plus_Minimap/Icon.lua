local e= select(2, ...)


local Save= function()
    return  WoWTools_MinimapMixin.Save
end





local function OnEnter_Tooltip(self)
    local expButton=ExpansionLandingPageMinimapButton
    if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
        expButton:OnEnter()
        if UnitAffectingCombat('player') then return end
    else
        if UnitAffectingCombat('player') then return end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
    end
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
    e.tips:AddDoubleLine(e.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI'), e.Icon.mid)
    e.tips:Show()
end





local function On_Click(self, d)
    if d=='LeftButton' then
        WoWTools_LoadUIMixin:ToggleLandingPage()

    elseif d=='RightButton' then
        WoWTools_MinimapMixin:Open_Menu(self)
    end
end







function WoWTools_MinimapMixin:Init_Icon()
    local libDataBroker = LibStub:GetLibrary("LibDataBroker-1.1", true)
    local libDBIcon = LibStub("LibDBIcon-1.0", true)
    if libDataBroker and libDBIcon then
        libDBIcon:Register('WoWTools', libDataBroker:NewDataObject('WoWTools', {
            OnClick=On_Click,--fun(displayFrame: Frame, buttonName: string)
            OnEnter=OnEnter_Tooltip,--fun(displayFrame: Frame)
            OnLeave=nil,--fun(displayFrame: Frame)
            OnTooltipShow=nil,--fun(tooltip: Frame)
            icon='Interface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga',--string
            iconB=nil,--number,
            iconCoords=nil,--table,
            iconG=nil,--number,
            iconR=nil,--number,
            label=nil,--string,
            suffix=nil,--string,
            text='WoWTools',-- string,
            tocname=nil,--string,
            tooltip=e.addName,--Frame,
            type='data source',-- "data source"|"launcher",
            value=nil,--string,
        }), Save().miniMapPoint)

        local btn= _G['LibDBIcon10_WoWTools']
        if btn then
            btn:EnableMouseWheel(true)
            btn:SetScript('OnMouseWheel', function(_, d)
                if d==1 then
                    e.OpenPanelOpting(nil, '|A:talents-button-undo:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT))
                else
                    e.OpenPanelOpting(nil, WoWTools_MinimapMixin.addName)
                end
            end)
        end
    end
end




--[[

function WowTools_OnAddonCompartmentClick(self, d)

    if d=='LeftButton' then
        e.OpenPanelOpting(nil, WoWTools_MinimapMixin.addName)

    elseif d=='RightButton' then
        WoWTools_MinimapMixin:Open_Menu(self)
    end
end



function WowTools_OnAddonCompartmentFuncOnEnter(_, root)
    MenuUtil.ShowTooltip(root, function(tooltip)
        tooltip:SetText(e.addName)
    end)
end]]
   --[[print(self, ...)
    local expButton=ExpansionLandingPageMinimapButton
    if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
        expButton:OnEnter()
        e.tips:AddLine(' ')
    else
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
    end


    e.tips:AddDoubleLine(e.onlyChinese and '选项' or SETTINGS_TITLE , e.Icon.mid)

    if self and type(self)=='table' then
        if _G['LibDBIcon10_WoWTools'] and _G['LibDBIcon10_WoWTools']:IsMouseWheelEnabled() then
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.mid)
        else
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, 'Alt'..e.Icon.right)
        end
    end
    e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Shift'..e.Icon.left)

    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(e.addName, WoWTools_MinimapMixin.addName)
    e.tips:Show()
end]]
