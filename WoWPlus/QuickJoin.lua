local id, e = ...
local Save= {}
local addName=	QUICK_JOIN

local function set_SOCIAL_QUEUE_UPDATE()
    local self=QuickJoinToastButton
    if not self then
        return
    end

    if not self.quickJoinText then
        self.quickJoinText= self:CreateFontString()
        self.quickJoinText:SetFontObject('NumberFontNormal');
        self.quickJoinText:SetPoint('TOPRIGHT', -6, -3);

        self:SetScript("OnMouseDown", function(self2, b)
                if b=='RightButton' then
                    ToggleQuickJoinPanel()
                elseif b=='LeftButton' then
                    ToggleFriendsPanel();
                end
        end)
        self:SetScript("OnMouseWheel", function(self2, b)
                if b==1 then
                    ToggleFriendsFrame(2);
                elseif b==-1 then
                    ToggleRaidFrame();
                end
        end)
        self:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.Icon.left..(e.onlyChinse and '好友' or FRIENDS))
            e.tips:AddLine(e.Icon.mid..(e.onlyChinse and '查询' or WHO))
            e.tips:AddLine(e.Icon.mid..(e.onlyChinse and '团队' or RAID))
            e.tips:AddLine(e.Icon.right..(e.onlyChinse and '快速加入' or QUICK_JOIN))
            e.tips:Show()
        end)
        self:SetScript('OnLeave', function() e.tips:Hide() end)
    end

    local n=#C_SocialQueue.GetAllGroups();
    if n==0 then n='' end
    self.quickJoinText:SetText(n);
end



--######
--初始化
--######
local function Init()
    set_SOCIAL_QUEUE_UPDATE()

    hooksecurefunc(QuickJoinEntryMixin, 'ApplyToFrame', function(self, frame)
            if not frame then return end

            local icon, icon2 = nil, '';--角色图标
            if self.guid then
                local guid= select(8, C_SocialQueue.GetGroupInfo(self.guid));
                if guid then
                    local _, class, _, race, sex = GetPlayerInfoByGUID(guid);
                    if race and sex then
                        icon=e.Race(nil, race, sex, true);
                    end
                    if class then
                        icon2='groupfinder-icon-class-'..class;
                    end
                end

                if not frame.chat then--悄悄话
                    frame.chat=e.Cbtn(frame, nil, nil, nil, nil, true, {20,20})
                    frame.chat:SetPoint('RIGHT', (frame.Icon or frame), 'LEFT')
                    frame.chat:SetScript('OnMouseDown',function()
                        local player=frame.Members[1].playerLink
                        if player then
                            local link, text = LinkUtil.SplitLink(player);
                            SetItemRef(link, text, "LeftButton");
                        end
                    end)
                    frame:HookScript("OnDoubleClick", function()
                        QuickJoinFrame:JoinQueue();
                    end);
                end
                icon=icon or 'communities-icon-chat';
                frame.chat:SetNormalAtlas(icon);

                if not frame.class and icon2 then--角色职业图标
                    frame.class=frame:CreateTexture();
                    frame.class:SetSize(20,20);
                    frame.class:SetPoint('RIGHT', frame, 'RIGHT', 0,0);
                end

                if frame.class then--种族图标
                    if icon2 then
                        frame.class:SetAtlas(icon2)
                    end
                    frame.class:SetShown(icon2 and true or false)
                end
            end
    end)

    hooksecurefunc(QuickJoinRoleSelectionFrame, 'ShowForGroup', function(self, guid)--职责选择框
        local t, h ,dps=self.RoleButtonTank.CheckButton, self.RoleButtonHealer.CheckButton, self.RoleButtonDPS.CheckButton;--选择职责
        local t3, h3, dps3 =t:GetChecked(), h:GetChecked(), dps:GetChecked();
        if not t3 and  not h3 and not dps3 then
            local sid=GetSpecialization();
            if sid and sid>0 then
                local role = select(5, GetSpecializationInfo(sid));
                if role=='TANK' then
                    t:Click();
                elseif role=='HEALER' then
                    h:Click();
                elseif role=='DAMAGER' then
                    dps:Click();
                end
            end
        end

        local player= select(8, C_SocialQueue.GetGroupInfo(guid));--玩家名称
        if player then
            local name, realm = select(6, GetPlayerInfoByGUID(player));
            if name then
                if not self.name then
                    self.name=self:CreateFontString();
                    self.name:SetFontObject('GameFontNormal');
                    self.name:SetPoint('BOTTOM', self.CancelButton, 'TOPLEFT', 2, 0);
                end
                if realm and realm=='' then realm=nil end
                name=name..(realm and ' - '..realm or '');
                self.name:SetText(name);
            else
                if self.name then self.name:SetText('') end
            end
        end
    end);

    if QuickJoinToastButton.Toast then
        QuickJoinToastButton.Toast:ClearAllPoints()
        QuickJoinToastButton.Toast:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT')
    end
end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('SOCIAL_QUEUE_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '快速加入' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='SOCIAL_QUEUE_UPDATE' then
        set_SOCIAL_QUEUE_UPDATE()
    end
end)
