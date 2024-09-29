local id, e = ...
local addName
WoWTools_LFDMixin={
    Save={
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
    },
    LFDButton=nil,
    TipsButton=nil,--小眼睛, 更新信息
}

local LFDButton

local function Save()
    return WoWTools_LFDMixin.Save
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
    WoWTools_ButtonMixin.LFDButton= LFDButton
    
    --自动离开,指示图标
    LFDButton.leaveInstance=LFDButton:CreateTexture(nil, 'ARTWORK')
    LFDButton.leaveInstance:SetPoint('BOTTOMLEFT',4, 0)
    LFDButton.leaveInstance:SetSize(12,12)
    LFDButton.leaveInstance:SetAtlas(e.Icon.toLeft)
    LFDButton.leaveInstance:Hide()
    
    LFDButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' and self.dungeonID then
            if self.type==LE_LFG_CATEGORY_LFD then
                e.call(LFDQueueFrame_SetType, self.dungeonID)
                e.call(LFDQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_RF then
                e.call(RaidFinderQueueFrame_SetRaid, self.dungeonID)
                e.call(RaidFinderQueueFrame_Join)
            elseif self.type==LE_LFG_CATEGORY_SCENARIO then

            end
        else
            WoWTools_LFDMixin:Init_Menu(self)            
        end
    end)

    LFDButton:SetScript('OnEnter',function(self)
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
        self:state_enter()--Init_Menu)
    end)

    LFDButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        if WoWTools_LFDMixin.TipsButton and WoWTools_LFDMixin.TipsButton:IsShown() then
            WoWTools_LFDMixin.TipsButton:SetButtonState('NORMAL')
        end
        self:state_leave()
    end)

    WoWTools_LFDMixin:Init_Queue_Status()--建立，小眼睛, 更新信息
    WoWTools_LFDMixin:Loot_Plus()--历史, 拾取框
    WoWTools_LFDMixin:Roll_Plus()--自动 ROLL
    WoWTools_LFDMixin:Init_RolePollPopup()    
    WoWTools_LFDMixin:Init_Exit_Instance()--离开副本
    WoWTools_LFDMixin:Init_LFG_Plus()--
    WoWTools_LFDMixin:Role_CheckInfo()--职责确认，信息    
    WoWTools_LFDMixin:Init_Holiday()--节日, 提示, button.texture
    WoWTools_LFDMixin:Init_RepopMe()--仅限战场，释放, 复活



    LFGDungeonReadyDialog:HookScript("OnShow", function(self)--自动进入FB
        e.PlaySound()--播放, 声音
        e.Ccool(self, nil, 38, nil, true, true)
    end)

    PVPTimerFrame:HookScript('OnShow', function(self2)
        e.PlaySound()--播放, 声音
        e.Ccool(self2, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)--冷却条
    end)
end














--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_LFDMixin.Save= WoWToolsSave['ChatButton_LFD'] or WoWTools_LFDMixin.Save
            WoWTools_LFDMixin.Save.sec= WoWTools_LFDMixin.Save.sec or 3

            WoWTools_LFDMixin.addName= '|A:groupfinder-eye-frame:0:0|a'..(e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)

            LFDButton= WoWTools_ChatButtonMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)

            if LFDButton then--禁用Chat Button
                
                Init()
        
                self:RegisterEvent('CORPSE_IN_RANGE')--仅限战场，释放, 复活
                self:RegisterEvent('PLAYER_DEAD')
                self:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')
                self:RegisterEvent('UPDATE_BATTLEFIELD_STATUS')
                self:RegisterEvent('GROUP_LEFT')
                self:RegisterEvent('PLAYER_ROLES_ASSIGNED')--职责确认
            end

            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_LFD']= WoWTools_LFDMixin.Save
        end




    end
end)

