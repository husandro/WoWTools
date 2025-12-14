WoWTools_HearthstoneMixin={}


--[[local ModifiedTab={
    [6948]='shift',--炉石
    [110560]='ctrl',--要塞炉石
    [140192]='alt',--达拉然炉石
}]]

local P_Save={
    items={},
    showBindNameShort=true,
    showBindName=true,
    lockedToy=nil,
}
local function Save()
    return WoWToolsSave['Tools_Hearthstone']
end
local function SaveItems()
    return WoWToolsPlayerDate['HearthstoneItems']
end




local P_Items={
    [142542]=true,--城镇传送之书
    [162973]=true,--冬天爷爷的炉石
    [163045]=true,--无头骑士的炉石
    [165669]=true,--春节长者的炉石
    [165670]=true,--小匹德菲特的可爱炉石
    [165802]=true,--复活节的炉石
    [166746]=true,--吞火者的炉石
    [166747]=true,--美酒节狂欢者的炉石
    [168907]=true,--全息数字化炉石
    [172179]=true,--永恒旅者的炉石
    [188952]=true,--被统御的炉石
    [190196]=true,--开悟者炉石
    [190237]=true,--掮灵传送矩阵
    [193588]=true,--时光旅行者的炉石
    [200630]=true,--欧恩伊尔轻风贤者的炉石, 找不到数据
    [209035]=true,--烈焰炉石
    [212337]=true,--炉之石
    [210455]=true,--德莱尼全息宝石
    [93672]=true,--黑暗之门
    [206195]=true,--纳鲁之路
    [208704]=true,--幽邃住民的土灵炉石
    [236687]=true,--高爆炉石
    [228940]=true,--恶名丝线炉石
    [235016]=true,--重部署模块
    [246565]=true,--星瀚炉石
    [245970]=true,--P.O.S.T.总管的特快炉石 11.2.7
    [257736]=true,--圣光呼唤炉石 12.0
    [265100]=true,--核心守卫的炉石
}



local ModifiedMenuTab={
    {type='Alt', itemID=140192, icon=1444943},--达拉然炉石
    {type='Ctrl', itemID=110560, icon=1041860},--要塞炉石
    {type='Shift', itemID=6948, icon=134414},----炉石
}










local function get_not_cooldown_toy(self)--发现就绪
    local duration = select(2, C_Item.GetItemCooldown(self.itemID))
    if duration and duration>3 then
        for itemID in pairs(P_Items) do
            if PlayerHasToy(itemID) then
                duration= select(2, C_Item.GetItemCooldown(itemID))
                if duration and duration<3 then
                    return itemID
                end
            end
        end
    end
end











local function Init_Menu(self, root)
    local sub, sub2, name
    WoWTools_HearthstoneMixin:Init_Menu_Toy(self, root)

--选项
    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root, WoWTools_HearthstoneMixin.addName)

    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '绑定位置' or SPELL_TARGET_CENTER_LOC, function()
        return Save().showBindName
    end, function()
        Save().showBindName= not Save().showBindName and true or false
        self:set_location()--显示, 炉石, 绑定位置
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(self:get_location())
    end)

    sub2:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '截取名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHORT, NAME), function()
        return Save().showBindNameShort
    end, function()
        Save().showBindNameShort= not Save().showBindNameShort and true or false
        self:set_location()--显示, 炉石, 绑定位置
    end)

--移除未收集
    sub:CreateDivider()
    name= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移除未收集' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, NOT_COLLECTED))
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            local n=0
            for itemID in pairs(SaveItems()) do
                if not PlayerHasToy(itemID) then
                    SaveItems()[itemID]=nil
                    n=n+1
                    print(n, WoWTools_DataMixin.onlyChinese and '移除' or REMOVE, WoWTools_ItemMixin:GetLink(itemID))
                end
            end
            if n>0 then
                self:Init_Random(Save().lockedToy)
            end
        end})
        return MenuResponse.Open
    end, {name=name})


--全部清除
    name= '|A:common-icon-redx:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            WoWToolsPlayerDate['HearthstoneItems']={}
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_HearthstoneMixin.addName, WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            self:Rest_Random()
        end})
        return MenuResponse.Open
    end, {name=name})



--还原
    local all= 0
    for _ in pairs(P_Items) do
        all=all+1
    end
    name= '|A:common-icon-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)..' '..all
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            WoWToolsPlayerDate['HearthstoneItems']= CopyTable(P_Items)
            self:Rest_Random()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_HearthstoneMixin.addName, '|cnGREEN_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
        end})
        return MenuResponse.Open
    end, {name=name})


--设置
    sub:CreateDivider()
    sub2=sub:CreateButton(
        '|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS),
    function()
        WoWTools_LoadUIMixin:Journal(3)
        return MenuResponse.Open
    end
    )
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
    end)
end














local function Init()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Hearthstone')
    --btn:SetAttribute("type1", "macro")
    btn:SetAttribute("type1", "toy")

    btn.text=WoWTools_LabelMixin:Create(btn, {size=10, color=true, justifyH='CENTER'})
    btn.text:SetPoint('TOP', btn, 'BOTTOM',0, 5)

    btn.textureModifier= btn:CreateTexture(nil, 'OVERLAY', nil, 2)
    btn.textureModifier:SetAllPoints()
    btn.textureModifier:AddMaskTexture(btn.IconMask)

    btn.typeItems={}

    for _, data in pairs(ModifiedMenuTab) do
        WoWTools_DataMixin:Load(data.itemID, 'item')

        local icon= btn:CreateTexture(nil,'BORDER', nil, 1)
        icon:SetSize(10, 10)
        icon:SetTexture(data.icon)

        if data.type=='Alt' then--达拉然炉石
            icon:SetPoint('BOTTOMRIGHT',-3,3)
        elseif data.type=='Ctrl' then--要塞炉石
            icon:SetPoint('BOTTOMLEFT',2,2)
        elseif data.type=='Shift' then--炉石
            icon:SetPoint('TOPLEFT',2,-2)
        end

        btn.IconMask:SetSize(10,10)
        btn.IconMask:SetPoint('CENTER', icon)
        icon:AddMaskTexture(btn.IconMask)

        btn.typeItems[data.itemID]= true
    end








    --设置 Alt Shift Ctrl
    function btn:set_alt()
        self.isAltEvent=nil
        if not self:CanChangeAttribute() then
            self.isAltEvent=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        for _, data in pairs(ModifiedMenuTab) do
            WoWTools_DataMixin:Load(data.itemID, 'item')
            if PlayerHasToy(data.itemID) then
                self:SetAttribute(data.type.."-type1", "toy")
                self:SetAttribute(data.type.."-toy1",  data.itemID)
            else
                local itemName= C_Item.GetItemNameByID(data.itemID)
                self:SetAttribute(data.type.."-type1", "item")
                if itemName then
                    self:SetAttribute(data.type.."-item1",  itemName)
                else
                    self.isAltEvent= true
                end
            end
        end

        if self.isAltEvent then
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
        end
    end


    function btn:get_modifier_index()
        return
            IsAltKeyDown() and 1
            or (IsControlKeyDown() and 2)
            or (IsShiftKeyDown() and 3)
    end

    function btn:set_textureModifier(down)
        local itemID, icon, isDesaturated
        if self:IsMouseOver() then
            if down==1 then
                local index= self:get_modifier_index()
                if index then
                    itemID= ModifiedMenuTab[index].itemID
                    icon= ModifiedMenuTab[index].icon
                    if itemID then
                        isDesaturated= not PlayerHasToy(itemID) and C_Item.GetItemCount(itemID)==0
                    end
                end
            end
            self:set_tooltip(itemID)
            self:set_cool(itemID)
            self.textureModifier:SetDesaturated(isDesaturated)
        end
        self.textureModifier:SetTexture(icon or 0)
    end


    --取得，炉石, 绑定位置
    function btn:get_location()
        return WoWTools_TextMixin:CN(GetBindLocation())
    end

    --显示, 炉石, 绑定位置
    function btn:set_location()
        local text
        if Save().showBindName then
            text= self:get_location()
            if text and Save().showBindNameShort then
                text= WoWTools_TextMixin:sub(text, 2, 5)
            end
        end
        self.text:SetText(text or '')
    end

    --提示, 炉石, 绑定位置，文本
    function btn:set_tooltip_location(tooltip)
        if tooltip.textLeft then
            tooltip.textLeft:SetText(self:get_location() or '')
        end
    end

    --CD
    function btn:set_cool(itemID)
        WoWTools_CooldownMixin:SetFrame(self, {itemID=itemID or self.itemID})--主图标冷却
    end













    btn:SetScript('OnEvent', function(self, event, arg1, arg2)
        if event=='ITEM_DATA_LOAD_RESULT' then
            if arg1 and arg2 then--success then
                if self.typeItems[arg1] then
                    self:set_alt()
                elseif SaveItems()[arg1] then
                    self:Set_Random_Event()--is_Random_Eevent
                end
                if not self.isAltEvent and not self.is_Random_Eevent then
                    self:UnregisterEvent('ITEM_DATA_LOAD_RESULT')
                end
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            if self.isAltEvent then
                self:set_alt()
            end
            if self.is_Random_Eevent then
                self:Set_Random_Event()--is_Random_Eevent
            end
            if not self.isAltEvent and not self.is_Random_Eevent then
                self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            end

        elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
            self:Init_Random(Save().lockedToy)

        elseif event=='HEARTHSTONE_BOUND' then
            self:set_location()

        elseif event=='UI_MODEL_SCENE_INFO_UPDATED' then
            self.isSelected=nil
            self:Get_Random_Value()

        elseif event=='BAG_UPDATE_COOLDOWN' then
            self:set_cool()

        elseif event=='MODIFIER_STATE_CHANGED' then
            self:set_textureModifier(arg2)
        end
    end)
















--Tooltip
    function btn:set_tooltip()
        self.elapsed= 0
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        local index= self:get_modifier_index()
        if index then
            WoWTools_SetTooltipMixin:Setup(GameTooltip, {itemID= ModifiedMenuTab[index].itemID})
        else

            GameTooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(self.itemID), WoWTools_DataMixin.Icon.left)
            GameTooltip:AddLine(' ')
            local name, col
            for _, data in pairs(ModifiedMenuTab) do
                name, col=WoWTools_ItemMixin:GetName(data.itemID)
                col= col or ''
                GameTooltip:AddDoubleLine(col..name, col..data.type..'+'..WoWTools_DataMixin.Icon.left)
            end
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '随机' or 'Random',
                (btn.Locked_Value and '' or '|cnGREEN_FONT_COLOR:#'..#self.Random_List..'|r')
                ..(btn.Selected_Value and '|A:transmog-icon-checkmark:0:0|a' or '')
                ..(btn.Locked_Value and '|A:AdventureMapIcon-Lock:0:0|a' or '')
                ..WoWTools_DataMixin.Icon.mid
            )


--发现就绪
            local duration= self.itemID and select(2, C_Item.GetItemCooldown(self.itemID))
            if duration and duration>3 then
                local itemID= get_not_cooldown_toy(self)
                if itemID then
                    GameTooltip:AddDoubleLine(
                        '|T'..(select(5, C_Item.GetItemInfoInstant(itemID)) or 0)..':32|t|cnGREEN_FONT_COLOR:'
                        ..(WoWTools_DataMixin.onlyChinese and '发现就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BATTLE_PET_SOURCE_11, READY)),
                        WoWTools_DataMixin.Icon.right
                    )
                end
            end
        end

        GameTooltip:Show()

        self:set_tooltip_location(GameTooltip)
    end













    btn:SetScript("OnEnter",function(self)
        WoWTools_ToolsMixin:EnterShowFrame(self)
        self:set_tooltip()
        local Elapsed=1
        self:SetScript('OnUpdate', function (s, elapsed)
            Elapsed = Elapsed + elapsed
            if Elapsed > 1 and s.itemID then
                Elapsed = 0
                if GameTooltip:IsOwned(s) and select(3, GameTooltip:GetItem())~=s.itemID then
                    s:set_tooltip()
                end
            end
        end)
        if self:CanChangeAttribute() then
            local itemID= get_not_cooldown_toy(self)--发现就绪
            if itemID then
                self.Selected_Value=itemID
                self:Set_Random_Value(itemID)
            end
        end
        self:RegisterEvent('MODIFIER_STATE_CHANGED')
        self:set_textureModifier(1)
    end)

    btn:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:SetScript('OnUpdate',nil)
        self:Get_Random_Value()
        self:UnregisterEvent('MODIFIER_STATE_CHANGED')
        self:set_textureModifier()
    end)

    btn:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    btn:SetScript("OnMouseUp", function(self, d)
        self:Get_Random_Value()
    end)
    btn:SetScript('OnMouseWheel', function(self)
        self.Selected_Value=nil
        self:Get_Random_Value()
    end)











    Mixin(btn, WoWTools_RandomMixin)

    function btn:Get_Random_Data()--取得数据库, {数据1, 数据2, 数据3, ...}
        local tab={}
        for itemID in pairs(SaveItems()) do
            if PlayerHasToy(itemID) then
                table.insert(tab, itemID)
            end
        end
        return tab
    end

    function btn:Set_Random_Value(itemID)--设置，随机值
        self.is_Random_Eevent=nil
        if not self:CanChangeAttribute() then
            self.is_Random_Eevent=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        self.itemID=itemID
        self:SetAttribute("toy1",  itemID)
        self.texture:SetTexture(select(5, C_Item.GetItemInfoInstant(itemID)) or 134414)
        self:set_cool()
    end
    function btn:Set_OnlyOneValue_Random()--当数据 <=1 时，设置值
        self:Set_Random_Value(self.Selected_Value or self.Locked_Value or self.Random_List[1] or 200869)--欧恩牌清淡饮水角
    end

    btn:Init_Random(Save().lockedToy)--初始










    function btn:set_event()
        if self:IsVisible() then
            self:RegisterEvent('HEARTHSTONE_BOUND')
            self:RegisterEvent('TOYS_UPDATED')
            self:RegisterEvent('NEW_TOY_ADDED')
            self:RegisterEvent('UI_MODEL_SCENE_INFO_UPDATED')
            self:RegisterEvent('BAG_UPDATE_COOLDOWN')

            self:Get_Random_Value()
        else
            self:UnregisterAllEvents()
            WoWTools_CooldownMixin:SetFrame(self)--主图标冷却
        end
    end

    btn:SetScript('OnShow', function(self) self:set_event() end)
    btn:SetScript('OnHide', function(self) self:set_event() end)













    --C_Timer.After(4, function()
    btn:set_alt()
    btn:set_location()
    btn:Get_Random_Value()
    btn:set_event()

    Init=function()end
end















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Tools_Hearthstone']= WoWToolsSave['Tools_Hearthstone'] or P_Save
            P_Save= nil

            WoWToolsPlayerDate['HearthstoneItems']= WoWToolsPlayerDate['HearthstoneItems'] or CopyTable(P_Items)

            WoWTools_HearthstoneMixin.addName='|A:delves-bountiful:0:0|a'..(WoWTools_DataMixin.onlyChinese and '炉石' or TUTORIAL_TITLE31)

            WoWTools_ToolsMixin:CreateButton({
                name='Hearthstone',
                tooltip= WoWTools_HearthstoneMixin.addName,
            })


            if WoWTools_ToolsMixin:Get_ButtonForName('Hearthstone') then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')

                for _, data in pairs(ModifiedMenuTab) do
                    WoWTools_DataMixin:Load(data.itemID, 'item')
                end

                for itemID in pairs(SaveItems()) do
                   WoWTools_DataMixin:Load(itemID, 'item')
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    WoWTools_HearthstoneMixin:Blizzard_Collections()
                    self:UnregisterEvent(event)
                end

            else
                self:SetScript('OnEvent', nil)
                self:UnregisterAllEvents()
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
            WoWTools_HearthstoneMixin:Blizzard_Collections()
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:UnregisterEvent(event)
    end
end)