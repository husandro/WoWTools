local id, e = ...
WoWTools_MarkerMixin={
Save={
    autoSet=true,
    tank= 2,
    tank2= 6,
    healer= 1,
    isSelf= e.Player.husandro and 4 or nil,

    countdown=7,
    groupReadyTips=true,
    tipsTextSacle=1,

    markersScale=1,
    markersFrame= e.Player.husandro,
    FrameStrata='MEDIUM',
    pingTime= e.Player.husandro,--显示ping冷却时间
    autoReady=0,
},
Color={
    [1]={r=1, g=1, b=0, col='|cffffff00'},--星星, 黄色
    [2]={r=1, g=0.45, b=0.04, col='|cffff7f3f'},--圆形, 橙色
    [3]={r=1, g=0, b=1, col='|cffa335ee'},--菱形, 紫色
    [4]={r=0, g=1, b=0, col='|cff1eff00'},--三角, 绿色
    [5]={r=0.6, g=0.6, b=0.6, col='|cffffffff'},--月亮, 白色
    [6]={r=0.1, g=0.2, b=1, col='|cff0070dd'},--方块, 蓝色
    [7]={r=1, g=0, b=0, col='|cffff2020'},--十字, 红色
    [8]={r=1, g=1, b=1, col='|cffffffff'},--骷髅,白色
},
AutoReadyFrame=nil,--自动就绪
TankHealerFrame=nil,
MakerFrame=nil,
}


local function Save()
    return WoWTools_MarkerMixin.Save
end
local MarkerButton





function WoWTools_MarkerMixin:Set_Taget(unit, index)--设置,目标,标记
    local marker= GetRaidTargetIndex(unit)
    if not marker and index==0 or not UnitExists(unit) or not CanBeRaidTarget(unit) or marker==index then
        return
    end
    SetRaidTarget(unit, index)
end
















--初始
local function Init()
    WoWTools_MarkerMixin.MarkerButton= MarkerButton

    --自动就绪, 主图标, 提示
    MarkerButton.ReadyTextrueTips=MarkerButton:CreateTexture(nil,'OVERLAY')
    MarkerButton.ReadyTextrueTips:SetPoint('TOP')

    local size=MarkerButton:GetWidth()/2
    MarkerButton.ReadyTextrueTips:SetSize(size, size)
    function MarkerButton.ReadyTextrueTips:settings()
        if Save().autoReady==1 then
            MarkerButton.ReadyTextrueTips:SetAtlas(e.Icon.select)
        elseif Save().autoReady==2 then
            MarkerButton.ReadyTextrueTips:SetAtlas('auctionhouse-ui-filter-redx')
        else
            MarkerButton.ReadyTextrueTips:SetTexture(0)
        end
    end
    MarkerButton.ReadyTextrueTips:settings()





    function MarkerButton:settings()--主图标,是否有权限
        if not IsInGroup() and Save().isSelf then
            self.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save().isSelf)
            self.texture:SetDesaturated(false)
        else
            local raid= IsInRaid()
            local enabled= not WoWTools_MapMixin:IsInPvPArea()
                    and (
                            (raid and WoWTools_GroupMixin:isLeader())--队长(团长)或助理
                        or (GetNumGroupMembers()>1 and not raid)
                    )
            self.texture:SetDesaturated(not enabled)
            self.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save().tank)
        end
    end
    --MarkerButton:settings()--主图标,是否有权限

    MarkerButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    MarkerButton:RegisterEvent('GROUP_ROSTER_UPDATE')
    MarkerButton:RegisterEvent('GROUP_LEFT')
    MarkerButton:RegisterEvent('GROUP_JOINED')
    MarkerButton:SetScript("OnEvent", MarkerButton.settings)





    MarkerButton:SetScript("OnClick", function(self, d)
        if d=='LeftButton' then
            WoWTools_MarkerMixin.TankHealerFrame:on_click()
        else
            WoWTools_MarkerMixin:Init_Menu(self)
        end
    end)

    function MarkerButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_MarkerMixin.addName, (e.onlyChinese and '标记' or EVENTTRACE_MARKER)..e.Icon.left)
        if IsInGroup() then
            e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().tank))
            if not IsInRaid() then
                e.tips:AddLine(e.Icon.HEALER..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().healer))
            else
                e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().tank2))
            end
        elseif Save().isSelf then
            e.tips:AddLine('|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().isSelf))
        end
        e.tips:Show()
    end



    MarkerButton:SetScript('OnLeave', function(self)
        if self.groupReadyTips then
            self.groupReadyTips:SetButtonState('NORMAL')
        end
        e.tips:Hide()
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(false)
        end
        self:state_leave()
    end)
    MarkerButton:SetScript('OnEnter', function(self)
        if self.groupReadyTips and self.groupReadyTips:IsShown() then
            self.groupReadyTips:SetButtonState('PUSHED')
        end
        self:set_tooltip()
        self:state_enter()--WoWTools_MarkerMixin.Init_Menu(self))
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(true)
        end
    end)




    WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
    WoWTools_MarkerMixin:Init_Ready_Tips_Button()--队员,就绪,提示信息
    WoWTools_MarkerMixin:Init_Tank_Healer()--设置队伍标记
    WoWTools_MarkerMixin:Init_AutoReady()
end
















--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWTools_MarkerMixin.Save= WoWToolsSave['ChatButton_Markers'] or WoWTools_MarkerMixin.Save

            WoWTools_MarkerMixin.addName= '|A:Bonus-Objective-Star:0:0|a'..(e.onlyChinese and '队伍标记' or BINDING_HEADER_RAID_TARGET)

            MarkerButton= WoWTools_ChatButtonMixin:CreateButton('Markers', WoWTools_MarkerMixin.addName)

            if MarkerButton then

                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Markers']=WoWTools_MarkerMixin.Save
        end
    end
end)

