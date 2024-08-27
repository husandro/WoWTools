local id, e = ...

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

if e.Player.faction=='Alliance' then
    --LM
    table.insert(Tab, {itemID=150743, achievements={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860}})--卡利姆多
    table.insert(Tab, {itemID=150746, achievements={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868}})--东部王国

elseif e.Player.faction=='Horde' then
    --BL
    table.insert(Tab, {itemID=150744, achievements={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860}})--卡利姆多
    table.insert(Tab, {itemID=150745, achievements={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868}})--东部王国
end


local addName
local ToyButton

local Save={
    no={
        --[guid]=true
    }
}







local function Init_Options()

end




local function Get_Valid(data)
    local num=0

    local name= WoWTools_SpellItemMixin:GetName(nil, data.itemID) or ''
    name=name:match('|cff......(.-)|r') or name
    
    local find= false
    
    local new={}
    for _, achievementID  in pairs(data.achievements) do
        local _, name2, _, _, _, _, _, _, _, icon, _, _, wasEarnedByMe= GetAchievementInfo(achievementID)
        if name2 then
            num= num+1
            table.insert(new, {
                achievementID=achievementID,
                icon=icon,
                name=name2,
                find= wasEarnedByMe
                --col= wasEarnedByMe and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'
            })
            
            find= not wasEarnedByMe
        end
    end

    data.has= PlayerHasToy(data.itemID) and C_ToyBox.IsToyUsable(data.itemID)
    data.name= name
    data.find= find
    data.num= num
    data.achievements=new

    return data
end




local function Init_Menu(self, root)
    local sub, sub2
    for _, info in pairs(Tab) do
        local new= Get_Valid(info)

        sub= root:CreateCheckbox(
            (not new.find or not new.has) and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:',
            new.name,
        function(data)
            return data.itemID==self.itemID
        end, function(data)
            self:Set_Random_Value(data.itemID)
        end, {itemID=info.itemID})

        WoWTools_SpellItemMixin:SetTooltip(nil, nil, sub, nil)
        --sub:SetEnabled(false)

        for _, tab in pairs(new.achievements) do
            sub2=sub:CreateButton(
                (tab.find and '|cff9e9e9e' or '')
                '|T'..(tab.icon or 0)..':0|t'
                ..tab.name,
            function(data)
                self:Set_Random_Value(data.itemID)
                return MenuResponse.Open
            end,
            {itemID=tab.itemID, achievementID=tab.achievementID})
            sub2:SetTooltip(function(tooltip, description)
                tooltip:SetAchievementByID(description.data.achievementID)
            end)
        end

    end
end





local function Init()
    for _, info in pairs(Tab) do
        e.LoadDate({id=info.itemID, type='item'})
        for _, achievementID in pairs(info.achievements) do
            GetAchievementCategory(achievementID)
        end
    end
    
    function ToyButton:set_tooltips()        
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if self.itemID then
            e.tips:SetItemByID(self.itemID)
        else
            e.tips:AddDoubleLine(' ', addName)
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        end
        e.tips:Show()
    end

    --CD
    function ToyButton:set_cool()
        e.SetItemSpellCool(self, {item=self.itemID})--主图标冷却
    end

    function ToyButton:set_texture()
        local icon= self.itemID and C_Item.GetItemIconByID(self.itemID)
        if icon and icon>0 then
            self.texture:SetTexture(icon)
        else
            self.texture:SetAtlas('Taxi_Frame_Yellow')
        end
    end

    function ToyButton:Set_Random_Value(itemID)--设置，随机值
        local name=C_Item.GetItemNameByID(itemID) or select(2, C_ToyBox.GetToyInfo(itemID))
        if not name or not self:CanChangeAttribute() then
            return
        end
        
        self.itemID=itemID
        self:SetAttribute('item1', name)
        self:set_texture()
        self:set_cool()
    end

    ToyButton:SetAttribute("type1", "item")

    ToyButton:SetScript('OnLeave', GameTooltip_Hide)
    ToyButton:SetScript('OnEnter', function(self)
        self:set_cool()
        self:set_tooltips()
    end)

    ToyButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    ToyButton:set_texture()
end











--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave['Tools_MapToy'] or {}

            WoWTools_ToolsButtonMixin:AddOptions(Init_Options)

            Save.no= Save.no or {}
            
            if Save.disabled
               or Save.no[e.Player.guid]
                or not WoWTools_ToolsButtonMixin:GetButton()
            then
                Tab=nil
                return
            end

            addName= '|A:Taxi_Frame_Yellow:0:0|a'..(e.onlyChinese and '侦察地图' or ADVENTURE_MAP_TITLE)
            ToyButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='MapToy',
                tooltip=addName,
            })

            if not ToyButton then
                Tab=nil
                return
            end

            Init()

            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_MapToy']= Save
        end
    end
end)
            --[[
            --if not e.toolsFrame.disabled then
                if not AchievementFrame then
                    AchievementFrame_LoadUI();
                end

                if not C_AddOns.IsAddOnLoaded('Blizzard_AchievementUI') then
                    C_AddOns.LoadAddOn("Blizzard_AchievementUI")
                end
                if not C_AddOns.IsAddOnLoaded('Blizzard_ToyBox') then
                    C_AddOns.LoadAddOn("Blizzard_ToyBox")
                end

                C_Timer.After(2, function()
                    ToggleAchievementFrame()
                    if AchievementFrame and AchievementFrame:IsVisible() then
                        ToggleAchievementFrame()
                    end
                end)

                panel:RegisterEvent('PLAYER_REGEN_DISABLED')
                panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                panel:RegisterEvent('UI_ERROR_MESSAGE')
                panel:RegisterEvent('CRITERIA_UPDATE')
                panel:RegisterEvent('RECEIVED_ACHIEVEMENT_LIST')

                C_Timer.After(4, self.get_Use_Toy)
            --else
              --  Toy=nil
            --end]]
            

--[[
function panel:Requested_Achievement()
    for itemID, achievementIDs in pairs(ToyTab) do
        e.LoadDate({id=itemID, type='item'})
        for _, achievementID in pairs(achievementIDs) do
            GetAchievementCategory(achievementID)
        end
    end
end



function panel:get_Use_Toy()
    local bat= UnitAffectingCombat('player')
    if bat or e.Player.faction=='Neutral' then
        if not bat and button then
            button:SetShown(false)
        end
        return
    end
    panel:Requested_Achievement()

    local notFindName
    for itemID, tab in pairs(ToyTab) do
        if PlayerHasToy(itemID) and C_ToyBox.IsToyUsable(itemID) or e.Player.husandro then
            for _, achievementID  in pairs(tab) do
                local _, name, _, _, _, _, _, _, _, _, _, _, wasEarnedByMe= GetAchievementInfo(achievementID)
                if name and not wasEarnedByMe then
                    if not button then

                        button= e.Cbtn2({
                            name=nil,
                            parent=_G['WoWToolsMountButton'],
                            click=true,-- right left
                            notSecureActionButton=nil,
                            notTexture=nil,
                            showTexture=true,
                            sizi=nil,
                        })

                        button:SetAttribute("type*", "item")
                        button:SetPoint('BOTTOM', _G['WoWToolsOpenItemsButton'], 'TOP')--自定义位置
                        button:SetScript('OnLeave', GameTooltip_Hide)
                        button:SetScript('OnEnter', function(self2)
                            if self2.itemID then
                                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                                e.tips:ClearLines()
                                e.tips:SetItemByID(self2.itemID)
                                --e.tips:SetToyByItemID(self2.itemID)
                                e.tips:AddLine(' ')
                                if e.onlyChinese then
                                    e.tips:AddLine('|cnRED_FONT_COLOR:使用, 请勿太快')
                                else
                                    e.tips:AddLine('|cnRED_FONT_COLOR:note: '..ERR_GENERIC_THROTTLE)
                                end
                                e.tips:Show()
                            end
                        end)
                    end
                    local itemName, _, _, _, _, _, _, _, _, itemTexture= C_Item.GetItemInfo(itemID)
                    itemName=itemName or  C_Item.GetItemNameByID(itemID) or itemID
                    itemTexture= itemTexture or C_Item.GetItemIconByID(itemID) or 0
                    button:SetAttribute("item*", itemName)
                    button.texture:SetTexture(itemTexture)
                    button:SetShown(true)
                    button.itemID=itemID
                    return

                elseif not name then
                    notFindName=true
                end
            end
        end
    end

    if button then
        button:SetShown(false)
    end
    if not notFindName then
        panel:UnregisterAllEvents()
        Toy=nil
    end
end




]]            