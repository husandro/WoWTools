--所以角色信息
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local Frame
local CHALLENGE_MODE_KEYSTONE_NAME= CHALLENGE_MODE_KEYSTONE_NAME:gsub('%%s', '')





local function Initializer(btn, data)
--玩家，图标
    btn.Icon:SetAtlas(WoWTools_UnitMixin:GetRaceIcon({
        guid=data.guid,
        reAtlas=true,
    } or ''))

--玩家，名称
    local col= WoWTools_UnitMixin:GetColor(nil, data.guid)
    local name= data.name or ''
    btn.Name:SetText(
        name:gsub('-'..WoWTools_DataMixin.Player.realm, '')--取得全名
        ..(WoWTools_UnitMixin:GetClassIcon(nil, nil, data.guid) or '')
        ..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon[data.faction] or '')
    )
    btn.Name:SetTextColor(col.r, col.g, col.b)

--钥石，名称
    btn.Name2:SetText(data.itemLink:gsub(CHALLENGE_MODE_KEYSTONE_NAME, '') or data.itemLink)

--背景
    btn.Background:SetAtlas(
        data.faction=='Alliance' and 'Campaign_Alliance'
        or (data.faction=='Horde' and 'Campaign_Horde')
        or 'StoryHeader-BG'
    )

    btn.RaidText:SetText(data.pve or '|cff8282820/0/0')
    btn.DungeonText:SetText(data.mythic or '|cff8282820/0/0')
    btn.WorldText:SetText(data.world or '|cff8282820/0/0')
    btn.PvPText:SetText(data.pvp or '|cff8282820/0/0')

    btn.ScoreText:SetText((data.score==0 and '|cff828282' or '')..data.score)
    btn.WeekNumText:SetText((data.weekNum==0 and '|cff828282' or '')..data.weekNum)
    btn.WeekLevelText:SetText((data.weekLevel==0 and '|cff828282' or '')..data.weekLevel)

    btn.itemLink= data.itemLink
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
    local data = CreateDataProvider()
    
    for guid, info in pairs(WoWTools_WoWDate) do
        if info.Keystone.link then
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

    data:SetSortComparator(Sort_Order)

    Frame.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
end









local function Init()
    if Save().hideLeft then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame, 'WowScrollBoxList')
    Frame:Hide()

    Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)
    Frame:SetPoint('TOPRIGHT', ChallengesFrame, 'TOPLEFT')
    Frame:SetPoint('BOTTOMRIGHT', ChallengesFrame, 'BOTTOMLEFT')
    Frame:SetWidth(250)

    Frame.ScrollBar= CreateFrame("EventFrame", nil, ChallengesFrame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPRIGHT", Frame, "TOPLEFT", -6,-12)
    Frame.ScrollBar:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMLEFT", -6,12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame, Frame.ScrollBar, Frame.view)

    Frame.view:SetElementInitializer('WoWToolsKeystoneButtonTemplate', Initializer)



    function Frame:Settings()
        self:SetWidth(250)
        self:SetShown(not Save().hideLeft)
        self:SetScale(Save().leftScale or 1)
    end

    Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider())
    end)
    Frame:SetScript('OnShow', function()
        Set_List()
    end)

    Frame:Settings()

    --显示背景 Background
   -- WoWTools_TextureMixin:CreateBackground(Frame, {isAllPoint=true})

    Init= function()
        Frame:Settings()
    end
end












function WoWTools_ChallengeMixin:ChallengesUI_Left()
    Init()
end

