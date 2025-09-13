
--local addName
local P_Save={
    leaveInstance=WoWTools_DataMixin.Player.husandro,--自动离开,指示图标
    autoROLL= WoWTools_DataMixin.Player.husandro,--自动,战利品掷骰
    --disabledLootPlus=true 禁用，战利品Plus
    --hideDontEnterMenu=true 隐藏，不可能副本，列表
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











local function Init(btn)
    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 5, -5)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -7, 7)

    --btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    --btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)

    --自动离开,指示图标
    btn.leaveInstance=btn:CreateTexture(nil, 'ARTWORK', nil, 1)
    btn.leaveInstance:SetPoint('BOTTOMLEFT',4, 0)
    btn.leaveInstance:SetSize(12,12)
    btn.leaveInstance:SetAtlas(WoWTools_DataMixin.Icon.toLeft)
    btn.leaveInstance:Hide()


    function btn:set_tooltip()
        self:set_owner()
        WoWTools_ChallengeMixin:ActivitiesTooltip()--周奖励，提示

        if self.name and (self.dungeonID or self.RaidID) then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(self.name..WoWTools_DataMixin.Icon.left)
        end
        if _G['WoWToolsChatToolsLFDTooltipButton'] then
            _G['WoWToolsChatToolsLFDTooltipButton']:SetButtonState('PUSHED')
        end
        GameTooltip:Show()
    end

    WoWTools_LFDMixin:Init_Menu(btn)


    function btn:set_OnMouseDown()
        if self.dungeonID then
            if self.type==LE_LFG_CATEGORY_LFD then
                WoWTools_DataMixin:Call(LFDQueueFrame_SetType, self.dungeonID)
                WoWTools_DataMixin:Call(LFDQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_RF then
                WoWTools_DataMixin:Call(RaidFinderQueueFrame_SetRaid, self.dungeonID)
                WoWTools_DataMixin:Call(RaidFinderQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_SCENARIO then

            end
            self:CloseMenu()
            self:set_tooltip()
        else
            return true
        end
    end


    function btn:set_OnLeave()
        if _G['WoWToolsChatToolsLFDTooltipButton'] then
           _G['WoWToolsChatToolsLFDTooltipButton']:SetButtonState('NORMAL')
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

    Init=function()end
end












local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['ChatButton_LFD']=  WoWToolsSave['ChatButton_LFD'] or P_Save
    WoWToolsSave['ChatButton_LFD'].sec= WoWToolsSave['ChatButton_LFD'].sec or 5
    P_Save=nil

    WoWTools_LFDMixin.addName= '|A:groupfinder-eye-frame:0:0|a'..(WoWTools_DataMixin.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)

    WoWTools_LFDMixin.LFDButton= WoWTools_ChatMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)

    if WoWTools_LFDMixin.LFDButton then--禁用Chat Button
        Init(WoWTools_LFDMixin.LFDButton)
    end
    self:UnregisterEvent(event)
end)