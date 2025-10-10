--所以角色信息
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local Frame
local CHALLENGE_MODE_KEYSTONE_NAME= CHALLENGE_MODE_KEYSTONE_NAME:gsub('%%s', '(.-)]|h')

local IsInSearch

















local function Initializer(btn, data)
    local col= WoWTools_UnitMixin:GetColor(nil, data.guid)

--玩家，图标
    btn.Icon:SetAtlas(WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil, {reAtlas=true} or ''))

--玩家，名称
    if data.guid== WoWTools_DataMixin.Player.GUID then
        btn.Name:SetText(
            (WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
            ..'|A:CampCollection-icon-star:0:0|a'
        )
    else
        local name= data.name or ''
        btn.Name:SetText(
            name:gsub('-'..WoWTools_DataMixin.Player.Realm, '')--取得全名
            ..(WoWTools_DataMixin.Player.BattleTag~= data.battleTag and WoWTools_DataMixin.Player.BattleTag and data.battleTag
                and '|A:tokens-guildRealmTransfer-small:0:0|a' or ''
            )
            ..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon[data.faction] or '')
        )
    end
    btn.Name:SetTextColor(col.r, col.g, col.b)
--职业
    btn.Class:SetAtlas('classicon-'..(select(2, GetPlayerInfoByGUID(data.guid)) or ''))

--Affix
    local affix= WoWTools_HyperLink:GetKeyAffix(data.itemLink, nil) or ''
    affix= affix:gsub(':0|t', ':17|t')
    btn.AffixText:SetText(affix)

--专精，天赋
    local sex=  select(5, GetPlayerInfoByGUID(data.guid))
    btn.Spec:SetTexture(data.specID>0 and select(4, GetSpecializationInfoForSpecID(data.specID, sex)) or 0)

--装等
    if data.itemLevel and data.itemLevel>0 then
        local item= data.itemLevel- (WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].itemLevel or 0)
        btn.ItemLevelText:SetText(
            (item>6 and '|cnGREEN_FONT_COLOR:' or '|cffffffff')
            ..data.itemLevel
        )
    else
        btn.ItemLevelText:SetText('')
    end

--钥石，名称
    local itemName= WoWTools_HyperLink:CN_Link(data.itemLink, {isName=true})
    btn.Name2:SetText(
        data.itemLink and
        (
            itemName~=data.itemLink and itemName
            or WoWTools_TextMixin:CN(data.itemLink:match(CHALLENGE_MODE_KEYSTONE_NAME) or data.itemLink)
        )
        or ''
    )

--背景
    btn.Background:SetAtlas(
        data.faction=='Alliance' and 'Campaign_Alliance'
        or (data.faction=='Horde' and 'Campaign_Horde')
        or 'StoryHeader-BG'
    )

    btn.RaidText:SetText(data.pve or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8' or ''))
    btn.DungeonText:SetText(data.mythic or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8' or ''))
    btn.WorldText:SetText(data.world or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8' or ''))
    btn.PvPText:SetText(data.pvp or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8' or ''))

--分数
    btn.ScoreText:SetText(
        WoWTools_ChallengeMixin:KeystoneScorsoColor(data.score)
        or ''
    )
--本周次数
    btn.WeekNumText:SetText(
        data.weekNum==0 and '' or data.weekNum
    )

--本周最高
    btn.WeekLevelText:SetText(
        data.weekLevel==0 and '' or data.weekLevel
    )

--背景
    btn.Background:SetAlpha(Save().leftBgAlpha or 0.75)

--数据
    btn.itemLink= data.itemLink
    btn.battleTag= data.battleTag
    btn.specID= data.specID
    btn.itemLevel= data.itemLevel

    btn:SetAlpha(btn.itemLink and 1 or 0.5)
end









local function Sort_Order(a,b)
    if a.faction==b.faction then
        if a.itemLevel==b.itemLevel then
            if a.score==b.score then
                if a.weekNum== b.weekNum then
                    if not b.itemLink or not a.itemLink then
                        return a.itemLink and true or false
                    else
                        return a.weekLevel> b.weekLevel
                    end
                else
                    return a.weekNum> b.weekNum
                end
            else
                return a.score>b.score
            end
        else
            return a.itemLevel>b.itemLevel
        end
    else
        return a.faction==WoWTools_DataMixin.Player.Faction
    end
end






















local function Set_List()
    if IsInSearch then
        return
    else
        IsInSearch=true
    end


    local findText= Frame.SearchBox:HasFocus() and Frame.SearchBox:GetText() or ''
    findText= findText:upper()

    local isFind= findText~=''
    local num=0

    local data = CreateDataProvider()
    for guid, info in pairs(WoWTools_WoWDate) do

        if Save().leftAllPlayer
            or (
                info.Keystone.link
                and guid~=WoWTools_DataMixin.Player.GUID
                and info.region==WoWTools_DataMixin.Player.Region
            )
        then
            num= num+1

            local itemLink= info.Keystone.link
            local fullName= WoWTools_UnitMixin:GetFullName(nil, nil, guid) or '^_^'

            local cnLink= WoWTools_HyperLink:CN_Link(itemLink, {isName=true})
            cnLink= cnLink~=itemLink and cnLink or nil

            if isFind and (
                    itemLink and itemLink:upper():find(findText)
                    or (cnLink and cnLink:upper():find(findText))
                    or fullName:upper():find(findText)
            ) or not isFind then

                data:Insert({
                    guid=guid,
                    name= fullName,
                    faction=info.faction,
                    itemLink= itemLink,

                    score= info.score or 0,
                    weekNum= info.weekNum or 0,
                    weekLevel= info.weekLevel or 0,


                    pve= info.Keystone.weekPvE,
                    mythic= info.Keystone.weekMythicPlus,
                    world= info.Keystone.weekWorld,
                    pvp= info.Keystone.weekPvP,

                    battleTag= info.battleTag,
                    specID= info.specID or 0,
                    itemLevel= info.itemLevel or 0
                })
            end
        end
    end


    data:SetSortComparator(function(...) Sort_Order(...) end)

    Frame.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)

    Frame.SearchBox:SetShown(num>5)
    Frame.Menu:SetShown(num>0)
    Frame.NumLabel:SetText(num>0 and num or '')


    IsInSearch= nil
end































local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, sub3, name
--小号. 史诗钥石
    local num, playerNum=0, 0
    local keys={}
    for guid, info in pairs(WoWTools_WoWDate) do
        if info.Keystone.link
            --and info.region==WoWTools_DataMixin.Player.Region
        then
            if guid==WoWTools_DataMixin.Player.GUID then
                playerNum= playerNum+1
            else
                num= num+1
            end
            keys[guid]= info.Keystone
        end

    end

    name= '|T525134:0|t'..(WoWTools_DataMixin.onlyChinese and '史诗钥石' or WEEKLY_REWARDS_MYTHIC_KEYSTONE)
        ..' #'..num..'+'..playerNum
    sub= root:CreateCheckbox(
        name,
    function()
        return not Save().hideLeft
    end, function()
        Save().hideLeft= not Save().hideLeft and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Left()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '小号钥石列表' or ACCOUNT_QUEST_LABEL)
    end)





    if Frame and self==Frame.Menu then
        sub=root
        sub:CreateDivider()
    end

--所有角色   
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '所有角色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, CHARACTER),
    function()
        return Save().leftAllPlayer
    end, function()
        Save().leftAllPlayer= not Save().leftAllPlayer and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Left()
    end)


--所有角色，全部清除
    sub3=sub2:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        (WoWTools_DataMixin.onlyChinese and '所有角色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, CHARACTER))
            ..'\n|T525134:0|t'..(WoWTools_DataMixin.onlyChinese and '挑战数据' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYER_DIFFICULTY5, SAVE))
            ..'\n\n'
            ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            ..'\n',
        nil,
        {SetValue=function()
            for guid in pairs(WoWTools_WoWDate) do
                WoWTools_WoWDate[guid].Keystone= {week=WoWTools_DataMixin.Player.Week}
            end
            C_MythicPlus.RequestMapInfo()
            WoWTools_ChallengeMixin:ChallengesUI_Left()
        end})
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '挑战数据' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYER_DIFFICULTY5, SAVE))
    end)


--所有角色，列表 
    sub2:CreateDivider()
    for guid, Keystone in pairs(keys) do
        sub3=sub2:CreateCheckbox(
            WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true})
            ..' '
            ..(WoWTools_TextMixin:CN(Keystone.link:match(CHALLENGE_MODE_KEYSTONE_NAME) or Keystone.link)),
        function(data)
            return WoWTools_WoWDate[data.guid].Keystone.link
        end, function(data)
            if WoWTools_WoWDate[data.guid].Keystone.link then
                WoWTools_WoWDate[data.guid].Keystone= {week=WoWTools_DataMixin.Player.Week}
            else
                WoWTools_WoWDate[data.guid].Keystone= data.Keystone
            end
            WoWTools_ChallengeMixin:ChallengesUI_Left()
        end, {guid=guid, Keystone=Keystone, itemLink= Keystone.link})

        WoWTools_SetTooltipMixin:Set_Menu(sub3)

    end
--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(sub2)


--宽度
    sub:CreateDivider()
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().leftWidth or 230
        end, setValue=function(value)
            Save().leftWidth=value
            WoWTools_ChallengeMixin:ChallengesUI_Left()
        end,
        name=WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH,
        minValue=100,
        maxValue=640,
        step=1,
    })
    sub:CreateSpacer()

--透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().leftBgAlpha or 0.75
        end, setValue=function(value)
            Save().leftBgAlpha=value
            WoWTools_ChallengeMixin:ChallengesUI_Left()
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY,
        minValue=0,
        maxValue=1,
        step='0.05',
        bit='%.2f',
    })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().leftScale or 1
    end, function(value)
        Save().leftScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Left()
    end, function()
        Save().leftScale=nil
        Save().leftWidth=nil
        Save().leftBgAlpha=nil
        WoWTools_ChallengeMixin:ChallengesUI_Left()
    end)

--sub 提示
    sub:CreateSpacer()
    sub:CreateTitle(name)
end


















local function Init()
    if Save().hideLeft then
        return
    end


    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:Hide()

    function Frame:Settings()
        local show= not Save().hideLeft
        self:SetWidth(Save().leftWidth or 230)
        self:SetScale(Save().leftScale or 1)
        self:SetShown(show)
        self.Menu:SetShown(show)
        self.SearchBox:SetShown(show)
    end

    Frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.view:SetDataProvider(CreateDataProvider())
    end)

    Frame:SetScript('OnShow', function(self)
        self:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        C_Timer.After(1, function()
            Set_List()
        end)
    end)

    Frame:SetScript('OnEvent', function()
        Set_List()
    end)


    --Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    Frame:SetPoint('TOPRIGHT', ChallengesFrame, 'TOPLEFT')
    Frame:SetPoint('BOTTOMRIGHT', ChallengesFrame, 'BOTTOMLEFT')

    Frame.Menu= WoWTools_ButtonMixin:Menu(ChallengesFrame, {icon='hide', size=23})
    Frame.Menu:SetPoint('BOTTOMRIGHT', Frame, 'TOPRIGHT', 0,2)
    Frame.Menu:SetFrameStrata('HIGH')
    Frame.Menu:SetFrameLevel(3)
    Frame.Menu:SetupMenu(Init_Menu)


--数量
    Frame.NumLabel= WoWTools_LabelMixin:Create(Frame.Menu, {color=true})
    Frame.NumLabel:SetPoint('CENTER', Frame.Menu)


--SearchBox
    Frame.SearchBox= WoWTools_EditBoxMixin:Create(Frame.Menu, {
        isSearch=true,
    })
    Frame.SearchBox:SetPoint('BOTTOMLEFT', Frame, 'TOPLEFT', 4, 2)
    Frame.SearchBox:SetPoint('BOTTOMRIGHT', Frame, 'TOPRIGHT', -24,2)
    Frame.SearchBox:SetAlpha(0.3)
    Frame.SearchBox.Instructions:SetText(
        WoWTools_DataMixin.onlyChinese and '角色名称，副本'
        or (REPORTING_MINOR_CATEGORY_CHARACTER_NAME..', '..INSTANCE)
    )
    Frame.SearchBox:HookScript('OnTextChanged', function()
        Set_List()
    end)
    Frame.SearchBox:HookScript('OnEditFocusGained', function(self)
        self:SetAlpha(1)
    end)
    Frame.SearchBox:HookScript('OnEditFocusLost', function(self)
        self:SetAlpha((self:HasFocus() or GameTooltip:IsOwned(self)) and 1 or 0.3)
    end)
    Frame.SearchBox:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
    end)
    Frame.SearchBox:SetScript('OnLeave', function(self)
        self:SetAlpha(self:HasFocus() and 1 or 0.3)
    end)







    Frame.ScrollBox= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollBox:SetAllPoints()

    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPRIGHT", Frame, "TOPLEFT", -6,-12)
    Frame.ScrollBar:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMLEFT", -6,12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsKeystoneButtonTemplate', function(...) Initializer(...) end)
























    Frame:Settings()

    Init= function()
        Frame:SetShown(false)
        Frame:Settings()
    end
end












function WoWTools_ChallengeMixin:ChallengesUI_Left()
    Init()
end

function WoWTools_ChallengeMixin:ChallengesUI_Left_Menu(...)
    Init_Menu(...)
end