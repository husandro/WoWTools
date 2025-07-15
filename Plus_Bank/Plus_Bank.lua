--[[
整合
NUM_CONTAINER_FRAMES = 13;
NUM_BAG_FRAMES = Constants.InventoryConstants.NumBagSlots; 4
NUM_REAGENTBAG_FRAMES = Constants.InventoryConstants.NumReagentBagSlots; 1
NUM_TOTAL_BAG_FRAMES = Constants.InventoryConstants.NumBagSlots + Constants.InventoryConstants.NumReagentBagSlots; 5
CONTAINER_OFFSET_Y = 85;
CONTAINER_OFFSET_X = -4;
]]
if not BankFrameTab2 then
    return
end


local function Save()
    return WoWToolsSave['Plus_Bank'] or {}
end


local LastButton
local NumLeftButton=0
local NumReagentLeftButton=0
local NumAccountLeftButton=0



local function Set_Frame_Size()--index)
    local x= NumLeftButton + NumReagentLeftButton+ NumAccountLeftButton
    if x>0 then
        local line= Save().line
        local y = Save().num

        BankFrame:SetSize(
            x*(37+line) + 14,

            y*(37+line) + 108
        )
    else
        BankFrame:SetSize(738, 460)
    end
end


local function MoveToLeft_Frame(frame)
    if not WoWTools_FrameMixin:IsLocked(frame) then
        frame:ClearAllPoints()
        frame:SetPoint('RIGHT', UIParent, 'LEFT', -30, 0)
        if frame.ResizeButton then
            frame.ResizeButton:SetClampedToScreen(false)
        end
    end
end








 --索引，提示
 local function Set_IndexLabel(btn, index, frameIndex)
    if not btn.indexLable then
        local color= frameIndex==2 and {r=1,g=0.5,b=0}
                    or (frameIndex==3 and {r=0,g=0.82,b=1})
                    or {r=0,g=1,b=0}
        btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BACKGROUND', color=color})
        btn.indexLable:SetPoint('CENTER')
        btn.indexLable:SetAlpha(0.3)

        WoWTools_TextureMixin:HideTexture(btn.ItemSlotBackground)
        btn.NormalTexture:SetVertexColor(color.r, color.g, color.b)

        WoWTools_TextureMixin:HideTexture(btn.Background)
    end
    btn.indexLable:SetText(Save().showIndex and index or '')
    btn.NormalTexture:SetAlpha(Save().NormalTextureAlpha or 0.5)
end








local function Get_AccountBankButton()
    local tab={}
    for btn in AccountBankPanel:EnumerateValidItems() do
        btn:ClearAllPoints()
        table.insert(tab, 1, btn)
    end
    return tab
end





local function Set_BankSlotsFrame(index)
    if index~=1 then
        return
    end

    local tab={}



--背包
    if not Save().disabledBankBag then
        --local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1
        local isShow, frame
        local maxBagID= NUM_TOTAL_BAG_FRAMES+NUM_REAGENTBAG_FRAMES--6
        for slotID= NUM_CONTAINER_FRAMES, (maxBagID+1), -1 do-- NUM_BANKBAGSLOTS, 1, -1 do
            frame= _G['ContainerFrame'..slotID]
            if frame then
                isShow= frame:IsShown()--select(2, GetInventorySlotInfo("Bag"..(slotID-maxBagID))) and
                for _, btn in frame:EnumerateValidItems()  do
                    if btn then
                        if isShow then
                            table.insert(tab, 1, btn)
                        end

                        btn:SetShown(isShow)
                    end
                end
                MoveToLeft_Frame(frame)
            end
        end
    end

    --基础包
    for i=NUM_BANKGENERIC_SLOTS, 1, -1 do--28
        local btn= BankSlotsFrame["Item"..i]
        if btn then
            btn.index=i
            table.insert(tab, 1, btn)
        end
    end

    LastButton= tab[1]
    LastButton:ClearAllPoints()
    LastButton:SetPoint('TOPLEFT', 8, -60)
    NumLeftButton= 1
    Set_IndexLabel(LastButton, 1, 1)--索引，提示

    local line= Save().line
    local num= Save().num

    for i=2, #tab, 1 do
        local btn= tab[i]
        btn:ClearAllPoints()
        if select(2, math.modf((i-1)/num))==0 then
            btn:SetPoint('LEFT', LastButton, 'RIGHT', line, 0)
            LastButton= btn
            NumLeftButton= NumLeftButton+1
        else
            btn:SetPoint('TOP', tab[i-1], 'BOTTOM', 0, -line)
        end
        Set_IndexLabel(btn, i, 1)--索引，提示
        --Set_IndexLabel(btn, btn:GetID(), 1)--索引，提示

    end
end












local function Set_BankReagent(tabIndex)
    if not IsReagentBankUnlocked() or tabIndex>2 then
        return
    end


    if tabIndex==2 then
        local slotOffsetX = 49;
        local slotOffsetY = 44;
        local index = 1;
        for column = 1, ReagentBankFrame.numColumn or 7 do
            local leftOffset = 6;
            for subColumn = 1, ReagentBankFrame.numSubColumn or 2 do
                for row = 0, ReagentBankFrame.numRow-1 do
                    local button=ReagentBankFrame["Item"..index]
                    if button then
                        Set_IndexLabel(button, index, 2)--索引，提示
                        button:ClearAllPoints()
                        button:SetPoint("TOPLEFT", ReagentBankFrame["BG"..column], "TOPLEFT", leftOffset, -(3+row*slotOffsetY));
                        index = index + 1;
                    end
                end
                leftOffset = leftOffset + slotOffsetX;
            end
        end

    elseif tabIndex==1 and not Save().disabledReagentFrame then--1

        do ReagentBankFrame:SetShown(true) end

        local line= Save().line
        local num= Save().num

        local last
        for index, btn in ReagentBankFrame:EnumerateItems() do
            btn:ClearAllPoints()
            if select(2, math.modf((index-1)/num))==0 then
                btn:SetPoint('LEFT', LastButton, 'RIGHT', line, 0)
                LastButton= btn
                NumReagentLeftButton= NumReagentLeftButton+1
            else
                btn:SetPoint('TOP', last, 'BOTTOM', 0, -line)
            end

            last= btn
            Set_IndexLabel(btn, index, 2)--索引，提示
        end
    end
end











--整合，战团事件
local function Init_All_AccountBankPanel()
    local Data= AccountBankPanel.purchasedBankTabData
    local selectedTabID= AccountBankPanel.selectedTabID or -1

    if not Save().allAccountBag or not Data or #Data<=1 or selectedTabID==-1 then
        return
    end

    local Tab= Get_AccountBankButton()
    local maxButton= C_Container.GetContainerNumSlots(AccountBankPanel.selectedTabID) or 98

    for _, data in pairs(Data) do
        if data.ID~= selectedTabID then
            for containerSlotID = 1, maxButton do
                local btn = AccountBankPanel.itemButtonPool:Acquire()
                btn:Init(data.ID, containerSlotID)

                btn:Show()
                table.insert(Tab, btn)
            end
            AccountBankPanel.selectedTabIDs[data.ID]=true
        end
    end

    local line= Save().line
    local num= Save().num
    local last, leftButton

    for index, btn in pairs(Tab) do
        if index==1 then
			btn:SetPoint("TOPLEFT", AccountBankPanel, "TOPLEFT", 8, -60)
            leftButton=btn
            NumAccountLeftButton=NumAccountLeftButton+1

        elseif select(2, math.modf((index-1)/num))==0 then
            btn:SetPoint('LEFT', leftButton, 'RIGHT', line, 0)
            leftButton= btn
            NumAccountLeftButton=NumAccountLeftButton+1

        else
            btn:SetPoint('TOP', last, 'BOTTOM', 0, -line)
        end
        Set_IndexLabel(btn, index, 3)--btn:GetContainerSlotID())--索引，提示
        last= btn
    end

end


local function Set_AccountBankPanel(index)
    if Save().disabledAccountBag then
        if index==3 and Save().allAccountBag then
            ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged)
            AccountBankPanel:GenerateItemSlotsForSelectedTab()
            Init_All_AccountBankPanel()--整合，战团事件
        end
        return
    end


    if index==1 then
        do
            AccountBankPanel:SetShown(true)
        end

        local Data= AccountBankPanel.purchasedBankTabData or C_Bank.FetchPurchasedBankTabData(Enum.BankType.Account)
        local selectedTabID= AccountBankPanel.selectedTabID or -1

        if not Data or #Data<=1 or selectedTabID==-1 then
            AccountBankPanel:Hide()
            return
        end

        local line= Save().line
        local num= Save().num
        local last
        for i, btn in pairs(Get_AccountBankButton())do

            if select(2, math.modf((i-1)/num))==0 then
                btn:SetPoint('LEFT', LastButton, 'RIGHT', line, 0)
                LastButton= btn
                NumAccountLeftButton= NumAccountLeftButton+1
            else
                btn:SetPoint('TOP', last, 'BOTTOM', 0, -line)
            end
            Set_IndexLabel(btn, i, 3)--btn:GetContainerSlotID())--索引，提示

            last= btn
        end

    elseif index==3 then
        ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged)
        AccountBankPanel:GenerateItemSlotsForSelectedTab()
        Init_All_AccountBankPanel()--整合，战团事件
    end
end

















local function Settings()
    NumLeftButton=0
    NumReagentLeftButton= 0
    NumAccountLeftButton= 0
    AccountBankPanel.selectedTabIDs={}
    local index= BankFrame.activeTabIndex or 1
    do Set_BankSlotsFrame(index) end
    do Set_BankReagent(index) end
    do Set_AccountBankPanel(index) end
    Set_Frame_Size()
end












local function Init()

--背包，需要这个函数 ContainerFrame7 - 13 <Frame name="ContainerFrame7" inherits="ContainerFrameBankTemplate"/>
    function BankSlotsFrame:IsCombinedBagContainer()
        return false
    end

    hooksecurefunc('BankFrame_ShowPanel', function() Settings() end)
    hooksecurefunc('BankFrameItemButtonBag_OnClick', function() Settings() end)
    hooksecurefunc(BankPanelTabMixin, 'OnClick', function() Settings() end)


--当整合银行背包时，隐藏ContainerFrame7 到 13
    hooksecurefunc('UpdateContainerFrameAnchors', function()--ContainerFrame.lua
        if not Save().disabledBankBag and BankFrame:IsShown() then
            for slotID= NUM_CONTAINER_FRAMES, (NUM_TOTAL_BAG_FRAMES+NUM_REAGENTBAG_FRAMES+1), -1 do-- 13 到 7
                local frame= _G['ContainerFrame'..slotID]
                if frame and frame:IsShown() then
                    MoveToLeft_Frame(frame)
                end
            end
        end
    end)
    


--整合，战团事件
    AccountBankPanel:HookScript('OnEvent', function(self, event, ...)
        if not Save().allAccountBag and BankFrame.activeTabIndex~=3 then
            self.selectedTabIDs={}
            return
        end

        if event == "BAG_UPDATE" then
            local containerID = ...
            if self.selectedTabIDs[containerID]then
                self:MarkDirty()
            end
        elseif event == "ITEM_LOCK_CHANGED" then
            local bankTabID, containerSlotID = ...

            if self.selectedTabIDs[bankTabID] then
                local itemButton = self:FindItemButtonByContainerSlotID(containerSlotID);
                if itemButton then
                    itemButton:Refresh()
                end
            end
        end
    end)

--去掉，基础银行，背影
    --BankSlotsFrame:DisableDrawLayer('BORDER')
    WoWTools_TextureMixin:HideFrame(BankSlotsFrame)

--银行，背包
    for i=1, NUM_BANKBAGSLOTS do
        local btn= BankSlotsFrame['Bag'..i]
        if btn then
            WoWTools_TextureMixin:HideTexture(btn.NormalTexture)
            WoWTools_TextureMixin:HideTexture(btn.icon)
            WoWTools_ButtonMixin:AddMask(btn)
        end
    end


    Init=function()
        Settings()
    end
end












local function Set_PortraitButton()
    local isAll = not Save().disabledBankBag--整合
    local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1
    local frame, slotID

    for index=1, NUM_BANKBAGSLOTS do--7
        slotID= index+ numBag
        frame= _G['ContainerFrame'..slotID]

        if frame then
            for _, button in frame:EnumerateValidItems()  do
                if button then
                    button:SetParent(isAll and BankSlotsFrame or frame)
                    --if not isAll then
                        --button:SetShown(true)
                    --end
                end
            end

            frame.PortraitButton:ClearAllPoints()
            if isAll then
                frame:SetParent(BankSlotsFrame)
                frame.PortraitButton:SetSize(20,20)
                frame.PortraitButton:SetPoint('BOTTOMRIGHT', BankSlotsFrame['Bag'..index])
            else
                frame:SetParent(ContainerFrameContainer)
                frame.PortraitButton:SetAllPoints(_G['ContainerFrame'..slotID..'Portrait'])
            end

            frame.FilterIcon.Icon:ClearAllPoints()
            frame.FilterIcon.Icon:SetAllPoints(frame.PortraitButton)
            --BankSlotsFrame['Bag'..index].MatchesBagID= frame.MatchesBagID
        end
    end
end






--整合
function WoWTools_BankMixin:Init_Plus()
    Set_PortraitButton()
    Init()
end







