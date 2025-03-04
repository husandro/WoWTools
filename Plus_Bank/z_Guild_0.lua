local e= select(2, ...)
local function Save()
    return WoWTools_BankMixin.Save.guild
end
--Blizzard_GuildBankUI.lua



local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local Buttons={}
local NumLeftButton=0

local Items={
    --[tab]=slot=itemLink,
}




local function Set_Frame_Size(frame)
    local x= NumLeftButton
    if frame.mode=='bank' then
        local line= Save().line
        local y = Save().num

        frame:SetSize(
            x*(37+line) + 14,

            y*(37+line) + 112
        )
    else
        frame:SetSize(750, 428)
    end
end


 --索引，提示
 local function Set_IndexLabel(btn, tabID, slotID)
    local color
    if select(2, math.modf(tabID/2))~=0 then
        color= {r=1,g=0.5,b=0}--金色
    else
        color= {r=0,g=0.82,b=1}
    end
    btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BACKGROUND', color=color})
    btn.indexLable:SetPoint('CENTER')
    btn.indexLable:SetAlpha(0.2)
    btn.indexLable:SetText(slotID)
    btn.NormalTexture:SetAlpha(0.2)


end



--GuildBankItemButtonMixin 
--需要 GetCurrentGuildBankTab() 修改成 self.tabID
local function Create_Button(index, tabID, slotID)
    local btn= CreateFrame('ItemButton', 'WoWToolsGuildItemButton'..tabID..'_'..slotID, Buttons[1], 'GuildBankItemButtonTemplate')

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
    btn:SetScript('OnEnter', btn.OnEnter)

    btn:SetScript('OnDragStart', function(self)
        PickupGuildBankItem(self.tabID, self:GetID())
        print('|cnGREEN_FONT_COLOR:OnDragStart|r',self.tabID, self:GetID())
    end)

    btn:SetScript('OnReceiveDrag', function(self)
        print('OnReceiveDrag',self.tabID, self:GetID())
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
    end

    Set_IndexLabel(btn, tabID, slotID)

    Buttons[index]= btn
    return btn
end














--local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals, filtered = GetGuildBankTabInfo(tab)


local function Init_Button(self)
    self.ResizeButton.setSize= self.mode == "bank"
    local currentIndex= GetCurrentGuildBankTab()--当前 Tab
    local numTab= GetNumGuildBankTabs()--总计Tab
    local isBank= self.mode== "bank"

    self.ResizeButton.setSize= isBank--缩放，按钮

    if not isBank and currentIndex> numTab then
        self:SetSize(750, 428)
        return
    end

    local num= Save().num
    local line= Save().line
    local index= MAX_GUILDBANK_SLOTS_PER_TAB--98
    local lableIndex=2
    for tab=1, numTab do
        if currentIndex~=tab and select(3, GetGuildBankTabInfo(tab)) then
            
            for slot=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                index= index+1
                local btn= Buttons[index] or Create_Button(index, lableIndex, slot)

                btn.tabID= tab
                btn:SetID(slot)
                C_Timer.After(0.3, function() btn:set_item() end)
            end
            lableIndex= lableIndex+1
        end
    end

    local leftButton
    NumLeftButton=0
    index=0
    for i, btn in pairs(Buttons) do
        btn:ClearAllPoints()
        index= index+1
        if select(2, math.modf((i-1)/MAX_GUILDBANK_SLOTS_PER_TAB))==0 or select(2, math.modf((index-1)/num))==0 then
            if i==1 then
                btn:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -60)
            else
                btn:SetPoint('LEFT', leftButton, 'RIGHT', line, 0)
                index=1
            end
            leftButton= btn
            NumLeftButton=NumLeftButton+1

        else
            btn:SetPoint('TOP', Buttons[i-1], 'BOTTOM', 0, -line)
        end
    end


    Set_Frame_Size(self)
end







local function New_Items()
    Items={}
    C_Timer.After(0.5, function()

    for tab= GetNumGuildBankTabs(), 1, -1 do
        Items[tab]={}
        print(GetGuildBankTabInfo(tab))
        if select(3, GetGuildBankTabInfo(tab)) then
            do
                SetCurrentGuildBankTab(tab)
            end
            for slot= 1, MAX_GUILDBANK_SLOTS_PER_TAB do
                local texture, itemCount, locked, isFiltered, quality = GetGuildBankItemInfo(tab, slot)
                if texture then
                    Items[tab][slot]={
                            item={GetGuildBankItemInfo(tab, slot)},
                            link= GetGuildBankItemLink(tab, slot),
                    }
                    print(Items[tab][slot].item[1], Items[tab][slot].link)
                end
                
            end
        end
    end

    end)
end



local function Init()

    New_Items()
        

    for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if ( btnIndex == 0 ) then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn=GuildBankFrame.Columns[column].Buttons[btnIndex]
        if btn then
            Set_IndexLabel(btn, 1, i)
            btn.NormalTexture:SetAlpha(0.2)
            Buttons[i]= btn
        end
    end


    WoWTools_MoveMixin:Setup(GuildBankFrame, {setSize=true, needSize=true, needMove=true, minW=80, minH=140,
        sizeUpdateFunc= function()
            local h= math.ceil((GuildBankFrame:GetHeight()-112)/(Save().line+37))
            Save().num= h
        end, sizeRestFunc= function(btn)
            Save().num=15
            Init_Button(btn.target)
        end, sizeStopFunc= function(btn)
            Init_Button(btn.target)
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

    
    local function Set_UpdateTabs(self)
        if not self.LimitLabel:IsShown() then
            return
        end
        local name, icon, _, _, _, remainingWithdrawals = GetGuildBankTabInfo(GetCurrentGuildBankTab())
        local stackString
        if ( remainingWithdrawals > 0 ) then
            stackString = '#|cffffffff'..remainingWithdrawals
        elseif ( remainingWithdrawals == 0 ) then
            stackString = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)
        else
            stackString = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '无限制' or UNLIMITED)
        end
        self.LimitLabel:SetText('|T'..(icon or 0)..':0|t'..stackString)
    end

    hooksecurefunc(GuildBankFrame, 'UpdateTabs', function(self)
        Set_UpdateTabs(self)
    end)

    for tabID= 1, GetNumGuildBankTabs() do
        
        print(GetGuildBankTabInfo(tabID))
    end


end
















function WoWTools_BankMixin:Init_Guild()
    if e.Player.husandro then
        Init()
    else
        WoWTools_MoveMixin:Setup(GuildBankFrame)
    end
end