

local Tab={
    {itemID=228412, achievements={16334, 19309, 17766, 16761, 17739, 16363, 16336, 15394}},--巨龙群岛探路者 侦察地图：巨龙群岛的天空

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
local ToyButton

local P_Save={
    no={
        --[guid]=true
    },
    autoAddDisabled= WoWTools_DataMixin.Player.husandro,
}

local function Save()
    return WoWToolsSave['Tools_MapToy']
end


















local function Is_Completed(tab)
    WoWTools_Mixin:Load({type='item', id=tab.itemID})

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
        hasToy= PlayerHasToy(tab.itemID),--没收集 ==false
        num=num,--没完成，数量
        isNotChecked=isNotChecked,--没数据 ==nil

        data=new,
    }
end












































local function Init_Menu(self, root)
    local sub, sub2, sub3
    for _, info in pairs(Tab) do
        local new= Is_Completed(info)

        local col=  new.isNotChecked==nil and new.num==0 and '|cff9e9e9e'
                    or (new.hasToy==false and '|cnRED_FONT_COLOR:')
                    or ''

        local name= WoWTools_ItemMixin:GetName(new.itemID)

        local num=(new.isNotChecked==nil and
                    (new.num>0 and ' |cnGREEN_FONT_COLOR:')
                    or (new.name==0 and ' |cff9e9e9e')
                    or ' '
                )
                ..(new.isNotChecked==nil and new.num or '')


        sub= root:CreateCheckbox(
            col..name..num,
        function(data)
            return data.itemID==self.itemID
        end, function(data)
            self:Set_Random_Value(data.itemID, data.achievements, true)
        end, {itemID=info.itemID, achievements=info.achievements})

        WoWTools_SetTooltipMixin:Set_Menu(sub)


        for index, tab in pairs(new.data) do
            sub2=sub:CreateButton(
                index..') '
                ..(tab.wasEarnedByMe==true and '|cff9e9e9e' or '')
                ..'|T'..(tab.icon or 0)..':0|t'
                ..(WoWTools_TextMixin:CN(tab.name) or tab.achievementID)
                ..(tab.wasEarnedByMe==true and '|A:common-icon-checkmark:0:0|a' or ''),
            function(data)
                self:Set_Random_Value(data.itemID, data.achievements, true)
                return MenuResponse.Open
            end,
            {itemID=tab.itemID, achievementID=tab.achievementID, achievements=info.achievements})
            sub2:SetTooltip(function(tooltip, description)
                tooltip:SetAchievementByID(description.data.achievementID)
            end)
        end
    end


    local tab={}
    local num=0
    for guid in pairs(Save().no) do
        num=num+1
        tab[guid]=true
    end

    root:CreateDivider()
    sub= root:CreateButton((WoWTools_DataMixin.onlyChinese and '已完成' or CRITERIA_COMPLETED)..(num>0 and ' #'..num or ''), function() return MenuResponse.Open end)

    sub2= sub:CreateCheckbox(WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil)..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE), function()
        return Save().no[WoWTools_DataMixin.Player.GUID]
    end, function()
        Save().no[WoWTools_DataMixin.Player.GUID]= not Save().no[WoWTools_DataMixin.Player.GUID] and true or nil
        print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().no[WoWTools_DataMixin.Player.GUID]), WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil, {reLink=true, reName=true, reRealm=true}))
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '如果已完成|n可以 “禁用” 禁用本模块' or ('If you are complete|nyou can \"'..DISABLE..'\" this module disabled'))
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT, WoWTools_TextMixin:GetEnabeleDisable(not Save().no[WoWTools_DataMixin.Player.GUID]))
    end)

    sub3= sub2:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO, function()
        return Save().autoAddDisabled
    end, function()
        Save().autoAddDisabled= not Save().autoAddDisabled and true or nil
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '自动禁用' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, DISABLE))
    end)

    if num>0 then
        sub:CreateDivider()
    end
    for guid in pairs(tab) do
        local player= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true})
        sub2=sub:CreateCheckbox(player,
            function(data)
                return Save().no[data.guid]
            end, function(data)
                Save().no[data.guid]= not Save().no[data.guid] and true or nil
                    print(WoWTools_DataMixin.Icon.icon2.. addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().no[data.guid]),
                        WoWTools_UnitMixin:GetPlayerInfo(nil, data.guid, nil, {reLink=true, reName=true, reRealm=true})
                    )

            end,
            {guid=guid, player=player}
        )
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)
            tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT, WoWTools_TextMixin:GetEnabeleDisable(not Save().no[description.data.guid]))
        end)
    end

    if num>2 then
        sub:CreateButton(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL, function()
            Save().no={}
        end)
    end
    WoWTools_MenuMixin:SetGridMode(sub, num)


    WoWTools_ToolsMixin:OpenMenu(root, addName)
end





















local function Init()
    ToyButton:SetAttribute("type1", "toy")

    function ToyButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if self.itemID then
            GameTooltip:SetItemByID(self.itemID)
        else
            GameTooltip:AddDoubleLine(' ', addName)
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:Show()
    end

    --CD
    function ToyButton:set_cool()
        WoWTools_CooldownMixin:SetFrame(self, {itemID=self.itemID})--主图标冷却
    end

    function ToyButton:set_texture()
        local icon= self.itemID and C_Item.GetItemIconByID(self.itemID)
        if icon and icon>0 then
            self.texture:SetTexture(icon)
        else
            self.texture:SetAtlas('Taxi_Frame_Yellow')
        end
    end

    function ToyButton:Set_Random_Value(itemID, achievements, isLocked)--设置，随机值
        --local name=C_Item.GetItemNameByID(itemID) or select(2, C_ToyBox.GetToyInfo(itemID))
        if not self:CanChangeAttribute() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        self.itemID=itemID
        self.achievements= achievements
        self.isLocked= isLocked
        self:SetAttribute('toy1', itemID)
        self:set_texture()
        self:set_cool()
    end

    function ToyButton:Cerca_Toy()
        if self.isLocked or not self:CanChangeAttribute() then
            return
        end

        for _, info in pairs(Tab) do
            local new= Is_Completed(info)
            if new.isNotChecked==nil and new.num>0 then
                self:Set_Random_Value(info.itemID, info.achievements, nil)
                return
            end
        end

    end



    ToyButton:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)
    ToyButton:SetScript('OnEnter', function(self)
        self:set_cool()
        self:set_tooltips()
        self:SetScript('OnUpdate', function (s, elapsed)
            s.elapsed = (s.elapsed or 2) + elapsed
            if s.elapsed > 2 then
                s.elapsed = 0
                self:Cerca_Toy()
                if GameTooltip:IsOwned(s) then
                    s:set_tooltips()
                end
            end
        end)
    end)

    ToyButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        elseif d=='LeftButton' then
            self.isLocked=nil
        end
    end)

    ToyButton:SetScript("OnEvent", function(self, event)
        self:Cerca_Toy()
        self:UnregisterEvent(event)
    end)

    ToyButton:Cerca_Toy()
    ToyButton:set_texture()
end











--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('LOADING_SCREEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Tools_MapToy']= WoWToolsSave['Tools_MapToy'] or P_Save

            addName= '|A:Taxi_Frame_Yellow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '侦察地图' or ADVENTURE_MAP_TITLE)

            WoWTools_ToolsMixin:AddOptions(function(category, layout)
                 WoWTools_PanelMixin:Check_Button({
                     checkName= addName,
                     GetValue= function() return not Save().disabled end,
                     SetValue= function()
                         Save().disabled = not Save().disabled and true or nil
                     end,
                     buttonText= WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
                     buttonFunc= function()
                         Save().no={}
                     end,
                     layout= layout,
                     category= category,
                 })
             end)

            if not Save().disabled
                and not Save().no[WoWTools_DataMixin.Player.GUID]
                and WoWTools_ToolsMixin.Button
            then
                ToyButton= WoWTools_ToolsMixin:CreateButton({
                    name='MapToy',
                    tooltip=addName,
                    disabledOptions=true
                })

                for _, info in pairs(Tab) do
                    WoWTools_Mixin:Load({id=info.itemID, type='item'})
                    for _, achievementID in pairs(info.achievements) do
                        GetAchievementCategory(achievementID)
                    end
                end

                self:UnregisterEvent(event)
            else

                self:UnregisterAllEvents()
            end
        end

    elseif event == "LOADING_SCREEN_DISABLED" then
        Init()
        self:UnregisterEvent(event)
    end
end)
        --[[local find
        local notHasToy
        for _, info in pairs(Tab) do
            local new= Is_Completed(info)

            if new.hasToy~=false--没收集
                and new.num>0--没完成，数量
                or new.isNotChecked--没数据
            then
                find=true
            end
            if new.hasToy~=true then
                notHasToy=true
            end
        end

        if find==nil then
            if not notHasToy and Save().autoAddDisabled then
                Save().no[WoWTools_DataMixin.Player.GUID]=true
                return
            end
        end]]
