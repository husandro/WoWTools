--战团，物品列表
local function Save()
    return WoWToolsSave['Plus_ItemInfo'] or {}
end

local Frame









local function Set_Left_Button(btn)
    if btn.Count2 then
       return
    end

    btn:SetPoint('RIGHT')
    btn.NameFrame:SetPoint('RIGHT')
    btn.NameFrame:SetAlpha(0.5)

    btn.BagTexture= btn:CreateTexture(nil, 'ARTWORK')
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
    btn.WoWTexture:SetPoint('BOTTOMLEFT', btn.Name, 'TOPLEFT')

    btn.Count:ClearAllPoints()
    btn.Count:SetPoint('RIGHT', btn.BagTexture, 'LEFT')

    btn.Count2= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
    btn.Count2:SetPoint('RIGHT', btn.BankTexture, 'LEFT')

    btn.Count3= WoWTools_LabelMixin:Create(btn, {color={r=0,g=0.8,b=1}})
    btn.Count3:SetPoint('LEFT', btn.WoWTexture, 'RIGHT')


    btn.Name:ClearAllPoints()
    btn.Name:SetPoint('BOTTOMLEFT', btn.NameFrame, 2, 2)
    btn.Name:SetPoint('RIGHT', btn.Count, 'LEFT', -2, 0)
    btn.Name:SetHeight(0)
    btn.Name:SetWordWrap(false)



    function btn:settings()
        local itemName, itemQuality, itemTexture, _
        local itemID= self.itemID
        local wow
        if itemID then
            itemName, _, itemQuality, _, _, _, _, _, _, itemTexture= C_Item.GetItemInfo(itemID)

            itemName= WoWTools_TextMixin:CN(itemName, {itemID=itemID, isName=true}) or itemID
            itemTexture= itemTexture or C_Item.GetItemIconByID(itemID)

            wow= WoWTools_ItemMixin:GetWoWCount(itemID)
            wow= wow>0 and WoWTools_Mixin:MK(wow, 3) or nil

            local r,g,b= C_Item.GetItemQualityColor(itemQuality or 1)
            self.Name:SetTextColor(r or 1, g or 1, b or 1)
        end

        local bag= self.bag and self.bag>0 and WoWTools_Mixin:MK(self.bag, 3)
        local bank= self.bank and self.bank>0 and WoWTools_Mixin:MK(self.bank, 3)


        self.Name:SetText(itemName or '')
        self.Icon:SetTexture(itemTexture or 0)
        self.Count:SetText(bag or '')
        self.Count2:SetText(bank or '')
        self.Count3:SetText(wow or '')
        self.BagTexture:SetShown(bag)
        self.BankTexture:SetShown(bank)
        self.WoWTexture:SetShown(wow)
        --self.Level:SetText(itemLevel or '')
    end

    btn:SetScript('OnHide', function(self)
        self.itemID= nil
        self.bag= nil
        self.bank= nil
        self:settings()
        self:UnregisterEvent('ITEM_DATA_LOAD_RESULT')
    end)

    btn:RegisterEvent('ITEM_DATA_LOAD_RESULT')
    btn:SetScript('OnShow', function(self)
        self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
    end)

    btn:SetScript('OnEvent', function(self, _, itemID, success)
        if success and self.itemID== itemID then
            self:settings()
        end
    end)

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:SetAlpha(1)
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Frame(self)
        self:SetAlpha(0.5)
    end)
end







local function Set_Left_List()
    local findText= (Frame.SearchBox2:GetText() or ''):upper()
    local isFind= findText~=''
    local findItemID= isFind and tonumber(findText)
    local num=0

    local data = CreateDataProvider()
    local info= WoWTools_WoWDate[Frame.guid] and WoWTools_WoWDate[Frame.guid].Item or {}
    for itemID, tab in pairs(info) do
        WoWTools_Mixin:Load({id=itemID, type='item'})
        local name, cnName
        if isFind then
            name= C_Item.GetItemNameByID(itemID)
            cnName= WoWTools_TextMixin:CN(name, {itemID=itemID, isName=true})
            cnName= cnName and cnName~=name and cnName:upper() or nil
            name=  name and name:upper()
        end

        if isFind and (itemID==findItemID or (name and name:find(findText)) or cnName and cnName:find(findText))
            or not isFind
        then
            data:Insert({
                itemID= itemID,
                bag= tab.bag or 0,
                bank= tab.bank or 0,
                quality= C_Item.GetItemQualityByID(itemID) or 1,
            })
            num=num+1
        end
    end

    data:SetSortComparator(function(v1, v2)
        return v1.quality==v2.quality and v1.itemID> v2.itemID or v1.quality>v2.quality
    end)
    Frame.view2:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)

--数量
    Frame.NumLabel2:SetText(num or '')
--头像
    Frame:set_portrait()
end





local function Init_Left_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
end












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
            name:gsub('-'..WoWTools_DataMixin.Player.realm, '')--取得全名
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
    btn.Background:SetAlpha(0.75)

--数据
    btn.itemLink= data.itemLink
    btn.battleTag= data.battleTag
    btn.specID= data.specID
    btn.itemLevel= data.itemLevel
    btn.guid= data.guid

    --btn:SetAlpha(btn.itemLink and 1 or 0.5)
    btn.SelectBg:SetShown(data.guid==Frame.guid)
    btn:SetAlpha(data.battleTag== WoWTools_DataMixin.Player.BattleTag and 1 or 0.5)


    if btn:GetScript('OnMouseDown') then
        return
    end

    btn:SetScript('OnMouseDown', function(self)
        Frame.guid= Frame.guid~=self.guid and self.guid or nil
        Frame.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition)
        Set_Left_List()
    end)

    btn:SetScript('OnLeave', function(self)
        self.Select:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self.Select:Show()
    end)
end






















local function Set_List()
    local findText= (Frame.SearchBox:GetText() or ''):upper()
    local isFind= findText~=''
    local num=0
    local findData

    local data = CreateDataProvider()
    for guid, info in pairs(WoWTools_WoWDate) do


        local cnLink, realm, class, cnClass, faction, cnFaction, _

        local itemLink= info.Keystone.link
        local fullName= WoWTools_UnitMixin:GetFullName(nil, nil, guid) or '^_^'
        local battleTag= info.battleTag

        if isFind then
            cnLink= WoWTools_HyperLink:CN_Link(itemLink, {isName=true})
            cnLink= cnLink~=itemLink and cnLink or nil

            class, _, _, _, _, _, realm=  GetPlayerInfoByGUID(guid)
            realm= (realm=='' or not realm) and WoWTools_DataMixin.Player.realm or realm

            cnClass= WoWTools_TextMixin:CN(class)
            cnClass= cnClass~=class and cnClass or nil

            faction= info.faction
            cnFaction= WoWTools_TextMixin:CN(faction)
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

        ) or not isFind then
            local insertData=  {
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

                battleTag= battleTag,
                specID= info.specID or 0,
                itemLevel= info.itemLevel or 0
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
    end

--刷新，列表
    if Frame.guid then
        Set_Left_List()
    end
end















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    
end








local function Init_IsMe_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    root:CreateButton(
        WoWTools_DataMixin.Icon.Player
        ..WoWTools_DataMixin.Player.col
        ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
    function()
        --Frame.SearchBox:SetText(UnitName('player'))
        Frame.ScrollBox:ScrollToElementData(function(_,data)
            return data.guid== WoWTools_DataMixin.Player.GUID
        end)
        return MenuResponse.Open
    end)

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
        realm= (realm=='' or not realm) and WoWTools_DataMixin.Player.realm or realm

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

    root:CreateDivider()
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
        Set_List()
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
        Set_List()
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
    Frame.Menu:SetupMenu(Init_Menu)
    WoWTools_TextureMixin:SetButton(Frame.Menu)

--数量
    Frame.NumLabel= WoWTools_LabelMixin:Create(Frame, {color=true})
    --Frame.NumLabel:SetPoint('CENTER', Frame.Menu)
    Frame.NumLabel:SetPoint('RIGHT', Frame.SearchBox, 'LEFT', -6, 0)


    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsKeystoneButtonTemplate', Initializer)












    Frame.ScrollBox2= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollBox2:SetPoint('TOPLEFT', 13, -55)
    Frame.ScrollBox2:SetPoint('BOTTOMRIGHT', Frame, 'BOTTOM', -23, 13)

    Frame.ScrollBar2= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar2:SetPoint("TOPLEFT", Frame.ScrollBox2, "TOPRIGHT", 6, -12)
    Frame.ScrollBar2:SetPoint("BOTTOMLEFT", Frame.ScrollBox2, "BOTTOMRIGHT", 6, 12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar2)--, true)

    Frame.SearchBox2= WoWTools_EditBoxMixin:Create(Frame, {
        isSearch=true,
        --text= WoWTools_DataMixin.onlyChinese and '角色名称，副本'or (REPORTING_MINOR_CATEGORY_CHARACTER_NAME..', '..INSTANCE)
    })
    Frame.SearchBox2:SetPoint('BOTTOMLEFT', Frame.ScrollBox2, 'TOPLEFT', 29, 2)
    Frame.SearchBox2:SetPoint('BOTTOMRIGHT', Frame.ScrollBox2, 'TOPRIGHT', -32, 2)
    Frame.SearchBox2:HookScript('OnTextChanged', function()
        Set_Left_List()
    end)

    Frame.Menu2= WoWTools_ButtonMixin:Menu(Frame, {
        size=23,
        icon='hide',
    })
    Frame.Menu2:SetPoint('LEFT', Frame.SearchBox2, 'RIGHT')
    Frame.Menu2:SetupMenu(Init_Left_Menu)

--数量
    Frame.NumLabel2= WoWTools_LabelMixin:Create(Frame, {color=true})
    Frame.NumLabel2:SetPoint('CENTER', Frame.Menu2)
    


    Frame.view2 = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox2, Frame.ScrollBar2, Frame.view2)
    Frame.view2:SetElementInitializer('SmallItemButtonTemplate', function(self, data)
        Set_Left_Button(self)
        self.itemID= data.itemID
        self.bag= data.bag
        self.bank= data.bank

        self:settings()
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