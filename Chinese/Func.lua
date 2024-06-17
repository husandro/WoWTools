--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5Chin e.Player.region~=3 
local id, e = ...
if e.Player.region~=3 and not e.Is_PTR then-- LOCALE_zhCN or LOCALE_zhTW 
    return
end

local addName= BUG_CATEGORY15
local Save={
    disabled= not e.Player.husandro
}

--e.disbledCN=true,--禁用汉化


local function font(lable)
    if lable then
        local fontName2, size2, fontFlag2= lable:GetFont()
        if e.onlyChinese then
            fontName2= 'Fonts\\ARHei.ttf'--黑体字
        end
        lable:SetFont(fontName2, size2, fontFlag2 or 'OUTLINE')
    end
end


local function set(self, text, affer, setFont)
    if self and text and text~='' and (not self.IsForbidden or not self:IsForbidden()) and self.SetText then--CanAccessObject(self) then
        if setFont then
            font(self)
        end
        if affer then
            C_Timer.After(affer, function() self:SetText(text) end)
        else
            self:SetText(text)
        end
    end
end


local function setLabel(lable, text)
    if lable and lable.SetText then
        set(lable, e.strText[text or lable:GetText()])
    end
end

local function dia(string, tab)
    if StaticPopupDialogs[string] then
        for name, text in pairs(tab) do
            if StaticPopupDialogs[string][name] then
                StaticPopupDialogs[string][name]= text
            end
        end
    end
end

local function hookDia(string, text, func)
    if StaticPopupDialogs[string] then
        if StaticPopupDialogs[string][text] then
            hooksecurefunc(StaticPopupDialogs[string], text, func)
        else
            StaticPopupDialogs[string][text]=func
        end
    end
end

local function reg(self, text, index)
    if not self then
        return
    end
    for i, region in pairs({self:GetRegions()}) do
        if region:GetObjectType()=='FontString' and (index==i or not index) then
            text= index==i and text or e.strText[region:GetText()]
            set(region, text)
            if index then
                return
            end
        end
    end
end

local function hookLable(lable)
    if lable and lable.SetText then
        set(lable)
        hooksecurefunc(lable, 'SetText', function(frame, name)
            if name and name~='' then
                set(frame, e.strText[name])
            end
        end)
    end
end

local function hookButton(self, setFont)
    local label= self.text or self.Text or self.Label
    if not self or not self.SetText or not label or not label.GetText then
        return
    end
    if setFont then
        font(label)
    end
    set(label, e.strText[label:GetText()])
    hooksecurefunc(self, 'SetText', function(frame, name)
        if name and name~='' then
            set(frame.text or frame.Text or frame.Label, e.strText[name])
        end
    end)
end



local function set_model_tooltip(self)
    if self then
        local tooltip= self.tooltip and e.strText[self.tooltip]
        if tooltip then
            self.tooltip = tooltip
        end
        local tooltipText= self.tooltipText and e.strText[self.tooltipText]
        if tooltipText then
            self.tooltipText = tooltipText
        end
        local simpleTooltipLine= self.simpleTooltipLine and e.strText[self.simpleTooltipLine]
        if simpleTooltipLine then
            self.simpleTooltipLine= simpleTooltipLine
        end
    end
end
local function model(self)
    local frame= self and self.ControlFrame
    if frame then
        set_model_tooltip(frame.zoomInButton)
        set_model_tooltip(frame.zoomOutButton)
        set_model_tooltip(frame.rotateLeftButton)
        set_model_tooltip(frame.rotateRightButton)
        set_model_tooltip(frame.resetButton)

        set_model_tooltip(frame.ResetCameraButton)
        set_model_tooltip(frame.ZoomOutButton)
        set_model_tooltip(frame.ZoomInButton)
        set_model_tooltip(frame.RotateLeftButton)
        set_model_tooltip(frame.RotateRightButton)
    end
end

local ITEM_UPGRADE_TOOLTIP_FORMAT_STRING= ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub(': (.+)', '(.+)')
local ENCHANTED_TOOLTIP_LINE = ENCHANTED_TOOLTIP_LINE:gsub('%%s', '(.+)')--附魔：%s
local COVENANT_RENOWN_TOAST_REWARD_COMBINER= COVENANT_RENOWN_TOAST_REWARD_COMBINER:gsub('%%s', '(.+)')--%s 和 %s
local EQUIPMENT_SETS= EQUIPMENT_SETS:match('(.-):')..'(.+)'
local function get_gameTooltip_text(self)
    local text= self and self:IsShown() and self:GetText()
    if text and text~='' and not text:find('|') then
        local text2= e.strText[text]
        if not text2 then
            local up= text:match(ITEM_UPGRADE_TOOLTIP_FORMAT_STRING)---"升级：%s %d/%d
            local set2= text:match(EQUIPMENT_SETS)--"装备配置方案：|cFFFFFFFF%s|r"
            local ench= text:match(ENCHANTED_TOOLTIP_LINE)
            local gem1, gem2= text:match(COVENANT_RENOWN_TOAST_REWARD_COMBINER)
            local str1, str2= text:match('(.-): (.+)')
            local str3= text:match('%d+ (.+)')
            local str4= text:match('|c........(.-)|r')

            if up then
                local t= up:match(': (.-) %d')
                if t and e.strText[t] then
                    text2= '升级'..up:gsub(t, e.strText[t])
                else
                    text2= '升级'..up
                end

            elseif set2 then
                text2= '装备配置方案'..set2

            elseif ench then--附魔：%s
                local col, str5=  ench:match('(|.-:)(.-)|r')
                local t= ench:match('(.+) |A') or ench:match(' (.+)')
                if t then
                    local num= t:match('%d+ (.+)')
                    if num then
                        t= e.strText[num] or e.strText[num:match(".+ (.+)")]
                        if t then
                            ench= ench:gsub(num, t)
                        end
                    elseif e.strText[t] then
                        ench= ench:gsub(t, e.strText[t])
                    end
                    text2= '附魔：'..e.cn(ench)
                elseif col and str5 then
                    text2='附魔：'..col..e.cn(str5)..'|r'
                else
                    text2='附魔：'..e.cn(ench)
                end
            elseif gem1 and gem2 then
                local find
                local t1= gem1:match('%d+ (.+)')
                if t1 then
                    local s1= e.strText[t1:match(".+ (.+)")] or e.strText[t1]
                    if s1 and gem1 then
                        gem1= gem1:gsub(t1, s1)
                        find=true
                    end
                end
                local t2= gem2:match('%d+ (.+) |A') or gem2:match('%d+ (.+)')--无法找到
                if t2 then
                    local s1= e.strText[t2] or e.strText[t2:match(".+ (.+)")]
                    if s1 then
                        gem2= gem2:gsub(t2, s1)
                        find=true
                    end
                end
                if find then
                    text2= gem1..' 和 '..gem2
                end

            elseif e.strText[str1] then
                if str2 then
                    str2= e.strText[str2] or str2
                    local t= str2:match(' (.-) %d')
                    if t and e.strText[t] then
                        str2= str2:gsub(t, e.strText[t])
                    end
                end
                text2= e.strText[str1]..': '..(str2 or '')

            elseif str3 then
                if e.strText[str3] then--+75 Maestria
                    text2= text:gsub(str3, e.strText[str3])
                else

                    local t= e.strText[str3:match(".+ (.+) |A")] or e.strText[str3:match(".+ (.+)")]--+75 Indice di Maestria(大写m)
                    if t then
                        text2= text:gsub(str3, t)
                    end
                end
            elseif e.strText[str4] then
                text2= text:gsub(str4, e.strText[str4])
            end
        end
        if text2 then
            self:SetText(text2)
            self:SetTextColor(self:GetTextColor())
        end
    end
end
local function set_gameTooltip_text(frame)
    if frame and frame.GetName then
        local name= frame:GetName()-- or 'GameTooltip'
        if name then
            for i=1, frame:NumLines() or 0 do
                get_gameTooltip_text(_G[name.."TextLeft"..i])
                get_gameTooltip_text(_G[name.."TextRight"..i])
            end
        end
    end
end
local function set_GameTooltip_func(self)
    self:HookScript('OnShow', set_gameTooltip_text)
    self:HookScript('OnUpdate', function(frame, elapsed)
        frame.elapsed= (frame.elapsed or TOOLTIP_UPDATE_TIME) +elapsed
        if frame.elapsed>TOOLTIP_UPDATE_TIME then
            set_gameTooltip_text(frame)
        end
    end)
end

local function set_pettips_func(self)--FloatingPetBattleTooltip.xml
    if not self then
        return
    end
    local function set_pet_func(frame)
        setLabel(frame.BattlePet)
        setLabel(frame.PetType)
        local level = frame.Level:GetText():match('(%d+)')
        if level then
            set(frame.Level, format('等级 %s', level))
        end
    end
    self:HookScript('OnShow', set_pet_func)
end














local function Init()
    hooksecurefunc(SettingsCategoryListButtonMixin, 'Init', function(self, initializer)--列表 Blizzard_CategoryList.lua
        local category = initializer.data.category
        if category then
            setLabel(self.Label, category:GetName())
        end
    end)
    hooksecurefunc(SettingsCategoryListHeaderMixin, 'Init', function(self, initializer)
        setLabel(self.Label, initializer.data.label)
    end)

    --选项
    hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, 'Update', function(frame)
        if not frame:GetView() or not frame:IsVisible() then
            return
        end
        --标提
        setLabel(SettingsPanel.Container.SettingsList.Header.Title)
        for _, btn in pairs(frame:GetFrames() or {}) do
            local lable
            if btn.Button then--按钮
                lable= btn.Button.Text or btn.Button
                if lable then
                    setLabel(lable)
                end
            end
            if btn.DropDown and btn.DropDown.Button and btn.DropDown.Button.SelectionDetails  then--下拉，菜单info= btn
                lable= btn.DropDown.Button.SelectionDetails.SelectionName
                if lable then
                    setLabel(lable)
                end
            end
            lable= btn.Text or btn.Label or btn.Title
            if lable then
                setLabel(lable)
            elseif btn.Text and btn.data and btn.data.name and btn.data.name then
                setLabel(btn.Text, btn.data.name)
            end
        end
    end)
    hooksecurefunc('BindingButtonTemplate_SetupBindingButton', function(_, button)--BindingUtil.lua
        local text= button:GetText()
        if text==GRAY_FONT_COLOR:WrapTextInColorCode(NOT_BOUND) then
            set(button, GRAY_FONT_COLOR:WrapTextInColorCode('未设置'))
        else
            setLabel(button, text)
        end
    end)
    hooksecurefunc(KeyBindingFrameBindingTemplateMixin, 'Init', function(self, initializer)
        setLabel(self.Label)
    end)






    set(GameMenuFrame.Header.Text, '游戏菜单')
    set(GameMenuButtonHelp, '帮助')
    set(GameMenuButtonStore, '商店')
    set(GameMenuButtonWhatsNew, '新内容')
    set(GameMenuButtonSettings, '选项')
    set(GameMenuButtonEditMode, '编辑模式')
    set(GameMenuButtonMacros, '宏')
    set(GameMenuButtonAddons, '插件')
    set(GameMenuButtonLogout, '登出')
    set(GameMenuButtonQuit, '退出游戏')
    set(GameMenuButtonContinue, '返回游戏')



    --角色
    set(CharacterFrameTab1, '角色')
    CharacterFrameTab1:HookScript('OnEnter', function()
        GameTooltip:SetText(MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0"), 1.0,1.0,1.0 )
    end)
        PAPERDOLL_SIDEBARS[1].name= '角色属性'
            set(CharacterStatsPane.ItemLevelCategory.Title, '物品等级')
            set(CharacterStatsPane.AttributesCategory.Title, '属性')
            set(CharacterStatsPane.EnhancementsCategory.Title, '强化属性')
            hooksecurefunc('PaperDollFrame_SetLabelAndText', function(statFrame, label)--PaperDollFrame.lua
                local text= e.strText[label]
                if text then
                    set(statFrame.Label, format('%s：', text))
                end
            end)


        PAPERDOLL_SIDEBARS[2].name= '头衔'
        PAPERDOLL_SIDEBARS[3].name= '装备管理'
            set(PaperDollFrameEquipSetText, '装备')
            set(PaperDollFrameSaveSetText , '保存')
                set(GearManagerPopupFrame.BorderBox.EditBoxHeaderText, '输入方案名称（最多16个字符）：')
                set(GearManagerPopupFrame.BorderBox.IconSelectionText, '选择一个图标：')
                set(GearManagerPopupFrame.BorderBox.OkayButton, '确认')
                set(GearManagerPopupFrame.BorderBox.CancelButton, '取消')
                hooksecurefunc('PaperDollEquipmentManagerPane_InitButton', function(button, elementData)
                    if elementData.addSetButton then
                        set(button.text, '新的方案')
                    end
                end)
    set(CharacterFrameTab2, '声望')
    CharacterFrameTab2:HookScript('OnEnter', function()
        GameTooltip:SetText(MicroButtonTooltipText('声望', "TOGGLECHARACTER2"), 1.0,1.0,1.0 )
    end)
        set(ReputationFrameFactionLabel, '阵营')--FACTION
        set(ReputationFrameStandingLabel,  "关系")--STANDING
        set(ReputationDetailViewRenownButton, '浏览名望')--ReputationFrame.xml
        set(ReputationDetailMainScreenCheckBoxText, '显示为经验条')
        set(ReputationDetailInactiveCheckBoxText, '隐藏')
        set(ReputationDetailAtWarCheckBoxText, '交战状态')
        hooksecurefunc('ReputationFrame_InitReputationRow', function(factionRow, elementData)
            local factionIndex = elementData.index
            local name, description, standingID, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(factionIndex)
            name= name and e.strText[name]
            local factionContainer = factionRow.Container
            set(factionContainer.Name, name)
            if not factionID then
                return
            end

            local factionStandingtext
            local isMajorFaction = factionID and C_Reputation.IsMajorFaction(factionID)
            local repInfo = factionID and C_GossipInfo.GetFriendshipReputation(factionID)
            if (repInfo and repInfo.friendshipFactionID > 0) then
                factionStandingtext = e.strText[repInfo.reaction]

            elseif ( isMajorFaction ) then
                local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID) or {}
                factionStandingtext = '名望'..majorFactionData.renownLevel
            else
                factionStandingtext = e.strText[GetText("FACTION_STANDING_LABEL"..standingID, e.Player.sex)]
            end
            if factionStandingtext then
                set(factionContainer.ReputationBar.FactionStanding, factionStandingtext)
                factionRow.standingText = factionStandingtext
            end
            if ( factionIndex == GetSelectedFaction() ) then
                if ( ReputationDetailFrame:IsShown() ) then
                    set(ReputationDetailFactionName, name)
                    set(ReputationDetailFactionDescription, e.strText[description])
                end
            end
        end)




    set(CharacterFrameTab3, '货币')
    CharacterFrameTab3:HookScript('OnEnter', function()
        GameTooltip:SetText(MicroButtonTooltipText('货币', "TOGGLECURRENCY"), 1.0,1.0,1.0 )
    end)
        set(TokenFramePopup.Title, '货币设置')
        set(TokenFramePopup.InactiveCheckBox.Text, '未使用')
        set(TokenFramePopup.BackpackCheckBox.Text, '在行囊上显示')

        hooksecurefunc('TokenFrame_InitTokenButton',function(_, frame)--Blizzard_TokenUI.lua
			if frame and frame.Name then
                local name= e.strText[frame.Name:GetText()]--汉化
                if name then
                    frame.Name:SetText(name)
                end
            end
		end)
        hooksecurefunc('TokenFrame_Update', function()
			local f=TokenFrame
			if not f.ScrollBox:GetView() then
				return
			end
			for _, frame in pairs(f.ScrollBox:GetFrames()) do
				if frame.Name then
                    local name= e.strText[frame.Name:GetText()]--汉化
                    if name then
                        frame.Name:SetText(name)
                    end
                end
			end			
		end)












    --法术 SpellBookFrame.lua
    hooksecurefunc('SpellBookFrame_Update', function()
        set(SpellBookFrameTabButton1, '法术')
        set(SpellBookFrameTabButton2, '专业')
        set(SpellBookFrameTabButton3, '宠物')

        if SpellBookFrame.bookType== BOOKTYPE_SPELL then
            SpellBookFrame:SetTitle('法术')
        elseif SpellBookFrame.bookType== BOOKTYPE_PROFESSION then
            SpellBookFrame:SetTitle('专业')
        elseif SpellBookFrame.bookType== BOOKTYPE_PET then
            SpellBookFrame:SetTitle('宠物')
        end
    end)
    hooksecurefunc('SpellBookFrame_UpdatePages', function()
        local currentPage, maxPages = SpellBook_GetCurrentPage()
        if ( maxPages == nil or maxPages == 0 ) then
            return
        end
        SpellBookPageText:SetFormattedText('第%d页', currentPage)
    end)

    hooksecurefunc('UpdateProfessionButton', function(self)
        local parent = self:GetParent()
        if not parent.professionInitialized then
            return
        end
        local spellIndex = self:GetID() + parent.spellOffset
        local spellName, _, spellID = GetSpellBookItemName(spellIndex, SpellBookFrame.bookType)
        set(self.spellString, e.strText[spellName])
        if spellID then
            local spell = Spell:CreateFromSpellID(spellID)
            spell:ContinueOnSpellLoad(function()
                local text= spell:GetSpellSubtext()
                set(self.subSpellString, e.strText[text] or text)
            end)
        end
    end)












    hooksecurefunc(DragonridingPanelSkillsButtonMixin, 'OnLoad', function(self)--Blizzard_DragonflightLandingPage.lua
        setLabel(self)
    end)










    --LFD PVEFrame.lua
    --地下城和团队副本
    GroupFinderFrame:HookScript('OnShow', function()
        PVEFrame:SetTitle('地下城和团队副本')
    end)
  
    
    
    --set(GroupFinderFrameGroupButton1Name, '地下城查找器')
    --set(GroupFinderFrameGroupButton2Name, '团队查找器')
    --set(GroupFinderFrameGroupButton3Name, '预创建队伍')
    hookLable(GroupFinderFrameGroupButton1Name)
    hookLable(GroupFinderFrameGroupButton2Name)
    hookLable(GroupFinderFrameGroupButton3Name)
    hookLable(RaidFinderQueueFrameScrollFrameChildFrameTitle)
    hookLable(RaidFinderQueueFrameScrollFrameChildFrameDescription)

    set(PVEFrameTab1, '地下城和团队副本')
    set(PVEFrameTab2, 'PvP')
    set(PVEFrameTab3, '史诗钥石地下城')

    set(GroupFinderFrame.groupButton1.name, '地下城查找器')
        set(LFDQueueFrameTypeDropDownName, '类型：')
        set(LFDQueueFrameRandomScrollFrameChildFrameTitle, '')
    set(GroupFinderFrame.groupButton2.name, '团队查找器')
        set(RaidFinderQueueFrameSelectionDropDownName, '团队')
            hooksecurefunc('RaidFinderFrameFindRaidButton_Update', function()--RaidFinder.lua
                local mode = GetLFGMode(LE_LFG_CATEGORY_RF, RaidFinderQueueFrame.raid)
	            --Update the text on the button
                if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
                    set(RaidFinderFrameFindRaidButton, '离开队列')--LEAVE_QUEUE
                else
                    if ( IsInGroup() and GetNumGroupMembers() > 1 ) then
                        set(RaidFinderFrameFindRaidButton, '小队加入')--:SetText(JOIN_AS_PARTY)
                    else
                        set(RaidFinderFrameFindRaidButton, '寻找组队')--:SetText(FIND_A_GROUP)
                    end
                end
            end)

    set(GroupFinderFrame.groupButton3.name, '预创建队伍')
        set(LFGListFrame.CategorySelection.Label, '预创建队伍')
        hooksecurefunc('LFGListCategorySelection_AddButton', function(self, btnIndex, categoryID, filters)--LFGList.lua
            local baseFilters = self:GetParent().baseFilters
            local allFilters = bit.bor(baseFilters, filters)
            if ( filters ~= 0 and #C_LFGList.GetAvailableActivities(categoryID, nil, allFilters) == 0) then
                return
            end
            local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID)
            local text=LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, filters, true)
            local button= self.CategoryButtons[btnIndex]
            if button and button.Label and text then
                if e.strText[text] then

                    set(button.Label, e.strText[text], nil, true)
                end
            end
        end)
        set(LFGListFrame.CategorySelection.StartGroupButton, '创建队伍')
        set(LFGListFrame.CategorySelection.FindGroupButton, '寻找队伍')
        set(LFGListFrame.CategorySelection.Label, '预创建队伍')
            set(LFGListFrame.EntryCreation.NameLabel, '名称')
            set(LFGListFrame.EntryCreation.DescriptionLabel, '详细信息')

            set(LFGListFrame.EntryCreation.PlayStyleLabel, '目标')
            set(LFGListFrame.EntryCreation.MythicPlusRating.Label, '最低史诗钥石评分')
            set(LFGListFrame.EntryCreation.ItemLevel.Label, '最低物品等级')
            set(LFGListFrame.EntryCreation.PvpItemLevel.Label, '最低PvP物品等级')
            set(LFGListFrame.EntryCreation.VoiceChat.Label, '语音聊天')

            set(LFGListFrame.EntryCreation.PrivateGroup.Label, '个人')
            LFGListFrame.EntryCreation.PrivateGroup.tooltip= '仅对已在队伍中的好友和公会成员可见。'

            set(LFGListFrame.ApplicationViewer.NameColumnHeader.Label, '名称', nil, true)
            set(LFGListFrame.ApplicationViewer.RoleColumnHeader.Label, '职责', nil, true)
            set(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader.Label, '装等', nil, true)
            set(LFGApplicationViewerRatingColumnHeader.Label, '分数', nil, true)
    set(LFGListApplicationDialog.Label, '选择你的角色')
    set(LFGListApplicationDialogDescription.EditBox.Instructions, '给队长留言（可选）')
    set(LFGListApplicationDialog.SignUpButton, '申请')
    set(LFGListApplicationDialog.CancelButton, '取消')
    local function GetFindGroupRestriction()
        if ( C_SocialRestrictions.IsSilenced() ) then
            return "SILENCED", RED_FONT_COLOR:WrapTextInColorCode('帐号禁言期间不能这样做')
        elseif ( C_SocialRestrictions.IsSquelched() ) then
            return "SQUELCHED", RED_FONT_COLOR:WrapTextInColorCode('我们已经暂时禁止了你的聊天和邮件权限。请参考您的邮件以获得更详细的信息。')
        end
        return nil, nil
    end
    local function GetStartGroupRestriction()
        return GetFindGroupRestriction()
    end
    local function LFGListUtil_GetActiveQueueMessage(isApplication)--LFGList.lua
        if ( not isApplication and select(2,C_LFGList.GetNumApplications()) > 0 ) then
            return '你不能在拥有有效的预创建队伍申请时那样做。'
        end
        if ( isApplication and C_LFGList.HasActiveEntryInfo() ) then
            return '你不能在你的队伍出现在预创建队伍列表中时那样做。'
        end
        for category=1, NUM_LE_LFG_CATEGORYS do
            local mode = GetLFGMode(category)
            if ( mode ) then
                if ( mode == "lfgparty" ) then
                    return '你不能在自动匹配队伍中那样做。'
                elseif ( mode == "rolecheck" or (mode and not isApplication) ) then
                    return '你不能在地下城、团队副本或场景战役队列中那样做。'
                end
            end
        end
        local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate()
        if ( inProgress ) then
            return isBattleground and '你不能在战场或竞技场队列中那样做。' or '你不能在地下城、团队副本或场景战役队列中那样做。'
        end
        for i=1, GetMaxBattlefieldID() do
            local status, _, _, _, _, _, _, _, _, _, _, isSoloQueue = GetBattlefieldStatus(i)
            if ( status and status ~= "none" ) then
                if not isSoloQueue or status == "active" then
                    return '你不能在战场或竞技场队列中那样做，也不能在进入战场或竞技场后那样做。'
                end
            end
        end
    end
    hooksecurefunc('LFGListCategorySelection_UpdateNavButtons', function(self)--LFGList.lua
        if ( not self.selectedCategory ) then
            self.FindGroupButton.tooltip = '做出选择。'
            self.StartGroupButton.tooltip = '做出选择。'
        end
        if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
            self.StartGroupButton.tooltip = '只有队长才能这么做。'
        end
        local messageStart = LFGListUtil_GetActiveQueueMessage(false)
        if ( messageStart ) then
            self.StartGroupButton.tooltip = messageStart
        end
        local findError, findErrorText = GetFindGroupRestriction()
        if ( findError ~= nil ) then
            self.FindGroupButton.tooltip = findErrorText
            self.StartGroupButton.tooltip = findErrorText
        end
    end)

    hooksecurefunc('LFGListNothingAvailable_Update', function(self)--LFGList.lua
        if ( IsRestrictedAccount() ) then
            set(self.Label, '免费试玩账号无法使用此功能。')
        elseif ( C_LFGList.HasActivityList() ) then
            set(self.Label, '你无法加入任何队伍。')
        else
            set(self.Label, '加载中…')
        end
    end)

    hooksecurefunc('LFGListEntryCreation_Select', function(self, filters, categoryID, groupID, activityID)
        filters, categoryID, groupID, activityID = LFGListUtil_AugmentWithBest(bit.bor(self.baseFilters or 0, filters or 0), categoryID, groupID, activityID)
        local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
        if(not activityInfo) then
            return
        end
        --local groupName = C_LFGList.GetActivityGroupInfo(groupID)
        local englishFaction, localizedFaction  = UnitFactionGroup("player")
        local faction= englishFaction=='Alliance' and '联盟'
                    or (englishFaction=="Horde" and '部落')
                    or (englishFaction=="Neutral" and '中立')
                    or localizedFaction
        set(self.CrossFactionGroup.Label, format('仅限%s', faction))
        self.CrossFactionGroup.tooltip = format('只有%s玩家会看到你的队伍。|n|n这可能会减少你收到的申请人数量。', faction)
        self.CrossFactionGroup.disableTooltip = format('这项活动不支持跨阵营队伍。|n|n你的队伍将只对%s玩家显示。', faction)
        if ( activityInfo.ilvlSuggestion ~= 0 ) then
            set(self.ItemLevel.EditBox.Instructions, format('推荐%d级', activityInfo.ilvlSuggestion))
        else
            set(self.ItemLevel.EditBox.Instructions, '物品等级')
        end
    end)

    hooksecurefunc('LFGListEntryCreation_SetPlaystyleLabelTextFromActivityInfo', function(self, activityInfo)--LFGList.lua
        if(not activityInfo) then
            return
        end
        local labelText
        if(activityInfo.isRatedPvpActivity) then
            labelText = '目标'--LFG_PLAYSTYLE_LABEL_PVP
        elseif (activityInfo.isMythicPlusActivity) then
            labelText = '目标'--LFG_PLAYSTYLE_LABEL_PVE
        else
            labelText = '游戏风格'--LFG_PLAYSTYLE_LABEL_PVE_MYTHICZERO
        end
        set(self.PlayStyleLabel, labelText)
    end)

    hooksecurefunc('LFGListEntryCreation_UpdateValidState', function(self)
        local errorText
        local activityInfo = C_LFGList.GetActivityInfoTable(self.selectedActivity)
        local maxNumPlayers = activityInfo and  activityInfo.maxNumPlayers or 0
        local mythicPlusDisableActivity = not C_LFGList.IsPlayerAuthenticatedForLFG(self.selectedActivity) and (activityInfo.isMythicPlusActivity and not C_LFGList.GetKeystoneForActivity(self.selectedActivity))
        if ( maxNumPlayers > 0 and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) >= maxNumPlayers ) then
            errorText = string.format('针对此项活动，你的队伍人数已满（%d）。', maxNumPlayers)
        elseif (mythicPlusDisableActivity) then
            errorText = '|cffff0000你只有给自己的账号添加战网安全令和短信安全保护功能后才能在没有钥石时发布一个史诗钥石队伍|r|n|cff1eff00<点击显示更多信息>|r'
        elseif ( LFGListEntryCreation_GetSanitizedName(self) == "" ) then
            errorText = '你必须为你的队伍输入一个名字。'
        elseif  not self.ItemLevel.warningText
            and not self.PvpItemLevel.warningText
            and not self.MythicPlusRating.warningText
            and not self.PVPRating.warningText
        then
            errorText = LFGListUtil_GetActiveQueueMessage(false)
        end
        if errorText then
            self.ListGroupButton.errorText = errorText
        end
    end)

    local function LFGListUtil_GetQuestDescription(questID)
        local descriptionFormat = '完成任务[%s]。'
        if ( QuestUtils_IsQuestWorldQuest(questID) ) then
            descriptionFormat = '完成世界任务[%s]。'
        end
        return descriptionFormat:format(QuestUtils_GetQuestName(questID))
    end
    hooksecurefunc('LFGListEntryCreation_SetEditMode', function(self)--LFGList.lua
        local descInstructions = nil
        local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(self:GetParent().selectedActivity)
        if (not isAccountSecured) then
            descInstructions = '给自己的账号添加安全令和和短信安全保护功能后才能解锁此栏'
        end
        if self.editMode then
            local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
            assert(activeEntryInfo)
            if ( activeEntryInfo.questID ) then
                self.Description.EditBox.Instructions:SetText(LFGListUtil_GetQuestDescription(activeEntryInfo.questID))
            else
                self.Description.EditBox.Instructions:SetText(descInstructions or '关于你的队伍的更多细节（可选）')
            end
            set(self.ListGroupButton, '编辑完毕')
        else
            set(self.Description.EditBox.Instructions, descInstructions or '关于你的队伍的更多细节（可选）')
            set(self.ListGroupButton, '列出队伍')
        end
    end)

    hooksecurefunc('LFGListApplicationViewer_UpdateInfo', function(self)
        local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
        assert(activeEntryInfo)
        local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID)
        if not activityInfo then
            return
        end
        local categoryInfo = C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID)

        if not categoryInfo then
            return
        end
        set(self.EntryName, e.strText[activeEntryInfo.name])

        local activityName= e.strText[self.DescriptionFrame.activityName]
        if ( activeEntryInfo.comment == "" ) then
            set(self.DescriptionFrame.Text, activityName)
        else
            local comment= e.strText[activeEntryInfo.comment]
            if comment or activityName then
                set(self.DescriptionFrame.Text,  format("%s |cff888888- %s|r", activityName or self.DescriptionFrame.activityName, comment or self.DescriptionFrame.comment))
            end
        end
        if activityInfo.isPvpActivity then
            if activeEntryInfo.requiredItemLevel ~= 0 then
                set(self.ItemLevel, format('PvP物品等级：%d', activeEntryInfo.requiredItemLevel))
            end
        else
            if activeEntryInfo.requiredItemLevel ~= 0 then
                set(self.ItemLevel, format('物品等级：|cffffffff%d|r', activeEntryInfo.requiredItemLevel))
            end
        end
        if activeEntryInfo.privateGroup then
            set(self.PrivateGroup, '个人')
        end
    end)
    LFGListFrame.ApplicationViewer.RefreshButton:HookScript('OnEnter', function()
        GameTooltip:SetText('刷新', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end)

    hooksecurefunc('LFGListApplicationViewer_UpdateAvailability', function(self)
        if IsRestrictedAccount() then
            self.EditButton.tooltip = '免费试玩账号无法使用此功能。'
        end
    end)

    hooksecurefunc('LFGListApplicationViewer_UpdateApplicant', function(button, applicantID)
        local applicantInfo = C_LFGList.GetApplicantInfo(applicantID) or {}
        if not ( applicantInfo.applicantInfo or applicantInfo.applicationStatus == "applied" ) then
            if ( applicantInfo.applicationStatus == "invited" ) then
                set(button.Status, '已邀请')
            elseif ( applicantInfo.applicationStatus == "failed" or applicantInfo.applicationStatus == "cancelled" ) then
                set(button.Status, '|cffff0000已取消|r')
            elseif ( applicantInfo.applicationStatus == "declined" or applicantInfo.applicationStatus == "declined_full" or applicantInfo.applicationStatus == "declined_delisted" ) then
                set(button.Status, '已拒绝')
            elseif ( applicantInfo.applicationStatus == "timedout" ) then
                set(button.Status, '已过期')
            elseif ( applicantInfo.applicationStatus == "inviteaccepted" ) then
                set(button.Status, '已加入')
            elseif ( applicantInfo.applicationStatus == "invitedeclined" ) then
                set(button.Status, '拒绝邀请')
            end
        end
    end)

    hooksecurefunc('LFGListSearchPanel_UpdateButtonStatus', function(self)
        local resultID = self.selectedResult
        local _, numActiveApplications = C_LFGList.GetNumApplications()
        local messageApply = LFGListUtil_GetActiveQueueMessage(true)
        local availTank, availHealer, availDPS = C_LFGList.GetAvailableRoles()
        if not messageApply then
            if ( not LFGListUtil_IsAppEmpowered() ) then
                self.SignUpButton.tooltip = '你不是队长。'
            elseif ( IsInGroup(LE_PARTY_CATEGORY_HOME) and C_LFGList.IsCurrentlyApplying() ) then
                self.SignUpButton.tooltip = '你正在申请加入另一支队伍。'
            elseif ( numActiveApplications >= MAX_LFG_LIST_APPLICATIONS ) then
                self.SignUpButton.tooltip = string.format('你只能同时发出%d份有效申请。', MAX_LFG_LIST_APPLICATIONS)
            elseif ( GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > MAX_PARTY_MEMBERS + 1 ) then
                self.SignUpButton.tooltip = '你的队伍中队员太多，无法申请。\n（最多不能超过5个）'
            elseif ( not (availTank or availHealer or availDPS) ) then
                self.SignUpButton.tooltip = '你必须有至少一项专精才能申请加入该队伍。'
            elseif ( GroupHasOfflineMember(LE_PARTY_CATEGORY_HOME) ) then
                self.SignUpButton.tooltip = '有一个或更多的队员处于离线状态。'
            elseif not ( resultID ) then
                self.SignUpButton.tooltip = '选择一个搜索结果。'
            end
        elseif self.SignUpButton.tooltip and e.strText[self.SignUpButton.tooltip] then
            self.SignUpButton.tooltip= e.strText[self.SignUpButton.tooltip]
        end
        local isPartyLeader = UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME)
        local canBrowseWhileQueued = C_LFGList.HasActiveEntryInfo() and isPartyLeader
        if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not isPartyLeader ) then
            self.ScrollBox.StartGroupButton:Disable()
            self.ScrollBox.StartGroupButton.tooltip = '只有队长才能这么做。'
        else
            local messageStart = LFGListUtil_GetActiveQueueMessage(false)
            local startError, errorText = GetStartGroupRestriction()
            if ( messageStart ) then
                self.ScrollBox.StartGroupButton.tooltip = messageStart
            elseif ( startError ~= nil ) then
                self.ScrollBox.StartGroupButton.tooltip = errorText
            elseif (canBrowseWhileQueued) then
                self.ScrollBox.StartGroupButton.tooltip = '你不能在你的队伍出现在预创建队伍列表中时那样做。'
            end
        end

    end)

    hooksecurefunc('LFGListSearchEntry_Update', function(self)
        if not C_LFGList.HasSearchResultInfo(self.resultID) then
            return
        end
        local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(self.resultID)
        local isApplication = (appStatus ~= "none" or pendingStatus)
        if not LFGListUtil_IsAppEmpowered() then
            self.CancelButton.tooltip = '你不是队长。'
            if ( pendingStatus == "applied" and C_LFGList.GetRoleCheckInfo() ) then
                set(self.PendingLabel, '职责确认')
            elseif ( pendingStatus == "cancelled" or appStatus == "cancelled" or appStatus == "failed" ) then
                set(self.PendingLabel, '|cffff0000已取消|r')
            elseif ( appStatus == "declined" or appStatus == "declined_full" or appStatus == "declined_delisted" ) then
                set(self.PendingLabel, (appStatus == "declined_full") and ' "满"' or '已拒绝')
            elseif ( appStatus == "timedout" ) then
                set(self.PendingLabel, '已过期')
            elseif ( appStatus == "invited" ) then
                set(self.PendingLabel, '已邀请')
            elseif ( appStatus == "inviteaccepted" ) then
                set(self.PendingLabel, '已加入')
            elseif ( appStatus == "invitedeclined" ) then
                set(self.PendingLabel, '拒绝邀请')
            elseif ( isApplication and pendingStatus ~= "applied" ) then
                set(self.PendingLabel, '待定|cff40bf40-|r')
            end
            local searchResultInfo = C_LFGList.GetSearchResultInfo(self.resultID)
            if e.strText[searchResultInfo.voiceChat] then
                self.VoiceChat.tooltip = e.strText[searchResultInfo.voiceChat]
            end
        end
    end)

    hooksecurefunc('LFGListInviteDialog_UpdateOfflineNotice', function(self)
        if ( GroupHasOfflineMember(LE_PARTY_CATEGORY_HOME) ) then
            set(self.OfflineNotice, '有一名队伍成员处于离线状态，将无法收到邀请。')
        else
            set(self.OfflineNotice, '所有队伍成员都为在线状态。')
        end
    end)

    hooksecurefunc('LFGListEntryCreation_Show', function(self, _, selectedCategory)
        local categoryInfo = C_LFGList.GetLfgCategoryInfo(selectedCategory)
        if e.strText[categoryInfo.name] then
            set(self.Label, e.strText[categoryInfo.name])
        end
    end)

    set(LFGListFrame.ApplicationViewer.AutoAcceptButton.Label, '自动邀请')
    set(LFGListFrame.ApplicationViewer.BrowseGroupsButton, '浏览队伍')
    set(LFGListFrame.ApplicationViewer.RemoveEntryButton, '移除')
    set(LFGListFrame.ApplicationViewer.EditButton, '编辑')
    set(LFGListFrame.ApplicationViewer.UnempoweredCover.Label, '你的队伍正在组建中。')
    set(LFGListFrame.SearchPanel.SearchBox.Instructions, '搜索')
    set(LFGListFrame.SearchPanel.FilterButton, '过滤器')
    set(LFGListFrame.SearchPanel.BackToGroupButton, '回到队伍')
    set(LFGListFrame.SearchPanel.SignUpButton, '申请')
    set(LFGListFrame.SearchPanel.BackButton, '后退')
    set(LFGListFrame.SearchPanel.ScrollBox.StartGroupButton, '创建队伍')
    LFGListFrame.SearchPanel.RefreshButton:HookScript('OnEnter', function()
        GameTooltip:SetText('重新搜索', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    end)
    hooksecurefunc('LFGListSearchPanel_UpdateResults', function(self)
        if self.ScrollBox.NoResultsFound:IsShown() and self.totalResults == 0 then
            set(self.ScrollBox.NoResultsFound, self.searchFailed and '搜索失败。请稍后再试。' or '未找到队伍。如果你找不到想要的队伍，可以自己创建一支。')
        end
    end)

    set(LFGListFrame.EntryCreation.CancelButton, '后退')
    set(LFGListFrame.EntryCreation.VoiceChat.EditBox.Instructions, '语音聊天程序')

    set(LFGListCreationDescription.EditBox.Instructions, '关于你的队伍的更多细节（可选）')
    set(LFGListFrame.EntryCreation.Name.Instructions, '你的队伍在列表中显示的描述性名称')
    LFGListCreationDescription:HookScript('OnShow', function(self)--LFGListCreationDescriptionMixin
        local isAccountSecured = C_LFGList.IsPlayerAuthenticatedForLFG(self:GetParent().selectedActivity)
        self.EditBox.Instructions:SetText(isAccountSecured and '关于你的队伍的更多细节（可选）' or '给自己的账号添加安全令和和短信安全保护功能后才能解锁此栏')
    end)
    hooksecurefunc('LFDQueueFrameFindGroupButton_Update', function()--LFDFrame.lua
        local mode = GetLFGMode(LE_LFG_CATEGORY_LFD)
        if ( mode == "queued" or mode == "rolecheck" or mode == "proposal" or mode == "suspended" ) then
            set(LFDQueueFrameFindGroupButton, '离开队列')
        else
            if ( IsInGroup() and GetNumGroupMembers() > 1 ) then
                set(LFDQueueFrameFindGroupButton, '小队加入')
            else
                set(LFDQueueFrameFindGroupButton, '寻找组队')
            end
        end
        if C_PlayerInfo.IsPlayerNPERestricted() then
            if not LFDQueueCheckRoleSelectionValid(LFGRole_GetChecked(LFDQueueFrameRoleButtonTank), LFGRole_GetChecked(LFDQueueFrameRoleButtonHealer), LFGRole_GetChecked(LFDQueueFrameRoleButtonDPS)) then
                -- the NPE restricted player needs to at least be a DPS role if nothing is selected
                LFDQueueFrameRoleButtonDPS.checkButton:SetChecked(true)
                LFDFrameRoleCheckButton_OnClick(LFDQueueFrameRoleButtonDPS.checkButton)
            end
        end
        if ( not LFDQueueCheckRoleSelectionValid( LFGRole_GetChecked(LFDQueueFrameRoleButtonTank),
                                                    LFGRole_GetChecked(LFDQueueFrameRoleButtonHealer),
                                                    LFGRole_GetChecked(LFDQueueFrameRoleButtonDPS)) ) then
            LFDQueueFrameFindGroupButton.tooltip = '该角色在某些地下城不可用。'
            return
        end
        if not ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) and ( IsInGroup(LE_PARTY_CATEGORY_HOME) and not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) ) then
                LFDQueueFrameFindGroupButton.tooltip = '你现在不是队长'
        end
        local lfgListDisabled
        if ( C_LFGList.HasActiveEntryInfo() ) then
            lfgListDisabled = '你不能在你的队伍出现在预创建队伍列表中时那样做。'
        elseif(C_PartyInfo.IsCrossFactionParty()) then
            lfgListDisabled = '在跨阵营队伍中无法这么做。你可以参加非队列匹配模式的团队副本和地下城。'
        end
        if ( lfgListDisabled ) then
            LFDQueueFrameFindGroupButton.tooltip = lfgListDisabled
        end
    end)

    set(LFDRoleCheckPopupAcceptButton, '接受')
    set(LFDRoleCheckPopupDeclineButton, '拒绝')
    set(LFDRoleCheckPopup.Text, '确定你的职责：')
    hooksecurefunc('LFDRoleCheckPopup_UpdateAcceptButton', function()
        if not ( LFDPopupCheckRoleSelectionValid( LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonTank),
                                            LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonHealer),
                                            LFGRole_GetChecked(LFDRoleCheckPopupRoleButtonDPS)) ) then
            LFDRoleCheckPopupAcceptButton.tooltipText = '该角色在某些地下城不可用。'
        end
    end)

    hooksecurefunc('LFDRoleCheckPopup_Update', function()
        local slots, bgQueue = GetLFGRoleUpdate()
        local isLFGList, activityID = C_LFGList.GetRoleCheckInfo()
        local displayName
        if( isLFGList ) then
            displayName = C_LFGList.GetActivityFullName(activityID)
        elseif ( bgQueue ) then
            displayName = GetLFGRoleUpdateBattlegroundInfo()
        elseif ( slots == 1 ) then
            local dungeonID, _, dungeonSubType = GetLFGRoleUpdateSlot(1)
            if ( dungeonSubType == LFG_SUBTYPEID_HEROIC ) then
                displayName = format('英雄难度：%s', select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID)))
            else
                displayName = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID))
            end
        else
            displayName = '多个地下城'
        end
        displayName = displayName and NORMAL_FONT_COLOR:WrapTextInColorCode(displayName) or ""

        if ( isLFGList ) then
            LFDRoleCheckPopupDescriptionText:SetFormattedText('申请加入%s', displayName)
        else
            LFDRoleCheckPopupDescriptionText:SetFormattedText('在等待%s的队列中', displayName)
        end

        local maxLevel, isLevelReduced = C_LFGInfo.GetRoleCheckDifficultyDetails()
        if isLevelReduced then
            local canDisplayLevel = maxLevel and maxLevel < UnitEffectiveLevel("player")
            if canDisplayLevel then
                LFDRoleCheckPopupDescription.SubText:SetFormattedText(bgQueue and '等级和技能限制为小队的最低等级范围（%s）。' or '等级和技能限制为地下城的最高等级（%s）。', maxLevel)
            else
                LFDRoleCheckPopupDescription.SubText:SetText('进入战场时，等级和技能可能会受到限制。')
            end
        end
    end)


    LFDParentFrame:HookScript('OnEvent', function(_, event, ...)
        if ( event == "LFG_ROLE_CHECK_SHOW" ) then
            local requeue = ...
            set(LFDRoleCheckPopup.Text, requeue and '你的队友已经将你加入另一场练习赛的队列。\n\n请确认你的角色：' or '确定你的职责：')
        elseif ( event == "LFG_READY_CHECK_SHOW" ) then
            local _, readyCheckBgQueue = GetLFGReadyCheckUpdate()
            local displayName
            if ( readyCheckBgQueue ) then
                displayName = GetLFGReadyCheckUpdateBattlegroundInfo()
            else
                displayName = '未知'
            end
            set(LFDReadyCheckPopup.Text, format('你的队长将你加入|cnGREEN_FONT_COLOR:%s|r的队列。准备好了吗？', displayName))
        end
    end)

    hooksecurefunc('LFDQueueFrameRandomCooldownFrame_Update', function()--LFDFrame.lua
        local cooldownFrame = LFDQueueFrameCooldownFrame
        local hasDeserter = false --If we have deserter, we want to show this over the specific frame as well as the random frame.

        local deserterExpiration = GetLFGDeserterExpiration()

        local myExpireTime
        if ( deserterExpiration ) then
            myExpireTime = deserterExpiration
            hasDeserter = true
        else
            myExpireTime = GetLFGRandomCooldownExpiration()
        end


        for i = 1, GetNumSubgroupMembers() do
            --local nameLabel = _G["LFDQueueFrameCooldownFrameName"..i]
            local statusLabel = _G["LFDQueueFrameCooldownFrameStatus"..i]

            --local _, classFilename = UnitClass("party"..i)
            --local classColor = classFilename and RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR
            --nameLabel:SetFormattedText("|cff%.2x%.2x%.2x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, GetUnitName("party"..i, true))

            if ( UnitHasLFGDeserter("party"..i) ) then
                statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", '逃亡者')
                hasDeserter = true
            elseif ( UnitHasLFGRandomCooldown("party"..i) ) then
                statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", '冷却中')
            else
                statusLabel:SetFormattedText(GREEN_FONT_COLOR_CODE.."%s|r", '就绪')
            end
        end
        if ( myExpireTime and GetTime() < myExpireTime ) then
            if ( deserterExpiration ) then
                cooldownFrame.description:SetText('你刚刚逃离了随机队伍，在接下来的时间内无法再度排队：')
            else
                cooldownFrame.description:SetText('你近期加入过一个随机地下城队列。\n需要过一段时间才可加入另一个，等待时间为：')
            end
        else
            if ( hasDeserter ) then
                cooldownFrame.description:SetText('你的一名队伍成员刚刚逃离了随机副本队伍，在接下来的时间内无法再度排队。')
            else
                cooldownFrame.description:SetText('的一名队友近期加入过一个随机地下城队列，暂时无法加入另一个。')
            end
        end

    end)

    --LFGList.lua
    dia("LFG_LIST_INVITING_CONVERT_TO_RAID", {text = '邀请这名玩家或队伍会将你的小队转化为团队。', button1 = '邀请', button2 = '取消'})

    hooksecurefunc('LFGDungeonReadyDialog_UpdateInstanceInfo', function(name, completedEncounters, totalEncounters)
        set(LFGDungeonReadyDialogInstanceInfoFrame.name, e.strText[name])
        if ( totalEncounters > 0 ) then
            set(LFGDungeonReadyDialogInstanceInfoFrame.statusText, format('已消灭|cnGREEN_FONT_COLOR:%d/%d|r个首领', completedEncounters, totalEncounters))
        end
    end)
    LFGDungeonReadyDialogInstanceInfoFrame:HookScript('OnEnter', function()--LFGDungeonReadyDialogInstanceInfo_OnEnter
        local numBosses = select(9, GetLFGProposal())
        local isHoliday = select(13, GetLFGProposal())
        if ( numBosses == 0 or isHoliday) then
            return
        end
        GameTooltip:SetText('首领：')
        for i=1, numBosses do
            local bossName, _, isKilled = GetLFGProposalEncounter(i)
            if ( isKilled ) then
                GameTooltip:AddDoubleLine('|A:common-icon-redx:0:0|a'.. e.cn(bossName), '|cnRED_FONT_COLOR:已消灭')
            else
                GameTooltip:AddDoubleLine(format('|A:%s:0:0|a', e.Icon.select)..e.cn(bossName), '|cnGREEN_FONT_COLOR:可消灭')
            end
        end
        GameTooltip:Show()
    end)
    hooksecurefunc('LFGDungeonReadyPopup_Update', function()--LFGFrame.lua
        local proposalExists, _, typeID, subtypeID, _, _, role, hasResponded, _, _, numMembers, _, _, _, isSilent = GetLFGProposal()
        if ( not proposalExists ) then
            return
        elseif ( isSilent ) then
            return
        end

        if ( role == "NONE" ) then
            role = "DAMAGER"
        end

        local leaveText = '离开队列'
        if ( subtypeID == LFG_SUBTYPEID_RAID or subtypeID == LFG_SUBTYPEID_FLEXRAID ) then
            set(LFGDungeonReadyDialog.enterButton, '进入')
        elseif ( subtypeID == LFG_SUBTYPEID_SCENARIO ) then
            if ( numMembers > 1 ) then
                set(LFGDungeonReadyDialog.enterButton, '进入')
            else
                set(LFGDungeonReadyDialog.enterButton, '接受')
                leaveText = '取消'
            end
        else
            LFGDungeonReadyDialog.enterButton:SetText('进入')
        end
        set(LFGDungeonReadyDialog.leaveButton, leaveText)

        if not hasResponded then
            local LFGDungeonReadyDialog = LFGDungeonReadyDialog
            if ( typeID == TYPEID_RANDOM_DUNGEON and subtypeID ~= LFG_SUBTYPEID_SCENARIO ) then
                set(LFGDungeonReadyDialog.label, '你的随机地下城小队已经整装待发！')
            else
                 if ( numMembers > 1 ) then
                    set(LFGDungeonReadyDialog.label, '已经建好了一个队伍，准备前往：')
                else
                    set(LFGDungeonReadyDialog.label, '已经建好了一个副本，准备前往：')
                end
            end
            role= _G[role]
            if ( subtypeID ~= LFG_SUBTYPEID_SCENARIO and subtypeID ~= LFG_SUBTYPEID_FLEXRAID  and e.strText[role]) then
                set(LFGDungeonReadyDialogRoleLabel, e.strText[role])
            end
        end
    end)
    set(LFGDungeonReadyDialogYourRoleDescription, '你的职责')
    set(LFGDungeonReadyDialogRoleLabel, '治疗者')
    set(LFGDungeonReadyDialogRewardsFrameLabel, '奖励')
    set(LFGDungeonReadyStatusLabel, '就位确认')

    set(LFGDungeonReadyDialogRandomInProgressFrameStatusText, '该地下城正在进行中。')
    set(RaidFinderQueueFrameScrollFrameChildFrameRewardsLabel, '奖励')
    set(LFDQueueFrameRandomScrollFrameChildFrameRewardsLabel, '奖励')

    RaidFinderQueueFrameScrollFrameChildFrameEncounterList:HookScript('OnEnter', function(self)
        if self.dungeonID then
            local numEncounters, numCompleted = GetLFGDungeonNumEncounters(self.dungeonID)
            if ( numCompleted > 0 ) then
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine(format('|cnHIGHLIGHT_FONT_COLOR:物品已经被拾取（%d/%d）', numCompleted, numEncounters))
                GameTooltip:Show()
            end
        end
    end)


    hooksecurefunc('LFGListInviteDialog_Show', function(self, resultID, kstringGroupName)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID) or {}
        local activityName = C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode)
        local _, status, _, _, role = C_LFGList.GetApplicationInfo(resultID)
        local name= kstringGroupName or searchResultInfo.name
        if e.strText[name] then
            self.GroupName:SetText(e.strText[name])
        end
        if e.strText[activityName] then
            self.ActivityName:SetText(e.strText[activityName])
        end
        role= _G[role]
        if e.strText[role] then
            self.Role:SetText(e.strText[role])
        end
        self.Label:SetText(status ~= "invited" and '你已经加入了一支队伍：' or '你收到了一支队伍的邀请：')
    end)
    set(LFGListInviteDialog.Label, '你收到了一支队伍的邀请：')
    set(LFGListInviteDialog.RoleDescription, '你的职责')
    set(LFGListInviteDialog.OfflineNotice, '有一名队伍成员处于离线状态，将无法收到邀请。')
    set(LFGListInviteDialog.AcceptButton, '接受')
    set(LFGListInviteDialog.DeclineButton, '拒绝')
    set(LFGListInviteDialog.AcknowledgeButton, '确定')


    hooksecurefunc('LFGListSearchPanel_SetCategory', function(self, categoryID, filters)--LFGList.lua
        local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID) or {} --if categoryInfo.searchPromptOverride then set(self.SearchBox.Instructions, e.strText[categoryInfo.searchPromptOverride])
        set(self.SearchBox.Instructions,'过滤器')
        local name = LFGListUtil_GetDecoratedCategoryName(categoryInfo.name, filters, false)
        if name then
            if e.strText[name] then
                set(self.CategoryName, e.strText[name])
            else
                local t1, t2 = name:match('(.-) %- (.+)')
                if t1 and t2 then
                    local a1, b2= e.strText[t1], e.strText[t2]
                    if a1 or b2 then
                        set(self.CategoryName, (a1 or t1)..' - '..(b2 or t2))
                    end
                end
            end
        end
    end)


    set(_G['LFDQueueFrameFollowerTitle'], '追随者地下城')
    set(_G['LFDQueueFrameFollowerDescription'], '与NPC队友一起完成地下城')
    --set(LFDQueueFrameRandomScrollFrameChildFrameTitle, '')
    hooksecurefunc('LFGRewardsFrame_UpdateFrame', function(parentFrame, dungeonID)--LFGFrame.lua
        if ( not dungeonID ) then
            return
        end
        local _, _, subtypeID,_,_,_,_,_,_,_,_,_,_,_, isHoliday, _, _, isTimewalker = GetLFGDungeonInfo(dungeonID)
        local isScenario = (subtypeID == LFG_SUBTYPEID_SCENARIO)
        local doneToday = GetLFGDungeonRewards(dungeonID)
        if ( isTimewalker ) then
            parentFrame.rewardsDescription:SetText('你将获得该奖励：')
            parentFrame.title:SetText('随机时空漫游地下城')
            parentFrame.description:SetText('时空漫游将让你回到低级地下城中，并将你的角色实力降低到与之相适应程度，但首领会掉落与你当前等级相符的战利品。')
        elseif ( isHoliday ) then
            if ( doneToday ) then
                parentFrame.rewardsDescription:SetText('每天继首次胜利之后的每次胜利将为你赢得：')
            else
                parentFrame.rewardsDescription:SetText('你每天取得的首次胜利将为你赢得：')
            end
            --parentFrame.title:SetText(dungeonName)
            --parentFrame.description:SetText(dungeonDescription)
        elseif ( subtypeID == LFG_SUBTYPEID_RAID ) then
            if ( doneToday ) then --May not actually be today, but whatever this reset period is.
                parentFrame.rewardsDescription:SetText('当你完成每周的首次副本之后，每次胜利都可为你赢得：')
            else
                parentFrame.rewardsDescription:SetText('每周第一次完成可获得：')
            end
            --parentFrame.title:SetText(dungeonName)
            --parentFrame.description:SetText(dungeonDescription)
        else
            local numCompletions, isWeekly = LFGRewardsFrame_EstimateRemainingCompletions(dungeonID)
            if ( numCompletions <= 0 ) then
                parentFrame.rewardsDescription:SetText('你将获得该奖励：')
            elseif ( isWeekly ) then
                parentFrame.rewardsDescription:SetText(format('本周你还能获取此奖励%d|4次:次：', numCompletions))
            else
                parentFrame.rewardsDescription:SetText(format('今天你还能获取此奖励%d|4次:次：', numCompletions))
            end
            if ( isScenario ) then
                if ( LFG_IsHeroicScenario(dungeonID) ) then
                    parentFrame.title:SetText('随机英雄场景战役')
                    parentFrame.description:SetText('使用随机英雄场景战役排队可获得额外奖励。但你需要组满队伍')
                else
                    parentFrame.title:SetText('随机场景战役')
                    parentFrame.description:SetText('使用随机场景战役排队，会获得额外奖励哦！')
                end
            else
                parentFrame.title:SetText('随机地下城')
                parentFrame.description:SetText('使用地下城查找器前往随机地下城，会有额外奖励哦！')
            end
        end
    end)

    set(LFGListFrame.ApplicationViewer.ScrollBox.NoApplicants, '"你的队伍已经加入列表。|n申请者将出现在此处。')

























    --快速快捷键模式
    --QuickKeybind.xml
    set(QuickKeybindFrame.Header.Text, '快速快捷键模式')
    set(QuickKeybindFrame.InstructionText, '你处于快速快捷键模式。将鼠标移到一个按钮上并按下你想要的按键，即可设置那个按钮的快捷键。')
    set(QuickKeybindFrame.CancelDescriptionText, '取消会使你离开快速快捷键模式。')
    set(QuickKeybindFrame.OkayButton, '确定')
    set(QuickKeybindFrame.DefaultsButton, '恢复默认设置')
    set(QuickKeybindFrame.CancelButton, '取消')
    set(QuickKeybindFrame.UseCharacterBindingsButton.text, '角色专用按键设置')









    e.Cstr(nil, {changeFont= QuickKeybindFrame.OutputText, size=16})
    local function set_SetOutputText(self, text)
        if not text then
            return
        end
        if text==KEYBINDINGFRAME_MOUSEWHEEL_ERROR then
            set(self.OutputText, '|cnRED_FONT_COLOR:无法将鼠标滚轮的上下滚动状态绑定在动作条上|r')
        elseif text==KEY_BOUND then
            set(self.OutputText, '|cnGREEN_FONT_COLOR:按键设置成功|r')
        else
            local a, b, c= e.Magic(PRIMARY_KEY_UNBOUND_ERROR), e.Magic(KEY_UNBOUND_ERROR), e.Magic(SETTINGS_BIND_KEY_TO_COMMAND_OR_CANCEL)
            local finda, findb= text:match(a), text:match(b)
            local findc1, findc2= text:match(c)
            if finda then
                set(self.OutputText, format('|cffff0000主要动作 |cffff00ff%s|r 现在没有绑定！|r', e.strText[finda] or finda))
            elseif findb then
                set(self.OutputText, format('|cffff0000动作 |cffff00ff%s|r 现在没有绑定！|r', e.strText[findb] or findb))
            elseif findc1 and findc2 then
                set(self.OutputText, format('设置 |cnGREEN_FONT_COLOR:%s|r 的快捷键，或者按 %s 取消', e.strText[findc1] or findc1, findc2))
            end
        end
    end
    hooksecurefunc(QuickKeybindFrame, 'SetOutputText', set_SetOutputText)
    hooksecurefunc(SettingsPanel, 'SetOutputText', set_SetOutputText)

    --快捷键
    hooksecurefunc(KeyBindingFrameBindingTemplateMixin,'Init', function(self)
        local label= self.Text or self.Label
        local text= label and e.strText[label:GetText()]
        set(label, text)
    end)




    --好友
    hooksecurefunc('FriendsFrame_Update', function()
        local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame) or FRIEND_TAB_FRIENDS
        if selectedTab == FRIEND_TAB_FRIENDS then
            local selectedHeaderTab = PanelTemplates_GetSelectedTab(FriendsTabHeader) or FRIEND_HEADER_TAB_FRIENDS
            if selectedHeaderTab == FRIEND_HEADER_TAB_FRIENDS then
                FriendsFrame:SetTitle('好友名单')
            elseif selectedHeaderTab == FRIEND_HEADER_TAB_IGNORE then
                FriendsFrame:SetTitle('屏蔽列表')
            elseif selectedHeaderTab == FRIEND_HEADER_TAB_RAF then
                FriendsFrame:SetTitle('招募战友')
            end
        elseif ( selectedTab == FRIEND_TAB_WHO ) then
            FriendsFrameTitleText:SetText('名单列表')
        elseif ( selectedTab == FRIEND_TAB_RAID ) then
            FriendsFrameTitleText:SetText('团队')
        elseif ( selectedTab == FRIEND_TAB_QUICK_JOIN ) then
            FriendsFrameTitleText:SetText('快速加入')
        end
    end)

    set(FriendsFrameTab1, '好友')
        reg(FriendsFrameBattlenetFrame.BroadcastFrame, '通告', 1)
        set(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.PromptText, '通告')
        set(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton, '更新')
        set(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton, '取消')
        set(FriendsFrameAddFriendButton, '添加好友')
            set(AddFriendEntryFrameTopTitle, '添加好友')
            set(AddFriendEntryFrameOrLabel, '或')
            hooksecurefunc('AddFriendFrame_ShowEntry', function()
                if ( BNFeaturesEnabledAndConnected() ) then
                    local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo()
                    if ( battleTag and isRIDEnabled ) then
                        AddFriendEntryFrameLeftTitle:SetText('实名')
                        AddFriendEntryFrameLeftDescription:SetText('输入电子邮件地址\n(或战网昵称)')
                        AddFriendNameEditBoxFill:SetText('输入：电子邮件地址、战网昵称、角色名')
                    elseif ( isRIDEnabled ) then
                        AddFriendEntryFrameLeftTitle:SetText('实名')
                        AddFriendEntryFrameLeftDescription:SetText('输入电子邮件地址')
                        AddFriendNameEditBoxFill:SetText('输入：电子邮件地址、角色名')
                    elseif ( battleTag ) then
                        AddFriendEntryFrameLeftTitle:SetText('战网昵称')
                        AddFriendEntryFrameLeftDescription:SetText('输入战网昵称')
                        AddFriendNameEditBoxFill:SetText('输入：战网昵称、角色名')
                    end
                else
                    AddFriendEntryFrameLeftDescription:SetText('暴雪游戏服务不可用')
                end
            end)
            set(AddFriendEntryFrameRightDescription, '输入角色名')
            hooksecurefunc('AddFriendEntryFrame_Init', function()
                set(AddFriendEntryFrameAcceptButtonText, '添加好友')
            end)
            set(AddFriendEntryFrameCancelButtonText, '取消')
            AddFriendNameEditBox:ClearAllPoints()--移动，输入框
            AddFriendNameEditBox:SetPoint('BOTTOMLEFT', AddFriendEntryFrameAcceptButton, 'TOPLEFT', 0, 4)
            set(AddFriendInfoFrameContinueButton, '继续')

        set(FriendsTabHeaderTab1, '好友')
        set(FriendsTabHeaderTab2, '屏蔽')
            set(FriendsFrameIgnorePlayerButton, '添加')
            set(FriendsFrameUnsquelchButton, '移除')
        set(FriendsTabHeaderTab3, '招募战友')
            if RecruitAFriendFrame then
                local function set_UpdateRAFInfo(self, rafInfo)
                    if self.rafEnabled and rafInfo and #rafInfo.versions > 0 then
                        local latestRAFVersionInfo = self:GetLatestRAFVersionInfo()
                        if (latestRAFVersionInfo.numRecruits == 0) and (latestRAFVersionInfo.monthCount.lifetimeMonths == 0) then
                            self.RewardClaiming.MonthCount:SetText('招募战友即可开始！')
                        else
                            self.RewardClaiming.MonthCount:SetFormattedText('招募战友已奖励%d个月', latestRAFVersionInfo.monthCount.lifetimeMonths)
                        end
                    end
                end
                hooksecurefunc(RecruitAFriendFrame, 'UpdateRAFInfo', set_UpdateRAFInfo)
                set_UpdateRAFInfo(RecruitAFriendFrame, RecruitAFriendFrame.rafInfo)

                local function set_UpdateNextReward(self, nextReward)--C_RecruitAFriend.GetRAFInfo()
                    if nextReward then
                        if nextReward.canClaim then
                            self.RewardClaiming.EarnInfo:SetText('你获得了：')
                        elseif nextReward.monthCost > 1 then
                            self.RewardClaiming.EarnInfo:SetFormattedText('下一个奖励 (|cnGREEN_FONT_COLOR:%d|r/%d个月)：', nextReward.monthCost - nextReward.availableInMonths, nextReward.monthCost)
                        elseif nextReward.monthsRequired == 0 then
                            self.RewardClaiming.EarnInfo:SetText('第一个奖励：')
                        else
                            self.RewardClaiming.EarnInfo:SetText('下一个奖励：')
                        end

                        if not nextReward.petInfo and not nextReward.appearanceInfo and not nextReward.appearanceSetInfo and not nextReward.illusionInfo then
                            if nextReward.titleInfo then
                                local titleName = TitleUtil.GetNameFromTitleMaskID(nextReward.titleInfo.titleMaskID)
                                if titleName then
                                    self:SetNextRewardName(format('新头衔：|cnGREEN_FONT_COLOR:%s|r', titleName), nextReward.repeatableClaimCount, nextReward.rewardType)
                                end
                            else
                                self:SetNextRewardName('30天免费游戏时间', nextReward.repeatableClaimCount, nextReward.rewardType)
                            end
                        end
                    end
                end
                hooksecurefunc(RecruitAFriendFrame, 'UpdateNextReward', set_UpdateNextReward)
                if RecruitAFriendFrame.rafEnabled and RecruitAFriendFrame.rafInfo and #RecruitAFriendFrame.rafInfo.versions > 0 then
                    local latestRAFVersionInfo = RecruitAFriendFrame:GetLatestRAFVersionInfo() or {}
                    set_UpdateNextReward(RecruitAFriendFrame, latestRAFVersionInfo.nextReward)
                end

                hooksecurefunc(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton, 'Update', function(self)
                    if self.haveUnclaimedReward then
                        self:SetText('获取奖励')
                    else
                        self:SetText('查看所有奖励')
                    end
                end)
                if RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton.haveUnclaimedReward then
                    set(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton, '获取奖励')
                else
                    set(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton, '查看所有奖励')
                end

                set(RecruitAFriendFrame.RecruitList.Header.RecruitedFriends, '已招募的战友')
                set(RecruitAFriendFrame.RecruitList.NoRecruitsDesc,  "|cffffd200招募战友后，战友每充值一个月的游戏时间，你就能获得一次奖励。|n|n若战友一次充值的游戏时间超过一个月，奖励会逐月进行发放。|n|n一起游戏还能解锁额外奖励！|r|n|n更多信息：|n|HurlIndex:49|h|cff82c5ff访问我们的战友招募网站|r|h")
                set(RecruitAFriendFrame.RecruitmentButton, '招募')
                RecruitAFriendFrame.RewardClaiming.NextRewardInfoButton:HookScript('OnEnter', function()
                    GameTooltip_AddNormalLine(GameTooltip, '招募好友后，当好友开始订阅时，你就能开始获得奖励。')
                    GameTooltip:Show()
                end)

                set(RecruitAFriendRewardsFrame.Title, '战友招募奖励')
                hooksecurefunc(RecruitAFriendRewardsFrame, 'UpdateDescription', function(self, selectedRAFVersionInfo)
                    self.Description:SetText((selectedRAFVersionInfo.rafVersion == self:GetRecruitAFriendFrame():GetLatestRAFVersion()) and '每名拥有可用的游戏时间的被招募者|n每30天可以为你提供一份月度奖励。' or '不能再为旧版招募活动再招募新的战友，但是旧版现有的被招募的战友还会继续提供战友招募奖励。')
                end)


                RecruitAFriendRewardsFrame.VersionInfoButton:HookScript('OnEnter', function(self)
                    local recruitAFriendFrame = self:GetRecruitAFriendFrame()
                    local selectedVersionInfo = recruitAFriendFrame:GetSelectedRAFVersionInfo()
                    local helpText = recruitAFriendFrame:IsLegacyRAFVersion(selectedVersionInfo.rafVersion) and '当前激活的旧版招募战友：|cnHIGHLIGHT_FONT_COLOR:%d|r|n尚未领取的奖励：|cnHIGHLIGHT_FONT_COLOR:%d|r' or '当前激活的招募战友：|cnHIGHLIGHT_FONT_COLOR:%d|r|n尚未领取的奖励：|cnHIGHLIGHT_FONT_COLOR:%d|r'
                    GameTooltip_AddNormalLine(GameTooltip, ' ')
                    GameTooltip_AddNormalLine(GameTooltip, helpText:format(selectedVersionInfo.numRecruits, selectedVersionInfo.numAffordableRewards))
                    GameTooltip:Show()
                end)

                set(RecruitAFriendRecruitmentFrame.Title, '招募')

                hooksecurefunc(RecruitAFriendRecruitmentFrame, 'UpdateRecruitmentInfo', function(self, recruitmentInfo, recruitsAreMaxed)
                    local maxRecruits = 0
                    local maxRecruitLinkUses = 0
                    local daysInCycle = 0
                    local rafSystemInfo = C_RecruitAFriend.GetRAFSystemInfo()
                    if rafSystemInfo then
                        maxRecruits = rafSystemInfo.maxRecruits
                        maxRecruitLinkUses = rafSystemInfo.maxRecruitmentUses
                        daysInCycle = rafSystemInfo.daysInCycle
                    end

                    if recruitmentInfo then
                        local expireDate = date("*t", recruitmentInfo.expireTime)
                        recruitmentInfo.expireDateString = FormatShortDate(expireDate.day, expireDate.month, expireDate.year)

                        set(self.Description, format('招募战友，与你一起游玩《魔兽世界》！|n你每%2$d天可以邀请%1$d个战友。', recruitmentInfo.totalUses, daysInCycle))

                        if recruitmentInfo.sourceFaction ~= "" then
                            local region= e.Get_Region(recruitmentInfo.sourceRealm)
                            local reaml= (region and region.col or '')..(recruitmentInfo.sourceRealm or '')
                            set(self.FactionAndRealm, format('我们会鼓励你的战友在%2$s服务器创建一个%1$s角色，从而加入你的冒险。', e.strText[recruitmentInfo.sourceFaction] or recruitmentInfo.sourceFaction, reaml))
                        end
                    else
                        local PLAYER_FACTION_NAME= e.Player.faction=='Alliance' and PLAYER_FACTION_COLOR_ALLIANCE:WrapTextInColorCode('联盟') or (e.Player.faction=='Horde' and PLAYER_FACTION_COLOR_HORDE:WrapTextInColorCode('部落')) or '中立'
                        set(self.Description, format('招募战友，与你一起游玩《魔兽世界》！|n你每%2$d天可以邀请%1$d个战友。', maxRecruitLinkUses, daysInCycle))
                        set(self.FactionAndRealm, format('我们会鼓励你的战友在%2$s服务器创建一个%1$s角色，从而加入你的冒险。', PLAYER_FACTION_NAME, e.Player.realm))
                    end

                    if recruitsAreMaxed then
                        set(self.InfoText1, format('"%d/%d 已招募的战友。已达到最大招募数量。', maxRecruits, maxRecruits))
                    elseif recruitmentInfo then
                        if recruitmentInfo.remainingUses > 0 then
                            set(self.InfoText1, format('此链接会在|cnGREEN_FONT_COLOR:%s|r后过期', recruitmentInfo.expireDateString))
                        else
                            set(self.InfoText1, format('你在|cnGREEN_FONT_COLOR:%s|r后即可创建一个新链接', recruitmentInfo.expireDateString))
                        end


                        local timesUsed = recruitmentInfo.totalUses - recruitmentInfo.remainingUses
                        set(self.InfoText2, format('%d/%d 名朋友已经使用了这个链接。', timesUsed, recruitmentInfo.totalUses))
                    end
                end)
            end

            hooksecurefunc(RecruitAFriendRecruitmentFrame.GenerateOrCopyLinkButton, 'Update', function(self, recruitmentInfo)
                recruitmentInfo= recruitmentInfo or self.recruitmentInfo
                if recruitmentInfo then
                    set(RecruitAFriendRecruitmentFrameText, '复制链接')
                else
                    set(RecruitAFriendRecruitmentFrameText, '创建链接')
                end
            end)

    set(FriendsFrameTab2, '查询')
        set(WhoFrameWhoButton, '刷新')
        set(WhoFrameAddFriendButton, '添加好友')
        set(WhoFrameGroupInviteButton, '组队邀请')
        set(FriendsFrameSendMessageButton, '发送信息')
    set(FriendsFrameTab3, '团队')
        set(RaidFrameAllAssistCheckButtonText, '所有|TInterface\\GroupFrame\\UI-Group-AssistantIcon:12:12:0:1|t')
        RaidFrameAllAssistCheckButton:HookScript('OnEnter', function(self)
            GameTooltip:AddLine('钩选此项可使所有团队成员都获得团队助理权限', nil, nil, nil, true)
            if ( not self:IsEnabled() ) then
                GameTooltip:AddLine('|cnRED_FONT_COLOR:只有团队领袖才能更改此项设置。', nil, nil, nil, true)
            end
            GameTooltip:Show()
        end)
        set(WhoFrameColumnHeader1, '名称')
        set(WhoFrameColumnHeader4, '职业')
        hooksecurefunc('WhoList_Update', function()
            local _, totalCount = C_FriendList.GetNumWhoResults()
            local displayedText = ""
            if ( totalCount > MAX_WHOS_FROM_SERVER ) then
                displayedText = format('（显示%d）', MAX_WHOS_FROM_SERVER)
            end
            WhoFrameTotals:SetText(format('找到%d个人', totalCount).."  "..displayedText)
        end)
        set(RaidFrameRaidInfoButton, '团队信息')
            set(RaidInfoFrame.Header.Text, '团队信息')
            set(RaidInfoInstanceLabel.text, '副本')
            set(RaidInfoIDLabel.text, '锁定过期')
            hooksecurefunc('RaidInfoFrame_UpdateButtons', function()
                if RaidInfoFrame.selectedIndex then
                    if RaidInfoFrame.selectedIsInstance then
                        local _, _, _, _, locked, extended= GetSavedInstanceInfo(RaidInfoFrame.selectedIndex)
                        if extended then
                            RaidInfoExtendButton:SetText('移除副本锁定延长')
                        else
                            RaidInfoExtendButton:SetText(locked and '延长副本锁定' or '重新激活副本锁定')
                        end
                    else
                        RaidInfoExtendButton:SetText('延长副本锁定')
                    end
                else
                    RaidInfoExtendButton:SetText('延长副本锁定')
                end
            end)
            hooksecurefunc('RaidInfoFrame_InitButton', function(button, elementData)--RaidFrame.lua
                local function InitButton(extended, locked, name, difficulty, difficultyId)
                    name= e.strText[name]
                    if extended or locked then
                        set(button.name, name)
                    else
                        button.reset:SetFormattedText("|cff808080%s|r", '已过期')
                        if name then
                            button.name:SetFormattedText("|cff808080%s|r", name)
                        end
                    end

                    local difficultyText= difficultyId and e.GetDifficultyColor(difficulty, difficultyId) or e.strText[difficulty]
                    set(button.difficulty, difficultyText)

                    if button.extended:IsShown() then
                        set(button.extended, '|cff00ff00已延长|r')
                    end
                end

                local index = elementData.index
                if elementData.isInstance then
                    local name, _, _, difficultyId, locked, extended, _, _, _, difficultyName = GetSavedInstanceInfo(index)
                    InitButton(extended, locked, name, difficultyName, difficultyId)
                else
                    local name = GetSavedWorldBossInfo(index)
                    local locked = true
                    local extended = false
                    --[[if index==1 then--Sha della Rabbia
                        e.strText[name]= '怒之煞'
                    elseif index==2 then --Galeone
                        e.strText[name]= '炮舰'
                    elseif index==3 then--Nalak
                        e.strText[name]= '纳拉克'
                    elseif index==4 then --Undasta
                        e.strText[name]= '乌达斯塔'
                    elseif index==9 then--Rukhmar
                        e.strText[name]= '鲁克玛'
                    end]]
                    InitButton(extended, locked, name, RAID_INFO_WORLD_BOSS)
                end
            end)
            hooksecurefunc('RaidFrame_OnShow', function(self)
                self:GetParent():GetTitleText():SetText('团队')
            end)
            set(RaidInfoCancelButton, '关闭')


        set(RaidFrameConvertToRaidButton, '转化为团队')
        set(RaidFrameRaidDescription, '团队是超过5个人的队伍，这是为了击败高等级的特定挑战而准备的大型队伍模式。\n\n|cffffffff- 团队成员无法获得非团队任务所需的物品或者杀死怪物的纪录。\n\n- 在团队中，你通过杀死怪物获得的经验值相对普通小队要少。\n\n- 团队让你可以赢得用其它方法根本无法通过的挑战。|r')



    hooksecurefunc('FriendsFrame_UpdateQuickJoinTab', function(numGroups)--FriendsFrame.lua
        if numGroups then
            set(FriendsFrameTab4, '快速加入'.. (numGroups>0 and '|cnGREEN_FONT_COLOR:' or '')..numGroups)
        end
    end)
    hooksecurefunc(QuickJoinFrame, 'UpdateJoinButtonState', function(self)--QuickJoin.lua
        set(self.JoinQueueButton, '申请加入')
        if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
            self.JoinQueueButton.tooltip = '你已在一个队伍中。你必须离开队伍才能加入此队列。'
        elseif  self:GetSelectedGroup() ~= nil then
            local queues = C_SocialQueue.GetGroupQueues(self:GetSelectedGroup())
            if ( queues and queues[1] and queues[1].queueData.queueType == "lfglist" ) then
                set(self.JoinQueueButton, '申请')
            end
        end
    end)
    --FriendsFrame.xml
    set(BattleTagInviteFrame.InfoText, '当他们接受你的好友请求后，就会被加入你的好友名单。')
    reg(BattleTagInviteFrame, '发送一个|cff82c5ff战网昵称|r请求给：', 1)




    set(ChatConfigChannelSettingsLeftColorHeader, '颜色')

    COMBAT_CONFIG_TABS[1].text= '信息来源'
    COMBAT_CONFIG_TABS[2].text= '信息类型'
    COMBAT_CONFIG_TABS[3].text= '颜色'
    COMBAT_CONFIG_TABS[4].text= '格式'
    COMBAT_CONFIG_TABS[5].text= '设置'
    --ChatConfigFrame.lua
    ChatConfigCombatSettings:HookScript('OnShow', function()
        for index, value in ipairs(COMBAT_CONFIG_TABS) do--ChatConfigCombat_OnLoad()
            local tab = _G[CHAT_CONFIG_COMBAT_TAB_NAME..index]
            set(tab.Text, value.text)
            PanelTemplates_TabResize(tab, 0)
        end
    end)

    hooksecurefunc('ChatConfig_CreateCheckboxes', function(frame, checkBoxTable, _, title)
        local checkBoxNameString = frame:GetName().."CheckBox"
        local checkBoxName, checkBox, check
        local text
        local checkBoxFontString
        if ( title ) then
            set(_G[frame:GetName().."Title"], e.strText[title])
        end
        for index, value in ipairs(checkBoxTable) do
            checkBoxName = checkBoxNameString..index
            checkBox = _G[checkBoxName]
            if ( value.text ) then
                text = value.text
                if type(text) == "function" then
                    text = text()
                end
            else
                text = _G[value.type]
            end
            text= e.strText[text]
            if text then
                checkBoxFontString = _G[checkBoxName.."CheckText"]
                set(checkBoxFontString, text)
                set(checkBox.BlankText, text)
                check = _G[checkBoxName.."Check"]
                if value.tooltip and e.strText[value.tooltip] then
                    check.tooltip = e.strText[value.tooltip]
                end
                if ( value.maxWidth ) then
                    if ( checkBoxFontString:GetWidth() > value.maxWidth ) then
                        check.tooltip = text
                    end
                end
            end
        end
    end)

    hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)
        if ( not FCF_GetCurrentChatFrame() ) then
            return
        end
        local checkBoxTable = frame.checkBoxTable
        local checkBoxNameString = frame:GetName().."CheckBox"
        local checkBox, baseName
        for index, value in ipairs(checkBoxTable) do
            baseName = checkBoxNameString..index
            checkBox = _G[baseName.."Check"]
            if ( checkBox ) then
                if value.tooltip and e.strText[value.tooltip] then
                    checkBox.tooltip =  e.strText[value.tooltip]
                end
                if ( type(value.text) == "function" ) then	--Dynamic text, we should update it
                    local text= value.text()
                    setLabel(_G[checkBoxNameString..index.."CheckText"], text and e.strText[text])
                end
            end
        end
    end)

    COMBAT_CONFIG_MESSAGESOURCES_BY[1].text = function () return ( UsesGUID("SOURCE") and '自定义单位' or '我') end
    COMBAT_CONFIG_MESSAGESOURCES_TO[1].text = function () return ( UsesGUID("SOURCE") and '自定义单位' or '我') end


    hooksecurefunc('ChatConfig_CreateTieredCheckboxes', function(frame, checkBoxTable)
        local checkBoxNameString = frame:GetName().."CheckBox"
        for index, value in ipairs(checkBoxTable) do
            local checkBoxName = checkBoxNameString..index
            local checkBox = _G[checkBoxNameString..index]
            if checkBox  then
                local text
                if ( value.text ) then
                    text = value.text
                else
                    text = _G[value.type]
                end
                set(_G[checkBoxName.."Text"], e.strText[text])
                if ( value.subTypes ) then
                    local subCheckBoxNameString = checkBoxName.."_"
                    for k, v in ipairs(value.subTypes) do
                        local subCheckBoxName = subCheckBoxNameString..k
                        local subCheckBox=_G[subCheckBoxNameString..k]
                        if e.strText[v.tooltip] then
                            subCheckBox.tooltip = e.strText[v.tooltip]
                        end
                        local subText
                        if (v.text ) then
                            subText = v.text
                        elseif v.type then
                            subText = _G[v.type]
                        end
                        set(_G[subCheckBoxName.."Text"], e.strText[subText])
                    end
                end
                if e.strText[value.tooltip] then
                    checkBox.tooltip = e.strText[value.tooltip]
                end
            end
        end
    end)

    hooksecurefunc('ChatConfig_CreateColorSwatches', function(frame, swatchTable, _, title)
        local nameString = frame:GetName().."Swatch"
        local swatchName
        local text
        frame.swatchTable = swatchTable
        if ( title ) then
            setLabel(_G[frame:GetName().."Title"], title)
        end
        for index, value in ipairs(swatchTable) do
            swatchName = nameString..index
            if ( _G[swatchName] ) then
                if ( value.text ) then
                    text = value.text
                else
                    text = _G[value.type]
                end
                setLabel(_G[swatchName.."Text"], text)
            end
        end
    end)


    hooksecurefunc('FCF_SetWindowName', function(frame, name)--FloatingChatFrame.lua
        local tab = _G[frame:GetName().."Tab"]
        set(tab, e.strText[name])
        PanelTemplates_TabResize(tab, tab.sizePadding or 0)
    end)

    hooksecurefunc(ChatWindowTabMixin, 'SetChatWindowIndex', function(self, chatWindowIndex)
        local text
        if chatWindowIndex ~= VOICE_WINDOW_ID then
            local chatTab = _G["ChatFrame"..chatWindowIndex.."Tab"]
            text= e.strText[chatTab.Text:GetText()]
        else
            text= '文本转语音'
        end
        set(self.Text, text)
    end)


    set(CombatConfigColorsExampleTitle, '范例文字：')
    set(CombatConfigFormattingExampleTitle, '范例文字：')
    set(CombatConfigFormattingShowTimeStamp.Text, '显示时间戳')
    CombatConfigFormattingShowTimeStamp.tooltip = '显示战斗记录信息的时间戳。'
    set(CombatConfigFormattingShowBraces.Text, '显示括号')
    CombatConfigFormattingShowBraces.tooltip = '在战斗记录信息中的超链接外显示括号。'
    set(CombatConfigFormattingUnitNamesText, '单位名称')
    CombatConfigFormattingUnitNames.tooltip = '在单位名称外显示括号。'

    set(CombatConfigFormattingSpellNamesText, '法术名')
    CombatConfigFormattingSpellNames.tooltip= '在法术名称外显示括号。'
    set(CombatConfigFormattingItemNamesText, '物品名')
    CombatConfigFormattingItemNames.tooltip= '在物品名称外显示括号。'
    set(CombatConfigFormattingFullTextText, '使用详细模式')
    CombatConfigFormattingItemNames.tooltip= '整句显示战斗记录信息。'






    set(CombatConfigSettingsShowQuickButtonText, '显示快捷按钮')
    CombatConfigSettingsShowQuickButton.tooltip= '在聊天窗口中放置一个该过滤条件的快捷方式。'
    set(CombatConfigSettingsSoloText, '独身')
    set(CombatConfigSettingsPartyText, '小队')
    set(CombatConfigSettingsRaidText, '团队')

    for i=1, 7 do
        local btn=_G['ChatConfigCategoryFrameButton'..i]
        if btn then
            local text= btn:GetText()
            if text==CHAT then
                set(btn, '聊天')
            elseif text==CHANNELS then
                set(btn, '频道')
            elseif text==OTHER then
                set(btn, '其它')
            elseif text==COMBAT then
                set(btn, '战斗')
            elseif text==SETTINGS then
                set(btn, '设置')
            elseif text== UNIT_COLORS then
                set(btn, '"单位颜色：')
            elseif text== COLORIZE then
                set(btn, '彩色标记：')
            elseif text== HIGHLIGHTING then
                set(btn, '高亮显示：')
            end
        end
    end

    set(ChatConfigFrameDefaultButton, '聊天默认')
    set(ChatConfigFrameRedockButton, '重置聊天窗口位置')
    set(ChatConfigFrameOkayButton, '确定')
    set(CombatLogDefaultButton, '战斗记录默认')
    set(TextToSpeechDefaultButton, '文字转语音默认设置')

    set(ChatConfigCombatSettingsFiltersCopyFilterButton, '复制')
    set(ChatConfigCombatSettingsFiltersAddFilterButton, '添加')
    set(ChatConfigCombatSettingsFiltersDeleteButton, '删除')
    set(CombatConfigSettingsSaveButton, '保存')

    set(TextToSpeechFramePlaySampleAlternateButton, '播放样本')
    set(TextToSpeechFramePlaySampleButton, '播放样本')

    set(TextToSpeechFramePanelContainer.PlaySoundSeparatingChatLinesCheckButton.text, '每条新信息之间播放声音')
    set(TextToSpeechFramePanelContainer.PlayActivitySoundWhenNotFocusedCheckButton.text, '某个聊天窗口有活动，而且不是当前焦点窗口时，播放一个音效')
    set(TextToSpeechFramePanelContainer.AddCharacterNameToSpeechCheckButton.text, '在语音中添加<角色名说>')
    set(TextToSpeechFramePanelContainer.NarrateMyMessagesCheckButton.text, '大声朗读我自己的信息')
    set(TextToSpeechFrameTtsVoiceDropdownLabel, '语音设置"')
    set(TextToSpeechFrameTtsVoiceDropdownMoreVoicesLabel, '更多信息请查阅|cff00aaff|HurlIndex:56|h支持页面|h|r')
    set(TextToSpeechFramePanelContainerText, '使用另一个声音来朗读系统信息')
    set(TextToSpeechFrameAdjustRateSliderLabel, '调节讲话速度')
    set(TextToSpeechFrameAdjustVolumeSliderLabel, '音量')
    set(ChatConfigTextToSpeechMessageSettingsSubTitle, '对特定信息开启文字转语音')
    set(TextToSpeechFrameAdjustRateSliderLow, '慢')
    set(TextToSpeechFrameAdjustRateSliderHigh, '快')

    TextToSpeechButton:HookScript('OnEnter', function()--TextToSpeech.lua
        GameTooltip_SetTitle(GameTooltip, '文字转语音选项')
        GameTooltip:Show()
    end)

    hooksecurefunc('TextToSpeechFrame_UpdateMessageCheckboxes', function(frame)--TextToSpeechFrame.lua
        local checkBoxNameString = frame:GetName().."CheckBox"
        for index in ipairs(frame.checkBoxTable or {}) do
            local checkBoxText = _G[checkBoxNameString..index].text
            if checkBoxText then
                set(checkBoxText, e.strText[checkBoxText:GetText()])
            end
        end
    end)
    set(TextToSpeechCharacterSpecificButtonText, '角色专用设置')

    hooksecurefunc('ChatConfigCategoryFrame_Refresh', function()--ChatConfigFrame.lua
        local currentChatFrame = FCF_GetCurrentChatFrame()
        if  CURRENT_CHAT_FRAME_ID == VOICE_WINDOW_ID then
            ChatConfigFrame.Header:Setup('文字转语音选项')
        else
            ChatConfigFrame.Header:Setup(currentChatFrame ~= nil and format('%s设置', e.strText[currentChatFrame.name] or currentChatFrame.name) or "")
        end
    end)



    set(ChannelFrameTitleText, '聊天频道')
    set(ChannelFrame.NewButton, '添加')
    set(ChannelFrame.SettingsButton, '设置')
    set(CreateChannelPopup.UseVoiceChat.Text, '启用语音聊天')
    set(CreateChannelPopup.Header.Text, '新建频道')
    set(CreateChannelPopup.Name.Label, '频道名称')
    set(CreateChannelPopup.Password.Label, '密码')
    set(CreateChannelPopup.OKButton, '确定')
    set(CreateChannelPopup.CancelButton, '取消')

    hooksecurefunc(ObjectiveTrackerBlocksFrame.QuestHeader, 'UpdateHeader', function(self)
        set(self.Text, '任务')
    end)

    ScenarioChallengeModeBlock.DeathCount:HookScript('OnEnter', function(self)--ScenarioChallengeDeathCountMixin
        GameTooltip:SetText(format('%d次死亡', self.count), 1, 1, 1)
        GameTooltip:AddLine(format('时间损失：|cffffffff%s|r', SecondsToClock(self.timeLost)))
        GameTooltip:Show()
    end)

    ScenarioChallengeModeBlock.TimesUpLootStatus:HookScript('OnEnter', function(self)--Scenario_ChallengeMode_TimesUpLootStatus_OnEnter
        GameTooltip:SetText('时间结束', 1, 1, 1)
        local line
        if (self:GetParent().wasDepleted) then
            if (UnitIsGroupLeader("player")) then
                line = '你的钥石无法升级，且你在完成此地下城后将无法获得战利品宝箱。你可以右键点击头像并选择“重置史诗地下城”来重新开始挑战。'
            else
                line = '你的钥石无法升级，且你在完成此地下城后将无法获得战利品宝箱。小队队长可以右键点击头像并选择“重置史诗地下城”来重新开始挑战。'
            end
        else
            line = '你的钥石无法升级。但你完成此地下城后仍可获得战利品宝箱'
        end
        GameTooltip:AddLine(line, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    hooksecurefunc('ScenarioBlocksFrame_SetupStageBlock', function(scenarioCompleted)
        if not ScenarioStageBlock.WidgetContainer:IsShown() then
            if ( scenarioCompleted ) then
                local scenarioType = select(10, C_Scenario.GetInfo())
                local dungeonDisplay = (scenarioType == LE_SCENARIO_TYPE_USE_DUNGEON_DISPLAY)
                if( dungeonDisplay ) then
                    set(ScenarioStageBlock.CompleteLabel, '地下城完成！')
                else
                    set(ScenarioStageBlock.CompleteLabel, '完成！')
                end
            else
                set(ScenarioStageBlock.CompleteLabel, '阶段完成')
            end
        end
    end)
    hooksecurefunc('Scenario_ChallengeMode_ShowBlock', function()
        local level= C_ChallengeMode.GetActiveKeystoneInfo()
        if level then
            set(ScenarioChallengeModeBlock.Level, format('%d级', level))
        end
    end)
    
    --出现Bug SCENARIO_CONTENT_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader, '场景战役', nil)
    --Blizzard_ScenarioObjectiveTracker.lua
    hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, 'Update', function()
        local scenarioName, currentStage, numStages, flags, _, _, _, _, _, scenarioType= C_Scenario.GetInfo()
        local shouldShowMawBuffs = ShouldShowMawBuffs()
        local isInScenario = numStages > 0
        if ( not isInScenario and (not shouldShowMawBuffs or IsOnGroundFloorInJailersTower()) ) then
            return
        end
        local BlocksFrame = SCENARIO_TRACKER_MODULE.BlocksFrame
        local stageBlock = ScenarioStageBlock
        local stageName = C_Scenario.GetStepInfo()
        local inChallengeMode = (scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE)
        local inProvingGrounds = (scenarioType == LE_SCENARIO_TYPE_PROVING_GROUNDS)
        local dungeonDisplay = (scenarioType == LE_SCENARIO_TYPE_USE_DUNGEON_DISPLAY)
        local scenariocompleted = currentStage > numStages
        if ( not isInScenario ) then
        elseif ( scenariocompleted ) then
        elseif ( inChallengeMode ) then
        elseif ( ScenarioProvingGroundsBlock.timerID ) then
        else
            if ( BlocksFrame.currentStage ~= currentStage or BlocksFrame.scenarioName ~= scenarioName or BlocksFrame.stageName ~= stageName) then
                if ( bit.band(flags, SCENARIO_FLAG_SUPRESS_STAGE_TEXT) == SCENARIO_FLAG_SUPRESS_STAGE_TEXT ) then
                    set(stageBlock.Stage, e.strText[stageName])
                else
                    if ( currentStage == numStages ) then
                        set(stageBlock.Stage, '最终阶段')
                    else
                        set(stageBlock.Stage, format('阶段%d', currentStage))
                    end
                    set(stageBlock.Name, e.strText[stageName])
                end
            end
        end
        if ( BlocksFrame.currentBlock ) then
            if ( inChallengeMode ) then-- header
                set(SCENARIO_CONTENT_TRACKER_MODULE.Header.Text, e.strText[BlocksFrame.scenarioName])
            elseif ( inProvingGrounds or ScenarioProvingGroundsBlock.timerID ) then
                set(SCENARIO_CONTENT_TRACKER_MODULE.Header.Text, '试炼场')
            elseif( dungeonDisplay ) then
                set(SCENARIO_CONTENT_TRACKER_MODULE.Header.Text, '地下城')
            elseif ( shouldShowMawBuffs and not IsInJailersTower() ) then
                set(SCENARIO_CONTENT_TRACKER_MODULE.Header.Text, e.strText[GetZoneText()])
            else
                set(SCENARIO_CONTENT_TRACKER_MODULE.Header.Text, e.strText[BlocksFrame.scenarioName])
            end
        end
    end)
    C_Timer.After(2, function()


        setLabel(SCENARIO_CONTENT_TRACKER_MODULE.Header.Text)
        set(ObjectiveTrackerFrame.HeaderMenu.Title, '追踪')
        set(ObjectiveTrackerBlocksFrame.CampaignQuestHeader.Text, '战役')
        set(ObjectiveTrackerBlocksFrame.ProfessionHeader.Text, '专业')
        set(ObjectiveTrackerBlocksFrame.MonthlyActivitiesHeader.Text, '旅行者日志')
        set(ObjectiveTrackerBlocksFrame.AchievementHeader.Text, '成就')

        reg(CombatConfigSettingsNameEditBox)--过滤名称
    end)

    --银行
    --BankFrame.lua
    set(BankFrameTab1.Text, '银行')
    set(BankFrameTab2.Text, '材料')
    BANK_PANELS[2].SetTitle=function() BankFrame:SetTitle('材料银行') end
    if ReagentBankFrame.DespositButton:GetText()~='' then
        set(ReagentBankFrame.DespositButton, '存放各种材料')
    end
    set(BankItemSearchBox.Instructions, '搜索')
    reg(BankSlotsFrame)


    --商人
    set(MerchantFrameTab1, '商人')
    set(MerchantFrameTab2, '购回')
    set(MerchantPageText, '')
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function ()
        MerchantFrame:SetTitle('从商人处购回')
    end)
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
        if not MerchantFrame:IsShown() then
            return
        end
        MerchantPageText:SetFormattedText('页数 %s/%s', MerchantFrame.page, math.ceil(GetMerchantNumItems() / MERCHANT_ITEMS_PER_PAGE))
    end)

    --就绪
    --ReadyCheck.lua
    set(ReadyCheckListenerFrame.TitleContainer.TitleText, '就位确认')
    set(ReadyCheckFrameYesButton, '就绪')--:SetText(GetText("READY", UnitSex("player")))
	set(ReadyCheckFrameNoButton, '未就绪')--:SetText(GetText("NOT_READY", UnitSex("player")))


    --插件
    set(AddonListTitleText, '插件列表')
    reg(AddonListForceLoad, '加载过期插件', 1)

    set(AddonListEnableAllButton, '全部启用')
    set(AddonListDisableAllButton, '全部禁用')
    hooksecurefunc('AddonList_Update', function()--AddonList.lua
        if ( not InGlue() ) then
            if ( AddonList_HasAnyChanged() ) then
                set(AddonListOkayButton, '重新加载UI')
            else
                set(AddonListOkayButton, '确定')
            end
        end
    end)
    set(AddonListCancelButton, '取消')
    hooksecurefunc('AddonList_InitButton', function(entry, addonIndex)
        local security = select(6, C_AddOns.GetAddOnInfo(addonIndex))
        -- Get the character from the current list (nil is all characters)
        local character = UIDropDownMenu_GetSelectedValue(AddonCharacterDropDown)
        if ( character == true ) then
            character = nil
        end
        local loadable, reason = C_AddOns.IsAddOnLoadable(addonIndex, character)
        local checkboxState = C_AddOns.GetAddOnEnableState(addonIndex, character)
        if (checkboxState == Enum.AddOnEnableState.Some ) then
            entry.Enabled.tooltip = '该插件只对某些角色启用。'
        end
        local name= _G["ADDON_"..security]
        if name then
            local text= e.strText[name]
            if text then
                entry.Security.tooltip = text
            end
            if ( not loadable and reason ) then
                set(entry.Status, e.strText[name])
            end
        end
    end)

    --拾取
    set(GroupLootHistoryFrameTitleText, '战利品掷骰')
    set(GroupLootHistoryFrame.NoInfoString, '地下城和团队副本的战利品掷骰在此显示')

    --邮箱 MailFrame.lua
    --MailFrame:HookScript('OnShow', function(self)
    set(InboxTooMuchMailText, '你的收件箱已满。')
    set(MailFrameTrialError, '你需要升级你的账号才能开启这项功能。')
    hooksecurefunc('MailFrameTab_OnClick', function(self, tabID)
        tabID = tabID or self:GetID()
        if tabID == 1  then
            MailFrame:SetTitle('收件箱')
        elseif tabID==2 then
            MailFrame:SetTitle('发件箱')
        end
    end)
    set(MailFrameTab1, '收件箱')
        set(OpenAllMail, '全部打开')
        hooksecurefunc(OpenAllMail,'StartOpening', function(self)
            set(self, '正在打开……')
        end)
        hooksecurefunc(OpenAllMail,'StopOpening', function(self)
            set(self, '全部打开')
        end)
        hooksecurefunc('InboxFrame_Update', function()
            local numItems = GetInboxNumItems()
            local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1
            for i=1, INBOXITEMS_TO_DISPLAY do
                if ( index <= numItems ) then
                    local daysLeft = select(7, GetInboxHeaderInfo(index))
                    if ( daysLeft >= 1 ) then
                        daysLeft = GREEN_FONT_COLOR_CODE..format('%d|4天:天', floor(daysLeft)).." "..FONT_COLOR_CODE_CLOSE
                    else
                        daysLeft = RED_FONT_COLOR_CODE..SecondsToTime(floor(daysLeft * 24 * 60 * 60))..FONT_COLOR_CODE_CLOSE
                    end
                    local expireTime= _G["MailItem"..i.."ExpireTime"]
                    if expireTime then
                        set(expireTime, daysLeft)
                        if ( InboxItemCanDelete(index) ) then
                            expireTime.tooltip = '信息保留时间'
                        else
                            expireTime.tooltip = '信息退回时间'
                        end
                    end
                end
                index = index + 1
            end
        end)
        local region= InboxPrevPageButton:GetRegions()
        if region and region:GetObjectType()=='FontString' then
            region:SetText('上一页')
        end
        region= InboxNextPageButton:GetRegions()
        if region and region:GetObjectType()=='FontString' then
            region:SetText('下一页')
        end
        --[[region= select(3, SendMailNameEditBox:GetRegions())
        if region and region:GetObjectType()=='FontString' then
            region:SetText('收件人：')
        end]]
        region= select(3, SendMailSubjectEditBox:GetRegions())
        if region and region:GetObjectType()=='FontString' then
            region:SetText('主题：')
        end



    set(MailFrameTab2, '发件箱')
        set(SendMailMailButton, '发送')
        set(SendMailCancelButton, '取消')
        hooksecurefunc('SendMailRadioButton_OnClick', function(index)--MailFrame.lua
            if ( index == 1 ) then
                SendMailMoneyText:SetText('|cnRED_FONT_COLOR:寄送金额：')
            else
                SendMailMoneyText:SetText('|cnGREEN_FONT_COLOR:付款取信邮件的金额')
            end
        end)
        set(SendMailSendMoneyButtonText, '|cnRED_FONT_COLOR:发送钱币')
        set(SendMailCODButtonText, '|cnGREEN_FONT_COLOR:付款取信')
        hooksecurefunc('SendMailAttachment_OnEnter', function(self)
            local index = self:GetID()
            if ( not HasSendMailItem(index) ) then
                GameTooltip:SetText('将物品放在这里随邮件发送', 1.0, 1.0, 1.0)
            end
        end)


        set(OpenMailSenderLabel, '来自：')
        set(OpenMailSubjectLabel, '主题：')
        hooksecurefunc('OpenMail_Update', function()
            if not InboxFrame.openMailID then
                return
            end
            local _, _, _, _, isInvoice, isConsortium = GetInboxText(InboxFrame.openMailID)
            if ( isInvoice ) then
                local invoiceType, itemName, playerName, _, _, _, _, _, etaHour, etaMin, count, commerceAuction = GetInboxInvoiceInfo(InboxFrame.openMailID)
                if ( invoiceType ) then
                    if ( playerName == nil ) then
                        playerName = (invoiceType == "buyer") and '多个卖家' or '多个买家'
                    end
                    local multipleSale = count and count > 1
                    if ( multipleSale ) then
                        itemName = format(AUCTION_MAIL_ITEM_STACK, itemName, count)
                    end
                    OpenMailInvoicePurchaser:SetShown(not commerceAuction)
                    if ( invoiceType == "buyer" ) then
                        OpenMailInvoicePurchaser:SetText("销售者： "..playerName)
                        OpenMailInvoiceAmountReceived:SetText('|cnRED_FONT_COLOR:付费金额：')
                    elseif (invoiceType == "seller") then
                        OpenMailInvoiceItemLabel:SetText("物品售出： "..itemName)
                        OpenMailInvoicePurchaser:SetText("购买者： "..playerName)
                        OpenMailInvoiceAmountReceived:SetText('|cnGREEN_FONT_COLOR:收款金额：')

                    elseif (invoiceType == "seller_temp_invoice") then
                        OpenMailInvoiceItemLabel:SetText("物品售出： "..itemName)
                        OpenMailInvoicePurchaser:SetText("购买者： "..playerName)
                        OpenMailInvoiceAmountReceived:SetText('等待发送的数量：')
                        OpenMailInvoiceMoneyDelay:SetFormattedText('预计投递时间%s', GameTime_GetFormattedTime(etaHour, etaMin, true))
                    end
                end
            end

            if ( isConsortium ) then
                local info = C_Mail.GetCraftingOrderMailInfo(InboxFrame.openMailID) or {}
                if ( info.reason == Enum.RcoCloseReason.RcoCloseCancel ) then
                    ConsortiumMailFrame.OpeningText:SetText('你的制造订单已被取消。')
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseExpire ) then
                    ConsortiumMailFrame.OpeningText:SetText('你的制造订单已过期。')
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseFulfill ) then
                    ConsortiumMailFrame.OpeningText:SetFormattedText('订单：%s',info.recipeName)
                    ConsortiumMailFrame.CrafterText:SetFormattedText('完成者：|cnHIGHLIGHT_FONT_COLOR:%s|r', info.crafterName or "")
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseReject ) then
                    ConsortiumMailFrame.OpeningText:SetFormattedText('订单：%s', info.recipeName)
                    ConsortiumMailFrame.CrafterText:SetFormattedText('|cnHIGHLIGHT_FONT_COLOR:%s|r决定不完成此订单。', info.crafterName or "")
                elseif ( info.reason == Enum.RcoCloseReason.RcoCloseCrafterFulfill ) then
                    ConsortiumMailFrame.OpeningText:SetFormattedText('订单：%s', info.recipeName)
                    ConsortiumMailFrame.CrafterText:SetFormattedText('收件人：%s', info.customerName or "")
                    ConsortiumMailFrame.ConsortiumNote:SetFormattedText('嗨，%1$s，你完成了%3$s的%2$s的订单，但还没寄给对方。因为你的订单即将过期，所以我们在没有收取额外费用的情况下帮你寄出去了！附上你的佣金。', UnitName("player"), info.recipeName, info.customerName or "")
                end
            end

            if (OpenMailFrame.itemButtonCount and OpenMailFrame.itemButtonCount > 0 ) then
                OpenMailAttachmentText:SetText('|cnGREEN_FONT_COLOR:拿取附件：')
            else
                OpenMailAttachmentText:SetText('无附件')
            end
            if InboxItemCanDelete(InboxFrame.openMailID) then
                OpenMailDeleteButton:SetText('删除')
            else
                OpenMailDeleteButton:SetText('退信')
            end
            set(OpenMailFrameTitleText, '打开邮件')
        end)
        set(OpenMailReplyButton, '回复')
        set(OpenMailCancelButton, '关闭')
    set(OpenMailInvoiceSalePrice, '售价：')
    set(OpenMailInvoiceDeposit, '保证金：')
    set(OpenMailInvoiceHouseCut, '拍卖费：')
    set(OpenMailInvoiceNotYetSent, '未发送的数量')

    set(OpenMailReportSpamButton, '举报玩家')
    set(ConsortiumMailFrame.CommissionReceived, '附上佣金：')
    set(ConsortiumMailFrame.CommissionPaidDisplay.CommissionPaidText, '已支付佣金：')

    hooksecurefunc('GuildChallengeAlertFrame_SetUp', function(frame, challengeType)--AlertFrameSystems.lua
        local name= _G["GUILD_CHALLENGE_TYPE"..challengeType]
        if name then
            set(frame.Type, e.strText[name])
        end
    end)

    hooksecurefunc('AchievementAlertFrame_SetUp', function(frame, achievementID, alreadyEarned)
        --local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = select(12, GetAchievementInfo(achievementID)
        local unlocked = frame.Unlocked
        if select(12, GetAchievementInfo(achievementID)) then
            unlocked:SetText('获得公会成就')
        else
            unlocked:SetText('已获得成就')
        end
    end)

    hooksecurefunc('LootWonAlertFrame_SetUp', function(self, _, _, _, _, _, _, _, _, _, _, _, _, _, isSecondaryResult)
        if isSecondaryResult then
            self.Label:SetText('你获得了')--YOU_RECEIVED_LABEL
        end
    end)

    hooksecurefunc('HonorAwardedAlertFrame_SetUp', function(self, amount)
        self.Amount:SetFormattedText('%d点荣誉', amount)
    end)
    hooksecurefunc('GarrisonShipFollowerAlertFrame_SetUp', function(frame, _, _, _, _, _, _, isUpgraded)
        if ( isUpgraded ) then
            frame.Title:SetText('升级的舰船已加入你的舰队')
        else
            frame.Title:SetText('舰船已加入你的舰队')
        end
    end)
    hooksecurefunc('NewRecipeLearnedAlertFrame_SetUp', function(self, recipeID, recipeLevel)
        local tradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID)
        if tradeSkillID then
            local recipeName = GetSpellInfo(recipeID)
            if recipeName then
                local rank = GetSpellRank(recipeID)
                self.Title:SetText(rank and rank > 1 and '配方升级！' or '学会了新配方！')

                if recipeLevel ~= nil then
                    recipeName = format('%s (等级 %i)', recipeName, recipeLevel)
                    local rankTexture = NewRecipeLearnedAlertFrame_GetStarTextureFromRank(rank)
                    if rankTexture then
                        self.Name:SetFormattedText("%s %s", recipeName, rankTexture)
                    else
                        self.Name:SetText(recipeName)
                    end
                end
            end
        end
    end)

    hooksecurefunc(SkillLineSpecsUnlockedAlertFrameMixin,'SetUp', function(self, skillLineID)
        self.Title:SetText('解锁新要素：')
        self.Name:SetFormattedText('%s专精', C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID))
    end)
    hooksecurefunc('WorldQuestCompleteAlertFrame_SetUp', function(frame, questData)
        frame.ToastText:SetText(questData.displayAsObjective and '目标完成！' or '世界任务完成！')
    end)

    hooksecurefunc(ItemAlertFrameMixin, 'SetUpDisplay', function(self, _, _, _, label)
        if label== YOU_COLLECTED_LABEL then
            self.Label:SetText('你收集到了')
        end
    end)

    --死亡
    set(GhostFrameContentsFrameText, '返回墓地')

    --宠物对战
    if PetBattleFrame then
        set(PetBattleFrame.BottomFrame.TurnTimer.SkipButton, '待命')
    end

    --[[任务对话框
    set(GossipFrame.GreetingPanel.GoodbyeButton, '再见')
    set(QuestFrameAcceptButton, '接受')
    set(QuestFrameGreetingGoodbyeButton, '再见')
    set(QuestFrameCompleteQuestButton, '完成任务')
    set(QuestFrameCompleteButton, '继续')
    set(QuestFrameGoodbyeButton, '再见')
    set(QuestFrameDeclineButton, '拒绝')
    set(QuestLogPopupDetailFrameAbandonButton, '放弃')
    set(QuestLogPopupDetailFrameShareButton, '共享')
    set(QuestLogPopupDetailFrame.ShowMapButton.Text, '显示地图')

    set(QuestMapFrame.DetailsFrame.BackButton, '返回')
    set(QuestMapFrame.DetailsFrame.AbandonButton, '放弃')

   hooksecurefunc('QuestMapFrame_UpdateQuestDetailsButtons', function()
        local questID = C_QuestLog.GetSelectedQuest()
        local isWatched = QuestUtils_IsQuestWatched(questID)
        if isWatched then
            QuestMapFrame.DetailsFrame.TrackButton:SetText('取消追踪')
            QuestLogPopupDetailFrame.TrackButton:SetText('取消追踪')
        else
            QuestMapFrame.DetailsFrame.TrackButton:SetText('追踪')
            QuestLogPopupDetailFrame.TrackButton:SetText('追踪')
        end
    end)

    set(QuestMapFrame.DetailsFrame.ShareButton, '共享')
    QuestMapFrame.DetailsFrame.DestinationMapButton.tooltipText= '显示最终目的地'
    QuestMapFrame.DetailsFrame.WaypointMapButton.tooltipText= '显示旅行路径'

    reg(QuestMapFrame.DetailsFrame.RewardsFrame, '奖励')
    set(MapQuestInfoRewardsFrame.ItemChooseText, '你可以从这些奖励品中选择一件：')
    set(MapQuestInfoRewardsFrame.PlayerTitleText, '新头衔： %s')
    set(MapQuestInfoRewardsFrame.QuestSessionBonusReward, '在小队同步状态下完成此任务有可能获得奖励：')
    set(QuestInfoRequiredMoneyText, '需要金钱：')
    set(QuestInfoRewardsFrame.ItemChooseText, '你可以从这些奖励品中选择一件：')
    set(QuestInfoRewardsFrame.PlayerTitleText, '新头衔： %s')
    set(QuestInfoRewardsFrame.QuestSessionBonusReward, '在小队同步状态下完成此任务有可能获得奖励：')


    hooksecurefunc(WorldMapFrame, 'SetupTitle', function(self)
        self.BorderFrame:SetTitle('地图和任务日志')
    end)
    hooksecurefunc(WorldMapFrame, 'SynchronizeDisplayState', function(self)
        if self:IsMaximized() then
            self.BorderFrame:SetTitle('地图')
        else
            self.BorderFrame:SetTitle('地图和任务日志')
        end
    end)
    set(WorldMapFrameHomeButtonText, '世界', nil, true)

    local optionButton=WorldMapFrame.overlayFrames[2]
    if optionButton then
        optionButton:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '地图筛选')
	        GameTooltip:Show()
        end)
    end
    local pingButton= WorldMapFrame.overlayFrames[3]
    if pingButton then
        pingButton:HookScript('OnEnter', function(self)--WorldMapTrackingPinButtonMixin:OnEnter()
            GameTooltip_SetTitle(GameTooltip, '地图标记')
            local mapID = self:GetParent():GetMapID()
            if C_Map.CanSetUserWaypointOnMap(mapID) then
                GameTooltip_AddNormalLine(GameTooltip, '在地图上放置一个位置标记，此标记可以追踪，也可以分享给其他玩家。')
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip_AddInstructionLine(GameTooltip, '点击这个按钮，然后在地图上点击来放置一个标记，或者直接<按住Ctrl点击地图>。')
            else
                GameTooltip_AddErrorLine(GameTooltip, '你不能在这张地图上放置标记。')
            end
            GameTooltip:Show()
        end)
    end
    local threatButton=  WorldMapFrame.overlayFrames[7]
    if threatButton then
        GameTooltip_SetTitle(GameTooltip, '恩佐斯突袭')
        GameTooltip_AddColoredLine(GameTooltip, '点击浏览被恩佐斯的军队突袭的地区。', GREEN_FONT_COLOR)
        GameTooltip:Show()
    end]]

    --小地图
    MinimapCluster.ZoneTextButton.tooltipText = MicroButtonTooltipText('世界地图', "TOGGLEWORLDMAP")
    MinimapCluster.ZoneTextButton:HookScript('OnEvent', function(self)
        self.tooltipText = MicroButtonTooltipText('世界地图', "TOGGLEWORLDMAP")
    end)
    Minimap.ZoomIn:HookScript('OnEnter', function()
        if GameTooltip:IsShown() then
            GameTooltip:SetText('放大')
        end
    end)
    Minimap.ZoomOut:HookScript('OnEnter', function()
        if GameTooltip:IsShown() then
            GameTooltip:SetText('缩小')
        end
    end)
    MinimapCluster.TrackingFrame.Button:HookScript('OnEnter', function()
        GameTooltip:SetText('追踪', 1, 1, 1)
	    GameTooltip:AddLine('点击以开启或关闭追踪类型。', nil, nil, nil, true)
        GameTooltip:Show()
    end)
    hooksecurefunc('MinimapMailFrameUpdate', function()
        local senders = { GetLatestThreeSenders() }
        local headerText = #senders >= 1 and '未读邮件来自：' or '你有未阅读的邮件'
        for i, sender in ipairs(senders) do
            headerText = headerText.."\n"..(e.strText[sender] or sender)
        end
        GameTooltip:SetText(headerText)
        GameTooltip:Show()
    end)
    
    hookLable(MinimapZoneText)

    --背包
    set(BagItemSearchBox.Instructions, '搜索')

    --SharedReportFrame.xml
    set(ReportFrame.TitleText, '《魔兽世界》客户支持')
    hooksecurefunc(ReportFrame, 'InitiateReportInternal', function(self, reportInfo, playerName, playerLocation, isBnetReport, sendReportWithoutDialog)--SharedReportFrame.lua
        local name
        local guid= playerLocation and playerLocation.guid
        if guid then
            name= e.GetPlayerInfo({guid=guid, reName=true, reRealm=true})
        end
        name= name and name~='' and name or playerName
        set(self.ReportString, format('举报 %s', name))
    end)
    set(ReportFrame.ReportingMajorCategoryDropdown.Label, '选择理由')

    set(ReportFrame.MinorReportDescription, '提供详细信息（选择所有适合的项目）')
    set(ReportFrame.Comment.EditBox.Instructions, '补充更多关于这次举报的细节（可选）')
    hooksecurefunc(ReportingFrameMinorCategoryButtonMixin, 'SetupButton', function(self, minorCategory)
        local categoryName = minorCategory and _G[C_ReportSystem.GetMinorCategoryString(minorCategory)]
        setLabel(self.Text, categoryName)
    end)
    set(ReportFrame.ThankYouText, '感谢您的举报！')
    set(ReportFrame.TitleText, '《魔兽世界》客户支持')
    set(ReportFrame.ReportButton, '举报')



























    --编辑模式    
    set(EditModeManagerFrame.Title, 'HUD编辑模式')
    EditModeManagerFrame.Tutorial.MainHelpPlateButtonTooltipText= '点击这里打开/关闭编辑模式的帮助系统。'
    set(EditModeManagerFrame.ShowGridCheckButton.Label, '显示网格')
    set(EditModeManagerFrame.EnableSnapCheckButton.Label, '贴附到界面元素上')
    set(EditModeManagerFrame.EnableAdvancedOptionsCheckButton.Label, '高级选项')
    set(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.FramesTitle.Title, '框体')
    set(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.CombatTitle.Title, '战斗')
    set(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.MiscTitle.Title, '其它')
    set(EditModeManagerFrame.LayoutDropdown.Label, '布局：')
    hooksecurefunc(EditModeManagerFrame.AccountSettings, 'SetExpandedState', function(self, expanded, isUserInput)
        set(self.Expander.Label, expanded and '收起选项 |A:editmode-up-arrow:16:11:0:3|a' or '展开选项 |A:editmode-down-arrow:16:11:0:-7|a')
    end)
    set(EditModeManagerFrame.AccountSettings.Expander.Label, '展开选项 |A:editmode-down-arrow:16:11:0:-7|a')
    set(EditModeManagerFrame.RevertAllChangesButton, '撤销所有变更')
    set(EditModeManagerFrame.SaveChangesButton, '保存')

    --EditModeDialogs.lua
    set(EditModeUnsavedChangesDialog.CancelButton, '取消')
    hooksecurefunc(EditModeUnsavedChangesDialog, 'ShowDialog', function(self, selectedLayoutIndex)
        if selectedLayoutIndex then
            set(self.Title, '如果你切换布局，你会丢失所有未保存的改动。|n你想继续吗？')
            set(self.SaveAndProceedButton, '保存并切换')
            set(self.ProceedButton, '切换')
        else
            set(self.Title, '如果你现在退出，你会丢失所有未保存的改动。|n你想继续吗？')
            set(self.SaveAndProceedButton, '保存并退出')
            set(self.ProceedButton, '退出')
        end
    end)

    hooksecurefunc(EditModeSystemSettingsDialog, 'AttachToSystemFrame', function(self, systemFrame)
        local name= systemFrame:GetSystemName()
        setLabel(self.Title, name)
    end)

    set(EditModeNewLayoutDialog.Title, '给新布局起名')
    set(EditModeNewLayoutDialog.CharacterSpecificLayoutCheckButton.Label, '角色专用布局')
    set(EditModeNewLayoutDialog.AcceptButton, '保存')
    set(EditModeNewLayoutDialog.CancelButton, '取消')

    set(EditModeImportLayoutDialog.Title, '导入布局')
    set(EditModeImportLayoutDialog.EditBoxLabel, '导入文本：')
    set(EditModeImportLayoutDialog.ImportBox.EditBox.Instructions, '在此粘贴布局代码')
    set(EditModeImportLayoutDialog.NameEditBoxLabel, '新布局名称：')
    set(EditModeImportLayoutDialog.CharacterSpecificLayoutCheckButton.Label, '角色专用布局')
    set(EditModeImportLayoutDialog.AcceptButton, '导入')
    set(EditModeImportLayoutDialog.CancelButton, '取消')


    EditModeImportLayoutDialog.AcceptButton.disabledTooltip= '输入布局的名称'
    EditModeNewLayoutDialog.AcceptButton.disabledTooltip= '输入布局的名称'

    local function CheckForMaxLayouts(acceptButton, charSpecificButton)
        if EditModeManagerFrame:AreLayoutsFullyMaxed() then
            acceptButton.disabledTooltip = format('最多允许%d种角色布局和%d种账号布局', Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType)
            return true
        end
        local layoutType = charSpecificButton:IsControlChecked() and Enum.EditModeLayoutType.Character or Enum.EditModeLayoutType.Account
        local areLayoutsMaxed = EditModeManagerFrame:AreLayoutsOfTypeMaxed(layoutType)
        if areLayoutsMaxed then
            acceptButton.disabledTooltip = (layoutType == Enum.EditModeLayoutType.Character) and format('只允许有%d个角色专用的布局。勾选以保存一种账号通用的布局', Constants.EditModeConsts.EditModeMaxLayoutsPerType) or format('只允许有%d个账号通用的布局。勾选以保存一种角色专用的布局', Constants.EditModeConsts.EditModeMaxLayoutsPerType)
            return true
        end
    end
    local function CheckForDuplicateLayoutName(acceptButton, editBox)
        local editBoxText = editBox:GetText()
        local editModeLayouts = EditModeManagerFrame:GetLayouts()
        for _, layout in ipairs(editModeLayouts) do
            if layout.layoutName == editBoxText then
                acceptButton.disabledTooltip = '该名称已被使用。'
                return true
            end
        end
    end
    hooksecurefunc(EditModeImportLayoutDialog, 'UpdateAcceptButtonEnabledState', function(self)
        if not CheckForMaxLayouts(self.AcceptButton, self.CharacterSpecificLayoutCheckButton)
            and not CheckForDuplicateLayoutName(self.AcceptButton, self.LayoutNameEditBox)  then
            self.AcceptButton.disabledTooltip = '输入布局的名称'
        end
    end)
    hooksecurefunc(EditModeNewLayoutDialog, 'UpdateAcceptButtonEnabledState', function(self)
        if not CheckForMaxLayouts(self.AcceptButton, self.CharacterSpecificLayoutCheckButton)
            and not CheckForDuplicateLayoutName(self.AcceptButton, self.LayoutNameEditBox)  then
            self.AcceptButton.disabledTooltip = '输入布局的名称'
        end
    end)

    --EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.CombatContainer

    for _, frame in pairs(EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.BasicOptionsContainer:GetLayoutChildren() or {}) do
        if frame.labelText then
            set(frame.Label, e.strText[frame.labelText])
        end
    end

    EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.FramesContainer:HookScript('OnShow', function(self)
        for _,frame in pairs(self:GetLayoutChildren() or {}) do
            local text= e.strText[frame.labelText]
            if text then
                frame:SetLabelText(text)
                --set(frame.Label, e.strText[frame.labelText])
            end
        end
    end)
    EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.CombatContainer:HookScript('OnShow', function(self)
        for _,frame in pairs(self:GetLayoutChildren() or {}) do
            local text= e.strText[frame.labelText]
            if text then
                frame:SetLabelText(text)
                --set(frame.Label, e.strText[frame.labelText])
            end
        end
    end)
    EditModeManagerFrame.AccountSettings.SettingsContainer.ScrollChild.AdvancedOptionsContainer.MiscContainer:HookScript('OnShow', function(self)
        for _,frame in pairs(self:GetLayoutChildren() or {}) do
            local text= e.strText[frame.labelText]
            if text then
                frame:SetLabelText(text)
            end
            if frame.disabledTooltipText== HUD_EDIT_MODE_LOOT_FRAME_DISABLED_TOOLTIP then
                frame.disabledTooltipText= '你必须关闭位于：界面 > 控制菜单中的“鼠标位置打开拾取窗口”选项，才能自定义拾取窗口布局。'
            end
        end
    end)
    hooksecurefunc(EditModeManagerFrame.AccountSettings, 'SetupStatusTrackingBar2', function(self)
        self.settingsCheckButtons.StatusTrackingBar2:SetLabelText('状态栏 2')
    end)


    --EditModeTemplates.lua
    hooksecurefunc(EditModeSettingCheckboxMixin, 'SetupSetting', function(self, settingData)
        setLabel(self.Label, settingData.settingName)
    end)
    hooksecurefunc(EditModeSettingDropdownMixin, 'SetupSetting', function(self, settingData)
        setLabel(self.Label, settingData.settingName)
    end)
    hooksecurefunc(EditModeSettingSliderMixin, 'SetupSetting', function(self, settingData)
        setLabel(self.Label, settingData.settingName)
        if settingData.displayInfo.minText then
            setLabel(self.Slider.MinText, settingData.displayInfo.minText)
        end
        if settingData.displayInfo.maxText then
            setLabel(self.Slider.MaxText, settingData.displayInfo.maxText)
        end
    end)
    EditModeManagerFrame.CloseButton:HookScript('OnEnter', function()--EditModeUnsavedChangesCheckerMixin:OnEnter()
        if EditModeManagerFrame:TryShowUnsavedChangesGlow() then
            GameTooltip_AddNormalLine(GameTooltip, '你有未保存的改动')
            GameTooltip:Show()
        end
    end)
    hooksecurefunc(EditModeDropdownEntryMixin, 'OnEnter', function(self)
        if not self.isEnabled then
            local text= e.strText[self.disabledTooltip]
            if text then
                GameTooltip_ShowDisabledTooltip(GameTooltip, self, text)
            end
        end
    end)
    local maxLayoutsErrorText = format('最多允许%d种角色布局和%d种账号布局', Constants.EditModeConsts.EditModeMaxLayoutsPerType, Constants.EditModeConsts.EditModeMaxLayoutsPerType)
    hooksecurefunc(EditModeDropdownEntryMixin, 'Init', function(self, text, _, disableOnMaxLayouts, disableOnActiveChanges, _, _, _, _, disabledText)
        if disableOnMaxLayouts and EditModeManagerFrame:AreLayoutsFullyMaxed() then
            self.disabledTooltip = maxLayoutsErrorText
        elseif disableOnActiveChanges and EditModeManagerFrame:HasActiveChanges()then
            self.disabledTooltip = '你有未保存的改动'
        end
        if disabledText and not self.isEnabled then
            text = disabledText
        end
        setLabel(self.Text, text)
    end)

    set(EditModeSystemSettingsDialog.Buttons.RevertChangesButton, '撤销变更')
    hooksecurefunc(EditModeSystemSettingsDialog, 'UpdateExtraButtons', function(self, systemFrame)
        if systemFrame == self.attachedToSystem then
            set(systemFrame.resetToDefaultPositionButton, '重设到默认位置')
        end
    end)
    hooksecurefunc(EditModeSystemSettingsDialog, 'UpdateButtons', function(self, systemFrame)
        if systemFrame == self.attachedToSystem then
            if systemFrame.Selection then
                setLabel(systemFrame.Selection.HorizontalLabel)
                setLabel(systemFrame.Selection.Label)
                setLabel(systemFrame.Selection.VerticalLabel)
            end
        end
    end)








    hooksecurefunc(ButtonTrayUtil, 'TestCheckBoxTraySetup', function(button, labelText, callback, customFont)--ButtonTrayUtil.lua
        setLabel(button, labelText)
    end)
    hooksecurefunc(ResizeCheckButtonMixin, 'SetLabelText', function(self, labelText)
        if self.Label ~= nil then
            setLabel(self.Label, labelText)
        end
    end)





    --GameTooltip.lua
    --替换，原生
    function GameTooltip_OnTooltipAddMoney(self, cost, maxcost)
        if( not maxcost or maxcost < 1 ) then --We just have 1 price to display
            SetTooltipMoney(self, cost, nil, string.format("%s:", '卖价'))
        else
            GameTooltip_AddColoredLine(self, ("%s:"):format('卖价'), HIGHLIGHT_FONT_COLOR)
            local indent = string.rep(" ",4)
            SetTooltipMoney(self, cost, nil, string.format("%s%s:", indent, '最小'))
            SetTooltipMoney(self, maxcost, nil, string.format("%s%s:", indent, '最大'))
        end
    end

    TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT.headerText = '奖励'
    TOOLTIP_QUEST_REWARDS_STYLE_WORLD_QUEST.headerText = '奖励'
    TOOLTIP_QUEST_REWARDS_STYLE_CONTRIBUTION.headerText = '为该建筑捐献物资会奖励你：'
    TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY.headerText = '悬赏奖励'
    TOOLTIP_QUEST_REWARDS_STYLE_ISLANDS_QUEUE.headerText = '获胜奖励：'
    TOOLTIP_QUEST_REWARDS_STYLE_EMISSARY_REWARD.headerText = '奖励'
    TOOLTIP_QUEST_REWARDS_PRIORITIZE_CURRENCY_OVER_ITEM.headerText = '奖励'


    --Ping系统
    set(PingSystemTutorialTitleText, '信号系统')
    set(PingSystemTutorial.Tutorial1.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:按下|r信号键，在世界上放置快速信号。')
    set(PingSystemTutorial.Tutorial2.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:按下并按住|r信号键，选择一个特定的信号。')
    set(PingSystemTutorial.Tutorial3.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:直接|r向一名生物或角色发送信号。')
    set(PingSystemTutorial.Tutorial4.TutorialHeader, '|cnTUTORIAL_BLUE_FONT_COLOR:设置使用|r信号的宏。')
    set(PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody1, "在聊天中|cnNORMAL_FONT_COLOR:输入/macro|r")
    set(PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody2, "宏命令：")
    set(PingSystemTutorial.Tutorial4.ImageBounds.TutorialBody3, "|cnNORMAL_FONT_COLOR:/ping [@target] 信号类型|r")




    --BNet.lua
    hooksecurefunc(BNToastFrame, 'ShowToast', function(self)
        local toastType, toastData
        toastType, toastData = self.toastType or {}, self.toastData or {}
        if ( toastType == 5 ) then
            set(self.DoubleLine, '你收到了一个新的好友请求。')
        elseif ( toastType == 4 ) then
            set(self.DoubleLine, format('你共有|cff82c5ff%d|r条好友请求。', toastData))
        elseif ( toastType == 1 ) then
            if C_BattleNet.GetAccountInfoByID(toastData) then
                set(self.BottomLine, FRIENDS_GRAY_COLOR:WrapTextInColorCode('已经|cff00ff00上线|r'))
            end
        elseif ( toastType == 2 ) then
            if C_BattleNet.GetAccountInfoByID(toastData) then
                set(self.BottomLine, '已经|cffff0000下线|r。')
            end
        elseif ( toastType == 6 ) then
            local clubName

            if toastData.club.clubType == Enum.ClubType.BattleNet then
                clubName = BATTLENET_FONT_COLOR:WrapTextInColorCode(toastData.club.name)
            else
                clubName = NORMAL_FONT_COLOR:WrapTextInColorCode(toastData.club.name)
            end
            set(self.DoubleLine, format('你已受邀加入|n%s', clubName or ''))
        elseif (toastType == 7) then
            local clubName = NORMAL_FONT_COLOR:WrapTextInColorCode(toastData.name)
            set(self.DoubleLine, format('你已受邀加入|n%s', clubName or ''))
        end
    end)



    set(StoreFrame.TitleContainer, '商城')
























    QuickJoinToastButton:HookScript('OnEnter', function(self)
        if ( not KeybindFrames_InQuickKeybindMode() ) then
            if ( self.displayedToast ) then
                local queues = C_SocialQueue.GetGroupQueues(self.displayedToast.guid)
                if ( queues ) then
                    local knowsLeader = SocialQueueUtil_HasRelationshipWithLeader(self.displayedToast.guid)
                    GameTooltip:SetOwner(self.Toast, self.isOnRight and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
                    SocialQueueUtil_SetTooltip(GameTooltip, SocialQueueUtil_GetHeaderName(self.displayedToast.guid), queues, true, knowsLeader)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine('|cnGREEN_FONT_COLOR:<点击加入>')
                    GameTooltip:Show()
                end
            else
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip_SetTitle(GameTooltip, MicroButtonTooltipText('社交', "TOGGLESOCIAL"))
                GameTooltip:Show()
            end
        end
    end)

    ChatFrameChannelButton:SetTooltipFunction(function()--ChannelFrameButtonMixin.lua
		return MicroButtonTooltipText('聊天频道', "TOGGLECHATTAB")
	end)

    MainMenuBarVehicleLeaveButton:HookScript('OnEnter', function()
        if UnitOnTaxi("player") then
            GameTooltip_SetTitle(GameTooltip, '请求终止')
            GameTooltip:AddLine('将在下一个可用的飞行管理员处着陆。', NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
            GameTooltip:Show()
        else
            GameTooltip_SetTitle(GameTooltip, '退出')
            GameTooltip:Show()
        end
    end)


    CharacterMicroButton.tooltipText = MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0")--MainMenuBarMicroButtons.lua
    CharacterMicroButton:HookScript('OnEvent', function(self, event)
        if ( event == "UPDATE_BINDINGS" ) then
		    self.tooltipText = MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0")
        end
    end)

    SpellbookMicroButton.tooltipText = MicroButtonTooltipText('法术书和专业', "TOGGLESPELLBOOK")
    SpellbookMicroButton:HookScript('OnEvent', function(self, event)
        if ( event == "UPDATE_BINDINGS" ) then
		    self.tooltipText = MicroButtonTooltipText('法术书和专业', "TOGGLESPELLBOOK")
        end
    end)

    TalentMicroButton.tooltipText = MicroButtonTooltipText('专精和天赋', "TOGGLETALENTS")
    TalentMicroButton.newbieText = '天赋的各种组合选择能够强化你的角色，并使你的角色与众不同。'
    TalentMicroButton:HookScript('OnEvent', function(self, event)
        if ( event == "UPDATE_BINDINGS" ) then
		    self.tooltipText = MicroButtonTooltipText('专精和天赋', "TOGGLETALENTS")
        end
    end)

    AchievementMicroButton.tooltipText = MicroButtonTooltipText('成就', "TOGGLEACHIEVEMENT")
    AchievementMicroButton.newbieText = '浏览有关你的成就和统计数据的信息。'
    AchievementMicroButton:HookScript('OnEvent', function(self, event)
        if not Kiosk.IsEnabled() and event == "UPDATE_BINDINGS" then
		    self.tooltipText = MicroButtonTooltipText('成就', "TOGGLEACHIEVEMENT")
        end
    end)

    hooksecurefunc(QuestLogMicroButton, 'UpdateTooltipText', function(self)
        self.tooltipText = MicroButtonTooltipText('任务日志', "TOGGLEQUESTLOG")
	    self.newbieText = '你现在所拥有的任务。你最多可以同时拥有25条任务记录。'
    end)

    hooksecurefunc(GuildMicroButton, 'UpdateMicroButton', function(self)
        if ( IsCommunitiesUIDisabledByTrialAccount() or self.factionGroup == "Neutral" or Kiosk.IsEnabled() ) then
            if not Kiosk.IsEnabled() then
                self.disabledTooltip = '免费试玩账号无法进行此项操作'
            end
        elseif ( C_Club.IsEnabled() and not BNConnected() ) then
            self.disabledTooltip = '不可用|n|n暴雪游戏服务目前不可用。'
        elseif ( C_Club.IsEnabled() and C_Club.IsRestricted() ~= Enum.ClubRestrictionReason.None ) then
            self.disabledTooltip = '不可用'
        elseif not (( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( _G['GuildFrame'] and _G['GuildFrame']:IsShown() )) then

            if ( CommunitiesFrame_IsEnabled() ) then
                self.tooltipText = MicroButtonTooltipText('公会与社区', "TOGGLEGUILDTAB")
                --self.newbieText = NEWBIE_TOOLTIP_COMMUNITIESTAB
            elseif ( IsInGuild() ) then
                self.tooltipText = MicroButtonTooltipText('公会', "TOGGLEGUILDTAB")
                self.newbieText = '查看关于你所在的公会及其会员的信息。如果你是公会的管理人员，还可以在这个窗口中进行公会管理工作。'
            else
                self.tooltipText = MicroButtonTooltipText('公会查找器', "TOGGLEGUILDTAB")
                self.newbieText = '让您找到一个公会。'
            end
        end
    end)

    LFDMicroButton.tooltipText = MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER")
    LFDMicroButton.disabledTooltip = function()
		local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder()
		return canUse and '此功能在你选择阵营前不可用。' or (e.strText[failureReason] or failureReason)
	end
    hooksecurefunc(LFDMicroButton, 'UpdateMicroButton',function(self)
        if not ( PVEFrame and PVEFrame:IsShown() ) and not self:IsActive() then
            self.disabledTooltip = function()
                local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder()
                return canUse and '此功能在你选择阵营前不可用。' or (e.strText[failureReason] or failureReason)
            end
        end
    end)
    LFDMicroButton:HookScript('OnEvent', function(self, event)
        if ( event == "UPDATE_BINDINGS" ) then
		    self.tooltipText = MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER")
        end
    end)

    CollectionsMicroButton.tooltipText = MicroButtonTooltipText('藏品', "TOGGLECOLLECTIONS")
    CollectionsMicroButton:HookScript('OnEvent', function(self, event)
        if CollectionsJournal and CollectionsJournal:IsShown() then
            return
        end
        if ( event == "UPDATE_BINDINGS" ) then
		    self.tooltipText = MicroButtonTooltipText('藏品', "TOGGLECOLLECTIONS")
        end
    end)

    EJMicroButton.tooltipText = MicroButtonTooltipText('地下城手册', "TOGGLEENCOUNTERJOURNAL")
    EJMicroButton.newbieText = '查看各个地下城及团队副本首领的资料，包括他们的技能和收藏的宝物。'
    EJMicroButton:HookScript('OnEvent', function(self, event)
        if event == "UPDATE_BINDINGS" then
		    self.tooltipText = MicroButtonTooltipText('冒险指南', "TOGGLEENCOUNTERJOURNAL")
            EJMicroButton.newbieText = '查看各个地下城及团队副本首领的资料，包括他们的技能和收藏的宝物。'
        end
    end)
    if not (EncounterJournal and EncounterJournal:IsShown() ) and not AdventureGuideUtil.IsAvailable() then
        EJMicroButton.disabledTooltip = Kiosk.IsEnabled() and (e.onlyChinese and '该系统目前已被禁用。' or ERR_SYSTEM_DISABLED) or (e.onlyChinese and '该功能尚不可用。' or FEATURE_NOT_YET_AVAILABLE)
    end
    hooksecurefunc(EJMicroButton, 'UpdateDisplay', function(self)
        if not ( EncounterJournal and EncounterJournal:IsShown() ) and not AdventureGuideUtil.IsAvailable() then
            self.disabledTooltip = Kiosk.IsEnabled() and (e.onlyChinese and '该系统目前已被禁用。' or ERR_SYSTEM_DISABLED) or (e.onlyChinese and '该功能尚不可用。' or FEATURE_NOT_YET_AVAILABLE)
        end
    end)


    StoreMicroButton.tooltipText = '商城'
    hooksecurefunc(StoreMicroButton, 'UpdateMicroButton', function(self)
        if ( C_StorePublic.IsDisabledByParentalControls() ) then
            self.disabledTooltip = '家长监控已禁用了该功能。'
        elseif ( Kiosk.IsEnabled() ) then
            self.disabledTooltip = '该系统目前已被禁用。'
        elseif ( not C_StorePublic.IsEnabled() ) then
            if not ( GetCurrentRegionName() == "CN" ) then
                self.disabledTooltip = '商城当前不可用。'
            end
        end
    end)










    --NavigationBar.lua
    hooksecurefunc('NavBar_AddButton', function(self, buttonData)
        local navButton = self.navList[#self.navList]
        local name= e.strText[buttonData.name]
        if name then
            set(navButton.text, name, nil, true)
            local buttonExtraWidth
            if ( buttonData.listFunc and not self.oldStyle ) then
                buttonExtraWidth = 53
            else
                buttonExtraWidth = 30
            end
            navButton:SetWidth(navButton.text:GetStringWidth() + buttonExtraWidth)
        end
    end)
    hooksecurefunc('NavBar_Initialize', function(_, _, homeData, homeButton)
        set(homeButton.text, e.strText[homeData.name] or '首页', nil, true)
    end)


    --MovieFrame.xml
    reg(MovieFrame.CloseDialog, '你确定想要跳过这段过场动画吗？', 1)
    set(MovieFrame.CloseDialog.ConfirmButton, '是')
    set(MovieFrame.CloseDialog.ResumeButton, '否')




    --StackSplitFrame.lua
    hooksecurefunc(StackSplitFrame, 'ChooseFrameType', function(self, splitAmount)
        if splitAmount ~= 1 then
            set(self.StackSplitText, format('%d 堆', self.split/self.minSplit))
            set(self.StackItemCountText, format('总计%d', self.split))
        end
    end)
    hooksecurefunc(StackSplitFrame, 'UpdateStackText', function(self)
        if self.isMultiStack then
            set(self.StackSplitText, format('%d 堆', self.split/self.minSplit))
            set(self.StackItemCountText, format('总计%d', self.split))
        end
    end)

    --LootFrame.lua
    set(LootFrameTitleText, '物品')
    hooksecurefunc(LootFrameItemElementMixin, 'Init', function(self)
        local elementData = self:GetElementData() or {}
        if elementData.quality then
	        setLabel(self.QualityText, _G[format("ITEM_QUALITY%s_DESC", elementData.quality)])
        end
    end)




    --SharedUIPanelTemplates.lua
    hooksecurefunc(SliderControlFrameMixin, 'SetupSlider', function(self, _, _, _, _, label)
        setLabel(self.Label, label)
    end)

    hooksecurefunc('SearchBoxTemplate_OnLoad', function(self)--SharedUIPanelTemplates.lua
        set(self.Instructions, '搜索')
    end)
    hooksecurefunc('Main_HelpPlate_Button_ShowTooltip', function(self)
        set(HelpPlateTooltip.Text, self.MainHelpPlateButtonTooltipText or '点击这里打开/关闭本窗口的帮助系统。')
    end)
    hooksecurefunc(SearchBoxListMixin, 'UpdateSearchPreview', function(self, finished, dbLoaded, numResults)
        if finished and not self.searchButtons[numResults] then
            set(self.showAllResults.text, format('显示全部%d个结果', numResults))
        end
    end)
    hooksecurefunc(IconSelectorPopupFrameTemplateMixin, 'SetSelectedIconText', function(self)
        if ( self:GetSelectedIndex() ) then
            set(self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription, '点击在列表中浏览')
        else
            set(self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription, '此图标不在列表中')
        end
    end)
    hooksecurefunc(LabeledEnumDropDownControlMixin, 'SetLabelText', function(self, text)
	    setLabel(self.Label, text)
    end)








    set(StackSplitFrame.OkayButton, '确定')
    set(StackSplitFrame.CancelButton, '取消')

    set(ColorPickerFrame.Footer.OkayButton, '确定')
    set(ColorPickerFrame.Footer.CancelButton, '取消')
    set(ColorPickerFrame.Header.Text, '颜色选择器')

    if e.Player.class=='HUNTER' then
        set(StableFrame.StabledPetList.FilterBar.SearchBox.Instructions, '查询')
        set(StableFrame.StabledPetList.FilterBar.FilterButton, '过滤')
        hookButton(StableFrame.StableTogglePetButton, true)
        set(StableFrame.ReleasePetButton, '释放')
        StableFrame.ReleasePetButton.disabledTooltip='你只能释放你当前召唤的宠物。'
        set(StableFrame.PetModelScene.AbilitiesList.ListHeader, '特殊技能')
        set(StableFrame.ActivePetList.ListName, '激活')
        set(StableFrame.StabledPetList.ListName, '兽栏')
        dia('RELEASE_PET', {text ='你确定要|cnRED_FONT_COLOR:永久释放|r你的宠物吗？你将永远无法再召唤此宠物。', button1='|cnRED_FONT_COLOR:确定|r', button2='|cnGREEN_FONT_COLOR:取消|r',})
        StableFrameTitleText:SetFormattedText('%s%s%s|r 的宠物', e.Icon.player, e.Player.col, e.Player.name)
        hooksecurefunc(StableFrame.PetModelScene.PetInfo, 'SetPet', function(self, petData)
            if petData.isExotic then
                set(self.Exotic, '特殊')
            end
        end)
    end





    --Blizzard_Dialogs.lua
    dia('CONFIRM_RESET_TO_DEFAULT_KEYBINDINGS', {text = '确定将所有快捷键设置为默认值吗？', button1 = '确定', button2 = '取消'})
    dia('GAME_SETTINGS_TIMED_CONFIRMATION', {button1 = '确定', button2 = '取消'})
    hookDia('GAME_SETTINGS_TIMED_CONFIRMATION', 'OnUpdate', function(self, elapsed)
        local duration = self.duration - elapsed
        local time = math.max(duration + 1, 1)
        set(self.text, format('接受新选项？\n\n|cnGREEN_FONT_COLOR:%d|r 秒后|cnGREEN_FONT_COLOR:恢复。|r', time))
        StaticPopup_Resize(self, "GAME_SETTINGS_TIMED_CONFIRMATION")
    end)
    dia('GAME_SETTINGS_CONFIRM_DISCARD', {text= '你尚有还未应用的设置。\n你确定要退出吗？', button1 = '退出', button2 = '应用并退出', button3 = '取消'})
    dia('GAME_SETTINGS_APPLY_DEFAULTS', {text= '你想要将所有用户界面和插件设置重置为默认状态，还是只重置这个界面或插件的设置？', button1 = '所有设置', button2 = '这些设置', button3 = '取消'})


    --StaticPopup.lua
    hookDia("GENERIC_CONFIRMATION", 'OnShow', function(self, data)--StaticPopup.lua
        if data.text==HUD_EDIT_MODE_DELETE_LAYOUT_DIALOG_TITLE then
            set(self.text, format('你确定要删除布局|n|cnGREEN_FONT_COLOR:%s|r吗？', data.text_arg1, data.text_arg2))

        elseif data.text==SELL_ALL_JUNK_ITEMS_POPUP then
            set(self.text, format('你即将出售所有垃圾物品，而且无法回购。\n你确定要继续吗？', data.text_arg1, data.text_arg2))

        elseif data.text==PROFESSIONS_CRAFTING_ORDER_MAIL_REPORT_WARNING then
            set(self.text, format('这名玩家有你还未认领的物品。如果你在认领前举报这名玩家，你会失去所有这些物品。', data.text_arg1, data.text_arg2))

        elseif data.text==SELL_ALL_JUNK_ITEMS_POPUP then
            set(self.text, format('你即将出售所有垃圾物品，而且无法回购。\n你确定要继续吗？', data.text_arg1, data.text_arg2))

        elseif data.text==TALENT_FRAME_CONFIRM_CLOSE then
            set(self.text, format('如果你继续，会失去所有待定的改动。', data.text_arg1, data.text_arg2))

        elseif data.text==CRAFTING_ORDER_RECRAFT_WARNING2 then
            set(self.text, format('再造可能导致你的物品的品质下降。|n|n\n\n你确定要发布此订单吗？', data.text_arg1, data.text_arg2))

        elseif data.text==PROFESSIONS_ORDER_UNUSABLE_WARNING then
            set(self.text, format('此物品目前不能使用，而且拾取后就会绑定。确定要下达此订单吗？', data.text_arg1, data.text_arg2))

        elseif data.text==CRAFTING_ORDERS_IGNORE_CONFIRMATION then
            set(self.text, format('你确定要屏蔽|cnGREEN_FONT_COLOR:%s|r吗？', data.text_arg1, data.text_arg2))

        elseif data.text==CRAFTING_ORDERS_OWN_REAGENTS_CONFIRMATION then
            set(self.text, format('你即将完成一个制造订单，里面包含一些你自己的材料。你确定吗？', data.text_arg1, data.text_arg2))

        elseif data.text==TALENT_FRAME_CONFIRM_LEAVE_DEFAULT_LOADOUT then
            set(self.text, format('你如果不先将你当前的天赋配置储存下来，就会永远失去此配置。|n|n你确定要继续吗？', data.text_arg1, data.text_arg2))

        elseif data.text==TALENT_FRAME_CONFIRM_STARTER_DEVIATION then
            set(self.text, format('选择此天赋会使你离开入门天赋配置指引。', data.text_arg1, data.text_arg2))

        end

        if not data.acceptText then
		    set(self.button1, '是')

        elseif data.acceptText==OKAY then
            set(self.button1, '确定')

        elseif data.acceptText==SAVE then
            set(self.button1, '保存')

        elseif data.acceptText==ACCEPT then
                set(self.button1, '接受')

        elseif data.acceptText==CONTINUE then
            set(self.button1, '继续')
        end

        if not data.cancelText then
            set(self.button2, '否')

        elseif data.cancelText==CANCEL then
            set(self.button2, '取消')
        end

	end)

    hookDia("GENERIC_INPUT_BOX", 'OnShow', function(self, data)
        if data.text==HUD_EDIT_MODE_RENAME_LAYOUT_DIALOG_TITLE then
            set(self.text, format('为布局|cnGREEN_FONT_COLOR:%s|r输入新名称', data.text_arg1, data.text_arg2))
        end

        if not data.acceptText then
            self.button1:SetText('完成')

        elseif data.acceptText==OKAY then
            set(self.button1, '确定')

        elseif data.acceptText==SAVE then
            set(self.button1, '保存')

        elseif data.acceptText==ACCEPT then
                set(self.button1, '接受')

        elseif data.acceptText==CONTINUE then
            set(self.button1, '继续')
        end

        if not data.cancelText then
		    self.button2:SetText('取消')
        end
	end)

    dia("CONFIRM_OVERWRITE_EQUIPMENT_SET", {text = '你已经有一个名为|cnGREEN_FONT_COLOR:%s|r的装备方案了。是否要覆盖已有方案', button1 = '是', button2 = '否'})
    dia("CONFIRM_SAVE_EQUIPMENT_SET", {text = '你想要保存装备方案\"|cnGREEN_FONT_COLOR:%s|r\"吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_DELETE_EQUIPMENT_SET", {text = '你确认要删除装备方案 |cnGREEN_FONT_COLOR:%s|r 吗？', button1 = '是', button2 = '否'})

    dia("CONFIRM_GLYPH_PLACEMENT",{button1 = '是', button2 = '否'})
    hookDia("CONFIRM_GLYPH_PLACEMENT", 'OnShow', function(self)
		self.text:SetFormattedText('你确定要使用|cnGREEN_FONT_COLOR:%s|r铭文吗？这将取代|cnGREEN_FONT_COLOR:%s|r。', self.data.name, self.data.currentName)
	end)

    dia("CONFIRM_GLYPH_REMOVAL",{button1 = '是', button2 = '否'})
    hookDia("CONFIRM_GLYPH_REMOVAL", 'OnShow', function(self)
		self.text:SetFormattedText('你确定要移除|cnGREEN_FONT_COLOR:%s|r吗？', self.data.name)
	end)

    dia("CONFIRM_RESET_TEXTTOSPEECH_SETTINGS", {text = '确定将所有文字转语音设定重置为默认值吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REDOCK_CHAT", {text = '这么做会将你的聊天窗口重新并入综合标签页。', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_PURCHASE_TOKEN_ITEM", {text = '你确定要将%s兑换为下列物品吗？ %s', button1 = '是', button2 = '否'})
    dia("CONFIRM_PURCHASE_NONREFUNDABLE_ITEM", {text = '你确定要将%s兑换为下列物品吗？本次购买将无法退还。%s', button1 = '是', button2 = '否'})

    dia("CONFIRM_UPGRADE_ITEM", {button1 = '是', button2 = '否'})
    hookDia("CONFIRM_UPGRADE_ITEM", 'OnShow', function(self, data)
		if data.isItemBound then
			self.text:SetFormattedText('你确定要花费|cnGREEN_FONT_COLOR:%s|r升级下列物品吗？', data.costString)
		else
			self.text:SetFormattedText('你确定要花费|cnGREEN_FONT_COLOR:%s|r升级下列物品吗？升级会将该物品变成灵魂绑定物品。', data.costString)
		end
    end)

    dia("CONFIRM_REFUND_TOKEN_ITEM", {text = '你确定要退还下面这件物品%s，获得%s的退款吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_REFUND_MAX_HONOR", {text = '你的荣誉已接近上限。卖掉这件物品会让你损失%d点荣誉。确认要继续吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_REFUND_MAX_ARENA_POINTS", {text = '你的竞技场点数已接近上限。出售这件物品会让你损失|cnGREEN_FONT_COLOR:%d|r点竞技场点数。确认要继续吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_REFUND_MAX_HONOR_AND_ARENA", {text = '你的荣誉已接近上限。卖掉此物品会使你损失%1$d点荣誉和%2$d的竞技场点数。要继续吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_HIGH_COST_ITEM", {text = '你确定要花费如下金额的货币购买%s吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_COMPLETE_EXPENSIVE_QUEST", {text = '完成这个任务需要缴纳如下数额的金币。你确定要完成这个任务吗？', button1 = '完成任务', button2 = '取消'})
    dia("CONFIRM_ACCEPT_PVP_QUEST", {text = '接受这个任务之后，你将被标记为PvP状态，直到你放弃或完成此任务。你确定要接受任务吗？', button1 = '接受', button2 = '取消'})
    dia("USE_GUILDBANK_REPAIR", {text = '你想要使用公会资金修理吗？', button1 = '使用个人资金', button2 = '确定'})
    dia("GUILDBANK_WITHDRAW", {text = '接提取数量：', button1 = '接受', button2 = '取消'})
    dia("GUILDBANK_DEPOSIT", {text = '存放数量：', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_BUY_GUILDBANK_TAB", {text = '你是否想要购买一个公会银行标签？', button1 = '是', button2 = '否'})
    dia("CONFIRM_BUY_REAGENTBANK_TAB", {text = '确定购买材料银行栏位吗？', button1 = '是', button2 = '否'})
    dia("TOO_MANY_LUA_ERRORS", {text = '你的插件有大量错误，可能会导致游戏速度降低。你可以在界面选项中打开Lua错误显示。', button1 = '禁用插件', button2 = '忽略'})
    dia("CONFIRM_ACCEPT_SOCKETS", {text = '镶嵌之后，一颗或多颗宝石将被摧毁。你确定要镶嵌新的宝石吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_RESET_INSTANCES", {text = '你确定想要重置你的所有副本吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_RESET_CHALLENGE_MODE", {text = '你确定要重置地下城吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_GUILD_DISBAND", {text = '你真的要解散公会吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_BUY_BANK_SLOT", {text = '你愿意付钱购买银行空位吗？', button1 = '是', button2 = '否'})
    dia("MACRO_ACTION_FORBIDDEN", {text = '一段宏代码已被禁止，因为其功能只对暴雪UI开放。', button1 = '确定'})
    dia("ADDON_ACTION_FORBIDDEN", {text = '|cnRED_FONT_COLOR:%s|r已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。', button1 = '禁用', button2 = '忽略'})
    dia("CONFIRM_LOOT_DISTRIBUTION", {text = '你想要将%s分配给%s，确定吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_BATTLEFIELD_ENTRY", {text = '你现在可以进入战斗：\n\n|cff20ff20%s|r\n', button1 = '进入', button2 = '离开队列'})
    dia("BFMGR_CONFIRM_WORLD_PVP_QUEUED", {text = '你已在%s队列中。请等候。', button1 = '确定'})
    dia("BFMGR_CONFIRM_WORLD_PVP_QUEUED_WARMUP", {text = '你正在下一场%s战斗的等待队列中。', button1 = '确定'})
    dia("BFMGR_DENY_WORLD_PVP_QUEUED", {text = '你现在无法进入%s战场的等待队列。', button1 = '确定'})
    dia("BFMGR_INVITED_TO_QUEUE", {text = '你想要加入%s的战斗吗？', button1 = '接受', button2 = '取消'})
    dia("BFMGR_INVITED_TO_QUEUE_WARMUP", {text = '%s的战斗即将打响！你要加入等待队列吗？', button1 = '接受', button2 = '取消'})
    dia("BFMGR_INVITED_TO_ENTER", {text = '%s的战斗又一次在召唤你！|n现在进入？|n剩余时间：%d %s', button1 = '接受', button2 = '取消'})
    dia("BFMGR_EJECT_PENDING", {text = '你已在%s队列中但还没有收到战斗的召唤。稍后你将被传出战场。', button1 = '确定'})
    dia("BFMGR_EJECT_PENDING_REMOTE", {text = '你已在%s队列中但还没有收到战斗的召唤。', button1 = '确定'})
    dia("BFMGR_PLAYER_EXITED_BATTLE", {text = '你已经从%s的战斗中退出。', button1 = '确定'})
    dia("BFMGR_PLAYER_LOW_LEVEL", {text = '你的级别太低，无法进入%s。', button1 = '确定'})
    dia("BFMGR_PLAYER_NOT_WHILE_IN_RAID", {text = '你不能在团队中进入%s。', button1 = '确定'})
    dia("BFMGR_PLAYER_DESERTER", {text = '在你的逃亡者负面效果消失之前，你无法进入%s。', button1 = '确定'})
    dia("CONFIRM_GUILD_LEAVE", {text = '确定要退出%s？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_GUILD_PROMOTE", {text = '确定要将%s提升为会长？', button1 = '接受', button2 = '取消'})
    dia("RENAME_GUILD", {text = '输入新的公会名：', button1 = '接受', button2 = '取消'})
    dia("HELP_TICKET_QUEUE_DISABLED", {text = 'GM帮助请求暂时不可用。', button1 = '确定'})
    dia("CLIENT_RESTART_ALERT", {text = '你的有些设置需要你重新启动游戏才能够生效。', button1 = '确定'})
    dia("CLIENT_LOGOUT_ALERT", {text = '你的某些设置将在你登出游戏并重新登录之后生效。', button1 = '确定'})
    dia("COD_ALERT", {text = '你没有足够的钱来支付付款取信邮件。', button1 = '关闭'})
    dia("COD_CONFIRMATION", {text = '收下这件物品将花费：', button1 = '接受', button2 = '取消'})
    dia("COD_CONFIRMATION_AUTO_LOOT", {text = '收下这件物品将花费：', button1 = '接受', button2 = '取消'})
    dia("DELETE_MAIL", {text = '删除这封邮件会摧毁%s', button1 = '接受', button2 = '取消'})
    dia("DELETE_MONEY", {text = '删除这封邮件会摧毁：', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REPORT_BATTLEPET_NAME", {text = '你确定要举报%s 使用不当战斗宠物名吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REPORT_PET_NAME", {text = '你确定要举报%s 使用不当战斗宠物名吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_REPORT_SPAM_MAIL", {text = '你确定要举报%s为骚扰者吗？', button1 = '接受', button2 = '取消'})
    dia("JOIN_CHANNEL", {text = '输入频道名称', button1 = '接受', button2 = '取消'})
    dia("CHANNEL_INVITE", {text = '你想要将谁邀请至%s？', button1 = '接受', button2 = '取消'})
    dia("CHANNEL_PASSWORD", {text = '为%s输入一个密码。', button1 = '接受', button2 = '取消'})
    dia("NAME_CHAT", {text = '输入对话窗口名称', button1 = '接受', button2 = '取消'})
    dia("RESET_CHAT", {text = '"将你的聊天窗口重置为默认设置。\n你会失去所有自定义设置。', button1 = '接受', button2 = '取消'})
    dia("PETRENAMECONFIRM", {text = '你确定要将宠物命名为\'%s\'吗？', button1 = '是', button2 = '否'})

    dia("DEATH", {text = '%d%s后释放灵魂', button1 = '释放灵魂', button2 = '复活', button3 = '复活', button4 = '摘要'})
    hookDia("DEATH", 'OnShow', function(self)
		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			self.text:SetText('你死亡了。释放灵魂后将进入观察模式。')
		elseif ( self.timeleft == -1 ) then
			self.text:SetText('你死亡了。要释放灵魂到最近的墓地吗？')
		end
	end)
    local function GetSelfResurrectDialogOptions()
        local resOptions = GetSortedSelfResurrectOptions()
        if ( resOptions ) then
            if ( IsEncounterLimitingResurrections() ) then
                return resOptions[1], resOptions[2]
            else
                return resOptions[1]
            end
        end
    end

    hookDia("DEATH", 'OnUpdate', function(self)
		if ( IsFalling() and not IsOutOfBounds()) then
			return
		end
		local b1_enabled = self.button1:IsEnabled()
		local encounterSupressRelease = IsEncounterSuppressingRelease()
		if ( encounterSupressRelease ) then
			self.button1:SetText('释放灵魂')
		else
			local hasNoReleaseAura, _, hasUntilCancelledDuration = HasNoReleaseAura()
			if ( hasNoReleaseAura ) then
				if hasUntilCancelledDuration then
					self.button1:SetText('释放灵魂')
				end
			else
				self.button1:SetText('释放灵魂')
			end
		end
		if ( b1_enabled ~= self.button1:IsEnabled() ) then
			if ( b1_enabled ) then
				if ( encounterSupressRelease ) then
					self.text:SetText('你队伍中有一名成员正在战斗中。')
				else
					self.text:SetText('现在无法释放。')
				end
			end
		end
        local option1, option2
        local resOptions = GetSortedSelfResurrectOptions()
        if ( resOptions ) then
            if ( IsEncounterLimitingResurrections() ) then
                option1, option2= resOptions[1], resOptions[2]
            else
                option1=resOptions[1]
            end
        end
		if ( option1 ) then
			if ( option1.name ) then
				set(self.button2, e.strText[option1.name])
			end
		end
		if ( option2 ) then
			if ( option2.name ) then
				set(self.button3, e.strText[option2.name])
			end
		end
	end)


    dia("RESURRECT", {text = '%s想要复活你。一旦这样复活，你将会进入复活虚弱状态', delayText = '%s要复活你，%d%s内生效。一旦这样复活，你将会进入复活虚弱状态。', button1 = '接受', button2 = '拒绝'})
    dia("RESURRECT_NO_SICKNESS", {text = '%s想要复活你', delayText = '%s要复活你，%d%s内生效', button1 = '接受', button2 = '拒绝'})
    dia("RESURRECT_NO_TIMER", {text = '%s想要复活你', button1 = '接受', button2 = '拒绝'})
    dia("SKINNED", {text = '徽记被取走 - 你只能在墓地复活', button1 = '接受'})
    dia("SKINNED_REPOP", {text = '徽记被取走 - 你只能在墓地复活', button1 = '释放灵魂', button2 = '拒绝'})
    dia("TRADE", {text = '和%s交易吗？', button1 = '是', button2 = '否'})
    dia("PARTY_INVITE", {button1 = '接受', button2 = '拒绝'})
    dia("GROUP_INVITE_CONFIRMATION", {button1 = '接受', button2 = '拒绝'})
    dia("CHAT_CHANNEL_INVITE", {text = '%2$s邀请你加入\'%1$s\'频道。', button1 = '接受', button2 = '拒绝'})
    dia("BN_BLOCK_FAILED_TOO_MANY_RID", {text = '你能够屏蔽的实名和战网昵称好友已达上限。', button1 = '确定'})
    dia("BN_BLOCK_FAILED_TOO_MANY_CID", {text = '你通过暴雪游戏服务屏蔽的角色数量已达上限。', button1 = '确定'})
    dia("CHAT_CHANNEL_PASSWORD", {text = '请输入\'%1$s\'的密码。', button1 = '接受', button2 = '取消'})
    dia("CAMP", {text = '%d%s后返回角色选择画面', button1 = '取消'})
    dia("QUIT", {text = '%d%s后退出游戏', button1 = '立刻退出', button2 = '取消'})
    dia("LOOT_BIND", {text = '拾取%s后，该物品将与你绑定', button1 = '确定', button2 = '取消'})
    dia("EQUIP_BIND", {text = '装备之后，该物品将与你绑定。', button1 = '确定', button2 = '取消'})
    dia("EQUIP_BIND_REFUNDABLE", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("EQUIP_BIND_TRADEABLE", {text = '执行此项操作会使该物品不可交易。', button1 = '确定', button2 = '取消'})
    dia("USE_BIND", {text = '使用该物品后会将它和你绑定', button1 = '确定', button2 = '取消'})
    dia("CONFIM_BEFORE_USE", {text = '你确定要使用这个物品吗？', button1 = '确定', button2 = '取消'})
    dia("USE_NO_REFUND_CONFIRM", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_AZERITE_EMPOWERED_BIND", {text = '选择一种力量后，此物品会与你绑定。', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_AZERITE_EMPOWERED_SELECT_POWER", {text = '你确定要选择这项艾泽里特之力吗？', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_AZERITE_EMPOWERED_RESPEC", {text = '重铸的花费会随使用的次数而提升。\n\n你确定要花费如下金额来重铸%s吗？', button1 = '是', button2 = '否'})
    dia("CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE", {text = '重铸的花费会随使用的次数而提升。|n|n你确定要花费%s来重铸%s吗？|n|n请输入 %s 以确认。', button1 = '是', button2 = '否'})
    dia("DELETE_ITEM", {text = '你确定要摧毁%s？', button1 = '是', button2 = '否'})
    dia("DELETE_QUEST_ITEM", {text = '确定要销毁%s吗？\n\n|cffff2020销毁该物品的同时也将放弃所有相关任务。|r', button1 = '是', button2 = '否'})
    dia("DELETE_GOOD_ITEM", {text = '你真的要摧毁%s吗？\n\n请在输入框中输入\"'..DELETE_ITEM_CONFIRM_STRING..'\"以确认。', button1 = '是', button2 = '否'})
    dia("DELETE_GOOD_QUEST_ITEM", {text = '确定要摧毁%s吗？\n|cffff2020摧毁该物品也将同时放弃相关任务。|r\n\n请在输入框中输入\"'..DELETE_ITEM_CONFIRM_STRING..'\"以确认。', button1 = '是', button2 = '否'})
    dia("QUEST_ACCEPT", {text = '%s即将开始%s\n你也想这样吗？', button1 = '是', button2 = '否'})
    dia("QUEST_ACCEPT_LOG_FULL", {text = '%s正在开始%s任务\n你的任务纪录已满。如果能够在任务纪录中\n空出位置，你也可以参与此任务。', button1 = '是', button2 = '否'})
    dia("ABANDON_PET", {text = '你是否决定永远地遗弃你的宠物？你将再也不能召唤它了。', button1 = '确定', button2 = '取消'})
    dia("ABANDON_QUEST", {text = '放弃\"%s\"？', button1 = '是', button2 = '否'})
    dia("ABANDON_QUEST_WITH_ITEMS", {text = '确定要放弃\"%s\"并摧毁%s吗？', button1 = '是', button2 = '否'})
    dia("ADD_FRIEND", {text = '输入好友的角色名：', button1 = '接受', button2 = '取消'})
    dia("SET_FRIENDNOTE", {text = '为%s设置备注：', button1 = '接受', button2 = '取消'})
    dia("SET_BNFRIENDNOTE", {text = '为%s设置备注：', button1 = '接受', button2 = '取消'})
    dia("SET_COMMUNITY_MEMBER_NOTE", {text = '为%s设置备注：', button1 = '接受', button2 = '取消'})

    dia("CONFIRM_REMOVE_COMMUNITY_MEMBER", {text = '你确定要将%s从群组中移除吗？', button1 = '是', button2 = '否'})
    hookDia("CONFIRM_REMOVE_COMMUNITY_MEMBER", 'OnShow', function(self, data)
		if data.clubType == Enum.ClubType.Character then
			self.text:SetFormattedText('你确定要将%s从社区中移除吗？', data.name)
		else
			self.text:SetFormattedText('你确定要将%s从群组中移除吗？', data.name)
		end
	end)


    dia("CONFIRM_DESTROY_COMMUNITY_STREAM", {text = '你确定要删除频道%s吗？', button1 = '是', button2 = '否'})
    hookDia("CONFIRM_DESTROY_COMMUNITY_STREAM", 'OnShow', function(self, data)
		local streamInfo = C_Club.GetStreamInfo(data.clubId, data.streamId)
		if streamInfo then
			self.text:SetFormattedText('你确定要删除频道%s吗', streamInfo.name)
		end
	end)

    dia("CONFIRM_LEAVE_AND_DESTROY_COMMUNITY", {text = '确定要退出并删除群组吗？', subText = '退出后群组会被删除。你确定要删除群组吗？此操作无法撤销。', button1 = '接受', button2 = '取消'})
    hookDia("CONFIRM_LEAVE_AND_DESTROY_COMMUNITY", 'OnShow', function(self, clubInfo)
        if clubInfo.clubType == Enum.ClubType.Character then
            self.text:SetText('确定要退出并删除社区吗？')
            self.SubText:SetText('退出后社区会被删除。你确定要删除社区吗？此操作无法撤销。')
        else
            self.text:SetText('确定要退出并删除群组吗？')
            self.SubText:SetText('退出后群组会被删除。你确定要删除群组吗？此操作无法撤销。')
        end
    end)

    dia("CONFIRM_LEAVE_COMMUNITY", {text = '退出群组？', subText = '你确定要退出%s吗？', button1 = '接受', button2 = '取消'})
    hookDia("CONFIRM_LEAVE_COMMUNITY", 'OnShow', function(self, clubInfo)
        if clubInfo.clubType == Enum.ClubType.Character then
			self.text:SetText('退出社区？')
			self.SubText:SetFormattedText('你确定要退出%s吗？', clubInfo.name)
		else
			self.text:SetText('退出群组？')
			self.SubText:SetFormattedText('你确定要退出%s吗？', clubInfo.name)
		end
    end)

    dia("CONFIRM_DESTROY_COMMUNITY", {button1 = '接受', button2 = '取消'})
    hookDia("CONFIRM_DESTROY_COMMUNITY", 'OnShow', function(self, clubInfo)
        if clubInfo.clubType == Enum.ClubType.BattleNet then
			self.text:SetFormattedText('你确定要删除群组\"%s\"吗？此操作无法撤销。|n|n请在输入框中输入\"'..COMMUNITIES_DELETE_CONFIRM_STRING ..'\"以确认。', clubInfo.name)
		else
			self.text:SetFormattedText('你确定要删除社区\"%s\"吗？此操作无法撤销。|n|n请在输入框中输入\"'..COMMUNITIES_DELETE_CONFIRM_STRING ..'\"以确认。', clubInfo.name)
		end
    end)

    dia("ADD_IGNORE", {text = '输入想要屏蔽的玩家名字\n或者\n在聊天窗口中按住Shift并点击该玩家的名字：', button1 = '接受', button2 = '取消'})
    dia("ADD_GUILDMEMBER", {text = '添加公会成员：', button1 = '接受', button2 = '取消'})
    dia("CONVERT_TO_RAID", {text = '你的队伍已经满了。你想要将队伍转换成团队吗？\n\n注意：在团队中，你的大部分任务都无法完成！', button1 = '转换', button2 = '取消'})
    dia("LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID", {text = '你的队伍已经满了。你想要将队伍转换成团队吗？\n\n注意：在团队中，你的大部分任务都无法完成！', button1 = '转换', button2 = '取消'})

    dia("REMOVE_GUILDMEMBER", {text = format('确定想要从公会中移除%s吗？', "XXX"), button1 = '是', button2 = '否'})
    hookDia("REMOVE_GUILDMEMBER", 'OnShow', function(self, data)
		if data then
			self.text:SetFormattedText('你确定想要从公会中移除%s吗？', data.name)
		end
	end)

    dia("SET_GUILDPLAYERNOTE", {text = '设置玩家信息', button1 = '接受', button2 = '取消'})
    dia("SET_GUILDOFFICERNOTE", {text = '设置公会官员信息', button1 = '接受', button2 = '取消'})

    dia("SET_GUILD_COMMUNITIY_NOTE", {text = '设置玩家信息', button1 = '接受', button2 = '取消'})
    hookDia("SET_GUILD_COMMUNITIY_NOTE", 'OnShow', function(self, data)
		if data then
			self.text:SetText(data.isPublic and '设置玩家信息' or '设置公会官员信息')
		end
	end)

    dia("RENAME_PET", {text = '输入你想要给宠物起的名字：', button1 = '接受', button2 = '取消'})
    dia("DUEL_REQUESTED", {text = '%s向你发出决斗要求。', button1 = '接受', button2 = '拒绝'})
    dia("DUEL_OUTOFBOUNDS", {text = '正在离开决斗区域,你将在%d%s内失败。'})
    dia("PET_BATTLE_PVP_DUEL_REQUESTED", {text = '%s向你发出宠物对战要求。', button1 = '接受', button2 = '拒绝'})
    dia("UNLEARN_SKILL", {text = '你确定要忘却%s并遗忘所有已经学会的配方？如果你选择回到此专业，你的专精知识将依然存在。|n|n在框内输入 \"'..UNLEARN_SKILL_CONFIRMATION ..'\" 以确认。', button1 = '忘却这个技能', button2 = '取消'})
    dia("XP_LOSS", {text = '如果你找到你的尸体，那么你可以在没有任何惩罚的情况下复活。现在由我来复活你，那么你的所有物品（包括已装备的和物品栏中的）将损失50%%的耐久度，你也要承受%s的|cff71d5ff|Hspell:15007|h[复活虚弱]|h|r时间。', button1 = '接受', button2 = '取消'})
    dia("XP_LOSS_NO_SICKNESS_NO_DURABILITY", {text = '你可以找到你的尸体并在尸体位置复活。10级以下的玩家可以在此复活并不受任何惩罚。"', button1 = '接受', button2 = '取消'})
    dia("RECOVER_CORPSE", {delayText = '%d%s后复活', text= '现在复活吗？', button1 = '接受'})
    dia("RECOVER_CORPSE_INSTANCE", {text= '你必须进入副本才能捡回你的尸体。'})
    dia("AREA_SPIRIT_HEAL", {text = '%d%s后复活', button1 = '选择位置', button2 = '取消'})
    dia("BIND_ENCHANT", {text = '对这件物品进行附魔将使其与你绑定。', button1 = '确定', button2 = '取消'})
    dia("BIND_SOCKET", {text = '该操作将使此物品与你绑定。', button1 = '确定', button2 = '取消'})
    dia("REFUNDABLE_SOCKET", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("ACTION_WILL_BIND_ITEM", {text = '该操作将使此物品与你绑定。', button1 = '确定', button2 = '取消'})
    dia("REPLACE_ENCHANT", {text = '你要将\"%s\"替换为\"%s\"吗？', button1 = '是', button2 = '否'})
    dia("REPLACE_TRADESKILL_ENCHANT", {text = '你要将\"%s\"替换为\"%s\"吗？', button1 = '是', button2 = '否'})
    dia("TRADE_REPLACE_ENCHANT", {text = '你要将\"%s\"替换为\"%s\"吗？', button1 = '是', button2 = '否'})
    dia("TRADE_POTENTIAL_BIND_ENCHANT", {text = '将此物品附魔会使其与你绑定。', button1 = '确定', button2 = '取消'})
    dia("TRADE_POTENTIAL_REMOVE_TRANSMOG", {text = '交易%s后，将把它从你的外观收藏中移除。', button1 = '确定'})
    dia("CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL", {text = '出售后%s将变为不可交易物品，即使你将其回购也无法恢复。', button1 = '确定', button2 = '取消'})
    dia("END_BOUND_TRADEABLE", {text = '执行此项操作会使该物品不可交易。', button1 = '确定', button2 = '取消'})
    dia("INSTANCE_BOOT", {text = '你现在不在这个副本的队伍里。你将在%d%s内被传送到最近的墓地中。'})
    dia("GARRISON_BOOT", {text = '该要塞不属于你或者你的队长。你将在%d %s后被传送出要塞。'})
    dia("INSTANCE_LOCK", {text = '你进入了一个已经保存进度的副本！你将在%2$s内被保存到%1$s的副本进度中！', button1 = '接受', button2 = '离开副本'})
    --dia("CONFIRM_TALENT_WIPE", {text = '你确定要遗忘所有的天赋吗', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_BINDER", {text = '你想要将%s设为你的新家吗？', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_SUMMON", {text = '%s想将你召唤到%s去。这个法术将在%d%s后取消。', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_SUMMON_SCENARIO", {text = '%s已在%s开启一个场景战役。你是否愿意加入他们？\n\n此邀请将在%d%s后失效。', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_SUMMON_STARTING_AREA", {text = '%s想召唤你前往%s。\n\n你将无法返回此初始区域。\n\n该法术将在%d %s后取消。', button1 = '接受', button2 = '取消'})
    dia("BILLING_NAG", {text = '您的帐户中还有%d%s的剩余游戏时间', button1 = '确定'})
    dia("IGR_BILLING_NAG", {text = '你的IGR游戏时间即将用尽，你很快会被断开连接。', button1 = '确定'})
    dia("CONFIRM_LOOT_ROLL", {text = '拾取%s后，该物品将与你绑定。', button1 = '确定', button2 = '取消'})
    dia("GOSSIP_CONFIRM", {button1 = '接受', button2 = '取消'})
    dia("GOSSIP_ENTER_CODE", {text = '请输入电子兑换券号码：', button1 = '接受', button2 = '取消'})
    dia("CREATE_COMBAT_FILTER", {text = '输入过滤名称：', button1 = '接受', button2 = '取消'})
    dia("COPY_COMBAT_FILTER", {text = '输入过滤名称：', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_COMBAT_FILTER_DELETE", {text = '你确认要删除这个过滤条件？', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_COMBAT_FILTER_DEFAULTS", {text = '你确定要将过滤条件设定为初始状态吗？', button1 = '确定', button2 = '取消'})
    dia("WOW_MOUSE_NOT_FOUND", {text = '无法找到魔兽世界专用鼠标。请连接鼠标后在用户界面中再次启动该选项。', button1 = '确定'})
    dia("CONFIRM_BUY_STABLE_SLOT", {text = '你确定要支付以下数量的金币来购买一个新的兽栏栏位吗？', button1 = '是', button2 = '否'})
    dia("TALENTS_INVOLUNTARILY_RESET", {text = '因为天赋树有了一些改动，你的某些天赋已被重置。', button1 = '确定'})
    dia("TALENTS_INVOLUNTARILY_RESET_PET", {text = '你的宠物天赋已被重置。', button1 = '确定'})
    dia("SPEC_INVOLUNTARILY_CHANGED", {text = '由于该专精暂时无法使用，你的角色专精已发生改变。', button1 = '确定'})

    dia("VOTE_BOOT_PLAYER", {button1 = '是', button2 = '否'})

    dia("VOTE_BOOT_REASON_REQUIRED", {text = '请写明将%s投票移出的理由：', button1 = '确定', button2 = '取消'})
    dia("LAG_SUCCESS", {text = '你的延迟报告已经成功提交。', button1 = '确定'})
    dia("LFG_OFFER_CONTINUE", {text = '一名玩家离开了你的队伍。是否寻找另一名玩家以完成%s？', button1 = '是', button2 = '否'})
    dia("CONFIRM_MAIL_ITEM_UNREFUNDABLE", {text = '进行此项操作会使该物品无法退还', button1 = '确定', button2 = '取消'})
    dia("AUCTION_HOUSE_DISABLED", {text = '拍卖行目前暂时关闭。|n请稍后再试。', button1 = '确定'})
    dia("CONFIRM_BLOCK_INVITES", {text = '你确定要屏蔽任何来自%s的邀请？', button1 = '接受', button2 = '取消'})
    dia("BATTLENET_UNAVAILABLE", {text = '暴雪游戏服务暂时不可用。\n\n你的实名和战网昵称好友无法显示，你也无法发送或收到实名或战网昵称好友邀请。也许需要重启游戏以重新启用暴雪游戏服务功能。', button1 = '确定'})
    dia("WEB_PROXY_FAILED", {text = '在配置浏览器时发生错误。请重启魔兽世界并再试一次。', button1 = '确定'})
    dia("WEB_ERROR", {text = '错误：%d|n浏览器无法完成你的请求。请重试。', button1 = '确定'})
    dia("CONFIRM_REMOVE_FRIEND", {button1 = '接受', button2 = '取消'})
    hookDia("CONFIRM_REMOVE_FRIEND", 'OnShow', function(self)
        local text= self.text:GetText() or ''
        local name= text:match(e.Magic(BATTLETAG_REMOVE_FRIEND_CONFIRMATION))
        local name2= text:match(e.Magic(REMOVE_FRIEND_CONFIRMATION))
        if name then
            set(self.text, format('你确定要将  |cnRED_FONT_COLOR:%s|r 移出|cff82c5ff战网昵称|r好友名单吗？', name))
        elseif name2 then
            set(self.text, format('你确定要将 |cnRED_FONT_COLOR:%s|r 移出|cnGREEN_FONT_COLOR:实名|r好友名单？', name2))
        end
    end)
    dia("PICKUP_MONEY", {text = '提取总额', button1 = '接受', button2 = '取消'})
    dia("CONFIRM_GUILD_CHARTER_PURCHASE", {text = '你会失去在上一个公会中的一级公会声望\n你是否要继续？', button1 = '是', button2 = '否'})
    dia("GUILD_DEMOTE_CONFIRM", {button1 = '是', button2 = '否'})
    dia("GUILD_PROMOTE_CONFIRM", {button1 = '是', button2 = '否'})
    dia("CONFIRM_RANK_AUTHENTICATOR_REMOVE", {button1 = '是', button2 = '否'})
    dia("VOID_DEPOSIT_CONFIRM", {text = '储存这件物品将移除该物品上的一切改动并使其无法退还，且无法交易。\n你是否要继续？', button1 = '确定', button2 = '取消'})
    dia("GUILD_IMPEACH", {text = '你所在公会的领袖已被标记为非活动状态。你现在可以争取公会领导权。是否要移除公会领袖？', button1 = '弹劾', button2 = '取消'})
    dia("SPELL_CONFIRMATION_PROMPT", {button1 = '是', button2 = '否'})
    dia("SPELL_CONFIRMATION_WARNING", {button1 = '确定'})
    dia("CONFIRM_LAUNCH_URL", {text = '点击“确定”后将在你的网络浏览器中打开一个窗口。', button1 = '确定', button2 = '取消'})

    dia("CONFIRM_LEAVE_INSTANCE_PARTY", {button1 = '是', button2 = '取消'})
    StaticPopupDialogs["CONFIRM_LEAVE_INSTANCE_PARTY"].OnShow= function(self)
        local text= self.text:GetText()
        if text== CONFIRM_LEAVE_BATTLEFIELD then
            set(self.text, '确定要离开战场吗？')
        elseif text== CONFIRM_LEAVE_INSTANCE_PARTY then
            set(self.text, '确定要离开副本队伍吗？\n\n一旦离开队伍，你将无法返回该副本。')
        end
    end

    dia("CONFIRM_LEAVE_BATTLEFIELD", {text = '确定要离开战场吗？', button1 = '是', button2 = '取消'})
    hookDia("CONFIRM_LEAVE_BATTLEFIELD", 'OnShow', function(self)
		local ratedDeserterPenalty = C_PvP.GetPVPActiveRatedMatchDeserterPenalty()
		if ( ratedDeserterPenalty ) then
			local ratingChange = math.abs(ratedDeserterPenalty.personalRatingChange)
			local queuePenaltySpellLink, queuePenaltyDuration = C_SpellBook.GetSpellLinkFromSpellID(ratedDeserterPenalty.queuePenaltySpellID), SecondsToTime(ratedDeserterPenalty.queuePenaltyDuration)
			self.text:SetFormattedText('现在离开比赛会使你失去至少|cnORANGE_FONT_COLOR:%1$d|r点评级分数，而且你会受到%3$s的影响，持续%2$s。|n|n如果你现在离开，你将无法获得你完成的回合的荣誉或征服点数。|n|n你确定要离开比赛吗？', ratingChange, queuePenaltyDuration, queuePenaltySpellLink)
		elseif ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			self.text:SetText('确定要离开竞技场吗？')
		else
			self.text:SetText('确定要离开战场吗？')
		end
	end)

    dia("CONFIRM_SURRENDER_ARENA", {text= '放弃？', button1 = '是', button2 = '取消'})
    hookDia("CONFIRM_SURRENDER_ARENA", 'OnShow', function(self)
		self.text:SetText('放弃？')
	end)


    dia("SAVED_VARIABLES_TOO_LARGE", {text = '你的计算机内存不足，无法加载下列插件设置。请关闭部分插件。\n\n|cffffd200%s|r', button1 = '确定'})
    dia("PRODUCT_ASSIGN_TO_TARGET_FAILED", {text = '获取物品错误。请重试一次。', button1 = '确定'})
    hookDia("BATTLEFIELD_BORDER_WARNING", 'OnUpdate', function(self)
        self.text:SetFormattedText('你已经脱离了%s的战斗。\n\n为你保留的位置将在%s后失效。', self.data.name, SecondsToTime(self.timeleft, false, true))
    end)
    dia("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS", {text = '针对此项活动，你的队伍人数已满，将被移出列表。', button1 = '确定'})
    dia("LFG_LIST_ENTRY_EXPIRED_TIMEOUT", {text = '你的队伍由于长期处于非活跃状态，已被移出列表。如果你还需要寻找申请者，请重新加入列表。', button1 = '确定'})
    dia("NAME_TRANSMOG_OUTFIT", {text = '输入外观方案名称：', button1 = '保存', button2 = '取消'})
    dia("CONFIRM_OVERWRITE_TRANSMOG_OUTFIT", {text = '你已经有一个名为%s的外观方案了。是否要覆盖已有方案？', button1 = '是', button2 = '否'})
    dia("CONFIRM_DELETE_TRANSMOG_OUTFIT", {text = '确定要删除外观方案%s吗？', button1 = '是', button2 = '否'})
    dia("TRANSMOG_OUTFIT_CHECKING_APPEARANCES", {text = '检查外观……', button1 = '取消'})
    dia("TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES", {text = '由于你的角色无法幻化此套装下的任何外观，因此你无法保存此外观方案。', button1 = '确定'})
    dia("TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES", {text = '此外观方案无法保存，因为你的角色有一件或多件物品无法幻化。', button1 = '确定', button2 = '取消'})
    dia("TRANSMOG_APPLY_WARNING", {button1 = '确定', button2 = '取消'})
    dia("TRANSMOG_FAVORITE_WARNING", {text = '将此外观设置为偏好外观将使你背包中的这个物品无法退款且无法交易。\n确定要继续吗？', button1 = '确定', button2 = '取消'})
    dia("CONFIRM_UNLOCK_TRIAL_CHARACTER", {text = '确定要升级这个角色吗？完成此步骤之后，你将无法更改自己的选择。', button1 = '确定', button2 = '取消'})
    dia("DANGEROUS_SCRIPTS_WARNING", {text = '你正试图运行自定义脚本。运行自定义脚本可能危害到你的角色，导致物品或金币损失。|n|n确定要运行吗？', button1 = '是', button2 = '否'})
    dia("EXPERIMENTAL_CVAR_WARNING", {text = '您已开启了一项或多项实验性镜头功能。这可能对部分玩家造成视觉上的不适。', button1 = '接受', button2 = '禁用"'})
    dia("PREMADE_GROUP_SEARCH_DELIST_WARNING", {text = '你的预创建队伍界面上已有一组队伍列表。是否要清除列表，开始新的搜索？', button1 = '是', button2 = '否'})

    dia("PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING", {text = '你已经被提升为队伍领袖|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0:0:0:-1|t |n|n|cffffd200你想以此队名重新列出队伍吗？|r|n%s|n', subText = '|n%s后自动从列表移除', button1 = '列出我的队伍', button2 = '我想编辑队名', button3 = '不列出我的队伍'})
    hookDia("PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING", 'OnShow', function(self, data)
		self.text:SetFormattedText('你已经被提升为队伍领袖|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0:0:0:-1|t |n|n|cffffd200你想以此队名重新列出队伍吗？|r|n%s|n', data.listingTitle)
	end)

    dia("PREMADE_GROUP_INSECURE_SEARCH", {text= '你的队伍已被移出列表，要搜索|n%s吗？', button1 = '是', button2 = '否'})
    dia("BACKPACK_INCREASE_SIZE", {text = '为您的《魔兽世界》账号添加安全令和短信安全保护功能，即可获得4格额外的背包空间。|n|n战网安全令完全免费，而且使用方便，可以有效地保护您的账号。短信安全保护功能可以在账号有重要改动时为您通知提醒。|n|n点击“启用”以打开账号安全设置页面。', button1 = '启用', button2 = '取消'})
    dia("GROUP_FINDER_AUTHENTICATOR_POPUP", {text = '为你的账号添加安全令和短信安全保护功能后就能使用队伍查找器的全部功能。|n|n战网安全令完全免费，而且使用方便，可以有效地保护您的账号，短信安全保护功能可以在账号有重要改动时为您通知提醒。|n|n点击“启用”即可打开安全令设置网站。', button1 = '启用', button2 = '取消'})
    dia("CLIENT_INVENTORY_FULL_OVERFLOW", {text= '你的背包满了。给背包腾出空间才能获得遗漏的物品。', button1 = '确定'})

    dia("LEAVING_TUTORIAL_AREA", {button2 = '结束教程"'})
    hookDia("LEAVING_TUTORIAL_AREA", 'OnShow', function(self)
		if UnitFactionGroup("player") == "Horde" then
			self.button1:SetText('返回')
			self.text:SetText('你距离奥格瑞玛太远了。|n |n如果你继续走的话，就会脱离教程。|n |n你想返回奥格瑞玛吗？|n |n |n')
		else
			self.button1:SetText('返回')
			self.text:SetText('你距离暴风城太远了。|n |n如果你继续走的话，就会脱离教程。|n |n你想返回暴风城吗？|n |n |n')
		end
	end)

    dia("CLUB_FINDER_ENABLED_DISABLED", {text = '公会和社区查找器已可用或不可用。', button1 = '确定'})

    dia("INVITE_COMMUNITY_MEMBER", {text = '邀请成员', subText = '输入战网昵称。',button1 = '发送', button2 = '取消'})
    hookDia("INVITE_COMMUNITY_MEMBER", 'OnShow', function(self, data)
		local clubInfo = C_Club.GetClubInfo(data.clubId) or {}
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			self.SubText:SetText('输入一位战网好友名称')
			self.editBox.Instructions:SetText('实名好友或战网昵称')
		else
			self.SubText:SetText('输入角色名-服务器名。')
		end
		self.button1:SetScript("OnEnter", function(self2)
			if(not self2:IsEnabled()) then
                GameTooltip:SetOwner(self2, "ANCHOR_BOTTOMRIGHT")
                GameTooltip_AddColoredLine(GameTooltip, '已经达到最大人数。移除一名玩家后才能进行邀请。', RED_FONT_COLOR, true)
                GameTooltip:Show()
            end
		end)
		if (self.extraButton) then
			self.extraButton:SetScript("OnEnter", function(self2)
				if(not self2:IsEnabled()) then
                    GameTooltip:SetOwner(self2, "ANCHOR_BOTTOMRIGHT")
                    GameTooltip_AddColoredLine(GameTooltip, '已经达到最大人数。移除一名玩家后才能进行邀请。', RED_FONT_COLOR, true)
                    GameTooltip:Show()
                end
			end)
		end
	end)

    dia("CONFIRM_RAF_REMOVE_RECRUIT", {text = '你确定要从你的招募战友中移除|n|cffffd200%s|r|n吗？|n|n请在输入框中输入“'..REMOVE_RECRUIT_CONFIRM_STRING..'”以确定。', button1 = '是', button2 = '否'})

    dia("REGIONAL_CHAT_DISABLED", {
        text = '聊天已关闭',
        subText = '某些区域规定对此账号有影响。聊天功能已经默认关闭。你现在可以重新开启这些功能。或者你之后决定开启的话，可以在聊天设置面板里进行操作。\n\n如果你决定开启这些功能，请注意我们的社区互动规则，如果你遇到了任何的不当言论、行为，只要这些言论和行为对游戏体验造成了破坏或者干扰，您就可以使用我们在游戏内的举报选项进行举报。我们会评估聊天记录并采取对应的措施。',
        button1 = '打开聊天',
        button2 = '聊天保持关闭'
    })

    dia("CHAT_CONFIG_DISABLE_CHAT", {text = '你确定要完全关闭聊天吗？你将无法发送和接收任何信息。', button1 = '关闭聊天', button2 = '取消'})

    dia("RETURNING_PLAYER_PROMPT", {button1 = '是', button2 = '否'})
    hookDia("RETURNING_PLAYER_PROMPT", 'OnShow', function(self)
        local factionMajorCities = {
            ["Alliance"] = '暴风城',
            ["Horde"] = '奥格瑞玛',
        }
		local playerFactionGroup = UnitFactionGroup("player")
		local factionCity = playerFactionGroup and factionMajorCities[playerFactionGroup] or nil
		if factionCity then
			self.text:SetFormattedText('我们有好一阵子没见到你了！|n|n在%s可以开始全新的冒险之旅！|n|n你希望传送到那里吗？', factionCity)
		end
	end)

    dia("CRAFTING_HOUSE_DISABLED", {text = '工匠商盟目前不接受制造订单。|n请稍后再来看看！', button1 = '确定'})
    dia("PERKS_PROGRAM_DISABLED", {text = '商栈目前关闭。|n请稍后再试。', button1 = '确定'})


    --HelpFrame.lua
    dia("EXTERNAL_LINK", {text = '你正被重新定向到：\n|cffffd200%s|r\n点击“确定”，以在你的网页浏览器中打开此链接。', button1 = '确定', button2= '取消', button3 = '复制链接'})

    --LFGFrame.lua
    dia("LFG_QUEUE_EXPAND_DESCRIPTION", {text = '你正被重新定向到：\n|cffffd200%s|r\n点击“确定”，以在你的网页浏览器中打开此链接。', button1 = '是', button2= '否'})

    --Blizzard_PetBattleUI.lua
    dia("PET_BATTLE_FORFEIT", {text = '确定要放弃比赛吗？你的对手将被判定获胜，你的宠物也将损失百分之%d的生命值。', button1 = '确定', button2 = '取消',})
    dia("PET_BATTLE_FORFEIT_NO_PENALTY", {text = '确定要放弃比赛吗？你的对手将被判定获胜。', button1 = '确定', button2 = '取消',})

    --TextToSpeechFrame.lua
    dia("TTS_CONFIRM_SAVE_SETTINGS", {text= '你想让这个角色使用已经在这台电脑上保存的文字转语音设置吗？如果你从另一台电脑上登入，此设置会保存并覆盖之前你拥有的任何设定。', button1= '是', button2= '取消'})

    --Keybindings.lua
    dia("CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS", {text = '确定要切换到通用键位设定吗？所有本角色专用的键位设定都将被永久删除。', button1 = '确定', button2 = '取消'})








    set_GameTooltip_func(GameTooltip)
    set_GameTooltip_func(ItemRefTooltip)
    set_GameTooltip_func(EmbeddedItemTooltip)
    --set_GameTooltip_func(NamePlateTooltip)


    set_pettips_func(BattlePetTooltip)
    set_pettips_func(FloatingBattlePetTooltip)

    --hooksecurefunc(GameTooltip, 'SetText', function(self, text)





    hooksecurefunc('VoiceTranscriptionFrame_UpdateEditBox', function(self)--VoiceChatTranscriptionFrame.lua
        if  C_VoiceChat.IsMuted() then
            set(self.editBox.prompt, '禁音 - 目前没有发送语音识别或文字转语音信息')
        elseif C_VoiceChat.IsSpeakForMeActive() then
            set(self.editBox.prompt, '输入文字后，文字转语音功能会为其他玩家朗读文字。')
        end
    end)



    --UIErrorsFrame
    hooksecurefunc(UIErrorsFrame, 'AddMessage', function(self, msg, ...)
        msg= e.strText[msg]
        if msg then
            self:AddMessage(msg, ...)
        end
    end)


    --团队
    set(CompactRaidFrameManager.displayFrame.label, IsInRaid() and '团员' or '队员')
    hooksecurefunc('CompactRaidFrameManager_UpdateLabel', function()
        set(CompactRaidFrameManager.displayFrame.label, IsInRaid() and '团员' or '队员')
    end)
    hooksecurefunc(CompactRaidFrameManagerDisplayFrame.RestrictPingsButton, 'UpdateLabel', function(self)
        set(self.Text, IsInRaid() and '只限助手发送信号' or '只限领袖发送信号')
    end)
    set(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButtonText, '将所有人提升为助理')

    set(CompactRaidFrameManagerDisplayFrameEditMode, '编辑')
    set(CompactRaidFrameManagerDisplayFrameConvertToRaid, '转团')
    hooksecurefunc('CompactRaidFrameManager_SetSetting', function(settingName, value)
        if ( settingName == "IsShown" ) then
            if EditModeManagerFrame:AreRaidFramesForcedShown() or (value and value ~= "0") then
                set(CompactRaidFrameManagerDisplayFrameHiddenModeToggle, '隐藏')
            else
                set(CompactRaidFrameManagerDisplayFrameHiddenModeToggle, '显示')
            end
        end
    end)

    reg(RolePollPopup, '选择你的职责', 1)
    set(RolePollPopupAcceptButtonText, '接受')

    --HelpTipTemplateMixin:ApplyText()
    hooksecurefunc(HelpTipTemplateMixin, 'ApplyText', function(frame)
        local text= e.strText[frame.info.text]
        if text then
            frame.info.text= text
            set(frame.Text, text)
        end
    end)

    hooksecurefunc('HelpPlate_Button_OnEnter', function(self)
        local text= e.strText[self.toolTipText]
        if text then
            self.toolTipText= text
            set(HelpPlateTooltip.Text, text)
        end
    end)


    --[[GossipFrameShared.lua
    hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, optionInfo)
        if optionInfo then
            local name= e.strText[optionInfo.name]
            if name then
                if (FlagsUtil.IsSet(optionInfo.flags, Enum.GossipOptionRecFlags.QuestLabelPrepend)) then
                    set(self, foramt('|cnPURE_BLUE_COLOR:（任务）|r%s', name))
                else
                    set(self, name)
                end
            end
        end
    end)
    local function UpdateTitleForQuest(self, info)--GossipSharedQuestButtonMixin:UpdateTitleForQuest 
        if info and info.title then
            local title= e.cn(info.title)
            if info.isIgnored then
                set(self, format('|cff000000%s（忽略）|r', title))
            elseif info.isTrivial then
                set(self, format('|cff000000%s （低等级）|r', title))
            else
                set(self, e.strText[titleText])
            end
        end
    end
    hooksecurefunc(GossipSharedAvailableQuestButtonMixin, 'Setup', function(self, questInfo)
        UpdateTitleForQuest(self, questInfo)
    end)
    hooksecurefunc(GossipSharedActiveQuestButtonMixin, 'Setup', function(self, questInfo)
        UpdateTitleForQuest(self, questInfo)
    end)]]

    --试衣间
    set(DressUpFrameTitleText, '试衣间')
    set(DressUpFrameOutfitDropDown.SaveButton, '保存')
    set(DressUpFrame.LinkButton, '外观方案链接')
    set(DressUpFrameResetButton, '重置')
    set(DressUpFrameCancelButton, '关闭')
    DressUpFrame.ToggleOutfitDetailsButton:HookScript('OnEnter', function()
        GameTooltip_SetTitle(GameTooltip, '外观列表')
		GameTooltip:Show()
    end)

    --local TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN_CHECKMARK = "|A:common-icon-checkmark:16:16:0:-1|a 你已经收藏过此外观了"
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'OnEnter', function(self)--DressUpFrames.lua
        if not self.transmogID or (self.item and not self.item:IsItemDataCached()) then
            return
        end
        local name= e.strText[self.name] or ' '
        if self.isHiddenVisual then
            GameTooltip_AddColoredLine(GameTooltip, name, NORMAL_FONT_COLOR)
        elseif not self.item then
            -- illusion
            GameTooltip_AddColoredLine(GameTooltip,name, NORMAL_FONT_COLOR)
            if self.slotState == 3 then
                GameTooltip_AddColoredLine(GameTooltip, '你尚未收藏过此外观', LIGHTBLUE_FONT_COLOR)
            else
                GameTooltip_AddColoredLine(GameTooltip, "|cnGREEN_FONT_COLOR:|A:common-icon-checkmark:16:16:0:-1|a 你已经收藏过此外观了", GREEN_FONT_COLOR)
            end
        elseif self.slotState == 1 then
            local hasData, canCollect = C_TransmogCollection.AccountCanCollectSource(self.transmogID)
            if not canCollect and (self.slotID == INVSLOT_MAINHAND or self.slotID == INVSLOT_OFFHAND) then
                local pairedTransmogID = C_TransmogCollection.GetPairedArtifactAppearance(self.transmogID)
                if pairedTransmogID then
                    hasData, canCollect = C_TransmogCollection.AccountCanCollectSource(pairedTransmogID)
                    if not hasData then
                        return
                    end
                end
            end
            if canCollect then
                local nameColor = self.item:GetItemQualityColor().color
                GameTooltip_AddColoredLine(GameTooltip,name, nameColor)
                local slotName = TransmogUtil.GetSlotName(self.slotID)
                GameTooltip_AddColoredLine(GameTooltip, e.cn(_G[slotName]), HIGHLIGHT_FONT_COLOR)
                GameTooltip_AddErrorLine(GameTooltip, '你的角色无法使用此外观。')
            else
                local hideVendorPrice = true
                GameTooltip:SetHyperlink(self.item:GetItemLink(), nil, nil, hideVendorPrice)
                GameTooltip_AddErrorLine(GameTooltip, '该物品无法在幻化时使用，但可以视为装备穿戴。')
            end
        elseif self.slotState == 3 then
            if not C_TransmogCollection.PlayerKnowsSource(self.transmogID) then
                local nameColor = self.item:GetItemQualityColor().color
                GameTooltip_AddColoredLine(GameTooltip, name, nameColor)
                local slotName = TransmogUtil.GetSlotName(self.slotID)
                GameTooltip_AddColoredLine(GameTooltip, e.cn(_G[slotName]), HIGHLIGHT_FONT_COLOR)
                GameTooltip_AddColoredLine(GameTooltip, '|cnRED_FONT_COLOR:你尚未收藏过此外观', LIGHTBLUE_FONT_COLOR)
            end
        else
            local nameColor = self.item:GetItemQualityColor().color
            GameTooltip_AddColoredLine(GameTooltip, name, nameColor)
            local slotName = TransmogUtil.GetSlotName(self.slotID)
            GameTooltip_AddColoredLine(GameTooltip, e.cn(_G[slotName]), HIGHLIGHT_FONT_COLOR)
            GameTooltip_AddColoredLine(GameTooltip, '|cnGREEN_FONT_COLOR:|A:common-icon-checkmark:16:16:0:-1|a 你已经收藏过此外观了', GREEN_FONT_COLOR)
        end
        GameTooltip:Show()
    end)

    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetAppearance', function(self, slotID, transmogID, isSecondary)
        local itemID = C_TransmogCollection.GetSourceItemID(transmogID)
        if not itemID and not isSecondary then
            local name= _G[TransmogUtil.GetSlotName(slotID)]
            local slotName = e.strText[name]
            if slotName then
                set(self.Name, format('(%s)', slotName))
            end
        end
    end)
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'RefreshAppearanceTooltip', function(self)
        GameTooltip_AddColoredLine(GameTooltip, '|cnRED_FONT_COLOR:你尚未收藏过此外观', LIGHTBLUE_FONT_COLOR)
        GameTooltip:Show()
    end)
    hooksecurefunc(WardrobeOutfitFrame, 'Update', function(self)
        if self.Buttons then
            local btn=self.Buttons[#self.Buttons]
            if btn then
                set(btn, GREEN_FONT_COLOR_CODE..'新外观方案'..FONT_COLOR_CODE_CLOSE)
            end
        end
    end)


    --PlayerCastingBarFrame
    hooksecurefunc(PlayerCastingBarFrame, 'HandleInterruptOrSpellFailed', function(self, _, event, ...)
        if self.barType == "interrupted" and self.Text then
            set(self.Text, event == "UNIT_SPELLCAST_FAILED" and '失败' or '被打断')
        end
    end)
    PlayerCastingBarFrame:HookScript('OnEvent', function(self, event)
        if event== "UNIT_SPELLCAST_START" or event== "UNIT_SPELLCAST_CHANNEL_START" or event== "UNIT_SPELLCAST_EMPOWER_START" then
            set(self.Text)
        end
    end)


    C_Timer.After(2, function()
        model(CharacterModelScene)
        if WardrobeTransmogFrame then
            model(WardrobeTransmogFrame.ModelScene)
        end
        model(PetStableModelScene)


        AddonCompartmentFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip_SetTitle(GameTooltip, '插件')
            GameTooltip:Show()
        end)

        --UIDropDownMenu.lua
        local function GetChild(frame, name, key)
            if (frame[key]) then
                return frame[key]
            elseif name then
                return _G[name..key]
            end

            return nil
        end
        local function get_menu_text(text)--( ) . % + - * ? [ ^ $
            if text then
                local col, text2= text:match('(|cff......)(.-)|r')
                local str1, str2= text:match('(.-) %((.-)%)')
                local str3= text:match('%((.+)%)')
                text= e.strText[text2 or text]
                if text then
                    return col and col..text..'|r' or text
                elseif str1 and str2 then
                    local name, col2 =str1:match('(.-)(|cff......)')
                    str1= name or str1
                    str2= str2:gsub('|r', '')
                    if e.strText[str1] or e.strText[str2] then
                        return (e.strText[str1] or str1)..(col2 or '')..' ('..(e.strText[str2] or str2)..')'..(col2 and '|r' or '')
                    end
                elseif e.strText[str3] then
                    return '('..e.strText[str3]..')'
                end
            end
        end
        hooksecurefunc('UIDropDownMenu_SetText', function(frame, name)
            if frame then
                local text
                if type(name)=='string' then
                    text= name
                elseif type(text)=='function' then
                    text= name()
                end
                text= get_menu_text(text)
                if text then
                    set(GetChild(frame, frame:GetName(), "Text"), text)
                end
            end
        end)
        hooksecurefunc('UIDropDownMenu_AddButton', function(info, level)
            level = level or 1
            local listFrame = _G["DropDownList"..level]
            listFrame = listFrame or _G["DropDownList"..level]
            local listFrameName = listFrame:GetName()
            local index = listFrame and (listFrame.numButtons) or 1
            local button = _G[listFrameName.."Button"..index]
            local text= get_menu_text(info.text)
            if text then
                set(button, info.colorCode and info.colorCode..text.."|r" or text)
            end
        end)


        hooksecurefunc('UIMenu_AddButton', function(self, text)--UIMenu.lua
            if ( self.numButtons > UIMENU_NUMBUTTONS ) then
                return
            end
            local button = _G[self:GetName().."Button"..self.numButtons]
            if ( button and text ) then
                set(button, e.strText[text])
		        set(_G[button:GetName().."ShortcutText"])
            end
        end)

        for i=1, 12 do
            setLabel(_G['ChatMenuButton'..i])
        end

        if _G['VoiceMacroMenu'] then
            local w= _G['VoiceMacroMenu']:GetWidth()
            _G['VoiceMacroMenu']:SetWidth(w*1.6)
            for i=1, 23 do
                local btn= _G['VoiceMacroMenuButton'..i]
                local name= btn and btn:GetText()
                local text= name and e.strText[name]
                if text then
                    set(btn, text)
                    local shortcutString = _G[btn:GetName().."ShortcutText"]
                    if shortcutString then
                        set(shortcutString, name)
                        shortcutString:Show()
                    end
                    btn:SetWidth(w*1.4)
                end
            end
        end
        if _G['EmoteMenu'] then
            local w= _G['EmoteMenu']:GetWidth()
            _G['EmoteMenu']:SetWidth(w*1.6)
            for i=1, 21 do
                local btn= _G['EmoteMenuButton'..i]
                local name= btn and btn:GetText()
                local text= name and e.strText[name]
                if text then
                    set(btn, text)
                    local shortcutString = _G[btn:GetName().."ShortcutText"]
                    if shortcutString then
                        set(shortcutString, name)
                        shortcutString:Show()
                    end
                    btn:SetWidth(w*1.4)
                end
            end
        end
    end)

    --EventToastManager.lua EventToastManagerFrame
    --没有全部测试
    hooksecurefunc(EventToastScenarioBaseToastMixin, 'Setup', function(self, toastInfo)
        set(self.Title, e.strText[toastInfo.title])
        set(self.SubTitle, e.strText[toastInfo.subtitle])
        set(self.Description, e.strText[toastInfo.instructionText])
    end)
    hooksecurefunc(EventToastScenarioExpandToastMixin, 'Setup', function(self, toastInfo)
        set(self.Description, '左键点击以查看详情')
    end)
    hooksecurefunc(EventToastScenarioExpandToastMixin, 'OnAnimFinished', function(self)
        set(self.Description, '左键点击以查看详情')
    end)
    hooksecurefunc(EventToastScenarioExpandToastMixin, 'OnClick', function(self, button, ...)
        if (button == "LeftButton") then
            if(not self.expanded) then
                set(self.Description, '左键点击以查看详情')
            else
                set(self.Description, '左键点击以隐藏详情')
            end
        end
    end)
    hooksecurefunc(EventToastWeeklyRewardToastMixin, 'Setup', function(self, toastInfo)
        set(self.Contents.Title, e.strText[toastInfo.title])
	    set(self.Contents.SubTitle, e.strText[toastInfo.subtitle])
    end)
    hooksecurefunc(EventToastWithIconBaseMixin, 'Setup', function(self, toastInfo)
        set(self.Title, e.strText[toastInfo.title])
        set(self.SubTitle, e.strText[toastInfo.subtitle])
        if not self.isSideDisplayToast then
            set(self.InstructionalText, e.strText[toastInfo.instructionText])
        end
    end)
    hooksecurefunc(EventToastWithIconWithRarityMixin, 'Setup', function(self, toastInfo)
        if (toastInfo.qualityString) then
            set(self.RarityValue, e.strText[toastInfo.qualityString])
        end
    end)
    hooksecurefunc(EventToastChallengeModeToastMixin, 'Setup', function(self, toastInfo)
        set(self.Title, e.strText[toastInfo.title])
        if (toastInfo.time) then
            if e.strText[toastInfo.subtitle] then
                set(self.SubTitle, format(e.strText[toastInfo.subtitle], SecondsToClock(toastInfo.time/1000, true)))
            end
        else
            set(self.SubTitle, e.strText[toastInfo.subtitle])
        end
    end)
    hooksecurefunc(EventToastManagerNormalTitleAndSubtitleMixin, 'Setup', function(self, toastInfo)
        set(self.Title, e.strText[toastInfo.title])
        set(self.SubTitle, e.strText[toastInfo.subtitle])
    end)
    hooksecurefunc(EventToastManagerNormalSingleLineMixin, 'Setup', function(self, toastInfo)
        set(self.Title, e.strText[toastInfo.title])
    end)
    hooksecurefunc(EventToastManagerNormalBlockTextMixin, 'Setup', function(self, toastInfo)
	    set(self.Title, e.strText[toastInfo.title])
    end)


    --ZoneText.lua
    hooksecurefunc('ZoneText_OnEvent', function(self, event, ...)
        local showZoneText = false
        local zoneText = GetZoneText()
        if ( (zoneText ~= self.zoneText) or (event == "ZONE_CHANGED_NEW_AREA") ) then
            set(ZoneTextString, e.strText[zoneText])
            showZoneText = true
        end
        local subzoneText = GetSubZoneText()
        if ( subzoneText == "" and not showZoneText) then
            subzoneText = zoneText
        end
        if ( subzoneText == zoneText ) then
            if ( not self:IsShown() ) then
                set(SubZoneTextString, e.strText[subzoneText])
            end
        else
            set(SubZoneTextString, e.strText[subzoneText])
        end
    end)
    set(SubZoneTextString, e.strText[GetSubZoneText()])
    hooksecurefunc('SetZoneText', function()
        local pvpType, isSubZonePvP, factionName = C_PvP.GetZonePVPInfo()
        local pvpTextString = PVPInfoTextString
        if ( isSubZonePvP ) then
            pvpTextString = PVPArenaTextString
        end
        if ( pvpType == "sanctuary" ) then
            set(pvpTextString, '（安全区域）')
        elseif ( pvpType == "arena" ) then
            set(pvpTextString, '（PvP区域）')
        elseif ( pvpType == "friendly" or  pvpType == "hostile" ) then
            if (factionName and factionName ~= "") then
                set(pvpTextString, format('（%s领地）', e.cn(factionName)))
            end
        elseif ( pvpType == "contested" ) then
            set(pvpTextString, '（争夺中的领土）')
        elseif ( pvpType == "combat" ) then
            set(PVPArenaTextString, '（战斗区域）')
        end
    end)
    hooksecurefunc('AutoFollowStatus_OnEvent', function(self, event, ...)
        if ( event == "AUTOFOLLOW_BEGIN" ) then
            set(AutoFollowStatusText, format('正在跟随%s', self.unit))
        end
        if ( event == "AUTOFOLLOW_END" ) then
            set(AutoFollowStatusText, format('已停止跟随%s。', self.unit))
        end
	end)

    --Constants.lua
    -- LFG
    for index, en in pairs(LFG_CATEGORY_NAMES) do
        local cn= e.strText[en]
        if cn then
            LFG_CATEGORY_NAMES[index]= cn
        end
    end
    -- PVP
    for index, en in pairs(CONQUEST_SIZE_STRINGS) do
        local cn= e.strText[en]
        if cn then
            CONQUEST_SIZE_STRINGS[index]= cn
        end
    end
    for index, en in pairs(CONQUEST_TYPE_STRINGS) do
        local cn= e.strText[en]
        if cn then
            CONQUEST_TYPE_STRINGS[index]= cn
        end
    end


    --[[if e.Player.class=='HUNTER' and StableFrame then--10.2.7
        StableFrame.StableTogglePetButton.disabledTooltip=
        StableFrame.StableTogglePetButton:SetText()
    end]]
end










































































local function Init_Loaded(arg1)
    if arg1=='Blizzard_AuctionHouseUI' then
        hooksecurefunc(AuctionHouseFrame, 'UpdateTitle', function(self)
            local tab = PanelTemplates_GetSelectedTab(self)
            local title = '浏览拍卖'
            if tab == 2 then
                title = '发布拍卖'
            elseif tab == 3 then
                title = '拍卖'
            end
            self:SetTitle(title)
        end)
        hooksecurefunc('AuctionHouseFilterButton_SetUp', function(btn, info)
            set(btn, e.strText[info.name])
        end)

        set(AuctionHouseFrameBuyTab.Text, '购买')
            set(AuctionHouseFrame.SearchBar.FilterButton, '过滤器')
            hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList, 'SetState', function(self, state)
                if state == 1 then
                    local searchResultsText = self.searchStartedFunc and select(2, self.searchStartedFunc())
                    if searchResultsText== AUCTION_HOUSE_BROWSE_FAVORITES_TIP then
                        set(self.ResultsText, '小窍门：右键点击物品可以设置偏好。偏好的物品会在你打开拍卖行时立即出现。')
                    end
                elseif state == 2 then
                    set(self.ResultsText, '未发现物品')
                end
            end)

        set(AuctionHouseFrameSellTab.Text, '出售')
        set(AuctionHouseFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrame.CancelAuctionButton, '取消拍卖')
        set(AuctionHouseFrameAuctionsFrameAuctionsTab.Text, '拍卖')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        set(AuctionHouseFrameAuctionsFrameBidsTab.Text, '竞标')
        hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList, 'SetDataProvider', function(self)
            if self.ResultsText and self.ResultsText:IsShown() then
                set(self.ResultsText, '小窍门：右键点击物品可以设置偏好。偏好的物品会在你打开拍卖行时立即出现。')
            end
        end)

        set(AuctionHouseFrame.SearchBar.SearchButton, '搜索')

        set(AuctionHouseFrame.ItemSellFrame.CreateAuctionLabel, '开始拍卖')
        set(AuctionHouseFrame.ItemSellFrame.PostButton,'创建拍卖')
        set(AuctionHouseFrame.ItemSellFrame.QuantityInput.Label, '数量')
        set(AuctionHouseFrame.ItemSellFrame.DurationDropDown.Label, '持续时间')
        set(AuctionHouseFrame.ItemSellFrame.Deposit.Label, '保证金')
        set(AuctionHouseFrame.ItemSellFrame.TotalPrice.Label, '总价')
        set(AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, '最大数量')
        set(AuctionHouseFrame.ItemSellFrame.PriceInput.PerItemPostfix, '每个物品')
        set(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput.Label, '竞标价格')

        --Blizzard_AuctionHouseUI
        hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'SetSecondaryPriceInputEnabled', function(self, enabled)
            self.PriceInput:SetLabel('一口价')--AUCTION_HOUSE_BUYOUT_LABEL)
            if enabled then
                self.PriceInput:SetSubtext('|cff777777(可选)|r')--AUCTION_HOUSE_BUYOUT_OPTIONAL_LABEL
            end
        end)

        set(AuctionHouseFrame.CommoditiesSellFrame.CreateAuctionLabel, '开始拍卖')
        set(AuctionHouseFrame.CommoditiesSellFrame.PostButton,'创建拍卖')
        set(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.Label, '数量')
        set(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.Label, '一口价')
        set(AuctionHouseFrame.CommoditiesSellFrame.DurationDropDown.Label, '持续时间')
        set(AuctionHouseFrame.CommoditiesSellFrame.Deposit.Label, '保证金')
        set(AuctionHouseFrame.CommoditiesSellFrame.TotalPrice.Label, '总价')
        set(AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, '最大数量')
        set(AuctionHouseFrame.CommoditiesSellFrame.PriceInput.PerItemPostfix, '每个物品')
        set(AuctionHouseFrame.ItemSellFrame.BuyoutModeCheckButton.Text, '一口价')
        AuctionHouseFrame.ItemSellFrame.BuyoutModeCheckButton:HookScript('OnEnter', function()
            GameTooltip_AddNormalLine(GameTooltip, '取消勾选此项以允许对你的拍卖品进行竞拍。', true)
            GameTooltip:Show()
        end)

        --刷新，列表
        set(AuctionHouseFrame.CommoditiesBuyFrame.BackButton, '返回')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.BuyButton, '一口价')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.Label, '数量')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.UnitPrice.Label, '单价')
        set(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.TotalPrice.Label, '总价')

        set(AuctionHouseFrame.ItemBuyFrame.BackButton, '返回')
        set(AuctionHouseFrame.ItemBuyFrame.BidFrame.BidButton, '竞标')
        set(AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton, '一口价')

        AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '刷新')
            GameTooltip:Show()
        end)
        AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '刷新')
            GameTooltip:Show()
        end)


        --Blizzard_AuctionHouseSharedTemplates.lua
        hooksecurefunc(AuctionHouseFrame.ItemSellList.RefreshFrame, 'SetQuantity', function(self, totalQuantity)
            if totalQuantity ~= 0 then
                set(self.TotalQuantity, format('可购买数量：|cnGREEN_FONT_COLOR:%s|r', e.MK(totalQuantity, 0)))
            end
        end)
        hooksecurefunc(AuctionHouseFrame.CommoditiesSellList.RefreshFrame, 'SetQuantity', function(self, totalQuantity)
            if totalQuantity ~= 0 then
                set(self.TotalQuantity, format('可购买数量：|cnGREEN_FONT_COLOR:%s|r', e.MK(totalQuantity, 0)))
            end
        end)
        hooksecurefunc(AuctionHouseFrame.ItemBuyFrame.BidFrame, 'SetPrice', function(self, minBid, isOwnerItem, isPlayerHighBid)
            if not (isPlayerHighBid or minBid == 0) then
                if minBid > GetMoney() then
                    self.BidButton:SetDisableTooltip('你的钱不够')
                elseif isOwnerItem then
                    self.BidButton:SetDisableTooltip('你不能购买自己的拍卖品')
                end
            end
        end)

        --Blizzard_AuctionHouseSellFrame.lua
        hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame, 'UpdatePostButtonState', function(self)
            local canPostItem, reasonTooltip = self:CanPostItem()
            if not canPostItem and reasonTooltip then
                if reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_ITEM then
                    self.PostButton:SetTooltip('没有选择物品')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_DEPOSIT then
                    self.PostButton:SetTooltip('你没有足够的钱来支付保证金')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_QUANTITY then
                    self.PostButton:SetTooltip('数量必须大于0')
                elseif reasonTooltip== ERR_GENERIC_THROTTLE then
                    self.PostButton:SetTooltip('你太快了')
                end
            end
        end)
        hooksecurefunc(AuctionHouseFrame.ItemSellFrame, 'UpdatePostButtonState', function(self)
            local canPostItem, reasonTooltip = self:CanPostItem()
            if not canPostItem and reasonTooltip then
                if reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_ITEM then
                    self.PostButton:SetTooltip('没有选择物品')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_DEPOSIT then
                    self.PostButton:SetTooltip('你没有足够的钱来支付保证金')
                elseif reasonTooltip== AUCTION_HOUSE_SELL_FRAME_ERROR_QUANTITY then
                    self.PostButton:SetTooltip('数量必须大于0')
                elseif reasonTooltip== ERR_GENERIC_THROTTLE then
                    self.PostButton:SetTooltip('你太快了')
                end
            end
        end)


        set(AuctionHouseFrame.WoWTokenResults.Buyout, '一口价')
        set(AuctionHouseFrame.WoWTokenResults.BuyoutLabel, '一口价')
        AuctionHouseFrame.WoWTokenResults.HelpButton:HookScript('OnEnter', function()
            GameTooltip:AddLine('关于魔兽世界时光徽章')
            GameTooltip:Show()
        end)

        --Blizzard_AuctionHouseFrame.lua
        dia("BUYOUT_AUCTION", {text = '以一口价购买：', button1 = '接受', button2 = '取消',})
        dia("BID_AUCTION", {text = '出价为：', button1 = '接受', button2 = '取消',})

        dia("PURCHASE_AUCTION_UNIQUE", {text = '出价为：', button1 = '确定', button2 = '取消',})
        hookDia("PURCHASE_AUCTION_UNIQUE", 'OnShow', function(self, data)
            self.text:SetFormattedText('|cffffd200此物品属于“%s”。|n|n你同时只能装备一件拥有此标签的装备。|r', data.categoryName)
        end)

        dia("CANCEL_AUCTION", {text = '取消拍卖将使你失去保证金。', button1 = '接受', button2 = '取消'})
        hookDia("CANCEL_AUCTION", 'OnShow', function(self)
            local cancelCost = C_AuctionHouse.GetCancelCost(self.data.auctionID)
            if cancelCost > 0 then
                set(self.text, e.strText['取消拍卖会没收你所有的保证金和：'])
            else
                set(self.text, e.strText['取消拍卖将使你失去保证金。'])
            end
        end)

        dia("AUCTION_HOUSE_POST_WARNING", {text = NORMAL_FONT_COLOR:WrapTextInColorCode('拍卖行即将在已经预定的每周维护时间段中进行重大更新。|n|n如果你的拍卖品到时还未售出，你的物品会被提前退回，而且你会失去你的保证金。'), button1 = '接受', button2 = '取消',})
        dia("AUCTION_HOUSE_POST_ERROR", {text =  NORMAL_FONT_COLOR:WrapTextInColorCode('目前无法拍卖物品。|n|n拍卖行即将进行重大更新。'), button1 = '确定'})

        --Blizzard_AuctionHouseWoWTokenFrame.lua
        dia("TOKEN_NONE_FOR_SALE", {text = '目前没有可售的魔兽世界时光徽章。请稍后再来查看。', button1 = '确定'})
        dia("TOKEN_AUCTIONABLE_TOKEN_OWNED", {text = '你必须先将从商城购得的魔兽世界时光徽章售出后才能从拍卖行中购买新的徽章。', button1 = '确定'})

        set(AuctionHouseFrame.BuyDialog.BuyNowButton, '立即购买')
        set(AuctionHouseFrame.BuyDialog.CancelButton, '取消')


















    elseif arg1=='Blizzard_ClassTalentUI' then
         for _, tabID in pairs(ClassTalentFrame:GetTabSet() or {}) do
            local btn= ClassTalentFrame:GetTabButton(tabID)
            if tabID==1 then
                set(btn, '专精')
            elseif tabID==2 then
                set(btn, '天赋')
            end
        end

        --Blizzard_ClassTalentTalentsTab.lua
        set(ClassTalentFrame.TalentsTab.ApplyButton, '应用改动')
        set(ClassTalentFrame.TalentsTab.SearchBox.Instructions, '搜索')
        hooksecurefunc(ClassTalentFrame.TalentsTab.ApplyButton, 'SetDisabledTooltip', function(self, canChangeError)
            if canChangeError then
                if canChangeError ==  TALENT_FRAME_REFUND_INVALID_ERROR  then
                    self.disabledTooltip = '你必须修复所有错误。忘却天赋来释放点数，并在其他地方花费这些点数来构建可用的配置。'
                elseif canChangeError== ERR_TALENT_FAILED_UNSPENT_TALENT_POINTS then
                    self.disabledTooltip= '你必须花费所有可用的天赋点才能应用改动'
                end
            end
        end)
        ClassTalentFrame.TalentsTab.ApplyButton:HookScript('OnEnter', function()
        end)
        hooksecurefunc(ClassTalentFrame.TalentsTab.ClassCurrencyDisplay, 'SetPointTypeText', function(self, text)
            set(self.CurrencyLabel, format('%s 可用点数', e.strText[ClassTalentFrame.TalentsTab:GetClassName()] or text))
        end)
        hooksecurefunc(ClassTalentFrame.TalentsTab.SpecCurrencyDisplay, 'SetPointTypeText', function(self, text)
            set(self.CurrencyLabel, format('%s 可用点数', e.strText[ClassTalentFrame.TalentsTab:GetSpecName()] or text))
        end)
        ClassTalentFrame.TalentsTab.InspectCopyButton:SetTextToFit('复制配置代码')

        if ClassTalentFrame.SpecTab.numSpecs and ClassTalentFrame.SpecTab.numSpecs>0 and ClassTalentFrame.SpecTab.SpecContentFramePool then
            local sex= UnitSex("player")
            local SPEC_STAT_STRINGS = {
                [LE_UNIT_STAT_STRENGTH] = '力量',
                [LE_UNIT_STAT_AGILITY] = '敏捷',
                [LE_UNIT_STAT_INTELLECT] = '智力',
            }
            for frame in pairs(ClassTalentFrame.SpecTab.SpecContentFramePool.activeObjects or {}) do
                set(frame.ActivatedText, '激活')
                set(frame.ActivateButton, '激活')
                if frame.RoleName then
                    set(frame.RoleName, e.strText[frame.RoleName:GetText()])
                end
                set(frame.SampleAbilityText, '典型技能')
                if frame.specIndex then
                    local specID, name, description, _, _, primaryStat = GetSpecializationInfo(frame.specIndex, false, false, nil, sex)
                    if specID and primaryStat and primaryStat ~= 0 then
                        set(frame.Description, (e.cn(description) or '').."|n"..format('主要属性：%s', SPEC_STAT_STRINGS[primaryStat]))
                    end
                    if frame.SpecName then
                        set(frame.SpecName, e.strText[name])
                    end
                end

            end
        end

        ClassTalentFrame.TalentsTab.UndoButton.tooltipText= '取消待定改动'
        --Blizzard_WarmodeButtonTemplate.lua
        ClassTalentFrame.TalentsTab.WarmodeButton:HookScript('OnEnter', function(self)
            --GameTooltip:SetOwner(self, "ANCHOR_LEFT", 14, 0)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('战争模式')
            --GameTooltip_SetTitle(GameTooltip, '战争模式')
            if C_PvP.IsWarModeActive() or self:GetWarModeDesired() then
                GameTooltip_AddInstructionLine(GameTooltip, '|cnGREEN_FONT_COLOR:开启')
            end
            local wrap = true
            local warModeRewardBonus = C_PvP.GetWarModeRewardBonus()
            GameTooltip_AddNormalLine(GameTooltip, format('加入战争模式即可激活世界PvP，使任务的奖励和经验值提高%1$d%%，并可以在野外使用PvP天赋。', warModeRewardBonus), wrap)
            local canToggleWarmode = C_PvP.CanToggleWarMode(true)
            local canToggleWarmodeOFF = C_PvP.CanToggleWarMode(false)

            if(not canToggleWarmode or not canToggleWarmodeOFF) then
                if (not C_PvP.ArePvpTalentsUnlocked()) then
                    GameTooltip_AddErrorLine(GameTooltip, format('|cnRED_FONT_COLOR:在%d级解锁', C_PvP.GetPvpTalentsUnlockedLevel()), wrap)
                else
                    local warmodeErrorText
                    if(not C_PvP.CanToggleWarModeInArea()) then
                        if(self:GetWarModeDesired()) then
                            if(not canToggleWarmodeOFF and not IsResting()) then
                                warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and '战争模式可以在任何休息区域关闭，但只能在奥格瑞玛或瓦德拉肯开启。' or '战争模式可以在任何休息区域关闭，但只能在暴风城或瓦德拉肯开启。'
                            end
                        else
                            if(not canToggleWarmode) then
                                warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and '只能在奥格瑞玛或瓦德拉肯进入战争模式。' or '只能在暴风城或瓦德拉肯进入战争模式。'
                            end
                        end
                    end
                    if(warmodeErrorText) then
                        GameTooltip_AddErrorLine(GameTooltip, '|cnRED_FONT_COLOR:'..warmodeErrorText, wrap)
                    elseif (UnitAffectingCombat("player")) then
                        GameTooltip_AddErrorLine(GameTooltip, '|cnRED_FONT_COLOR:你正处于交战状态', wrap)
                    end
                end
            end
            GameTooltip:Show()
        end)

        dia("CONFIRM_LEARN_SPEC", {button1 = '是', button2 = '否',})
        hookDia("CONFIRM_LEARN_SPEC", 'OnShow', function(self)
            if (self.data.previewSpecCost and self.data.previewSpecCost > 0) then
                self.text:SetFormattedText('激活此专精需要花费%s。确定要学习此专精吗？', GetMoneyString(self.data.previewSpecCost))
            else
                self.text:SetText('你确定要学习这种天赋专精吗？')
            end
        end)

        dia("CONFIRM_EXIT_WITH_UNSPENT_TALENT_POINTS", {text = '你还有未分配的天赋。你确定要关闭这个窗口？', button1 = '是', button2 = '否'})

        hooksecurefunc(ClassTalentFrame, 'UpdateFrameTitle', function(self)
            local tabID = self:GetTab()
            if self:IsInspecting() then
                local inspectUnit = self:GetInspectUnit()
                if inspectUnit then
                    self:SetTitle(format('天赋 - %s', UnitName(self:GetInspectUnit())))
                else
                    self:SetTitle(format('天赋链接 (%s %s)', self:GetSpecName(), self:GetClassName()))
                end
            elseif tabID == self.specTabID then
                self:SetTitle('专精')
            else -- tabID == self.talentTabID
                self:SetTitle('天赋')
            end
        end)

        --Blizzard_ClassTalentLoadoutEditDialog.lua
        dia("LOADOUT_CONFIRM_DELETE_DIALOG", {text = '你确定要删除配置%s吗？', button1 = '删除', button2 = '取消'})
        dia("LOADOUT_CONFIRM_SHARED_ACTION_BARS", {text = '此配置的动作条会被你共享的动作条替换。', button1 = '接受', button2 = '取消'})
        ClassTalentLoadoutEditDialog.UsesSharedActionBars:HookScript('OnEnter', function()
            GameTooltip:AddLine(' ')
            GameTooltip_AddNormalLine(GameTooltip, '默认条件下，每个配置都有自己保存的一套动作条。\n\n所有开启此选项的配置都会共享同样的动作条。')
            GameTooltip:Show()
        end)

        --Blizzard_ClassTalentLoadoutImportDialog.xml
        set(ClassTalentLoadoutImportDialog.Title, '导入配置')
        set(ClassTalentLoadoutImportDialog.ImportControl.Label, '导入文本')
        set(ClassTalentLoadoutImportDialog.ImportControl.InputContainer.EditBox.Instructions, '在此粘贴配置代码')
        set(ClassTalentLoadoutImportDialog.NameControl.Label, '新配置名称')
        set(ClassTalentLoadoutImportDialog.AcceptButton, '导入')
        set(ClassTalentLoadoutImportDialog.CancelButton, '取消')
        ClassTalentLoadoutImportDialog.AcceptButton.disabledTooltip = '输入可用的配置代码'

        --Blizzard_ClassTalentLoadoutEditDialog.xml
        set(ClassTalentLoadoutEditDialog.Title, '配置设定')
        set(ClassTalentLoadoutEditDialog.NameControl.Label, '名字')
        set(ClassTalentLoadoutEditDialog.UsesSharedActionBars.Label, '使用共享的动作条')
        set(ClassTalentLoadoutEditDialog.AcceptButton, '接受')
        set(ClassTalentLoadoutEditDialog.DeleteButton, '删除')
        set(ClassTalentLoadoutEditDialog.CancelButton, '取消')

        --Blizzard_ClassTalentLoadoutCreateDialog.xml
        set(ClassTalentLoadoutCreateDialog.Title, '新配置')
        set(ClassTalentLoadoutCreateDialog.NameControl.Label, '名字')
        set(ClassTalentLoadoutCreateDialog.AcceptButton, '保存')
        set(ClassTalentLoadoutCreateDialog.CancelButton, '取消')






















    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then
        hooksecurefunc(ProfessionsCustomerOrdersCategoryButtonMixin, 'Init', function(self, categoryInfo, _, isRecraftCategory)
            if isRecraftCategory then
                set(self, '开始再造订单')
            elseif categoryInfo and categoryInfo.categoryName and e.strText[categoryInfo.categoryName] then
                set(self, e.strText[categoryInfo.categoryName])
            end
        end)
        set(ProfessionsCustomerOrdersFrameBrowseTab, '发布订单')
        set(ProfessionsCustomerOrdersFrameOrdersTab, '我的订单')
        set(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.FilterButton, '过滤器')

        ProfessionsCustomerOrdersFrame.BrowseOrders:HookScript('OnEvent', function (self, event)
            if event == "CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED" and not C_CraftingOrders.HasFavoriteCustomerOptions() then
                set(self.RecipeList.ResultsText, '小窍门：右键点击配方可以设置偏好。偏好的配方会在你打开商盟时立即出现。')
            end
        end)
        hooksecurefunc(ProfessionsCustomerOrdersFrame.BrowseOrders, 'StartSearch', function (self)
            if self.RecipeList.ResultsText:IsShown() then
                self.RecipeList.ResultsText:SetText('未找到配方')
            end
        end)
        set(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchButton, '搜索')
        ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.FavoritesSearchButton:HookScript("OnEnter", function(frame)
            GameTooltip:SetText('|cffffffff收藏')
            if not C_CraftingOrders.HasFavoriteCustomerOptions() then
                GameTooltip_AddNormalLine(GameTooltip, '你的偏好列表是空的。右键点击订单列表的一个物品可以将其添加到偏好中。')
            end
            GameTooltip:Show()
         end)






        set(ProfessionsCustomerOrdersFrame.Form.BackButton, '返回' )
        set(ProfessionsCustomerOrdersFrame.Form.MinimumQuality.Text, '最低品质：')
        set(ProfessionsCustomerOrdersFrame.Form.ReagentContainer.RecraftInfoText, '再造使你可以改变某些制造装备的附加材料和品质。')
        set(ProfessionsCustomerOrdersFrame.Form.AllocateBestQualityCheckBox.Text, '使用最高品质材料')

        set(ProfessionsCustomerOrdersFrame.Form.OrderRecipientDisplay.Crafter, '制作者：')
        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'SetupDurationDropDown', function(self)
            self.PaymentContainer.Duration:SetText('持续时间')
        end)

        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.Tip, '佣金')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.NoteEditBox.TitleBox.Title, '给制作者的信息：')
        ProfessionsCustomerOrdersFrame.Form.PaymentContainer.NoteEditBox.ScrollingEditBox.defaultText= '在此输入消息'
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.TimeRemaining, '过期时间')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.PostingFee, '发布费')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.TotalPrice, '总价')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.ListOrderButton, '发布订单')
        set(ProfessionsCustomerOrdersFrame.Form.PaymentContainer.CancelOrderButton, '取消订单')

        ProfessionsCustomerOrdersFrame.Form.FavoriteButton:HookScript('OnEnter', function (self)
            local isFavorite = self:GetChecked()
            if not isFavorite and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES then
                GameTooltip_AddErrorLine(GameTooltip, '你的偏好列表已满。取消偏好一个配方后才能添加此配方。')
            else
                GameTooltip_AddHighlightLine(GameTooltip, isFavorite and '从偏好中移除' or '设置为偏好')
            end
            GameTooltip:Show()
        end)
        ProfessionsCustomerOrdersFrame.Form.RecraftSlot.InputSlot:HookScript('OnEnter', function()
            local self= ProfessionsCustomerOrdersFrame.Form
            local itemGUID = ProfessionsCustomerOrdersFrame.Form.transaction and self.transaction:GetRecraftAllocation()
            if itemGUID then
                if not self.committed then
                    GameTooltip_AddInstructionLine(GameTooltip, '|cnDISABLED_FONT_COLOR:左键点击替换此装备|r')
                    GameTooltip:Show()
                end
            elseif not self.order.recraftItemHyperlink then
                GameTooltip_AddInstructionLine(GameTooltip, '左键点击选择一件可用的装备来再造')
                GameTooltip:Show()
            end
        end)


        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'UpdateListOrderButton', function(self)
            if self.committed or self.pendingOrderPlacement then
                return
            end
            local errorText
            if self.order.isRecraft and not self.order.skillLineAbilityID then
                errorText = '你必须选择一个此订单要再造的物品'
            elseif self.order.isRecraft and self:GetPendingRecraftItemQuality() == #self.minQualityIDs and not self:AnyModifyingReagentsChanged() then
                errorText = '"你不能在不改变任何附加材料的情况下发布最高品质的物品的再造订单。'
            elseif not self:AreRequiredReagentsProvided() then
                errorText = '你没有发布此订单所需的材料。'
            elseif not self.transaction:HasMetPrerequisiteRequirements() then
                errorText = '一种或多种附加材料不满足必要条件。'
            elseif self.order.orderType == Enum.CraftingOrderType.Personal and self.OrderRecipientTarget:GetText() == "" then
                errorText = '你必须指定收件人才能发布个人订单。'
            elseif self.PaymentContainer.TipMoneyInputFrame:GetAmount() <= 0 then
                errorText = '你必须提供佣金。'
            elseif self.PaymentContainer.TotalPriceMoneyDisplayFrame:GetAmount() > GetMoney() then
                errorText = '金币不足，无法购买建筑。'
            end
            if errorText then
                local listOrderButton = self.PaymentContainer.ListOrderButton
                listOrderButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(listOrderButton, "ANCHOR_RIGHT")
                    GameTooltip_AddErrorLine(GameTooltip, errorText)
                    GameTooltip:Show()
                end)
            end
        end)

        ProfessionsCustomerOrdersFrame.Form:HookScript('OnEvent', function(self, event, ...)
            if event == "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE" or event == "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE" then
                local result = ...
                local success = (result == Enum.CraftingOrderResult.Ok)
                if not success then
                    local errorText
                    if event == "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE" then
                        if result == Enum.CraftingOrderResult.InvalidTarget then
                            errorText = '该玩家不存在。'
                        elseif result == Enum.CraftingOrderResult.TargetCannotCraft then
                            errorText = '该玩家没有所需的专业来制作此订单。'
                        elseif result == Enum.CraftingOrderResult.MaxOrdersReached then
                            errorText = '订单数量已达上限。'
                        else
                            errorText = '制造订单生成失败。请稍后重试。'
                        end
                    elseif event == "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE" then
                        errorText = (result == Enum.CraftingOrderResult.AlreadyClaimed) and '取消订单失败。订单被认领后就无法再取消。' or '取消订单失败。请稍后再试。'
                    end
                    UIErrorsFrame:AddExternalErrorMessage(errorText)
                end
            end
        end)

        ProfessionsCustomerOrdersFrame.Form.PaymentContainer.ViewListingsButton:SetScript("OnEnter", function(frame)
            GameTooltip_AddHighlightLine(GameTooltip, '查看类似的订单。')
            GameTooltip:Show()
         end)

        set(ProfessionsCustomerOrdersFrame.Form.TrackRecipeCheckBox.Text, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('追踪配方'))

        ProfessionsCustomerOrdersFrame.Form.AllocateBestQualityCheckBox:HookScript("OnEnter", function(button)
            local checked = button:GetChecked()
            if checked then
                GameTooltip_AddNormalLine(GameTooltip, '取消勾选后，总会使用可用的最低品质的材料。')
            else
                GameTooltip_AddNormalLine(GameTooltip, '勾选后，总会使用可用的最高品质的材料。')
            end
            GameTooltip:Show()
        end)


        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'InitSchematic', function(self)
            local professionName = C_TradeSkillUI.GetProfessionNameForSkillLineAbility(self.order.skillLineAbilityID)
            professionName= e.strText[professionName] or professionName
	        set(self.ProfessionText, format('%s 配方', professionName))
        end)

        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'Init', function(self, order)
            if not self.committed then
                set(self.ReagentContainer.Reagents.Label, '提供材料：')
                set(self.ReagentContainer.OptionalReagents.Label, '提供附加材料：')
            else
                if self.order.orderState ~= Enum.CraftingOrderState.Created then
                    local remainingTime = Professions.GetCraftingOrderRemainingTime(order.expirationTime)
                    local seconds = remainingTime >= 60 and remainingTime or 60 -- Never show < 1min
                    local timeRemainingText = Professions.OrderTimeLeftFormatter:Format(seconds)
                    timeRemainingText = format('%s （等待中）', timeRemainingText)
                    set(self.PaymentContainer.TimeRemainingDisplay.Text, timeRemainingText)
                end

                if not order.crafterName then
                    local crafterText
                    if self.order.orderState == Enum.CraftingOrderState.Created then
                        crafterText = '尚未被认领'
                    else
                        crafterText = '未领取'
                    end
                    set(self.OrderRecipientDisplay.CrafterValue, crafterText)
                end

                local orderTypeText
                if self.order.orderType == Enum.CraftingOrderType.Public then
                    orderTypeText = '公开订单'
                elseif self.order.orderType == Enum.CraftingOrderType.Guild then
                    orderTypeText = '公会订单'
                elseif self.order.orderType == Enum.CraftingOrderType.Personal then
                    orderTypeText = '个人订单'
                end
                set(self.OrderRecipientDisplay.PostedTo, orderTypeText)

                local orderStateText
                if self.order.orderState == Enum.CraftingOrderState.Created then
                    orderStateText = '未领取'
                elseif self.order.orderState == Enum.CraftingOrderState.Expired then
                    orderStateText = '订单过期'
                elseif self.order.orderState == Enum.CraftingOrderState.Canceled then
                    orderStateText = '订单取消'
                elseif self.order.orderState == Enum.CraftingOrderState.Rejected then
                    orderStateText = '订单被拒绝'
                elseif self.order.orderState == Enum.CraftingOrderState.Claimed then
                    orderStateText = '订单正在进行中'
                else
                    orderStateText = '|cnGREEN_FONT_COLOR:订单完成！|r'
                end
                set(self.OrderStateText, orderStateText)

                set(self.ReagentContainer.Reagents.Label, '提供的材料：')
                set(self.ReagentContainer.OptionalReagents.Label, '提供的附加材料：')
            end
        end)


        hooksecurefunc(ProfessionsCustomerOrdersFrame.Form, 'DisplayCurrentListings', function(self)
            local orders = C_CraftingOrders.GetCustomerOrders()
            if #orders == 0 then
                set(self.CurrentListings.OrderList.ResultsText, '没有发现订单')
            end
        end)
        ProfessionsCustomerOrdersFrame.Form.CurrentListings:SetTitle('当前列表')
        set(ProfessionsCustomerOrdersFrame.Form.CurrentListings.CloseButton, '关闭')


        hooksecurefunc(ProfessionsCustomerOrdersFrame, 'SelectMode', function(self, mode)
            if mode== ProfessionsCustomerOrdersMode.Browse then
	            self:SetTitle('发布制造订单')
            elseif mode== ProfessionsCustomerOrdersMode.Orders then
                self:SetTitle('我的订单')
            end
        end)
        set(ProfessionsCustomerOrdersFrame.MyOrdersPage.OrderList.ResultsText, '没有发现订单')



















    elseif arg1=='Blizzard_Professions' then--专业
        hooksecurefunc(ProfessionsFrame, 'SetTitle', function(self, skillLineName)
            if e.strText[skillLineName] then
                skillLineName= e.strText[skillLineName]
                if C_TradeSkillUI.IsTradeSkillGuild() then
                    self:SetTitleFormatted('公会%s"', skillLineName)
                else
                    local linked, linkedName = C_TradeSkillUI.IsTradeSkillLinked()
                    if linked and linkedName then
                        self:SetTitleFormatted("%s %s[%s]|r", TRADE_SKILL_TITLE:format(skillLineName), HIGHLIGHT_FONT_COLOR_CODE, linkedName)
                    else
                        self:SetTitleFormatted(TRADE_SKILL_TITLE, skillLineName)
                    end
                end
            elseif C_TradeSkillUI.IsTradeSkillGuild() then
                self:SetTitleFormatted('公会%s"', skillLineName)
            end
        end)

        hooksecurefunc(ProfessionsFrame, 'UpdateTabs', function(self)
            local recipesTab = self:GetTabButton(self.recipesTabID)
            set(recipesTab.Text, '配方', nil, true)

            recipesTab = self:GetTabButton(self.specializationsTabID)
            set(recipesTab.Text, '专精', nil, true)

            recipesTab = self:GetTabButton(self.craftingOrdersTabID )
            set(recipesTab.Text, '制造订单', nil, true)
        end)

        set(ProfessionsFrame.CraftingPage.RecipeList.SearchBox.Instructions, '搜索')
        set(ProfessionsFrame.CraftingPage.RecipeList.FilterButton, "过滤器")
        set(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.SearchBox.Instructions, '搜索')
        set(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton, '过滤器')

        --Blizzard_ProfessionsCrafting.lua
        set(ProfessionsFrame.CraftingPage.ViewGuildCraftersButton, '查看工匠')

        local FailValidationReason = EnumUtil.MakeEnum("Cooldown", "InsufficientReagents", "PrerequisiteReagents", "Disabled", "Requirement", "LockedReagentSlot", "RecraftOptionalReagentLimit")
        local FailValidationTooltips = {
            [FailValidationReason.Cooldown] = '配方冷却中。',
            [FailValidationReason.InsufficientReagents] = '你的材料不足。',
            [FailValidationReason.PrerequisiteReagents] = '一种或多种附加材料不满足必要条件。',
            [FailValidationReason.Requirement] = '你不满足一个或更多的条件，不能制作此配方。',
            [FailValidationReason.LockedReagentSlot] = '你尚未解锁必需的附加材料栏位。',
            [FailValidationReason.RecraftOptionalReagentLimit] = '你尝试再造的物品有装备唯一限制。需要先脱下该装备后进行再造。',
        }
        hooksecurefunc(ProfessionsFrame.CraftingPage, 'ValidateControls', function(self)
            local currentRecipeInfo = self.SchematicForm:GetRecipeInfo()
            local isRuneforging = C_TradeSkillUI.IsRuneforging()
            if currentRecipeInfo ~= nil and currentRecipeInfo.learned and (Professions.InLocalCraftingMode() or C_TradeSkillUI.IsNPCCrafting() or isRuneforging)
                and not currentRecipeInfo.isRecraft
                and not currentRecipeInfo.isDummyRecipe and not currentRecipeInfo.isGatheringRecipe
            then
                local transaction = self.SchematicForm:GetTransaction()
                local isEnchant = transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant)
                local countMax = self:GetCraftableCount()
                if isEnchant then
                    self.CreateButton:SetTextToFit('附魔')
                    local quantity = math.max(1, countMax)
                    self.CreateAllButton:SetTextToFit(format('"%s [%d]', '附魔所有', quantity))
                elseif not currentRecipeInfo.abilityVerb and not currentRecipeInfo.alternateVerb then
                    if self.SchematicForm.recraftSlot and self.SchematicForm.recraftSlot.InputSlot:IsVisible() then
                        self.CreateButton:SetTextToFit('再造')
                    else
                        self.CreateButton:SetTextToFit('制造')
                    end
                    if not currentRecipeInfo.abilityAllVerb then
                        self.CreateAllButton:SetTextToFit(format('%s [%d]', '全部制造', countMax))
                    end
                end
                local enabled = true
                if PartialPlayTime() then
                    local reasonText = format('你的在线时间已经超过3小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏下线休息。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                elseif NoPlayTime() then
                    local reasonText = format('你的在线时间已经超过5小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏，下线休息和运动。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                end
                if enabled then
                    local failValidationReason = self:ValidateCraftRequirements(currentRecipeInfo, transaction, isRuneforging, countMax)
                    if failValidationReason and FailValidationTooltips[failValidationReason] then
                        self:SetCreateButtonTooltipText(FailValidationTooltips[failValidationReason])
                    end
                end
            end
        end)


        set(ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog.AcceptButton, '接受')
        set(ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog.CancelButton, '取消')
        ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog:SetTitle('材料品质')

        set(ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox.text, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('使用最高品质材料'))
        ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox:HookScript("OnEnter", function(button)--Blizzard_ProfessionsRecipeSchematicForm.lua
            local checked = button:GetChecked()
            if checked then
                GameTooltip_AddNormalLine(GameTooltip, '取消勾选后，总会使用可用的最低品质的材料。')
            else
                GameTooltip_AddNormalLine(GameTooltip, '勾选后，总会使用可用的最高品质的材料。')
            end
            GameTooltip:Show()
        end)
        set(ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox.text, LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('追踪配方'))
        ProfessionsFrame.CraftingPage.SchematicForm.FavoriteButton:HookScript("OnEnter", function(button)
            GameTooltip_AddHighlightLine(GameTooltip, button:GetChecked() and '从偏好中移除' or '设置为偏好')
            GameTooltip:Show()
        end)
        ProfessionsFrame.CraftingPage.SchematicForm.FavoriteButton:HookScript("OnClick", function(button)
            GameTooltip_AddHighlightLine(GameTooltip, button:GetChecked() and '从偏好中移除' or '设置为偏好')
            GameTooltip:Show()
        end)
        ProfessionsFrame.CraftingPage.SchematicForm.FirstCraftBonus:SetScript("OnEnter", function()
            GameTooltip_AddNormalLine(GameTooltip, '首次制造此配方会教会你某种新东西。')
            GameTooltip:Show()
        end)

        hooksecurefunc(ProfessionsFrame.CraftingPage, 'Init', function(self)--Blizzard_ProfessionsCrafting.lua
            local minimized = ProfessionsUtil.IsCraftingMinimized()
            if minimized and self.MinimizedSearchBox:IsCurrentTextValidForSearch() then
                set(self.MinimizedSearchResults:GetTitleText(),  format('搜索结果\"%s\"(%d)', self.MinimizedSearchBox:GetText(), self.searchDataProvider:GetSize()))
            end
        end)

        hooksecurefunc(ProfessionsFrame.CraftingPage, 'ValidateControls', function(self)--Blizzard_ProfessionsCrafting.lua
            local currentRecipeInfo = self.SchematicForm:GetRecipeInfo()
            local isRuneforging = C_TradeSkillUI.IsRuneforging()
            if currentRecipeInfo ~= nil and currentRecipeInfo.learned and (Professions.InLocalCraftingMode() or C_TradeSkillUI.IsNPCCrafting() or isRuneforging)
                and not currentRecipeInfo.isRecraft
                and not currentRecipeInfo.isDummyRecipe and not currentRecipeInfo.isGatheringRecipe then

                local transaction = self.SchematicForm:GetTransaction()
                local isEnchant = transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant)

                local countMax = self:GetCraftableCount()

                if isEnchant then
                    self.CreateButton:SetTextToFit('附魔')
                    local quantity = math.max(1, countMax)
                    self.CreateAllButton:SetTextToFit(format('%s [%d]', '附魔所有', quantity))
                else
                    if currentRecipeInfo.abilityVerb then
                        -- abilityVerb is recipe-level override
                        --self.CreateButton:SetTextToFit(currentRecipeInfo.abilityVerb)
                    elseif currentRecipeInfo.alternateVerb then
                        -- alternateVerb is profession-level override
                        --self.CreateButton:SetTextToFit(currentRecipeInfo.alternateVerb)
                    elseif self.SchematicForm.recraftSlot and self.SchematicForm.recraftSlot.InputSlot:IsVisible() then
                        self.CreateButton:SetTextToFit('再造')
                    else
                        self.CreateButton:SetTextToFit('制造')
                    end

                    local createAllFormat
                    if currentRecipeInfo.abilityAllVerb then
                        -- abilityAllVerb is recipe-level override
                        createAllFormat = currentRecipeInfo.abilityAllVerb
                    else
                        createAllFormat = '全部制造'
                    end
                    self.CreateAllButton:SetTextToFit(format('%s [%d]', createAllFormat, countMax))
                end

                local enabled = true
                if PartialPlayTime() then
                    local reasonText = format('你的在线时间已经超过3小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏下线休息。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                elseif NoPlayTime() then
                    local reasonText = format('你的在线时间已经超过5小时。在目前阶段下，你不能这么做。在下线休息%d小时后，你的防沉迷时间将会清零。请退出游戏，下线休息和运动。', REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60))
                    self:SetCreateButtonTooltipText(reasonText)
                    enabled = false
                end

                if enabled then
                    local failValidationReason = self:ValidateCraftRequirements(currentRecipeInfo, transaction, isRuneforging, countMax)
                    self:SetCreateButtonTooltipText(FailValidationTooltips[failValidationReason])
                end

            end
        end)

        set(ProfessionsFrame.SpecPage.ApplyButton, '应用改动')
        set(ProfessionsFrame.SpecPage.UnlockTabButton, '解锁专精')
        set(ProfessionsFrame.SpecPage.ViewTreeButton, '解锁专精')
        set(ProfessionsFrame.SpecPage.BackToPreviewButton, '后退')
        set(ProfessionsFrame.SpecPage.ViewPreviewButton, '综述')
        set(ProfessionsFrame.SpecPage.BackToFullTreeButton, '后退')
        ProfessionsFrame.SpecPage.UndoButton.tooltipText= '取消待定改动'
        set(ProfessionsFrame.SpecPage.DetailedView.SpendPointsButton, '运用知识')
        set(ProfessionsFrame.SpecPage.DetailedView.UnlockPathButton, '学习副专精')
        set(ProfessionsFrame.SpecPage.TreePreview.HighlightsHeader, '专精特色：')

        ProfessionsFrame.SpecPage.DetailedView.SpendPointsButton:HookScript("OnEnter", function()
            local self= ProfessionsFrame.SpecPage
            local spendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(self:GetDetailedPanelNodeID())
            if spendCurrency ~= nil then
                local currencyTypesID = self:GetSpendCurrencyTypesID()
                if currencyTypesID then
                    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyTypesID)
                    if self.treeCurrencyInfoMap[spendCurrency] ~= nil and self.treeCurrencyInfoMap[spendCurrency].quantity == 0 then
                        GameTooltip:SetText(format('|cnRED_FONT_COLOR:你没有可以消耗的|r|n|cffffffff%s|r|r', currencyInfo.name), nil, nil, nil, nil, true)
                        GameTooltip:Show()
                    end
                end
            end
        end)
        hooksecurefunc(ProfessionsFrame.SpecPage, 'ConfigureButtons', function(self)
            self.DetailedView.SpendPointsButton:SetScript("OnEnter", function()
                local spendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(self:GetDetailedPanelNodeID())
                if spendCurrency ~= nil then
                    local currencyTypesID = self:GetSpendCurrencyTypesID()
                    if currencyTypesID then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyTypesID)
                        if self.treeCurrencyInfoMap[spendCurrency] ~= nil and self.treeCurrencyInfoMap[spendCurrency].quantity == 0 then
                            GameTooltip:SetOwner(self.DetailedView.SpendPointsButton, "ANCHOR_RIGHT", 0, 0)
                            GameTooltip_AddErrorLine(GameTooltip, format('你没有可以消耗的%s。', currencyInfo.name))

                            GameTooltip:Show()
                        end
                    end
                end
            end)
        end)


        set(ProfessionsFrame.OrdersPage.BrowseFrame.SearchButton, '搜索')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.BackButton, '返回')

        set(ProfessionsFrame.OrdersPage.BrowseFrame.PublicOrdersButton.Text, '公开', nil, true)
        set(ProfessionsFrame.OrdersPage.BrowseFrame.PersonalOrdersButton.Text, '个人', nil, true)

        ProfessionsFrame.OrdersPage.BrowseFrame.OrdersRemainingDisplay:HookScript('OnEnter', function()
            local claimInfo = C_CraftingOrders.GetOrderClaimInfo(ProfessionsFrame.OrdersPage.professionInfo.profession)
            local tooltipText
            if claimInfo.secondsToRecharge then
                tooltipText = format('你目前还能完成|cnGREEN_FONT_COLOR:%d|r份公开订单。|cnGREEN_FONT_COLOR:%s|r后才有更多可用的订单。', claimInfo.claimsRemaining, SecondsToTime(claimInfo.secondsToRecharge))
            else
                tooltipText = format('你目前还能完成|cnGREEN_FONT_COLOR:%d|r份公开订单。', claimInfo.claimsRemaining)
            end
            GameTooltip_AddNormalLine(GameTooltip, tooltipText)
            GameTooltip:Show()
        end)

        local orderTypeTabTitles ={
            [Enum.CraftingOrderType.Public] = '公开',
            [Enum.CraftingOrderType.Guild] = '公会',
            [Enum.CraftingOrderType.Personal] = '个人',}
        local function SetTabTitleWithCount(tabButton, type, count)
            local title = orderTypeTabTitles[type]
            if tabButton and title then
                if type == Enum.CraftingOrderType.Public then
                    set(tabButton.Text, title)
                else
                    set(tabButton.Text, format("%s (%s)", title, count))
                end
            end
        end
        hooksecurefunc(ProfessionsFrame.OrdersPage, 'InitOrderTypeTabs', function(self)
            for _, typeTab in ipairs(self.BrowseFrame.orderTypeTabs) do
                SetTabTitleWithCount(typeTab, typeTab.orderType, 0)
            end
        end)
        ProfessionsFrame.OrdersPage:HookScript('OnEvent', function(self, event, ...)
            if event == "CRAFTINGORDERS_UPDATE_ORDER_COUNT" then
                local type, count = ...
                local tabButton
                if type == Enum.CraftingOrderType.Guild then
                    tabButton = self.BrowseFrame.GuildOrdersButton
                elseif type == Enum.CraftingOrderType.Personal then
                    tabButton = self.BrowseFrame.PersonalOrdersButton
                end
                SetTabTitleWithCount(tabButton, type, count)
            elseif event == "CRAFTINGORDERS_REJECT_ORDER_RESPONSE" then
                local result = ...
                local success = (result == Enum.CraftingOrderResult.Ok)
                if not success then
                    UIErrorsFrame:AddExternalErrorMessage('拒绝订单失败。请稍后再试。')
                end
            end
        end)

        hooksecurefunc(ProfessionsFrame.OrdersPage, 'StartDefaultSearch', function(self)
            if self.BrowseFrame.OrderList.ResultsText:IsShown() then
                set(self.BrowseFrame.OrderList.ResultsText, '小窍门：右键点击配方可以设置偏好。偏好的配方会在你打开你的公开订单时立即出现。')
            end
        end)
        hooksecurefunc(ProfessionsFrame.OrdersPage, 'UpdateOrdersRemaining', function(self)
            if self.professionInfo then
                local isPublic = self.orderType == Enum.CraftingOrderType.Public
                if isPublic and self.professionInfo and self.professionInfo.profession then
                    set(self.BrowseFrame.OrdersRemainingDisplay.OrdersRemaining, format('剩余订单：%s', C_CraftingOrders.GetOrderClaimInfo(self.professionInfo.profession).claimsRemaining))
                end
            end
        end)
        hooksecurefunc(ProfessionsFrame.OrdersPage, 'ShowGeneric', function(self)
            if self.BrowseFrame.OrderList.ResultsText:IsShown() then
                set(self.BrowseFrame.OrderList.ResultsText, '没有发现订单')
            end
        end)

        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.PostedByTitle, '订单发布人：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.CommissionTitle, '佣金：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.ConsortiumCutTitle, '财团分成：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.FinalTipTitle, '你的分成：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.TimeRemainingTitle, '剩余时间：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.NoteBox.NoteTitle, '给制作者的信息：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.StartOrderButton, '开始接单')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.DeclineOrderButton, '拒绝订单')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderInfo.ReleaseOrderButton, '取消订单')

        set(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.OptionalReagents.Label, '附加材料：')
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.OptionalReagents.labelText= '附加材料：'--Blizzard_ProfessionsRecipeSchematicForm.xml
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.AllocateBestQualityCheckBox:HookScript("OnEnter", function(button)
            local checked = button:GetChecked()
            if checked then
                GameTooltip:SetText('取消勾选后，总会使用可用的最低品质的材料。')
            else
                GameTooltip:SetText('勾选后，总会使用可用的最高品质的材料。')
            end
            GameTooltip:Show()
        end)


        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'UpdateStartOrderButton', function(self)--Blizzard_ProfessionsCrafterOrderView.lua
            local errorReason
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID)
            local profession = C_TradeSkillUI.GetChildProfessionInfo().profession
            local claimInfo = profession and C_CraftingOrders.GetOrderClaimInfo(profession)
            if self.order.customerGuid == UnitGUID("player") then
                errorReason = '你不能认领你自己的订单。'
            elseif claimInfo and self.order.orderType == Enum.CraftingOrderType.Public and claimInfo.claimsRemaining <= 0 and Professions.GetCraftingOrderRemainingTime(self.order.expirationTime) > Constants.ProfessionConsts.PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD then
                errorReason = format('你目前无法认领更多的公开订单。%s后才有更多可用的订单。', SecondsToTime(claimInfo.secondsToRecharge))
            elseif not recipeInfo or not recipeInfo.learned or (self.order.isRecraft and not C_CraftingOrders.OrderCanBeRecrafted(self.order.orderID)) then
                errorReason = '你还没有学会此配方。'
            elseif not self.hasOptionalReagentSlots then
                errorReason = '你尚未解锁完成此订单所需的附加材料栏位。'
            end

            if errorReason then
                self.OrderInfo.StartOrderButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self.OrderInfo.StartOrderButton, "ANCHOR_RIGHT")
                    GameTooltip_AddErrorLine(GameTooltip, errorReason)
                    GameTooltip:Show()
                end)
            else
                self.OrderInfo.StartOrderButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self.OrderInfo.StartOrderButton, "ANCHOR_RIGHT")
                    GameTooltip_AddHighlightLine(GameTooltip, '此订单开始后，你有30分钟的时间来完成此订单。')
                    GameTooltip:Show()
                end)
            end
        end)


        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.FulfillmentForm.NoteEditBox.ScrollingEditBox.defaultText= '在此输入消息'

        set(ProfessionsFrame.OrdersPage.OrderView.CompleteOrderButton, '完成订单')
        set(ProfessionsFrame.OrdersPage.OrderView.StartRecraftButton, '再造')
        set(ProfessionsFrame.OrdersPage.OrderView.StopRecraftButton, '取消再造')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.ConfirmationText, '你确定想拒绝此订单吗？')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.NoteEditBox.TitleBox.Title, '拒绝原因：')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.CancelButton, '否')
        set(ProfessionsFrame.OrdersPage.OrderView.DeclineOrderDialog.ConfirmButton, '是')

        set(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.AllocateBestQualityCheckBox.text,  LIGHTGRAY_FONT_COLOR:WrapTextInColorCode('使用最高品质材料'))



        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'InitRegions', function(self)
            self.OrderDetails.FulfillmentForm.OrderCompleteText:SetText('订单完成！')
            self.DeclineOrderDialog:SetTitle('拒绝订单')
        end)

        ProfessionsFrame.OrdersPage.OrderView:HookScript('OnEvent', function(self, event, ...)
            if event == "CRAFTINGORDERS_CLAIM_ORDER_RESPONSE" then
                local result, orderID = ...
                if orderID == self.order.orderID then
                    local success = result == Enum.CraftingOrderResult.Ok
                    if not success then
                        if result == Enum.CraftingOrderResult.CannotClaimOwnOrder then
                            UIErrorsFrame:AddExternalErrorMessage('你不能认领你自己的制造订单。')
                        elseif result == Enum.CraftingOrderResult.OutOfPublicOrderCapacity then
                            UIErrorsFrame:AddExternalErrorMessage('你没有剩余的每日公开订单，现在只能完成即将过期的订单。')
                        else
                            UIErrorsFrame:AddExternalErrorMessage('此订单已不可用。')
                        end
                    end
                end
            elseif event == "CRAFTINGORDERS_RELEASE_ORDER_RESPONSE" or event == "CRAFTINGORDERS_REJECT_ORDER_RESPONSE" then
                local result, orderID = ...
                if orderID == self.order.orderID then
                    local success = result == Enum.CraftingOrderResult.Ok
                    if not success then
                        UIErrorsFrame:AddExternalErrorMessage('制造订单运行失败。请稍后重试。')
                    end
                end
            elseif event == "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE" then
                local result, orderID = ...
                if orderID == self.order.orderID then
                    local success = result == Enum.CraftingOrderResult.Ok
                    if not success then
                        UIErrorsFrame:AddExternalErrorMessage('制造订单运行失败。请稍后重试。')
                    end
                end
            elseif event == "CRAFTINGORDERS_UNEXPECTED_ERROR" then
                UIErrorsFrame:AddExternalErrorMessage('制造订单运行失败。请稍后重试。')
            end
        end)

        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'UpdateCreateButton', function(self)
            local transaction = self.OrderDetails.SchematicForm.transaction
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID)
            if transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
                self.CreateButton:SetText('附魔')
            else
                if recipeInfo and recipeInfo.abilityVerb then
                    --self.CreateButton:SetText(recipeInfo.abilityVerb)
                elseif recipeInfo and recipeInfo.alternateVerb then
                    -- alternateVerb is profession-level override
                    --self.CreateButton:SetText(recipeInfo.alternateVerb)
                elseif self:IsRecrafting() then
                    self.CreateButton:SetText('再造')
                else
                    self.CreateButton:SetText('制造')
                end
            end


            local errorReason
            if Professions.IsRecipeOnCooldown(self.order.spellID) then
                errorReason = '配方冷却中。'
            elseif not transaction:HasMetAllRequirements() then
                errorReason = '你的材料不足。'
            elseif self.order.minQuality and self.OrderDetails.SchematicForm.Details:GetProjectedQuality() and self.order.minQuality > self.OrderDetails.SchematicForm.Details:GetProjectedQuality() then
                local smallIcon = true
                errorReason = format('此订单要求的最低品质是%s', Professions.GetChatIconMarkupForQuality(self.order.minQuality, smallIcon))
            end
            if not errorReason then
                self.CreateButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self.CreateButton, "ANCHOR_RIGHT")
                    GameTooltip_AddErrorLine(GameTooltip, errorReason)
                    GameTooltip:Show()
                end)
            end
        end)


        hooksecurefunc(ProfessionsFrame.OrdersPage.OrderView, 'SetOrder', function(self)
            local warningText
            if self.order.reagentState == Enum.CraftingOrderReagentsType.All then
                warningText = '所有材料都由顾客提供。'
            elseif self.order.reagentState == Enum.CraftingOrderReagentsType.Some then
                warningText = '将由你来提供某些材料。'
            elseif self.order.reagentState == Enum.CraftingOrderReagentsType.None then
                warningText = '将由你来提供全部材料。'
            end
            set(self.OrderInfo.OrderReagentsWarning.Text, warningText)
        end)



        ProfessionsFrame.CraftingPage.CraftingOutputLog:SetTitle('制作成果')

        set(ProfessionsFrame.CraftingPage.SchematicForm.Details.FinishingReagentSlotContainer.Label, '成品材料：')
        set(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Details.FinishingReagentSlotContainer.Label, '成品材料：')
        ProfessionsFrame.CraftingPage.SchematicForm.Details:HookScript('OnShow', function(self)
            set(self.Label, '制作详情')
            set(self.StatLines.DifficultyStatLine.LeftLabel, '配方难度：')
            set(self.StatLines.SkillStatLine.LeftLabel, '技能：')
        end)

        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.Details:HookScript('OnShow', function(self)
            set(self.Label, '制作详情')
            set(self.StatLines.DifficultyStatLine.LeftLabel, '配方难度：')
            set(self.StatLines.SkillStatLine.LeftLabel, '技能：')
        end)




        --set(ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.LeftLabel, '配方难度：')
        --set(ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.LeftLabel, '技能：')

        hooksecurefunc(ProfessionsCrafterDetailsStatLineMixin, 'SetLabel', function(self, label)--Blizzard_ProfessionsRecipeCrafterDetails.lua
            if label== PROFESSIONS_CRAFTING_STAT_TT_CRIT_HEADER then
                set(self.LeftLabel, '灵感')
            elseif label== PROFESSIONS_CRAFTING_STAT_TT_RESOURCE_RETURN_HEADER then
                set(self.LeftLabel, '充裕')
            elseif label== ITEM_MOD_CRAFTING_SPEED_SHORT then
                set(self.LeftLabel, '制作速度')
            elseif label== PROFESSIONS_OUTPUT_MULTICRAFT_TITLE then
                set(self.LeftLabel, '产能')
            end

        end)

        hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'Init', function(self)
            setLabel(self.Label)
        end)
        hooksecurefunc(ProfessionsRecipeListCategoryMixin, 'Init', function(self, node)
            setLabel(self.Label)
        end)

        --Blizzard_ProfessionsSpecializations.lua
        dia("PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB", {button1 = '是', button2 = '取消'})
        hookDia("PROFESSIONS_SPECIALIZATION_CONFIRM_PURCHASE_TAB", 'OnShow', function(self, info)
            local headerText = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(format('学习%s？', info.specName).."\n\n")
            local bodyKey = info.hasAnyConfigChanges and '所有待定的改动都会在解锁此专精后进行应用。您确定要学习%s副专精吗？' or '您确定想学习%s专精吗？您将来可以在%s专业里更加精进后选择额外的专精。'
            local bodyText = NORMAL_FONT_COLOR:WrapTextInColorCode(bodyKey:format(info.specName, info.profName))
            self.text:SetText(headerText..bodyText)
            self.text:Show()
        end)

        --Blizzard_ProfessionsFrame.lua
        dia("PROFESSIONS_SPECIALIZATION_CONFIRM_CLOSE", {text = '你想在离开前应用改动吗？', button1 = '是', button2 = '否',})






















    elseif arg1=='Blizzard_Collections' then--收藏
        hooksecurefunc('CollectionsJournal_UpdateSelectedTab', function(self)--设置，标题
            local selected = CollectionsJournal_GetTab(self)
            if selected==1 then
                self:SetTitle('坐骑')
            elseif selected==2 then
                self:SetTitle('宠物手册')
            elseif selected==3 then
                self:SetTitle('玩具箱')
            elseif selected==4 then
                self:SetTitle('传家宝')
            elseif selected==5 then
                self:SetTitle('外观')
            end
        end)
        set(CollectionsJournalTab1, '坐骑')
            set(MountJournalSearchBox.Instructions, '搜索')
            set(MountJournalFilterButtonText, '过滤器')
            set(MountJournal.MountCount.Label, '坐骑')
            set(MountJournalSummonRandomFavoriteButton.spellname, "随机召唤\n偏好坐骑")--hooksecurefunc('MountJournalSummonRandomFavoriteButton_OnLoad', function(self)
            set(MountJournal.MountDisplay.ModelScene.TogglePlayer.TogglePlayerText, '显示角色')
            hooksecurefunc('MountJournal_OnLoad', function(self)
	            self.SlotRequirementLabel:SetFormattedText('坐骑装备在%s级解锁', C_MountJournal.GetMountEquipmentUnlockLevel())
            end)
            hooksecurefunc('MountJournal_InitializeEquipmentSlot', function(self, item)
                if not item then
                    set(self.SlotLabel, '使用坐骑装备来强化你的坐骑。')
                end
            end)
            hooksecurefunc('MountJournal_UpdateMountDisplay', function(forceSceneChange)
                if ( MountJournal.selectedMountID ) then
                    local creatureName, spellID= C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)
                    if ( MountJournal.MountDisplay.lastDisplayed ~= spellID or forceSceneChange ) then
                        local _, descriptionText, sourceText = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID)
                        set(MountJournal.MountDisplay.InfoButton.Name, e.strText[creatureName])
                        set(MountJournal.MountDisplay.InfoButton.Source, e.strText[sourceText])
                        set(MountJournal.MountDisplay.InfoButton.Lore, e.strText[descriptionText])
                    end
                    if C_MountJournal.NeedsFanfare(MountJournal.selectedMountID) then
                        set(MountJournal.MountButton, '打开')
                    elseif select(4, C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)) then
                        set(MountJournal.MountButton, '解散坐骑')
                    else
                        set(MountJournal.MountButton, '召唤坐骑')
                    end
                end
            end)
            MountJournalMountButton:HookScript('OnEnter', function()
                local needsFanFare = MountJournal.selectedMountID and C_MountJournal.NeedsFanfare(MountJournal.selectedMountID)
                if needsFanFare then
                    GameTooltip_AddNormalLine(GameTooltip, '打开即可获得你的崭新坐骑。', true)
                else
                    GameTooltip_AddNormalLine(GameTooltip, '召唤或解散你选定的坐骑。', true)
                end
                GameTooltip:Show()
            end)
            hooksecurefunc('MountJournal_InitMountButton', function(button, elementData)
                local creatureName= C_MountJournal.GetDisplayedMountInfo(elementData.index)
                set(button.name, e.strText[creatureName])
                if button.DragonRidingLabel:IsShown() then
                    set(button.DragonRidingLabel, '驭空术')
                end
            end)

        set(CollectionsJournalTab2, '宠物手册')
            set(PetJournalSearchBox.Instructions, '搜索')
            set(PetJournalFilterButtonText, '过滤器')
            local function Set_Pet_Button_Name()
                local petID = PetJournalPetCard.petID
                local hasPetID = petID ~= nil
                local needsFanfare = hasPetID and C_PetJournal.PetNeedsFanfare(petID)
                if hasPetID and petID == C_PetJournal.GetSummonedPetGUID() then
                    PetJournal.SummonButton:SetText('解散')
                elseif needsFanfare then
                    PetJournal.SummonButton:SetText('打开')
                else
                    PetJournal.SummonButton:SetText('召唤')
                end
            end
            hooksecurefunc('PetJournal_UpdateSummonButtonState', Set_Pet_Button_Name)
            Set_Pet_Button_Name()

            local function set_PetJournalFindBattle()
                local queueState = C_PetBattles.GetPVPMatchmakingInfo()
                if ( queueState == "queued" or queueState == "proposal" or queueState == "suspended" ) then
                    PetJournalFindBattle:SetText('离开队列')
                else
                    PetJournalFindBattle:SetText('搜寻战斗')
                end
            end
            hooksecurefunc('PetJournalFindBattle_Update', set_PetJournalFindBattle)
            set_PetJournalFindBattle()
            set(PetJournal.PetCount.Label, '宠物')
            set(PetJournalSummonRandomFavoritePetButtonSpellName, '召唤随机\n偏好战斗宠物')
            set(PetJournalHealPetButtonSpellName, '复活\n战斗宠物')
        set(CollectionsJournalTab3, '玩具箱')
            set(ToyBox.searchBox.Instructions, '搜索')
            set(ToyBoxFilterButtonText, '过滤器')
            hooksecurefunc(ToyBox.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
            end)
        set(CollectionsJournalTab4, '传家宝')
            set(HeirloomsJournalText, '过滤器')
            set(HeirloomsJournalSearchBox.Instructions, '搜索')
            hooksecurefunc(HeirloomsJournal.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
            end)
        set(CollectionsJournalTab5, '外观')
            set(WardrobeCollectionFrameSearchBox.Instructions, '搜索')
            hooksecurefunc(WardrobeCollectionFrame, 'SetContainer', function(self, parent)
                if parent == CollectionsJournal then
                    set(self.FilterButton, '过滤器')
                elseif parent == WardrobeFrame then
                    set(self.FilterButton, '来源')
                end
            end)
            set(WardrobeCollectionFrame.FilterButton.text, '过滤器')
            set(WardrobeCollectionFrameTab1, '物品')
                hooksecurefunc(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                    self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
                end)
            set(WardrobeCollectionFrameTab2, '套装')
                hooksecurefunc(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame, 'Update', function(self)--Blizzard_CollectionTemplates.lua
                    self.PageText:SetFormattedText('%d/%d页', self.currentPage, self.maxPages)
                end)

            set(WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox.Label, '两侧肩膀使用不同的幻化外观')

        dia("BATTLE_PET_RENAME", {text = '重命名', button1 = '接受', button2 = '取消', button3 = '默认'})
        dia("BATTLE_PET_PUT_IN_CAGE", {text = '把这只宠物放入笼中？', button1 = '确定', button2 = '取消'})
        dia("BATTLE_PET_RELEASE", {text = "\n\n你确定要释放|cffffd200%s|r吗？\n\n", button1 = '确定', button2 = '取消'})


        dia("DIALOG_REPLACE_MOUNT_EQUIPMENT", {text = '你确定要替换此坐骑装备吗？已有的坐骑装备将被摧毁。', button1 = '是', button2 = '否'})

        --试衣间
        set(WardrobeFrameTitleText, '幻化')
        set(WardrobeOutfitDropDown.SaveButton, '保存')
        set(WardrobeTransmogFrame.ApplyButton, '应用')
        set(WardrobeOutfitEditFrame.Title, '输入外观方案名称：')
        set(WardrobeOutfitEditFrame.AcceptButton, '接受')
        set(WardrobeOutfitEditFrame.CancelButton, '取消')
        set(WardrobeOutfitEditFrame.DeleteButton, '删除外观方案')
        WardrobeTransmogFrame.ModelScene.ClearAllPendingButton:HookScript('OnEnter', function()
            GameTooltip:SetText('取消所有的待定改动')
        end)
















    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        local t= EJ_GetTierInfo(2)
        if t then
            e.strText[t]='燃烧远征'
        end
        t= EJ_GetTierInfo(10)
        if t then
            e.strText[t]='本赛季'
        end

        set(EncounterJournalTitleText, '冒险指南')

        if EncounterJournalMonthlyActivitiesTab then
            set(EncounterJournalMonthlyActivitiesTab, '旅行者日志')
                EncounterJournalMonthlyActivitiesTab:SetScript('OnEnter', function()
                    if not C_PlayerInfo.IsTravelersLogAvailable() then
                        local tradingPostLocation = e.Player.faction == "Alliance" and '暴风城' or '奥格瑞玛'
                        GameTooltip_AddBlankLineToTooltip(GameTooltip)
                        GameTooltip_AddErrorLine(GameTooltip, format('拜访%s的商栈，查看旅行者日志。', tradingPostLocation))
                        if AreMonthlyActivitiesRestricted() then
                            GameTooltip_AddBlankLineToTooltip(GameTooltip)
                            GameTooltip_AddErrorLine(GameTooltip, '需要可用的游戏时间。')
                        end

                        GameTooltip:Show()
                    end
                end)
            end

        set(EncounterJournalSuggestTab, '推荐玩法')
        set(EncounterJournalDungeonTab, '地下城')
        set(EncounterJournalRaidTab, '团队副本')
        set(EncounterJournalLootJournalTab, '套装物品')
        set(EncounterJournalSearchBox.Instructions, '搜索')

        hooksecurefunc('EJInstanceSelect_UpdateTitle', function(tabId)
            local text
            if ( tabId == EncounterJournal.suggestTab:GetID()) then
                text= '推荐玩法'
            elseif ( tabId == EncounterJournal.raidsTab:GetID()) then
                text= '团队副本'
            elseif ( tabId == EncounterJournal.dungeonsTab:GetID()) then
                text= '地下城'
            --elseif ( tabId == EncounterJournal.MonthlyActivitiesTab:GetID()) then
            elseif (tabId == EncounterJournal.LootJournalTab:GetID()) then
                text= '套装物品'
            end
            if text then
                set(EncounterJournal.instanceSelect.Title, text)
            end
        end)
        if EncounterJournalMonthlyActivitiesFrame and EncounterJournalMonthlyActivitiesFrame.HeaderContainer then
            set(EncounterJournalMonthlyActivitiesFrame.HeaderContainer.Title, '旅行者日志')
            set(EncounterJournalMonthlyActivitiesFrame.BarComplete.AllRewardsCollectedText, '你已经收集完了本月的所有奖励')
        end

        set(EncounterJournalEncounterFrameInfoFilterToggle.Text, '过滤器')
        set(EncounterJournalEncounterFrameInstanceFrameMapButtonText, '显示\n地图')
        set(EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle, '综述')

        local function EncounterJournal_SetupIconFlags(sectionID, infoHeaderButton, index)--Blizzard_EncounterJournal.lua
            local iconFlags = C_EncounterJournal.GetSectionIconFlags(sectionID)
            for index2, icon in ipairs(infoHeaderButton.icons or {}) do
                local iconFlag = iconFlags and iconFlags[index2]
                if iconFlag then
                    local tab={
                        [0] = "坦克预警",
                        [1] = "伤害输出预警",
                        [10] = "疾病效果",
                        [11] = "激怒",
                        [12] = "史诗难度",
                        [13] = "流血",
                        [2] = "治疗预警",
                        [3] = "英雄难度",
                        [4] = "灭团技",
                        [5] = "重要",
                        [6] = "可打断技能",
                        [7] = "法术效果",
                        [8] = "诅咒效果",
                        [9] = "中毒效果",
                    }
                    if tab[iconFlag] then
                        icon.tooltipTitle = tab[iconFlag]--_G["ENCOUNTER_JOURNAL_SECTION_FLAG"..iconFlag]
                        if index then
                            if iconFlag==1 then
                                set(infoHeaderButton.title, '伤害')
                            elseif iconFlag==2 then
                                set(infoHeaderButton.title, '治疗者')
                            elseif iconFlag==0 then
                                set(infoHeaderButton.title, '坦克')
                            end
                        end
                    end
                end
            end
        end
        hooksecurefunc('EncounterJournal_SetUpOverview', function(self, overviewSectionID, index)
            local infoHeader= self.overviews[index]
            --local sectionInfo = C_EncounterJournal.GetSectionInfo(overviewSectionID)
            if infoHeader and infoHeader.button and overviewSectionID then
                EncounterJournal_SetupIconFlags(overviewSectionID, infoHeader.button, index)
            end
        end)
        hooksecurefunc('EncounterJournal_ToggleHeaders', function()
            for _, infoHeader in pairs(EncounterJournal.encounter.usedHeaders or {}) do
                if infoHeader.myID and  infoHeader.button then
                    EncounterJournal_SetupIconFlags(infoHeader.myID, infoHeader.button)
                end
            end
        end)




        hooksecurefunc(MonthlyActivitiesButtonTextContainerMixin, 'UpdateText', function(self, data)
            if data.name then
                local a,b= data.name:match('(.-): (.+)')
                a= e.strText[a] or a
                b= e.strText[b] or b
                if a and b then
                    set(self.NameText, (e.strText[a] or a)..': '..(e.strText[b] or b))
                else
                    set(self.NameText, e.strText[data.name])
                end
            end
        end)
        hooksecurefunc(EncounterJournalMonthlyActivitiesFrame.FilterList.ScrollBox, 'Update', function(self)
            if not self:GetView() then
                return
            end
            for _, btn in pairs(self:GetFrames() or {}) do
                setLabel(btn.Label)
            end
        end)


        hooksecurefunc('EncounterJournal_ListInstances', function()
            local frame= EncounterJournal.instanceSelect.ScrollBox
            if not frame:GetView() then
                return
            end
            for _, button in pairs(frame:GetFrames()) do
                setLabel(button.name)
                if button.tooltiptext and e.strText[button.tooltiptext] then
                    button.tooltiptext= e.strText[button.tooltiptext]
                end
            end
        end)

        hooksecurefunc(EncounterJournalItemMixin,'Init', function(self)--Blizzard_EncounterJournal.lua
            local itemInfo = C_EncounterJournal.GetLootInfoByIndex(self.index)
            if ( itemInfo and itemInfo.name ) then
                local name= e.strText[itemInfo.name]
                if name then
                    set(self.name, WrapTextInColorCode(name, itemInfo.itemQuality))
                end
                local slot= e.strText[itemInfo.slot]
                if slot then
                    if itemInfo.handError then
                        set(self.slot, INVALID_EQUIPMENT_COLOR:WrapTextInColorCode(slot))
                    else
                        set(self.slot, slot)
                    end
                end
                local armorType= e.strText[itemInfo.armorType]
                if armorType then
                    if itemInfo.weaponTypeError then
                        set(self.armorType, INVALID_EQUIPMENT_COLOR:WrapTextInColorCode(armorType))
                    else
                        set(self.armorType, armorType)
                    end
                end

                local numEncounters = EJ_GetNumEncountersForLootByIndex(self.index)
                if ( numEncounters == 1 ) then
                    set(self.boss, format('首领：%s', EJ_GetEncounterInfo(itemInfo.encounterID)))
                elseif ( numEncounters == 2) then
                    local itemInfoSecond = C_EncounterJournal.GetLootInfoByIndex(self.index, 2)
                    local secondEncounterID = itemInfoSecond and itemInfoSecond.encounterID
                    if ( itemInfo.encounterID and secondEncounterID ) then
                        set(self.boss:SetFormattedText('首领：%s，%s', e.cn(EJ_GetEncounterInfo(itemInfo.encounterID)), e.cn(EJ_GetEncounterInfo(secondEncounterID))))
                    end
                elseif ( numEncounters > 2 ) then
                    set(self.boss:SetFormattedText('首领：%s及其他', e.cn(EJ_GetEncounterInfo(itemInfo.encounterID))))
                end
            else
                self.name:SetText('正在获取物品信息')
            end
        end)

        hooksecurefunc(EncounterJournalItemHeaderMixin, 'Init', function(self, elementData)
            set(self.name, e.strText[elementData.text])
        end)

        hooksecurefunc(EncounterBossButtonMixin, 'Init', function(self, elementData)
            set(self, e.strText[elementData.name])
        end)

        hooksecurefunc('EncounterJournal_UpdateFilterString', function(self)
            local name
            local classID, specID = EJ_GetLootFilter()
            if (specID > 0) then
                local _
                _, name = GetSpecializationInfoByID(specID, UnitSex("player"))
            elseif (classID > 0) then
                local classInfo = C_CreatureInfo.GetClassInfo(classID)
                if classInfo then
                    name = classInfo.className
                end
            end
            name= e.cn(name)
            if name then
                set(EncounterJournal.encounter.info.LootContainer.classClearFilter.text, format('职业筛选：%s', name))
            end
        end)


        if EncounterJournal.encounter.info then
            local btnTab={
                --"overviewTab",
                "lootTab",
                "bossTab",
                "modelTab"
            }
            for _, str in pairs (btnTab) do
                local button= EncounterJournal.encounter.info[str]
                if button then
                    local tooltip= e.strText[button.tooltip]
                    if tooltip then
                        button.tooltip= tooltip
                    end
                end
            end
        end
        hooksecurefunc('EncounterJournal_DisplayInstance', function()
            local self= EncounterJournal.encounter
            local instanceName, description = EJ_GetInstanceInfo()
            set(self.instance.title, e.strText[instanceName])
            set(self.info.instanceTitle, e.strText[instanceName])
            set(self.instance.LoreScrollingFont, e.strText[description])
            local tooltip= e.strText[self.info['overviewTab'].tooltip]
            if tooltip then
                self.info['overviewTab'].tooltip= tooltip
            end
        end)

        hookButton(EncounterJournalEncounterFrameInfoSlotFilterToggle)
        hookButton(EncounterJournalEncounterFrameInfoDifficulty)

























    --[[elseif arg1=='Blizzard_AchievementUI' then--成就
        set(AchievementFrameTab1, '成就')
        set(AchievementFrameTab2, '公会')
        set(AchievementFrameTab3, '统计')
        set(AchievementFrame.SearchBox.Instructions, '搜索')
        set(AchievementFrameSummaryAchievementsHeaderTitle, '近期成就')
        set(AchievementFrameSummaryCategoriesHeaderTitle, '进展总览')

        hooksecurefunc('AchievementFrame_RefreshView', function()--Blizzard_AchievementUI.lua
            if AchievementFrame.Header.Title:GetText()==GUILD_ACHIEVEMENTS_TITLE then
                AchievementFrame.Header.Title:SetText('公会成就')
            else
                AchievementFrame.Header.Title:SetText('成就点数')
            end
        end)


        hooksecurefunc('AchievementFrameCategories_UpdateDataProvider', function()
            for _, btn in pairs(AchievementFrameCategories.ScrollBox:GetFrames() or {}) do
                if btn.Button then
                    set(btn.Button.Label, e.strText[btn.Button.name])
                end
            end
        end)]]










    elseif arg1=='Blizzard_MacroUI' then
        set(MacroFrameTab1, '通用宏')
        set(MacroFrameTab2, '专用宏', 0.3)
        set(MacroSaveButton, '保存')
        set(MacroCancelButton, '取消')
        set(MacroDeleteButton, '删除')
        set(MacroNewButton, '新建')
        set(MacroExitButton, '退出')

        dia("CONFIRM_DELETE_SELECTED_MACRO", {text= '确定要删除这个宏吗？', button1= '是', button2= '取消'})










    elseif arg1=='Blizzard_Communities' then--公会和社区
        set(CommunitiesFrameTitleText, '公会与社区')
        set(CommunitiesFrame.AddToChatButton.Label, '添加至聊天窗口')
        set(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton, '公会招募')
        set(CommunitiesFrame.InviteButton, '邀请成员')
        set(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton, '公会设置')
        hooksecurefunc(CommunitiesFrame.CommunitiesControlFrame, 'Update', function(self)
            if self.CommunitiesSettingsButton:IsShown() then
                local communitiesFrame = self:GetCommunitiesFrame()
                local clubId = communitiesFrame:GetSelectedClubId()
                if clubId then
                    local clubInfo = C_Club.GetClubInfo(clubId)
                    if clubInfo then
                        self.CommunitiesSettingsButton:SetText(clubInfo.clubType == Enum.ClubType.BattleNet and '群组设置' or '社区设置')
                    end
                end
            end
            set(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton, '社区设置')
        end)

        set(CommunitiesFrame.RecruitmentDialog.DialogLabel, '招募')
        set(CommunitiesFrame.RecruitmentDialog.ShouldListClub.Label, '在公会查找器里列出我的公会')
        set(ClubFinderClubFocusDropdown.Label, '活动倾向')

        set(CommunitiesFrame.RecruitmentDialog.RecruitmentMessageFrame.Label, '招募信息')
        set(CommunitiesFrame.RecruitmentDialog.RecruitmentMessageFrame.RecruitmentMessageInput.EditBox.Instructions, '在此介绍你的公会以及你们需要什么样的玩家。')
        set(CommunitiesFrame.RecruitmentDialog.MinIlvlOnly.EditBox.Text, '物品等级')
        set(CommunitiesFrame.RecruitmentDialog.MaxLevelOnly.Label, '只限满级')
        set(CommunitiesFrame.RecruitmentDialog.MinIlvlOnly.Label, '最低物品等级')
        set(CommunitiesFrame.RecruitmentDialog.Accept, '接受')
        set(CommunitiesFrame.RecruitmentDialog.Cancel, '取消')

        set(CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Label, '公会声望：')

        set(CommunitiesFrame.NotificationSettingsDialog.TitleLabel, '通知设置')--CommunitiesStreams.xml
        set(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.SettingsLabel, '通知')
        set(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.QuickJoinButton.Text, '快速加入通知')
        set(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.NoneButton, '无')
        set(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.AllButton, '全部')

        set(CommunitiesFrame.NotificationSettingsDialog.Selector.OkayButton, '确定')
        set(CommunitiesFrame.NotificationSettingsDialog.Selector.CancelButton, '取消')

        hooksecurefunc(CommunitiesFrame, 'UpdateCommunitiesButtons', function(self)--CommunitiesFrameMixin
            local clubId = self:GetSelectedClubId()
            local inviteButton = self.InviteButton
            if clubId ~= nil then
                local clubInfo = C_Club.GetClubInfo(clubId)
                local isClubAtCapacity = clubInfo and clubInfo.memberCount and clubInfo.memberCount >= C_Club.GetClubCapacity()
                if clubInfo and clubInfo.clubType == Enum.ClubType.Guild then
                    local hasGuildPermissions = CanGuildInvite()
                    local isButtonEnabled = inviteButton:IsEnabled()
                    if(hasGuildPermissions and not isButtonEnabled) then
                        if(isClubAtCapacity) then
                            inviteButton.disabledTooltip = '你无法邀请新成员，你的公会已满。'
                        end
                    elseif(not isButtonEnabled) then
                        inviteButton.disabledTooltip = '你没有邀请的权限。'
                    end
                elseif clubInfo and (clubInfo.clubType == Enum.ClubType.Character or clubInfo.clubType == Enum.ClubType.BattleNet) then
                    local privileges = self:GetPrivilegesForClub(clubId)
                    inviteButton:SetEnabled(not isClubAtCapacity and privileges.canSendInvitation)
                    local isButtonEnabled = inviteButton:IsEnabled()
                    if(privileges.canSendInvitation and not isButtonEnabled) then
                        if(isClubAtCapacity) then
                            inviteButton.disabledTooltip = '你无法邀请新成员，你的社区已满。'
                        end
                    elseif(not isButtonEnabled) then
                        inviteButton.disabledTooltip = '你没有邀请的权限。'
                    end
                end
            end
        end)

        hooksecurefunc(CommunitiesFrame.TicketFrame, 'DisplayTicket', function(self, ticketInfo)--CommunitiesTicketFrameMixin
            local clubInfo = ticketInfo.clubInfo
            self.Type:SetText(clubInfo.clubType == Enum.ClubType.Character and '《魔兽世界》社区' or '暴雪群组')
            self.MemberCount:SetFormattedText('成员：|cffffffff%d|r', clubInfo.memberCount or 1)
        end)
        hooksecurefunc(CommunitiesFrame.InvitationFrame, 'DisplayInvitation', function(self)--CommunitiesInvitationFrame.lua
            local clubInfo = self.invitationInfo.club
            local inviterInfo = self.invitationInfo.inviter
            local isCharacterClub = clubInfo.clubType == Enum.ClubType.Character
            local inviterName = inviterInfo.name or ""
            local classInfo = inviterInfo.classID and C_CreatureInfo.GetClassInfo(inviterInfo.classID)
            local inviterText
            if isCharacterClub and classInfo then
                local classColorInfo = RAID_CLASS_COLORS[classInfo.classFile]
                inviterText = GetPlayerLink(inviterName, ("[%s]"):format(WrapTextInColorCode(inviterName, classColorInfo.colorStr)))
            elseif isCharacterClub then
                inviterText = GetPlayerLink(inviterName, ("[%s]"):format(inviterName))
            else
                inviterText = inviterName
            end
            self.InvitationText:SetFormattedText('%s邀请你加入', inviterText)
            self.Type:SetText(isCharacterClub and '《魔兽世界》社区' or '暴雪群组')
            local leadersText = ""
            for i, leader in ipairs(self.invitationInfo.leaders) do
                if leader.name then
                    leadersText = leadersText..leader.name
                    if i ~= #self.invitationInfo.leaders then
                        leadersText = leadersText..', '
                    end
                end
            end
            self.Leader:SetFormattedText('管理员：|cffffffff%s|r', leadersText)
            self.MemberCount:SetFormattedText('成员：|cffffffff%d|r', clubInfo.memberCount or 1)
        end)


        --CommunitiesMemberList.lua
        COMMUNITY_MEMBER_ROLE_NAMES[Enum.ClubRoleIdentifier.Owner] = '拥有者'
        COMMUNITY_MEMBER_ROLE_NAMES[Enum.ClubRoleIdentifier.Leader] = '管理员'
        COMMUNITY_MEMBER_ROLE_NAMES[Enum.ClubRoleIdentifier.Moderator] = '协管员'
        COMMUNITY_MEMBER_ROLE_NAMES[Enum.ClubRoleIdentifier.Member] = '成员'
        hooksecurefunc(CommunitiesFrame.MemberList, 'UpdateMemberCount', function(self)
            local numOnlineMembers = 0
            for i, memberInfo in ipairs(self.allMemberList) do
                if memberInfo.presence == Enum.ClubMemberPresence.Online or
                    memberInfo.presence == Enum.ClubMemberPresence.Away or
                    memberInfo.presence == Enum.ClubMemberPresence.Busy then
                    numOnlineMembers = numOnlineMembers + 1
                end
            end
            self.MemberCount:SetFormattedText('%s/%s人在线', AbbreviateNumbers(numOnlineMembers), AbbreviateNumbers(#self.allMemberList))
        end)

        set(CommunitiesFrame.MemberList.ShowOfflineButton.Text, '显示离线成员')
        set(CommunitiesFrame.GuildBenefitsFrame.Rewards.TitleText, '公会奖励')
        CommunitiesFrame.GuildBenefitsFrame.GuildRewardsTutorialButton:HookScript('OnEnter', function()--GuildRewards.xml
            GameTooltip:SetText('访问任一主城中的公会商人以购买奖励', nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        CommunitiesFrame.GuildBenefitsFrame.GuildAchievementPointDisplay:HookScript('OnEnter', function()--GuildRewards.lua
            GameTooltip_SetTitle(GameTooltip, '公会成就')
	        GameTooltip:Show()
        end)

        set(CommunitiesFrameGuildDetailsFrameInfo.TitleText, '信息')

        set(ClubFinderGuildFinderFrame.InsetFrame.CommunityCards, 'BuildCardList', function(self)--ClubFinderCommunitiesCardsMixin
            set(self:GetParent().InsetFrame.GuildDescription, '未发现结果。请修改你的搜索条件。')
        end)
        set(ClubFinderGuildFinderFrame.InsetFrame.PendingCommunityCards, 'BuildCardList', function(self)
            set(self:GetParent().InsetFrame.GuildDescription, '未发现结果。请修改你的搜索条件。')
        end)
        hooksecurefunc(ClubFinderGuildFinderFrame, 'UpdateType', function(self)-- ClubFinderGuildAndCommunityMixin:UpdateType()
            if (self.isGuildType) then
                set(self.InsetFrame.GuildDescription, '公会是由许多关系紧密，想要一起享受游戏乐趣的玩家组成的群体。加入公会后，你可以享受许多福利，包括分享公会银行，以及公会聊天频道。\n\n使用此工具来寻找与你志同道合的公会吧。')
                if (#self.PendingGuildCards.CardList > 0) then
                    self.ClubFinderPendingTab.tooltip = format('等待确认中（%d）', #self.PendingGuildCards.CardList)
                else
                    self.ClubFinderPendingTab.tooltip = format('等待确认中（%d）', 0)
                end
            else
                self.InsetFrame.GuildDescription:SetText('选择搜索条件，然后按下“搜索”')
                if (#self.PendingCommunityCards.CardList > 0) then
                    self.ClubFinderPendingTab.tooltip = format('等待确认中（%d）', #self.PendingCommunityCards.CardList)
                else
                    self.ClubFinderPendingTab.tooltip = '等待确认中（0）'
                end
            end
        end)

        CommunitiesSettingsDialog:HookScript('OnShow', function(self)
            if self:GetClubType() == Enum.ClubType.BattleNet then
                self.DialogLabel:SetText('创建暴雪群组')
            else
                self.DialogLabel:SetText('创建《魔兽世界》社区')
            end
        end)
        set(CommunitiesSettingsDialog.NameLabel, '名称')--CommunitiesSettings.xml
        set(CommunitiesSettingsDialog.ShortNameLabel, '简称')
        set(CommunitiesSettingsDialog.DescriptionLabel, '介绍')
        set(CommunitiesSettingsDialog.MessageOfTheDayLabel, '今日信息')
        set(CommunitiesSettingsDialog.ChangeAvatarButton, '更换')
        set(CommunitiesSettingsDialog.CrossFactionToggle.Label, '跨阵营')
        set(CommunitiesSettingsDialog.ShouldListClub.Label, '在社区查找器里列出')
        set(CommunitiesSettingsDialog.AutoAcceptApplications.Label, '自动接受申请者')
        set(CommunitiesSettingsDialog.MaxLevelOnly.Label, '只限满级')
        set(CommunitiesSettingsDialog.MinIlvlOnly.EditBox.Text, '物品等级')
        set(CommunitiesSettingsDialog.MinIlvlOnly.Label, '最低物品等级')
        set(CommunitiesSettingsDialog.LookingForDropdown.Label, '寻找：')
        set(CommunitiesSettingsDialog.LanguageDropdown.Label, '语言')
        CommunitiesSettingsDialog.Description.instructions= '介绍一下你的社区（可选）。'
        set(CommunitiesSettingsDialog.Delete, '删除')
        set(CommunitiesSettingsDialog.Accept, '接受')
        set(CommunitiesSettingsDialog.Cancel, '取消')




        set(CommunitiesFrame.GuildLogButton, '查看日志')
        set(CommunitiesGuildLogFrameCloseButton, '关闭')

        set(CommunitiesFrame.ClubFinderInvitationFrame.AcceptButton, '接受')
        set(CommunitiesFrame.ClubFinderInvitationFrame.DeclineButton, '拒绝')
        set(CommunitiesFrame.ClubFinderInvitationFrame.InvitationText, '')

        hooksecurefunc(CommunitiesFrame.ClubFinderInvitationFrame, 'DisplayInvitation', function(self, clubInfo)--ClubFinderInvitationsFrameMixin
            if clubInfo then
                local isGuild = clubInfo.isGuild
                --self.isLinkInvitation = isLinkInvitation
                if	(isGuild) then
                    self.Type:SetText('公会')
                else
                    self.Type:SetText('社区')
                end
                self.Leader:SetFormattedText('管理员：|cffffffff%s|r', clubInfo.guildLeader)
                self.MemberCount:SetFormattedText('成员：|cffffffff%d|r', clubInfo.numActiveMembers or 1)
                self.InvitationText:SetFormattedText('%s邀请你加入', clubInfo.guildLeader)
            end
        end)

        hooksecurefunc(CommunitiesListEntryMixin, 'SetFindCommunity', function(self)
            set(self.Name, '寻找社区')
        end)
            --set(ClubFinderFilterDropdown.Label, '过滤器')
            --set(ClubFinderSortByDropdown.Label, '排序')
            set(ClubFinderSizeDropdown.Label)
            set(ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search, '搜索')
            set(ClubFinderGuildFinderFrame.OptionsList.Search, '搜索')
            hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame, 'UpdateType', function(self)-- ClubFinderGuildAndCommunityMixin:UpdateType()
                if (self.isGuildType) then
                    set(self.InsetFrame.GuildDescription, '公会是由许多关系紧密，想要一起享受游戏乐趣的玩家组成的群体。加入公会后，你可以享受许多福利，包括分享公会银行，以及公会聊天频道。\n\n使用此工具来寻找与你志同道合的公会吧。')
                    if (#self.PendingGuildCards.CardList > 0) then
                        self.ClubFinderPendingTab.tooltip = format('等待确认中（%d）', #self.PendingGuildCards.CardList)
                    else
                        self.ClubFinderPendingTab.tooltip = format('等待确认中（%d）', 0)
                    end
                else
                    self.InsetFrame.GuildDescription:SetText('选择搜索条件，然后按下“搜索”')
                    if (#self.PendingCommunityCards.CardList > 0) then
                        self.ClubFinderPendingTab.tooltip = format('等待确认中（%d）', #self.PendingCommunityCards.CardList)
                    else
                        self.ClubFinderPendingTab.tooltip = '等待确认中（0）'
                    end
                end
            end)
            hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.CommunityCards, 'BuildCardList', function(self)
                self:GetParent().InsetFrame.GuildDescription:SetText('未发现结果。请修改你的搜索条件。')
            end)
            set(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.GuildDescription, '公会是由许多关系紧密，想要一起享受游戏乐趣的玩家组成的群体。加入公会后，你可以享受许多福利，包括分享公会银行，以及公会聊天频道。|n|n使用此工具来寻找与你志同道合的公会吧。')
            --set(ClubFinderGuildFinderFrame.InsetFrame.GuildDescription, '公会是由许多关系紧密，想要一起享受游戏乐趣的玩家组成的群体。加入公会后，你可以享受许多福利，包括分享公会银行，以及公会聊天频道。|n|n使用此工具来寻找与你志同道合的公会吧。')

            hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame, 'GetDisplayModeBasedOnSelectedTab', function(self)
                if (self.isGuildType) then
                    set(self.InsetFrame.GuildDescription, '公会是由许多关系紧密，想要一起享受游戏乐趣的玩家组成的群体。加入公会后，你可以享受许多福利，包括分享公会银行，以及公会聊天频道。\n\n使用此工具来寻找与你志同道合的公会吧。')
                else
                    set(self.InsetFrame.GuildDescription, '选择搜索条件，然后按下“搜索”')
                end
            end)
            ClubFinderGuildFinderFrame.InsetFrame:HookScript('OnShow', function(self)--ClubFinder.xml
                local disabledReason = C_ClubFinder.GetClubFinderDisableReason()
                if disabledReason == Enum.ClubFinderDisableReason.Muted then
                    self.ErrorDescription:SetText(RED_FONT_COLOR:WrapTextInColorCode('因为你的战网账号的家长监控设定或者隐私设定，此功能处于关闭状态'))
                elseif disabledReason == Enum.ClubFinderDisableReason.Silenced then
                    self.ErrorDescription:SetText(RED_FONT_COLOR:WrapTextInColorCode('由于您的角色在游戏中存在发布不当内容的行为，导致您的账号受到了禁言处罚。被禁言期间，您无法使用此功能。'))
                end
            end)
        hooksecurefunc(CommunitiesListEntryMixin, 'SetAddCommunity', function(self)
            set(self.Name, '加入或创建社区')
        end)
        hooksecurefunc(CommunitiesListEntryMixin, 'SetGuildFinder', function(self)
            set(self.Name, '公会查找器')
        end)

        set(CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.Accept, '接受')
        set(CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog.Cancel, '取消')
        CommunitiesFrame.ClubFinderInvitationFrame.WarningDialog:HookScript('OnShow', function(self)
            if (IsInGuild()) then
                self.DialogLabel:SetText('加入此公会时，你会|cnRED_FONT_COLOR:离开当前的公会|r。')
            else
                self.DialogLabel:SetText('你只能加入一个公会。|n加入此公会时，|cnRED_FONT_COLOR:其他公会邀请会被移除。|r')
            end
        end)

        local function ClubFinderGetTotalNumSpecializations()
            local numClasses = GetNumClasses();
            local count = 0;
            for i = 1, numClasses do
                local _, _, classID = GetClassInfo(i);
                for i2 = 1, GetNumSpecializationsForClassID(classID) do
                    count = count + 1
                end
            end
            return count;
        end
        local function set_ClubFinderRequestToJoin(self)
            if (not self.info) then
                return
            end
            for check in pairs(self.SpecsPool.activeObjects or {}) do
                setLabel(check.SpecName)
            end

            local specIds = ClubFinderGetPlayerSpecIds()
            local matchingSpecNames = { }
            for i, specId in ipairs(specIds) do
                local _, name = GetSpecializationInfoForSpecID(specId)
                if (self.card.recruitingSpecIds[specId]) then
                    table.insert(matchingSpecNames, e.cn(name))
                end
            end
            local classDisplayName = UnitClass("player")
            classDisplayName= e.cn(classDisplayName)
            local isRecruitingAllSpecs = #self.info.recruitingSpecIds == 0 or #self.info.recruitingSpecIds == ClubFinderGetTotalNumSpecializations()
            if(isRecruitingAllSpecs) then
                if(self.info.isGuild) then
                    set(self.RecruitingSpecDescriptions, '此公会正在招募所有的专精类型。')
                else
                    set(self.RecruitingSpecDescriptions, '此社区正在招募所有的专精类型。')
                end
            elseif (#matchingSpecNames == 1) then
                set(self.RecruitingSpecDescriptions, format('此公会正在寻找%s %s。你玩的是哪个专精？', matchingSpecNames[1], classDisplayName))
            elseif (#matchingSpecNames == 2) then
                set(self.RecruitingSpecDescriptions, format('此公会正在寻找%s和%s %s。你玩的是哪个专精？', matchingSpecNames[1], matchingSpecNames[2], classDisplayName))
            elseif (#matchingSpecNames == 3) then
                set(self.RecruitingSpecDescriptions, format('此公会正在寻找%s %s和%s %s。你玩的是哪个专精？', matchingSpecNames[1], matchingSpecNames[2], matchingSpecNames[3], classDisplayName))
            elseif (#matchingSpecNames == 4) then
                set(self.RecruitingSpecDescriptions, format('此公会正在寻找%s %s %s和%s %s。你玩的是哪个专精？', matchingSpecNames[1], matchingSpecNames[2], matchingSpecNames[3], matchingSpecNames[4], classDisplayName))
            end
        end
        hooksecurefunc(ClubFinderGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_ClubFinderRequestToJoin)
        hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_ClubFinderRequestToJoin)
        set(ClubFinderGuildFinderFrame.RequestToJoinFrame.Apply, '申请')
        set(ClubFinderGuildFinderFrame.RequestToJoinFrame.Cancel, '取消')
        set(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.Apply, '申请')
        set(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.Cancel, '取消')
        set(ClubFinderGuildFinderFrame.RequestToJoinFrame.DialogLabel, '申请加入')
        set(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame.DialogLabel, '申请加入')


        hooksecurefunc(ClubsFinderJoinClubWarningMixin, 'OnShow', function(self)--没测试
            if (IsInGuild()) then
                set(self.DialogLabel, '加入此公会时，你会离开当前的公会。')
            else
                set(self.DialogLabel, '你只能加入一个公会。加入此公会时，其他公会邀请会被移除。')
            end
        end)











    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        set(GuildBankFrameTab1, '公会银行')
            set(GuildItemSearchBox.Instructions, '搜索')
            set(GuildBankFrame.WithdrawButton, '提取')
            set(GuildBankFrame.DepositButton, '存放')
            set(GuildBankMoneyLimitLabel, '可用数量：')
            hooksecurefunc(GuildBankFrame, 'UpdateTabs', function(self)--Blizzard_GuildBankUI.lua
                local name, isViewable, canDeposit, numWithdrawals, remainingWithdrawals, disableAll, titleText, withdrawalText
                local numTabs = GetNumGuildBankTabs()
                local currentTab = GetCurrentGuildBankTab()
                -- Set buyable tab
                local tabToBuyIndex
                if ( numTabs < MAX_BUY_GUILDBANK_TABS ) then
                    tabToBuyIndex = numTabs + 1
                end
                -- Disable and gray out all tabs if in the moneyLog since the tab is irrelevant
                if ( self.mode == "moneylog" ) then
                    disableAll = 1
                end
                for i=1, MAX_GUILDBANK_TABS do
                    local tab = self.BankTabs[i]
                    local tabButton = tab.Button
                    name, _, isViewable = GetGuildBankTabInfo(i)
                    if ( not name or name == "" ) then
                        name = format('标签%d', i)
                    end
                    if ( i == tabToBuyIndex and IsGuildLeader() ) then
                        tabButton.tooltip = '购买新的公会银行标签'
                        if ( disableAll or self.mode == "log" or self.mode == "tabinfo" ) then
                        else
                            if ( i == currentTab ) then
                                titleText = '购买新的公会银行标签'
                            end
                        end
                    elseif ( i > numTabs ) then
                    else
                        if ( isViewable ) then
                            if ( i == currentTab ) then
                                withdrawalText = name
                                titleText =  name
                            end
                        end
                    end
                end

                -- Set Title
                if ( self.mode == "moneylog" ) then
                    titleText = '金币记录'
                    withdrawalText = nil
                elseif ( self.mode == "log" ) then
                    if ( titleText ) then
                        titleText = format('%s 记录', titleText)
                    end
                elseif ( self.mode == "tabinfo" ) then
                    withdrawalText = nil
                    if ( titleText ) then
                        titleText = format('%s 信息', titleText)
                    end
                end
                -- Get selected tab info
                name, _, _, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(currentTab)
                if ( titleText and (self.mode ~= "moneylog" and titleText ~= BUY_GUILDBANK_TAB) ) then
                    local access
                    if ( not canDeposit and numWithdrawals == 0 ) then
                        access = '|cffff2020（锁定）|r'
                    elseif ( not canDeposit ) then
                        access = '|cffff2020（只能提取）|r'
                    elseif ( numWithdrawals == 0 ) then
                        access = '|cffff2020（只能存放）|r'
                    else
                        access = '|cff20ff20（全部权限）|r'
                    end
                    titleText = titleText.."  "..access
                end
                if ( titleText ) then
                    self.TabTitle:SetText(titleText)
                end
                if ( withdrawalText ) then
                    local stackString
                    if ( remainingWithdrawals > 0 ) then
                        stackString = format('%d 堆', remainingWithdrawals)
                    elseif ( remainingWithdrawals == 0 ) then
                        stackString = '无'
                    else
                        stackString = '无限'
                    end
                    self.LimitLabel:SetText(format('%s的每日提取额度剩余：|cffffffff%s|r', withdrawalText, stackString))
                end
            end)
        set(GuildBankFrameTab2, '记录')
        set(GuildBankFrameTab3, '金币记录')
        set(GuildBankFrameTab4, '信息')
            set(GuildBankInfoSaveButton, '保存改变')














    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        set(InspectFrameTab1, '角色')
        --pvp
            hooksecurefunc('InspectPVPFrame_Update', function()
                local _, _, _, _, lifetimeHKs, _, honorLevel = GetInspectHonorData()
                InspectPVPFrame.HKs:SetFormattedText('|cffffd200荣誉消灭：|r %d', lifetimeHKs or 0)
                if C_SpecializationInfo.CanPlayerUsePVPTalentUI() then
                    InspectPVPFrame.HonorLevel:SetFormattedText('荣誉等级：%d', honorLevel)
                end
            end)
        set(InspectFrameTab3, '公会')




















    elseif arg1=='Blizzard_PVPUI' then--地下城和团队副本, PVP
        hooksecurefunc('PVPQueueFrame_UpdateTitle', function()--Blizzard_PVPUI.lua
            if ConquestFrame.seasonState == 2 then--SEASON_STATE_PRESEASON
                PVEFrame:SetTitle('PvP（季前赛）')
            elseif ConquestFrame.seasonState == 1 then--SEASON_STATE_OFFSEASON
                PVEFrame:SetTitle('玩家VS玩家（休赛期）')
            else
                local expName = _G["EXPANSION_NAME"..e.ExpansionLevel]
                PVEFrame:SetTitleFormatted('玩家VS玩家 '..(e.strText[expName] or expName)..' 第 %d 赛季', PVPUtil.GetCurrentSeasonNumber())
            end
        end)
        set(PVPQueueFrameCategoryButton1.Name, '快速比赛')
            hooksecurefunc('HonorFrameBonusFrame_Update', function()--Blizzard_PVPUI.lua
                set(HonorFrame.BonusFrame.RandomBGButton.Title, '随机战场')
                set(HonorFrame.BonusFrame.RandomEpicBGButton.Title, '随机史诗战场')
                set(HonorFrame.BonusFrame.Arena1Button.Title, '竞技场练习赛')
            end)
        set(PVPQueueFrameCategoryButton2.Name, '评级')
        set(PVPQueueFrameCategoryButton3.Name, '预创建队伍')
        set(PVPQueueFrame.NewSeasonPopup.Leave, '关闭')

        hooksecurefunc('HonorFrame_UpdateQueueButtons', function()
            local HonorFrame = HonorFrame
            local canQueue
            local arenaID
            local isBrawl
            local isSpecialBrawl
            if ( HonorFrame.type == "specific" ) then
                if ( HonorFrame.SpecificScrollBox.selectionID ) then
                    canQueue = true
                end
            elseif ( HonorFrame.type == "bonus" ) then
                if ( HonorFrame.BonusFrame.selectedButton ) then
                    canQueue = HonorFrame.BonusFrame.selectedButton.canQueue
                    arenaID = HonorFrame.BonusFrame.selectedButton.arenaID
                    isBrawl = HonorFrame.BonusFrame.selectedButton.isBrawl
                    isSpecialBrawl = HonorFrame.BonusFrame.selectedButton.isSpecialBrawl
                end
            end

            local disabledReason

            if arenaID then
                local battlemasterListInfo = C_PvP.GetSkirmishInfo(arenaID)
                if battlemasterListInfo then
                    local groupSize = GetNumGroupMembers()
                    local minPlayers = battlemasterListInfo.minPlayers
                    local maxPlayers = battlemasterListInfo.maxPlayers
                    if groupSize > maxPlayers then
                        canQueue = false
                        disabledReason = format('要进入该竞技场，你的团队需要减少%d名玩家。', groupSize - maxPlayers)
                    elseif groupSize < minPlayers then
                        canQueue = false
                        disabledReason = format('要进入该竞技场，你的团队需要增加%d名玩家。', minPlayers - groupSize)
                    end
                end
            end

            if (isBrawl or isSpecialBrawl) and not canQueue then
                if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                    local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo() or {}
                    if brawlInfo then
                        disabledReason = format('你的小队未满足最低等级要求（%s）。', isSpecialBrawl and brawlInfo.minLevel or GetMaxLevelForPlayerExpansion())
                    end
                else
                    disabledReason = '你的级别不够。'
                end
            end

            if isBrawl or isSpecialBrawl and canQueue then
                local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo() or {}
                local brawlHasMinItemLevelRequirement = brawlInfo and brawlInfo.brawlType == Enum.BrawlType.SoloRbg
                if (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
                    if(brawlInfo and not brawlInfo.groupsAllowed) then
                        canQueue = false
                        disabledReason = '你不能在队伍中那样做。'
                    end
                    if (brawlHasMinItemLevelRequirement and brawlInfo.groupsAllowed) then
                        local brawlMinItemLevel = brawlInfo.minItemLevel
                        local partyMinItemLevel, playerWithLowestItemLevel = C_PartyInfo.GetMinItemLevel(Enum.AvgItemLevelCategories.PvP)
                        if (UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) and partyMinItemLevel < brawlMinItemLevel) then
                            canQueue = false
                            disabledReason = format('"%1$s需要更高的平均装备物品等级。（需要：%2$d。当前%3$d。）', playerWithLowestItemLevel, brawlMinItemLevel, partyMinItemLevel)
                        end
                    end
                end
                local _, _, playerPvPItemLevel = GetAverageItemLevel()
                if (brawlHasMinItemLevelRequirement and playerPvPItemLevel < brawlInfo.minItemLevel) then
                    canQueue = false
                    disabledReason = format('你需要更高的PvP装备物品平均等级才能加入队列。|n（需要 %2$d，当前%3$d。）', brawlInfo.minItemLevel, playerPvPItemLevel)
                end
            end
            if not disabledReason then
                if ( select(2,C_LFGList.GetNumApplications()) > 0 ) then
                    disabledReason = '你不能在拥有有效的预创建队伍申请时那样做。'
                    canQueue = false
                elseif ( C_LFGList.HasActiveEntryInfo() ) then
                    disabledReason = '你不能在你的队伍出现在预创建队伍列表中时那样做。'
                    canQueue = false
                end
            end
            local isInCrossFactionGroup = C_PartyInfo.IsCrossFactionParty()
            if ( canQueue ) then
                if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
                    HonorFrame.QueueButton:SetText('小队加入')
                    if (not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME)) then
                        disabledReason = '你现在不是队长'
                    elseif(isInCrossFactionGroup) then
                        if isBrawl or isSpecialBrawl then
                            local brawlInfo = isSpecialBrawl and C_PvP.GetSpecialEventBrawlInfo() or C_PvP.GetAvailableBrawlInfo()
                            local allowCrossFactionGroups = brawlInfo and brawlInfo.brawlType == Enum.BrawlType.SoloRbg
                            if (not allowCrossFactionGroups) then
                                disabledReason ='在跨阵营队伍中无法这么做。你可以参加竞技场或者评级战场。'
                            end
                        end
                    end
                else
                    HonorFrame.QueueButton:SetText('加入战斗')
                end
            else
                if (HonorFrame.type == "bonus" and HonorFrame.BonusFrame.selectedButton and HonorFrame.BonusFrame.selectedButton.queueID) then
                    if not disabledReason then
                        disabledReason = LFGConstructDeclinedMessage(HonorFrame.BonusFrame.selectedButton.queueID)
                    end
                end
            end
            HonorFrame.QueueButton.tooltip = disabledReason
        end)

        hooksecurefunc('PVPConquestLockTooltipShow', function()
            GameTooltip:SetText(string.format('该功能将在%d级开启。', GetMaxLevelForLatestExpansion()))
            GameTooltip:Show()
        end)

        PVPQueueFrame.HonorInset.CasualPanel:HookScript('OnShow', function(self)
            if self.HKLabel:IsShown() then
                set(self.HKLabel, '宏伟宝库')
            end
        end)
        set(PVPQueueFrame.HonorInset.CasualPanel.HKLabel, '宏伟宝库')
        PVPQueueFrame.HonorInset.CasualPanel.WeeklyChest:HookScript('OnEnter', function()
            if not ConquestFrame_HasActiveSeason() then
                GameTooltip_SetTitle(GameTooltip, '宏伟宝库奖励')
                GameTooltip_AddDisabledLine(GameTooltip, '无效会阶')
                GameTooltip_AddNormalLine(GameTooltip, '征服点数只能在PvP赛季开启期间获得。')
                GameTooltip:Show()
            else
                local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress()
                local unlocksCompleted = weeklyProgress.unlocksCompleted or 0
                local maxUnlocks = weeklyProgress.maxUnlocks or 3
                local description
                if unlocksCompleted > 0 then
                    description = format('通过评级PvP获得获得荣誉点数以解锁宏伟宝库的奖励。你的奖励的物品等级会以你本周胜场的最高段位为基准。\n\n%s/%s奖励已解锁。', unlocksCompleted, maxUnlocks)
                else
                    description = format('通过评级PvP获得获得荣誉点数以解锁宏伟宝库的奖励。你的奖励的物品等级会以你本周胜场的最高段位为基准。\n\n%s/%s奖励已解锁。', unlocksCompleted, maxUnlocks)
                end
                GameTooltip_SetTitle(GameTooltip, '宏伟宝库奖励')
                local hasRewards = C_WeeklyRewards.HasAvailableRewards()
                if hasRewards then
                    GameTooltip_AddColoredLine(GameTooltip, '宏伟宝库里有奖励在等待着你。', GREEN_FONT_COLOR)
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                end
                GameTooltip_AddNormalLine(GameTooltip, description)
                GameTooltip_AddInstructionLine(GameTooltip, '点击预览宏伟宝库')
                GameTooltip:Show()
            end
        end)

        hooksecurefunc(PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay, 'Update', function(self)
            local honorLevel = UnitHonorLevel("player")
	        set(self.LevelLabel, format('荣誉等级 %d', honorLevel))
        end)
        PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '生涯荣誉')
            GameTooltip_AddColoredLine(GameTooltip, '所有角色获得的荣誉。', NORMAL_FONT_COLOR)
            GameTooltip_AddBlankLineToTooltip(GameTooltip)
            local currentHonor = UnitHonor("player")
            local maxHonor = UnitHonorMax("player")
            GameTooltip_AddColoredLine(GameTooltip, string.format('%d / %d', currentHonor, maxHonor), HIGHLIGHT_FONT_COLOR)
            GameTooltip:Show()
        end)
        PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.NextRewardLevel:HookScript('OnEnter', function(self)
            local honorLevel = UnitHonorLevel("player")
            local nextHonorLevelForReward = C_PvP.GetNextHonorLevelForReward(honorLevel)
            local rewardInfo = nextHonorLevelForReward and C_PvP.GetHonorRewardInfo(nextHonorLevelForReward)
            if rewardInfo then
                local rewardText = select(11, GetAchievementInfo(rewardInfo.achievementRewardedID))
                if rewardText and rewardText ~= "" then
                    GameTooltip:SetText(format('到达荣誉等级%d级后可获得下一个奖励', nextHonorLevelForReward))
                    local WRAP = true
                    GameTooltip_AddColoredLine(GameTooltip, rewardText, HIGHLIGHT_FONT_COLOR, WRAP)
                    GameTooltip:Show()
                end
            end
        end)

        BONUS_BUTTON_TOOLTIPS.RandomBG.func= function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText('随机战场', 1, 1, 1)
            GameTooltip:AddLine('在随机战场上与敌对阵营竞争。', nil, nil, nil, true)
            GameTooltip:Show()
        end
        BONUS_BUTTON_TOOLTIPS.EpicBattleground.func = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText('随机史诗战场', 1, 1, 1)
            GameTooltip:AddLine('在40人的大型战场上与敌对阵营竞争。', nil, nil, nil, true)
            GameTooltip:Show()
        end

        --role_tooltips('HonorFrame')
        set(ConquestJoinButton, '加入战斗')



        local function conquestFrameButton_OnEnter(self)--hooksecurefunc('ConquestFrameButton_OnEnter', function(self)--Blizzard_PVPUI.lua
            local tooltip = ConquestTooltip
            local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(self.bracketIndex)
            tooltip.Title:SetText(e.strText[self.toolTipTitle] or self.toolTipTitle)
            local isSoloShuffle = self.id == 1
            local tierInfo = pvpTier and C_PvP.GetPvpTierInfo(pvpTier)
            local tierName = tierInfo and tierInfo.pvpTierEnum and PVPUtil.GetTierName(tierInfo.pvpTierEnum)
            local hasSpecRank = tierName and ranking and isSoloShuffle
            tierName= e.strText[tierName]
            if tierName then
                if ranking and not hasSpecRank then
                    tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RANK_AND_RATING, tierName, ranking, rating)
                else
                    tooltip.Tier:SetFormattedText(PVP_TIER_WITH_RATING, tierName, rating)
                end
            end
            local specName= PlayerUtil.GetSpecName()
            set(tooltip.SpecRank, hasSpecRank and format('%s: 等级 #%d', e.strText[specName] or specName, ranking) or "")
            set(tooltip.WeeklyBest, '最高等级：'..weeklyBest)
            set(tooltip.WeeklyWon, isSoloShuffle and ('胜利回合：' .. roundsWeeklyWon) or ('赢得比赛：' .. weeklyWon))
            set(tooltip.WeeklyPlayed, isSoloShuffle and ('已完成回合：' .. roundsWeeklyPlayed) or ('比赛场次：' .. weeklyPlayed))
            set(tooltip.SeasonBest, '最高等级：'..seasonBest)
            set(tooltip.SeasonWon, isSoloShuffle and ('胜利回合：' .. roundsSeasonWon) or ('赢得比赛：' .. seasonWon))
            set(tooltip.SeasonPlayed, isSoloShuffle and ('已完成回合：' .. roundsSeasonPlayed) or ('比赛场次：' .. seasonPlayed))
            local specStats = isSoloShuffle and C_PvP.GetPersonalRatedSoloShuffleSpecStats()
            if specStats then
                set(tooltip.WeeklyMostPlayedSpec, format('使用最多：%s (%d)', PlayerUtil.GetSpecNameBySpecID(specStats.weeklyMostPlayedSpecID), specStats.weeklyMostPlayedSpecRounds))
                set(tooltip.SeasonMostPlayedSpec, format('使用最多：%s (%d)',PlayerUtil.GetSpecNameBySpecID(specStats.seasonMostPlayedSpecID), specStats.seasonMostPlayedSpecRounds))
            end
            set(self.modeDescription, e.strText[self.modeDescription])
        end
        if ConquestFrame.Arena2v2 then
            ConquestFrame.Arena2v2:HookScript('OnEnter', conquestFrameButton_OnEnter)
        end
        if ConquestFrame.Arena3v3 then
            ConquestFrame.Arena3v3:HookScript('OnEnter', conquestFrameButton_OnEnter)
        end
        if ConquestFrame.RatedBG then
            ConquestFrame.RatedBG:HookScript('OnEnter', conquestFrameButton_OnEnter)
        end


        hooksecurefunc('LFGInvitePopup_Update', function(inviter, _, _, _, _, isQuestSessionActive)
            local titleMarkup = isQuestSessionActive and CreateAtlasMarkup("QuestSharing-QuestLog-Replay", 19, 16) or ""
            local playerName= e.GetPlayerInfo({name=inviter, reName=true, reRealm=true})
            playerName= playerName=='' and inviter or playerName
            LFGInvitePopupText:SetFormattedText(titleMarkup ..'%s邀请你加入队伍', inviter)
            local tankButton = LFGInvitePopupRoleButtonTank
            if tankButton.disabledTooltip and e.strText[tankButton.disabledTooltip] then
                tankButton.disabledTooltip = e.strText[tankButton.disabledTooltip]
            end

            local text
            if WillAcceptInviteRemoveQueues() then
                text= '加入该队伍会将你从激活的队列中移除。'
            end
            if isQuestSessionActive then
                text= (text and text..'|n|n' or '')..'接受此邀请会激活小队同步。任务会与小队进行同步。'
            end
            if text then
                LFGInvitePopup.QueueWarningText:SetText(text)
            end
        end)
--hooksecurefunc('HonorFrame_UpdateQueueButtons', function()









































    elseif arg1=='Blizzard_ArtifactUI' then
        --Blizzard_ArtifactUI.lua
        dia("CONFIRM_ARTIFACT_RESPEC", {text = '确定要重置你的神器专长吗？|n|n这将消耗%s点|cffe6cc80神器能量|r。', button1 = '是', button2 = '否'})
        dia("NOT_ENOUGH_POWER_ARTIFACT_RESPEC", {text = '你没有足够的|cffe6cc80神器能量|r来重置你的专长。|n|n需要%s点|cffe6cc80神器能量|r。', button1 = '确定'})

        --Blizzard_ArtifactPerks.lua
        dia("CONFIRM_RELIC_REPLACE", {text = '你确定要替换此圣物吗？已有的圣物将被摧毁。', button1 = '接受', button2 = '取消'})

    elseif arg1=='Blizzard_Soulbinds' then
        dia("SOULBIND_DIALOG_MOVE_CONDUIT", {text = '一个导灵器只能同时被放置在一个插槽内，所以之前插槽里的该导灵器已被移除。', button1 = '接受'})
        dia("SOULBIND_DIALOG_INSTALL_CONDUIT_UNUSABLE", {text = '此插槽目前未激活。你确定想在此添加一个导灵器吗？', button1 = '接受', button2 = '取消'})

    elseif arg1=='Blizzard_AnimaDiversionUI' then--Blizzard_AnimaDiversionUI.lua
        dia("ANIMA_DIVERSION_CONFIRM_CHANNEL", {text = '你确定想引导心能到%s吗？|n|n|cffffd200%s|r', button1 = '是', button2 = '取消'})
        dia("ANIMA_DIVERSION_CONFIRM_REINFORCE", {text = '你确定想强化%s吗？|n|n|cffffd200这样会永久激活此地点，而且无法撤销。|r', button1 = '是', button2 = '取消'})

        dia("SOULBIND_CONDUIT_NO_CHANGES_CONFIRMATION", {text = '你对你的导灵器进行了改动，但并没有应用这些改动。你确定想要离开吗？', button1 = '离开', button2 = '取消'})

    elseif arg1=='Blizzard_CovenantSanctum' then--Blizzard_CovenantSanctumUpgrades.lua
        dia("CONFIRM_ARTIFACT_RESPEC", {button1 = '是', button2 = '否'})
        hookDia("CONFIRM_ARTIFACT_RESPEC", 'OnShow', function(self, data)
            if data then
                local costString = GetGarrisonTalentCostString(data.talent)
                self.text:SetFormattedText('把|cff20ff20%s|r升到%d级会花费|n%s', data.talent.name, data.talent.tier + 1, costString)
            end
        end)

    elseif arg1=='Blizzard_PerksProgram' then--Blizzard_PerksProgramElements.lua
        set_GameTooltip_func(PerksProgramTooltip)
        set(PerksProgramFrame.ProductsFrame.PerksProgramFilter.FilterDropDownButton.ButtonText, '过滤器')

        dia("PERKS_PROGRAM_CONFIRM_PURCHASE", {text= '用%s%s 交易下列物品？', button1 = '购买', button2 = '取消'})
        dia("PERKS_PROGRAM_CONFIRM_REFUND", {text= '退还下列物品，获得退款%s%s？', button1 = '退款', button2 = '取消'})
        dia("PERKS_PROGRAM_SERVER_ERROR", {text= '商栈与服务器交换数据时出现困难，请稍后再试。', button1 = '确定'})
        dia("PERKS_PROGRAM_ITEM_PROCESSING_ERROR", {text= '正在处理一件物品。请稍后再试。。', button1 = '确定'})
        dia("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM", {text= '你确定想替换当前的冻结物品吗？现在的冻结物品有可能已经下架了。', button1 = '确认', button2 = '取消'})
        dia("PERKS_PROGRAM_SLOW_PURCHASE", {text= '处理您的本次购买所花费的时间比正常情况更长。购买过程会在后台继续进行。', button1= '回到商栈'})
        C_Timer.After(0.3, function()
            set(PerksProgramFrame.FooterFrame.LeaveButton, format('%s 离开', CreateAtlasMarkup("perks-backarrow", 8, 13, 0, 0)))
        end)

    elseif arg1=='Blizzard_WeeklyRewards' then--Blizzard_WeeklyRewards.lua
        font(WeeklyRewardsFrame.HeaderFrame.Text)
        hooksecurefunc(WeeklyRewardsFrame, 'UpdateTitle', function(self)
            local canClaimRewards = C_WeeklyRewards.CanClaimRewards()
            if canClaimRewards then
                set(self.HeaderFrame.Text, '你只能从宏伟宝库选择一件奖励。')
            elseif not C_WeeklyRewards.HasInteraction() and C_WeeklyRewards.HasAvailableRewards() then
                set(self.HeaderFrame.Text, '返回宏伟宝库，获取你的奖励')
            else
                set(self.HeaderFrame.Text, '每周完成活动可以将物品添加到宏伟宝库中。|n你每周可以选择一件奖励。')
            end
        end)

        dia("CONFIRM_SELECT_WEEKLY_REWARD", {text = '你一旦选好奖励就不能变更了。|n|n你确定要选择这件物品吗？', button1 = '是', button2 = '取消'})

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插入， 界面
        hooksecurefunc(ChallengesFrame, 'UpdateTitle', function()
            local currentDisplaySeason =  C_MythicPlus.GetCurrentUIDisplaySeason()
            if ( not currentDisplaySeason ) then
                PVEFrame:SetTitle('史诗钥石地下城')
            else
                local expName = _G["EXPANSION_NAME"..e.ExpansionLevel]
                local title = format('史诗钥石地下城 %s 赛季 %d', e.strText[expName] or expName, currentDisplaySeason)
                PVEFrame:SetTitle(title)
            end
        end)
        set(ChallengesFrame.WeeklyInfo.Child.SeasonBest, '赛季最佳')
        set(ChallengesFrame.WeeklyInfo.Child.ThisWeekLabel, '本周')
        set(ChallengesFrame.WeeklyInfo.Child.Description, '在史诗难度下，你每完成一个地下城，都会提升下一个地下城的难度和奖励。\n\n每周你都会根据完成的史诗地下城获得一系列奖励。\n\n要想开始挑战，把你的地下城难度设置为史诗，然后前往任意下列地下城吧。')

        hooksecurefunc(ChallengesFrame.WeeklyInfo.Child.WeeklyChest, 'Update', function(self, bestMapID, dungeonScore)
            if C_WeeklyRewards.HasAvailableRewards() then
                self.RunStatus:SetText('拜访宏伟宝库获取你的奖励！')
            elseif self:HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Activities)  then
                self.RunStatus:SetText('完成史诗钥石地下城即可获得：')
            elseif C_MythicPlus.GetOwnedKeystoneLevel() or (dungeonScore and dungeonScore > 0) then
                self.RunStatus:SetText('完成史诗钥石地下城即可获得：')
            end
        end)


        ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript('OnEnter', function(self)
            GameTooltip_SetTitle(GameTooltip, '宏伟宝库奖励')
            if self.state == 4 then--CHEST_STATE_COLLECT
                GameTooltip_AddColoredLine(GameTooltip, '宏伟宝库里有奖励在等待着你。', GREEN_FONT_COLOR)
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
            end
            local lastCompletedActivityInfo, nextActivityInfo = WeeklyRewardsUtil.GetActivitiesProgress()
            if not lastCompletedActivityInfo then
                GameTooltip_AddNormalLine(GameTooltip, '在本周内完成一个满级英雄或史诗地下城可以解锁一个宏伟宝库奖励。时空漫游地下城算作英雄地下城。|n|n你的奖励的物品等级会以你本周最高等级的成绩为依据。')
            else
                if nextActivityInfo then
                    local globalString = (lastCompletedActivityInfo.index == 1) and '再完成%1$d个满级英雄或史诗地下城可以解锁第二个宏伟宝库奖励。时空漫游地下城算作英雄地下城。' or '再完成%1$d个满级英雄或史诗地下城可以解锁第三个宏伟宝库奖励。时空漫游地下城算作英雄地下城。'
                    GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress))
                else
                    GameTooltip_AddNormalLine(GameTooltip, '你已经解锁了本周可提供的所有奖励。在下周开始时拜访宏伟宝库，从你解锁的奖励里进行选择！')
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    GameTooltip_AddColoredLine(GameTooltip, '提升你的奖励', GREEN_FONT_COLOR)
                    local level, count = WeeklyRewardsUtil.GetLowestLevelInTopDungeonRuns(lastCompletedActivityInfo.threshold)
                    if level == WeeklyRewardsUtil.HeroicLevel then
                        GameTooltip_AddNormalLine(GameTooltip, format('完成%1$d次史诗难度的地下城，提升你的奖励。', count))
                    else
                        local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level)
                        GameTooltip_AddNormalLine(GameTooltip, format('完成%1$d个%2$d级或更高的史诗地下城可以提升你的奖励。', count, nextLevel))
                    end
                end
            end
            GameTooltip_AddInstructionLine(GameTooltip, '点击预览宏伟宝库')
            GameTooltip:Show()
        end)

        set(ChallengesFrame.WeeklyInfo.Child.DungeonScoreInfo.Title, '史诗钥石评分')
        ChallengesFrame.WeeklyInfo.Child.DungeonScoreInfo:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '史诗钥石评分')
            GameTooltip_AddNormalLine(GameTooltip, '基于你在每个地下城的最佳成绩得出的总体评分。你可以通过更迅速地完成地下城或者完成更高难度的地下城来提高你的评分。|n|n提升你的史诗地下城评分后，你就能把你的地下城装备升级到最高等级。|n|cff1eff00<Shift+点击以链接到聊天栏>|r')
            GameTooltip:Show()
        end)


        CHALLENGE_MODE_EXTRA_AFFIX_INFO["dmg"].name= '额外伤害'
        CHALLENGE_MODE_EXTRA_AFFIX_INFO["dmg"].desc = '敌人的伤害值提高%d%%'
        CHALLENGE_MODE_EXTRA_AFFIX_INFO["health"].name= '额外生命值'
        CHALLENGE_MODE_EXTRA_AFFIX_INFO["health"].desc = '敌人的生命值提高%d%%'
        set(ChallengesKeystoneFrame.StartButton, '激活')
        set(ChallengesKeystoneFrame.Instructions, '插入史诗钥石')
            hooksecurefunc(ChallengesKeystoneFrame, 'OnKeystoneSlotted', function(self)
                local mapID, _, powerLevel= C_ChallengeMode.GetSlottedKeystoneInfo()
                if mapID ~= nil then
                    local name= C_ChallengeMode.GetMapUIInfo(mapID)
                    set(self.DungeonName, e.strText[name])
                    set(self.PowerLevel, format('%d级', powerLevel))
                end
            end)

        set(ChallengesFrame.SeasonChangeNoticeFrame.NewSeason, '全新赛季！')
        set(ChallengesFrame.SeasonChangeNoticeFrame.SeasonDescription, '地下城奖励的物品等级已经提升！')
        set(ChallengesFrame.SeasonChangeNoticeFrame.SeasonDescription2, '史诗地下城的敌人变得更强了！')

        set(ChallengesFrame.SeasonChangeNoticeFrame.Leave, '离开')











    elseif arg1=='Blizzard_PlayerChoice' then
        dia("CONFIRM_PLAYER_CHOICE", {button1 = '确定', button2 = '取消'})
        dia("CONFIRM_PLAYER_CHOICE_WITH_CONFIRMATION_STRING", {button1 = '接受', button2 = '拒绝'})
        hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'SetupHeader', function (self)
            if self.Header:IsShown() then
                set(self.Header.Text, e.strText[self.optionInfo.header])
            end
        end)
        local rarityToString ={
            [Enum.PlayerChoiceRarity.Common] = "|cffffffff普通|r|n|n",
            [Enum.PlayerChoiceRarity.Uncommon] = "|cff1eff00优秀|r|n|n",
            [Enum.PlayerChoiceRarity.Rare] = "|cff0070dd精良|r|n|n",
            [Enum.PlayerChoiceRarity.Epic] = "|cffa335ee史诗|r|n|n",
        }
        hooksecurefunc(PlayerChoiceFrame, 'SetupOptions', function(self)----Blizzard_PlayerChoice.lua
            for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
                set(optionFrame.OptionText, (rarityToString[optionFrame.optionInfo.rarity] or "")..e.cn(optionFrame.optionInfo.description))
            end
        end)
        hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'OnEnter', function(self)
            if self.optionInfo and not self.optionInfo.spellID then
                local header= e.cn(self.optionInfo.header)
                if self.optionInfo.rarityColor then
                    header= self.optionInfo.rarityColor:WrapTextInColorCode(header)
                end
                GameTooltip_SetTitle(GameTooltip, header)
                if self.optionInfo.rarity and self.optionInfo.rarityColor then
                    local rarityStringIndex = self.optionInfo.rarity + 1
                    GameTooltip_AddColoredLine(GameTooltip, e.cn(_G["ITEM_QUALITY"..rarityStringIndex.."_DESC"]), self.optionInfo.rarityColor)
                end
                GameTooltip_AddNormalLine(GameTooltip, e.cn(self.optionInfo.description))
                GameTooltip:Show()
            end
        end)

        hooksecurefunc(GenericPlayerChoiceToggleButton, 'UpdateButtonState', function(self)--PlayerChoiceToggleButtonMixin
            if self:IsShown() then
                local choiceFrameShown = PlayerChoiceFrame:IsShown()
                local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo() or {}
                set(self.Text, choiceFrameShown and '隐藏' or e.strText[choiceInfo.pendingChoiceText])
            end
        end)








    elseif arg1=='Blizzard_GarrisonTemplates' then--Blizzard_GarrisonSharedTemplates.lua
        dia("CONFIRM_FOLLOWER_UPGRADE", {button1 = '是', button2 = '否'})
        dia("CONFIRM_FOLLOWER_ABILITY_UPGRADE", {button1 = '是', button2 = '否'})
        dia("CONFIRM_FOLLOWER_TEMPORARY_ABILITY", {text = '确定要赋予%s这个临时技能吗？', button1 = '是', button2 = '否'})
        dia("CONFIRM_FOLLOWER_EQUIPMENT", {button1 = '是', button2 = '否'})

    elseif arg1=='Blizzard_ClassTrial' then--Blizzard_WeeklyRewards.lua
        dia("CLASS_TRIAL_CHOOSE_BOOST_TYPE", {text = '你希望使用哪种角色直升？', button1 = '接受', button2 = '接受', button3 = '取消'})
        dia("CLASS_TRIAL_CHOOSE_BOOST_LOGOUT_PROMPT", {text = '要使用此角色直升服务，请登出游戏，返回角色选择界面。', button1 = '立刻返回角色选择画面', button2 = '取消'})

    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        dia("DEACTIVATE_FOLLOWER", {button1 = '是', button2 = '否'})
        hookDia("DEACTIVATE_FOLLOWER", 'OnShow', function(self)
            local quality = C_Garrison.GetFollowerQuality(self.data)
            local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE
            local cost = GetMoneyString(C_Garrison.GetFollowerActivationCost())
            local uses = C_Garrison.GetNumFollowerDailyActivations()
            self.text:SetFormattedText('确定要遣散|n%s吗？|n|n重新激活一名追随者需要花费%s。|n你每天可重新激活%d名追随者。', name, cost, uses)
        end)

        dia("ACTIVATE_FOLLOWER", {button1 = '是', button2 = '否'})
        hookDia("ACTIVATE_FOLLOWER", 'OnShow', function(self)
            local quality = C_Garrison.GetFollowerQuality(self.data)
            local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data)..FONT_COLOR_CODE_CLOSE
            local cost = GetMoneyString(C_Garrison.GetFollowerActivationCost())
            local uses = C_Garrison.GetNumFollowerDailyActivations()
            self.text:SetFormattedText('确定要激活|n%s吗？|n|n你今天还能激活%d名追随者，这将花费：', name, cost, uses)
        end)

        dia("CONFIRM_RECRUIT_FOLLOWER", {text  = '确定要招募%s吗？', button1 = '是', button2 = '否'})

        dia("DANGEROUS_MISSIONS", {button1 = '确定', button2 = '取消'})
        hookDia("DANGEROUS_MISSIONS", 'OnShow', function(self)
            local warningIconText = "|T" .. STATICPOPUP_TEXTURE_ALERT .. ":15:15:0:-2|t"
            self.text:SetFormattedText('|n %s |cffff2020警告！|r %s |n|n你即将执行一项高危行动。如果行动失败，所有参与任务的舰船都有一定几率永久损毁。', warningIconText, warningIconText)
        end)

        dia("GARRISON_SHIP_RENAME", {text  = '输入你想要的名字：', button1 = '接受', button2 = '取消', button3= '默认'})

        dia("GARRISON_SHIP_DECOMMISSION", {button1 = '是', button2 = '否'})
        hookDia("GARRISON_SHIP_DECOMMISSION", 'OnShow', function(self)
            local quality = C_Garrison.GetFollowerQuality(self.data.followerID)
            local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data.followerID)..FONT_COLOR_CODE_CLOSE
            self.text:SetFormattedText('你确定要永久报废|n%s吗？|n|n你将无法重新获得这艘舰船。', name)
        end)

        dia("GARRISON_CANCEL_UPGRADE_BUILDING", {text  = '确定要取消这次建筑升级吗？升级的费用将被退还。', button1 = '是', button2 = '否'})
        dia("GARRISON_CANCEL_BUILD_BUILDING", {text  = '确定要取消建造这座建筑吗？建造的费用将被退还。', button1 = '是', button2 = '否'})
        dia("COVENANT_MISSIONS_CONFIRM_ADVENTURE", {text  = '开始冒险？', button1 = '确认', button2 = '取消'})
        dia("COVENANT_MISSIONS_HEAL_CONFIRMATION", {text  = '你确定要彻底治愈这名追随者吗？', button1 = '确认', button2 = '取消'})
        dia("COVENANT_MISSIONS_HEAL_ALL_CONFIRMATION", {text  = '你确定要付出%s，治疗所有受伤的伙伴？', button1 = '治疗全部', button2 = '取消'})

    elseif arg1=='Blizzard_RuneforgeUI' then--Blizzard_RuneforgeCreateFrame.lua
        dia("CONFIRM_RUNEFORGE_LEGENDARY_CRAFT", {button1 = '是', button2 = '否'})
        hookDia("CONFIRM_RUNEFORGE_LEGENDARY_CRAFT", 'OnShow', function(self, data)
            self.text:SetText(data.title)
            local text= data and data.title or ''
            local a= text:match(e.Magic(RUNEFORGE_LEGENDARY_UPGRADING_CONFIRMATION))
            local b= text:match(e.Magic(RUNEFORGE_LEGENDARY_CRAFTING_CONFIRMATION))
            if a then
                set(self.text, format('你确定要花费%s给这件传说装备升级吗？', a))
            elseif b then
                set(self.text, format('你确定要花费%s打造这件传说装备吗？', b))
            end
        end)
        --set_GameTooltip_func(RuneforgeFrameResultTooltip)

    elseif arg1=='Blizzard_ClickBindingUI' then
        dia("CONFIRM_LOSE_UNSAVED_CLICK_BINDINGS", {text  = '你有未保存的点击施法按键绑定。如果你现在关闭，会丢失所有改动。', button1 = '确定', button2 = '取消'})
        dia("CONFIRM_RESET_CLICK_BINDINGS", {text  = '确定将所有点击施法按键绑定重置为默认值吗？\n', button1 = '确定', button2 = '取消'})


        set(ClickBindingFrameTitleText, '关于点击施法按键绑定')
        ClickBindingFrame.TutorialFrame:SetTitle('关于点击施法按键绑定')

        set(ClickBindingFrame.SaveButton, '保存')
        set(ClickBindingFrame.AddBindingButton, '添加绑定')
        set(ClickBindingFrame.ResetButton, '恢复默认设置')
        set(ClickBindingFrame.EnableMouseoverCastCheckbox.Label, '鼠标悬停施法')
        ClickBindingFrame.EnableMouseoverCastCheckbox:HookScript('OnEnter', function()
            GameTooltip:SetText('启用后，鼠标悬停到一个单位框体并使用一个键盘快捷键施放法术时，会直接对该单位施法，无需将该单位设为目标。', nil, nil, nil, nil, true)

        end)
        set(ClickBindingFrame.MouseoverCastKeyDropDown.Label, '鼠标悬停施法按键')
        set(ClickBindingFrame.TutorialFrame.SummaryText, '将法术和宏绑定到鼠标点击')
        set(ClickBindingFrame.TutorialFrame.InfoText, '通过点击单位框体施放绑定的法术和宏')
        set(ClickBindingFrame.TutorialFrame.AlternateText, '可以使用Shift键、Ctrl键或者Alt键来设定其他的点击绑定')
        set(ClickBindingFrame.TutorialFrame.ThrallName, '萨尔')
        ClickBindingFrame.SpellbookPortrait:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, MicroButtonTooltipText('法术书和专业', "TOGGLESPELLBOOK"))
            GameTooltip:Show()
        end)
        ClickBindingFrame.MacrosPortrait:HookScript('OnEnter', function()
            GameTooltip_SetTitle(GameTooltip, '宏')
            GameTooltip:Show()
        end)

        local function NameAndIconFromElementData(elementData)
            if elementData.bindingInfo then
                local bindingInfo = elementData.bindingInfo
                local type = bindingInfo.type
                local actionID = bindingInfo.actionID

                local actionName
                if type == Enum.ClickBindingType.Spell or type == Enum.ClickBindingType.PetAction then
                    local overrideID = FindSpellOverrideByID(actionID)
                    actionName = GetSpellInfo(overrideID)
                elseif type == Enum.ClickBindingType.Macro then
                    local macroName
                    macroName = GetMacroInfo(actionID)
                    actionName = format('%s (宏)', macroName)
                elseif type == Enum.ClickBindingType.Interaction then
                    if actionID == Enum.ClickBindingInteraction.Target then
                        actionName = '目标单位框架 (默认)'
                    elseif actionID == Enum.ClickBindingInteraction.OpenContextMenu then
                        actionName = '打开上下文菜单 (默认)'
                    end
                end
                return actionName
            elseif elementData.elementType == 1 then
                return '默认鼠标绑定'
            elseif elementData.elementType == 3 then
                return '自定义鼠标绑定'
            elseif elementData.elementType == 5 then
                return '空'
            end
        end
        hooksecurefunc(ClickBindingFrame, 'SetUnboundText', function(self, elementData)
            set(self.UnboundText, format('%s 解除绑定', NameAndIconFromElementData(elementData)))
        end)

        local ButtonStrings = {
            LeftButton = '左键',
            Button1 = '左键',
            RightButton = '右键',
            Button2 = '右键',
            MiddleButton = '中键',
            Button3 = '中键',
            Button4 = '按键4',
            Button5 = '按键5',
            Button6 = '按键6',
            Button7 = '按键7',
            Button8 = '按键8',
            Button9 = '按键9',
            Button10 = '按键10',
            Button11 = '按键11',
            Button12 = '按键12',
            Button13 = '按键13',
            Button14 = '按键14',
            Button15 = '按键15',
            Button16 = '按键16',
            Button17 = '按键17',
            Button18 = '按键18',
            Button19 = '按键19',
            Button20 = '按键20',
            Button21 = '按键21',
            Button22 = '按键22',
            Button23 = '按键23',
            Button24 = '按键24',
            Button25 = '按键25',
            Button26 = '按键26',
            Button27 = '按键27',
            Button28 = '按键28',
            Button29 = '按键29',
            Button30 = '按键30',
            Button31 = '按键31',
        }

        local function BindingTextFromElementData(elementData)
            if elementData.elementType == 5 then
                local bindingText = elementData.bindingInfo and '鼠标移到该位置并点击一个鼠标按键来进行绑定' or '点击一个法术或宏以开始'
                return GREEN_FONT_COLOR:WrapTextInColorCode(bindingText)
            end

            local bindingInfo = elementData.bindingInfo
            if not bindingInfo or not bindingInfo.button then
                return RED_FONT_COLOR:WrapTextInColorCode('解除绑定 - 把鼠标移到目标上并点击来设置')
            end

            local buttonString = ButtonStrings[bindingInfo.button]
            local modifierText = C_ClickBindings.GetStringFromModifiers(bindingInfo.modifiers)
            if modifierText ~= "" then
                return format('%s-%s', modifierText, buttonString)
            else
                return buttonString
            end
        end
        local function ColoredNameAndIconFromElementData(elementData)
            local name = NameAndIconFromElementData(elementData)
            local isDisabled
            if elementData.elementType == 5 then
                isDisabled = (elementData.bindingInfo == nil)
            else
                isDisabled = elementData.unbound
            end
            if isDisabled then
                name = DISABLED_FONT_COLOR:WrapTextInColorCode(name)
            end
            return name
        end
        hooksecurefunc(ClickBindingLineMixin, 'Init', function(self, elementData)
            set(self.BindingText, BindingTextFromElementData(elementData))

            set(self.Name, ColoredNameAndIconFromElementData(elementData))
        end)
        hooksecurefunc(ClickBindingHeaderMixin, 'Init', function(self, elementData)
	        set(self.Name, ColoredNameAndIconFromElementData(elementData))
        end)

    elseif arg1=='Blizzard_ProfessionsTemplates' then
        dia("PROFESSIONS_RECRAFT_REPLACE_OPTIONAL_REAGENT", {button1 = '接受', button2 = '取消'})
        hookDia("PROFESSIONS_RECRAFT_REPLACE_OPTIONAL_REAGENT", 'OnShow', function(self, data)
            self.text:SetFormattedText('你想替换%s吗？\n它会在再造时被摧毁。', data.itemName)
        end)

    elseif arg1=='Blizzard_BlackMarketUI' then
        dia("BID_BLACKMARKET", {text = '确定要出价%s竞拍以下物品吗？', button1 = '确定', button2 = '取消'})

    elseif arg1=='Blizzard_TrainerUI' then--专业，训练师
        dia("CONFIRM_PROFESSION", {text = format('你只能学习两个专业。你要学习|cffffd200%s|r作为你的第一个专业吗？', "XXX"), button1 = '接受', button2 = '取消'})
        hookDia("CONFIRM_PROFESSION", 'OnShow', function(self)
            local prof1, prof2 = GetProfessions()
            if ( prof1 and not prof2 ) then
                self.text:SetFormattedText('你只能学习两个专业。你要学习|cffffd200%s|r作为你的第二个专业吗？', GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService))
            elseif ( not prof1 ) then
                self.text:SetFormattedText('你只能学习两个专业。你要学习|cffffd200%s|r作为你的第一个专业吗？', GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService))
            end
        end)
        set(ClassTrainerTrainButton, '训练')

    elseif arg1=='Blizzard_DeathRecap' then
        set(DeathRecapFrame.CloseButton, '关闭')
        set(DeathRecapFrame.Title, '死亡摘要')

    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        set(ItemSocketingSocketButton, '应用')
        set_GameTooltip_func(ItemSocketingDescription)

    elseif arg1=='Blizzard_CombatLog' then--聊天框，战斗记录
        local function set_filter(self)
            if not self then
                return
            end
            for index, tab in pairs(self) do
                if type(tab)=='table' then
                    local name= tab.name
                    local quickButtonName= tab.quickButtonName
                    local tooltip= tab.tooltip
                    name= name and e.strText[name]
                    quickButtonName= quickButtonName and e.strText[quickButtonName]
                    tooltip= tooltip and e.strText[tooltip]
                    if name then
                        self[index].name= name
                    end
                    if quickButtonName then
                        self[index].quickButtonName= quickButtonName
                    end
                    if tooltip then
                        self[index].tooltip= tooltip
                    end
                end
            end
        end
        set_filter(Blizzard_CombatLog_Filter_Defaults.filters)
        set_filter(Blizzard_CombatLog_Filters.filters )

    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面
        set(ItemUpgradeFrameTitleText, '物品升级')
        set(ItemUpgradeFrame.UpgradeButton, '升级')
        set(ItemUpgradeFrame.ItemInfo.MissingItemText, '将物品拖曳至此处升级。')
        set(ItemUpgradeFrame.MissingDescription, '许多可装备的物品都可以进行升级，从而提高其物品等级。不同来源的物品升级所需的货币也各不相同。')
        set(ItemUpgradeFrame.ItemInfo.UpgradeTo, '升级至：')
        set(ItemUpgradeFrame.UpgradeCostFrame.Label, '总花费：')
        hooksecurefunc(ItemUpgradeFrame, 'PopulatePreviewFrames', function(self)
            if self.FrameErrorText:IsShown() then
                setLabel(self.FrameErrorText)--该物品已经升到满级了
            end
        end)


    elseif arg1=='Blizzard_Settings' then--Blizzard_SettingsPanel.lua 
        local label2= e.Cstr(SettingsPanel.CategoryList)
        label2:SetPoint('RIGHT', SettingsPanel.ClosePanelButton, 'LEFT', -2, 0)
        label2:SetText(id..' 语言翻译 提示：请要不在战斗中修改选项')

        set(SettingsPanel.Container.SettingsList.Header.DefaultsButton, '默认设置')
        dia('GAME_SETTINGS_APPLY_DEFAULTS', {text= '你想要将所有用户界面和插件设置重置为默认状态，还是只重置这个界面或插件的设置？', button1= '所有设置', button2= '取消', button3= '这些设置'})--Blizzard_Dialogs.lua
        set(SettingsPanel.GameTab.Text, '游戏')
        set(SettingsPanel.AddOnsTab.Text, '插件')
        set(SettingsPanel.NineSlice.Text, '选项')
        set(SettingsPanel.CloseButton, '关闭')
        set(SettingsPanel.ApplyButton, '应用')

        set(SettingsPanel.NineSlice.Text, '选项')
        set(SettingsPanel.SearchBox.Instructions, '搜索')

    elseif arg1=='Blizzard_TimeManager' then--小时图，时间
        set(TimeManagerStopwatchFrameText, '显示秒表')
        set(TimeManagerAlarmTimeLabel, '提醒时间')
        set(TimeManagerAlarmMessageLabel, '提醒信息')
        set(TimeManagerAlarmEnabledButtonText, '开启提醒')
        set(TimeManagerMilitaryTimeCheckText, '24小时模式')
        set(TimeManagerLocalTimeCheckText, '使用本地时间')
        set(StopwatchTitle, '秒表')

        hooksecurefunc('GameTime_UpdateTooltip', function()--GameTime.lua
            GameTooltip:SetText('时间信息', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddDoubleLine( '服务器时间：', GameTime_GetGameTime(true), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            GameTooltip:AddDoubleLine( '本地时间：', GameTime_GetLocalTime(true), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        end)

    elseif arg1=='Blizzard_ArchaeologyUI' then
        set(ArchaeologyFrameTitleText, '考古学')
        set(ArchaeologyFrameSummaryPageTitle, '种族')
        set(ArchaeologyFrameCompletedPage.infoText, '你还没有完成任何神器。寻找碎片及钥石以完成神器。')
        set(ArchaeologyFrameCompletedPage.titleBig, '已完成神器')
        set(ArchaeologyFrameCompletedPage.titleMid, '已完成的普通神器')

        set(ArchaeologyFrameCompletedPage.titleTop, '已完成的普通神器')

        set(ArchaeologyFrameArtifactPage.historyTitle, '历史')
        set(ArchaeologyFrameArtifactPage.raceRarity, '种族')
        set(ArchaeologyFrame.backButton, '后退')
        set(ArchaeologyFrameArtifactPageSolveFrameSolveButton, '解密')

        hooksecurefunc(ArchaeologyFrame.summaryPage, 'UpdateFrame', function(self)
            set(self.pageText, format('第%d页', self.currentPage))
        end)
        hooksecurefunc(ArchaeologyFrame.completedPage, 'UpdateFrame', function(self)
            set(self.pageText, format('第%d页', self.currentPage))
            set(self.titleTop, self.currData.onRare and '已完成的精良神器' or '已完成的普通神器')
        end)
        hooksecurefunc('ArchaeologyFrame_CurrentArtifactUpdate', function(self)
            local RaceName, _, RaceitemID	= GetArchaeologyRaceInfo(self.raceID, true)

            local runeName
            if RaceitemID and RaceitemID > 0 then
                runeName = C_Item.GetItemInfo(RaceitemID)
            end
            if runeName then
                for i=1, ARCHAEOLOGY_MAX_STONES do
                    local slot= self.solveFrame["keystone"..i]
                    if slot and slot:IsShown() then
                        if ItemAddedToArtifact(i) then
                            self.solveFrame["keystone"..i].tooltip = format('点此以移除 |cnGREEN_FONT_COLOR:%s|r 。', runeName)
                        else
                            self.solveFrame["keystone"..i].tooltip = format('点此以从你的背包中选择一块 |cnGREEN_FONT_COLOR:%s|r 来降低完成该神器所需要的碎片数量。', runeName)
                        end
                    end
                end
            end

            if select(3, GetSelectedArtifactInfo()) == 0 then --Common Item
                self.raceRarity:SetText(RaceName.." - |cffffffff普通|r")
            else
                self.raceRarity:SetText(RaceName.." - |cff0070dd精良|r")
            end
        end)

        ArchaeologyFrame.rankBar:HookScript('OnEnter', function()
            GameTooltip:SetText('考古学技能', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
			GameTooltip:Show()
        end)

        ArchaeologyFrameArtifactPageSolveFrameStatusBar:HookScript('OnEnter', function()
            local _, _, _, _, _, maxCount = GetArchaeologyRaceInfo(ArchaeologyFrame.artifactPage.raceID)
            GameTooltip:SetText(format('拼出该神器所需的碎片数量。\n\n每个种族的碎片最多只能保存%d块。', maxCount), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
			GameTooltip:Show()
        end)
        set(ArchaeologyFrameHelpPageTitle, '考古学')
        set(ArchaeologyFrameHelpPageHelpScrollHelpText, '你需要搜集散落在世界各处的神器碎片来将它们复原为完整的神器。你能够在挖掘场里找到这些碎片，挖掘场的位置会标记在你的地图上。在挖掘场使用调查技能，你的调查工具就会显示出神器碎片大致的埋藏方向和位置。在前往一个新的挖掘地址前你可以在一个挖掘场中收集六次碎片。当你拥有了足够的碎片之后，你就可以破译隐藏在神器中的秘密，了解更多关于艾泽拉斯昔日的历史和传说。寻宝愉快！')
        set(ArchaeologyFrameHelpPageDigTitle, '考古学地图位置标记')

        ArchaeologyFrameSummarytButton:HookScript('OnEnter', function()
            GameTooltip:SetText('当前神器')
        end)
        ArchaeologyFrameCompletedButton:HookScript('OnEnter', function()
            GameTooltip:SetText('已完成神器')
        end)

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换
        set(ItemInteractionFrame.CurrencyCost.Costs, '花费：')
        --hooksecurefunc(ItemInteractionFrame, 'LoadInteractionFrameData', function(self, frameData)dia("ITEM_INTERACTION_CONFIRMATION", {button2 = '取消'})
        dia("ITEM_INTERACTION_CONFIRMATION_DELAYED", {button2 = '取消'})
        dia("ITEM_INTERACTION_CONFIRMATION_DELAYED_WITH_CHARGE_INFO", {button2 = '取消'})

    elseif arg1=='Blizzard_MajorFactions' then

        hooksecurefunc(MajorFactionButtonUnlockedStateMixin, 'SetUpParagonRewardsTooltip', function(self)
            local factionID = self:GetParent().factionID
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID) or {}
            local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)

            if tooLowLevelForParagon then
                GameTooltip_SetTitle(GameTooltip, '你的等级太低，无法获得这个阵营的典范声望。', NORMAL_FONT_COLOR)
            else
                GameTooltip_SetTitle(GameTooltip, '最高名望等级', NORMAL_FONT_COLOR)
                local description = format('继续获取%s的声望以赢取奖励。', e.strText[majorFactionData.name] or majorFactionData.name)
                if hasRewardPending then
                    local questIndex = C_QuestLog.GetLogIndexForQuestID(rewardQuestID)
                    local text = questIndex and GetQuestLogCompletionText(questIndex)
                    if text and text ~= "" then
                        description = e.strText[text] or text
                    end
                end

                GameTooltip_AddHighlightLine(GameTooltip, description)
                if not hasRewardPending then
                    local value = mod(currentValue, threshold)
                    -- Show overflow if a reward is pending
                    if hasRewardPending then
                        value = value + threshold
                    end
                    GameTooltip_ShowProgressBar(GameTooltip, 0, threshold, value, REPUTATION_PROGRESS_FORMAT:format(value, threshold))
                end
                GameTooltip_AddQuestRewardsToTooltip(GameTooltip, rewardQuestID)
            end
        end)
        hooksecurefunc(MajorFactionButtonUnlockedStateMixin, 'SetUpRenownRewardsTooltip', function(self)
            local majorFactionData = C_MajorFactions.GetMajorFactionData(self:GetParent().factionID) or {}
            local tooltipTitle = e.strText[majorFactionData.name] or majorFactionData.name
            GameTooltip_SetTitle(GameTooltip, tooltipTitle, NORMAL_FONT_COLOR)
            local factionID = self:GetParent().factionID
            if not C_MajorFactions.HasMaximumRenown(factionID) then
                GameTooltip_AddNormalLine(GameTooltip, format('当前进度：|cffffffff%d/%d|r', majorFactionData.renownReputationEarned, majorFactionData.renownLevelThreshold))
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, C_MajorFactions.GetCurrentRenownLevel(factionID) + 1) or {}
                if #nextRenownRewards > 0 then
                    RenownRewardUtil.AddRenownRewardsToTooltip(GameTooltip, nextRenownRewards, GenerateClosure(self.ShowMajorFactionRenownTooltip, self))
                end
            end
            GameTooltip_AddColoredLine(GameTooltip, '<点击查看名望>', GREEN_FONT_COLOR)
        end)

        hooksecurefunc(MajorFactionButtonUnlockedStateMixin, 'Refresh', function(self, majorFactionData)--Blizzard_MajorFactionsLandingTemplates.lua
            set(self.Title, majorFactionData.name and e.strText[majorFactionData.name])
            set(self.RenownLevel, format('%d级', majorFactionData.renownLevel or 0))
        end)
        hooksecurefunc(MajorFactionWatchFactionButtonMixin, 'OnLoad', function(self)
            set(self.Label, '显示为经验条')
        end)

        --Blizzard_MajorFactionRenown.lua
        hooksecurefunc(MajorFactionRenownFrame, 'SetUpMajorFactionData', function(self)
            local majorFactionData = C_MajorFactions.GetMajorFactionData(self.majorFactionID) or {}
            if majorFactionData.name and majorFactionData.currentFactionID ~= self.majorFactionID then
                set(self.TrackFrame.Title, e.strText[majorFactionData.name])
            end
        end)



    elseif arg1=='Blizzard_CharacterCustomize' then--飞龙，制定界面
        CharCustomizeFrame.RandomizeAppearanceButton.simpleTooltipLine= '随机外观'

    elseif arg1=='Blizzard_DebugTools' then--FSTACK
        set(TableAttributeDisplay.VisibilityButton.Label, '显示')
        set(TableAttributeDisplay.HighlightButton.Label, '高亮')
        set(TableAttributeDisplay.DynamicUpdateButton.Label, '动态更新')

    elseif arg1=='Blizzard_Calendar' then--日历
        set(CalendarFilterFrameText, '过滤器')
        set(CalendarEventPickerFrame.Header.Text, '选择一个活动')
        set(CalendarEventPickerCloseButtonText, '关闭')
        hooksecurefunc('CalendarFrame_Update', function()
            for i= 1, 7 do
                setLabel(_G['CalendarWeekday'..i..'Name'])
            end
        end)
        hooksecurefunc('CalendarFrame_UpdateTitle', function()
            setLabel(CalendarMonthName)
        end)

        hooksecurefunc('CalendarEventPickerFrame_InitButton', function(btn, elementData)
            local dayButton = CalendarEventPickerFrame.dayButton;
            local monthOffset = dayButton.monthOffset;
            local day = dayButton.day;
            local eventIndex = elementData.index;
            local event = C_Calendar.GetDayEvent(monthOffset, day, eventIndex) or {}
            local tab= e.HolidayEvent[event.eventID]
            if tab and tab[1] then
                btn.Title:SetText(tab[1])
            end
        end)

        local function ShouldDisplayEventOnCalendar(event)
            local shouldDisplayBeginEnd = event and event.sequenceType ~= "ONGOING";
            if ( event.sequenceType == "END" and event.dontDisplayEnd ) then
                shouldDisplayBeginEnd = false;
            end
            return shouldDisplayBeginEnd;
        end
        hooksecurefunc('CalendarFrame_UpdateDayEvents', function(index, day, monthOffset, selectedEventIndex, contextEventIndex)
            local dayButtonName= 'CalendarDayButton'..index    
            local numEvents = C_Calendar.GetNumDayEvents(monthOffset, day);
            local eventIndex = 1;
            local eventButtonIndex = 1;
            while ( eventButtonIndex <= 4 and eventIndex <= numEvents ) do
                local eventButtonText1 = _G[dayButtonName..'EventButton'..eventButtonIndex.."Text1"];--CalendarDayButton16EventButton1Text1
                local event = C_Calendar.GetDayEvent(monthOffset, day, eventIndex);
                if ShouldDisplayEventOnCalendar(event) then
                    local title= e.HolidayEvent[event.eventID] and e.HolidayEvent[event.eventID][1]
                    if title then--and not event.isCustomTitle  then
                        eventButtonText1:SetText(title)
                    end
                    eventButtonIndex = eventButtonIndex + 1;
                end
                eventIndex = eventIndex + 1;
            end
        end)
        

    elseif arg1=='Blizzard_EventTrace' then--ETRACE
        set(EventTraceTitleText, '事件记录')

        set(EventTrace.SubtitleBar.ViewLog.Label, '查看日志')
        set(EventTrace.SubtitleBar.ViewFilter.Label, '过滤器')
        set(EventTrace.Log.Bar.Label, '记录')
        set(EventTrace, 'DisplayEvents', function(self)
            set(self.Log.Bar.Label, '记录')
        end)
        set(EventTrace, 'OnSearchDataProviderChanged', function(self)
            set(self.Log.Bar.Label, format('结果：%d', self.searchDataProvider:GetSize() or 0))
        end)
        set(EventTrace.Log.Bar.DiscardAllButton.Label, '全部清除')
        set(EventTrace.Log.Bar.PlaybackButton.Label, EventTrace:IsLoggingPaused() and '|cnRED_FONT_COLOR:开始' or '|cnGREEN_FONT_COLOR:暂停')
        hooksecurefunc(EventTrace, 'UpdatePlaybackButton', function(self)
            set(self.Log.Bar.PlaybackButton.Label, self:IsLoggingPaused() and '|cnRED_FONT_COLOR:开始' or '|cnGREEN_FONT_COLOR:暂停')
        end)
        set(EventTrace.Log.Bar.MarkButton.Label, '标记')

        set(EventTrace.Filter.Bar.Label, '过滤')
        set(EventTrace.Filter.Bar.DiscardAllButton.Label, '全部删除')
        set(EventTrace.Filter.Bar.UncheckAllButton.Label, '全部取消')
        set(EventTrace.Filter.Bar.CheckAllButton.Label, '全部选取')

    elseif arg1=='Blizzard_ScrappingMachineUI' then--分解
        set(ScrappingMachineFrame.ScrapButton, '拆解')
        C_Timer.After(0.3, function() set(ScrappingMachineFrameTitleText, '拆解大师Mk1型') end)
    end
end
























--###########
--加载保存数据
--###########
local EnabledTab={}
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if e.onlyChinese then
                Save= WoWToolsSave[addName] or Save
                if not Save.disabled then
                    e.disbledCN=nil
                    Init()
                    do
                        for _, name in pairs(EnabledTab or {}) do
                            Init_Loaded(name)
                        end
                    end
                    EnabledTab=nil
                else
                    EnabledTab=nil
                    self:UnregisterEvent("ADDON_LOADED")
                end
                
                --添加控制面板
                e.AddPanel_Check({
                    name= e.onlyChinese and '语言翻译' or e.cn(addName),
                    tooltip= 'UI, 仅限中文，|cnRED_FONT_COLOR:可能会出错|r|nChinese only',
                    value= not Save.disabled,
                    func= function()
                        Save.disabled = not Save.disabled and true or nil
                        print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                    end
                })
            else
                self:UnregisterEvent("ADDON_LOADED")
                EnabledTab=nil
            end

        elseif arg1 then
            if EnabledTab then
                table.insert(EnabledTab, arg1)
            else
                Init_Loaded(arg1)
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
