local id, e = ...
WoWTools_MarkerMixin.Save={
    autoSet=true,

    tank= 2,
    tank2= 6,
    healer= 1,
    isSelf= e.Player.husandro and 4 or nil,
    target= e.Player.husandro and 7 or nil,

    countdown=7,
    groupReadyTips=true,
    tipsTextSacle=1,

    markersScale=1,
    markersFrame= e.Player.husandro,
    showMakerFrameBackground=true,
    FrameStrata='MEDIUM',
    pingTime= e.Player.husandro,--显示ping冷却时间

    --autoReady=nil, 1,就绪， 2未就绪， nil禁用
    autoReadySeconds=3,
}

local function Save()
    return WoWTools_MarkerMixin.Save
end
local MarkerButton
















--初始
local function Init()
    WoWTools_MarkerMixin.MarkerButton= MarkerButton

    --[[自动就绪, 主图标, 提示
    ReadyCheckFrame.readyLabel= WoWTools_LabelMixin:Create(ReadyCheckFrame)
    ReadyCheckFrame.readyLabel:SetPoint('BOTTOM', ReadyCheckFrame, 'TOP')
]]
    MarkerButton.ready=MarkerButton:CreateTexture(nil,'OVERLAY')
    MarkerButton.ready:SetPoint('TOP', -6, 6)
    MarkerButton.ready:SetSize(MarkerButton:GetWidth()/2, MarkerButton:GetWidth()/2)

    function MarkerButton:settings()--主图标,是否有权限
        local index
        if not WoWTools_MapMixin:IsInPvPArea() then
            if GetNumGroupMembers()<=1 then
                index= Save().isSelf or Save().target
            else
                local raid= IsInRaid()
                if (raid and WoWTools_GroupMixin:isLeader() or not raid) then
                    index= Save().tank or Save().healer
                end
            end

            if index then
                self.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
            end
        end
        self.texture:SetShown(index)
        self.texture:SetDesaturated(not Save().autoSet)

--就绪，图标
        local _, atlas= WoWTools_MarkerMixin:Get_ReadyTextIcon()
        if atlas then
            self.ready:SetAtlas(atlas)
        else
            self.ready:SetTexture(0)
        end

        --ReadyCheckFrame.readyLabel:SetText(text or '')
    end


    MarkerButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    MarkerButton:RegisterEvent('GROUP_ROSTER_UPDATE')
    MarkerButton:RegisterEvent('GROUP_LEFT')
    MarkerButton:RegisterEvent('GROUP_JOINED')
    MarkerButton:SetScript("OnEvent", MarkerButton.settings)

     WoWTools_MarkerMixin:Setup_Menu()

    function MarkerButton:set_OnMouseDown()
        WoWTools_MarkerMixin:Set_TankHealer(true)
    end

    function MarkerButton:tooltip()
        local autoSet, tank, tank2, healer, isSelf, target= Save().autoSet, Save().tank, Save().tank2, Save().healer, Save().isSelf, Save().target
        GameTooltip:AddDoubleLine(
            (autoSet and '|cnGREEN_FONT_COLOR:' or '|cff828282')
            ..(e.onlyChinese and '自动标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, EVENTTRACE_MARKER)),
            e.GetEnabeleDisable(autoSet)
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            (tank and WoWTools_MarkerMixin:SetColor(tank).col or '|cff828282')
            ..e.Icon.TANK..(e.onlyChinese and '坦克' or TANK),
           tank and format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', tank) or ''
        )
        GameTooltip:AddDoubleLine(
            (tank2 and WoWTools_MarkerMixin:SetColor(tank2).col or '|cff828282')
            ..e.Icon.TANK..(e.onlyChinese and '坦克' or TANK)..' 2',
           tank2 and format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', tank2) or ''
        )
        GameTooltip:AddDoubleLine(
            (healer and WoWTools_MarkerMixin:SetColor(healer).col or '|cff828282')
            ..e.Icon.HEALER..(e.onlyChinese and '治疗' or HEALER),
           healer and format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', healer) or ''
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            (isSelf and WoWTools_MarkerMixin:SetColor(isSelf).col or '|cff828282')
            ..'|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
            isSelf and format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', isSelf) or ''
        )
        GameTooltip:AddDoubleLine(
            (target and WoWTools_MarkerMixin:SetColor(target).col or '|cff828282')
            ..'|A:Target:0:0|a'..(e.onlyChinese and '目标' or TARGET),
            target and format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', target) or ''
        )
        GameTooltip:AddDoubleLine()
    end

     
    

    function MarkerButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        self:tooltip()
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_MarkerMixin.addName, (e.onlyChinese and '标记' or EVENTTRACE_MARKER)..e.Icon.left)
        GameTooltip:Show()
    end


    function MarkerButton:set_OnLeave()
        if self.groupReadyTips then
            self.groupReadyTips:SetButtonState('NORMAL')
        end
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(false)
        end
    end

    function MarkerButton:set_OnEnter()
        if self.groupReadyTips and self.groupReadyTips:IsShown() then
            self.groupReadyTips:SetButtonState('PUSHED')
        end
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(true)
        end
    end


    WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
    WoWTools_MarkerMixin:Init_Ready_Tips_Button()--队员,就绪,提示信息
    WoWTools_MarkerMixin:Init_Tank_Healer()--设置队伍标记
    WoWTools_MarkerMixin:Init_AutoReady()
end








local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1 == id then
            WoWTools_MarkerMixin.Save= WoWToolsSave['ChatButton_Markers'] or WoWTools_MarkerMixin.Save

            if WoWTools_MarkerMixin.Save.autoReady==0 then
                WoWTools_MarkerMixin.Save.autoReady= nil
            end
            WoWTools_MarkerMixin.Save.autoReadySeconds= WoWTools_MarkerMixin.Save.autoReadySeconds or 3

            WoWTools_MarkerMixin.addName= '|A:Bonus-Objective-Star:0:0|a'..(e.onlyChinese and '队伍标记' or BINDING_HEADER_RAID_TARGET)

            MarkerButton= WoWTools_ChatMixin:CreateButton('Markers', WoWTools_MarkerMixin.addName)

            if MarkerButton then
                Init()
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Markers']=WoWTools_MarkerMixin.Save
        end
    end
end)