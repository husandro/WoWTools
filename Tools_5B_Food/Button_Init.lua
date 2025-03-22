local e= select(2, ...)
local function Save()
    return WoWTools_FoodMixin.Save
end










local function Add_Item(info)
    local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(info.itemLink or info.itemID)
    StaticPopup_Show('WoWTools_Item', WoWTools_FoodMixin.addName, nil, {
        link= info.itemLink or itemLink,
        itemID=info.itemID,
        name= e.cn(itemName, {itemID=info.itemID, isName=true}),
        color= {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()},
        texture= itemTexture,
        count=C_Item.GetItemCount(info.itemID, true, true, true, true),
        OnShow=function(self, data)
           self.button1:SetEnabled(not Save().addItems[data.itemID])
           self.button3:SetEnabled(Save().addItems[data.itemID])
        end,
        SetValue = function(_, data)
            Save().addItems[data.itemID]= true
            WoWTools_FoodMixin:Check_Items()
        end,
        OnAlt = function(_, data)
            Save().addItems[data.itemID]= nil
            WoWTools_FoodMixin:Check_Items()
        end
    })
end











local function Init()
    local UseButton= WoWTools_FoodMixin.UseButton
    if not UseButton then
        return
    end

    UseButton.RePoint={UseButton:GetPoint(1)}
    UseButton.texture:SetTexture(538745)

--显示背景 Background
    WoWTools_TextureMixin:CreateBackground(UseButton, {
        point=function(texture)
            texture:SetPoint('BOTTOMRIGHT', 1 , 1)
            texture:SetPoint('TOP', UseButton, 1 , 1)
            texture:SetPoint('LEFT', UseButton, -1 , -1)
        end}
    )
    function UseButton:set_background()
        self.Background:SetShown(Save().isShowBackground)
    end



    function UseButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

    function UseButton:set_point()
        if not self:CanChangeAttribute() then
            return
        end
        self:ClearAllPoints()
        if Save().point and Save().point[1] then
            self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        else
            self:SetPoint(self.RePoint[1], self.RePoint[2], self.RePoint[3], self.RePoint[4], self.RePoint[5])
        end
    end

    function UseButton:set_scale()
        if self:CanChangeAttribute() then
            self:SetScale(Save().scale or 1)
        end
    end


    function UseButton:get_tooltip_item()
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink and self.itemID~=itemID then
            return itemID, itemLink
        end
    end


    UseButton:RegisterForDrag("RightButton")
    UseButton:SetMovable(true)
    UseButton:SetClampedToScreen(true)
    UseButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    UseButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save().point={self:GetPoint(1)}
        Save().point[2]=nil
    end)
    UseButton:SetScript("OnMouseDown", function(self, d)
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            Add_Item({itemID=itemID, itemLink=itemLink})
            ClearCursor()
            return
        end

        if d=='RightButton' then
            if not IsModifierKeyDown() then--菜单
                WoWTools_FoodMixin:Init_Menu(self)
                self:set_tooltip()
            elseif IsAltKeyDown() then--移动
                SetCursor('UI_MOVE_CURSOR')
            end
        end
    end)


    UseButton:SetScript("OnMouseUp", ResetCursor)
    UseButton:SetScript('OnMouseWheel',function(self, d)
        if not IsModifierKeyDown() then
            if not self:CanChangeAttribute() then
                print(WoWTools_FoodMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            else
                WoWTools_FoodMixin:Check_Items(true)
            end
        end
    end)





    function UseButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:ClearLines()
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            GameTooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(itemID), WoWTools_Mixin.onlyChinese and '添加自定义' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, CUSTOM))
        else
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_FoodMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
            GameTooltip:AddDoubleLine((self:CanChangeAttribute() and '' or '|cff9e9e9e')..(WoWTools_Mixin.onlyChinese and '查询' or WHO), e.Icon.mid)

            GameTooltip:AddLine(' ')
            if self.alt then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.alt), 'Alt+'..e.Icon.left)
            end
            if self.ctrl then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.ctrl), 'Ctrl+'..e.Icon.left)
            end
            if self.shift then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.shift), 'Shift+'..e.Icon.left)
            end
            if self.alt or self.ctrl or self.shift then
                GameTooltip:AddLine(' ')
            end
            GameTooltip:AddDoubleLine(
                (Save().onlyMaxExpansion and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')
                ..(WoWTools_Mixin.onlyChinese and '仅当前版本物品'
                    or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, GAME_VERSION_LABEL))
                ),
                e.GetEnabeleDisable(Save().onlyMaxExpansion)
            )
        end
        GameTooltip:Show()
    end

    UseButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()--查询，背包里物品
        self:set_alpha()
        self:set_count()
        self:set_cool()
        self:set_desaturated()
        self:SetScript('OnUpdate', nil)
        self.elapsed=nil
    end)

    function UseButton:set_update(elapsed)
        self.elapsed= (self.elapsed or 1) +elapsed
        if self.elapsed>=1 then
            self.elapsed=0
            self:set_tooltip()
        end
    end
    UseButton:SetScript("OnEnter",function(self)
        if self.alt or self.ctrl or self.shift then
            self:SetScript('OnUpdate', self.set_update)
        else
            self:set_tooltip()
        end
        self:settings()
        if self:CanChangeAttribute() then
            self:set_attribute()
        end
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)


    UseButton:SetAttribute('type1', 'item')
    UseButton:SetAttribute('alt-type1', 'spell')
    UseButton:SetAttribute('ctrl-type1', 'spell')
    UseButton:SetAttribute('shift-type1', 'spell')


    if Save().point then
        UseButton:set_point()
    end
    UseButton:set_strata()
    UseButton:set_scale()
    UseButton:set_background()

    WoWTools_FoodMixin:Set_Button_Function(UseButton)
    UseButton:settings()
    UseButton:set_attribute()
end



function WoWTools_FoodMixin:Init_Button()
    Init()
end