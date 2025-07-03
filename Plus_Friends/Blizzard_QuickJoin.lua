--快速加入, 模块



local function Init()--快速加入, 初始化 QuickJoin.lua

    QuickJoinToastButton.Toast:ClearAllPoints()
    QuickJoinToastButton.Toast:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT', 29, 2)

    QuickJoinToastButton.Toast2:ClearAllPoints()
    QuickJoinToastButton.Toast2:SetPoint('BOTTOMLEFT', QuickJoinToastButton.Toast or QuickJoinToastButton, 'TOPLEFT', 29 ,2)

    QuickJoinToastButton.quickJoinText= WoWTools_LabelMixin:Create(QuickJoinToastButton, {color=true})--:CreateFontString()
    QuickJoinToastButton.quickJoinText:SetPoint('TOPRIGHT', -6, -3)
    local function set_QuickJoinToastButton()
        local n=#C_SocialQueue.GetAllGroups()
        QuickJoinToastButton.quickJoinText:SetText(n~=0 and n or '')
    end
    EventRegistry:RegisterFrameEventAndCallback("SOCIAL_QUEUE_UPDATE", function()
        set_QuickJoinToastButton()
    end)
    set_QuickJoinToastButton()
    --[[hooksecurefunc(QuickJoinToastButton, 'UpdateEntry', function(self)
        local n=#C_SocialQueue.GetAllGroups()
        self.quickJoinText:SetText(n~=0 and n or '')

        set_QuickJoinToastButton()
    end)]]








    hooksecurefunc(QuickJoinEntryMixin, 'ApplyToFrame', function(self, frame)
        if not frame then
            return
        end
        for i=1, #self.displayedMembers do
            local guid=self.displayedMembers[i].guid
            local nameObj = frame.Members[i]
            local name = nameObj and nameObj.name
            if guid and name then
                local _, class, _, race, sex = GetPlayerInfoByGUID(guid)
                local raceTexture=WoWTools_UnitMixin:GetRaceIcon(nil, guid, race, {sex=sex})
                local hex= select(4, GetClassColor(class))
                hex= '|c'..hex
                name= (raceTexture or '').. name
                name=hex..name..'|r'
                nameObj:SetText(name)

                nameObj.guid=guid
                nameObj.col= hex
                if not nameObj:IsMouseEnabled() then
                    nameObj:EnableMouse(true)
                    nameObj:SetScript('OnLeave', GameTooltip_Hide)
                    nameObj:SetScript('OnEnter', function(self2)
                        GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                        GameTooltip:ClearLines()
                        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '/密语' or SLASH_SMART_WHISPER2, self2.col..self2.name)
                        GameTooltip:AddLine(' ')
                        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FriendsMixin.addName)
                        GameTooltip:Show()
                    end)
                    nameObj:SetScript('OnMouseDown',function(self2)
                        WoWTools_ChatMixin:Say(nil, self2.name, self2.guid2 and C_BattleNet.GetGameAccountInfoByGUID(self2.guid))
                    end)
                end
            end
        end

        if not frame.OnDoubleClick then--设置, 双击, 加入
            frame:HookScript("OnDoubleClick", function()--QuickJoin.lua
                QuickJoinFrame:JoinQueue()
                local frame2=LFGListApplicationDialog
                if frame2:IsShown() then
                    if not frame2.TankButton.CheckButton:GetChecked() and not frame2.HealerButton.CheckButton:GetChecked() and not frame2.DamagerButton.CheckButton:GetChecked() then
                        local specID=GetSpecialization()--当前专精
                        if specID then
                            local role = select(5, GetSpecializationInfo(specID))
                            if role=='DAMAGER' and frame2.DamagerButton:IsShown() then
                                frame2.DamagerButton.CheckButton:SetChecked(true)

                            elseif role=='TANK' and frame2.TankButton:IsShown() then
                                frame2.TankButton.CheckButton:SetChecked(true)

                            elseif role=='HEALER' and frame2.HealerButton:IsShown() then
                                frame2.HealerButton.CheckButton:SetChecked(true)
                            end
                            LFGListApplicationDialog_UpdateValidState(frame2)
                        end
                    end
                    --[[if frame2.SignUpButton:IsEnabled() then
                        --frame2.SignUpButton:Click()
                    end]]
                end
            end)
        end

        local text--需求职责, 提示
        if self.guid then
            local canJoin, numQueues, needTank, needHealer, needDamage, isSoloQueuePart, questSessionActive, leaderGUID = C_SocialQueue.GetGroupInfo(self.guid)
            if canJoin then
                if numQueues and numQueues>0 then
                    text= '|cnGREEN_FONT_COLOR:'..numQueues..'|r'
                end
                if needTank or needHealer or needDamage then
                    text= (text or '')..(needTank and INLINE_TANK_ICON or '')..(needHealer and INLINE_HEALER_ICON or '')..(needDamage and INLINE_DAMAGER_ICON or '')
                end
                if questSessionActive then
                    text= (text or '')..'|A:QuestPortraitIcon-SandboxQuest:0:0|a'
                end
            end
        end
        if text and not frame.roleTips then
            frame.roleTips= WoWTools_LabelMixin:Create(frame)
            frame.roleTips:SetPoint('BOTTOMRIGHT')
        end
        if frame.roleTips then
            frame.roleTips:SetText(text or '')
        end
    end)










    hooksecurefunc(QuickJoinRoleSelectionFrame, 'ShowForGroup', function(self, guid)--职责选择框
        local t, h ,dps=self.RoleButtonTank.CheckButton, self.RoleButtonHealer.CheckButton, self.RoleButtonDPS.CheckButton--选择职责
        local t3, h3, dps3 =t:GetChecked(), h:GetChecked(), dps:GetChecked()
        if not t3 and not h3 and not dps3 then
            local sid=GetSpecialization()
            if sid and sid>0 then
                local role = select(5, GetSpecializationInfo(sid))
                if role=='TANK' then
                    t:Click()
                elseif role=='HEALER' then
                    h:Click()
                elseif role=='DAMAGER' then
                    dps:Click()
                end
            end
        end

        local leaderGUID = select(8, C_SocialQueue.GetGroupInfo(guid))--玩家名称
        local link= leaderGUID and WoWTools_UnitMixin:GetPlayerInfo(nil, leaderGUID, nil, {reName=true, reRealm=true, reLink=true,})
        if link and not self.nameInfo then
            self.nameInfo= WoWTools_LabelMixin:Create(self)
            self.nameInfo:SetPoint('BOTTOM', self.CancelButton, 'TOPLEFT', 2, 0)
            self:HookScript('OnHide', function(self2)
                if self2.nameInfo then
                    self2.nameInfo:SetText('')
                end
            end)
        end
        if self.nameInfo then
            self.nameInfo:SetText(link or '')
        end

        if self.AcceptButton:IsEnabled() and not IsModifierKeyDown() then
            local tank2, healer2, dps2= self:GetSelectedRoles()
            self.AcceptButton:Click()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_FriendsMixin.addName,
                    tank2 and INLINE_TANK_ICON, healer2 and INLINE_HEALER_ICON, dps2 and INLINE_DAMAGER_ICON,
                    WoWTools_TextMixin:GetEnabeleDisable(false)..'Alt',
                    link
                )
        end
    end)


    Init=function()end
end





function WoWTools_FriendsMixin:Blizzard_QuickJoin()
    Init()
end