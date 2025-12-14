--[[
NUM_CONTAINER_FRAMES = 13; 11.2版本是 6
NUM_BAG_FRAMES = Constants.InventoryConstants.NumBagSlots; 4
NUM_REAGENTBAG_FRAMES = Constants.InventoryConstants.NumReagentBagSlots; 1
NUM_TOTAL_BAG_FRAMES = Constants.InventoryConstants.NumBagSlots + Constants.InventoryConstants.NumReagentBagSlots; 5
CONTAINER_OFFSET_Y = 85;
CONTAINER_OFFSET_X = -4;
]]




--背包 Bg FlatPanelBackgroundTemplate
function WoWTools_TextureMixin.Frames:ContainerFrame1()
    if _G['ElvUI_ContainerFrame'] then
        return
    end

    self:SetButton(BagItemAutoSortButton, {alpha=1})

    local function set_script(frame)
        WoWTools_DataMixin:Hook(frame, 'UpdateItems', function(f)
            local bg= self:Save().bagBorderAlpha or 0.2
            for _, btn in f:EnumerateValidItems() do
                if not btn.isSetTexture then
                    self:SetAlphaColor(btn.ItemSlotBackground, nil, nil, 0)
                    self:SetAlphaColor(btn.Background,nil, nil, 0)
                    self:SetAlphaColor(btn.NormalTexture, true, nil)
                    btn.isSetTexture=true
                end

                if f:GetID()<= NUM_TOTAL_BAG_FRAMES+1 then--银行，自定义
                    btn.NormalTexture:SetAlpha(btn.hasItem and 0 or bg)
                end
                btn.icon:SetAlpha(btn.hasItem and 1 or 0)
            end
        end)
        WoWTools_DataMixin:Hook(frame, 'UpdateName', function(f) f:SetTitle('') end)
        self:SetButton(frame.CloseButton)
    end

    local function Refresh_Bag(frame)
        if InCombatLockdown() or not frame.AddItemsForRefresh then
            return
        end
        if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsVisible() and ContainerFrameCombinedBags.AddItemsForRefresh then
            ContainerFrameCombinedBags:AddItemsForRefresh()
        end
        for bagID= 1, NUM_CONTAINER_FRAMES do--NUM_TOTAL_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do--6
        local f= _G['ContainerFrame'..bagID]
            if f and f:IsVisible() and f.AddItemsForRefresh then
                f:AddItemsForRefresh()
            end
        end
    end

    local function Set_BGMenu(frame)
        frame.Bg:SetFrameStrata('LOW')
        set_script(frame)
        self:Init_BGMenu_Frame(frame, {
            settings=function(icon, texture, alpha)
                icon:GetParent().Bg:SetAlpha(texture and 0 or alpha or 1)
            end,
            addMenu=function(f, root)
                root:CreateSpacer()
                WoWTools_MenuMixin:CreateSlider(root, {
                    getValue=function()
                            return self:Save().bagBorderAlpha or 0.2
                        end,
                    setValue=function(value)
                            self:Save().bagBorderAlpha = value
                            Refresh_Bag(f)
                        end,
                    name='Border',
                    minValue=0,
                    maxValue=1,
                    step=0.01,
                    bit='%.2f',
                })
                root:CreateSpacer()
            end
        })
    end

--ContainerFrame1 到 13 11.2版本是 6
    for bagID= 1, NUM_CONTAINER_FRAMES do--NUM_TOTAL_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do--6
        local frame= _G['ContainerFrame'..bagID]
        if frame then
            Set_BGMenu(frame)
        end
    end
    self:HideFrame(ContainerFrame1MoneyFrame.Border)

--ContainerFrameCombinedBags
    self:HideFrame(ContainerFrameCombinedBags.MoneyFrame.Border)
    self:HideFrame(BackpackTokenFrame.Border)
    self:SetEditBox(BagItemSearchBox)
    Set_BGMenu(ContainerFrameCombinedBags)
end
















--小，背包
--NUM_CONTAINER_FRAMES 11.2版本是 6， 以前是13
--NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do--13 NUM_CONTAINER_FRAMES = 13
--or i== NUM_TOTAL_BAG_FRAMES+2 then
function WoWTools_MoveMixin.Frames:ContainerFrame1()
    if C_AddOns.IsAddOnLoaded('Blizzmove') then
        print(self.addName..WoWTools_DataMixin.Icon.icon2,
            format(WoWTools_DataMixin.onlyChinese and '|cffff0000与%s发生冲突！|r' or ALREADY_BOUND, 'Blizzmove'),
            'ContainerFrame1', WoWTools_TextMixin:GetEnabeleDisable(false)
        )
        return
    end

    for i=1, NUM_CONTAINER_FRAMES do
        local frame= _G['ContainerFrame'..i]
        if frame then
            if i==1 then
                self:Setup(frame, {
                    restPointFunc=function()
                        if not InCombatLockdown() then
                            WoWTools_DataMixin:Call('UpdateContainerFrameAnchors')
                        end
                    end
                })
            else
                self:Setup(frame, {notSave=true})
            end
        end
    end

    WoWTools_DataMixin:Hook('UpdateContainerFrameAnchors', function()--ContainerFrame.lua
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            self:Set_SizeScale(frame)
            if frame==ContainerFrameCombinedBags or frame==ContainerFrame1 then--位置
                self:SetPoint(frame)--设置, 移动, 位置
            end
        end
    end)

--背包
    self:MoveAlpha(BagsBar)

    self:Setup(ContainerFrameCombinedBags)
end
