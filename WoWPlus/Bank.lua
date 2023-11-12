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

    showIndex=true,--显示，索引
    --showBackground= true,--设置，背景
}
















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

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end
    ReagentBankFrame.ShowHideButton:SetScript('OnClick', function(self, d)
        if IsControlKeyDown() and d=='RightButton' then
            Save.pointReagentBank= nil
            self:show_hide()
            self:set_tooltips()
            print(id, addName, e.onlyChinese and '还原位置' or RESET_POSITION)
        else
            Save.hideReagentBankFrame= not Save.hideReagentBankFrame and true or nil
            self:show_hide(Save.hideReagentBankFrame)
            self:set_atlas()
            self:set_tooltips()
        end
    end)

    ReagentBankFrame.ShowHideButton:SetScript('OnLeave', function() e.tips:Hide() end)
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
    ReagentBankFrame.Bg:SetAlpha(0.5)
    ReagentBankFrame.Bg:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
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
local function Init_All_Bank()
    BankFrame.setAllBank= e.Cbtn(BankFrame.TitleContainer, {size={22,22}, icon=true})
    BankFrame.setAllBank:SetAlpha(0.5)
    if _G['MoveZoomInButtonPerBankFrame'] then
        BankFrame.setAllBank:SetPoint('RIGHT', _G['MoveZoomInButtonPerBankFrame'], 'LEFT')
    else
        BankFrame.setAllBank:SetPoint('LEFT', 12,0)
    end
    function BankFrame.setAllBank:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
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
    function BankFrame.setAllBank:set_background()
        if Save.showBackground~=nil then
            if Save.showBackground then
                BankFrame:DisableDrawLayer('BACKGROUND')
            else
                BankFrame:EnableDrawLayer('BACKGROUND')
            end
        end
    end
    BankFrame.setAllBank:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Save.showIndex= not Save.showIndex and true or nil--显示，索引
            BankFrame.setAllBank:set_bank()--设置，银行，按钮
            BankFrame.setAllBank:set_reagent()--设置，材料，按钮
            BankFrame.setAllBank:set_size()--设置，外框，大小

        elseif d=='RightButton' then
            Save.showBackground= not Save.showBackground and true or false
            self:set_background()--设置，背景
        end
        self:set_tooltips()
    end)
    BankFrame.setAllBank:SetScript('OnMouseWheel', function(self, d)
        if not IsModifierKeyDown() then
            local n= Save.num
            if d==1 then
                n= n-1
            elseif d==-1 then
                n=n +1
            end
            n= n<4 and 4 or n
            n= n>14 and 14 or n
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

    BankFrame.setAllBank:SetScript('OnLeave', function(self) self:SetAlpha(0.5) e.tips:Hide() end)
    BankFrame.setAllBank:SetScript('OnEnter', BankFrame.setAllBank.set_tooltips)

    --索引，提示
    function BankFrame.setAllBank:set_index_label(btn, index)
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
    function BankFrame.setAllBank:set_bank()
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
    function BankFrame.setAllBank:set_reagent()
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


    function BankFrame.setAllBank:set_size()--设置，外框，大小
        if BankFrame.activeTabIndex==1 then
            local num= BankFrame.setAllBank.num + BankFrame.setAllBank.reagentNum
            BankFrame:SetSize(8+num*37+((num-1)*Save.line)+8+8+2, (Save.num+1)*37 +((Save.num-1)*Save.line)+64+8+6)
        elseif BankFrame.activeTabIndex==2 then
            local num= BankFrame.setAllBank.reagentNum
            BankFrame:SetSize(8+(num*38)+((num-1)*Save.line), 64+(Save.num*37)+(Save.num*Save.line)+8)--设置，大小
        end
    end



    --隐藏，ITEMSLOTTEXT"物品栏位" BAGSLOTTEXT"背包栏位";
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
        BankItemAutoSortButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -2, 0)
        BankItemAutoSortButton:SetParent(BankSlotsFrame)

        ReagentBankFrame.autoSortButton:SetPoint('LEFT', BankItemSearchBox, 'RIGHT', 2, 0)--整理材料银行

        ReagentBankFrame.DespositButton:ClearAllPoints()
        ReagentBankFrame.DespositButton:SetSize(32, 32)
        ReagentBankFrame.DespositButton:SetText('')
        ReagentBankFrame.DespositButton:SetNormalAtlas('128-RedButton-Refresh')
        ReagentBankFrame.DespositButton:SetPushedAtlas('128-RedButton-Refresh-Pressed')
        ReagentBankFrame.DespositButton:SetPoint('TOPRIGHT', -8, -26)
        ReagentBankFrame.DespositButton:HookScript('OnLeave', function() e.tips:Hide() end)
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
            BankFrame.setAllBank:set_bank()--设置，银行，按钮
            BankFrame.setAllBank:set_reagent()--设置，材料，按钮

        elseif BankFrame.activeTabIndex==2 then
            local btn= ReagentBankFrame["Item1"]
            if btn then
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', 8,-60)
            end
        end
        BankFrame.setAllBank:set_size()--设置，外框，大小
        if not IsReagentBankUnlocked() and ReagentBankFrame.UnlockInfo then
            ReagentBankFrame.UnlockInfo:SetShown(BankFrame.activeTabIndex==2)
        end

    end)

    hooksecurefunc('BankFrameItemButtonBag_OnClick', function()
        BankFrame.setAllBank:set_bank()--设置，银行，按钮
        BankFrame.setAllBank:set_reagent()--设置，材料，按钮
        BankFrame.setAllBank:set_size()--设置，外框，大小
    end)

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
    BankFrame.setAllBank:set_bank()--设置，银行，按钮

    
    BankFrame.setAllBank:set_background()--设置，背景
end


























--银行
--BankFrame.lua
local function Init_Bank_Frame()
    if not ReagentBankFrame then
        return
    end

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
        e.tips:AddLine(e.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    ReagentBankFrame.autoSortButton:SetScript('OnClick', function()
        C_Container.SortReagentBankBags()
    end)


    if Save.allBank then
        Init_All_Bank()--整合，一起
    else
        Init_Bank_Plus()--增强，原生
    end

  
end

















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            local initializer2= e.AddPanel_Check({
                name= e.Icon.bank2..(e.onlyChinese and '银行' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })
            local initializer= e.AddPanel_Check({
                name= (e.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED ),
                value= Save.allBank,
                func= function()
                    Save.allBank = not Save.allBank and true or nil
                    print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })
            initializer:SetParentInitializer(initializer2, function() return not Save.disabled end)

            if not Save.disabled then
                Init_Bank_Frame()--银行
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end



    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]= Save
        end
    end
end)
