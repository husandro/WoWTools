local Save= function()
    return  WoWToolsSave['Minimap_Plus']
end





local function On_Enter(self)
    local expButton=ExpansionLandingPageMinimapButton
    if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
        expButton:OnEnter()
        --GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        if InCombatLockdown() then
            return
        end
    else
        if InCombatLockdown() then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
    end
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI'), WoWTools_DataMixin.Icon.mid)
    GameTooltip:Show()
end





local function On_Click(self, d)
    if d=='LeftButton' then
        WoWTools_LoadUIMixin:ToggleLandingPage()

    elseif d=='RightButton' then
        WoWTools_MinimapMixin:Open_Menu(self)
    end
end












local function Init()
    if not Save().Icons.disabled and Save().Icons.hideAdd['WoWTools'] then
        return
    end

    local libDataBroker = LibStub:GetLibrary("LibDataBroker-1.1", true)
    local libDBIcon = LibStub("LibDBIcon-1.0", true)
    if not libDataBroker or not libDBIcon then
        return
    end

    local name='WoWTools'
    --if not libDBIcon:GetMinimapButton(name) then
    libDBIcon:Register(name, libDataBroker:NewDataObject('WoWTools', {
        OnClick=On_Click,--fun(displayFrame: Frame, buttonName: string)
        OnEnter=On_Enter,--fun(displayFrame: Frame)
        OnLeave=GameTooltip_Hide,--fun(displayFrame: Frame)
        OnTooltipShow=nil,--fun(tooltip: Frame)
        icon='Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools.tga',--string
        iconB=nil,--number,
        iconCoords=nil,--table,
        iconG=nil,--number,
        iconR=nil,--number,
        label=nil,--string,
        suffix=nil,--string,
        text=name,-- string,
        tocname=nil,--string,
        tooltip=WoWTools_DataMixin.addName,--Frame,
        type='data source',-- "data source"|"launcher",
        value=nil,--string,
    }), Save().miniMapPoint)


    local btn= libDBIcon:GetMinimapButton(name)
    if not btn then
        return
    end

    btn:EnableMouseWheel(true)
    btn:SetScript('OnMouseWheel', function(_, d)
        if d==1 then
            WoWTools_PanelMixin:Open(nil, '|A:talents-button-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置数据' or RESET_ALL_BUTTON_TEXT))
        else
            WoWTools_PanelMixin:Open(nil, WoWTools_MinimapMixin.addName)
        end
    end)
    --WoWTools_MinimapMixin.MiniButton= btn

    Init=function()end
end




function WoWTools_MinimapMixin:Init_Icon()
   Init()
end




--[[

function WowTools_OnAddonCompartmentClick(self, d)

    if d=='LeftButton' then
        WoWTools_PanelMixin:Open(nil, WoWTools_MinimapMixin.addName)

    elseif d=='RightButton' then
        WoWTools_MinimapMixin:Open_Menu(self)
    end
end



function WowTools_OnAddonCompartmentFuncOnEnter(_, root)
    MenuUtil.ShowTooltip(root, function(tooltip)
        tooltip:SetText(WoWTools_DataMixin.addName)
    end)
end]]
   --[[print(self, ...)
    local expButton=ExpansionLandingPageMinimapButton
    if expButton and expButton.OnEnter and expButton.title then--Minimap.lua
        expButton:OnEnter()
        GameTooltip:AddLine(' ')
    else
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
    end


    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '选项' or SETTINGS_TITLE , WoWTools_DataMixin.Icon.mid)

    if self and type(self)=='table' then
        if _G['LibDBIcon10_WoWTools'] and _G['LibDBIcon10_WoWTools']:IsMouseWheelEnabled() then
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.mid)
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, 'Alt'..WoWTools_DataMixin.Icon.right)
        end
    end
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT , 'Shift'..WoWTools_DataMixin.Icon.left)

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MinimapMixin.addName)
    GameTooltip:Show()
end]]
