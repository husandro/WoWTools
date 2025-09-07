
local function Save()
    return WoWToolsSave['Tools_Foods']
end










local function Add_Item(info)
    local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(info.itemLink or info.itemID)
    StaticPopup_Show('WoWTools_Item', WoWTools_FoodMixin.addName, nil, {
        link= info.itemLink or itemLink,
        itemID=info.itemID,
        name= WoWTools_TextMixin:CN(itemName, {itemID=info.itemID, isName=true}),
        color= {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()},
        texture= itemTexture,
        count=C_Item.GetItemCount(info.itemID, true, true, true, true),
        OnShow=function(self, data)
            local b1= self.button1 or self:GetButton1()
            local b3= self.button3 or self:GetButton3()
            b1:SetEnabled(not Save().addItems[data.itemID])
            b3:SetEnabled(Save().addItems[data.itemID])
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











local function Init(btn)
    btn.RePoint={btn:GetPoint(1)}
    btn.texture:SetTexture(538745)

--显示背景 Background
    WoWTools_TextureMixin:CreateBG(btn, {
        point=function(texture)
            texture:SetPoint('BOTTOMRIGHT', 1 , 1)
            texture:SetPoint('TOP', btn, 1 , 1)
            texture:SetPoint('LEFT', btn, -1 , -1)
        end}
    )
    function btn:set_background()
        --self.Background:SetShown(Save().isShowBackground)
        self.Background:SetAlpha(Save().bgAlpha or 0.5)
    end



    function btn:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

    function btn:set_point()
        if not self:CanChangeAttribute() then
            return
        end
        self:ClearAllPoints()
        if Save().point and Save().point[1] then
            self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
            self:SetParent(UIParent)
        else
            self:SetPoint(self.RePoint[1], self.RePoint[2], self.RePoint[3], self.RePoint[4], self.RePoint[5])
            self:SetParent()
        end
    end

    function btn:set_scale()
        if self:CanChangeAttribute() then
            self:SetScale(Save().scale or 1)
        end
    end


    function btn:get_tooltip_item()
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink and self.itemID~=itemID then
            return itemID, itemLink
        end
    end


    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)
    btn:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self) then
            self:StartMoving()
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
    end)
    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().point={self:GetPoint(1)}
            Save().point[2]=nil
        end
        if self:CanChangeAttribute() then
            self:SetParent(UIParent)
        end
        self:UnregisterEvent('PLAYER_REGEN_DISABLED')
    end)
    btn:SetScript("OnMouseDown", function(self, d)
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
            elseif IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self) then--移动
                SetCursor('UI_MOVE_CURSOR')
            end
        end
    end)


    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript('OnMouseWheel',function(self, d)
        if not IsModifierKeyDown() then
            if not self:CanChangeAttribute() then
                print(WoWTools_FoodMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            else
                WoWTools_FoodMixin:Check_Items(true)
            end
        end
    end)





    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:ClearLines()
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            GameTooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(itemID), WoWTools_DataMixin.onlyChinese and '添加自定义' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, CUSTOM))
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FoodMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine((self:CanChangeAttribute() and '' or '|cff9e9e9e')..(WoWTools_DataMixin.onlyChinese and '查询' or WHO), WoWTools_DataMixin.Icon.mid)

            GameTooltip:AddLine(' ')
            if self.alt then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.alt), 'Alt+'..WoWTools_DataMixin.Icon.left)
            end
            if self.ctrl then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.ctrl), 'Ctrl+'..WoWTools_DataMixin.Icon.left)
            end
            if self.shift then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.shift), 'Shift+'..WoWTools_DataMixin.Icon.left)
            end
            if self.alt or self.ctrl or self.shift then
                GameTooltip:AddLine(' ')
            end
            GameTooltip:AddDoubleLine(
                (Save().onlyMaxExpansion and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e')
                ..(WoWTools_DataMixin.onlyChinese and '仅当前版本物品'
                    or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, GAME_VERSION_LABEL))
                ),
                WoWTools_TextMixin:GetEnabeleDisable(Save().onlyMaxExpansion)
            )
        end
        GameTooltip:Show()
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()--查询，背包里物品
        self:set_alpha()
        self:set_count()
        self:set_cool()
        self:set_desaturated()
        self:SetScript('OnUpdate', nil)
        --self.elapsed=nil
    end)

    --[[function btn:set_update(elapsed)
        self.elapsed= (self.elapsed or 1) +elapsed
        if self.elapsed>=1 then
            self.elapsed=0
            self:set_tooltip()
        end
    end]]
    btn:SetScript("OnEnter",function(self)
        if self.alt or self.ctrl or self.shift then
            local Elapsed= 1
            self:SetScript('OnUpdate', function(s, elapsed)
                Elapsed= (Elapsed or 1) + elapsed
                if Elapsed>=1 then
                    Elapsed=0
                    s:set_tooltip()
                end
            end)
        else
            self:set_tooltip()
        end
        self:settings()
        if self:CanChangeAttribute() then
            self:set_attribute()
        end
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)


    btn:SetAttribute('type1', 'item')
    btn:SetAttribute('alt-type1', 'spell')
    btn:SetAttribute('ctrl-type1', 'spell')
    btn:SetAttribute('shift-type1', 'spell')


    if Save().point then
        btn:set_point()
    end
    btn:set_strata()
    btn:set_scale()
    btn:set_background()

    WoWTools_FoodMixin:Set_Button_Function(btn)
    btn:settings()
    btn:set_attribute()
end



function WoWTools_FoodMixin:Init_Button()
    Init(self.Button)
end