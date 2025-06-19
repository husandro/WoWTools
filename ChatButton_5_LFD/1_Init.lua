
--local addName
local P_Save={
    leaveInstance=WoWTools_DataMixin.Player.husandro,--自动离开,指示图标
    autoROLL= WoWTools_DataMixin.Player.husandro,--自动,战利品掷骰
    --disabledLootPlus=true,--禁用，战利品Plus
    ReMe=true,--仅限战场，释放，复活
    autoSetPvPRole=WoWTools_DataMixin.Player.husandro,--自动职责确认， 排副本
    LFGPlus= WoWTools_DataMixin.Player.husandro,--预创建队伍增强
    tipsScale=1,--提示内容,缩放
    sec=5,--时间 timer
    wow={
        --['island']=0,
        --[副本名称]=0,
    }
}

local LFDButton









local function Init()
    LFDButton.IconMask:SetPoint("TOPLEFT", LFDButton, "TOPLEFT", 5, -5)
    LFDButton.IconMask:SetPoint("BOTTOMRIGHT", LFDButton, "BOTTOMRIGHT", -7, 7)

    --LFDButton.texture:SetPoint("TOPLEFT", LFDButton, "TOPLEFT", 4, -4)
    --LFDButton.texture:SetPoint("BOTTOMRIGHT", LFDButton, "BOTTOMRIGHT", -6, 6)

    --自动离开,指示图标
    LFDButton.leaveInstance=LFDButton:CreateTexture(nil, 'ARTWORK', nil, 1)
    LFDButton.leaveInstance:SetPoint('BOTTOMLEFT',4, 0)
    LFDButton.leaveInstance:SetSize(12,12)
    LFDButton.leaveInstance:SetAtlas(WoWTools_DataMixin.Icon.toLeft)
    LFDButton.leaveInstance:Hide()


    function LFDButton:set_tooltip()
        self:set_owner()
        WoWTools_ChallengeMixin:ActivitiesTooltip()--周奖励，提示

        if self.name and (self.dungeonID or self.RaidID) then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(self.name..WoWTools_DataMixin.Icon.left)
        end
        if WoWTools_LFDMixin.TipsButton and WoWTools_LFDMixin.TipsButton:IsShown() then
            WoWTools_LFDMixin.TipsButton:SetButtonState('PUSHED')
        end
        GameTooltip:Show()
    end

    LFDButton:SetupMenu(function(...)
        if LFDButton:IsVisible() then
            WoWTools_LFDMixin:Init_Menu(...)
        end
    end)

    function LFDButton:set_OnMouseDown()
        if self.dungeonID then
            if self.type==LE_LFG_CATEGORY_LFD then
                WoWTools_Mixin:Call(LFDQueueFrame_SetType, self.dungeonID)
                WoWTools_Mixin:Call(LFDQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_RF then
                WoWTools_Mixin:Call(RaidFinderQueueFrame_SetRaid, self.dungeonID)
                WoWTools_Mixin:Call(RaidFinderQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_SCENARIO then

            end
            self:CloseMenu()
            self:set_tooltip()
        else
            return true
        end
    end


    function LFDButton:set_OnLeave()
        if WoWTools_LFDMixin.TipsButton and WoWTools_LFDMixin.TipsButton:IsShown() then
            WoWTools_LFDMixin.TipsButton:SetButtonState('NORMAL')
        end
    end


    WoWTools_LFDMixin:Init_Queue_Status()--建立，小眼睛, 更新信息
    WoWTools_LFDMixin:Init_Loot_Plus()--历史, 拾取框
    WoWTools_LFDMixin:Init_Roll_Plus()--自动 ROLL
    WoWTools_LFDMixin:Init_RolePollPopup()
    WoWTools_LFDMixin:Init_Exit_Instance()--离开副本
    WoWTools_LFDMixin:Init_LFG_Plus()--
    WoWTools_LFDMixin:Init_Role_CheckInfo()--职责确认，信息    
    WoWTools_LFDMixin:Init_Holiday()--节日, 提示, button.texture
    WoWTools_LFDMixin:Init_RepopMe()--释放, 复活

    WoWTools_LFDMixin:Init_LFGDungeonReadyDialog()--确定，进入副本
    WoWTools_LFDMixin:Init_LFGListInviteDialog_Info()--队伍查找器, 邀请信息

    PVPTimerFrame:HookScript('OnShow', function(self2)
        WoWTools_Mixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)

    Init=function()end
end












local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then
            WoWToolsSave['ChatButton_LFD']=  WoWToolsSave['ChatButton_LFD'] or P_Save
            WoWToolsSave['ChatButton_LFD'].sec= WoWToolsSave['ChatButton_LFD'].sec or 5

            WoWTools_LFDMixin.addName= '|A:groupfinder-eye-frame:0:0|a'..(WoWTools_DataMixin.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)

            LFDButton= WoWTools_ChatMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)

            if LFDButton then--禁用Chat Button                
                WoWTools_LFDMixin.LFDButton= LFDButton
                
                Init()
            end
            self:UnregisterEvent(event)
        end
    end
end)