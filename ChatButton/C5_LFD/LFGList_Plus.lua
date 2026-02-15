local function Save()
    return WoWToolsSave['ChatButton_LFD'] or {}
end
















local function Init()--预创建队伍增强
    if not Save().LFGPlus then
        return
    end

    local btn= WoWTools_ButtonMixin:Menu(LFGListFrame, {
        size=16,
        texture='Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools',
        name='WoWToolsLFGPlusMainButton',
    })

    btn:SetPoint('LEFT', PVEFrame.TitleContainer)
    btn:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    btn:SetAlpha(0.5)

    btn:SetupMenu(function(_, root)
        local sub= root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        function()
            return Save().LFGPlus
        end, function()
            Save().LFGPlus= not Save().LFGPlus and true or nil
            if not Save().LFGPlus then
                print(
                    WoWTools_DataMixin.Icon.icon2
                    ..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
                    WoWTools_TextMixin:GetEnabeleDisable( not Save().LFGPlus)
                )
            end
        end)

        sub:SetTooltip(function(tooltip)
            if not Save().LFGPlus then
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end
        end)

--重新加载UI
        root:CreateDivider()
        WoWTools_MenuMixin:Reload(root)
    end)

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(0.5)
        WoWTools_ChatMixin:GetButtonForName('LFD'):SetButtonState('NORMAL')
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '预创建队伍增强' or (LFGLIST_NAME..' Plus'),
            WoWTools_TextMixin:GetEnabeleDisable(Save().LFGPlus)
        )
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_LFDMixin.addName)
        GameTooltip:Show()
        WoWTools_ChatMixin:GetButtonForName('LFD'):SetButtonState('PUSHED')
        self:SetAlpha(1)
    end)















--显示，更多，副本，列表
    WoWTools_DataMixin:Hook('LFGListEntryCreation_SetupGroupDropdown', function(self)
        if not self.useMoreButton then
            self.useMoreButton= CreateFrame('Button', 'WoWToolsLFGPlusUseMoreButton', self, 'WoWToolsButtonTemplate') --[[WoWTools_ButtonMixin:Cbtn(self, {
                size=18,
                atlas='common-icon-zoomin',
                name='WoWToolsLFGPlusUseMoreButton',
            })]]
            self.useMoreButton:SetNormalAtlas('common-icon-zoomin')
            self.useMoreButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '更多...' or LFG_LIST_MORE)
            self.useMoreButton:SetPoint('LEFT', self.GroupDropdown, 'RIGHT')
            LFGListEntryCreationActivityDropdown:SetPoint('LEFT', self.useMoreButton, 'RIGHT')
            self.useMoreButton:SetScript('OnClick', function()
                if not InCombatLockdown() then
                    LFGListEntryCreationActivityFinder_Show(self.ActivityFinder, self.selectedCategory, nil, bit.bor(self.baseFilters, self.selectedFilters))
                end
            end)
        end

        local enabled= self.selectedCategory and true or false
        if enabled then
            local groups = C_LFGList.GetAvailableActivityGroups(self.selectedCategory, bit.bor(self.baseFilters, self.selectedFilters))
            local activities = C_LFGList.GetAvailableActivities(self.selectedCategory, 0, bit.bor(self.baseFilters, self.selectedFilters))
            if (#activities + #groups) <= MAX_LFG_LIST_GROUP_DROPDOWN_ENTRIES then
                enabled= false
            end
        end
        self.useMoreButton:SetShown(enabled and not InCombatLockdown())
    end)
















--预创建队伍， 双击创建， 右击寻找
    LFGListFrame.EntryCreation.ActivityFinder.Dialog.EntryBox:SetScript('OnEscapePressed', function(self)
        self:ClearFocus()
    end)

    WoWTools_DataMixin:Hook('LFGListCategorySelection_AddButton', function(self, btnIndex)--, categoryID, filter)
        local b= self.CategoryButtons[btnIndex]
        if InCombatLockdown() or not b then
            return
        end

        b:SetScript('OnDoubleClick', function()
            if not InCombatLockdown() and LFGListFrame.CategorySelection.StartGroupButton:IsEnabled() then
                LFGListFrame.CategorySelection.StartGroupButton:Click()
            end
        end)
        b:SetScript('OnMouseDown', function(f, d)
            if not InCombatLockdown() and d=='RightButton' then
                do
                    LFGListCategorySelectionButton_OnClick(f)
                end
                if LFGListFrame.CategorySelection.FindGroupButton:IsEnabled() then
                    LFGListFrame.CategorySelection.FindGroupButton:Click()
                end
            end
        end)
        b:SetScript('OnLeave', function() GameTooltip:Hide() end)
        b:SetScript('OnEnter', function(f)
            if InCombatLockdown() then
                return
            end
            GameTooltip:SetOwner(f,  'ANCHOR_LEFT')
            GameTooltip_SetTitle(GameTooltip, 
                (WoWTools_DataMixin.onlyChinese and '创建' or CREATE_ARENA_TEAM)
                ..' ('..(WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)..')'
                ..WoWTools_DataMixin.Icon.left
                ..WoWTools_DataMixin.Icon.icon2
                ..WoWTools_DataMixin.Icon.right
                ..(WoWTools_DataMixin.onlyChinese and '寻找' or LFG_LIST_FIND_A_GROUP)
            )
            GameTooltip:Show()
        end)
    end)


















--预创建队伍增强
    local function getIndex(values, val)
        local index={}
        for k,v in pairs(values) do
            index[v]=k
        end
        return index[val]
    end

    WoWTools_DataMixin:Hook('LFGListSearchEntry_Update', function(self)
        local resultID = self.resultID
        if not resultID or not C_LFGList.HasSearchResultInfo(resultID) or InCombatLockdown() then
            return
        end

        local info = C_LFGList.GetSearchResultInfo(resultID)
        local categoryID= LFGListFrame.SearchPanel.categoryID
        local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
        local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus) or info.isDelisted

        local text, color, autoAccept = nil, nil, nil
        text=''
        if not isAppFinished then
            text, color= WoWTools_ChallengeMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore, true)--地下城, 分数
            if info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 then--PVP, 分数
                local text2, color2=WoWTools_ChallengeMixin:KeystoneScorsoColor(info.leaderPvpRatingInfo.rating)
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
                text= text..' '..WoWTools_DataMixin.Icon.wow2..info.numBNetFriends
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
            self.autoAcceptTexture:SetAtlas('common-icon-checkmark')
            self.autoAcceptTexture:SetSize(12,12)
            self.autoAcceptTexture:EnableMouse(true)
            self.autoAcceptTexture:SetScript('OnEnter', function(f)
                GameTooltip:SetOwner(f, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '自动接受' or LFG_LIST_AUTO_ACCEPT)
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_LFDMixin.addName)
                GameTooltip:Show()
            end)
            self.autoAcceptTexture:SetScript("OnLeave", GameTooltip_Hide)
        end
        if self.autoAcceptTexture then
            self.autoAcceptTexture:SetShown(autoAccept)
        end

        local realm, realmText
        if info.leaderName and not isAppFinished then
            local server= info.leaderName:match('%-(.+)') or WoWTools_DataMixin.Player.Realm
            server=WoWTools_RealmMixin:Get_Region(server)--服务器，EU， US {col, text}
            realm= server and server.col
            realmText=server and server.realm
        end
        if realm and not self.realmText then
            self.realmText= WoWTools_LabelMixin:Create(self)
            self.realmText:SetPoint('BOTTOMRIGHT', self.DataDisplay.Enumerate,0,-3)
            self.realmText:EnableMouse(true)
            self.realmText:SetScript('OnEnter', function(f)
                if f.realm then
                    GameTooltip:SetOwner(f, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '服务器' or 'Realm', '|cnGREEN_FONT_COLOR:'..f.realm)
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_LFDMixin.addName)
                    GameTooltip:Show()
                end
            end)
            self.realmText:SetScript("OnLeave", GameTooltip_Hide)
        end

        if self.realmText then
            self.realmText.realm= realmText
            self.realmText:SetText(realm or '')
        end

        if not self.OnDoubleClick then
            self:SetScript('OnDoubleClick', function(f)--LFGListApplicationDialogSignUpButton_OnClick(LFDButton) LFG队长分数, 双击加入 LFGListSearchPanel_UpdateResults
                if InCombatLockdown() then
                    return
                end
                if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
                    LFGListFrame.SearchPanel.SignUpButton:Click()
                end
                local frame=LFGListApplicationDialog
                if not frame.TankButton.CheckButton:GetChecked() and not frame.HealerButton.CheckButton:GetChecked() and not frame.DamagerButton.CheckButton:GetChecked() then
                    local specID=GetSpecialization()--当前专精
                    if specID then
                        local role = select(5, C_SpecializationInfo.GetSpecializationInfo(specID))
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
                class= WoWTools_UnitMixin:GetClassIcon(nil, nil, orderIndexes[i][2], {reAtlas=true})
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
                        GameTooltip:SetOwner(f, "ANCHOR_LEFT")
                        GameTooltip:ClearLines()
                        GameTooltip:AddLine(f.specLocalized)
                        GameTooltip:Show()
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
    end)













--预创建队伍增强, 提示
    WoWTools_DataMixin:Hook('LFGListUtil_SetSearchEntryTooltip', function(tooltip, resultID)--, autoAcceptOption)
        if InCombatLockdown() then
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
                        if WoWTools_DataMixin.Icon[role.role] then
                            roleText= roleText..WoWTools_DataMixin.Icon[role.role]
                        end
                    end
                    text= text.. roleText
                    tooltip:AddDoubleLine((WoWTools_UnitMixin:GetClassIcon(classInfo.classFile) or '').. (text or ''), col..i)
                end
            end
        end
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '申请' or SIGN_UP, (WoWTools_DataMixin.onlyChinese and '双击' or BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left, 0,1,0, 0,1,0)
        tooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_LFDMixin.addName)
        tooltip:Show()
    end)








    Init=function()end
end
























--预创建队伍增强
function WoWTools_LFDMixin:Init_LFG_Plus()
    Init()
end