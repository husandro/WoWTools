
local function Save()
    return WoWToolsSave['Plus_GuildBank'] or {}
end

local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local Buttons={}--新建按钮
local NumLeftButton=0



local function Set_Frame_Size(frame, currentIndex, numTab)
    local x= NumLeftButton
    if frame.mode=='bank' then
        if currentIndex<= numTab and x>0 then
            local line= Save().line
            local y = Save().num

            frame:SetSize(
                x*(37+line) + 14,

                y*(37+line) + 90
            )
        else
            frame:SetSize(750, 428)
        end
    elseif Save().otherSize then
        frame:SetSize(Save().otherSize[1], Save().otherSize[2])
    else
        frame:SetSize(750, 428)
    end
end



local function Set_UpdateTabs(frame)

end







--更改, UI, 位置
local function Init_UI()

    GuildBankFrame.TabTitle:SetPoint('CENTER', GuildBankFrame.TabTitleBG, 0, 10)

--"%s的每日提取额度剩余：|cffffffff%s|r"
    GuildBankFrame.LimitLabel:ClearAllPoints()
    GuildBankFrame.LimitLabel:SetPoint('BOTTOMLEFT', GuildBankFrame.Column1.Button1, 'TOPLEFT', 22, 4)
    GuildBankFrame.LimitLabel:SetTextColor(1,0,1)

    GuildBankFrame.DepositButton:ClearAllPoints()
    GuildBankFrame.DepositButton:SetPoint('BOTTOMRIGHT', -8, 8)

    GuildBankMoneyFrame:ClearAllPoints()
    GuildBankMoneyFrame:SetPoint('RIGHT', GuildBankFrame.WithdrawButton, 'LEFT')

    GuildItemSearchBox:ClearAllPoints()
    GuildItemSearchBox:SetPoint('RIGHT', GuildBankMoneyFrame, 'LEFT', -6, 0)

--可用数量
    GuildBankWithdrawMoneyFrame:ClearAllPoints()
    --GuildBankWithdrawMoneyFrame:SetPoint('RIGHT', GuildItemSearchBox, 'LEFT', -2, 0)
    --GuildBankWithdrawMoneyFrame:SetPoint('RIGHT', GuildBankFrame.TabTitle, 'LEFT', 2, 0)
    GuildBankWithdrawMoneyFrame:SetPoint('TOPRIGHT', -2, -28)

    GuildBankWithdrawMoneyFrame:SetScript('OnLeave', GameTooltip_Hide)
    GuildBankWithdrawMoneyFrame:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '可用数量' or GUILDBANK_AVAILABLE_MONEY)
        GameTooltip:Show()
    end)

    GuildBankMoneyLimitLabel:ClearAllPoints()
    --GuildBankMoneyLimitLabel:SetPoint('RIGHT', GuildBankWithdrawMoneyFrame, 'LEFT',-4,0)

--金币记录    
    GuildBankMessageFrame:SetPoint('TOPLEFT', GuildBankFrame, 24, -54)
    GuildBankMessageFrame:SetPoint('BOTTOMRIGHT', GuildBankFrame, -30, 54)

--信息，标签
    GuildBankInfoScrollFrame:SetPoint('TOPLEFT', GuildBankFrame, 24, -54)
    GuildBankInfoScrollFrame:SetPoint('BOTTOMRIGHT', GuildBankFrame, -30, 54)

    GuildBankTabInfoEditBox.Instructions=WoWTools_LabelMixin:Create(GuildBankTabInfoEditBox, {layer='BORDER', color={r=0.35, g=0.35, b=0.35}})
    GuildBankTabInfoEditBox.Instructions:SetPoint('TOPLEFT')
    GuildBankTabInfoEditBox.Instructions:Hide()

    GuildBankTabInfoEditBox.maxNumLetters= WoWTools_LabelMixin:Create(GuildBankTabInfoEditBox, {layer='BORDER', color=true})
    GuildBankTabInfoEditBox.maxNumLetters:SetPoint('BOTTOMRIGHT', GuildBankInfoScrollFrame, -8,8)
    GuildBankTabInfoEditBox.maxNumLetters:Hide()

    function GuildBankTabInfoEditBox:settings()
        self.maxNumLetters:SetText(self:GetNumLetters()..'/'..self:GetMaxLetters())
    end
    GuildBankTabInfoEditBox:HookScript('OnEditFocusGained', function(self)
        self:settings()
        self.maxNumLetters:Show()
    end)
    GuildBankTabInfoEditBox:HookScript('OnEditFocusLost', function(self)
        self.maxNumLetters:Hide()
    end)
    GuildBankTabInfoEditBox:HookScript('OnTextChanged', function(self)
        self.Instructions:SetShown(self:GetText() == "")
        self:settings()
    end)

    hooksecurefunc(GuildBankFrame, 'UpdateTabInfo', function(_, tabID)
        --QueryGuildBankTab(tabID)

        GuildBankTabInfoEditBox.Instructions:SetText(
            GetGuildBankTabInfo(tabID)
            or format(WoWTools_DataMixin.onlyChinese and '标签%d' or GUILDBANK_TAB_NUMBER, tabID)
        )
    end)





    Init_UI=function()end
end








--GuildBankItemButtonMixin
local function Set_Button_Script(btn)
    btn:SetScript('OnClick', function(self, d)
        if HandleModifiedItemClick(GetGuildBankItemLink(self.tabID, self.slotID)) then
            return
        end
        if IsModifiedClick("SPLITSTACK") then
            if not CursorHasItem() then
                local _, count, locked = GetGuildBankItemInfo(self.tabID, self.slotID)
                if not locked and count and count > 1 then
                    StackSplitFrame:OpenStackSplitFrame(count, self, "BOTTOMLEFT", "TOPLEFT")
                end
            end
            return
        end
        local type, money = GetCursorInfo()
        if type == "money" then
            DepositGuildBankMoney(money)
            ClearCursor()
        elseif type == "guildbankmoney" then
            DropCursorMoney()
            ClearCursor()
        else
            if d == "RightButton" then
                AutoStoreGuildBankItem(self.tabID, self.slotID)
                self:OnLeave()
            else
                PickupGuildBankItem(self.tabID, self.slotID)
            end
        end
    end)

    function btn:OnEnter()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetGuildBankItem(self.tabID, self.slotID)
    end

    function btn:OnLeave()
        self.updateTooltipTimer = nil
        GameTooltip_Hide()
        ResetCursor()
    end

    btn:SetScript('OnHide', function(self)
        if self.hasStackSplit and (self.hasStackSplit == 1) then
            StackSplitFrame:Hide()
        end
    end)

    function btn:OnDragStart()
        PickupGuildBankItem(self.tabID, self.slotID)
    end

    function btn:OnReceiveDrag()
        PickupGuildBankItem(self.tabID, self.slotID)
    end

    function btn:OnEvent()
        if GameTooltip:IsOwned(self) then
            self:OnEnter()
        end
    end

    function btn:Init()
        local texture, itemCount, locked, isFiltered, quality = GetGuildBankItemInfo(self.tabID, self.slotID)
        
        SetItemButtonTexture(self, texture)
        SetItemButtonCount(self, itemCount)
        SetItemButtonDesaturated(self, locked)
        self:SetMatchesSearch(not isFiltered)
        local itemLink= GetGuildBankItemLink(self.tabID, self.slotID)
        SetItemButtonQuality(self, quality, itemLink)
        WoWTools_ItemMixin:SetupInfo(btn, {itemLink= itemLink})
    end


    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn.SplitStack= function(self, split)
        SplitGuildBankItem(self.tabID, self.slotID, split)
    end
    btn.UpdateTooltip = btn.OnEnter

    btn.indexLable= WoWTools_LabelMixin:Create(btn, {
        layer='BACKGROUND',
        color=select(2, math.modf(btn.tabID/2))==0 and {r=0,g=0.8,b=1,a=0.3} or {r=1,g=1,b=1, a=0.3}}
    )
    btn.indexLable:SetPoint('CENTER')
    btn.indexLable:SetText(btn.slotID)
    btn.NormalTexture:SetAlpha(0.2)

    --[[if isName then--创建，TabName标签
        btn.nameLabel= WoWTools_LabelMixin:Create(btn)
        btn.nameLabel:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT', 22, 5)
    end]]
end


--设置按钮
local function Set_Button_Point()

    local num= Save().num
    local line= Save().line

    local x, y= 8, -60
    local index=0

    for tabID=1, GetNumGuildBankTabs() do
        if select(3, GetGuildBankTabInfo(tabID)) then--name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals, filtered 
            for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                index= index+1

                local btn= Buttons[index]
                if not btn then
                    btn= CreateFrame('ItemButton', nil, GuildBankFrame.Column1, 'GuildBankItemButtonTemplate', tabID)
                    btn.tabID= tabID
                    btn.slotID= slotID
                    Set_Button_Script(btn)
                    table.insert(Buttons, btn)
                end

                btn:SetPoint("TOPLEFT", GuildBankFrame, x, y)

                if slotID==MAX_GUILDBANK_SLOTS_PER_TAB or select(2, math.modf(index/num))==0 then--37 37
                    x= x+ line+ 37
                    y= -60
                else
                    y= y- line- 37
                end
            end
        end
    end

    if index>0 then
        GuildBankFrame:SetSize(
            x+8,
            (37+line)*num+60+8-line
        )
    end
end




--替换，原生
local function GuildBankFrameMixinUpdate(self)
	-- Figure out which mode you're in and which tab is selected
	if self.mode ~= "bank" then
        GuildBankFrameMixin.Update(self)
        return
    end
    -- Determine whether its the buy tab or not
    self.Log:Hide()
    self.Info:Hide()
    local tab = GetCurrentGuildBankTab()
    if self.noViewableTabs then
        self:HideColumns()
        self.BuyInfo:Hide()
        self.ErrorMessage:SetText(NO_VIEWABLE_GUILDBANK_TABS)
        self.ErrorMessage:Show()
    elseif tab > GetNumGuildBankTabs() then
        if IsGuildLeader() then
            --Show buy screen
            self:HideColumns()
            self.BuyInfo:Show()
            self.ErrorMessage:Hide()
        else
            self:HideColumns()
            self.BuyInfo:Hide()
            self.ErrorMessage:SetText(NO_GUILDBANK_TABS)
            self.ErrorMessage:Show()
        end
    else
        local _, _, _, canDeposit, numWithdrawals = GetGuildBankTabInfo(tab)
        if not canDeposit and numWithdrawals == 0 then
            self:DesaturateColumns(true)
        else
            self:DesaturateColumns(false)
        end
        self:ShowColumns()
        self.BuyInfo:Hide()
        self.ErrorMessage:Hide()
    end

    -- Update the tab items
    for _, btn in ipairs(Buttons) do
        btn:Init()
    end

    MoneyFrame_Update("GuildBankMoneyFrame", GetGuildBankMoney())
    if CanWithdrawGuildBankMoney() then
        self.WithdrawButton:Enable()
    else
        self.WithdrawButton:Disable()
    end

    self:UpdateWithdrawMoney()
end


local function Init()
    
--加载数据
    for tabID= 1, GetNumGuildBankTabs() do
        QueryGuildBankTab(tabID)
    end

    local isCanViewable=nil
    for tabID=1, GetNumGuildBankTabs() do
        if select(3, GetGuildBankTabInfo(tabID)) then
            isCanViewable=true
            break
        end
    end
    if not isCanViewable then
        Set_Button_Point= function()end
        Set_UpdateTabs= function()end
        return
    end

    --自带按钮
    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(slotID, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if btnIndex == 0 then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((slotID-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn= GuildBankFrame.Columns[column].Buttons[btnIndex]
        btn.tabID= 1
        btn.slotID= slotID
        Set_Button_Script(btn)
        btn:ClearAllPoints()
        table.insert(Buttons, btn)
    end
--设置按钮
    Set_Button_Point()



--移动，大小
    WoWTools_MoveMixin:Setup(GuildBankFrame, {setSize=true, minW=80, minH=140,
    sizeRestFunc= function()
        Save().otherSize= nil
        Save().num=15
        if GuildBankFrame.mode== "bank" then
            Set_Button_Point()
        else
            Set_Frame_Size(GuildBankFrame, GetCurrentGuildBankTab(), GetNumGuildBankTabs())
        end
    end, sizeStopFunc= function()--<Size x="750" y="428" />
        if GuildBankFrame.mode== "bank" then
            local h= math.modf(
                (GuildBankFrame:GetHeight()-90)/(Save().line+37)
            )
            Save().num= h
            Set_Button_Point()
        else
            Save().otherSize= {GuildBankFrame:GetSize()}
        end
    end})

--替换，原生
    GuildBankFrame.Update= GuildBankFrameMixinUpdate

--调整，UI
    Init_UI()

    Init=function()end
end


function WoWTools_GuildBankMixin:Init_Plus()
    Init()
end


function WoWTools_GuildBankMixin:Update_Button()
    Set_Button_Point()
    Set_UpdateTabs(GuildBankFrame)
end