

local function Save()
    return WoWToolsSave['Tools_OpenItems']
end

local Events_All={
    'BAG_UPDATE_COOLDOWN',
    'BAG_UPDATE_DELAYED',
    'PLAYER_REGEN_DISABLED',
    'PLAYER_REGEN_ENABLED',
    'PET_BATTLE_CLOSE',
    'PET_BATTLE_OPENING_DONE',
    'ZONE_CHANGED_NEW_AREA',
}

local Event_Unit={
    'UNIT_ENTERED_VEHICLE',--车辆
    'UNIT_EXITED_VEHICLE',
}










local function Init()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('OpenItems')
    if not btn then
        return
    end

    btn.count= btn:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    btn.count:SetFontHeight(12)
    btn.count:SetPoint('BOTTOMRIGHT')
    btn.noText= '|A:talents-button-reset:0:0|a'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
    btn.useText= '|A:jailerstower-wayfinder-rewardcheckmark:0:0|a'..(WoWTools_DataMixin.onlyChinese and '使用' or USE)

    WoWTools_KeyMixin:Init(btn, function() return Save().KEY end)

    Mixin(btn, WoWTools_ItemLocationMixin)

    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local bagID, slotIndex= self:GetBagAndSlot()
        if self:IsBagAndSlot() then
            local itemLink= C_Container.GetContainerItemLink(bagID, slotIndex)
            if itemLink and itemLink:find('Hbattlepet:%d+') then
                BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
                GameTooltip:Hide()
            else
                GameTooltip:SetBagItem(bagID, slotIndex)
                if self:CanChangeAttribute() then
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.mid..'|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP), self.noText)
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), (WoWTools_KeyMixin:IsKeyValid(self) or '')..WoWTools_DataMixin.Icon.left)
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.mid..'|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN), WoWTools_DataMixin.onlyChinese and '刷新' or REFRESH)
                    GameTooltip:Show()
                end

                if (BattlePetTooltip) then
                    BattlePetTooltip:Hide()
                end
            end
            WoWTools_BagMixin:Find(true, {itemLink= itemLink})--查询，背包里物品
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_OpenItemMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), WoWTools_KeyMixin:IsKeyValid(self))
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.mid..'|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN), WoWTools_DataMixin.onlyChinese and '刷新' or REFRESH)
            GameTooltip:Show()
            if (BattlePetTooltip) then
                BattlePetTooltip:Hide()
            end
        end


    end


    btn:SetScript("OnEnter",  function(self)
        WoWTools_OpenItemMixin:Get_Item()
        WoWTools_KeyMixin:SetTexture(self)
        WoWTools_ToolsMixin:EnterShowFrame(self)
        self:set_tooltips()
        local Elapsed= 0.3
        self:SetScript('OnUpdate', function (s, elapsed)
            Elapsed = Elapsed + elapsed
            if Elapsed > 0.3 then
                Elapsed = 0
                if GameTooltip:IsOwned(s) then
                    local itemID= s:GetItemID()
                    if itemID then
                        if itemID~=select(3, GameTooltip:GetItem()) then
                            s:set_tooltips()
                        end
                    else
                        WoWTools_OpenItemMixin:Get_Item()
                    end
                end
            end
        end)
    end)
    btn:SetScript("OnLeave",function(self)
        GameTooltip_Hide()
        ResetCursor()
        WoWTools_OpenItemMixin:Get_Item()
        WoWTools_BagMixin:Find(false)--查询，背包里物品
        self:SetScript('OnUpdate',nil)
    end)


    btn:SetScript("OnMouseDown", function(self,d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            if self:IsValid() and self:GetItemID()==itemID then
                return
            end
            WoWTools_OpenItemMixin:Edit_Item(self, {itemID=itemID, itemLink=itemLink})
            ClearCursor()
            return
        end


        local key= IsModifierKeyDown()
        if (d=='RightButton' and not key) then
            WoWTools_OpenItemMixin:Setup_Menu()
        else
            if d=='LeftButton' and not key and btn.IsEquipItem and not PaperDollFrame:IsVisible() then
                ToggleCharacter("PaperDollFrame")
            end
            if MerchantFrame:IsShown() and MerchantFrame:CanChangeAttribute() then
                MerchantFrame:Hide()
            end
            if SendMailFrame:IsShown() and SendMailFrame:CanChangeAttribute() then
                MailFrame:Hide()
            end
            if ScrappingMachineFrame and ScrappingMachineFrame:IsShown() and ScrappingMachineFrame:CanChangeAttribute() then
                ScrappingMachineFrame:Hide()
            end
        end
    end)

    btn:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        if d == 1 then
            self:set_disabled_current_item()--禁用当物品
            self:set_tooltips()
        elseif d==-1 then
            self:settings()
        end
    end)
    btn:SetScript('OnShow', function(self)
        self:settings()
        WoWTools_OpenItemMixin:Get_Item()
    end)

    btn:SetScript('OnHide', function(self)
        self:settings()
    end)



    btn:SetScript('OnEvent', function(self, event)

        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_MAP_CHANGED' then--出进副本
            C_Timer.After(1, function()
                if not InCombatLockdown() then
                    self:SetShown(not IsInInstance() or WoWTools_MapMixin:IsInDelve())
                end
                self:settings()
            end)

        elseif event=='PLAYER_MOUNT_DISPLAY_CHANGED'--上下坐骑
            or event=='UNIT_ENTERED_VEHICLE'--车辆
            or event=='UNIT_EXITED_VEHICLE'
            or event=='PET_BATTLE_CLOSE'
            or event=='PET_BATTLE_OPENING_DONE'
            or event=='ZONE_CHANGED_NEW_AREA'

        then
            self:settings()

        elseif event=='BAG_UPDATE_COOLDOWN' then--冷却
            self:set_cooldown()

        elseif event=='PLAYER_REGEN_DISABLED' then
            ClearOverrideBindings(self)--清除KEY
            WoWTools_KeyMixin:SetTexture(self)

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set_key(false)
            if self.isInCombat then
                WoWTools_OpenItemMixin:Get_Item()
            end

        elseif event=='BAG_UPDATE_DELAYED' then
            WoWTools_OpenItemMixin:Get_Item()
        end
    end)







    btn:RegisterEvent('PLAYER_MAP_CHANGED')
    btn:RegisterEvent('PLAYER_ENTERING_WORLD')

    function btn:settings()
        self.isDisabled= (IsInInstance() and not WoWTools_MapMixin:IsInDelve())
                        or not self:IsVisible()
                        or C_PetBattles.IsInBattle()
                        or UnitHasVehicleUI('player')

        if self.isDisabled then
            FrameUtil.UnregisterFrameForEvents(self, Events_All)
            FrameUtil.UnregisterFrameForEvents(self, Event_Unit)
        else
            FrameUtil.RegisterFrameForEvents(self, Events_All)
            FrameUtil.RegisterFrameForUnitEvents(self, Event_Unit, 'player')
        end

        if Save().KEY and not self.isDisabled then
            self:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')--上下坐骑
        else
            self:UnregisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
        end

        if self:CanChangeAttribute() and not InCombatLockdown() then
            self:set_key()
            self:SetShown(not self.isDisabled)
        else
            self.isInCombat=true
        end
    end




--设置捷键
    function btn:set_key(isDisabled)
        if Save().KEY then
            WoWTools_KeyMixin:Setup(self,
                self.isDisabled
                or not self:IsValid()
                or IsMounted()
                or UnitInVehicle('player')
                or C_PetBattles.IsInBattle()
                or (IsInInstance() and not WoWTools_MapMixin:IsInDelve())
                or isDisabled
            )
        end
    end

--是否已绑定KEY
    function btn:get_key()
        local key= Save().KEY
        if key then
            local col= C_KeyBindings.GetBindingByKey(key)==self:GetName()..':LeftButton' and '|cnGREEN_FONT_COLOR:' or '|cff828282'
            return col..(WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..'|r'
        end
    end

--冷却条
    function btn:set_cooldown()
        local start, duration, enable
        if self:IsValid() then
            start, duration, enable = self:GetItemCooldown()
            self.texture:SetDesaturated(not enable)
        end
        WoWTools_CooldownMixin:Setup(self, start, duration, nil, true,nil, true)
    end


--禁用当物品
    function btn:set_disabled_current_item()
        if self:IsValid() then
            local itemID= self:GetItemID()
            if itemID then
                Save().no[itemID]=true
                Save().use[itemID]=nil
            end
            WoWTools_OpenItemMixin:Get_Item()
        end
        return MenuResponse.Open
    end






    btn:settings()

    WoWTools_OpenItemMixin:Get_Item()

    Init=function()end
end













function WoWTools_OpenItemMixin:Init_Button()
    Init()
end