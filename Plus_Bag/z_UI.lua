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
    print(ElvUI_ContainerFrame)
if _G['ElvUI_ContainerFrame'] then
    return
end
    local function set_script(frame)
        WoWTools_DataMixin:Hook(frame, 'UpdateItems', function(f)
            for _, btn in f:EnumerateValidItems() do
                if not btn.isSetTexture then
                    self:SetAlphaColor(btn.ItemSlotBackground, nil, nil, 0)
                    self:SetAlphaColor(btn.Background,nil, nil, 0)
                    self:SetAlphaColor(btn.NormalTexture, true, nil)
                    btn.isSetTexture=true
                end

                if f:GetID()<= NUM_TOTAL_BAG_FRAMES+1 then--银行，自定义
                    btn.NormalTexture:SetAlpha(btn.hasItem and 0 or 0.3)
                end
                btn.icon:SetAlpha(btn.hasItem and 1 or 0)
            end
        end)
        WoWTools_DataMixin:Hook(frame, 'UpdateName', function(f) f:SetTitle('') end)
        self:SetButton(frame.CloseButton)
    end

--ContainerFrame1 到 13 11.2版本是 6
    for bagID= 1, NUM_CONTAINER_FRAMES do--NUM_TOTAL_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do--6
        local frame= _G['ContainerFrame'..bagID]
        if frame then
            frame.Bg:SetFrameStrata('LOW')
            self:Init_BGMenu_Frame(frame, {
                settings=function(icon, texture, alpha)
                    icon:GetParent().Bg:SetAlpha(texture and 0 or alpha or 1)
                end
            })
            set_script(frame)
        end
    end
    self:HideFrame(ContainerFrame1MoneyFrame.Border)

--ContainerFrameCombinedBags
    self:HideFrame(ContainerFrameCombinedBags.MoneyFrame.Border)
    self:HideFrame(BackpackTokenFrame.Border)
    self:SetEditBox(BagItemSearchBox)
    set_script(ContainerFrameCombinedBags)


    self:Init_BGMenu_Frame(ContainerFrameCombinedBags, {
        settings=function(icon, texture, alpha)
            icon:GetParent().Bg:SetAlpha(texture and 0 or alpha or 1)
        end
    })
end
















--小，背包
--NUM_CONTAINER_FRAMES 11.2版本是 6， 以前是13
--NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do--13 NUM_CONTAINER_FRAMES = 13
--or i== NUM_TOTAL_BAG_FRAMES+2 then
function WoWTools_MoveMixin.Frames:ContainerFrame1()
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
