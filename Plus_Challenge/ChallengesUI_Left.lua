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
    btn.Icon:SetAtlas(WoWTools_UnitMixin:GetRaceIcon({
        guid=data.guid,
        reAtlas=true,
    } or ''))

--玩家，名称
    local name= data.name or ''
    btn.Name:SetText(
        name:gsub('-'..WoWTools_DataMixin.Player.realm, '')--取得全名
        ..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon[data.faction] or '')
    )
    btn.Name:SetTextColor(col.r, col.g, col.b)
--职业
    btn.Class:SetAtlas('classicon-'..(select(2, GetPlayerInfoByGUID(data.guid)) or ''))

--钥石，名称
    btn.Name2:SetText(
        WoWTools_TextMixin:CN(
        data.itemLink:match(CHALLENGE_MODE_KEYSTONE_NAME)
        or data.itemLink
    ))

--背景
    btn.Background:SetAtlas(
        data.faction=='Alliance' and 'Campaign_Alliance'
        or (data.faction=='Horde' and 'Campaign_Horde')
        or 'StoryHeader-BG'
    )


    btn.RaidText:SetText(data.pve or '|cff8282822/4/8')
    btn.DungeonText:SetText(data.mythic or '|cff8282822/4/8')
    btn.WorldText:SetText(data.world or '|cff8282822/4/8')
    btn.PvPText:SetText(data.pvp or '|cff8282822/4/8')

--分数
    btn.ScoreText:SetText(
        data.score==0 and '|cff8282820' or
        WoWTools_ChallengeMixin:KeystoneScorsoColor(data.score)
    )
--本周次数
    btn.WeekNumText:SetText(
        (data.weekNum==0 and '|cff828282' or '')
        ..data.weekNum
    )

--本周最高
    btn.WeekLevelText:SetText(
        (data.weekLevel==0 and '|cff828282' or '')
        ..data.weekLevel
    )

    btn.itemLink= data.itemLink

    btn.Background:SetAlpha(Save().leftBgAlpha or 0.75)
end









local function Sort_Order(a,b)
    if a.faction==b.faction then
        if a.score==b.score then
            if a.weekNum== b.weekNum then
                return b.weekLevel> a.weekLevel
            else
                return b.weekNum> a.weekNum
            end
        else
            return b.score>a.score
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

        if info.Keystone.link and guid~=WoWTools_DataMixin.Player.GUID then
            num= num+1

            local name= isFind and WoWTools_UnitMixin:GetFullName(nil, nil, guid):upper()
            local link= isFind and info.Keystone.link:match('|h%[(.-)]|h'):upper()

            if (isFind and (link:find(findText) or name:find(findText))) or not isFind then

                data:Insert({
                    guid=guid,
                    name= WoWTools_UnitMixin:GetFullName(nil, nil, guid),
                    faction=info.faction,
                    itemLink= info.Keystone.link,

                    score= info.score or 0,
                    weekNum= info.weekNum or 0,
                    weekLevel= info.weekLevel or 0,


                    pve= info.Keystone.weekPvE,
                    mythic= info.Keystone.weekMythicPlus,
                    world= info.Keystone.weekWorld,
                    pvp= info.Keystone.weekPvP,
                })

            end
        end
    end

    data:SetSortComparator(Sort_Order)

    Frame.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)

    Frame.SearchBox:SetShown(num>6)

    Frame.NumLabel:SetText(num>0 and num or '')


    IsInSearch= nil
end





















local function Init()
    if Save().hideLeft then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:Hide()

    Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    Frame:SetPoint('TOPRIGHT', ChallengesFrame, 'TOPLEFT')
    Frame:SetPoint('BOTTOMRIGHT', ChallengesFrame, 'BOTTOMLEFT')



--SearchBox
    Frame.SearchBox= WoWTools_EditBoxMixin:Create(Frame, {
        isSearch=true,
    })
    Frame.SearchBox:SetPoint('BOTTOMLEFT', Frame, 'TOPLEFT', 4, 2)
    Frame.SearchBox:SetPoint('BOTTOMRIGHT', Frame, 'TOPRIGHT', 0,2)
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


--数量
    Frame.NumLabel= WoWTools_LabelMixin:Create(Frame, {color=true})
    Frame.NumLabel:SetPoint('TOPRIGHT', Frame, 'TOPLEFT', -2, 2)
    Frame.NumLabel:EnableMouse(true)
    Frame.NumLabel:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    Frame.NumLabel:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)






    Frame.ScrollList= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollList:SetAllPoints()

    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPRIGHT", Frame, "TOPLEFT", -6,-12)
    Frame.ScrollBar:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMLEFT", -6,12)
    Frame.ScrollBar:SetHideIfUnscrollable(true)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollList, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsKeystoneButtonTemplate', Initializer)

    function Frame:Settings()
        self:SetWidth(Save().leftWidth or 230)
        self:SetScale(Save().leftScale or 1)
        self:SetShown(not Save().hideLeft)
    end

    Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider())
    end)
    Frame:SetScript('OnShow', function()
        Set_List()
    end)

    Frame:Settings()

    Init= function()
        Frame:SetShown(false)
        Frame:Settings()
    end
end












function WoWTools_ChallengeMixin:ChallengesUI_Left()
    Init()
end