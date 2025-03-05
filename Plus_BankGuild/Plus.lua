local e= select(2, ...)
local function Save()
    return WoWTools_GuildBankMixin.Save
end
--Blizzard_GuildBankUI.lua

local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14

local Buttons={}--新建按钮
local MainButtons={}--自带按钮
local NumLeftButton=0

local TabNameLabels={}--创建，索引标签

--local Items={  --[tabID][slotID]=itemLink,}




local function Set_Frame_Size(frame, currentIndex, numTab)
    local x= NumLeftButton
    if frame.mode=='bank' then
        currentIndex= currentIndex or GetCurrentGuildBankTab()--当前 Tab
        numTab= numTab or GetNumGuildBankTabs()--总计Tab
        if currentIndex<= numTab then
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



 --索引，提示
 local function Set_IndexLabel(btn)
    btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BACKGROUND'})
    btn.indexLable:SetPoint('CENTER')
    btn.indexLable:SetText(btn:GetID())
    btn.indexLable:SetAlpha(0.3)
    btn.NormalTexture:SetAlpha(0.2)
end

--设置，索引颜色
local function Set_IndexLabel_Color(btn, lableColor, isCurrent)
    if isCurrent then
        btn.indexLable:SetTextColor(1, 0, 1)
    elseif select(2, math.modf(lableColor/2))==0 then
        btn.indexLable:SetTextColor(1, 0.82, 0)
    else
        btn.indexLable:SetTextColor(0, 0.68, 1)
    end
end

--创建，索引标签
local function Creater_TabName_ForButton(btn, tabID)
    local label= WoWTools_LabelMixin:Create(btn)
    label:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT', 0, 4)
    label:SetTextColor(0.62, 0.62, 0.62)
    TabNameLabels[tabID]= label
end




local function Click_Tab(self)
    local btn = _G['GuildBankTab'..self.tabID]
    if btn then
        btn:OnClick('LeftButton')
    else
        SetCurrentGuildBankTab(self.tabID)
    end
end





--GuildBankItemButtonMixin 
--需要 GetCurrentGuildBankTab() 修改成 self.tabID
local function Create_Button(tabID, slotID)
    local btn= CreateFrame('ItemButton', 'WoWToolsGuildItemButton'..tabID..'_'..slotID, MainButtons[1], 'GuildBankItemButtonTemplate', slotID)

    btn.SplitStack = function(button, split)
        SplitGuildBankItem(button.tabID, button:GetID(), split)
    end

    btn:SetScript('OnClick', function(self, d)
        if HandleModifiedItemClick(GetGuildBankItemLink(self.tabID, self:GetID())) then
            return
        end
        if ( IsModifiedClick("SPLITSTACK") ) then
            if ( not CursorHasItem() ) then
                local texture, count, locked = GetGuildBankItemInfo(self.tabID, self:GetID())
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

    function btn:OnEnter()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetGuildBankItem(self.tabID, self:GetID())
    end
    btn.UpdateTooltip = btn.OnEnter
    btn:SetScript('OnEnter', function(self)
        Click_Tab(self)
        self:OnEnter()
    end)

    btn:SetScript('OnDragStart', function(self)
        PickupGuildBankItem(self.tabID, self:GetID())
    end)

    btn:SetScript('OnReceiveDrag', function(self)
        Click_Tab(self)
        PickupGuildBankItem(self.tabID, self:GetID())
    end)

    function btn:set_item()
        local tab, slot= self.tabID, self:GetID()
        local texture, itemCount, locked, isFiltered, quality = GetGuildBankItemInfo(tab, slot)

        SetItemButtonTexture(self, texture)
        SetItemButtonCount(self, itemCount)
        SetItemButtonDesaturated(self, locked)

        self:SetMatchesSearch(not isFiltered)

        SetItemButtonQuality(self, quality, GetGuildBankItemLink(tab, slot))

        e.Set_Item_Info(btn, {guidBank={tab=tab, slot=slot}})
    end

    Set_IndexLabel(btn)

    if slotID==1 then
        Creater_TabName_ForButton(btn, tabID)
    end

    return btn
end














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

    local num= Save().num
    local line= Save().line
    local index= 1--MAX_GUILDBANK_SLOTS_PER_TAB--98

    for tabID=1, numTab do
        --Items[tabID]= Items[tabID] or {}
        if select(3, GetGuildBankTabInfo(tabID)) then
            if currentIndex~=tabID then
                for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                    local btn= Buttons[index]
                    if not btn then
                        btn= Create_Button(tabID, slotID)
                        Buttons[index]= btn
                    end

                    btn.tabID= tabID
                    btn:set_item()
                    index= index+1
                    table.insert(newTab, btn)

                end
            else
                for slotID, btn in pairs(MainButtons) do
                    btn.tabID= tabID
                    table.insert(newTab, btn)
                    --Items[tabID][slotID]=GetGuildBankItemLink(tabID, slotID)

                    e.Set_Item_Info(btn,{guidBank={tab=tabID, slot=slotID}})
                end
            end
        end
    end


    local leftButton,  lableColor, newLine

    NumLeftButton=0
    index=0

    for i, btn in pairs(newTab) do
        btn:ClearAllPoints()
        index= index+1
        lableColor, newLine= math.modf((i-1)/MAX_GUILDBANK_SLOTS_PER_TAB)
        if newLine==0 or select(2, math.modf((index-1)/num))==0 then
            if i==1 then
                btn:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -60)
            else
                btn:SetPoint('LEFT', leftButton, 'RIGHT', line, 0)
                index=1
            end
            leftButton= btn
            NumLeftButton=NumLeftButton+1
        else
            btn:SetPoint('TOP', newTab[i-1], 'BOTTOM', 0, -line)
        end

--设置，索引颜色
        Set_IndexLabel_Color(btn, lableColor, btn.tabID==currentIndex)


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

    Update_ResizeButton(self, currentIndex, numTab)--缩放按钮

    local name, icon, _, canDeposit, numWithdrawals, remainingWithdrawals, label, access

    for tabID= 1, GetNumGuildBankTabs(), 1 do
        name, icon, _, canDeposit, numWithdrawals, remainingWithdrawals= GetGuildBankTabInfo(tabID)
--Tab 名称
        local btn= _G['GuildBankTab'..tabID]
        if btn then
            if not btn.indexLable then
                btn.indexLable= WoWTools_LabelMixin:Create(btn)
                btn.indexLable:SetPoint('TOPLEFT', btn.Button, 'BOTTOMLEFT')
            end
            btn.indexLable:SetText(name or '')
            btn.indexLable:SetAlpha(currentIndex==tabID and 1 or 0.3)
            Set_IndexLabel_Color(btn, tabID, currentIndex==tabID)
        end

--标签，提示
        label= currentIndex==tabID and self.LimitLabel or TabNameLabels[tabID]
        if label then
            access= ( not canDeposit and numWithdrawals==0 and '|A:Monuments-Lock:0:0|a' )--锁定
                or ( not canDeposit and '|A:Cursor_OpenHand_32:0:0|a' )--只能提取
                or ( numWithdrawals==0 and '|A:Banker:0:0|a' )--只能存放 --or GUILDBANK_TAB_FULL_ACCESS--全部权限

            label:SetText(
                '|T'..(icon or 0)..':0|t'
                ..(
                    remainingWithdrawals > 0  and remainingWithdrawals
                    or ( (remainingWithdrawals==0 and access) and (e.onlyChinese and '无' or NONE) )
                    or ( e.onlyChinese and '无限制' or UNLIMITED )
                )
                ..(access or '')
            )
        end
    end
end



















local function Init()
    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(slotID, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if ( btnIndex == 0 ) then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((slotID-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn=GuildBankFrame.Columns[column].Buttons[btnIndex]

        MainButtons[slotID]= btn

        Set_IndexLabel(btn)
    end


    WoWTools_MoveMixin:Setup(GuildBankFrame, {setSize=true, needSize=true, needMove=true, minW=80, minH=140,
        sizeUpdateFunc= function(btn)
           
        end, sizeRestFunc= function(btn)
            Save().otherSize= nil
            Save().num=15
            if btn.target.mode== "bank" then
                Init_Button(btn.target)
            else
                Set_Frame_Size(btn.target, nil, nil)
            end
        end, sizeStopFunc= function(btn)
            if btn.target.mode== "bank" then
                local h= math.ceil((GuildBankFrame:GetHeight()-90)/(Save().line+37))
                Save().num= h
                Init_Button(btn.target)
            else
                Save().otherSize= {btn.target:GetSize()}
            end
        end
    })

    -- bank, log, moneylog, tabinfo
    hooksecurefunc(GuildBankFrame, 'Update', Init_Button)
    hooksecurefunc(GuildBankFrame, 'UpdateFiltered', function(self)
        if self.mode ~= "bank" then
            return
        end
        local isFiltered
        for index=MAX_GUILDBANK_SLOTS_PER_TAB+1, #Buttons do
            local btn=Buttons[index]
            isFiltered= select(4, GetGuildBankItemInfo(btn.tabID, btn:GetID()))
            btn:SetMatchesSearch(not isFiltered)
        end
    end)



    hooksecurefunc(GuildBankFrame, 'UpdateTabs', Set_UpdateTabs)


--更改UI位置
    GuildBankFrame.TabTitle:SetPoint('CENTER', GuildBankFrame.TabTitleBG, 0, 10)

    --"%s的每日提取额度剩余：|cffffffff%s|r"
    GuildBankFrame.LimitLabel:ClearAllPoints()
    GuildBankFrame.LimitLabel:SetPoint('BOTTOMLEFT', GuildBankFrame.Column1.Button1, 'TOPLEFT', 0, 4)
    GuildBankFrame.LimitLabel:SetTextColor(1,0,1)

    GuildBankFrame.DepositButton:ClearAllPoints()
    GuildBankFrame.DepositButton:SetPoint('BOTTOMRIGHT', -8, 8)

    GuildBankMoneyFrame:ClearAllPoints()
    GuildBankMoneyFrame:SetPoint('RIGHT', GuildBankFrame.WithdrawButton, 'LEFT')

    GuildItemSearchBox:ClearAllPoints()
    GuildItemSearchBox:SetPoint('RIGHT', GuildBankMoneyFrame, 'LEFT', -6, 0)

    GuildBankWithdrawMoneyFrame:ClearAllPoints()
    GuildBankWithdrawMoneyFrame:SetPoint('RIGHT', GuildItemSearchBox, 'LEFT', -2, 0)

    GuildBankMoneyLimitLabel:ClearAllPoints()
    GuildBankMoneyLimitLabel:SetPoint('RIGHT', GuildBankWithdrawMoneyFrame, 'LEFT')


--信息，标签

    GuildBankInfoScrollFrame:SetPoint('TOPLEFT', GuildBankFrame, 24, -54)
    GuildBankInfoScrollFrame:SetPoint('BOTTOMRIGHT', GuildBankFrame, -30, 54)
    --GuildBankInfoScrollFrame:SetPoint('BOTTOMRIGHT')

    return true
end
















function WoWTools_GuildBankMixin:Init_Plus()
    if Init() then
        Init=function () end
    end
end


function WoWTools_GuildBankMixin:Init_Button()
    Init_Button(GuildBankFrame)
end