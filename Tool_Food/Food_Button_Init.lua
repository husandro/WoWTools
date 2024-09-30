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
        self:ClearAllPoints()
        if Save().point and Save().point[1] then
            self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        else
            self:SetPoint(self.RePoint[1], self.RePoint[2], self.RePoint[3], self.RePoint[4], self.RePoint[5])
        end
    end

    function UseButton:set_scale()
        if not UnitAffectingCombat('player') then
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
            if UnitAffectingCombat('player') then
                print(WoWTools_FoodMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            else
                WoWTools_FoodMixin:Check_Items(true)
            end
        end
    end)





    function UseButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT");
        e.tips:ClearLines()
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            e.tips:AddDoubleLine(WoWTools_ItemMixin:GetName(itemID), e.onlyChinese and '添加自定义' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, CUSTOM))
        else
            e.tips:AddDoubleLine(e.addName, WoWTools_FoodMixin.addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
            e.tips:AddDoubleLine((UnitAffectingCombat('player') and '|cff9e9e9e' or '')..(e.onlyChinese and '查询' or WHO), e.Icon.mid)

            e.tips:AddLine(' ')
            if self.alt then
                e.tips:AddDoubleLine(WoWTools_SpellMixin:GetName(self.alt), 'Alt+'..e.Icon.left)
            end
            if self.ctrl then
                e.tips:AddDoubleLine(WoWTools_SpellMixin:GetName(self.ctrl), 'Ctrl+'..e.Icon.left)
            end
            if self.shift then
                e.tips:AddDoubleLine(WoWTools_SpellMixin:GetName(self.shift), 'Shift+'..e.Icon.left)
            end
            if self.alt or self.ctrl or self.shift then
                e.tips:AddLine(' ')
            end
            e.tips:AddDoubleLine(
                (Save().onlyMaxExpansion and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')
                ..(e.onlyChinese and '仅当前版本物品'
                    or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, GAME_VERSION_LABEL))
                ),
                e.GetEnabeleDisable(Save().onlyMaxExpansion)
            )
        end

        e.tips:Show()
    end

    UseButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()--查询，背包里物品
        self:set_alpha()
        self:SetScript('OnUpdate', nil)
        self.elapsed=nil
        self:set_count()
        self:set_cool()
        self:set_desaturated()
    end)
    UseButton:SetScript("OnEnter",function(self)
        self:set_tooltip()
        if self.alt then
            self.elapsed=0
            self:SetScript('OnUpdate', function(f, elapsed)
                f.elapsed= f.elapsed +elapsed
                if f.elapsed>=1 then
                    f.elapsed=0
                    f:set_tooltip()
                end
            end)
        end
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)


    UseButton:SetAttribute('type1', 'item')
    UseButton:SetAttribute('alt-type1', 'spell')
    UseButton:SetAttribute('alt-type1', 'spell')
    UseButton:SetAttribute('ctrl-type1', 'spell')


    if Save().point then
        UseButton:set_point()
    end
    UseButton:set_strata()
    UseButton:set_scale()
    UseButton:set_background()

    WoWTools_FoodMixin:Set_Button_Function(UseButton)
    UseButton:settings()
end



function WoWTools_FoodMixin:Init_Button()
    Init()
end