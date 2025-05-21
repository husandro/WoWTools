
local function Save()
    return WoWToolsSave['Plus_GuildBank'] or {}
end

--Blizzard_GuildBankUI.lua  bank, log, moneylog, tabinfo

local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14

local Buttons={}--新建按钮
local MainButtons={}--自带按钮
local NumLeftButton=0
local PickupGuildBankItemTabID--刷新用

local function Click_Tab(self)
    --if self.tabID~=GetCurrentGuildBankTab() then
    local btn = GuildBankFrame.BankTabs[self.tabID]-- _G['GuildBankTab'..self.tabID]
    --QueryGuildBankTab(self.tabID)
    if btn then
        btn:OnClick('LeftButton')
    else
        SetCurrentGuildBankTab(self.tabID)
    end
end






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































local function Set_Label(self)
    local showIndex= Save().showIndex
    local r, g, b= 0, 0.68, 1
    if showIndex then
        if self.isCurrent then
            r,g,b= 1, 0, 1
        elseif select(2, math.modf(self.tabID/2))==0 then
            r,g,b= 1, 0.82, 0
        else
            r,g,b= 0, 0.68, 1
        end
    end

    if self.indexLable then
        if showIndex then
            self.indexLable:SetTextColor(r,g,b)
        end
        self.indexLable:SetShown(showIndex)
    end

    if self.nameLabel then
        if showIndex then
            --QueryGuildBankTab(self.tabID)

            local name, icon, _, canDeposit, numWithdrawals, remainingWithdrawals= GetGuildBankTabInfo(self.tabID)

            if self.onlyName then
                self.nameLabel:SetText(name or '')

            else
                local access= ( not canDeposit and numWithdrawals==0 and '|A:Monuments-Lock:0:0|a' )--锁定
                    or ( not canDeposit and '|A:Cursor_OpenHand_32:0:0|a' )--只能提取
                    or ( numWithdrawals==0 and '|A:Banker:0:0|a' )--只能存放 --or GUILDBANK_TAB_FULL_ACCESS--全部权限

                self.nameLabel:SetText(
                    '|T'..(icon or 0)..':0|t'
                    ..(
                        remainingWithdrawals > 0  and remainingWithdrawals
                        or ( (remainingWithdrawals==0 and access) and (WoWTools_DataMixin.onlyChinese and '无' or NONE) )
                        or ( WoWTools_DataMixin.onlyChinese and '无限制' or UNLIMITED )
                    )
                    ..(access or '')
                )
            end

            self.nameLabel:SetTextColor(r,g,b)
        else
            self.nameLabel:SetText('')
        end
    end
end




























 --索引，提示
 local function Create_IndexLabel(btn, isName)
    btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BACKGROUND'})
    btn.indexLable:SetPoint('CENTER')
    btn.indexLable:SetText(btn:GetID())
    btn.indexLable:SetAlpha(0.3)
    btn.NormalTexture:SetAlpha(0.2)

    if isName then--创建，TabName标签
        btn.nameLabel= WoWTools_LabelMixin:Create(btn)
        btn.nameLabel:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT', 22, 5)
    end
end




local function Create_SortButton(frame, isFunc)--if not WoWTools_GuildMixin:IsLeaderOrOfficer() then--会长或官员
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {
        --isMenu= true,
        --atlas='Cursor_OpenHand_32',
        size=23,
        template='BankAutoSortButtonTemplate',
    })
    btn:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0,0)

    btn:SetAlpha(isFunc and 1 or 0.5)
    btn:SetScale(isFunc and 1.1 or 1)

    if isFunc then
        --WoWTools_GuildBankMixin:Set_TabButton_Menu(btn)
        btn:SetScript('OnMouseDown', function(self)
            MenuUtil.CreateContextMenu(self, function(...)
                WoWTools_GuildBankMixin:Init_Button_Menu(...)
            end)
        end)
        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript('OnEnter', function(self)
            QueryGuildBankTab(GetCurrentGuildBankTab())
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(WoWTools_GuildBankMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            GameTooltip:Show()
        end)
        frame.SortButton= btn
    else
        btn:SetScript('OnEnter', function(self)
            if not WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
                Click_Tab(self:GetParent())
            end
        end)
    end
end













--GuildBankItemButtonMixin 
--需要 GetCurrentGuildBankTab() 修改成 self.tabID
local function Create_Button(index, tabID, slotID)
    local btn= CreateFrame('ItemButton', 'WoWToolsGuildItemButton'..tabID..'_'..slotID, MainButtons[1], 'GuildBankItemButtonTemplate', slotID)

    function btn:OnEnter()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetGuildBankItem(self.tabID, self:GetID())
    end
    btn.UpdateTooltip = btn.OnEnter

    btn:SetScript('OnEnter', function(self)
        if not WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
            Click_Tab(self)
        else
            self:OnEnter()
        end
    end)
    btn:SetScript('OnMouseDown', function(self)
        Click_Tab(self)
    end)

    function btn:set_item()
        local tab, slot= self.tabID, self:GetID()
        local texture, itemCount, locked, isFiltered, quality = GetGuildBankItemInfo(tab, slot)
        
        SetItemButtonTexture(self, texture)
        SetItemButtonCount(self, itemCount)
        SetItemButtonDesaturated(self, locked)

        self:SetMatchesSearch(not isFiltered)

        SetItemButtonQuality(self, quality, GetGuildBankItemLink(tab, slot))
    end



    local one= slotID==1

    Create_IndexLabel(btn, one)

    if one then
        Create_SortButton(btn, false)
    end

    Buttons[index]= btn

    return btn
end




--[[
btn.SplitStack = function(button, split)
    SplitGuildBankItem(button.tabID, button:GetID(), split)
end

btn:SetScript('OnClick', function(self, d)
    if HandleModifiedItemClick(GetGuildBankItemLink(self.tabID, self:GetID())) then
        return
    end
    if ( IsModifiedClick("SPLITSTACK") ) then
        if ( not CursorHasItem() ) then
            local _, count, locked = GetGuildBankItemInfo(self.tabID, self:GetID())
            if ( not locked and count and count > 1) then
                StackSplitFrame:OpenStackSplitFrame(count, self, "BOTTOMLEFT", "TOPLEFT")
            end
        end
        return
    end
    local type, money = GetCursorInfo()
    if ( type == "money" ) then
        DepositGuildBankMoney(money)
        ClearCursor()
    elseif ( type == "guildbankmoney" ) then
        DropCursorMoney()
        ClearCursor()
    else
        if ( d == "RightButton" ) then
            AutoStoreGuildBankItem(self.tabID, self:GetID())
            self:OnLeave()
        else
            PickupGuildBankItem(self.tabID, self:GetID())
        end
    end
end)

btn:SetScript('OnDragStart', function(self)
    Click_Tab(self)
    PickupGuildBankItem(self.tabID, self:GetID())
end)

btn:SetScript('OnReceiveDrag', function(self)
    Click_Tab(self)
    PickupGuildBankItem(self.tabID, self:GetID())
end)
]]
















--local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals, filtered = GetGuildBankTabInfo(tab)
local function Init_Button(self)
    local currentIndex= GetCurrentGuildBankTab()--当前 Tab
    local numTab= GetNumGuildBankTabs()--总计Tab
    local isEnable= self.mode== "bank" and currentIndex<= numTab


    if not isEnable then
        Set_Frame_Size(self, currentIndex, numTab)
        return
    end

    local newTab={}
    local index= 1

    for tabID=1, numTab do
        --if select(3, GetGuildBankTabInfo(tabID)) then
           -- print(tabID, self.BankTabs[tabID].Button:IsEnabled())
        --QueryGuildBankTab(tabID)

        if self.BankTabs[tabID].Button:IsEnabled() then
            if currentIndex~=tabID then
                for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                    local btn= Buttons[index] or Create_Button(index, tabID, slotID)
                    btn.tabID= tabID
                    --btn.isCurrent= false

                --物品，信息
                    btn:set_item()
                    WoWTools_ItemMixin:Setup(btn, {guidBank={tab=tabID, slot=slotID}})

                    index= index+1
                    table.insert(newTab, btn)
                end
            else
                for slotID, btn in pairs(MainButtons) do
                    btn.tabID= tabID


                --物品，信息
                    WoWTools_ItemMixin:Setup(btn, {guidBank={tab=tabID, slot=slotID}})
                    table.insert(newTab, btn)
                end
            end
        end
    end


    local leftButton,  newLine
    local num= Save().num
    local line= Save().line
    NumLeftButton=0
    index=0

    for i, btn in pairs(newTab) do
        btn:ClearAllPoints()
        index= index+1
        newLine= select(2, math.modf((i-1)/MAX_GUILDBANK_SLOTS_PER_TAB))

        if newLine==0 or select(2, math.modf((index-1)/num))==0 then
            if i==1 then
                btn:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -60)
            else
                btn:SetPoint('LEFT', leftButton, 'RIGHT', line, 0)
                index=1
            end
            leftButton= btn
            NumLeftButton= NumLeftButton+1
        else
            btn:SetPoint('TOP', newTab[i-1], 'BOTTOM', 0, -line)
        end

--设置，索引颜色
       Set_Label(btn)
       btn:SetShown(true)
    end

--print( #newTab, #MainButtons, #Buttons)
--新登入，会出现BUG
    for i= #newTab-#MainButtons+1, #Buttons, 1 do
        Buttons[i]:SetShown(false)
    end

    Set_Frame_Size(self, currentIndex, numTab)
end

















--缩放按钮
local function Update_ResizeButton(self, currentIndex, numTab)
    currentIndex= currentIndex or GetCurrentGuildBankTab()--当前 Tab
    numTab= numTab or GetNumGuildBankTabs()--总计Tab
    self.ResizeButton.setSize= self.mode~= "bank" or currentIndex<= numTab
end












local function Set_UpdateTabs(self)
    local currentIndex= GetCurrentGuildBankTab()--当前 Tab
    local numTab= GetNumGuildBankTabs()--总计Tab
    local isCurrent, isEnable

    Update_ResizeButton(self, currentIndex, numTab)--缩放按钮


    for tabID= 1, GetNumGuildBankTabs(), 1 do
        local btn= self.BankTabs[tabID].Button

        isCurrent= currentIndex==tabID
        isEnable= btn:IsEnabled() and currentIndex<= numTab

        btn.isCurrent= isCurrent
        if isEnable then
            btn.nameLabel:SetAlpha(isCurrent and 1 or 0.3)
            Set_Label(btn)
        end
        btn.nameLabel:SetShown(isEnable)
    end
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

end


















local function Init()
    if
        Save().plusOnlyOfficerAndLeader--仅限公会官员
        and not (WoWTools_GuildMixin:IsLeaderOrOfficer())--会长或官员
    then
        if not GuildBankFrame.ResizeButton then
            WoWTools_MoveMixin:Setup(GuildBankFrame)
        end
        return
    end


--"%s的每日提取额度剩余：|cffffffff%s|r";
    GuildBankFrame.Column1.Button1.nameLabel=  GuildBankFrame.LimitLabel


--自带按钮
    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(slotID, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if ( btnIndex == 0 ) then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((slotID-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn= GuildBankFrame.Columns[column].Buttons[btnIndex]

        MainButtons[slotID]= btn
        btn.isCurrent=true

        Create_IndexLabel(btn, false)

        if slotID==1 then
            Create_SortButton(btn, true)
        end
        btn:HookScript('OnMouseDown', function()
            if WoWTools_GuildBankMixin.isInRun then--禁用，按钮移动事件
                GuildBankFrame.Column1.Button1.SortButton.isInRun=true--停止，已运行
            end
        end)

--刷新用
        btn:HookScript('OnClick', function()
            if PickupGuildBankItemTabID and PickupGuildBankItemTabID~=GetCurrentGuildBankTab() then
                QueryGuildBankTab(PickupGuildBankItemTabID)
            end
            PickupGuildBankItemTabID= GetCurrentGuildBankTab()
        end)

        btn:HookScript('OnDragStart', function()
            PickupGuildBankItemTabID= GetCursorInfo() == "item" and GetCurrentGuildBankTab() or nil
        end)
        btn:HookScript('OnReceiveDrag', function()
            if PickupGuildBankItemTabID and PickupGuildBankItemTabID~=GetCurrentGuildBankTab() then
                QueryGuildBankTab(PickupGuildBankItemTabID)
            end
            PickupGuildBankItemTabID= nil
        end)
    end

    C_Timer.After(1, function()
        GuildBankFrame:HookScript('OnShow', function()
            for tabID=1, MAX_GUILDBANK_TABS do
                QueryGuildBankTab(tabID)
            end
        end)
    end)

--右边标签，提示
    for tabID=1, MAX_GUILDBANK_TABS do--MAX_GUILDBANK_TABS
        if _G['GuildBankTab'..tabID] then
            local btn= _G['GuildBankTab'..tabID].Button
            btn.onlyName= true
            btn.tabID= tabID

            btn:SetScript('OnEnter', function(self)
                --if not GuildBankTabInfoEditBox:IsVisible() then
                    --QueryGuildBankText(self.tabID)
                --end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
                GameTooltip:AddLine(GetGuildBankText(self.tabID))
                GameTooltip:Show()
            end)

            btn.nameLabel= WoWTools_LabelMixin:Create(btn)
            btn.nameLabel:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')

            QueryGuildBankText(tabID)
            QueryGuildBankTab(tabID)
        end

    end


--背景
    GuildBankFrame.BlackBG:SetAlpha(Save().BgAplha or 1)

--移动，大小
    WoWTools_MoveMixin:Setup(GuildBankFrame, {
        --needSize=true, needMove=true,
        setSize=true, minW=80, minH=140,
    sizeRestFunc= function(btn)
        Save().otherSize= nil
        Save().num=15
        if btn.targetFrame.mode== "bank" then
            Init_Button(btn.targetFrame)
        else
            Set_Frame_Size(btn.targetFrame, GetCurrentGuildBankTab(), GetNumGuildBankTabs())
        end
    end, sizeStopFunc= function(btn)
        if btn.targetFrame.mode== "bank" then
            local h= math.ceil((GuildBankFrame:GetHeight()-90)/(Save().line+37))
            Save().num= h
            Init_Button(btn.targetFrame)
        else
            Save().otherSize= {btn.targetFrame:GetSize()}
        end
    end})


   -- hooksecurefunc(GuildBankFrame, 'Update', Init_Button)
   hooksecurefunc(GuildBankFrame, 'Update', Init_Button)

    hooksecurefunc(GuildBankFrame, 'UpdateFiltered', function(self)
        if self.mode ~= "bank" then
            return
        end
        local isFiltered
        for index= MAX_GUILDBANK_SLOTS_PER_TAB+1, #Buttons do
            local btn=Buttons[index]
            isFiltered= select(4, GetGuildBankItemInfo(btn.tabID, btn:GetID()))
            btn:SetMatchesSearch(not isFiltered)
        end
    end)

    hooksecurefunc(GuildBankFrame, 'UpdateTabs', Set_UpdateTabs)


--调整，UI
    Init_UI()

    GuildBankFrame:HookScript('OnHide', function()
        WoWTools_GuildBankMixin.isInRun= nil
    end)

    return true
end
















function WoWTools_GuildBankMixin:Init_Plus()
    if Init() then
        Init=function () end
        return true
    end
end


function WoWTools_GuildBankMixin:Update_Button()
    Init_Button(GuildBankFrame)
    Set_UpdateTabs(GuildBankFrame)
end