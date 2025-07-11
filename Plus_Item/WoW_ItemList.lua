--战团，物品列表
local function Save()
    return WoWToolsSave['Plus_ItemInfo'] or {}
end

local Frame
local CHALLENGE_MODE_KEYSTONE_NAME= CHALLENGE_MODE_KEYSTONE_NAME:gsub('%%s', '(.+)')
local List2Type='Item'
local List2Buttons={}






local function Get_Player_Name(data)
    local name= WoWTools_UnitMixin:GetPlayerInfo(nil, data.guid, nil, {
        reNotRace=true,
        faction=data.faction,
        level=data.level,
        realm=data.realm,
        reRealm=true,
        reName=true}
    ) or data.guid

    if data.battleTag and WoWTools_DataMixin.Player.BattleTag~=data.battleTag then
        name= name..' |cnRED_FONT_COLOR:'..data.battleTag..'|r'
    end
    if data.region and data.region~=WoWTools_DataMixin.Player.Region then
        name= name.. ' |cff6060600'..data.region..'|r'
    end

    local atlas= WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil, {reAtlas=true})

    return name, atlas
end





local List2TypeTab= {
--物品
    ['Item']= {
    atlas='bag-main',
    tooltip=WoWTools_DataMixin.onlyChinese and '物品' or ITEMS,
    set_num=function(self)
        local num=0
        local wowData= WoWTools_WoWDate[Frame.guid]
        for _ in pairs(wowData and wowData.Item or {}) do
            num=num+1
        end
        self.Text:SetText(num==0 and '|cff6060600' or num)
    end,
    get_data=function(isFind, findText, findID)
        local wowData= WoWTools_WoWDate[Frame.guid]
        local data, num= CreateDataProvider(), 0
        for itemID, tab in pairs(wowData and wowData.Item or {}) do
            WoWTools_Mixin:Load({id=itemID, type='item'})

            local name, cnName
            if isFind then
                name= C_Item.GetItemNameByID(itemID)
                cnName= WoWTools_TextMixin:CN(name, {itemID=itemID, isName=true})
                cnName= cnName and cnName~=name and cnName:upper() or nil
                name=  name and name:upper()
            end

            if isFind and (itemID==findID or (name and name:find(findText)) or cnName and cnName:find(findText))
                or not isFind
            then
                data:Insert({
                    itemID= itemID,
                    bag= tab.bag or 0,
                    bank= tab.bank or 0,
                    quality= C_Item.GetItemQualityByID(itemID) or 1,
                })
                num=num+ (tab.bag or 0)+ (tab.bank or 0)
            end
        end
        data:SetSortComparator(function(v1, v2)
            return v1.quality==v2.quality and v1.itemID> v2.itemID or v1.quality>v2.quality
        end)
        return data, num
    end,
    set_button=function(self)
        local data= self.data
        local itemID= data and data.itemID
        local itemName, itemTexture, itemAtlas, count, r, g, b
        if itemID then
            local itemQuality, _
            itemName, _, itemQuality, _, _, _, _, _, _, itemTexture= C_Item.GetItemInfo(itemID)

            itemName= WoWTools_TextMixin:CN(itemName, {itemID=itemID, isName=true}) or itemID
            itemTexture= itemTexture or C_Item.GetItemIconByID(itemID)

            r,g,b= C_Item.GetItemQualityColor(itemQuality or data.quality or 1)


            local bag, bank ,wow
            bag= data.bag
            bag= bag>0 and WoWTools_Mixin:MK(bag, 3)..'|A:bag-main:0:0|a' or ''

            bank= data.bank
            bank= bank>0 and WoWTools_Mixin:MK(bank, 3)..'|A:ParagonReputation_Bag:0:0|a' or ''

            wow= WoWTools_ItemMixin:GetWoWCount(itemID, Frame.guid, Frame.regon)
            wow= wow>0 and '|cff00ccff'..WoWTools_Mixin:MK(wow, 3)..'|r|A:glues-characterSelect-iconShop-hover:0:0|a' or ''

            count= wow..bank..bag
        end
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end
    },







--货币
    ['Currency']= {
    atlas='PH-currency-icon',
    tooltip=WoWTools_DataMixin.onlyChinese and '货币' or CURRENCY,
    set_num=function(self)
        local num=0
        local wowData= WoWTools_WoWDate[Frame.guid]
        for _ in pairs(wowData and wowData.Item or {}) do
            num=num+1
        end
        self.Text:SetText(num==0 and '|cff6060600' or num)
    end,
    get_data=function(isFind, findText, findID)
        local wowData= WoWTools_WoWDate[Frame.guid]
        local data, num= CreateDataProvider(), 0
        for currencyID, all in pairs(wowData and wowData.Currency or {}) do
            local name, cnName
            if isFind then
                local info= C_CurrencyInfo.GetCurrencyInfo(currencyID)
                name= info and info.name
                if name then
                    cnName= WoWTools_TextMixin:CN(name)
                    cnName= cnName and cnName~=name and cnName:upper() or nil
                    name=  name and name:upper()
                end
            end

            if isFind and (currencyID==findID or (name and name:find(findText)) or cnName and cnName:find(findText))
                or not isFind
            then
                data:Insert({
                    currencyID= currencyID,
                    num= all or 0,
                })
                num=num+all
            end
        end
        data:SetSortComparator(function(v1, v2)
            return v1.currencyID>v2.currencyID
        end)
        return data, WoWTools_Mixin:MK(num, 3)
    end,
    set_button=function(self)
        local itemName, itemTexture, itemAtlas, count, r, g, b
        local data= self.data
        local currencyID= data and data.currencyID
        if currencyID then
            local info= C_CurrencyInfo.GetCurrencyInfo(currencyID)
            if info then
                local icon, _, _, col= WoWTools_CurrencyMixin:GetAccountIcon(currencyID)
                itemName= (icon or '')..(col or '')..WoWTools_TextMixin:CN(info.name) or currencyID
                itemTexture= info.iconFileID

                local wow= WoWTools_CurrencyMixin:GetWoWCount(currencyID, Frame.guid, Frame.regon)
                count= (wow>0 and '|cff00ccff'..wow..'|r|A:glues-characterSelect-iconShop-hover:0:0|a' or '')
                    ..(data.num>0 and WoWTools_Mixin:MK(data.num, 3)..WoWTools_DataMixin.Icon.Player or '')

                r,g,b= C_Item.GetItemQualityColor(info.quality or 1)
            end
        end
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end},







--钱
    ['Money']= {
    atlas='Auctioneer',
    tooltip=WoWTools_DataMixin.onlyChinese and '钱' or MONEY,
    set_num=function(self)
        local num=0
        for _, data in pairs(WoWTools_WoWDate) do
            if data.Money and data.Money>0 then
                num= num+1
            end
        end
        self.Text:SetText(num==0 and '|cff6060600' or num)
    end,
    get_data=function()
        local data, num= CreateDataProvider(), 0
        for guid, tab in pairs(WoWTools_WoWDate) do
            if tab.Money and tab.Money>0 then
                data:Insert({
                    money= tab.Money,

                    guid= guid,
                    region= tab.region,
                    faction= tab.faction,
                    battleTag= tab.battleTag,
                    level= tab.level
                })
                num= num+ tab.Money
            end
        end
        data:SetSortComparator(function(v1, v2)
            return v1.money> v2.money
        end)
        return data, WoWTools_Mixin:MK(num/10000, 3)
    end,
    set_button=function(self)
        local itemName, itemTexture, itemAtlas, count, r, g, b
        local data= self.data
        local money= data and data.money
        if money then
            itemName, itemAtlas= Get_Player_Name(data)
            count= WoWTools_Mixin:MK(money/10000, 3)..'|A:Auctioneer:0:0|a'
        end
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end},









--游戏时间
    ['Time']= {
    atlas='clock-icon',
    tooltip=WoWTools_DataMixin.onlyChinese and '游戏时间' or TOKEN_REDEEM_GAME_TIME_TITLE or SLASH_PLAYED2:gsub('/', ''),
    set_num=function(self)
        local num=0
        for _, data in pairs(WoWTools_WoWDate) do
            if data.Time and data.Time.totalTime and data.Time.totalTime>0 then
                num= num+1
            end
        end
        self.Text:SetText(num==0 and '|cff6060600' or num)
    end,
    get_data=function()
        local data, num= CreateDataProvider(), 0
        for guid, tab in pairs(WoWTools_WoWDate) do
            if tab.Time and tab.Time.totalTime and tab.Time.totalTime>0 then
                local seconds= WoWTools_TimeMixin:GetUpdate_Seconds(tab.Time.upData)
                data:Insert({
                    totalTime= tab.Time.totalTime+ seconds,
                    levelTime= (tab.Time.levelTime or 0)+ seconds,

                    guid= guid,
                    region= tab.region,
                    faction= tab.faction,
                    battleTag= tab.battleTag,
                    level= tab.level
                })
                num= num+ tab.Time.totalTime
            end
        end

        data:SetSortComparator(function(v1, v2)
            return v1.totalTime> v2.totalTime
        end)

        return data, WoWTools_TimeMixin:SecondsToFullTime(num)
    end,
    set_button=function(self)
        local itemName, itemTexture, itemAtlas, count, r, g, b
        local data= self.data
        local totalTime= data and data.totalTime
        if totalTime then
            itemName, itemAtlas= Get_Player_Name(data)
            count= WoWTools_TimeMixin:SecondsToFullTime(totalTime)
        end
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end}
}

--[[
 WoWTools_WoWDate[guid]= {--默认数据
    Item={},--{itemID={bag=包, bank=银行}},
    Currency={},--{currencyID = 数量}

    Keystone={week=WoWTools_DataMixin.Player.Week},--{score=总分数, link=超连接, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},

    Instance={ins={}, week=WoWTools_DataMixin.Player.Week, day=day},--ins={[名字]={[难度]=已击杀数}}
    Worldboss={boss={}, week=WoWTools_DataMixin.Player.Week, day=day},--{week=周数, boss=table}
    Rare={day=day, boss={}},--稀有
    Time={},--{totalTime=总游戏时间, levelTime=当前等级时间}总游戏时间
    Guild={
        --text= text, GuildInfo() 公会信息,
        --guid= guid, 公会 clubFinderGUID 
        data={},-- {guildName, guildRankName, guildRankIndex, realm} = GetGuildInfo('player')
    },
    --Money=钱
    Bank={},--{[itemID]={num=数量,quality=品质}}银行，数据
    region= WoWTools_DataMixin.Player.Region
    --specID 专精
    --itemLevel 装等
    --faction
    --level
    --battleTag
}
]]



local function Settings_Left_Button(self)
    local itemName, itemTexture, itemAtlas, count, r, g, b = List2TypeTab[List2Type].set_button(self)
    self.Name:SetText(itemName or '')
    self.Name:SetTextColor(r or 1, g or 1, b or 1)
    self.Count:SetText(count or '')
    if itemAtlas then
        self.Icon:SetAtlas(itemAtlas)
    else
        self.Icon:SetTexture(itemTexture or 0)
    end
end




local function SetScript_Left_Button(btn)
    if btn.Count2 then
       return
    end

    btn:SetPoint('RIGHT')
    btn.NameFrame:SetPoint('RIGHT')
    btn.NameFrame:SetAlpha(0.5)

    --[[btn.BagTexture= btn:CreateTexture(nil, 'ARTWORK')
    btn.BagTexture:SetSize(12,12)
    btn.BagTexture:SetAtlas('bag-main')
    btn.BagTexture:SetPoint('BOTTOMRIGHT', btn.NameFrame, -2, 2)

    btn.BankTexture= btn:CreateTexture(nil, 'ARTWORK')
    btn.BankTexture:SetSize(12,12)
    btn.BankTexture:SetAtlas('ParagonReputation_Bag')
    btn.BankTexture:SetPoint('BOTTOM', btn.BagTexture, 'TOP')


    btn.WoWTexture= btn:CreateTexture(nil, 'ARTWORK')
    btn.WoWTexture:SetSize(12,12)
    btn.WoWTexture:SetAtlas('glues-characterSelect-iconShop-hover')
    btn.WoWTexture:SetPoint('BOTTOMLEFT', btn.Name, 'TOPLEFT')]]

    --btn.Count:ClearAllPoints()
    --btn.Count:SetPoint('BOTTOMRIGHT', btn.NameFrame, -2, 2)
    --btn.Count:SetPoint('RIGHT', btn.BagTexture, 'LEFT')

    --btn.Count2= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
    --btn.Count2:SetPoint('BOTTOM', btn.BagTexture, 'TOP')
    --btn.Count2:SetPoint('RIGHT', btn.BankTexture, 'LEFT')

    --[[btn.Count3= WoWTools_LabelMixin:Create(btn, {color={r=0,g=0.8,b=1}})
    btn.Count3:SetPoint('BOTTOMLEFT', btn.Name, 'TOPLEFT')]]
    --btn.Count3:SetPoint('LEFT', btn.WoWTexture, 'RIGHT')


    btn.Name:ClearAllPoints()
    btn.Name:SetHeight(0)
    btn.Name:SetPoint('BOTTOMLEFT', btn.NameFrame, 2, 2)
    btn.Name:SetPoint('RIGHT', btn.NameFrame,-2, 0)--, btn.Count, 'LEFT', -2, 0)
    btn.Name:SetWordWrap(false)

    btn.Count:ClearAllPoints()
    btn.Count:SetPoint('TOPRIGHT', btn.NameFrame, -2, -2)
    btn.Count:SetJustifyH('RIGHT')
    btn.Count:SetFontObject('ChatFontNormal')


    btn:SetScript('OnHide', function(self)
        self.data=nil
        Settings_Left_Button(self)
        self:UnregisterEvent('ITEM_DATA_LOAD_RESULT')
    end)

    btn:RegisterEvent('ITEM_DATA_LOAD_RESULT')
    btn:SetScript('OnShow', function(self)
        self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
    end)

    btn:SetScript('OnEvent', function(self, _, itemID, success)
        if success and self.data and self.data.itemID== itemID then
            Settings_Left_Button(self)
        end
    end)

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:SetAlpha(1)
    end)
    btn:SetScript('OnEnter', function(self)
        local data= self.data
        if not data then
            return
        end
        if data.guid then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(WoWTools_UnitMixin:GetFullName(nil, nil, data.guid))
            GameTooltip:AddDoubleLine('Region', (WoWTools_DataMixin.Player.Region~= data.region and '|cnRED_FONT_COLOR:' or '')..(data.region or ''))
            GameTooltip:AddDoubleLine('BattleTag', (WoWTools_DataMixin.Player.BattleTag~= data.battleTag and '|cnRED_FONT_COLOR:' or '')..(data.battleTag or ''))
            GameTooltip:Show()
        else
            WoWTools_SetTooltipMixin:Frame(self, nil, {
                itemID=data.itemID,
                currencyID=data.currencyID,
            })
        end
        self:SetAlpha(0.5)
    end)
end










local function Init_Left_List()
    local findText= (Frame.SearchBox2:GetText() or ''):upper()
    local isFind= findText~=''
    local findID= isFind and tonumber(findText)

    local data, num
    if List2TypeTab[List2Type] then
        data, num= List2TypeTab[List2Type].get_data(isFind, findText, findID)
        num= num and num~=0 and '|A:'..List2TypeTab[List2Type].atlas..':0:0|a'..num
    else
        data= CreateDataProvider()
    end

    Frame.view2:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)

--数量
    Frame.NumLabel2:SetText(num or '')

--头像
    Frame:set_portrait()

    for _, btn in pairs(List2Buttons) do
        List2TypeTab[btn.name].set_num(btn)
    end
end


















































local function Init_Right_List()
    local findText= (Frame.SearchBox:GetText() or ''):upper()
    local isFind= findText~=''
    local num=0
    local findData

    local data = CreateDataProvider()
    for guid, info in pairs(WoWTools_WoWDate) do


        local cnLink, realm, class, cnClass, faction, cnFaction, region, _

        local itemLink= info.Keystone.link
        local fullName= WoWTools_UnitMixin:GetFullName(nil, nil, guid) or '^_^'
        local battleTag= info.battleTag

        if isFind then
            cnLink= WoWTools_HyperLink:CN_Link(itemLink, {isName=true})
            cnLink= cnLink~=itemLink and cnLink or nil

            class, _, _, _, _, _, realm=  GetPlayerInfoByGUID(guid)
            realm= (realm=='' or not realm) and WoWTools_DataMixin.Player.Realm or realm

            cnClass= WoWTools_TextMixin:CN(class)
            cnClass= cnClass~=class and cnClass or nil

            faction= info.faction
            cnFaction= WoWTools_TextMixin:CN(faction)
            region= format('REGION%d', info.region or 0)
        end

        if isFind and (
                itemLink and (
                    itemLink:upper():find(findText)
                    or WEEKLY_REWARDS_MYTHIC_KEYSTONE:upper()==findText
                )
                or (cnLink and cnLink:upper():find(findText))

                or fullName:upper():find(findText)

                or (realm and realm:upper()==findText)

                or (class and class:upper():find(findText))
                or (cnClass and cnClass:upper():find(findText))

                or (faction and faction:upper():find(findText))
                or (cnFaction and cnFaction:upper():find(findText))

                or (battleTag and battleTag:upper()==findText)
                or region==findText

        ) or not isFind then
            local insertData=  {
                guid=guid,
                name= fullName,
                faction=info.faction,
                battleTag= battleTag,
                region= info.region,
                realm= realm,

                itemLink= itemLink,

                score= info.score or 0,
                weekNum= info.weekNum or 0,
                weekLevel= info.weekLevel or 0,

                pve= info.Keystone.weekPvE,
                mythic= info.Keystone.weekMythicPlus,
                world= info.Keystone.weekWorld,
                pvp= info.Keystone.weekPvP,

                specID= info.specID or 0,
                itemLevel= info.itemLevel or 0,
                playerLevel= info.level or 1,
            }

            data:Insert(insertData)

            num= num+1

            if not Frame.guid and guid==WoWTools_DataMixin.Player.GUID or Frame.guid==guid then
                findData= insertData
            end
        end
    end


    data:SetSortComparator(function(v1, v2)
        return v1.itemLevel>v2.itemLevel
            or v1.score> v2.score
            or v1.weekLevel> v2.weekLevel
            or v1.weekNum> v2.weekNum

    end)

    Frame.ScrollBox:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    Frame.NumLabel:SetText(num or '')

--转到以前，指定位置
    if findData then
        Frame.ScrollBox:ScrollToElementData(findData)
        --Frame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
    end

--刷新，列表
    if Frame.guid then
        Init_Left_List()
    end
end














local function Settings_Right_Button(btn, data)
    local col= WoWTools_UnitMixin:GetColor(nil, data.guid)

--玩家，图标
    btn.Icon:SetAtlas(WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil, {reAtlas=true} or ''))
--玩家等级
    btn.PlayerLevelText:SetText(data.playerLevel~=GetMaxLevelForPlayerExpansion() and data.playerLevel or '')
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

--提示，不同战网
    btn.BattleTag:SetText(data.battleTag~=WoWTools_DataMixin.Player.BattleTag and data.battleTag or '')
    btn:SetAlpha(data.battleTag== WoWTools_DataMixin.Player.BattleTag and 1 or 0.5)

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
    if itemName then
        itemName= itemName:match('%[(.-)]') or itemName
        itemName= itemName:match(CHALLENGE_MODE_KEYSTONE_NAME) or itemName:match('钥石：(.+)') or itemName:match('钥石: (.+)') or itemName
    end
    btn.ItemName:SetText(itemName or '')

--背景
    btn.Background:SetAtlas(
        data.faction=='Alliance' and 'Campaign_Alliance'
        or (data.faction=='Horde' and 'Campaign_Horde')
        or 'StoryHeader-BG'
    )

    btn.RaidText:SetText(data.pve or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8') or '')
    btn.DungeonText:SetText(data.mythic or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8') or '')
    btn.WorldText:SetText(data.world or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8') or '')
    btn.PvPText:SetText(data.pvp or (WoWTools_DataMixin.Player.husandro and '|cff8282822/4/8') or '')

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
    btn.Background:SetAlpha(WoWTools_DataMixin.Player.BattleTag~=data.battleTag and 0.5 or 1)
    btn.Background:SetDesaturated(WoWTools_DataMixin.Player.Region~=data.region)


    btn.SelectBg:SetShown(data.guid==Frame.guid)

end










local function OnEnter_BattleTexture(self)
    local data= self:GetParent().data
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddDoubleLine()

    local battleTag= data and data.battleTag
    GameTooltip:AddDoubleLine(
        WoWTools_DataMixin.onlyChinese and '战网昵称' or BATTLETAG,
        (battleTag~=WoWTools_DataMixin.Player.BattleTag and '|cnRED_FONT_COLOR:' or '|cffffffff')
        ..(battleTag or '')
    )
    if battleTag~=WoWTools_DataMixin.Player.BattleTag then
        GameTooltip:AddLine(
            '|A:tokens-guildRealmTransfer-small:0:0|a|cnRED_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '不同战网' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OTHER, COMMUNITY_COMMAND_BATTLENET))
        )
    end

    local curRegion= GetCurrentRegion()
    local region= data and data.region
    if region then
        GameTooltip:AddDoubleLine(
            'Region',
            (region~=curRegion and '|cnRED_FONT_COLOR:' or '|cffffffff')
            ..region
        )
        if region~=curRegion then
            GameTooltip:AddLine(
                '|A:adventureguide-microbutton-alert:0:0|a|cnRED_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '不同地区' or ERR_TRAVEL_PASS_DIFFERENT_REGION)
            )
        end
    end

    if curRegion then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT, ' Region'),
            curRegion
        )
    end
    GameTooltip:Show()
    self:SetAlpha(0.3)
end









local function OnMouseDown_RightButton(self, d)
    if not self.data then
        return
    end
    local guid= self.data.guid

    if d=='LeftButton' then
        Frame.guid= Frame.guid~=guid and guid or nil

    else
        Frame.guid= guid

        MenuUtil.CreateContextMenu(self, function(_, root)
            local isMe= guid==WoWTools_DataMixin.Player.GUID
            local battleTag= self.data.battleTag
            local faction= self.data.faction

            local sub=root:CreateButton(
                WoWTools_DataMixin.Icon.wow2
                ..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
            function()
                StaticPopup_Show('WoWTools_OK',
                    WoWTools_DataMixin.Icon.wow2
                    ..(WoWTools_DataMixin.onlyChinese and '清除WoW数据' or 'Clear WoW data')
                    ..'|n|n'
                    ..(battleTag or '')
                    ..'|n'
                    ..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=faction, reName=true, reRealm=true})
                    ..'|n|n|cnGREEN_FONT_COLOR:'
                    ..(isMe and (WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI) or ''),

                    nil,
                    {SetValue=function()
                        WoWTools_WoWDate[guid]=nil
                        if isMe then
                            WoWTools_Mixin:Reload()
                        else
                            Init_Right_List()
                        end
                    end}
                )
            end)
            sub:SetTooltip(function(tootip)
                if isMe then
                    tootip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
                end
            end)
        end)

        Frame.regon= Frame.guid and self.data.region or nil
    end



    Frame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
    Init_Left_List()
end





















local function Init_Right_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, name

    local all, region, tag= {}, {}, {}

    for guid, info in pairs(WoWTools_WoWDate) do
        name= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true})
        local tab= {name=name or guid, region=info.region, tag=info.battleTag}
        table.insert(all, tab)

        if info.region~=WoWTools_DataMixin.Player.Region then
            table.insert(region, tab)
        end

        if info.battleTag~=WoWTools_DataMixin.Player.BattleTag then
            table.insert(tag, tab)
        end
    end

    local function set_tooltip(tooltip, desc)
        tooltip:AddDoubleLine(
        format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT,  'Region'),
           WoWTools_DataMixin.Player.Region
        )
        tooltip:AddDoubleLine(
           WoWTools_DataMixin.onlyChinese and '战网昵称' or BATTLETAG,
           WoWTools_DataMixin.Player.BattleTag
        )
        for index, info in pairs(desc.data) do
            if index==1 then
                tooltip:AddLine(' ')
            end
            tooltip:AddDoubleLine((info.name or '')..' |cff00ccff'..(info.region or ''), '|cff00ccff'..(info.tag or '').. ' |r('..index)
        end
    end



--清除不同地区
    local regionText= '|A:bags-button-autosort-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '不同地区' or ERR_TRAVEL_PASS_DIFFERENT_REGION)
            ..' #'..#region
    sub= root:CreateButton(
        regionText,
    function()
        StaticPopup_Show('WoWTools_OK',
            regionText,
            nil,
            {SetValue=function()
                for guid, info in pairs(WoWTools_WoWDate) do
                    if info.region~=WoWTools_DataMixin.Player.Region and guid~=WoWTools_DataMixin.Player.GUID then
                        WoWTools_WoWDate[guid]=nil
                    end
                end
            end
        })
        return MenuResponse.Open
    end, region)
    sub:SetTooltip(set_tooltip)

--清除不同战网
    local tagTtext= '|A:bags-button-autosort-up:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '其它战网' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OTHER, COMMUNITY_COMMAND_BATTLENET))
            ..' #'..#tag
    sub= root:CreateButton(
        tagTtext,
    function()
        StaticPopup_Show('WoWTools_OK',
            tagTtext,
            nil,
            {SetValue=function()
                for guid, info in pairs(WoWTools_WoWDate) do
                    if info.battleTag ~=WoWTools_DataMixin.Player.BattleTag and guid~=WoWTools_DataMixin.Player.GUID then
                        WoWTools_WoWDate[guid]=nil
                    end
                end
            end
        })
        return MenuResponse.Open
    end, tag)
    sub:SetTooltip(set_tooltip)


--清除WoW数据
    local allTtext= '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
        ..' #'..#all
    sub= root:CreateButton(
        allTtext,
    function()
        StaticPopup_Show('WoWTools_RestData',
            allTtext
            ..'|n|n|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI),
            nil,
            function()
                WoWTools_WoWDate={}
                WoWTools_Mixin:Reload()
            end
        )
        return MenuResponse.Open
    end, all)
    sub:SetTooltip(set_tooltip)


--重新加载UI
    root:CreateDivider()
    WoWTools_MenuMixin:Reload(root)
end








local function Init_IsMe_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub

    root:CreateButton(
        WoWTools_DataMixin.Icon.Player
        ..WoWTools_DataMixin.Player.col
        ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
    function()
        --Frame.SearchBox:SetText(UnitName('player'))
        Frame.SearchBox:SetText('')
        if Frame.ScrollBox:ScrollToElementDataByPredicate(function(data)
            return data.guid== WoWTools_DataMixin.Player.GUID
        end)
        then
            Frame.guid= WoWTools_DataMixin.Player.GUID
            Frame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
            Init_Left_List()
        end

        return MenuResponse.Open
    end)

    root:CreateDivider()
    root:CreateButton(
        '|T525134:0|t'
        ..(WoWTools_DataMixin.onlyChinese and '史诗钥石' or WEEKLY_REWARDS_MYTHIC_KEYSTONE),
    function()
        Frame.SearchBox:SetText(WEEKLY_REWARDS_MYTHIC_KEYSTONE)
        return MenuResponse.Open
    end)

    local s, c, b= {}, {}, {}
    local bl, lm= 0, 0

    for guid, tab in pairs(WoWTools_WoWDate) do
        local class, englishClass, _, _, _, _, realm=  GetPlayerInfoByGUID(guid)
        realm= (realm=='' or not realm) and WoWTools_DataMixin.Player.Realm or realm

        s[realm]= (s[realm] or 0)+1

        c[class]= {
            num=(c[class] and c[class].num or 0)+1,
            icon= WoWTools_UnitMixin:GetClassIcon(nil, nil, englishClass) or '',
            col= select(5, WoWTools_UnitMixin:GetColor(nil, nil, englishClass)) or ''
        }

        if tab.faction=='Alliance' then
            lm= lm+1
        elseif tab.faction=='Horde' then
            bl= bl+1
        end

        b[tab.battleTag]= (b[tab.battleTag] or 0)+1
    end


    for realm, num in pairs(s) do
        root:CreateButton(
            '|A:tokens-guildRealmTransfer-small:0:0|a'
            ..(WoWTools_DataMixin.Player.Realms[realm] and '|cnGREEN_FONT_COLOR:' or '')
            ..realm..' #'..num,
        function(data)
            Frame.SearchBox:SetText(data.realm)
            return MenuResponse.Open
        end, {realm=realm})
    end
    for battleTag, num in pairs(b) do
        root:CreateButton(
            '|A:tokens-WoW-generic-small:0:0|a'
            ..(WoWTools_DataMixin.Player.BattleTag== battleTag and '|cnGREEN_FONT_COLOR:' or '')
            ..battleTag..' #'..num,
        function(data)
            Frame.SearchBox:SetText(data.battleTag)
            return MenuResponse.Open
        end, {battleTag=battleTag})
    end

    root:CreateDivider()
    for class, tab in pairs(c) do
        root:CreateButton(
            tab.icon
            ..tab.col
            ..WoWTools_TextMixin:CN(class)
            ..' #'
            ..tab.num,
        function(data)
            Frame.SearchBox:SetText(data.class)
            return MenuResponse.Open
        end, {class=class})
    end

    root:CreateDivider()
    root:CreateButton(
        '|A:communities-create-button-wow-horde:0:0|a|cffff2834'
        ..(WoWTools_DataMixin.onlyChinese and '部落' or FACTION_HORDE)
        ..' #'..bl,
    function()
        Frame.SearchBox:SetText('Horde')
        return MenuResponse.Open
    end)

    root:CreateButton(
        '|A:communities-create-button-wow-alliance:0:0|a|cff00adf0'
        ..(WoWTools_DataMixin.onlyChinese and '联盟' or FACTION_ALLIANCE)
        ..' #'..lm,
    function()
        Frame.SearchBox:SetText('Alliance')
        return MenuResponse.Open
    end)

--Region
    local regions={}
    for _, info in pairs(WoWTools_WoWDate) do
        regions[info.region]= (regions[info.region] or 0)+ 1
    end
    root:CreateDivider()
    local curRegion= GetCurrentRegion()
    for r, num in pairs(regions) do
        local isCurRegion= r==WoWTools_DataMixin.Player.Region
        sub=root:CreateButton(
            (isCurRegion and '|cnGREEN_FONT_COLOR:' or '|cffedd100')
            ..(WoWTools_DataMixin.onlyChinese and '地区' or ZONE)
            ..' '..r..' #'..num,
        function(data)
            Frame.SearchBox:SetText('Region'..data.region)
            return MenuResponse.Open
        end, {region=r, isCurRegion=isCurRegion})

        sub:SetTooltip(function(tootip, desc)
            tootip:AddDoubleLine('Region', curRegion)
            if not desc.data.isCurRegion then
                tootip:AddLine(
                    '|cnRED_FONT_COLOR:'
                    ..(WoWTools_DataMixin.onlyChinese and '不同的地区' or ERR_TRAVEL_PASS_DIFFERENT_REGION)
                )
            end
        end)
    end


    WoWTools_MenuMixin:SetScrollMode(root)
end

























local function Init_List()
    Frame= WoWTools_FrameMixin:Create(nil, {
        name='WoWToolsWoWItemListFrame',
        header= WoWTools_DataMixin.Icon.wow2
            ..(WoWTools_DataMixin.onlyChinese and '战网物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS))
    })

    Frame:SetScript('OnHide', function(self)
        self.ScrollBox:RemoveDataProvider()
        self.ScrollBox2:RemoveDataProvider()
    end)

    Frame:SetScript('OnShow', function(self)
        Init_Right_List()
        --self.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
    end)

    Frame.ScrollBox= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollBox:SetPoint('TOPRIGHT', -28, -55)
    Frame.ScrollBox:SetPoint('BOTTOMLEFT', Frame, 'BOTTOM', 0, 13)

    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame.ScrollBox, "TOPRIGHT", 6, -12)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame.ScrollBox, "BOTTOMRIGHT", 6, 12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar, true)

    Frame.SearchBox= WoWTools_EditBoxMixin:Create(Frame, {
        isSearch=true,
        --text= WoWTools_DataMixin.onlyChinese and '角色名称，副本'or (REPORTING_MINOR_CATEGORY_CHARACTER_NAME..', '..INSTANCE)
    })
    Frame.SearchBox:SetPoint('BOTTOMLEFT', Frame.ScrollBox, 'TOPLEFT', 24, 2)
    Frame.SearchBox:SetPoint('RIGHT', Frame, -55, 2)
    Frame.SearchBox:HookScript('OnTextChanged', function()
        Init_Right_List()
    end)

    Frame.IsMe= WoWTools_ButtonMixin:Menu(Frame, {
        size=23,
        atlas= WoWTools_UnitMixin:GetClassIcon(nil, WoWTools_DataMixin.Player.GUID, nil, {reAtlas=true})
    })
    Frame.IsMe:SetPoint('LEFT', Frame.SearchBox, 'RIGHT')
    Frame.IsMe:SetScript('OnLeave', function()
        GameTooltip_Hide()
    end)
    Frame.IsMe:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:SetText(
            '|A:common-search-magnifyingglass:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        )
        GameTooltip:Show()
    end)
    Frame.IsMe:SetupMenu(Init_IsMe_Menu)


    Frame.Menu= WoWTools_ButtonMixin:Menu(Frame, {
        size=23,
        atlas='GM-icon-settings-hover'
    })
    Frame.Menu:SetPoint('LEFT', Frame.IsMe, 'RIGHT')
    Frame.Menu:SetupMenu(Init_Right_Menu)
    WoWTools_TextureMixin:SetButton(Frame.Menu)

--数量
    Frame.NumLabel= WoWTools_LabelMixin:Create(Frame, {color=true})
    Frame.NumLabel:SetPoint('RIGHT', Frame.SearchBox, 'LEFT', -6, 0)


    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsPlayerFrameTemplate', function(self, data)
         if not self:GetScript('OnMouseDown') then
            self:SetScript('OnMouseDown', function(...)
                OnMouseDown_RightButton(...)
            end)
            self.Battle:SetScript('OnLeave', function(frame)
                GameTooltip:Hide()
                frame:SetAlpha(1)
            end)
            self.Battle:SetScript('OnEnter', function(...)
                OnEnter_BattleTexture(...)
            end)
        end
        self.data= data
        Settings_Right_Button(self, data)
    end)












    Frame.ScrollBox2= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollBox2:SetPoint('TOPLEFT', 13, -55)
    Frame.ScrollBox2:SetPoint('BOTTOMRIGHT', Frame, 'BOTTOM', -23, 13)

    Frame.ScrollBar2= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar2:SetPoint("TOPLEFT", Frame.ScrollBox2, "TOPRIGHT", 6, -12)
    Frame.ScrollBar2:SetPoint("BOTTOMLEFT", Frame.ScrollBox2, "BOTTOMRIGHT", 6, 12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar2, true)

    Frame.SearchBox2= WoWTools_EditBoxMixin:Create(Frame, {
        isSearch=true,
        --text= WoWTools_DataMixin.onlyChinese and '角色名称，副本'or (REPORTING_MINOR_CATEGORY_CHARACTER_NAME..', '..INSTANCE)
    })
    Frame.SearchBox2:SetPoint('BOTTOMLEFT', Frame.ScrollBox2, 'TOPLEFT', 29, 2)
    Frame.SearchBox2:SetPoint('BOTTOMRIGHT', Frame.ScrollBox2, 'TOPRIGHT', -23*4, 2)
    Frame.SearchBox2:HookScript('OnTextChanged', function()
        Init_Left_List()
    end)


    Frame.view2 = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox2, Frame.ScrollBar2, Frame.view2)
    Frame.view2:SetElementInitializer('SmallItemButtonTemplate', function(btn, data)
        btn.data= data
        SetScript_Left_Button(btn)
        Settings_Left_Button(btn)
    end)

--[[
    Frame.Menu2= WoWTools_ButtonMixin:Menu(Frame, {
        size=23,
        icon='hide',
    })
    Frame.Menu2:SetPoint('LEFT', Frame.SearchBox2, 'RIGHT')
    Frame.Menu2:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
    end)]]

--头像
    Frame.Portrait=Frame:CreateTexture(nil, 'ARTWORK')
    Frame.Portrait:SetPoint('RIGHT', Frame.SearchBox2, 'LEFT', -4, 0)
    Frame.Portrait:SetSize(23,23)
    function Frame:set_portrait()
        local atlas= WoWTools_UnitMixin:GetRaceIcon(nil, self.guid, nil, {reAtlas=true})
        if atlas then
            self.Portrait:SetAtlas(atlas)
        else
            self.Portrait:SetTexture(0)
        end
    end

    --数量
    Frame.NumLabel2= WoWTools_LabelMixin:Create(Frame, {color=true})
    Frame.NumLabel2:SetPoint('BOTTOMLEFT', Frame.Portrait, 'TOPLEFT')















    local x=0
    for name, data in pairs(List2TypeTab) do
        List2Buttons[name]= WoWTools_ButtonMixin:Cbtn(Frame, {
            name='WoWToolsWoWList2'..name..'Button',
            icon='hide',
            addTexture=true,
            size=23,
        })

        List2Buttons[name].name= name
        List2Buttons[name].tooltip= data.tooltip


        List2Buttons[name].Text= WoWTools_LabelMixin:Create(List2Buttons[name], {color=true})
        List2Buttons[name].Text:SetPoint('BOTTOMRIGHT')

        List2Buttons[name].texture:SetAtlas(data.atlas)

        List2Buttons[name]:SetPoint('LEFT', Frame.SearchBox2, 'RIGHT', x, 0)
        x= x+23
        List2Buttons[name]:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        List2Buttons[name]:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(self.tooltip)
            GameTooltip:Show()
        end)
        List2Buttons[name]:SetScript('OnClick', function(self)
            List2Type= self.name
            Init_Left_List()

            for _, btn in pairs(List2Buttons) do
                local isSelect= List2Type==btn.name
                btn:SetButtonState(isSelect and 'PUSHED' or 'NORMAL', true)
                btn.texture:SetDesaturated(isSelect)
            end
        end)
    end

    List2Buttons[List2Type]:SetButtonState('PUSHED', true)
    List2Buttons[List2Type].texture:SetDesaturated(true)




















    Init_List=function()
        Frame:SetShown(not Frame:IsShown())
    end
end























local function Init()
    if Save().disabled then
        return
    end

    local btn= WoWTools_ButtonMixin:Cbtn(ContainerFrameCombinedBags.CloseButton, {
        name='WoWToolsWoWItemListBagButton',
        atlas='glues-characterSelect-iconShop-hover',
        size=23,
    })
    btn:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT', -23, 0)

    btn:SetScript('OnLeave', function()
        GameTooltip_Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.wow2
            ..(WoWTools_DataMixin.onlyChinese and '战团物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS)))
        GameTooltip:Show()
    end)
    btn:SetScript('OnClick', function()
        Init_List()
    end)
    WoWTools_TextureMixin:SetButton(btn)


if WoWTools_DataMixin.Player.husandro then
    Init_List()
end


    Init=function()
        Init_List()
    end
end




function WoWTools_ItemMixin:Init_WoW_ItemList()
    Init()
end


function WoWTools_ItemMixin:OpenWoWItemListMenu(_, root)--战团，物品列表
    root:CreateButton(
        WoWTools_DataMixin.Icon.wow2
        ..(WoWTools_DataMixin.onlyChinese and '战网物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS)),
    function()
        Init_List()
        return MenuResponse.Open
    end)
end