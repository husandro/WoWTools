local id, e = ...
--local addName
WoWTools_LFDMixin.Save={
    leaveInstance=e.Player.husandro,--自动离开,指示图标
    autoROLL= e.Player.husandro,--自动,战利品掷骰
    --disabledLootPlus=true,--禁用，战利品Plus
    ReMe=true,--仅限战场，释放，复活
    autoSetPvPRole=e.Player.husandro,--自动职责确认， 排副本
    LFGPlus= e.Player.husandro,--预创建队伍增强
    tipsScale=1,--提示内容,缩放
    sec=3,--时间 timer
    wow={
        --['island']=0,
        --[副本名称]=0,
    }
}

local LFDButton

local function Save()
    return WoWTools_LFDMixin.Save
end








--离开所有队列
function WoWTools_LFDMixin:Leave_All_LFG(isCheck)
    local isInGroup= IsInGroup()
    local isLeavel= not isCheck and (isInGroup and UnitIsGroupLeader("player") or not isInGroup)
    local num=0
    if GetLFGQueueStats(LE_LFG_CATEGORY_SCENARIO) then
        if isLeavel then
            LeaveLFG(LE_LFG_CATEGORY_SCENARIO)
        end
        num= num+1
    end

    --pve
    for i=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(i) then
            for _ in pairs(GetLFGQueuedList(i) or {}) do
                num= num+1
            end
        end
        if isLeavel then
            LeaveLFG(i)
        end
    end

    if C_PetBattles.GetPVPMatchmakingInfo() then--Pet Battles
        if isLeavel then
            C_PetBattles.StopPVPMatchmaking()--PetC_PetBattles.DeclineQueuedPVPMatch()
        end
        num= num+1
    end

    if isLeavel then
        RejectProposal()--拒绝 LFG 邀请并离开队列
    end

    for i=1, MAX_WORLD_PVP_QUEUES or 2 do --World PvP
        local queueID = select(3, GetWorldPVPQueueStatus(i))
        if queueID and queueID>0 then
            if isLeavel then
                BattlefieldMgrExitRequest(queueID)
            end
            num= num+1
        end
    end

--自己，创建
    if C_LFGList.HasActiveEntryInfo() then
        num= num+1
        if isLeavel then
            C_LFGList.RemoveListing()
            C_LFGList.ClearSearchResults()
        end
    end

    --申请，列表
    local apps= C_LFGList.GetApplications() or {}
    if isLeavel then
        for _, resultID in pairs(apps) do
            C_LFGList.CancelApplication(resultID)
        end
    end
    num= num+ #apps


    return num
end








function WoWTools_LFDMixin:Get_Instance_Num(name)
    name= name or GetInstanceInfo()
    local num = Save().wow[name] or 0
    local text
    if num >0 then
        text= '|cnGREEN_FONT_COLOR:#'..num..'|r '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    else
        text= '0 '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
    end
    return text , num
end






function WoWTools_LFDMixin:Set_LFDButton_Data(dungeonID, type, name, texture, atlas)--设置图标, 点击,提示
    LFDButton.dungeonID=dungeonID
    LFDButton.name=name
    LFDButton.type=type--LE_LFG_CATEGORY_LFD LE_LFG_CATEGORY_RF LE_LFG_CATEGORY_SCENARIO
    if atlas then
        LFDButton.texture:SetAtlas(atlas)
    elseif texture then
        LFDButton.texture:SetTexture(texture)
    else
        if not Save().hideQueueStatus then
            LFDButton.texture:SetAtlas('groupfinder-eye-frame')
        else
            LFDButton.texture:SetAtlas('UI-HUD-MicroMenu-Groupfinder-Mouseover')
        end
    end
end












local function Init()
    WoWTools_LFDMixin.LFDButton= LFDButton

    --自动离开,指示图标
    LFDButton.leaveInstance=LFDButton:CreateTexture(nil, 'ARTWORK')
    LFDButton.leaveInstance:SetPoint('BOTTOMLEFT',4, 0)
    LFDButton.leaveInstance:SetSize(12,12)
    LFDButton.leaveInstance:SetAtlas(e.Icon.toLeft)
    LFDButton.leaveInstance:Hide()

    function LFDButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        WoWTools_WeekMixin:Activities({showTooltip=true})--周奖励，提示

        if self.name and (self.dungeonID or self.RaidID) then
            e.tips:AddLine(' ')
            e.tips:AddLine(self.name..e.Icon.left)
        end
        if WoWTools_LFDMixin.TipsButton and WoWTools_LFDMixin.TipsButton:IsShown() then
            WoWTools_LFDMixin.TipsButton:SetButtonState('PUSHED')
        end
        e.tips:Show()
    end

    LFDButton:SetupMenu(function(...)
        WoWTools_LFDMixin:Init_Menu(...)
    end)

    function LFDButton:set_OnMouseDown()
        if self.dungeonID then
            if self.type==LE_LFG_CATEGORY_LFD then
                e.call(LFDQueueFrame_SetType, self.dungeonID)
                e.call(LFDQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_RF then
                e.call(RaidFinderQueueFrame_SetRaid, self.dungeonID)
                e.call(RaidFinderQueueFrame_Join)
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


    PVPTimerFrame:HookScript('OnShow', function(self2)
        e.PlaySound()--播放, 声音
        e.Ccool(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)
end









local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1 == id then
            WoWTools_LFDMixin.Save= WoWToolsSave['ChatButton_LFD'] or WoWTools_LFDMixin.Save
            WoWTools_LFDMixin.Save.sec= WoWTools_LFDMixin.Save.sec or 3

            WoWTools_LFDMixin.addName= '|A:groupfinder-eye-frame:0:0|a'..(e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)

            LFDButton= WoWTools_ChatButtonMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)

            if LFDButton then--禁用Chat Button                
                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_LFD']= WoWTools_LFDMixin.Save
        end
    end
end)