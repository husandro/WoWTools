--整合
local e= select(2, ...)

local function Save()
    return WoWTools_BankMixin.Save
end


local LastButton
local NumLeftButton=0
local NumReagentLeftButton=0
local NumAccountLeftButton=0


local function Set_Frame_Size(index)
    if index==1 then
        local x= NumLeftButton + NumReagentLeftButton+ NumAccountLeftButton
        local line= Save().line
        local y =Save().num

        BankFrame:SetSize(
            x*(37+2+line)+12,

            y*(37+2+line) + 108
        )
    else
        BankFrame:SetSize(738, 460)
    end
end








 --索引，提示
 local function Set_IndexLabel(btn, index)
    if not btn.indexLable and Save().showIndex then
        btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BACKGROUND', color={r=1,g=1,b=1}})
        btn.indexLable:SetPoint('CENTER')
        btn.indexLable:SetAlpha(0.2)
    end
    if btn.indexLable then
        btn.indexLable:SetText(Save().showIndex and index or '')
    end
end





--设置，frame到最左边，为隐藏
local function Hide_BagFrame(frame, index)
    --[[if not frame:IsShown() then
        ToggleBag(frame:GetID())
    end]]

    if frame.set_point_toleft then
        frame:set_point_toleft()
        return
    end

    if frame.ResizeButton then
        frame.ResizeButton:SetClampedToScreen(false)
    end

    function frame:set_point_toleft()
        --self:UpdateFilterIcon()
        self:ClearAllPoints()
        self:SetPoint('RIGHT', UIParent, 'LEFT', -60, 0)
        self:SetAlpha(0)
    end

    frame:HookScript('OnEnter', frame.set_point_toleft)
    frame:HookScript('OnShow', frame.set_point_toleft)

    frame:set_point_toleft()


--菜单，选项
    local btn= BankSlotsFrame['Bag'..index]
    btn.MatchesBagID= frame.PortraitButton:GetParent().MatchesBagID

    frame.PortraitButton:SetParent(btn)
    frame.PortraitButton:ClearAllPoints()
    frame.PortraitButton:SetPoint('TOPLEFT', btn,-2,2)
    frame.PortraitButton:SetSize(20,20)--37
    frame.PortraitButton:SetNormalAtlas(e.Icon.icon)
    frame.PortraitButton:SetPushedAtlas('bag-border-highlight')
    frame.PortraitButton:SetHighlightAtlas('bag-border')

    frame.FilterIcon.Icon:SetParent(frame.PortraitButton)
    frame.FilterIcon.Icon:ClearAllPoints()
    frame.FilterIcon.Icon:SetAllPoints()

end









--local index= BankFrame.activeTabIndex
local function Set_BankSlotsFrame(index)
    if index~=1 then
        return
    end



--btn:SetPoint('TOPLEFT', 8,-60)
    local tab={}

--基础包
    for i=1, NUM_BANKGENERIC_SLOTS do--28
        local btn= BankSlotsFrame["Item"..i]
        if btn then
            btn.index=i
            Set_IndexLabel(btn, i)--索引，提示
            table.insert(tab, btn)
        end
    end


--背包
    local num=0
    local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES--5+1
    for i=1, NUM_BANKBAGSLOTS do
        local bag= i+ numBag
        local frame= _G['ContainerFrame'..bag]
        if frame then
            local isShow= frame:IsShown()

            Hide_BagFrame(frame, i)

            for _, btn in frame:EnumerateValidItems()  do
                if btn then
                    if isShow then
                        btn:SetParent(BankSlotsFrame)
                        table.insert(tab, btn)
                    else
                        btn:SetParent(frame)
                    end
                    btn:SetShown(isShow)
                end
            end
        end
    end


    LastButton= tab[1]
    LastButton:ClearAllPoints()
    LastButton:SetPoint('TOPLEFT', 8, -60)
    NumLeftButton= 1
    Set_IndexLabel(LastButton, 1)--索引，提示

    local line= Save().line+2
    num= Save().num

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
        Set_IndexLabel(btn, i)--索引，提示
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
                        Set_IndexLabel(button, index)--索引，提示
                        button:ClearAllPoints()
                        button:SetPoint("TOPLEFT", ReagentBankFrame["BG"..column], "TOPLEFT", leftOffset, -(3+row*slotOffsetY));
                        index = index + 1;
                    end
                end
                leftOffset = leftOffset + slotOffsetX;
            end
        end

    elseif tabIndex==1 then--1

        do ReagentBankFrame:SetShown(true)  end

        local line= Save().line+2
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
            Set_IndexLabel(btn, index)--索引，提示
        end
    end
end













local function Set_AccountBankPanel(index)
    if not C_PlayerInfo.HasAccountInventoryLock() then
        return
    end

    do
        AccountBankPanel:SetShown(index==1 or index==3)
    end


    if index==1 then--for btn in AccountBankPanel.itemButtonPool:EnumerateActive() do

        local line= Save().line+2
        local num= Save().num
        local i=1
        local last

        for btn in AccountBankPanel:EnumerateValidItems() do
            

            btn:ClearAllPoints()

            if select(2, math.modf((i-1)/num))==0 then
                
                btn:SetPoint('LEFT', LastButton, 'RIGHT', line, 0)


                LastButton= btn
                NumAccountLeftButton= NumAccountLeftButton+1

            else
                btn:SetPoint('TOP', last, 'BOTTOM', 0, -line)
            end

            last= btn
            Set_IndexLabel(btn, i)--索引，提示

            i=i+1
        end

    elseif index==3 then
        AccountBankPanel:GenerateItemSlotsForSelectedTab()
    end
end





        --[[AccountBankPanel.itemButtonPool:ReleaseAll();
        AccountLeftButton=0

        local selectedTabID= AccountBankPanel.selectedTabID or 13
        local tab={}
        for containerSlotID = 1, C_Container.GetContainerNumSlots(selectedTabID) do
            local btn = AccountBankPanel.itemButtonPool:Acquire()
            btn:ClearAllPoints()
            --btn:SetParent(BankSlotsFrame)
            if containerSlotID==1 then
                btn:SetPoint('LEFT', NumLeftButton, 'RIGHT', Save().line+6, 0)
                LeftButton=btn
                AccountLeftButton= AccountLeftButton+1
            else
                btn:SetPoint('TOP', tab[containerSlotID-1], 'BOTTOM', 0, -Save().line)
            end

            btn:Init(selectedTabID, containerSlotID)
            btn:Refresh()
            btn:SetShown(true)
            table.insert(tab, btn)
        end

        for i=Save().num+1, #tab, Save().num do
            local btn= tab[i]
            btn:ClearAllPoints()
            btn:SetPoint('LEFT', LeftButton, 'RIGHT', Save().line, 0)
            LeftButton= btn
            AccountLeftButton= AccountLeftButton+1
        end]]






local function Settings()
    NumReagentLeftButton= 0
    NumAccountLeftButton= 0

    local index= BankFrame.activeTabIndex or 1
    do Set_BankSlotsFrame(index) end
    do Set_BankReagent(index) end
    do Set_AccountBankPanel(index) end
    Set_Frame_Size(index)
end









local function Init()
    --背包，需要这个函数 ContainerFrame7 - 13 <Frame name="ContainerFrame7" inherits="ContainerFrameBankTemplate"/>
    function BankSlotsFrame:IsCombinedBagContainer()
        return false
    end





    hooksecurefunc('BankFrame_ShowPanel', Settings)
    hooksecurefunc('BankFrameItemButtonBag_OnClick', Settings)
    

    hooksecurefunc(BankPanelTabMixin, 'OnClick', Settings)

    --背包位
    for index=1, NUM_BANKBAGSLOTS do--NUM_BANKBAGSLOTS 7
        local btn= BankSlotsFrame['Bag'..index]
        if btn then
            btn:ClearAllPoints()
            if index==1 then
                --btn:SetPoint('TOPLEFT', _G['BankFrameItem'..Save().num], 'BOTTOMLEFT', 0,-8)
                btn:SetPoint('BOTTOMLEFT',8,10)
            else
                btn:SetPoint('LEFT', BankSlotsFrame['Bag'..(index-1)], 'RIGHT', Save().line, 0)
            end
        end
    end


--购买，背包栏
    BankFramePurchaseInfo:ClearAllPoints()
    BankFramePurchaseInfo:SetPoint('TOP', BankFrame, 'BOTTOM',0, -28)
    WoWTools_TextureMixin:CreateBackground(BankFramePurchaseInfo, {isAllPoint=true})
    
    --[[背包
    for i=1, NUM_BANKBAGSLOTS do--NUM_BANKBAGSLOTS 7
        local btn= BankSlotsFrame['Bag'..i]
        if btn then
            btn:ClearAllPoints()
            if i==1 then
                btn:SetPoint('TOPLEFT', _G['BankFrameItem'..Save().num], 'BOTTOMLEFT', 0,-8)
            else
                btn:SetPoint('LEFT', BankSlotsFrame['Bag'..(i-1)], 'RIGHT', Save().line, 0)
            end
        end
    end]]
end


--整合
function WoWTools_BankMixin:Init_Plus()
    if Init() then
        Init= function() end
    else
        Settings()
    end
end

--[[

local function Init()
    hooksecurefunc('BankFrame_ShowPanel', Settings)
    hooksecurefunc('BankFrameItemButtonBag_OnClick', Settings)
end

    local SetAllBank= CreateFrame('Frame', 'WoWTools_SetAllBankButton')

    --设置，银行，按钮
    if not BankSlotsFrame.IsCombinedBagContainer then
        function BankSlotsFrame:IsCombinedBagContainer()
            return false
        end
    end

    function SetAllBank:set_bank()
        
    end










    --设置，材料，按钮
    function SetAllBank:set_reagent(tabindex)
        if not IsReagentBankUnlocked() then
            return
        end
        if tabindex==2 then
            local slotOffsetX = 49;
            local slotOffsetY = 44;
            local index = 1;
            for column = 1, ReagentBankFrame.numColumn or 7 do
                local leftOffset = 6;
                for subColumn = 1, ReagentBankFrame.numSubColumn or 2 do
                    for row = 0, ReagentBankFrame.numRow-1 do
                        local button=ReagentBankFrame["Item"..index]
                        if button then
                            Set_IndexLabel(button, index)--索引，提示
                            button:ClearAllPoints()
                            button:SetPoint("TOPLEFT", ReagentBankFrame["BG"..column], "TOPLEFT", leftOffset, -(3+row*slotOffsetY));
                            index = index + 1;
                        end
                    end
                    leftOffset = leftOffset + slotOffsetX;
                end
            end

        else--1

            self.reagentNum= 0
            local btnNum=0
            for index, btn in ReagentBankFrame:EnumerateItems() do
                btn:ClearAllPoints()
                if index==1 then
                    btn:SetPoint('LEFT', self.last, 'RIGHT', Save().line+6, 0)
                    self.last=btn
                    self.reagentNum= self.reagentNum+1
                else
                    btn:SetPoint('TOP', ReagentBankFrame["Item"..(index-1)], 'BOTTOM', 0, -Save().line)
                end
                if not btn.Bg then
                    btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
                    btn.Bg:SetAllPoints(btn)
                    btn.Bg:SetAtlas('ChallengeMode-DungeonIconFrame')
                    btn.Bg:SetVertexColor(0,1,0)
                end
                Set_IndexLabel(btn, index)--索引，提示
                btnNum=index
            end
            for i=Save().num+1, btnNum, Save().num do
                local btn= ReagentBankFrame["Item"..i]
                btn:ClearAllPoints()
                btn:SetPoint('LEFT', self.last, 'RIGHT', Save().line, 0)
                self.last= btn
                self.reagentNum= self.reagentNum+1
            end
        end
    end





 --设置，战团银行，按钮
 function SetAllBank:set_account()
    if not C_PlayerInfo.HasAccountInventoryLock() then
        return
    end

    --AccountBankPanel:SetShown(true)

    local numRows = 7;
	local numSubColumns = 2;
	local lastColumnStarterButton;
	local lastCreatedButton;
	local currentColumn = 1;

    local btnNum=0

   AccountBankPanel.itemButtonPool:ReleaseAll();

    local selectedTabID= AccountBankPanel.selectedTabID or 13
	for containerSlotID = 1, C_Container.GetContainerNumSlots(selectedTabID) do
		local btn = AccountBankPanel.itemButtonPool:Acquire()
        btn:ClearAllPoints()
        btn:SetParent(BankSlotsFrame)
		if containerSlotID==1 then
            btn:SetPoint('TOPLEFT', self.last, 'TOPRIGHT')
        else
            btn:SetPoint('TOP', self.last, 'BOTTOM')
        end

        
print(btn, containerSlotID)

		btn:Init(selectedTabID, containerSlotID)
        btn:Refresh()
		btn:SetShown(true)

        self.last=btn
		--lastCreatedButton = button;
	end

    for i=Save().num+1, btnNum, Save().num do
        local btn= ReagentBankFrame["Item"..i]
        btn:ClearAllPoints()
        btn:SetPoint('LEFT', self.last, 'RIGHT', Save().line, 0)
        self.last= btn
        self.reagentNum= self.reagentNum+1
    end

 end






--设置，外框，大小
    function SetAllBank:set_size(tabindex)
        if tabindex==1 then
            local num= SetAllBank.num + (SetAllBank.reagentNum or 0)
            BankFrame:SetSize(
                8+(num*37)+((num-1)*Save().line)+8+6 +100,

                (Save().num+1)*37 +((Save().num-1)*Save().line)+64+8+6
            )
        end
    end







    function SetAllBank:Settings(tabindex)--如果没有tabIndex，为设置，全部
        local index= tabindex or BankFrame.activeTabIndex
        if index==1 then
            do
                if IsReagentBankUnlocked() then
                    ReagentBankFrame:SetShown(true)
                end

                if not C_PlayerInfo.HasAccountInventoryLock() then
                   AccountBankPanel:SetShown(true)
                end
            end
            do self:set_bank() end
            do self:set_reagent(1) end
            self:set_account()

        elseif index==2 then
            do self:set_reagent(2) end
        else

        end

        SetAllBank:set_size(index)--设置，外框，大小

        if not tabindex then
           -- e.call(AccountBankPanel.GenerateItemSlotsForSelectedTab, AccountBankPanel)
        end
    end



    hooksecurefunc('BankFrame_ShowPanel', function()
        local index= BankFrame.activeTabIndex
        if index==1 then
            if IsReagentBankUnlocked() then
                ReagentBankFrame:SetShown(true)
            end
            if not C_PlayerInfo.HasAccountInventoryLock() then
                AccountBankPanel:SetShown(true)
            end


            SetAllBank:Settings(index)

        elseif index==2 then
            SetAllBank:Settings(index)

        --elseif index==3 then
            --e.call(AccountBankPanel.GenerateItemSlotsForSelectedTab, AccountBankPanel)
        end

        if not IsReagentBankUnlocked() and ReagentBankFrame.UnlockInfo then
            ReagentBankFrame.UnlockInfo:SetShown(BankFrame.activeTabIndex==2)
        end
    end)

    hooksecurefunc('BankFrameItemButtonBag_OnClick', function()
        SetAllBank:Settings(BankFrame.activeTabIndex)
    end)



    BankFramePurchaseButton:SetWidth(BankFramePurchaseButton:GetFontString():GetWidth()+12)






--购买，背包栏
    hooksecurefunc('UpdateBagSlotStatus', function()
        if BankFramePurchaseInfo and BankFramePurchaseInfo:IsShown() then
            BankFramePurchaseInfo:ClearAllPoints()
            BankFramePurchaseInfo:SetPoint('Top', BankFrame, 'BOTTOM',0, -28)
            WoWTools_TextureMixin:CreateBackground(BankFramePurchaseInfo, {isAllPoint=true})
        end
        SetAllBank:Settings(BankFrame.activeTabIndex)
    end)


    --hooksecurefunc(AccountBankPanel, 'GenerateItemSlotsForSelectedTab', Set_AccountBankPanel)


    Settings()
end
Settings

























































local function Set_AccountBankPanel()
    if not AccountBankPanel.selectedTabID or AccountBankPanel.selectedTabID == -1 then
        return

    elseif BankFrame.activeTabIndex==3 then
        AccountBankPanel:ClearAllPoints()
        AccountBankPanel:SetAllPoints()
        return
    end

    AccountBankPanel:ClearAllPoints()
    AccountBankPanel:SetPoint('TOPLEFT', BankFrame, 'TOPRIGHT')
    local numRows = Save().num
    local lastColumnStarterButton
    local lastCreatedButton
    local currentColumn = 1
    local x= Save().line

    local containerSlotID=0

    local tab={}
    for button in AccountBankPanel:EnumerateValidItems() do
        table.insert(tab, 1, button)
    end
    for _, button in pairs(tab) do
        containerSlotID= containerSlotID+1
        local isFirstButton = containerSlotID == 1
        local needNewColumn = (containerSlotID % numRows) == 1

        if isFirstButton then
            button:SetPoint("TOPLEFT", AccountBankPanel, "TOPLEFT", 8, -60)
            lastColumnStarterButton = button

        elseif needNewColumn then
            currentColumn = currentColumn + 1
            button:SetPoint("TOPLEFT", lastColumnStarterButton, "TOPRIGHT", x, 0)
            lastColumnStarterButton = button
        else
            button:SetPoint("TOPLEFT", lastCreatedButton, "BOTTOMLEFT", 0, -x)
        end
        lastCreatedButton = button
        Set_IndexLabel(button, button:GetContainerSlotID())--索引，提示
    end
    AccountBankPanel:SetSize(
        8+(currentColumn*37)+((currentColumn-1)*x)+8,
        36+(numRows*(37+x))+68
    )
end]]

