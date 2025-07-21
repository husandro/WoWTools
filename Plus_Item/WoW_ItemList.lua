--战团，物品列表
--[[local function Save()
    return WoWToolsSave['Plus_ItemInfo'] or {}
end]]






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



local Frame
local CHALLENGE_MODE_KEYSTONE_NAME= CHALLENGE_MODE_KEYSTONE_NAME:gsub('%%s', '(.+)')
local List2Type='Item'
local List2Buttons={}
local TypeTabs= {
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
    set_btn=function(data)
        local itemID= data.itemID
        if not itemID then
            return
        end
        local itemName, itemTexture, itemAtlas, count, r, g, b
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
        for _ in pairs(wowData and wowData.Currency or {}) do
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
    set_btn=function(data)
        local currencyID= data.currencyID
        if not currencyID then
            return
        end
        local itemName, itemTexture, itemAtlas, count, r, g, b
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

        local account= C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0
        num= num+ account
        data:Insert({
            isAccunt= true,
            money=account,
        })

        data:SetSortComparator(function(v1, v2)
            return v1.isAccunt or v1.money> v2.money
        end)

        return data, WoWTools_Mixin:MK(num/10000, 3)
    end,
    set_btn=function(data)
        local money= data.money
        if not money then
            return
        end
        local itemName, itemTexture, itemAtlas, count, r, g, b
        if data.isAccunt then
            itemName= '|cff00ccff'..(WoWTools_DataMixin.onlyChinese and '战团银行' or ACCOUNT_BANK_PANEL_TITLE)..'|r'
            itemAtlas= 'questlog-questtypeicon-account'
        else
            itemName, itemAtlas= Get_Player_Name(data)
        end
        count= WoWTools_Mixin:MK(money/10000, 3)..'|A:Auctioneer:0:0|a'
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
    set_btn=function(data)
        local totalTime= data.totalTime
        if not totalTime then
            return
        end
        local itemName, itemTexture, itemAtlas, count, r, g, b
        itemName, itemAtlas= Get_Player_Name(data)
        count= WoWTools_TimeMixin:SecondsToFullTime(totalTime)
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end,
    set_tips=function(data)
        if data.totalTime then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(format(
                WoWTools_DataMixin.onlyChinese and '总游戏时间：%s' or TIME_PLAYED_TOTAL,
                WoWTools_TimeMixin:SecondsToFullTime(data.totalTime)
            ), nil, nil, nil)
        end
        if data.levelTime then
            GameTooltip:AddLine(format(
                WoWTools_DataMixin.onlyChinese and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL,
                WoWTools_TimeMixin:SecondsToFullTime(data.levelTime)
            ))
        end
    end},





--副本
    ['Instance']= {
    atlas='poi-rift1',
    tooltip=WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE,
    set_num=function(self)
        local guid= Frame.guid
        local data= guid and WoWTools_WoWDate[Frame.guid]
        local num=0
        for _ in pairs(data and data.Instance.ins or {}) do
            num= num+1
        end
        self.Text:SetText(num==0 and '|cff6060600' or num)
    end,
    get_data=function(isFind, findText)
        local data, num= CreateDataProvider(), 0
        local guid= Frame.guid
        local info= guid and WoWTools_WoWDate[Frame.guid]
        for insName, tab in pairs(info and info.Instance.ins or {}) do--[名字]={[难度]=已击杀数}
            local text
            for difficuly, killNum in pairs(tab) do
                text= (text and text..' ' or '')..WoWTools_MapMixin:GetDifficultyColor(difficuly)..killNum
            end
            if text then
                if isFind and (text:upper():find(findText) or insName:upper():find(findText))
                    or not isFind
                then
                    data:Insert({
                        insName= WoWTools_TextMixin:CN(insName),
                        killText= text,
                    })
                    num=num+1
                end
            end
        end
        return data, num
    end,
    set_btn=function(data)
        local itemName, itemTexture, itemAtlas, count, r, g, b
        itemName= data.insName
        count= data.killText
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end},





--稀有
    ['Rare']= {
    atlas='UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star',
    tooltip=WoWTools_DataMixin.onlyChinese and '稀有' or MAP_LEGEND_RARE,
    set_num=function(self)
        local guid= Frame.guid
        local data= guid and WoWTools_WoWDate[Frame.guid]
        local num=0
        for _ in pairs(data and data.Rare.boss or {}) do
            num= num+1
        end
        self.Text:SetText(num==0 and '|cff6060600' or num)
    end,
    get_data=function(isFind, findText)
        local data, num= CreateDataProvider(), 0
        local guid= Frame.guid
        local info= guid and WoWTools_WoWDate[Frame.guid]
        local rare, rare2
        for name in pairs(info and info.Rare.boss or {}) do--[name]= UnitGUID('target')
            num= num+1
            name= '|cff606060'..num..'|r'..WoWTools_TextMixin:CN(name)
            if select(2, math.modf(num/2))~=0 then
                rare= (rare and ' ' or '')..name
            else
                rare2= (rare2 and ' ' or '')..name
            end
        end
        if rare then
            if isFind and (
                    rare and rare:upper():find(findText)
                    or (rare2 and rare:upper():find(findText))
                ) or not isFind
            then
                data:Insert({
                    rare= rare,
                    rare2= rare2,
                    rareTab=info.Rare.boss
                })
            end
        end
        return data, num
    end,
    set_btn=function(data)
        local itemName, itemTexture, itemAtlas, count, r, g, b
        itemName= data.rare
        count= data.rare2
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end,
    set_tips=function(data)
        local index=0
        local col
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED))
        for name in pairs(data.rareTab or {}) do
            index= index+1
            col= select(2, math.modf(index/2))~=0 and '|cff00ccff' or '|cffff8000'
            GameTooltip:AddDoubleLine(col..WoWTools_TextMixin:CN(name), col..'('..index)
        end
    end},










--世界首领
    ['Worldboss']= {
    atlas='vignettekillboss',
    tooltip=WoWTools_DataMixin.onlyChinese and '世界首领' or MAP_LEGEND_WORLDBOSS,
    set_num=function(self)
        local guid= Frame.guid
        local data= guid and WoWTools_WoWDate[Frame.guid]
        local num=0
        for _ in pairs(data and data.Worldboss.boss or {}) do
            num= num+1
        end
        self.Text:SetText(num==0 and '|cff6060600' or num)
    end,
    get_data=function(isFind, findText)
        local data, num= CreateDataProvider(), 0
        local guid= Frame.guid
        local info= guid and WoWTools_WoWDate[Frame.guid]
        local boos, boos2
        for name in pairs(info and info.Worldboss.boss  or {}) do--[name]= id
            num= num+1
            name= '|cff606060'..num..'|r'..WoWTools_TextMixin:CN(name)
            if select(2, math.modf(num/2))~=0 then
                boos= (boos and boos..' ' or '')..name
            else
                boos2= (boos2 and boos2..' ' or '')..name
            end
        end
        if boos then
            if isFind and (
                    boos and boos:upper():find(findText)
                    or (boos2 and boos:upper():find(findText))
                ) or not isFind
            then
                data:Insert({
                    boos= boos,
                    boos2= boos2,
                    boosTab=info.Worldboss.boss
                })
            end
        end
        return data, num
    end,
    set_btn=function(data)
        local itemName, itemTexture, itemAtlas, count, r, g, b
        itemName= data.boos
        count= data.boos2
        return itemName, itemTexture, itemAtlas, count, r, g, b
    end,
    set_tips=function(data)
        local index=0
        local col
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED))
        for name in pairs(data.boosTab or {}) do
            index= index+1
            col= select(2, math.modf(index/2))~=0 and '|cff00ccff' or '|cffff8000'
            GameTooltip:AddDoubleLine(col..WoWTools_TextMixin:CN(name), col..'('..index)
        end
    end},
}

































local function Settings_Left_Button(self)
    local itemName, itemTexture, itemAtlas, count, r, g, b
    if self.data then
        itemName, itemTexture, itemAtlas, count, r, g, b= TypeTabs[List2Type].set_btn(self.data)
    end
    self.Name:SetText(itemName or '')
    self.Name:SetTextColor(r or 1, g or 1, b or 1)
    self.Count:SetText(count or '')
    if itemAtlas then
        self.Icon:SetAtlas(itemAtlas)
    else
        self.Icon:SetTexture(itemTexture or 0)
    end
end


local function OnEnter_Left_Button(self)
    self:SetAlpha(0.5)
    local data= self.data
    if not data then
        return
    end

    if data.itemID or data.currencyID then
            WoWTools_SetTooltipMixin:Frame(self, nil, {
            itemID=data.itemID,
            currencyID=data.currencyID,
        })
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    if data.guid then
        local r,g,b= select(2, WoWTools_UnitMixin:GetColor(nil, data.guid))
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_UnitMixin:GetFullName(nil, nil, data.guid), r,g,b)
        GameTooltip:AddDoubleLine('Region', (WoWTools_DataMixin.Player.Region~= data.region and '|cnRED_FONT_COLOR:' or '')..(data.region or ''), r,g,b, r,g,b)
        GameTooltip:AddDoubleLine('BattleTag', (WoWTools_DataMixin.Player.BattleTag~= data.battleTag and '|cnRED_FONT_COLOR:' or '')..(data.battleTag or ''), r,g,b, r,g,b)
    end

    if TypeTabs[List2Type] and TypeTabs[List2Type].set_tips then
        TypeTabs[List2Type].set_tips(data)
    end

    GameTooltip:Show()
end












local function SetScript_Left_Button(btn)
    if btn.Count2 then
       return
    end

    btn:SetPoint('RIGHT')
    btn.NameFrame:SetPoint('RIGHT')
    btn.NameFrame:SetTexture(0)
    btn.NameFrame:SetColorTexture(0, 0, 0, 0.3)

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

    btn:SetScript('OnShow', function(self)
        if List2Type=='Item' then
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
        end
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
        OnEnter_Left_Button(self)
    end)
end










local function Init_Left_List()
    local findText= (Frame.SearchBox2:GetText() or ''):upper()
    local isFind= findText~=''
    local findID= isFind and tonumber(findText)

    local data, num
    if TypeTabs[List2Type] then
        data, num= TypeTabs[List2Type].get_data(isFind, findText, findID)
        num= '|A:'..TypeTabs[List2Type].atlas..':0:0|a'..(num or 0)
    else
        --data= CreateDataProvider()
    end

    Frame.view2:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)

--数量
    Frame.NumLabel2:SetText(num or '')

--头像
    Frame:set_portrait()

    for _, btn in pairs(List2Buttons) do
        TypeTabs[btn.name].set_num(btn)
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

                guild= info.Guild or {}
            }

            data:Insert(insertData)

            num= num+1

            if not Frame.guid and guid==WoWTools_DataMixin.Player.GUID or Frame.guid==guid then
                findData= insertData
            end
        end
    end


    data:SetSortComparator(function(v1, v2)
        return v1.guid==WoWTools_DataMixin.Player.GUID
            or v1.itemLevel>v2.itemLevel
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
    local r,g,b= col.r, col.g, col.b
--玩家，图标
    btn.Icon:SetAtlas(WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil, {reAtlas=true} or ''))

--玩家等级
    btn.PlayerLevelText:SetText(data.playerLevel~=GetMaxLevelForPlayerExpansion() and data.playerLevel or '')
    btn.PlayerLevelText:SetTextColor(col.r, col.g, col.b)

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
    --btn:SetAlpha(data.battleTag== WoWTools_DataMixin.Player.BattleTag and 1 or 0.5)
    btn.BattleTag:SetTextColor(r,g,b)

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
            (item>6 and '|cnGREEN_FONT_COLOR:' or col.hex)
            ..data.itemLevel
        )
    else

        btn.ItemLevelText:SetText('')
    end

--公会信息
    local guild= data.guild
    local guidName= guild.data[1]
    if guidName then--SetLargeGuildTabardTextures(unit, emblemTexture, backgroundTexture, borderTexture, tabardData)
        guidName=WoWTools_TextMixin:sub(guidName, 12, 24)
    end
    btn.Guild:SetShown(guidName)
    btn.GuildText:SetText(guidName or '')
    btn.GuildText:SetTextColor(r,g,b)

--钥石，名称
    local itemName= WoWTools_HyperLink:CN_Link(data.itemLink, {isName=true})
    if itemName then
        itemName= itemName:match('%[(.-)]') or itemName
        itemName= itemName:match(CHALLENGE_MODE_KEYSTONE_NAME) or itemName:match('钥石：(.+)') or itemName:match('钥石: (.+)') or itemName
    end
    btn.ItemName:SetText(itemName or '')
    btn.ItemName:SetTextColor(r,g,b)

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

    btn.RaidText:SetTextColor(r,g,b)
    btn.DungeonText:SetTextColor(r,g,b)
    btn.WorldText:SetTextColor(r,g,b)
    btn.PvPText:SetTextColor(r,g,b)

--分数
    btn.ScoreText:SetText(
        WoWTools_ChallengeMixin:KeystoneScorsoColor(data.score)
        or ''
    )
--本周次数
    btn.WeekNumText:SetText(
        data.weekNum==0 and '' or data.weekNum
    )
    btn.WeekNumText:SetTextColor(r,g,b)

--本周最高
    btn.WeekLevelText:SetText(
        data.weekLevel==0 and '' or data.weekLevel
    )
    btn.WeekLevelText:SetTextColor(r,g,b)

--背景
    btn.Background:SetAlpha(WoWTools_DataMixin.Player.BattleTag~=data.battleTag and 0.5 or 1)
    btn.Background:SetDesaturated(WoWTools_DataMixin.Player.Region~=data.region)

    btn.SelectBg:SetShown(data.guid==Frame.guid)
end










local function OnEnter_BattleTexture(self)
    local data= self:GetParent().data
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()

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

local function OnEntre_GuildText(self)
    local p= self:GetParent()
    local data= p.data and p.data.guild
    if not data then
        return
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    if data.data then
        GameTooltip:AddLine(data.data[1], data.data[4])
        GameTooltip:AddDoubleLine(data.data[2], data.data[3])
    end
    GameTooltip:AddLine(data.text, nil, nil, nil, true)
    if data.link then
        GameTooltip:AddLine(
            '|cff00ccff'
            ..(WoWTools_DataMixin.onlyChinese and '分享链接至聊天栏' or CLUB_FINDER_LINK_POST_IN_CHAT)
            ..WoWTools_DataMixin.Icon.left
        )
    end
    GameTooltip:Show()
    self:SetAlpha(0.3)
end

local function OnMouseDown_GuildText(self)
    local p= self:GetParent()
    local data= p.data and p.data.guild
    if not data or not data.link then
        return
    end
    WoWTools_ChatMixin:Chat(data.link,
        nil,
        true--ChatEdit_GetActiveWindow() and true or false
    )
end



local function OnMouseDown_RightButton(self, d)
    if not self.data then
        return
    end
    local guid= self.data.guid
    Frame.guid= guid

    if d=='RightButton' then
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


    end

    Frame.regon= Frame.guid and self.data.region or nil

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
        tooltip:AddLine('|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2))
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
    root:CreateSpacer()
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

    Frame.guid=WoWTools_DataMixin.Player.GUID

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

    Frame.SearchBox= WoWTools_EditBoxMixin:Create(Frame, {isSearch=true})
    Frame.SearchBox:SetPoint('BOTTOMLEFT', Frame.ScrollBox, 'TOPLEFT', 24, 4)
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
            self.GuildText:SetScript('OnEnter', function(...)
                OnEntre_GuildText(...)
            end)
            self.GuildText:SetScript('OnMouseDown', function(...)
                OnMouseDown_GuildText(...)
            end)

            OnEntre_GuildText(self)
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
    --Frame.SearchBox2:SetPoint('BOTTOMRIGHT', Frame.ScrollBox2, 'TOPRIGHT', -23*4, 2)
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
















    local last
    for name, data in pairs(TypeTabs) do
        List2Buttons[name]= WoWTools_ButtonMixin:Cbtn(Frame, {
            name='WoWToolsWoWList2'..name..'Button',
            icon='hide',
            --addTexture=true,
            size=23,
        })
        List2Buttons[name].texture=List2Buttons[name]:CreateTexture(nil, 'BORDER')
        List2Buttons[name].texture:SetPoint('CENTER')
        List2Buttons[name].texture:SetSize(23,23)

        List2Buttons[name].name= name
        List2Buttons[name].tooltip= data.tooltip


        List2Buttons[name].Text= WoWTools_LabelMixin:Create(List2Buttons[name], {color={r=1,g=1,b=1}})
        List2Buttons[name].Text:SetPoint('BOTTOMRIGHT')

        List2Buttons[name].texture:SetAtlas(data.atlas)

        if last then
            List2Buttons[name]:SetPoint('RIGHT', last, 'LEFT', -2, 0)
        else
            List2Buttons[name]:SetPoint('BOTTOMRIGHT', Frame.ScrollBox2, 'TOPRIGHT')
        end
        --List2Buttons[name]:SetPoint('LEFT', Frame.SearchBox2, 'RIGHT', x, 0)
        --x= x+23
        List2Buttons[name]:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        List2Buttons[name]:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(self.tooltip)
            GameTooltip:Show()
        end)
        List2Buttons[name]:SetScript('OnMouseDown', function(self)
            List2Type= self.name
            Init_Left_List()

            for _, btn in pairs(List2Buttons) do
                local isSelect= List2Type==btn.name
                --btn:SetButtonState(isSelect and 'PUSHED' or 'NORMAL', true)
                btn.texture:SetDesaturated(isSelect)
                btn.texture:SetScale(isSelect and 0.5 or 1)
            end
        end)
        last=List2Buttons[name]
    end






    --List2Buttons[List2Type]:SetButtonState('PUSHED', true)
    List2Buttons[List2Type].texture:SetDesaturated(true)
    List2Buttons[List2Type].texture:SetScale(0.5)
    Frame.SearchBox2:SetPoint('RIGHT', last, 'LEFT', -2, 0)






    Init_List=function()
        Frame:SetShown(not Frame:IsShown())
    end
end





















local function Init()
    local btn= WoWTools_ItemMixin:Create_WoWButton(ContainerFrameCombinedBags.CloseButton)
    btn:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT', -23, 0)

    MainMenuBarBackpackButton:HookScript('OnEnter', function()
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.wow2
            ..'|cnGREEN_FONT_COLOR:<'
            ..(WoWTools_DataMixin.onlyChinese and '战团物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS))
            ..WoWTools_DataMixin.Icon.mid
            ..'>'
        )
        GameTooltip:Show()
    end)
    MainMenuBarBackpackButton:EnableMouseWheel(true)
    MainMenuBarBackpackButton:SetScript('OnMouseWheel', function(_, d)
        if d==1 then
            if not Frame then
                Init_List()
            else
                Frame:SetShown(true)
            end
        elseif Frame then
            Frame:SetShown(false)
        end
    end)


    Init=function()
        Init_List()
    end
end




function WoWTools_ItemMixin:Init_WoW_ItemList()
    Init()
end















function WoWTools_ItemMixin:Create_WoWButton(frame, name)
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {
        name=name,
        atlas='glues-characterSelect-iconShop-hover',
        size=23,
    })
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
    return btn
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