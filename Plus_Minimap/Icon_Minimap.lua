local e= select(2, ...)
local addName

local Save= function()
    return  WoWTools_MinimapMixin.Save
end






function WowTools_OnAddonCompartmentClick(self, d)
    local key= IsModifierKeyDown()
    if IsAltKeyDown() and self and type(self)=='table' then
        WoWTools_MinimapMixin:Open_Menu(self)

    elseif IsShiftKeyDown() then
        WeeklyRewards_LoadUI()--宏伟宝库
        WeeklyRewards_ShowUI()--WeeklyReward.lua

    elseif d=='LeftButton' and not key then
            local expButton=ExpansionLandingPageMinimapButton
            if expButton and expButton.ToggleLandingPage and expButton.title then
                expButton:ToggleLandingPage()--Minimap.lua
            else
                if not Initializer then
                    e.OpenPanelOpting()
                end
                e.OpenPanelOpting(Initializer)
                --Settings.OpenToCategory(id)
                --e.call(InterfaceOptionsFrame_OpenToCategory, id)
            end

    elseif d=='RightButton' and not key then
        if SettingsPanel:IsShown() then
            if not Initializer then
                e.OpenPanelOpting()
            end
            e.OpenPanelOpting(Initializer)
        else
            e.OpenPanelOpting()
        end
    end
end



local function WowTools_OnAddonCompartmentFuncOnEnter(self)
    local expButton=ExpansionLandingPageMinimapButton
    if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
        expButton:OnEnter()
        e.tips:AddLine(' ')
    else
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
    end

    e.tips:AddDoubleLine(e.onlyChinese and '选项' or SETTINGS_TITLE , e.Icon.right)

    if self and type(self)=='table' then
        if _G['LibDBIcon10_WoWTools'] and _G['LibDBIcon10_WoWTools']:IsMouseWheelEnabled() then
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.mid)
        else
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, 'Alt'..e.Icon.right)
        end
    end
    e.tips:AddDoubleLine(e.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Shift'..e.Icon.left)

    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(e.addName, Initializer:GetName())
    e.tips:Show()
end





    --图标
local function Init()
    local libDataBroker = LibStub:GetLibrary("LibDataBroker-1.1", true)
    local libDBIcon = LibStub("LibDBIcon-1.0", true)
    if libDataBroker and libDBIcon then
        local Set_MinMap_Icon= function(tab)-- {name, texture, func, hide} 小地图，建立一个图标 Hide("MyLDB") icon:Show("")
            local bunnyLDB = libDataBroker:NewDataObject(tab.name, {
                OnClick=tab.func,--fun(displayFrame: Frame, buttonName: string)
                OnEnter=tab.enter,--fun(displayFrame: Frame)
                OnLeave=nil,--fun(displayFrame: Frame)
                OnTooltipShow=nil,--fun(tooltip: Frame)
                icon=tab.texture,--string
                iconB=nil,--number,
                iconCoords=nil,--table,
                iconG=nil,--number,
                iconR=nil,--number,
                label=nil,--string,
                suffix=nil,--string,
                text=tab.name,-- string,
                tocname=nil,--string,
                tooltip=nil,--Frame,
                type='data source',-- "data source"|"launcher",
                value=nil,--string,
            })

            libDBIcon:Register(tab.name, bunnyLDB, Save().miniMapPoint)
            return libDBIcon
        end
        Save().miniMapPoint= Save().miniMapPoint or {}

        Set_MinMap_Icon({name= 'WoWTools', texture= [[Interface\AddOns\WoWTools\Sesource\Texture\WoWtools.tga]],--texture= -18,--136235,
            func= WowTools_OnAddonCompartmentClick,
            enter= function(self)
                if Save().moving_over_Icon_show_menu and not UnitAffectingCombat('player') then
                    WoWTools_MinimapMixin:Open_Menu(self)
                end
                WowTools_OnAddonCompartmentFuncOnEnter(self)
            end,
        })
        local btn= _G['LibDBIcon10_WoWTools']
        if btn then
            btn:EnableMouseWheel(true)
            btn:SetScript('OnMouseWheel', function(self)
                WoWTools_MinimapMixin:Open_Menu(self)
            end)
        end
    end
end





function WoWTools_MinimapMixin:Init_Icon()
    Init()
end