local id, e= ...
local addName= ITEM_UPGRADE--物品升级
local Save= {
}
local Initializer




--添加一个按钮, 打开，角色界面
local function add_Button_OpenOption(frame)
    if not frame then
        return
    end
    local btn= e.Cbtn(frame, {atlas='charactercreate-icon-customize-body-selected', size={40,40}})
    btn:SetPoint('TOPRIGHT',-5,-25)
    btn:SetScript('OnClick', function()
        ToggleCharacter("PaperDollFrame")
    end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:Show()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    if frame==ItemUpgradeFrameCloseButton then--装备升级, 界面
        --物品，货币提示
        e.ItemCurrencyLabel({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
        btn:SetScript("OnEvent", function()
            --物品，货币提示
            e.ItemCurrencyLabel({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
        end)
        btn:SetScript('OnShow', function(self)
            e.ItemCurrencyLabel({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
        end)
        btn:SetScript('OnHide', function(self)
            self:UnregisterAllEvents()
        end)
    end
end







local function Init_ItemInteractionFrame()
    e.Set_Move_Frame(ItemInteractionFrame, {setSize=true, needSize=true, needMove=true, restSizeFunc=function(btn)

    end})
   
    local frame= CreateFrame('EventScrollFrame', nil, ItemInteractionFrame, 'ScrollFrameTemplate')
    frame:SetPoint('TOPRIGHT', ItemInteractionFrame, 'TOPLEFT', -24, 0)
    frame:SetPoint('BOTTOMRIGHT', ItemInteractionFrame, 'BOTTOMLEFT', -24,0)
    frame:SetWidth(253)
    frame.scrollBarHideIfUnscrollable=true
    frame.scrollBarX= -14
    frame.scrollBarTopY= -5
    frame.scrollBarBottomY=1

    --local f= CreateFrame('Frame', nil, frame)
   -- f:SetSize(240, 254)

    local tip= CreateFrame('GameTooltip', nil, frame, 'GameTooltipTemplate')
    tip:SetOwner(frame, "ANCHOR_PRESERVE")
    tip:SetAllPoints(frame)
    --tip:SetClampedToScreen(false)
    --tip:SetScript('OnHide', tip.ClearLines)
    --tip.supportsDataRefresh=true
    --tip.updateTooltipTimer=0
    --tip.IsEmbedded=true
    --tip:SetScript('OnUpdate', GameTooltip_OnUpdate)

    frame:SetScrollChild(tip)
    frame:RegisterCallback("OnScrollRangeChanged", function()
        tip:SetItemInteractionItem()
    end)

    --ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot.Text= e.Cstr(ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot)
    --ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot.Text:SetPoint('LEFT', ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot, 'RIGHT',12,0)
    ItemInteractionFrame.Tip= CreateFrame('GameTooltip', nil, ItemInteractionFrame, 'GameTooltipTemplate')
    hooksecurefunc(ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot, 'RefreshIcon', function(self)
        local itemInteractionFrame = self:GetParent():GetParent()
        local itemLocation = itemInteractionFrame:GetItemLocation()
        --local text=''
        local itemLink
        local show= (itemLocation and itemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.ItemConversion)
        if show then
            --[[tip:SetMinimumWidth(240, true)
            tip:SetOwner(frame, "ANCHOR_PRESERVE")
            tip:SetItemInteractionItem()
            tip:Show()]]

            itemInteractionFrame.Tip:SetItemInteractionItem()
            itemLink= select(2, itemInteractionFrame.Tip:GetItem())
            --[[if itemLink then
                for k, v in pairs(C_Item.GetItemStats(itemLink) or {}) do
                    text= format("%s: %d", e.cn(_G[k]), v)..'|n'..text
                end
            end]]
        end
        e.Set_Item_Stats(self, itemLink, {}) --设置，物品，次属性，表
        --self.Text:SetText(text)
        --frame:SetShown(show)
    end)
end

local panel= CreateFrame('Frame')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= format('|A:Garr_UpgradeIcon:0:0|a%s', e.onlyChinese and '物品升级' or addName),
                --tooltip= e.onlyChinese and '系统背包|n商人' or (BAGSLOT..'|n'..MERCHANT),--'Inventorian, Baggins', 'Bagnon'
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled then
                self:UnregisterEvent("ADDON_LOADED")
            end

        elseif arg1=='Blizzard_ItemInteractionUI' then--套装转换, 界面
            Init_ItemInteractionFrame()
            add_Button_OpenOption(ItemInteractionFrameCloseButton)--添加一个按钮, 打开选项

        elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级, 界面
            add_Button_OpenOption(ItemUpgradeFrameCloseButton)--添加一个按钮, 打开选项
        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
	end
end)