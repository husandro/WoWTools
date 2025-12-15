
--https://www.wowhead.com/cn/spell=431280/瞬息全战团地图
local SpellID= 431280

local Tab={
    --{itemID=228412, achievements={16334, 19309, 17766, 16761, 17739, 16363, 16336, 15394}},--巨龙群岛探路者 侦察地图：巨龙群岛的天空

    {itemID=187869, achievements={14663, 14303, 14304, 14305, 14306}},--暗影界

    {itemID=187875, achievements={10665,10666, 10667, 10668, 10669, 11543}},--破碎群岛

    {itemID=187900, achievements={12558, 12556, 13776, 12557, 12559, 13712, 12560, 12561}},--库尔提拉斯和赞达拉 侦察地图：库尔提拉斯和赞达拉的奇景

    {itemID=187895, achievements={8938, 8939, 8940, 8941, 8937, 8942, 10260}},--德拉诺

    {itemID=187896, achievements={6977, 6975, 6976, 6979, 6351, 6978, 6969}},--潘达利亚旅行指南

    {itemID=187897, achievements={4864, 4863, 4866, 4865, 4825}},--大灾变

    {itemID=187898, achievements={1267, 1264, 1268, 1269, 1265, 1266, 1263, 1457, 1270}},--诺森德

    {itemID=187899, achievements={865, 862, 866, 843, 864, 867, 863}},--外域

}

if WoWTools_DataMixin.Player.Faction=='Alliance' then
    --LM
    table.insert(Tab, {itemID=150743, achievements={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860}})--卡利姆多
    table.insert(Tab, {itemID=150746, achievements={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868}})--东部王国

elseif WoWTools_DataMixin.Player.Faction=='Horde' then
    --BL
    table.insert(Tab, {itemID=150744, achievements={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860}})--卡利姆多
    table.insert(Tab, {itemID=150745, achievements={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868}})--东部王国
end


local addName

local P_Save={
    no={
        --[guid]=true
    },
    --maxLevelIsDisabled= WoWTools_DataMixin.Player.husandro,
}

local function Save()
    return WoWToolsSave['Tools_MapToy']
end


















local function Is_Completed(tab)
    WoWTools_DataMixin:Load(tab.itemID, 'item')

    local num= 0
    local isNotChecked
    local new={}
    for _, achievementID in pairs(tab.achievements) do
        local _, name, _, _, _, _, _, _, _, icon, _, _, wasEarnedByMe= GetAchievementInfo(achievementID)
        if name then
            if not wasEarnedByMe then
                num= num+1--没完成
            end
        else
            isNotChecked=true--没发现，数据
        end
        table.insert(new, {
            achievementID= achievementID,
            name=name,
            icon=icon,
            wasEarnedByMe=wasEarnedByMe
        })
    end

    return {
        itemID= tab.itemID,
        hasToy= C_ToyBox.GetToyInfo(tab.itemID) and PlayerHasToy(tab.itemID) or C_Item.GetItemCount(tab.itemID)>0,--没收集 ==false
        num=num,--没完成，数量
        isNotChecked=isNotChecked,--没数据 ==nil
        data=new,
    }
end












































local function Init_Menu(self, root)
    WoWTools_DataMixin:Load(SpellID, 'spell')

    local sub, sub2
    for _, info in pairs(Tab) do
        local new= Is_Completed(info)

        local col=  new.isNotChecked==nil and new.num==0 and '|cff626262'
                    or (new.hasToy==false and '|cnWARNING_FONT_COLOR:')
                    or ''

        local name= WoWTools_ItemMixin:GetName(new.itemID)

        local num=(new.isNotChecked==nil and
                    (new.num>0 and ' |cnGREEN_FONT_COLOR:')
                    or (new.name==0 and ' |cff626262')
                    or ' '
                )
                ..(new.isNotChecked==nil and new.num or '')


        sub= root:CreateCheckbox(
            col..name..num,
        function(data)
            return data.itemID==self.itemID
        end, function(data)
            self:settings(data.itemID)
        end, {itemID=info.itemID})

        WoWTools_SetTooltipMixin:Set_Menu(sub)


        for index, tab in pairs(new.data) do
            sub2=sub:CreateButton(
                index..') '
                ..(tab.wasEarnedByMe==true and '|cff626262' or '')
                ..'|T'..(tab.icon or 0)..':0|t'
                ..(WoWTools_TextMixin:CN(tab.name) or tab.achievementID)
                ..(tab.wasEarnedByMe==true and '|A:common-icon-checkmark:0:0|a' or ''),
            function(data)
                self:settings(data.itemID)
                return MenuResponse.Open
            end,
            {itemID=tab.itemID, achievementID=tab.achievementID})
            sub2:SetTooltip(function(tooltip, description)
                tooltip:SetAchievementByID(description.data.achievementID)
            end)
        end
    end

    sub= root:CreateCheckbox(
        WoWTools_SpellMixin:GetName(SpellID),
    function()
        return self.spellID==SpellID
    end, function()
        self:settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:SetSpellByID(SpellID)
    end)

    local tab=CopyTable(Save().no)
    tab[WoWTools_DataMixin.Player.GUID]= true

    root:CreateDivider()
    sub= WoWTools_ToolsMixin:OpenMenu(root, WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)

    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)

    for guid in pairs(tab) do
        sub2=sub:CreateCheckbox(
            WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true}),
        function(data)
            return Save().no[data]
        end, function(data)
            Save().no[data]= not Save().no[data] and true or nil
        end, guid)
    end

    sub:CreateDivider()


    sub2=sub:CreateCheckbox(
        format('%s = %d %s',
            (WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE),
            GetMaxLevelForLatestExpansion(),
            WoWTools_DataMixin.onlyChinese and '等级' or LEVEL
        ),
    function()
        return Save().maxLevelIsDisabled
    end, function()
        Save().maxLevelIsDisabled= not Save().maxLevelIsDisabled and true or nil
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(
            WoWTools_DataMixin.onlyChinese and '禁用最高级'
            or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, BEST), LEVEL)
        )
    end)

    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        nil,
        {SetValue=function()
            Save().no={}
            Save().maxLevelIsDisabled=nil
        end})
        return MenuResponse.Open
    end)

    WoWTools_MenuMixin:SetScrollMode(sub)
end





















local function Init()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('MapToy')
    if not btn then
        return
    end

    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if self.itemID then
            GameTooltip:SetItemByID(self.itemID)
            GameTooltip:AddLine(' ')
        elseif self.spellID then
            GameTooltip:SetSpellByID(self.spellID)
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end

--CD 主图标冷却
    function btn:set_cool()
        WoWTools_CooldownMixin:SetFrame(self, {
            itemID=self.itemID,
            spellID=self.spellID,
        })
    end

    function btn:set_texture()
        local icon
        if self.itemID then
            icon= select(5, C_Item.GetItemInfoInstant(self.itemID))
        elseif self.spellID then
            icon= C_Spell.GetSpellTexture(self.spellID)
        end

        if icon and icon>0 then
            self.texture:SetTexture(icon)
        else
            self.texture:SetAtlas('Taxi_Frame_Yellow')
        end
    end

    function btn:settings(itemID)--设置，随机值
        if not self:CanChangeAttribute() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        local spellName= nil
        local spellID
        if itemID then
            self:SetAttribute("type1", "toy")
        else
            self:SetAttribute("type1", "spell")
            spellID= SpellID
            spellName= C_Spell.GetSpellName(spellID) or (LOCALE_zhCN and '瞬息全战团地图') or SpellID
        end
        self:SetAttribute('toy1', itemID)
        self:SetAttribute('spell1', spellName or SpellID)

        self.itemID=itemID
        self.spellID=spellID


        self:set_texture()
        self:set_cool()
    end




    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetScript('OnUpdate',nil)
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_cool()
        self:set_tooltips()
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    btn:settings()
    btn:set_texture()

    Init=function()end
end











--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Tools_MapToy']= WoWToolsSave['Tools_MapToy'] or P_Save
            P_Save= nil
--旧数据
            Save().autoAddDisabled= nil

            addName= '|A:Taxi_Frame_Yellow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '侦察地图' or ADVENTURE_MAP_TITLE)

            WoWTools_ToolsMixin:Set_AddList(function(category, layout)
                 WoWTools_PanelMixin:Check_Button({
                     checkName= addName,
                     GetValue= function() return not Save().disabled end,
                     SetValue= function()
                         Save().disabled = not Save().disabled and true or nil
                     end,
                     buttonText= WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
                     buttonFunc= function()
                        StaticPopup_Show('WoWTools_OK',
                        addName,
                        nil,
                        {SetValue=function()
                            Save().no={}
                            Save().maxLevelIsDisabled=nil
                        end})
                     end,
                     layout= layout,
                     category= category,
                 })
             end)

            if not Save().disabled
                and not Save().no[WoWTools_DataMixin.Player.GUID]
                and not (Save().maxLevelIsDisabled and WoWTools_DataMixin.Player.IsMaxLevel)
             then
                WoWTools_ToolsMixin:CreateButton({
                    name='MapToy',
                    tooltip=addName,
                    disabledOptions=true
                })
            end

            if WoWTools_ToolsMixin:Get_ButtonForName('MapToy') then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')

                for _, info in pairs(Tab) do
                    WoWTools_DataMixin:Load(info.itemID, 'item')
                    for _, achievementID in pairs(info.achievements) do
                        GetAchievementCategory(achievementID)
                    end
                end
                WoWTools_DataMixin:Load(SpellID, 'spell')

            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)