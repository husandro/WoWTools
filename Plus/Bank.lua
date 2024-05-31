local id, e = ...
local addName= BANK
local Save={
    --disabled=true,--禁用
    --hideReagentBankFrame=true,--银行,隐藏，材料包
    --scaleReagentBankFrame=0.75,--银行，缩放
    xReagentBankFrame=-15,--坐标x
    yReagentBankFrame=10,--坐标y
    --pointReagentBank=｛｝--保存位置
    line=2,
    num=14,

    allBank=true,--转化为联合的大包
    --notSearchItem=true,--OnEnter时，搜索物品

    --showIndex=true,--显示，索引
    --showBackground= true,--设置，背景
}
local Initializer















--增强，原生
local function Init_Bank_Plus()--增强，原生
    ReagentBankFrame.autoSortButton:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 2, 0)--整理材料银行


    --选项
    ReagentBankFrame.ShowHideButton= e.Cbtn(BankFrame, {size={18,18}, atlas='hide'})
    ReagentBankFrame.ShowHideButton:SetPoint('BOTTOMRIGHT', _G['BankFrameTab1'], 'BOTTOMLEFT')
    function ReagentBankFrame.ShowHideButton:set_atlas()
        self:SetNormalAtlas(Save.hideReagentBankFrame and 'editmode-up-arrow' or 'editmode-down-arrow')
    end
    function ReagentBankFrame.ShowHideButton:set_scale()
        if BankFrame.activeTabIndex==2 then
            ReagentBankFrame:SetScale(1)
        else
            ReagentBankFrame:SetScale(Save.scaleReagentBankFrame or 1)
        end
    end
    function ReagentBankFrame.ShowHideButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示材料银行' or REAGENT_BANK, e.GetShowHide(not Save.hideReagentBankFrame)..e.Icon.left)
        e.tips:AddLine(' ')

        local col= not ReagentBankFrame:IsShown() and '|cff606060'
        e.tips:AddDoubleLine((col or '')..(e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleReagentBankFrame or 1), (col or '')..'Alt+'..e.Icon.mid)

        if Save.pointReagentBank then
            col='|cff606060'
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((col or '')..'X |cnGREEN_FONT_COLOR:'..Save.xReagentBankFrame, (col or '')..'Ctrl+'..e.Icon.mid)
        e.tips:AddDoubleLine((col or '')..'Y |cnGREEN_FONT_COLOR:'..Save.yReagentBankFrame, (col or '')..'Shift+'..e.Icon.mid)
        col= Save.pointReagentBank and '' or '|cff606060'
        e.tips:AddDoubleLine(col..(e.onlyChinese and '还原位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
        e.tips:Show()
    end
    ReagentBankFrame.ShowHideButton:SetScript('OnClick', function(self, d)
        if IsControlKeyDown() and d=='RightButton' then
            Save.pointReagentBank= nil
            self:show_hide()
            self:set_tooltips()
            print(id, Initializer:GetName(), e.onlyChinese and '还原位置' or RESET_POSITION)
        else
            Save.hideReagentBankFrame= not Save.hideReagentBankFrame and true or nil
            self:show_hide(Save.hideReagentBankFrame)
            self:set_atlas()
            self:set_tooltips()
        end
    end)

    ReagentBankFrame.ShowHideButton:SetScript('OnLeave', GameTooltip_Hide)
    ReagentBankFrame.ShowHideButton:SetScript('OnEnter', ReagentBankFrame.ShowHideButton.set_tooltips)
    ReagentBankFrame.ShowHideButton:SetScript('OnMouseWheel', function(self, d)
        if Save.hideReagentBankFrame then
            return
        end
        local n
        if IsAltKeyDown() then
            n= Save.scaleReagentBankFrame or 1--缩放
            if d==1 then
                n= n+0.05
            elseif d==-1 then
                n= n-0.05
            end
            n= n>4 and 4 or n
            n= n<0.4 and 0.4 or n
            Save.scaleReagentBankFrame= n
            self:set_scale()
        elseif not Save.pointReagentBank then
            if IsControlKeyDown() then
                n= Save.xReagentBankFrame--坐标 X
                if d==1 then
                    n= n+5
                elseif d==-1 then
                    n= n-5
                end
                Save.xReagentBankFrame= n
                self:show_hide()--设置，显示材料银行
            elseif IsShiftKeyDown() then
                n= Save.yReagentBankFrame--坐标 Y
                if d==1 then
                    n= n+5
                elseif d==-1 then
                    n= n-5
                end
                Save.yReagentBankFrame= n
                self:show_hide()--设置，显示材料银行
            end
        end
        self:set_tooltips()
    end)
    ReagentBankFrame.ShowHideButton:set_scale()
    ReagentBankFrame.ShowHideButton:set_atlas()




    --移动
    ReagentBankFrame:SetClampedToScreen(false)
    ReagentBankFrame:SetMovable(true)
    ReagentBankFrame:HookScript("OnDragStart", ReagentBankFrame.StartMoving)
    ReagentBankFrame:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.pointReagentBank= {self:GetPoint(1)}
        Save.pointReagentBank[2]= nil
        ResetCursor()
    end)
    ReagentBankFrame:HookScript("OnMouseUp", ResetCursor)--停止移动
    ReagentBankFrame:HookScript("OnMouseDown", function(_, d)--设置, 光标
        SetCursor('UI_MOVE_CURSOR')
    end)
    ReagentBankFrame:RegisterForDrag("RightButton", "LeftButton")


    --添加，背景
    ReagentBankFrame.Bg= ReagentBankFrame:CreateTexture(nil, 'BACKGROUND')
    ReagentBankFrame.Bg:SetSize(715, 350)
    ReagentBankFrame.Bg:SetPoint('BOTTOMLEFT',10, 10)
    ReagentBankFrame.Bg:SetAtlas('auctionhouse-background-buy-noncommodities-market')
    --ReagentBankFrame.Bg:SetAlpha(0.5)
    e.Set_Label_Texture_Color(ReagentBankFrame.Bg, {type='Texture', alpha=0.5})--设置颜色
    --ReagentBankFrame.Bg:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
    ReagentBankFrame:SetSize(715, 415)--386, 415
    --设置，显示材料银行
    function ReagentBankFrame.ShowHideButton:show_hide(hide)
        --local unlocked= IsReagentBankUnlocked()
        if (not Save.hideReagentBankFrame or hide) and BankFrame.activeTabIndex then
            if BankFrame.activeTabIndex==1 and not hide then
            -- BankFrame:SetSize(370, 300)--<Size x="386" y="415"/>
                ReagentBankFrame:ClearAllPoints()
                if Save.pointReagentBank then
                    ReagentBankFrame:SetPoint(Save.pointReagentBank[1], UIParent, Save.pointReagentBank[3], Save.pointReagentBank[4],  Save.pointReagentBank[5])
                else
                    ReagentBankFrame:SetPoint('TOPLEFT', BankFrame, 'BOTTOMLEFT', Save.xReagentBankFrame, Save.yReagentBankFrame)
                end
                ReagentBankFrame:SetShown(true)
            elseif BankFrame.activeTabIndex==2 or hide then
                ReagentBankFrame:ClearAllPoints()
                ReagentBankFrame:SetPoint('TOPLEFT')
                if hide then
                    ReagentBankFrame:SetShown(false)
                end
            end
        end
        ReagentBankFrame.ShowHideButton:SetShown(BankFrame.activeTabIndex==1)--选项
        ReagentBankFrame.ShowHideButton:set_scale()--缩放
        ReagentBankFrame.autoSortButton:SetShown(not Save.hideReagentBankFrame and BankFrame.activeTabIndex==1)--整理材料银行
    end
    hooksecurefunc('BankFrame_ShowPanel', ReagentBankFrame.ShowHideButton.show_hide)

end
















--整合，一起
--#########
local SetAllBank
local function Init_All_Bank()
    SetAllBank= e.Cbtn(BankFrame.TitleContainer, {size={22,22}, icon=true})
    SetAllBank:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerBankFrame'] then
        SetAllBank:SetPoint('RIGHT', _G['MoveZoomInButtonPerBankFrame'], 'LEFT')
    else
        SetAllBank:SetPoint('LEFT', 12,0)
    end
    function SetAllBank:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS)..' |cnGREEN_FONT_COLOR:'..Save.num, e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '间隔' or 'Interval')..' |cnGREEN_FONT_COLOR:'..Save.line, 'Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '索引' or 'Index', e.Icon.left)
        e.tips:AddDoubleLine(Save.showBackground and (e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND) or (e.onlyChinese and '隐藏背景' or HIDE_PULLOUT_BG ), e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end
    --设置，背景
    function SetAllBank:set_background()
        if Save.showBackground~=nil then
            if Save.showBackground then
                BankFrame:DisableDrawLayer('BACKGROUND')
            else
                BankFrame:EnableDrawLayer('BACKGROUND')
            end
        end
    end
    SetAllBank:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Save.showIndex= not Save.showIndex and true or nil--显示，索引
            self:set_bank()--设置，银行，按钮
            self:set_reagent()--设置，材料，按钮
            self:set_size()--设置，外框，大小

        elseif d=='RightButton' then
            Save.showBackground= not Save.showBackground and true or false
            self:set_background()--设置，背景
        end
        self:set_tooltips()
    end)
    SetAllBank:SetScript('OnMouseWheel', function(self, d)
        if not IsModifierKeyDown() then
            local n= Save.num
            if d==1 then
                n= n-1
            elseif d==-1 then
                n=n +1
            end
            n= n<4 and 4 or n
            n= n>24 and 24 or n
            Save.num= n
        elseif IsAltKeyDown() then
            local n= Save.line
            if d==1 then
                n= n-1
            elseif d==-1 then
                n= n+1
            end
            n=n<0 and 0 or n
            n=n>24 and 24 or n
            Save.line= n
        end
        self:set_bank()--设置，银行，按钮
        self:set_reagent()--设置，材料，按钮
        self:set_size()--设置，外框，大小
        self:set_tooltips()
    end)

    SetAllBank:SetScript('OnLeave', function(self) self:SetAlpha(0.5) e.tips:Hide() end)
    SetAllBank:SetScript('OnEnter', SetAllBank.set_tooltips)


    --索引，提示
    function SetAllBank:set_index_label(btn, index)
        if not btn.indexLable and Save.showIndex then
            btn.indexLable= e.Cstr(btn, {layer='BACKGROUND', color={r=1,g=1,b=1}})
            btn.indexLable:SetPoint('CENTER')
            btn.indexLable:SetAlpha(0.2)
        end
        if btn.indexLable then
            btn.indexLable:SetText(Save.showIndex and index or '')
        end
    end

    --设置，银行，按钮
    function SetAllBank:set_bank()
        self.last=nil
        self.num=0
        local last
        local tab={}
        for i=1, NUM_BANKGENERIC_SLOTS do--NUM_BANKGENERIC_SLOTS 28
            local btn= BankSlotsFrame["Item"..i]
            if btn then
                btn:ClearAllPoints()
                if not self.last then
                    btn:SetPoint('TOPLEFT', 8,-60)
                    self.last=btn
                    self.num= self.num+1
                    last=btn
                else
                    btn:SetPoint('TOP', last, 'BOTTOM', 0, -Save.line)
                    last=btn
                end
                btn.index=i
                self:set_index_label(btn, i)--索引，提示
                table.insert(tab, btn)
            end
        end

        local num=0
        local bagindex
        local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES
        for i=1, NUM_BANKBAGSLOTS do
            local bag= i+ numBag
            bagindex= bagindex and bagindex+1 or bag
            local bagFrame= _G['ContainerFrame'..bag]
            local bagID= bagFrame and bagFrame:GetID() or 0
            if bagFrame and bagID>= numBag then
                bagFrame:ClearAllPoints()
                bagFrame:SetPoint('RIGHT', UIParent, 'LEFT', -10, 0)
                for slot=1, ContainerFrame_GetContainerNumSlots(bagFrame:GetID()) do-- C_Container.GetContainerNumSlots(bagindex) do
                    local btn=_G['ContainerFrame'..(bagindex)..'Item'..slot]
                    if btn then
                        if bagFrame:IsShown() then
                            num=num+1
                            btn:SetParent(BankSlotsFrame)
                            btn:ClearAllPoints()
                            btn:SetPoint('TOP', last, 'BOTTOM', 0, -Save.line)
                            last=btn
                            table.insert(tab, btn)
                            btn:SetShown(true)
                            self:set_index_label(btn, num+NUM_BANKGENERIC_SLOTS)--索引，提示
                        else
                            btn:SetShown(false)
                        end
                    end
                end
            end
        end

        for i=Save.num+1, #tab, Save.num do--NUM_BANKGENERIC_SLOTS 28
            local btn= tab[i]
            if btn then
                btn:ClearAllPoints()
                btn:SetPoint('LEFT', self.last, 'RIGHT', Save.line, 0)
                self.last= btn
                self.num= self.num+1
            end
        end

        --材料包
        for i=1, NUM_BANKBAGSLOTS do--NUM_BANKBAGSLOTS 7
            local btn= BankSlotsFrame['Bag'..i]
            if btn then
                btn:ClearAllPoints()
                if i==1 then
                    btn:SetPoint('TOPLEFT', _G['BankFrameItem'..Save.num], 'BOTTOMLEFT', 0,-8)
                else
                    btn:SetPoint('LEFT', BankSlotsFrame['Bag'..(i-1)], 'RIGHT', Save.line, 0)
                end

            end

        end
    end



    --设置，材料，按钮
    function SetAllBank:set_reagent()
        self.reagentNum= 0
        local btnNum=0
        for index, btn in ReagentBankFrame:EnumerateItems() do
            btn:ClearAllPoints()
            if index==1 then
                if BankFrame.activeTabIndex==2 then
                    btn:ClearAllPoints()
                    btn:SetPoint('TOPLEFT', 8,-60)
                else
                    btn:SetPoint('LEFT', self.last, 'RIGHT', Save.line+6, 0)
                end
                self.last=btn
                self.reagentNum= self.reagentNum+1
            else
                btn:SetPoint('TOP', ReagentBankFrame["Item"..(index-1)], 'BOTTOM', 0, -Save.line)
            end
            if not btn.Bg then
                btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
                btn.Bg:SetAllPoints(btn)
                btn.Bg:SetAtlas('ChallengeMode-DungeonIconFrame')
                btn.Bg:SetAlpha(0.5)
            end
            self:set_index_label(btn, index)--索引，提示
            btnNum=index
        end
        for i=Save.num+1, btnNum, Save.num do
            local btn= ReagentBankFrame["Item"..i]
            btn:ClearAllPoints()
            btn:SetPoint('LEFT', self.last, 'RIGHT', Save.line, 0)
            self.last= btn
            self.reagentNum= self.reagentNum+1
        end
        self.last=nil
    end


    function SetAllBank:set_size()--设置，外框，大小
        if BankFrame.activeTabIndex==1 then
            local num= SetAllBank.num + SetAllBank.reagentNum
            BankFrame:SetSize(8+num*37+((num-1)*Save.line)+8+8+2, (Save.num+1)*37 +((Save.num-1)*Save.line)+64+8+6)
        elseif BankFrame.activeTabIndex==2 then
            local num= SetAllBank.reagentNum
            BankFrame:SetSize(8+(num*38)+((num-1)*Save.line), 64+(Save.num*37)+(Save.num*Save.line)+8)--设置，大小
        end
    end



    --隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位"
    for _, region in pairs({BankSlotsFrame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then
            region:SetText('')
            region:Hide()
        end
    end

    ReagentBankFrame:HookScript('OnShow', function(self)
        if self.isSetPoint or not self.slots_initialized then--or not IsReagentBankUnlocked() then
            return
        end
        self.isSetPoint=true

        for _, region in pairs({ReagentBankFrame:GetRegions()}) do--隐藏，材料包，背景
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
                region:Hide()
            end
        end

        BankItemSearchBox:ClearAllPoints()--移动，搜索框
        BankItemSearchBox:SetPoint('TOP', 0,-33)

        BankItemAutoSortButton:ClearAllPoints()--移动，整理，按钮
        BankItemAutoSortButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
        BankItemAutoSortButton:SetParent(BankSlotsFrame)

        ReagentBankFrame.autoSortButton:SetPoint('LEFT', BankItemSearchBox, 'RIGHT', 2, 0)--整理材料银行

        ReagentBankFrame.DespositButton:ClearAllPoints()
        ReagentBankFrame.DespositButton:SetSize(23, 23)
        ReagentBankFrame.DespositButton:SetPoint('LEFT', ReagentBankFrame.autoSortButton, 'RIGHT', 2, 0)
        ReagentBankFrame.DespositButton:SetText('')
        ReagentBankFrame.DespositButton.Middle:Hide()
        ReagentBankFrame.DespositButton.Right:Hide()
        ReagentBankFrame.DespositButton.Left:Hide()
        ReagentBankFrame.DespositButton:SetNormalAtlas('poi-traveldirections-arrow')
        ReagentBankFrame.DespositButton:GetNormalTexture():SetTexCoord(0,1,1,0)
        ReagentBankFrame.DespositButton:SetHighlightAtlas('auctionhouse-nav-button-select')
        ReagentBankFrame.DespositButton:SetPushedAtlas('auctionhouse-nav-button-select')
        ReagentBankFrame.DespositButton:HookScript('OnLeave', GameTooltip_Hide)
        ReagentBankFrame.DespositButton:HookScript('OnEnter', function(s)
            e.tips:SetOwner(s, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT)
            e.tips:Show()
        end)
    end)


    hooksecurefunc('BankFrame_ShowPanel', function()
        if BankFrame.activeTabIndex==1 then
            ReagentBankFrame:SetShown(true)
            SetAllBank:set_bank()--设置，银行，按钮
            SetAllBank:set_reagent()--设置，材料，按钮

        elseif BankFrame.activeTabIndex==2 then
            local btn= ReagentBankFrame["Item1"]
            if btn then
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', 8,-60)
            end
        end
        SetAllBank:set_size()--设置，外框，大小
        if not IsReagentBankUnlocked() and ReagentBankFrame.UnlockInfo then
            ReagentBankFrame.UnlockInfo:SetShown(BankFrame.activeTabIndex==2)
        end

    end)

    hooksecurefunc('BankFrameItemButtonBag_OnClick', function()
        SetAllBank:set_bank()--设置，银行，按钮
        SetAllBank:set_reagent()--设置，材料，按钮
        SetAllBank:set_size()--设置，外框，大小
    end)


    BankFramePurchaseButton:SetWidth(BankFramePurchaseButton:GetFontString():GetWidth()+12)
    hooksecurefunc('UpdateBagSlotStatus', function()
        if BankFramePurchaseInfo then
            BankFramePurchaseInfo:ClearAllPoints()
            BankFramePurchaseInfo:SetPoint('Top', BankFrame, 'BOTTOM')
            BankFramePurchaseButton:ClearAllPoints()
            if BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS] then
                BankFramePurchaseButton:SetPoint('LEFT', BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS], 'RIGHT', 2,0)
            else
                BankFramePurchaseButton:SetPoint('BOTTOM', BankFrame)
            end
        end
    end)
    SetAllBank:set_bank()--设置，银行，按钮
    SetAllBank:set_background()--设置，背景
end























--[[
local AllPlayerBankItem
local function Init_Save_BankItem()
    if not e.Player.husandro then
        return
    end
    AllPlayerBankItem= e.Cbtn(BankFrame.TitleContainer, {size={22,22}, atlas='Banker'})
    AllPlayerBankItem:SetPoint('LEFT', BankFrame.optionButton , 'RIGHT')
    AllPlayerBankItem:SetAlpha(0.5)
    function AllPlayerBankItem:get_item_text(itemID, quality)
        e.LoadDate({id=itemID, type='item'})
        local name= GetItemInfo(itemID) or itemID
        local hex= select(4, C_Item.GetItemQualityColor(quality or 1))
        local icon= C_Item.GetItemIconByID(itemID)
        return (icon and '|T'..icon..':0|t' or '')..(hex and '|c'..hex or '')..name
    end
    function AllPlayerBankItem:get_Player_item(playerGuid)
        local num=0
        local tabs={}
        for itemID, tab in pairs(e.WoWDate[playerGuid].Bank or {}) do
            table.insert(tabs, {itemID= itemID, num=tab.num, quality=tab.quality or 1})
        end
        table.sort(tabs, function(a, b)
            if not a.isReagent and b.isReagent then
                return true
            elseif a.quality==b.quality then
                return a.itemID< b.itemID
            else
                return a.quality< b.quality
            end
        end)
        for _, tab in pairs(tabs) do
            e.tips:AddDoubleLine(self:get_item_text(tab.itemID, tab.quality), tab.num)
            num= num+1
        end
        e.tips:AddDoubleLine(e.GetPlayerInfo({guid=playerGuid}), num)
    end

    AllPlayerBankItem:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.5) end)
    AllPlayerBankItem:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        self:get_Player_item(e.Player.guid)
        e.tips:Show()
        self:SetAlpha(1)
    end)
    function AllPlayerBankItem:save_button_info(button, isReagent)
        if button then
            local container = button:GetParent():GetID()
            local buttonID = button:GetID()
            local info = C_Container.GetContainerItemInfo(container, buttonID)
            if info and info.itemID then
                local num=C_Item.GetItemCount(info.itemID, true)- C_Item.GetItemCount(info.itemID, nil)
                e.WoWDate[e.Player.guid].Bank[info.itemID]={num=num, quality=info.quality, isReagent=isReagent}
            end
        end
    end

    BankSlotsFrame:HookScript('OnShow', function()
        --e.WoWDate[e.Player.guid].Bank={}
    end)
    BankSlotsFrame:HookScript('OnHide', function()
        for i=1, NUM_BANKGENERIC_SLOTS do
            local button = BankSlotsFrame["Item"..i]
            --AllPlayerBankItem:save_button_info(button)
        end

        --for i=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
        local bagindex
        local numBag= NUM_TOTAL_EQUIPPED_BAG_SLOTS+ NUM_REAGENTBAG_FRAMES
        for i=1, NUM_BANKBAGSLOTS do
            local bag= i+ numBag
            bagindex= bagindex and bagindex+1 or bag
            local bagFrame= _G['ContainerFrame'..bag]
            for slot=1, ContainerFrame_GetContainerNumSlots(bagFrame:GetID()) do-- C_Container.GetContainerNumSlots(bagindex) do
                local button=_G['ContainerFrame'..(bagindex)..'Item'..slot]

                AllPlayerBankItem:save_button_info(button)
            end
        end
    end)
    ReagentBankFrame:HookScript('OnHide', function(self)
        for _, button in self:EnumerateItems() do
            --AllPlayerBankItem:save_button_info(button, true)
        end

    end)

end
]]















local function Init_Desposit_TakeOut_All_Items()--存放，取出，所有
    --取出，所有, 物品
    local btn= e.Cbtn(BankSlotsFrame, {size=23, icon='hide'})
    btn:SetNormalAtlas('poi-traveldirections-arrow')
    btn:GetNormalTexture():SetTexCoord(1,0,1,0)
    if Save.allBank then
        btn:SetPoint('RIGHT', BankItemAutoSortButton, 'LEFT', -2, 0)
    else
        btn:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
    end
    function btn:get_bag_slot(frame)
        return frame.isBag and Enum.BagIndex.Bankbag or frame:GetParent():GetID(), frame:GetID()
    end
    function btn:get_free()
        local free= 0--CalculateTotalNumberOfFreeBagSlots() MainMenuBarBagButtons.lua
        for i = BACKPACK_CONTAINER, NUM_BAG_FRAMES do
            free= free+ (C_Container.GetContainerNumFreeSlots(i) or 0)
        end
        return free
    end
    btn:SetScript('OnClick', function(self)
        local free= self:get_free()
        if free==0 then
            return
        end
        for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                    self:show_tooltips()
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        for i=NUM_BANKGENERIC_SLOTS, 1, -1 do--28
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                self:show_tooltips()
                return
            end
            local bag, slot = self:get_bag_slot(BankSlotsFrame["Item"..i])
            if bag and slot then
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        self:show_tooltips()
    end)
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= self:get_free()
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有物品' or 'Take out all items',
            format('|A:bag-main:0:0|a%s #%s%d',
                e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btn:show_tooltips()
        C_Timer.After(1.8, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btn:HookScript('OnLeave', GameTooltip_Hide)
    btn:HookScript('OnEnter', btn.set_tooltips)
    ReagentBankFrame.TakeOutAllItemButton= btn

    --存放，所有，物品
    btn= e.Cbtn(ReagentBankFrame.TakeOutAllItemButton, {size=23, icon='hide'})
    btn:SetNormalAtlas('poi-traveldirections-arrow')
    btn:GetNormalTexture():SetTexCoord(0,1,1,0)
    btn:SetPoint('RIGHT', ReagentBankFrame.TakeOutAllItemButton, 'LEFT', -2, 0)

    function btn:is_free(frame)
        if frame and frame:IsShown() then
            local info = C_Container.GetContainerItemInfo(frame.isBag and Enum.BagIndex.Bankbag or frame:GetParent():GetID(), frame:GetID()) or {}
            if not info.itemID then
                return true
            end
        end
    end
    function btn:get_free()
        local free= 0
        for i=1, NUM_BANKGENERIC_SLOTS do--28
            if self:is_free(BankSlotsFrame["Item"..i]) then
                free= free+1
            end
        end
        for bag=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if not info.itemID then
                    free= free+ 1
                end
            end
        end
        --for index, button in ReagentBankFrame:EnumerateItems() do
        return free
    end
    btn:SetScript('OnClick', function(self)
        local all= self:get_free()
        if all==0 then
            return
        end
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES do--NUM_TOTAL_EQUIPPED_BAG_SLOTS
            for slot= C_Container.GetContainerNumSlots(bag), 1, -1 do
                if not self:IsVisible() or IsModifierKeyDown() or all==0 then
                    self:show_tooltips()
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.hyperlink and not select(17, C_Item.GetItemInfo(info.hyperlink)) then
                    C_Container.UseContainerItem(bag, slot)
                    all= all-1
                end
            end
        end
        self:show_tooltips()
    end)
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= self:get_free()
        e.tips:AddDoubleLine(e.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GUILDCONTROL_DEPOSIT_ITEMS, ' ('..ALL..')'),
            format('|A:Banker:0:0|a%s #%s%d',
                e.onlyChinese and '银行' or BANK,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btn:show_tooltips()
        C_Timer.After(1.8, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btn:HookScript('OnLeave', GameTooltip_Hide)
    btn:HookScript('OnEnter', btn.set_tooltips)
    ReagentBankFrame.DespositAllItemButton= btn


    --取出，所有，材料
    btn= e.Cbtn(ReagentBankFrame.DespositButton, {size=23, icon='hide'})
    btn:SetNormalAtlas('poi-traveldirections-arrow')
    btn:GetNormalTexture():SetTexCoord(1,0,1,0)
    btn:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 2, 0)
    function btn:get_bag_slot(frame)
        return frame.isBag and Enum.BagIndex.Bankbag or frame:GetParent():GetID(), frame:GetID()
    end
    function btn:get_free()
        return C_Container.GetContainerNumFreeSlots(NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES) or 0
    end
    btn:SetScript('OnClick', function(self)
        local free= self:get_free()
        if free==0 then
            return
        end
        local tabs={}
        for _, frame in ReagentBankFrame:EnumerateItems() do
            table.insert(tabs, 1, frame)
        end
        for _, frame in pairs(tabs) do
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                self:show_tooltips()
                return
            end
            local bag, slot = self:get_bag_slot(frame)
            if bag and slot then
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        self:show_tooltips()
    end)
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= self:get_free()
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有材料' or 'Take out all reagents',
            format('|A:4549254:0:0|a%s #%s%d',
                e.onlyChinese and '材料' or AUCTION_CATEGORY_TRADE_GOODS,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btn:show_tooltips()
        C_Timer.After(1, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btn:HookScript('OnLeave', GameTooltip_Hide)
    btn:HookScript('OnEnter', btn.set_tooltips)
    ReagentBankFrame.TakeOutAllReagentsButton= btn
end



















--#######
--设置菜单
--#######
local function Init_Menu(_, level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED,
        checked= Save.allBank,
        keepShownOnClick=true,
        func= function()
            Save.allBank= not Save.allBank and true or nil
            BankFrame.optionButton:set_atlas()
            print(id, Initializer:GetName(),'|cnGREEN_FONT_COLOR:', e.GetEnabeleDisable(Save.allBank),  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    }, level)

    e.LibDD:UIDropDownMenu_AddButton({
        text= e.onlyChinese and '选项' or OPTIONS,
        notCheckable=true,
        icon= 'mechagon-projects',
        func= function()
            e.OpenPanelOpting(Initializer)
        end
    }, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({--重载
        text= '|TInterface\\Vehicles\\UI-Vehicles-Button-Exit-Up:0|t'..(e.onlyChinese and '重新加载UI' or RELOADUI),
        notCheckable=true,
        tooltipOnButton=true,
        tooltipTitle= SLASH_RELOAD1,-- '/reload',
        colorCode='|cffff0000',
        keepShownOnClick=true,
        func=function()
            e.Reload()
        end
    }, level)
end




--银行
--BankFrame.lua
local function Init_Bank_Frame()
    BankFrame.optionButton= e.Cbtn(BankFrame.TitleContainer, {size={22,22}, atlas='hide'})
    if _G['MoveZoomInButtonPerBankFrame'] then
        BankFrame.optionButton:SetPoint('LEFT', _G['MoveZoomInButtonPerBankFrame'], 'RIGHT')
    else
        BankFrame.optionButton:SetPoint('LEFT', 34,0)
    end
    function BankFrame.optionButton:set_atlas()
        self:SetNormalAtlas(Save.allBank and 'Warfronts-BaseMapIcons-Alliance-Workshop-Minimap' or 'Warfronts-BaseMapIcons-Empty-Workshop-Minimap')
    end
    BankFrame.optionButton:SetScript('OnLeave', function(self) self:SetAlpha(0.5) end)
    BankFrame.optionButton:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
    BankFrame.optionButton:SetScript('OnMouseDown', function(self)
        if not self.Menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)
    BankFrame.optionButton:SetAlpha(0.5)
    BankFrame.optionButton:set_atlas()

    local tab={--隐藏，背景
        'LeftTopCorner-Shadow',
        'LeftBottomCorner-Shadow',
        'RightTopCorner-Shadow',
        'RightBottomCorner-Shadow',
        'Right-Shadow',
        'Left-Shadow',
        'Bottom-Shadow',
        'Top-Shadow',
    }
    for _, textrue in pairs(tab) do
        if ReagentBankFrame[textrue] then
            ReagentBankFrame[textrue]:SetTexture(0)
            ReagentBankFrame[textrue]:Hide()
            ReagentBankFrame[textrue]:SetAlpha(0)
        end
    end

    --整理材料银行
    ReagentBankFrame.autoSortButton= CreateFrame("Button", nil, ReagentBankFrame, 'BankAutoSortButtonTemplate')
    ReagentBankFrame.autoSortButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(e.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        e.tips:Show()
    end)
    ReagentBankFrame.autoSortButton:SetScript('OnClick', function()
        C_Container.SortReagentBankBags()
    end)

    do
        if Save.allBank then
            Init_All_Bank()--整合，一起
        else
            Init_Bank_Plus()--增强，原生
        end
    end
    --Init_Save_BankItem()
    Init_Desposit_TakeOut_All_Items()--存放，取出，所有
end

















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if not Save.disabled then
                Init_Bank_Frame()--银行
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]= Save
        end
    end
end)
