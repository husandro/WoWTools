--梦境之种
if PlayerGetTimerunningSeasonID() then
    return
end

local id, e = ...
if e.Player.level<70 then
    return
end

local Save={
    disabled= not e.Player.husandro,
    scale= e.Player.husandro and 0.85 or 1,
}

local addName
local Button
local CurrencyID= 2650
local ItemTab={
    208066,--小小的梦境之种
    208067,--饱满的梦境之种
    208047,--硕大的梦境之种
   -- 210014
}
for _, itemID in pairs(ItemTab) do
    WoWTools_Mixin:Load({id=itemID, type='item'})
end










local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(nil, {size=22, icon='hide'})

    function Button:set_Point()
        if not self:CanChangeAttribute() then
            return
        end
        self:ClearAllPoints()
        if Save.point then
            self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPRIGHT', PlayerFrame, 'TOPLEFT',0,15)
        else
            self:SetPoint('CENTER', -400, 200)
        end
    end
    function Button:set_Scale()
        if self:CanChangeAttribute() then
            self:SetScale(Save.scale or 1)
        end
    end
    function Button:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, addName)
        e.tips:AddLine(' ')
        for _, itemID in pairs(ItemTab) do
            local link= WoWTools_ItemMixin:GetLink(itemID)
            local icon
            icon= C_Item.GetItemIconByID(itemID)
            icon= icon and '|T'..icon..':0|t' or ''
            local num
            num= C_Item.GetItemCount(itemID)
            num= num>0 and '|cnGREEN_FONT_COLOR:'..num or ('|cnRED_FONT_COLOR:'..num)
            e.tips:AddDoubleLine(icon..link, num)
        end
        if CurrencyID and CurrencyID>0 then
            local info= C_CurrencyInfo.GetCurrencyInfo(CurrencyID)
            if info and info.quantity and info.name then
                e.tips:AddDoubleLine((info.iconFileID and '|T'..info.iconFileID..':0|t' or '')..info.name, info.quantity)
            end
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        local col= not self:CanChangeAttribute() and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.scale or 1), col..('Alt+'..e.Icon.mid))
        col= not Save.point and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '重置位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
        e.tips:Show()
    end


    Button:SetClampedToScreen(true)
    Button:SetMovable(true)
    Button:RegisterForDrag("RightButton")
    Button:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    Button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)

    Button:SetScript("OnMouseUp", ResetCursor)
    Button:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then--移动
            SetCursor('UI_MOVE_CURSOR');
        elseif d=='RightButton' and IsControlKeyDown() then--还原
            if self:CanChangeAttribute() then
                Save.point=nil
                self:set_Point()
                print(WoWTools_Mixin.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        end
    end)
    Button:SetScript('OnMouseWheel',function(self, d)
        if not IsAltKeyDown() or not self:CanChangeAttribute() then
            return
        end
        local scale= Save.scale or 1
        if d==1 then
            scale= scale+ 0.05
        elseif d==-1 then
            scale= scale- 0.05
        end
        scale= scale>4 and 4 or scale
        scale= scale<0.4 and 0.4 or scale
        Save.scale=scale
        self:set_Scale()
        self:set_Tooltips()
    end)
    Button:SetScript('OnLeave', function()
        e.tips:Hide()
        ResetCursor()
        --self.texture:SetAlpha(0.5)
    end)
    Button:SetScript('OnEnter', function(self)
        self:set_Tooltips()
        self:set_button()
        --self.texture:SetAlpha(1)
    end)

    --货币，数量
    if CurrencyID and CurrencyID>0 then
        Button.label=WoWTools_LabelMixin:Create(Button, {color=true})
        Button.label:SetPoint('BOTTOMRIGHT')
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(CurrencyID) or {}
        if currencyInfo.iconFileID then
            Button:SetNormalTexture(currencyInfo.iconFileID)
        end
        function Button:set_Currency()
            local info = C_CurrencyInfo.GetCurrencyInfo(CurrencyID) or {}
            self.label:SetText(info.quantity and info.quantity>0 and WoWTools_Mixin:MK(info.quantity, 0) or '')
        end
        Button:set_Currency()
    else
        Button:SetNormalTexture(e.Icon.icon)
    end

    function Button:set_Event()
        self:UnregisterAllEvents()
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:RegisterEvent('PLAYER_MAP_CHANGED')
        if self.uiMapID then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            --self:RegisterEvent('BAG_UPDATE')
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')
            if CurrencyID and CurrencyID>0 then
                self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
            end
        end
        self:set_Shown()
    end
    function Button:set_Shown(show)
        if self:CanChangeAttribute() then
            self:SetShown(
                show or (self.uiMapID and not C_PetBattles.IsInBattle() and not IsInInstance())
            )
        end
    end
    function Button:get_UIMapID()
        self.uiMapID= C_Map.GetBestMapForUnit('player')==2200 and true or false
    end
    Button:SetScript("OnEvent", function(self, event, arg1)
        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_MAP_CHANGED' then
            self:get_UIMapID()
            if self:CanChangeAttribute() then
                self:set_Event()
            end
        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set_button()
            self:set_Shown()
        elseif event=='BAG_UPDATE_DELAYED' then--event=='BAG_UPDATE' or 
            self:set_button()
        elseif event=='CURRENCY_DISPLAY_UPDATE' then--货币，数量
            if arg1==CurrencyID and CurrencyID and CurrencyID>0 then
                self:set_Currency()
            end
        end

        if self:CanChangeAttribute() then
            self:set_Shown()
        end
    end)



    Button.btn={}
    function Button:set_button(show)
        if UnitAffectingCombat('player') then
            return
        end
        local index=1
        for _, itemID in pairs(ItemTab) do
            local num= C_Item.GetItemCount(itemID)
            if num>0 or show then
                local btn= self.btn[index]
                if not btn then
                    btn= WoWTools_ButtonMixin:Cbtn(self, {type=true, button='ItemButton', icon='hide'})
                    btn:SetAttribute('type*', 'item')
                    btn:SetPoint('TOP', index==1 and Button or self.btn[index-1], 'BOTTOM', 0, -6)
                    btn:SetScript('OnEnter', function(self2)
                        if self2.itemID  then
                            e.tips:SetOwner(self, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetItemByID(self2.itemID)
                            e.tips:Show()
                        end
                    end)
                    btn:SetScript('OnLeave', GameTooltip_Hide)
                    btn:UpdateItemContextOverlayTextures(1)
                    self.btn[index]= btn
                end
                if btn.itemID~= itemID then
                    btn.itemID= itemID
                    local name=C_Item.GetItemNameByID(itemID) or C_Item.GetItemInfo(itemID) or itemID
                    btn:SetAttribute('item*', name)
                    btn:SetItem(itemID)
                end
                btn:SetItemButtonCount(C_Item.GetItemCount(itemID))
                index= index+1
                btn:SetShown(true)
            end
        end
        for i= index, #self.btn do
            local btn= self.btn[i]
            if btn then
                btn:Reset()
                btn:SetShown(false)
            end
        end
    end

    Button:set_Point()
    Button:set_button()
    Button:set_Scale()
    Button:get_UIMapID()
    Button:set_Event()

    return true
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWToolsSave['DormantSeeds']= nil
            Save= WoWToolsSave['Other_DormantSeeds'] or Save

            if not PlayerGetTimerunningSeasonID() then
                addName= '|T656681:0|t'..(e.onlyChinese and '梦境之种' or 'DormantSeeds')

                e.AddPanel_Check_Button({
                    checkName= addName,
                    GetValue= function() return not Save.disabled end,
                    SetValue= function()
                        Save.disabled = not Save.disabled and true or nil
                        if Button then
                            Button:set_Shown(not Save.disabled)
                            Button:set_button(not Save.disabled)
                            print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                        elseif not Save.disabled then
                            if Init() then Init=function()end end
                        end
                    end,
                    buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                    buttonFunc= function()
                        Save.Point=nil
                        if Button then
                            Button:set_Point()
                        end
                        print(WoWTools_Mixin.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                    end,
                    tooltip=function()
                        return e.cn(C_Item.GetItemNameByID(2200), {itemID=2200, isName=true}) or addName
                    end,
                    layout= WoWTools_OtherMixin.Layout,
                    category= WoWTools_OtherMixin.Category,
                })

                if not Save.disabled then
                    if Init() then Init=function()end end
                end
            end

            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Other_DormantSeeds']=Save
        end
    end
end)

