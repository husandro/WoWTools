--战团，物品列表
local Frame




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

    --btn:SetAlpha(btn.itemLink and 1 or 0.5)
    btn.SelectBg:SetShown(data.guid==Frame.guid)
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
    local findText= (Frame.SearchBox:GetText() or ''):upper()

    local isFind= findText~=''
    local num=0

    local data = CreateDataProvider()
    for guid, info in pairs(WoWTools_WoWDate) do
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


    data:SetSortComparator(function(...) Sort_Order(...) end)

    Frame.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)

    Frame.SearchBox:SetShown(num>5)
    Frame.Menu:SetShown(num>0)
    Frame.NumLabel:SetText(num>0 and num or '')
end




local function Init_Menu(self, root)
    
end


local function Init_List()

    Frame= WoWTools_FrameMixin:Create(nil, {
        name='WoWToolsWoWItemListFrame',
        header= WoWTools_DataMixin.Icon.wow2..(WoWTools_DataMixin.onlyChinese and '战团物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS))
    })

    Frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.view:SetDataProvider(CreateDataProvider())
    end)

    Frame:SetScript('OnShow', function(self)
        self:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        Set_List()
    end)
    Frame:SetScript('OnEvent', function()
        Set_List()
    end)



    Frame.ScrollBox= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollBox:SetPoint('TOPRIGHT', -28, -55)
    Frame.ScrollBox:SetPoint('BOTTOMLEFT', Frame, 'BOTTOM', 0, 3)
    
    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame.ScrollBox, "TOPRIGHT", 6,-12)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame.ScrollBox, "BOTTOMRIGHT", 6,12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar)--, true)

    



--SearchBox
    Frame.SearchBox= WoWTools_EditBoxMixin:Create(Frame, {
        isSearch=true,
    })
    Frame.SearchBox:SetPoint('BOTTOMLEFT', Frame.ScrollBox, 'TOPLEFT', 4, 2)
    Frame.SearchBox:SetPoint('RIGHT', Frame, -32, 2)
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





    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsKeystoneButtonTemplate', function(...) Initializer(...) end)

    Frame.Menu= WoWTools_ButtonMixin:Menu(Frame, {
        size=23,
        icon='hide',
    })
    Frame.Menu:SetPoint('LEFT', Frame.SearchBox, 'RIGHT')
    Frame.Menu:SetupMenu(function(...)
        Init_Menu(...)
    end)


--数量
    Frame.NumLabel= WoWTools_LabelMixin:Create(Frame, {color=true})
    Frame.NumLabel:SetPoint('CENTER', Frame.Menu)



    Init_List=function()
        Frame:SetShown(not Frame:IsShown())
    end
end























local function Init()
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

    Init=function()end
end




function WoWTools_ItemMixin:Init_WoW_ItemList()
    Init()
end


function WoWTools_ItemMixin:OpenWoWItemListMenu(frame, root)--战团，物品列表
    root:CreateButton(
        WoWTools_DataMixin.Icon.wow2
        ..(WoWTools_DataMixin.onlyChinese and '战团物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS)),
    function()
        Init_List()
        return MenuResponse.Open
    end)
end