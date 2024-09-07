local id, e = ...
local addName
local Save={
    --disabled=true,--禁用
    --hideReagentBankFrame=true,--银行,隐藏，材料包
    --scaleReagentBankFrame=0.75,--银行，缩放
    xReagentBankFrame=-15,--坐标x
    yReagentBankFrame=10,--坐标y
    --pointReagentBank=｛｝--保存位置
    line=2,
    num=14,
    --notSearchItem=true,--OnEnter时，搜索物品
    --showIndex=true,--显示，索引
    --showBackground= true,--设置，背景

    allBank=true,--转化为联合的大包
    show_AllBank_Type=e.Player.husandro,--大包时，显示，存取，分类，按钮
    --show_AllBank_Type_Scale=1,
}
























--增强，原生
local function Init_Bank_Plus()--增强，原生
    --选项
    ReagentBankFrame.ShowHideButton= WoWTools_ButtonMixin:Cbtn(BankFrame, {size={18,18}, atlas='hide'})
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
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示材料银行' or REAGENT_BANK, e.GetShowHide(not Save.hideReagentBankFrame)..e.Icon.left)
        e.tips:AddLine(' ')

        local col= not ReagentBankFrame:IsShown() and '|cff9e9e9e'
        e.tips:AddDoubleLine((col or '')..(e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleReagentBankFrame or 1), (col or '')..'Alt+'..e.Icon.mid)

        if Save.pointReagentBank then
            col='|cff9e9e9e'
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((col or '')..'X |cnGREEN_FONT_COLOR:'..Save.xReagentBankFrame, (col or '')..'Ctrl+'..e.Icon.mid)
        e.tips:AddDoubleLine((col or '')..'Y |cnGREEN_FONT_COLOR:'..Save.yReagentBankFrame, (col or '')..'Shift+'..e.Icon.mid)
        col= Save.pointReagentBank and '' or '|cff9e9e9e'
        e.tips:AddDoubleLine(col..(e.onlyChinese and '还原位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
        e.tips:Show()
    end
    ReagentBankFrame.ShowHideButton:SetScript('OnClick', function(self, d)
        if IsControlKeyDown() and d=='RightButton' then
            Save.pointReagentBank= nil
            self:show_hide()
            self:set_tooltips()
            print(e.addName, addName, e.onlyChinese and '还原位置' or RESET_POSITION)
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





    --设置，显示材料银行
    function ReagentBankFrame.ShowHideButton:show_hide(hide)
        --local unlocked= IsReagentBankUnlocked()
        if (not Save.hideReagentBankFrame or hide) and BankFrame.activeTabIndex then
            if BankFrame.activeTabIndex==1 and not hide then
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





    ReagentBankFrame:SetSize(715, 415)--386, 415
    --添加，背景
    ReagentBankFrame.Bg= ReagentBankFrame:CreateTexture(nil, 'BACKGROUND')
    ReagentBankFrame.Bg:SetSize(715, 350)
    ReagentBankFrame.Bg:SetPoint('BOTTOMLEFT',10, 10)
    ReagentBankFrame.Bg:SetAtlas('auctionhouse-background-buy-noncommodities-market')
    ReagentBankFrame.Bg:SetAlpha(0.5)

    ReagentBankFrame.NineSlice:Hide()
    ReagentBankFrame.EdgeShadows:Hide()

    ReagentBankFrame.DespositButton:ClearAllPoints()
    ReagentBankFrame.DespositButton:SetPoint('BOTTOM',0 ,18)

    ReagentBankFrame.autoSortButton:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 25, 0)--整理材料银行
    ReagentBankFrame.DespositButton.texture2= ReagentBankFrame.DespositButton:CreateTexture(nil, 'OVERLAY')--增加，提示图标
    ReagentBankFrame.DespositButton.texture2:SetSize(23,23)
    ReagentBankFrame.DespositButton.texture2:SetPoint('RIGHT', -4, 0)
    ReagentBankFrame.DespositButton.texture2:SetAtlas('poi-traveldirections-arrow')
    ReagentBankFrame.DespositButton.texture2:SetTexCoord(0,1,1,0)

    --[[ReagentBankFrame.DespositButton:SetScript('OnClick', function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
        print(e.addName,addName)
		DepositReagentBank();
    end)]]
    ReagentBankFrame:HookScript('OnShow', function(self)
        --[[for i=1, 7 do
            local texture= self['BG'..i]
            if texture then
                texture:SetTexture(0)
                texture:Hide()
            end
        end]]
        for _, region in pairs({ReagentBankFrame:GetRegions()}) do--隐藏，材料包，背景
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
                region:Hide()
            end
        end
    end)
end
















--整合，一起
--#########
local SetAllBank
local function Init_All_Bank()
    SetAllBank= WoWTools_ButtonMixin:Cbtn(BankFrame.TitleContainer, {size={22,22}, icon=true})
    SetAllBank:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerBankFrame'] then
        SetAllBank:SetPoint('RIGHT', _G['MoveZoomInButtonPerBankFrame'], 'LEFT')
    else
        SetAllBank:SetPoint('LEFT', 12,0)
    end
    function SetAllBank:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS)..' |cnGREEN_FONT_COLOR:'..Save.num, e.Icon.mid)
        e.tips:AddDoubleLine((e.onlyChinese and '间隔' or 'Interval')..' |cnGREEN_FONT_COLOR:'..Save.line, 'Alt+'..e.Icon.mid)
        --e.tips:AddLine(' ')
        --e.tips:AddDoubleLine(e.onlyChinese and '索引' or 'Index', e.Icon.left)
        --e.tips:AddDoubleLine(Save.showBackground and (e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND) or (e.onlyChinese and '隐藏背景' or HIDE_PULLOUT_BG ), e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end
    --设置，背景
    
    function SetAllBank:set_background()
        if Save.showBackground~=nil then
            if Save.showBackground then
                BankFrame:DisableDrawLayer('BACKGROUND')
                
                BankFrame.Background:ClearAllPoints()
                BankFrame.Background:SetAllPoints()
                BankFrame.Background:SetAtlas('bank-frame-background')
            else
                BankFrame:EnableDrawLayer('BACKGROUND')
                BankFrame.Background:ClearAllPoints()
                BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
                BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)
                BankFrame.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
            end
        end
    end
    --[[SetAllBank:SetScript('OnClick', function(self, d)
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
    end)]]
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
                bagFrame:SetPoint('RIGHT', UIParent, 'LEFT', -40, 0)
                if not bagFrame.isHideFrame then
                    bagFrame.isHideFrame=true
                    bagFrame:HookScript('OnShow', function(f)
                        f:Hide()
                    end)
                end

               for _, btn in bagFrame:EnumerateValidItems()  do
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












    ReagentBankFrame.NineSlice:Hide()
    if BankFrameMoneyFrameBorder then
        BankFrameMoneyFrameBorder:Hide()
    end

    --隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位"
    for _, region in pairs({BankSlotsFrame:GetRegions()}) do
        if region:GetObjectType()=='FontString' then
            region:SetText('')
            region:Hide()
        end
    end


    hooksecurefunc('BankFrame_UpdateAnchoringForPanel', function()
        BankItemSearchBox:ClearAllPoints()--移动，搜索框
        BankItemSearchBox:SetPoint('TOP', 0,-33)
    end)



    ReagentBankFrame:HookScript('OnShow', function(self)
        if self.isSetPoint then--or not IsReagentBankUnlocked() then
            return
        end
        self.isSetPoint=true


        for _, region in pairs({ReagentBankFrame:GetRegions()}) do--隐藏，材料包，背景
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
                region:Hide()
            end
        end

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
end























--[[
local AllPlayerBankItem
local function Init_Save_BankItem()
    if not e.Player.husandro then
        return
    end
    AllPlayerBankItem= WoWTools_ButtonMixin:Cbtn(BankFrame.TitleContainer, {size={22,22}, atlas='Banker'})
    AllPlayerBankItem:SetPoint('LEFT', BankFrame.optionButton , 'RIGHT')
    AllPlayerBankItem:SetAlpha(0.5)
    function AllPlayerBankItem:get_item_text(itemID, quality)
        e.LoadData({id=itemID, type='item'})
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















local function Get_Bank_BagAndSlotID(btn)
    return btn.isBag and Enum.BagIndex.Bankbag or btn:GetParent():GetID(), btn:GetID()
end

local function Get_Bank_Button_ItemID(btn)--银行，ButtonID, 测试是否是空位
    if btn and btn:IsShown() then
        local info = C_Container.GetContainerItemInfo(Get_Bank_BagAndSlotID(btn)) or {}
        return info.itemID, info.stackCount
    end
end

local function Get_Bag_Free(all)--背包，空位
    local free= 0--CalculateTotalNumberOfFreeBagSlots() MainMenuBarBagButtons.lua
    for i = BACKPACK_CONTAINER, NUM_BAG_FRAMES+(all and NUM_REAGENTBAG_FRAMES or 0) do
        free= free+ (C_Container.GetContainerNumFreeSlots(i) or 0)
    end
    return free
end

local function Get_Bank_Free()--银行，空位
    local free= 0
    for i=1, NUM_BANKGENERIC_SLOTS do--28        
        if not Get_Bank_Button_ItemID(BankSlotsFrame["Item"..i]) then
            free= free+1
        end
    end
    for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot) or {}
            if not info.itemID then
                free= free+ 1
            end
        end
    end
    return free
end


--大包时，显示，存取，分类，按钮
local function Init_Desposit_TakeOut_Button()
    local btn= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide'})
    btn:SetPoint('TOPRIGHT', BankFrame, 'TOPLEFT', -2, -32)
    btn.frame=CreateFrame('Frame', nil, btn)
    btn.frame:SetPoint('BOTTOMRIGHT')
    btn.frame:SetSize(1,1)
    function btn:settings()
        self:SetNormalAtlas(Save.show_AllBank_Type and 'NPE_ArrowDown' or e.Icon.disabled)
        self:SetAlpha(Save.show_AllBank_Type and 1 or 0.3)
        self.frame:SetShown(Save.show_AllBank_Type)
        self.frame:SetScale(Save.show_AllBank_Type_Scale or 1)
    end
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(Save.show_AllBank_Type), e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..': |cnGREEN_FONT_COLOR:'..(Save.show_AllBank_Type_Scale or 1), e.Icon.mid)
        e.tips:Show()
    end
    btn:SetScript('OnClick', function(self)
        Save.show_AllBank_Type= not Save.show_AllBank_Type and true or nil
        self:settings()
        self:set_tooltips()
    end)
    btn:SetScript('OnMouseWheel', function(self, d)
        local n
        n= Save.show_AllBank_Type_Scale or 1
        n= d==1 and n-0.05 or n
        n= d==-1 and n+0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        if n==1 then n=nil end
        Save.show_AllBank_Type_Scale= n
        self:settings()
        self:set_tooltips()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:settings()

    btn.buttons={}
    function btn.frame:take_out_item(classID)--取出，ClassID 物品
        local free= Get_Bag_Free()--背包，空位
        if free==0 then
            return
        end
        for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        for i=NUM_BANKGENERIC_SLOTS, 1, -1 do--28
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                return
            end
            local bag, slot= Get_Bank_BagAndSlotID(BankSlotsFrame["Item"..i])
            if bag and slot then
                local info= C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
    end
    function btn.frame:desposit_item(classID)--存放，ClassID 物品
        local free= Get_Bank_Free()--银行，空位
        if free==0 then
            return
        end
        for bag= NUM_BAG_FRAMES,  BACKPACK_CONTAINER, -1 do-- + NUM_REAGENTBAG_FRAMES do--NUM_TOTAL_EQUIPPED_BAG_SLOTS
            for slot= C_Container.GetContainerNumSlots(bag), 1, -1 do
                if not self:IsVisible() or IsModifierKeyDown() or free==0 then
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))==classID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
    end
    local last= btn.frame
    for classID=0, 19 do
        if classID~=6 and classID~=10 and classID~=14 and classID~=11 and classID~=7 then
            local className=C_Item.GetItemClassInfo(classID)--生成,物品列表
            if className then
                local frame= WoWTools_ButtonMixin:Cbtn(btn.frame, {icon='hide'})
                frame.Text= e.Cstr(frame, {justifyH='RIGHT'})
                frame.Text:SetPoint('RIGHT', -2,0)
                frame.Text:SetText(e.cn(className)..' '..classID)
                frame.Label= e.Cstr(frame, {justifyH='RIGHT'})
                frame.Label:SetPoint('RIGHT', frame, 'LEFT', -4, 0)
                frame:SetSize(frame.Text:GetWidth()+4, 18)
                frame:SetPoint('TOPRIGHT', last, 'BOTTOMRIGHT')
                frame:SetScript('OnClick', function(self, d)
                    if d=='LeftButton' then--取出
                        self:GetParent():take_out_item(self.classID)
                    elseif d=='RightButton' then--存放
                        self:GetParent():desposit_item(self.classID)
                    end
                end)
                frame:SetScript('OnLeave', GameTooltip_Hide)
                frame:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    local text= self.Label:GetText() or ''

                    e.tips:AddDoubleLine(
                        e.Icon.left..(e.onlyChinese and '取出' or 'take out'),--..(text:match('(.-|A:Banker:0:0|a)') or ''),
                        (e.onlyChinese and '存放' or 'on bank')..e.Icon.right
                    )

                    e.tips:Show()
                end)
                frame.classID= classID
                last=frame
                table.insert(btn.buttons, frame)
            end
        end
    end
    function btn:set_event()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:set_label()
        else
            self:UnregisterAllEvents()
        end
    end


    function btn:set_label()
        if not self:IsShown() or self.isRun then return end
        self.isRun=true
        local bankClass={}
        for i=1, NUM_BANKGENERIC_SLOTS do--28
            local itemID, stackCount= Get_Bank_Button_ItemID(BankSlotsFrame["Item"..i])
            local classID = itemID and select(6, C_Item.GetItemInfoInstant(itemID))
            if classID then
                bankClass[classID]= (bankClass[classID] or 0)+ (stackCount or 1)
            end
        end
        for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                local classID = info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))
                if classID then
                    bankClass[classID]= (bankClass[classID] or 0)+ (info.stackCount or 1)
                end
            end
        end

        local bagClass={}
        for bag= BACKPACK_CONTAINER, NUM_BAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                local classID = info.itemID and select(6, C_Item.GetItemInfoInstant(info.itemID))
                if classID then
                    bagClass[classID]= (bagClass[classID] or 0)+ (info.stackCount or 1)
                end
            end
        end
        for _, frame in pairs(self.buttons) do
            local bank= bankClass[frame.classID] or 0
            local bag= bagClass[frame.classID] or 0
            if bank==0 and bag==0 then
                frame.Label:SetText('')
            else
                frame.Label:SetText(
                    (bank==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..e.MK(bank, 3)..'|A:Banker:0:0|a'
                    ..'|A:bag-main:0:0|a'..( bag==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..e.MK(bag, 3)
                )
            end
        end
        self.isRun=nil
    end
    btn:SetScript('OnShow', btn.set_event)
    btn:SetScript('OnHide', btn.set_event)
    btn:SetScript('OnEvent', btn.set_label)
end













--存放，取出，所有
local function Init_Desposit_TakeOut_All_Items()
    --取出，所有, 物品
    local btn= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide'})
    btn:SetNormalAtlas('poi-traveldirections-arrow')
    btn:GetNormalTexture():SetTexCoord(1,0,1,0)
    if Save.allBank then
        btn:SetPoint('RIGHT', BankItemAutoSortButton, 'LEFT', -2, 0)
    else
        btn:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
    end
    btn:SetScript('OnClick', function(self)
        local free= Get_Bag_Free()--背包，空位
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
            local bag, slot= Get_Bank_BagAndSlotID(BankSlotsFrame["Item"..i])
            if bag and slot then
                local info= C_Container.GetContainerItemInfo(bag, slot) or {}
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
        local free= Get_Bag_Free()--背包，空位
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有物品' or 'Take out all items',
            format('|A:bag-main:0:0|a%s #%s%d',
                e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btn:show_tooltips()
        C_Timer.After(1.5, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btn:HookScript('OnLeave', GameTooltip_Hide)
    btn:HookScript('OnEnter', btn.set_tooltips)
    ReagentBankFrame.TakeOutAllItemButton= btn

    --存放，所有，物品
    local btnOut= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame.TakeOutAllItemButton, {size=23, icon='hide'})
    btnOut:SetNormalAtlas('poi-traveldirections-arrow')
    btnOut:GetNormalTexture():SetTexCoord(0,1,1,0)
    btnOut:SetPoint('RIGHT', ReagentBankFrame.TakeOutAllItemButton, 'LEFT', -2, 0)
    btnOut:SetScript('OnClick', function(self)
        local free= Get_Bank_Free()--银行，空位
        if free==0 then
            return
        end
        for bag= NUM_BAG_FRAMES,  BACKPACK_CONTAINER, -1 do
            for slot= C_Container.GetContainerNumSlots(bag), 1, -1 do
                if not self:IsVisible() or IsModifierKeyDown() or free==0 then
                    self:show_tooltips()
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.hyperlink and not select(17, C_Item.GetItemInfo(info.hyperlink)) then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
    end)
    function btnOut:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free=Get_Bank_Free()--银行，空位
        e.tips:AddDoubleLine(e.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GUILDCONTROL_DEPOSIT_ITEMS, ' ('..ALL..')'),
            format('|A:Banker:0:0|a%s #%s%d',
                e.onlyChinese and '银行' or BANK,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btnOut:show_tooltips()
        C_Timer.After(1.5, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnOut:HookScript('OnLeave', GameTooltip_Hide)
    btnOut:HookScript('OnEnter', btnOut.set_tooltips)
    ReagentBankFrame.DespositAllItemButton= btnOut


    --取出，所有，材料
    local btnR= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame.DespositButton, {size=23, icon='hide'})
    btnR:SetNormalAtlas('poi-traveldirections-arrow')
    btnR:GetNormalTexture():SetTexCoord(1,0,1,0)
    btnR:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 2, 0)
    function btnR:get_bag_slot(frame)
        return frame.isBag and Enum.BagIndex.Bankbag or frame:GetParent():GetID(), frame:GetID()
    end
    --[[function btnR:get_free()
        return C_Container.GetContainerNumFreeSlots(NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES) or 0
    end]]
    btnR:SetScript('OnClick', function(self)
        local free= Get_Bag_Free(true)--self:get_free()
        if free==0 or not IsReagentBankUnlocked() then
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
            local bag, slot= Get_Bank_BagAndSlotID(frame)
            if bag and slot then
                local info= C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        self:show_tooltips()
    end)
    function btnR:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= Get_Bag_Free(true)--self:get_free()
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有材料' or 'Take out all reagents',
            format('|A:4549254:0:0|a%s #%s%d',
                e.onlyChinese and '材料' or AUCTION_CATEGORY_TRADE_GOODS,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btnR:show_tooltips()
        C_Timer.After(1, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnR:HookScript('OnLeave', GameTooltip_Hide)
    btnR:HookScript('OnEnter', btnR.set_tooltips)
    ReagentBankFrame.TakeOutAllReagentsButton= btnR


    --[[ReagentBankFrame.DespositButton:SetScript('OnEnter', function(self)
        local free=0
        if IsReagentBankUnlocked() then
            for i=1, 98 do
                local slot= _G['ReagentBankFrameItem'..i]
                if slot and not Get_Bank_Button_ItemID(slot) then
                    free= free+1
                end
            end
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()        
        e.tips:AddDoubleLine(e.onlyChinese and '存放各种材料' or REAGENTBANK_DEPOSIT, '#|cnGREEN_FONT_COLOR:'..free)
        e.tips:Show()
    end)]]
end



















--#######
--设置菜单
--#######
local function Init_Menu(_, root)
    local btn= root:CreateCheckbox(e.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED, function()
        return Save.allBank
    end, function()
        Save.allBank= not Save.allBank and true or nil
        BankFrame.optionButton:set_atlas()
        print(e.addName, addName, e.GetEnabeleDisable(Save.allBank),  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    btn:SetTooltip(function(tooltip, elementDescription)
        GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
    end)

    if Save.allBank then
        root:CreateDivider()
        root:CreateCheckbox(e.onlyChinese and '索引' or 'Index', function()
            return Save.showIndex
        end, function()
            Save.showIndex= not Save.showIndex and true or nil--显示，索引
            SetAllBank:set_bank()--设置，银行，按钮
            SetAllBank:set_reagent()--设置，材料，按钮
            SetAllBank:set_size()--设置，外框，大小
        end)

        root:CreateCheckbox(e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND, function()
            return Save.showBackground or Save.showBackground==nil
        end, function()
            Save.showBackground= not Save.showBackground and true or false
            SetAllBank:set_background()--设置，背景
        end)
    end

    root:CreateDivider()
    root:CreateButton(e.onlyChinese and '选项' or OPTIONS, function()
        e.OpenPanelOpting(nil, addName)
    end)

    root:CreateButton(e.onlyChinese and '重新加载UI' or RELOADUI, e.Reload)
end












--银行
--BankFrame.lua
local function Init_Bank_Frame()
    BankFrame.optionButton= WoWTools_ButtonMixin:Cbtn(BankFrame.TitleContainer, {size={22,22}, atlas='hide'})
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
        MenuUtil.CreateContextMenu(self, Init_Menu)
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

    e.Set_NineSlice_Color_Alpha(BankFrame, true)
    e.Set_NineSlice_Color_Alpha(AccountBankPanel, true)
    e.Set_NineSlice_Color_Alpha(BankSlotsFrame, nil, true)
    e.Set_Alpha_Frame_Texture(BankFrameTab1, {notAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab2, {notAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab3, {notAlpha=true})
    BankFrameBg:SetTexture(0)

    e.Set_Alpha_Frame_Texture(ReagentBankFrame.EdgeShadows, {})

    --整理材料银行
    ReagentBankFrame.autoSortButton= CreateFrame("Button", nil, ReagentBankFrame, 'BankAutoSortButtonTemplate')
    ReagentBankFrame.autoSortButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(e.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        e.tips:Show()
    end)
    ReagentBankFrame.autoSortButton:SetScript('OnClick', function()
        C_Container.SortReagentBankBags()
    end)





    ReagentBankFrame.EdgeShadows:Hide()
    BankSlotsFrame.EdgeShadows:Hide()
    AccountBankPanel.Header.Text:ClearAllPoints()
    AccountBankPanel.Header.Text:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -12, 0)
    e.Set_Alpha_Frame_Texture(BankFrameTab1, {isMinAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab2, {isMinAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab3, {isMinAlpha=true})

    

     --银行
     --[[e.Set_NineSlice_Color_Alpha(BankFrame,true)

     
     hide_Texture(BankFrameMoneyFrameBorderMiddle)
     hide_Texture(BankFrameMoneyFrameBorderRight)
     hide_Texture(BankFrameMoneyFrameBorderLeft)

     set_SearchBox(BankItemSearchBox)

     BankFrame:DisableDrawLayer('BACKGROUND')
     local texture= BankFrame:CreateTexture(nil,'BORDER',nil, 1)
     texture:SetAtlas('auctionhouse-background-buy-noncommodities-market')
     texture:SetAllPoints(BankFrame)
     set_Alpha_Color(texture)
     hide_Texture(BankFrameBg)

     hooksecurefunc('BankFrameItemButton_Update',function(button)--银行
         if button.NormalTexture and button.NormalTexture:IsShown() then
             hide_Texture(button.NormalTexture)
         end
         if ReagentBankFrame.numColumn and not ReagentBankFrame.hidexBG then
             ReagentBankFrame.hidexBG=true
             for column = 1, 7 do
                 hide_Texture(ReagentBankFrame["BG"..column])
             end
         end
     end)
     e.Set_Alpha_Frame_Texture(BankFrameTab1, {isMinAlpha=true})
     e.Set_Alpha_Frame_Texture(BankFrameTab2, {isMinAlpha=true})
     e.Set_Alpha_Frame_Texture(BankFrameTab2, {isMinAlpha=true})]]

    do
        if Save.allBank then
            Init_All_Bank()--整合，一起
        else
            Init_Bank_Plus()--增强，原生
        end
    end
    --Init_Save_BankItem()

    Init_Desposit_TakeOut_All_Items()--存放，取出，所有

    if Save.allBank then
        C_Timer.After(4, Init_Desposit_TakeOut_Button)--分类，存取, 2秒为翻译加载时间
     end
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
            addName= '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or BANK)
            if WoWToolsSave[BANK] or WoWToolsSave['Bank_Lua'] then
                Save= WoWToolsSave[BANK] or WoWToolsSave['Bank_Lua']
                WoWToolsSave[BANK]=nil
                WoWToolsSave['Bank_Lua']=nil
            else
                Save= WoWToolsSave['Plus_Bank'] or Save
            end
            


            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                GetValue=function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if not Save.disabled then
                Init_Bank_Frame()--银行
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Bank']= Save
        end
    end
end)
