local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end








--预创建队伍增强
local function getIndex(values, val)
    local index={}
    for k,v in pairs(values) do
        index[v]=k
    end
    return index[val]
end








local function Init_LFGListSearchEntry_Update(self)
    local resultID = Save().LFGPlus and self.resultID
    if not resultID or not C_LFGList.HasSearchResultInfo(resultID) then
        return
    end

    local info = C_LFGList.GetSearchResultInfo(resultID)
    local categoryID= LFGListFrame.SearchPanel.categoryID
    local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
    local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus) or info.isDelisted

    local text, color, autoAccept = nil, nil, nil
    text=''
    if not isAppFinished then
        text, color= WoWTools_WeekMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore, true)--地下城, 分数
        if info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 then--PVP, 分数
            local text2, color2=WoWTools_WeekMixin:KeystoneScorsoColor(info.leaderPvpRatingInfo.rating)
            local icon= info.leaderPvpRatingInfo.tier and info.leaderPvpRatingInfo.tier>0 and ('|A:honorsystem-icon-prestige-'..info.leaderPvpRatingInfo.tier..':0:0|a') or '|A:pvptalents-warmode-swords:0:0|a'
            if info.isWarMode then
                text= icon..text2..' '..text
            else
                text= text..' '..icon..text2
            end
            color= info.isWarMode and color2 or color

        end
        color= color or {r=1,g=1,b=1}
        if info.numBNetFriends and info.numBNetFriends>0 then--好友, 数量
            text= text..' '..e.Icon.wow2..info.numBNetFriends
        end
        if info.numCharFriends and info.numCharFriends>0 then--好友, 数量
            text= text..' |A:socialqueuing-icon-group:0:0|a'..info.numCharFriends
        end
        if info.numGuildMates and info.numGuildMates>0 then--好友, 数量
            text= text..' |A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'..info.numCharFriends
        end
        autoAccept= info.autoAccept--自动, 邀请
    end
    if text~='' and not self.scorsoText then
        self.scorsoText= WoWTools_LabelMixin:Create(self, {justifyH='RIGHT'})
        self.scorsoText:SetPoint('TOPLEFT', self.DataDisplay.Enumerate, 0, 5)
        --self.scorsoText:SetPoint('RIGHT', self.DataDisplay.Enumerate.Icon5, 'LEFT', -2, 0)
    end
    if self.scorsoText then
        self.scorsoText:SetText(text)
        if color then
            self.Name:SetTextColor(color.r, color.g, color.b)
        end
    end
    if autoAccept and not self.autoAcceptTexture then--自动, 邀请
        self.autoAcceptTexture=self:CreateTexture(nil,'OVERLAY')
        self.autoAcceptTexture:SetPoint('LEFT')
        self.autoAcceptTexture:SetAtlas(e.Icon.select)
        self.autoAcceptTexture:SetSize(12,12)
        self.autoAcceptTexture:EnableMouse(true)
        self.autoAcceptTexture:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '自动接受' or LFG_LIST_AUTO_ACCEPT)
            e.tips:AddDoubleLine(e.addName, WoWTools_LFDMixin.addName)
            e.tips:Show()
        end)
        self.autoAcceptTexture:SetScript("OnLeave", GameTooltip_Hide)
    end
    if self.autoAcceptTexture then
        self.autoAcceptTexture:SetShown(autoAccept)
    end

    local realm, realmText
    if info.leaderName and not isAppFinished then
        local server= info.leaderName:match('%-(.+)') or e.Player.realm
        server=e.Get_Region(server)--服务器，EU， US {col, text}
        realm= server and server.col
        realmText=server and server.realm
    end
    if realm and not self.realmText then
        self.realmText= WoWTools_LabelMixin:Create(self)
        self.realmText:SetPoint('BOTTOMRIGHT', self.DataDisplay.Enumerate,0,-3)
        self.realmText:EnableMouse(true)
        self.realmText:SetScript('OnEnter', function(self2)
            if self2.realm then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '服务器' or 'Realm', '|cnGREEN_FONT_COLOR:'..self2.realm)
                e.tips:AddDoubleLine(e.addName, WoWTools_LFDMixin.addName)
                e.tips:Show()
            end
        end)
        self.realmText:SetScript("OnLeave", GameTooltip_Hide)
    end

    if self.realmText then
        self.realmText.realm= realmText
        self.realmText:SetText(realm or '')
    end

    if not self.OnDoubleClick then
        self:SetScript('OnDoubleClick', function()--LFGListApplicationDialogSignUpButton_OnClick(LFDButton) LFG队长分数, 双击加入 LFGListSearchPanel_UpdateResults
            if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
                LFGListFrame.SearchPanel.SignUpButton:Click()
            end
            local frame=LFGListApplicationDialog
            if not frame.TankButton.CheckButton:GetChecked() and not frame.HealerButton.CheckButton:GetChecked() and not frame.DamagerButton.CheckButton:GetChecked() then
                local specID=GetSpecialization()--当前专精
                if specID then
                    local role = select(5, GetSpecializationInfo(specID))
                    if role=='DAMAGER' and frame.DamagerButton:IsShown() then
                        frame.DamagerButton.CheckButton:SetChecked(true)

                    elseif role=='TANK' and frame.TankButton:IsShown() then
                        frame.TankButton.CheckButton:SetChecked(true)

                    elseif role=='HEALER' and frame.HealerButton:IsShown() then
                        frame.HealerButton.CheckButton:SetChecked(true)
                    end
                    LFGListApplicationDialog_UpdateValidState(frame)
                end
            end
            if frame:IsShown() and frame.SignUpButton:IsEnabled() then
                frame.SignUpButton:Click()
            end
        end)
    end

    local orderIndexes = {}
    if categoryID == 2 and not isAppFinished then--_G["ShowRIORaitingWA1NotShowClasses"] ~= true--https://wago.io/klC4qqHaF
        for i=1, info.numMembers do
            --local role, class, classLocalized, specLocalized, isLeader = C_LFGList.GetSearchResultMemberInfo(resultID, i)
            local role, class, _, specLocalized, isLeader = C_LFGList.GetSearchResultMemberInfo(resultID, i)
            local orderIndex = getIndex(LFG_LIST_GROUP_DATA_ROLE_ORDER, role)
            table.insert(orderIndexes, {orderIndex, class, specLocalized, isLeader})
        end
        table.sort(orderIndexes, function(a,b) return a[1] < b[1] end)
    end
    --local xOffset = -88
    for i = 1, 5 do
        local class, specLocalized, isLeader
        if orderIndexes[i] then
            class= WoWTools_UnitMixin:GetClassIcon(nil, orderIndexes[i][2], true)
            specLocalized= orderIndexes[i][3]
            isLeader= orderIndexes[i][4]
        end
        local texture = self.DataDisplay.Enumerate["tex"..i]
        if not texture then
            texture = self.DataDisplay.Enumerate:CreateTexture(nil, "OVERLAY")
            self.DataDisplay.Enumerate["tex"..i]= texture
            texture:EnableMouse(true)
            texture:SetSize(12, 14)
            texture:SetPoint("RIGHT", self.DataDisplay.Enumerate, -106+i*18 ,-12)--xOffset, -10)
            texture:SetScript('OnLeave', function(f) f:SetAlpha(1) end)
            texture:SetScript('OnEnter', function(f)
                if f.specLocalized then
                    e.tips:SetOwner(f, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine(f.specLocalized)
                    e.tips:Show()
                end
                f:SetAlpha(0.5)
            end)
            texture.leader = self.DataDisplay.Enumerate:CreateTexture(nil, "OVERLAY")
            texture.leader:SetPoint('CENTER', texture, 0, 0)
            texture.leader:SetAlpha(0.5)
            texture.leader:SetAtlas('Forge-ColorSwatchSelection')
            texture.leader:SetSize(16,16)

            self.DataDisplay.Enumerate["tex"..i]= texture
        end
        if class then
            texture:SetAtlas(class)
        else
            texture:SetTexture(0)
        end
        texture.leader:SetShown(isLeader)
        texture.specLocalized= specLocalized
        --xOffset = xOffset + 18
    end
end
















--预创建队伍增强, 提示
local function Init_LFGListUtil_SetSearchEntryTooltip(tooltip, resultID, autoAcceptOption)
    if not Save().LFGPlus then
        return
    end
    local info = C_LFGList.GetSearchResultInfo(resultID)
    local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
    local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus) or info.isDelisted
    if isAppFinished then
        return
    end
    local tab={}
    for i=1, info.numMembers do
        local role, classFile = C_LFGList.GetSearchResultMemberInfo(resultID, i)
        if classFile then
            tab[classFile]= tab[classFile] or {num=0, role={}}
            tab[classFile].num= tab[classFile].num +1
            table.insert(tab[classFile].role, {role=role, index= role=='TANK' and 1 or role=='HEALER' and 2 or 3})
        end
    end
    tooltip:AddLine(' ')
    for i=1,  GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(i)
        if classInfo and classInfo.classFile then
            local col='|c'..select(4, GetClassColor(classInfo.classFile))
            local text
            if tab[classInfo.classFile] then
                local num=tab[classInfo.classFile].num
                text= ' '..col..num..'|r'
                local roleText=' '
                table.sort(tab[classInfo.classFile].role, function(a,b) return a.index< b.index end)
                for _, role in pairs(tab[classInfo.classFile].role) do
                    if e.Icon[role.role] then
                        roleText= roleText..e.Icon[role.role]
                    end
                end
                text= text.. roleText
            end
            tooltip:AddDoubleLine(WoWTools_UnitMixin:GetClassIcon(nil, classInfo.classFile).. (text or ''), col..i)
        end
    end
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine(e.onlyChinese and '申请' or SIGN_UP, (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left, 0,1,0, 0,1,0)
    tooltip:AddDoubleLine(e.addName, WoWTools_LFDMixin.addName)
    tooltip:Show()
end






local function Init_Button()--预创建队伍增强    
    local Button= WoWTools_ButtonMixin:Cbtn(LFGListFrame, {size={20, 20}, atlas= Save().LFGPlus and e.Icon.icon or e.Icon.disabled})
    Button:SetPoint('LEFT', PVEFrame.TitleContainer)
    Button:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    Button:SetAlpha(0.5)
    function Button:set_texture()
        self:SetNormalAtlas(Save().LFGPlus and e.Icon.icon or e.Icon.disabled)
    end
    Button:SetScript('OnClick', function(self)
        Save().LFGPlus= not Save().LFGPlus and true or nil
        self:set_texture()
    end)
    Button:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
    Button:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(not e.onlyChinese and LFGLIST_NAME..' Plus'  or '预创建队伍增强', e.GetEnabeleDisable(Save().LFGPlus))
        e.tips:AddDoubleLine(e.addName, WoWTools_LFDMixin.addName)
        e.tips:Show()
        self2:SetAlpha(1)
    end)

    WoWTools_LFDMixin.LFGPlusButton= Button

end





















































function WoWTools_LFDMixin:Init_LFG_Plus()
    Init_Button()--预创建队伍增强

--预创建队伍增强
    hooksecurefunc('LFGListSearchEntry_Update', Init_LFGListSearchEntry_Update)
    hooksecurefunc('LFGListUtil_SetSearchEntryTooltip', Init_LFGListUtil_SetSearchEntryTooltip)
end