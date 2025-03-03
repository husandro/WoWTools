local e= select(2, ...)
local function Save()
    return WoWTools_BankMixin.Save.guild
end
--Blizzard_GuildBankUI.lua



local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local Buttons={}
local NumLeftButton=0


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
 local function Set_IndexLabel(btn, index)
    local color= select(2, math.modf(index/2))==0 and {r=1,g=0.5,b=0}
                or {r=0,g=0.82,b=1}
    btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BACKGROUND', color=color})
    btn.indexLable:SetPoint('CENTER')
    btn.indexLable:SetAlpha(0.2)
    btn.indexLable:SetText(index)
end




local function Create_Button(index)--需要 GetCurrentGuildBankTab() 修改成 self.tabID
    local btn= CreateFrame('ItemButton', 'WoWToolsGuildItemButton'..index, Buttons[1], 'GuildBankItemButtonTemplate')

    btn.SplitStack = function(self, split)
		SplitGuildBankItem(self.tabID, self:GetID(), split)
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

    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetGuildBankItem(self.tabID, self:GetID())
    end)

    btn:SetScript('OnDragStart', function(self)
        PickupGuildBankItem(self.tabID, self:GetID())
    end)

    btn:SetScript('OnReceiveDrag', function(self)
        PickupGuildBankItem(self.tabID, self:GetID())
    end)
    
    Set_IndexLabel(btn, index)
    Buttons[index]= btn
    return btn
end




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
    local index=MAX_GUILDBANK_SLOTS_PER_TAB--98
    local texture, itemCount, locked, isFiltered, quality

    for tab=1, numTab do
        if currentIndex~=tab then
            for slot=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                index= index+1

                local btn= Buttons[index] or Create_Button(index)

                btn.tabID= tab
                btn:SetID(slot)

                texture, itemCount, locked, isFiltered, quality = GetGuildBankItemInfo(tab, slot)

                SetItemButtonTexture(btn, texture)
                SetItemButtonCount(btn, itemCount)
                SetItemButtonDesaturated(btn, locked)
                btn:SetMatchesSearch(not isFiltered)
                SetItemButtonQuality(btn, quality, GetGuildBankItemLink(tab, slot))
            end
        end
    end


    local leftButton
    NumLeftButton=0
    for i, btn in pairs(Buttons) do
        btn:ClearAllPoints()
        if select(2, math.modf((i-1)/num))==0 then
            if i==1 then
                btn:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -60)
            else
                btn:SetPoint('LEFT', leftButton, 'RIGHT', line, 0)
            end
            leftButton= btn
            NumLeftButton=NumLeftButton+1

        else
            btn:SetPoint('TOP', Buttons[i-1], 'BOTTOM', 0, -line)
        end
    end



    Set_Frame_Size(self)
end

    --[[local currentIndex= GetCurrentGuildBankTab()

    
	for tabIndex=1, GetNumGuildBankTabs() do-- MAX_GUILDBANK_TABS do
        for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
            if currentIndex==tabIndex then
                local btnIndex = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
                if ( btnIndex == 0 ) then
                    btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
                end
                local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
                local btn = frame.Columns[column].Buttons[btnIndex]
            end
            index= index+1
        end
    end

]]





local function Init()
    for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if ( btnIndex == 0 ) then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn=GuildBankFrame.Columns[column].Buttons[btnIndex]
        if btn then
            Set_IndexLabel(btn, i)
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

    hooksecurefunc(GuildBankFrame, 'UpdateTabs', function(self)
        if self.LimitLabel:IsShown() then
            local name, icon, _, _, _, remainingWithdrawals = GetGuildBankTabInfo(GetCurrentGuildBankTab())
            local stackString
            if ( remainingWithdrawals > 0 ) then
                stackString = format(STACKS, remainingWithdrawals)
            elseif ( remainingWithdrawals == 0 ) then
                stackString = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE)..'|r'
            else
                stackString = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '无限制' or UNLIMITED)..'|r'
            end
            self.LimitLabel:SetText(format(GUILDBANK_REMAINING_MONEY, '|T'..icon..':0|t', stackString))
        end
    end)
end


function WoWTools_BankMixin:Init_Guild()
    if e.Player.husandro then
        Init()
    else
        WoWTools_MoveMixin:Setup(GuildBankFrame)
    end
end