local e= select(2, ...)
local function Save()
    return WoWTools_HearthstoneMixin.Save
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
}

WoWTools_HearthstoneMixin.Save.items= P_Items

local ModifiedMenuTab={
    {type='Alt', itemID=140192, icon=1444943},
    {type='Ctrl', itemID=110560, icon=1041860},
    {type='Shift', itemID=6948, icon=134414},
}

for _, data in pairs(ModifiedMenuTab) do
    WoWTools_Mixin:Load({id=data.itemID, type='item'})
end

for itemID in pairs(P_Items) do
    WoWTools_Mixin:Load({id=itemID, type='item'})
end








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








local function Init(ToyButton)
    ToyButton:SetAttribute("type1", "macro")

    ToyButton.text=WoWTools_LabelMixin:Create(ToyButton, {size=10, color=true, justifyH='CENTER'})
    ToyButton.text:SetPoint('TOP', ToyButton, 'BOTTOM',0, 5)

    ToyButton.textureModifier= ToyButton:CreateTexture(nil, 'OVERLAY', nil, 2)
    ToyButton.textureModifier:SetAllPoints()
    ToyButton.textureModifier:AddMaskTexture(ToyButton.mask)
    ToyButton.textureModifier.Shift= 134414
    ToyButton.textureModifier.Ctrl=1041860
    ToyButton.textureModifier.Alt=1444943

    ToyButton.typeItems={}

    for _, data in pairs(ModifiedMenuTab) do
        local icon= ToyButton:CreateTexture(nil,'BORDER', nil, 1)
        icon:SetSize(10, 10)
        icon:SetTexture(data.icon)

        if data.type=='Alt' then--达拉然炉石
            icon:SetPoint('BOTTOMRIGHT',-3,3)
        elseif data.type=='Ctrl' then--要塞炉石
            icon:SetPoint('BOTTOMLEFT',2,2)
        elseif data.type=='Shift' then--炉石
            icon:SetPoint('TOPLEFT',2,-2)
        end

        ToyButton.mask:SetSize(10,10)
        ToyButton.mask:SetPoint('CENTER', icon)
        icon:AddMaskTexture(ToyButton.mask)

        ToyButton.typeItems[data.itemID]= true
    end








    --设置 Alt Shift Ctrl
    function ToyButton:set_alt()
        self.isAltEvent=nil
        if not self:CanChangeAttribute() then
            self.isAltEvent=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        local toyName, itemName

        for _, data in pairs(ModifiedMenuTab) do
            itemName= C_Item.GetItemNameByID(data.itemID)
            toyName= select(2, C_ToyBox.GetToyInfo(data.itemID))
            if toyName then
                self:SetAttribute(data.type.."-type1", "macro")
                self:SetAttribute(data.type.."-macrotext1",  '/usetoy '..toyName)
            elseif itemName then
                self:SetAttribute(data.type.."-type1", "item")
                self:SetAttribute(data.type.."-item1",  itemName)
            else
                self.isAltEvent=true
            end
        end
        if self.isAltEvent then
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
        end
    end


    function ToyButton:get_modifier_index()
        return
            IsAltKeyDown() and 1
            or (IsControlKeyDown() and 2)
            or (IsShiftKeyDown() and 3)
    end

    --取得，炉石, 绑定位置
    function ToyButton:get_location()
        return e.cn(GetBindLocation())
    end

    --显示, 炉石, 绑定位置
    function ToyButton:set_location()
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
    function ToyButton:set_tooltip_location(tooltip)
        if tooltip.textLeft then
            tooltip.textLeft:SetText(self:get_location() or '')
        end
    end

    --CD
    function ToyButton:set_cool(itemID)
        e.SetItemSpellCool(self, {item=itemID or self.itemID})--主图标冷却
    end













    ToyButton:SetScript('OnEvent', function(self, event, arg1, arg2)
        if event=='ITEM_DATA_LOAD_RESULT' then
            if arg2 then--success then
                if self.typeItems[arg1] then
                    self:set_alt()
                elseif Save().items[arg1] then
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
            local itemID, icon
            if arg2==1 then
                local index= self:get_modifier_index()
                if index then
                    itemID= ModifiedMenuTab[index].itemID
                    icon= ModifiedMenuTab[index].icon
                end
            end
            self:set_tooltips(itemID)
            self:set_cool(itemID)
            self.textureModifier:SetTexture(icon or 0)
        end
    end)
















--Tooltip
    function ToyButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        local index= self:get_modifier_index()
        if index then
            WoWTools_SetTooltipMixin:Setup(GameTooltip, {itemID= ModifiedMenuTab[index].itemID})
        else

            GameTooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(self.itemID), e.Icon.left)
            GameTooltip:AddLine(' ')
            local name, col
            for _, data in pairs(ModifiedMenuTab) do
                name, col=WoWTools_ItemMixin:GetName(data.itemID)
                col= col or ''
                GameTooltip:AddDoubleLine(col..name, col..data.type..'+'..e.Icon.left)
            end
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            GameTooltip:AddDoubleLine(
                e.onlyChinese and '随机' or 'Random',
                (ToyButton.Locked_Value and '' or '|cnGREEN_FONT_COLOR:#'..#self.Random_List..'|r')
                ..(ToyButton.Selected_Value and '|A:transmog-icon-checkmark:0:0|a' or '')
                ..(ToyButton.Locked_Value and '|A:AdventureMapIcon-Lock:0:0|a' or '')
                ..e.Icon.mid
            )


--发现就绪
            local duration= self.itemID and select(2, C_Item.GetItemCooldown(self.itemID))
            if duration and duration>3 then
                local itemID= get_not_cooldown_toy(self)
                if itemID then
                    GameTooltip:AddDoubleLine(
                        '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':32|t|cnGREEN_FONT_COLOR:'
                        ..(e.onlyChinese and '发现就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BATTLE_PET_SOURCE_11, READY)),
                        e.Icon.right
                    )
                end
            end
        end

        GameTooltip:Show()

        self:set_tooltip_location(GameTooltip)
    end













    ToyButton:SetScript("OnEnter",function(self)
        WoWTools_ToolsMixin:EnterShowFrame(self)
        self:set_tooltips()
        self:SetScript('OnUpdate', function (s, elapsed)
            s.elapsed = (s.elapsed or 0.3) + elapsed
            if s.elapsed > 0.3 and s.itemID then
                s.elapsed = 0
                if GameTooltip:IsOwned(s) and select(3, GameTooltip:GetItem())~=s.itemID then
                    s:set_tooltips()
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
    end)

    ToyButton:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
        self:Get_Random_Value()
    end)

    ToyButton:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            WoWTools_HearthstoneMixin:Setup_Menu()
        end
    end)

    ToyButton:SetScript("OnMouseUp", function(self, d)
        self:Get_Random_Value()
    end)
    ToyButton:SetScript('OnMouseWheel', function(self)
        self.Selected_Value=nil
        self:Get_Random_Value()
    end)











    Mixin(ToyButton, WoWTools_RandomMixin)

    function ToyButton:Get_Random_Data()--取得数据库, {数据1, 数据2, 数据3, ...}
        local tab={}
        for itemID in pairs(Save().items) do
            if PlayerHasToy(itemID) then
                table.insert(tab, itemID)
            end
        end
        return tab
    end

    function ToyButton:Set_Random_Value(itemID)--设置，随机值
        self.is_Random_Eevent=nil
        if not self:CanChangeAttribute() then
            self.is_Random_Eevent=true
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        local toyName=select(2, C_ToyBox.GetToyInfo(itemID)) or C_Item.GetItemNameByID(itemID)
        if not toyName then
            self.is_Random_Eevent=true
            self:RegisterEvent('ITEM_DATA_LOAD_RESULT')
            return
        end

        self.itemID=itemID
        self:SetAttribute("macrotext1",  '/usetoy '..toyName)
        self.texture:SetTexture(C_Item.GetItemIconByID(itemID) or 134414)

        self:set_cool()
    end
    function ToyButton:Set_OnlyOneValue_Random()--当数据 <=1 时，设置值
        self:Set_Random_Value(self.Selected_Value or self.Locked_Value or self.Random_List[1] or 200869)--欧恩牌清淡饮水角
    end

    ToyButton:Init_Random(Save().lockedToy)--初始








    function ToyButton:set_event()
        if self:IsVisible() then
            self:RegisterEvent('HEARTHSTONE_BOUND')
            self:RegisterEvent('TOYS_UPDATED')
            self:RegisterEvent('NEW_TOY_ADDED')
            self:RegisterEvent('UI_MODEL_SCENE_INFO_UPDATED')
            self:RegisterEvent('BAG_UPDATE_COOLDOWN')
            self:RegisterEvent('MODIFIER_STATE_CHANGED')
            self:Get_Random_Value()
        else
            self:UnregisterAllEvents()
            e.SetItemSpellCool(self)--主图标冷却
        end
    end

    ToyButton:SetScript('OnShow', ToyButton.set_event)
    ToyButton:SetScript('OnHide', ToyButton.set_event)
    ToyButton:set_event()










    ToyButton:set_alt()
    C_Timer.After(4, function()
        ToyButton:set_location()
        ToyButton:Get_Random_Value()
    end)
end


















function WoWTools_HearthstoneMixin:Init_Button()
    Init(self.ToyButton)
end


function WoWTools_HearthstoneMixin:Get_P_Items()
    return P_Items
end