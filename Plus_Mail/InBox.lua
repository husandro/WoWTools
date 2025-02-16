if GameLimitedMode_IsActive() then
    return
end


local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end










local function get_Money(num)
    local text
    if num and num>0 then
        if num>=1e4 then
            text= WoWTools_Mixin:MK(num/1e4, 2)..'|TInterface/moneyframe/ui-goldicon:0|t'
        else
            text= GetMoneyString(num)
        end
    end
    return text or ''
end
--查找，信件里的第一个物品，超链接
local function find_itemLink(itemCount, openMailID, itemLink)
    itemLink= (itemCount and itemCount>0) and itemLink
    if itemCount and itemCount>0 and not itemLink then
        for i= 1, itemCount do
            itemLink= GetInboxItemLink(openMailID, i)
            if itemLink then
                break
            end
        end
    end
    return itemLink
end

--删除，或退信
local function return_delete_InBox(openMailID)--删除，或退信
    local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity, firstItemLink = GetInboxHeaderInfo(openMailID)

    local itemName= find_itemLink(itemCount, openMailID, firstItemLink)
    local icon=packageIcon or stationeryIcon

    local text= GetInboxText(openMailID) or ''
    text= text:gsub(' ','') and nil or text

    local delOrRe
    local canDelete= InboxItemCanDelete(openMailID)
    if InboxItemCanDelete(openMailID) then
        delOrRe= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r'
    else
        delOrRe= '|cFFFF00FF'..(e.onlyChinese and '退信' or MAIL_RETURN)..'|r'
    end

    if canDelete and (not money or money==0) and (not CODAmount or CODAmount==0) and (not itemCount or itemCount) then
        DeleteInboxItem(openMailID)
    else
        InboxFrame.openMailID= openMailID
        OpenMailFrame.itemName= (itemCount and itemCount>0) and itemName or nil
        OpenMailFrame.money= money
        e.call(OpenMail_Delete)--删除，或退信 MailFrame.lua
    end

    print('|cFFFF00FF'..openMailID..')|r',
        ((icon and not itemName) and '|T'..icon..':0|t' or '')..delOrRe,
        WoWTools_UnitMixin:GetLink(sender, nil, true),
        subject,
        itemName or '',
        (money and money>0) and GetMoneyString(money, true) or '',
        (CODAmount and CODAmount>0) and GetMoneyString(CODAmount, true) or '',
        text and '|n' or '',
        text or '')
end


--隐藏，所有，选中提示
local function set_btn_enterTipTexture_Hide_All()
    for i=1, INBOXITEMS_TO_DISPLAY do
        local btn=_G["MailItem"..i.."Button"]
        if btn and btn.enterTipTexture then
            btn.enterTipTexture:SetShown(false)
        end
    end
end











local function set_Tooltips_DeleteAll(self, del)--所有，删除，退信，提示
    set_btn_enterTipTexture_Hide_All()--隐藏，所有，选中提示

    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
    local num=0
    local findReTips--显示第一个，退回信里，的物品
    for i=1, select(2, GetInboxNumItems()) do
        local canDelete=InboxItemCanDelete(i)
        local packageIcon, stationeryIcon, sender, subject, money, CODAmount, _, itemCount, wasRead, _, _, _, _, _, firstItemLink = GetInboxHeaderInfo(i)
        local moneyPaga= (CODAmount and CODAmount>0) and CODAmount or nil
        local moneyGet= (money and money>0) and money or nil
        local itemLink= find_itemLink(itemCount, i, firstItemLink)--查找，信件里的第一个物品，超链接
        if (canDelete and del and not moneyPaga and not moneyGet and not itemLink) or (not del and not canDelete) then
            e.tips:AddDoubleLine((i<10 and ' ' or '')
                                    ..i..') |T'..(packageIcon or stationeryIcon)..':0|t'
                                    ..WoWTools_MailMixin:GetNameInfo(sender)
                                    ..(not wasRead and ' |cnRED_FONT_COLOR:'..(e.onlyChinese and '未读' or COMMUNITIES_FRAME_JUMP_TO_UNREAD) or '')
                                , subject)

            if not canDelete and (itemCount and itemCount>0) and not findReTips then--物品，提示
                local allCount=0
                for itemIndex= 1, itemCount do
                    local itemIndexLink= GetInboxItemLink(i, itemIndex)
                    if itemIndexLink then
                        local texture, count = select(3, GetInboxItem(i, itemIndex))
                        allCount= allCount+ (count or 1)
                        e.tips:AddDoubleLine(' ','|cnGREEN_FONT_COLOR:'..(count or 1)..'x|r '..(texture and '|T'..texture..':0|t' or '')..itemIndexLink..' ('..itemIndex)
                    end
                end
                if allCount>1 then
                    e.tips:AddDoubleLine(' ', '#'..WoWTools_Mixin:MK(allCount, 3))
                end
                e.tips:AddLine(' ')
            end

            if not findReTips and not Save().hide then--显示，所有，选中提示
                for i2=1, INBOXITEMS_TO_DISPLAY do
                    local btn=_G["MailItem"..i2.."Button"]
                    if btn and btn.enterTipTexture and btn.index==i then
                        btn.enterTipTexture:SetShown(true)
                        break
                    end
                end
            end

            findReTips=true
            num=num+1
        end
    end
    e.tips:AddDoubleLine(' ',
                        del and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r |cnGREEN_FONT_COLOR:#'..num
                        or ('|cFFFF00FF'..(e.onlyChinese and '退信' or MAIL_RETURN)..'|r |cnGREEN_FONT_COLOR:#'..num)
                    )
    e.tips:Show()
end



local function eventEnter(self, get)--enter 提示，删除，或退信，按钮
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
    e.tips:AddLine(' ')
    local packageIcon, stationeryIcon, _, _, _, _, _, itemCount = GetInboxHeaderInfo(self.openMailID)
    local allCount=0
    if itemCount then
        for itemIndex= 1, itemCount do
            local itemIndexLink= GetInboxItemLink(self.openMailID, itemIndex)
            if itemIndexLink then
                local texture, count = select(3, GetInboxItem(self.openMailID, itemIndex))
                texture = texture or C_Item.GetItemIconByID(itemIndexLink)
                allCount= allCount+ (count or 1)
                e.tips:AddLine((itemIndex<10 and ' ' or '')..itemIndex..') '..(texture and '|T'..texture..':0|t' or '')..itemIndexLink..'|cnGREEN_FONT_COLOR: x'..(count or 1)..'|r')
            end
        end
        e.tips:AddLine(' ')
    end
    local text= GetInboxText(self.openMailID)
    if text and text:gsub(' ', '')~='' then
        e.tips:AddLine(text, nil,nil,nil, true)
        e.tips:AddLine(' ')
    end

    local text2
    if get then
        text2= e.onlyChinese and '提取' or WITHDRAW
    elseif self.canDelete then
        text2= e.onlyChinese and '删除' or DELETE
    else
        text2= e.onlyChinese and '退信' or MAIL_RETURN
    end
    local icon= packageIcon or stationeryIcon
    e.tips:AddLine('|cffff00ff'..self.openMailID..' |r'..(icon and '|T'..icon..':0|t')..text2..(allCount>1 and ' |cnGREEN_FONT_COLOR:'..WoWTools_Mixin:MK(allCount,3)..'|r'..(e.onlyChinese and '物品' or ITEMS) or ''))
    e.tips:Show()
end














--删除所有信，按钮
local function Create_DeleteAllButton()
    InboxFrame.DeleteAllButton= WoWTools_ButtonMixin:Cbtn(InboxFrame, {size={25,25}, atlas='xmarksthespot'})
    if _G['PostalSelectReturnButton'] then
        InboxFrame.DeleteAllButton:SetPoint('LEFT', _G['PostalSelectReturnButton'], 'RIGHT')
    else
        InboxFrame.DeleteAllButton:SetPoint('BOTTOMRIGHT', _G['MailItem1'], 'TOPRIGHT', 15, 15)
    end

    InboxFrame.DeleteAllButton:SetScript('OnEnter', function(self)--提示，要删除信，内容
        set_Tooltips_DeleteAll(self, true)
    end)
    InboxFrame.DeleteAllButton:SetScript('OnLeave', function(self)
        set_btn_enterTipTexture_Hide_All()--隐藏，所有，选中提示
        e.tips:Hide()
    end)

    --删除信
    InboxFrame.DeleteAllButton:SetScript('OnClick', function(self)

        for i=1, select(2, GetInboxNumItems())do
            if InboxItemCanDelete(i) then
                local money, CODAmount, _, itemCount= select(5, GetInboxHeaderInfo(i))
                if (not money or money==0) and (not CODAmount or CODAmount==0) and (not itemCount or itemCount==0) then
                    return_delete_InBox(i)--删除，或退信
                    --DeleteInboxItem(i);
                    break
                end
            end
        end
        C_Timer.After(0.5, function()
            set_Tooltips_DeleteAll(self, true)
        end)
    end)

    InboxFrame.DeleteAllButton.Text= WoWTools_LabelMixin:Create(InboxFrame.DeleteAllButton)
    InboxFrame.DeleteAllButton.Text:SetPoint('BOTTOMRIGHT')
end













--退回，所有信，按钮
local function Create_ReAllButton()
    InboxFrame.ReAllButton= WoWTools_ButtonMixin:Cbtn(InboxFrame, {size={25,25}, atlas='common-icon-undo'})
    if _G['PostalSelectReturnButton'] then
        InboxFrame.ReAllButton:SetPoint('RIGHT', _G['PostalSelectOpenButton'], 'LEFT')
    else
        InboxFrame.ReAllButton:SetPoint('RIGHT', InboxFrame.DeleteAllButton,'LEFT')
    end

    InboxFrame.ReAllButton:SetScript('OnEnter', function(self)--提示，要删除信，内容
        set_Tooltips_DeleteAll(self, false)
    end)
    InboxFrame.ReAllButton:SetScript('OnLeave', function(self)
        set_btn_enterTipTexture_Hide_All()--隐藏，所有，选中提示
        e.tips:Hide()
    end)

    --删除信
    InboxFrame.ReAllButton:SetScript('OnClick', function(self)
        for i=1, select(2, GetInboxNumItems()) do
            if not InboxItemCanDelete(i) then
                return_delete_InBox(i)--删除，或退信
                break
            end
        end
        C_Timer.After(0.5, function()
            set_Tooltips_DeleteAll(self, false)
        end)
    end)

    InboxFrame.ReAllButton.Text= WoWTools_LabelMixin:Create(InboxFrame.ReAllButton)
    InboxFrame.ReAllButton.Text:SetPoint('BOTTOMRIGHT')
end










--总，内容，提示
local function Create_AllTipsLable()
    InboxFrame.AllTipsLable= WoWTools_LabelMixin:Create(InboxFrame)
    InboxFrame.AllTipsLable:SetPoint('TOP', 20, -48)

    MailFrameTrialError:ClearAllPoints()--你需要升级你的账号才能开启这项功能。
    MailFrameTrialError:SetPoint('BOTTOM', InboxFrame.AllTipsLable, 'TOP', 0, 2)
    MailFrameTrialError:SetPoint('LEFT', InboxFrame, 55, 0)
    MailFrameTrialError:SetPoint('RIGHT', InboxFrame)
    MailFrameTrialError:SetWordWrap(false)

    InboxTooMuchMail:SetPoint('BOTTOM', InboxFrame.AllTipsLable, 'TOP', 0, 2)
end









--删除，或退信，按钮
local function Create_Unit_Button(btn, i)
    if btn.DeleteButton then
        return
    end

    --发信人，提示, 点击回复
    local lable=_G["MailItem"..i.."Sender"]
    btn.senderLable= lable

    lable:SetScript('OnMouseDown', function(self)
        if (self.playerName or self.sender) and self.canReply  then
            OpenMailSender.Name:SetText(self.playerName or self.sender)
            OpenMailSubject:SetText(self.subject)
            InboxFrame.openMailID= self.openMailID
            e.call(OpenMail_Reply)--回复
        end
        self:SetAlpha(1)
    end)
    lable:SetScript('OnEnter', function(self)
        if (self.playerName or self.sender) and self.canReply  then
            e.tips:SetOwner(self:GetParent(), "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
            e.tips:AddDoubleLine(e.onlyChinese and '回复' or REPLY_MESSAGE, self.playerName or self.sender)
            e.tips:Show()
        end
        self:SetAlpha(0.3)
    end)
    lable:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:SetAlpha(1)
    end)

--信件，索引，提示
    btn.indexText= WoWTools_LabelMixin:Create(btn, {alpha= 0.5})
    btn.indexText:SetPoint('RIGHT', btn, 'LEFT',-2,0)

--提示，需要付钱, 可收取钱
    btn.CODAmountTips= btn:CreateTexture(nil, 'OVERLAY')--图片
    btn.CODAmountTips:SetSize(150, 20)
    btn.CODAmountTips:SetPoint('BOTTOM', _G['MailItem'..i], 0,-4)
    btn.CODAmountTips:SetAtlas('jailerstower-wayfinder-rewardbackground-selected')
    btn.CODAmountTips:EnableMouse(true)
    btn.moneyPagaTip= WoWTools_LabelMixin:Create(btn)--文本
    btn.moneyPagaTip:SetPoint('CENTER', btn.CODAmountTips)
    btn.moneyPagaTip:EnableMouse(true)

    btn.DeleteButton= WoWTools_ButtonMixin:Cbtn(btn, {size=18})
    function btn.DeleteButton:set_point()
        self:ClearAllPoints()
        if _G['MailItem'..i..'ExpireTime'] and _G['MailItem'..i..'ExpireTime'].returnicon then
            self:SetPoint('RIGHT', _G['MailItem'..i..'ExpireTime'].returnicon, 'LEFT')
        else
            self:SetPoint('BOTTOMRIGHT', _G['MailItem'..i])
        end
    end

    btn.DeleteButton:SetScript('OnClick', function(self)--OpenMail_Delete()
        return_delete_InBox(self.openMailID)--删除，或退信
        C_Timer.After(0.3, function()
            if GameTooltip:IsOwned(self) then
                eventEnter(self)
                self:GetParent().enterTipTexture:SetShown(true)
            end
        end)
    end)
    btn.DeleteButton:SetScript('OnEnter', function(self)
        eventEnter(self)
        self:GetParent().enterTipTexture:SetShown(true)
    end)
    btn.DeleteButton:SetScript('OnLeave', function(self)
        self:GetParent().enterTipTexture:SetShown(false)
        e.tips:Hide()
    end)

    --移过时，提示，选中，信件
    btn.DeleteButton.numItemLabel= WoWTools_LabelMixin:Create(btn.DeleteButton)
    btn.DeleteButton.numItemLabel:SetPoint('BOTTOMRIGHT')
    btn.enterTipTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
    btn.enterTipTexture:SetAtlas('jailerstower-wayfinder-rewardbackground-selected')
    btn.enterTipTexture:SetAllPoints(_G['MailItem'..i])
    btn.enterTipTexture:SetVertexColor(0,1,0)
    btn.enterTipTexture:Hide()

    --提取，物品，和钱
    btn.outItemOrMoney= WoWTools_ButtonMixin:Cbtn(btn, {size={22, 20}, atlas='talents-search-notonactionbarhidden'})
    btn.outItemOrMoney:SetPoint('RIGHT', btn.DeleteButton, 'LEFT', -22, 0)
    btn.outItemOrMoney:SetScript('OnClick', function(self)
        e.call(InboxFrame_OnModifiedClick, self:GetParent(), self.openMailID)
    end)
    btn.outItemOrMoney:SetScript('OnLeave' ,function(self)
        self:GetParent().enterTipTexture:SetShown(false)
        e.tips:Hide()
    end)
    btn.outItemOrMoney:SetScript('OnEnter', function(self)
        eventEnter(self, true)
        self:GetParent().enterTipTexture:SetShown(true)
    end)


    function btn:clear_all_date()
        self.senderLable.canReply= nil
        self.senderLable.sender= nil
        self.senderLable.subject= nil
        self.senderLable.openMailID= nil
        self.senderLable.playerName= nil
        self.senderLable:EnableMouse(false)
        
        self.indexText:SetText('')
        self.CODAmountTips:SetShown(false)
        self.moneyPagaTip:SetText('')
        self.DeleteButton:SetShown(false)
        self.outItemOrMoney:SetShown(false)
        self.DeleteButton:SetShown(false)
        self.outItemOrMoney:SetShown(false)
        e.Set_Item_Info(btn, {})
    end
    btn:HookScript('OnHide', btn.clear_all_date)
end















local function Init_InboxFrame_Update()
    local hide= Save().hide

    for i=1, INBOXITEMS_TO_DISPLAY do
        local btn=_G["MailItem"..i.."Button"]
        if hide or not btn then
            if btn and btn.clear_all_date then
                btn:clear_all_date()
            end
        else

            Create_Unit_Button(btn, i)

            local _, _, sender, subject, money2, CODAmount2, _, itemCount2, _, _, _, canReply, isGM, _, firstItemLink = GetInboxHeaderInfo(btn.index)
            local invoiceType, _, playerName, bid, _, deposit, consignment = GetInboxInvoiceInfo(btn.index)
            local CODAmount= (CODAmount2 and CODAmount2>0) and CODAmount2 or nil
            local money= (money2 and money2>0) and money2 or nil
            local itemCount= (itemCount2 and itemCount2>0) and itemCount2 or nil
            --local isPlayer= sender and canReply and sender ~= UnitName("player") and not isGM

            --发信人，提示, 点击回复

            btn.senderLable.canReply= canReply
            btn.senderLable.sender= sender
            btn.senderLable.subject= subject
            btn.senderLable.openMailID= btn.index
            btn.senderLable.playerName= (invoiceType=='buyer' or invoiceType=='seller') and playerName or nil
            --frame.isGM= isGM
            if sender and not isGM and btn.index then
                btn.senderLable:EnableMouse(true)
                btn.senderLable:SetText(playerName and sender..'  '..WoWTools_MailMixin:GetNameInfo(playerName) or WoWTools_MailMixin:GetNameInfo(sender))--发信人，提示 
            else
                btn.senderLable:EnableMouse(false)
            end

            --信件，索引，提示
            btn.indexText:SetText(btn.index and '')

            --提示，需要付钱, 可收取钱
            if CODAmount then
                btn.CODAmountTips:SetVertexColor(1,0,0)
                btn.moneyPagaTip:SetTextColor(1,0,0)
            else
                btn.CODAmountTips:SetVertexColor(0,1,0)
                btn.moneyPagaTip:SetTextColor(0,1,0)
            end
            btn.CODAmountTips:SetShown(money or CODAmount)

            local text
            if (money or CODAmount) then
                if CODAmount then
                    text= (e.onlyChinese and '付款' or COD)
                elseif money or invoiceType=='seller' then
                    text= (e.onlyChinese and '可取' or WITHDRAW)
                    text= invoiceType=='seller' and '|A:Levelup-Icon-Bag:0:0|a'..text or text
                end
                if text then
                    if bid and deposit and consignment then
                        text= text..' '..get_Money(bid + deposit - consignment)
                    else
                        text= text..' '..get_Money(money)
                    end
                end
            end
            btn.moneyPagaTip:SetText(text or '')

            --删除，或退信，按钮，设置参数
            btn.DeleteButton:SetNormalTexture(InboxItemCanDelete(btn.index) and 'xmarksthespot' or 'common-icon-undo')
            btn.DeleteButton.openMailID= btn.index
            if invoiceType or (sender and strlower(sender) == strlower(BUTTON_LAG_AUCTIONHOUSE)) then
                btn.DeleteButton:SetShown(show)
                btn.DeleteButton.numItemLabel:SetText(show and (itemCount and itemCount>1) and itemCount or '')
                btn.outItemOrMoney.openMailID= btn.index
                btn.outItemOrMoney:SetShown((money or itemCount) and not CODAmount)
                btn.DeleteButton:SetShown(show)
                btn.DeleteButton.numItemLabel:SetText(show and (itemCount and itemCount>1) and itemCount or '')

                btn.outItemOrMoney.openMailID= btn.index
                btn.outItemOrMoney:SetShown((money or itemCount) and not CODAmount)
            else
                btn.DeleteButton:SetShown(false)
                btn.outItemOrMoney:SetShown(false)
                btn.DeleteButton:SetShown(false)
                btn.outItemOrMoney:SetShown(false)
            end

            e.Set_Item_Info(btn, {itemLink=firstItemLink})
        end
    end





    --####################
    --所有，删除，退信，按钮
    --####################
    local totalItems= select(2, GetInboxNumItems())  --信件，总数量

    local allMoney= 0--总，可收取钱
    local allCODAmount= 0--总，要付款钱
    local allItemCount= 0--总，物品数
    local allSender= 0--总，发信人数
    local allSenderTab= {}--总，发信人数,表

    local numCanDelete= 0--可以删除，数量
    local numCanRe=0--可以退回，数量

    if not hide then
        for i= 1, totalItems do
            local _, _, sender, _, money, CODAmount, _, itemCount, _, _, _, _, isGM= GetInboxHeaderInfo(i)
            local invoiceType= GetInboxInvoiceInfo(i)
            if sender then
                if InboxItemCanDelete(i) then
                    if (not CODAmount or CODAmount==0) and (not money or money==0) and (not itemCount or itemCount==0) then
                        numCanDelete= numCanDelete +1
                    end
                else
                    numCanRe= numCanRe+1
                end
                allMoney= allMoney+ (money or 0)
                allCODAmount= allCODAmount+ (CODAmount or 0)
                allItemCount= allItemCount+ (itemCount or 0)
                if not allSenderTab[sender] and not isGM and not invoiceType then
                    allSenderTab[sender]=true
                    allSender= allSender +1
                end
            end
        end
    end

    InboxFrame.DeleteAllButton.Text:SetText(numCanDelete)--删除所有信，按钮
    InboxFrame.DeleteAllButton:SetShown(numCanDelete>0)

    --退回，所有信，按钮
    InboxFrame.ReAllButton.Text:SetText(numCanRe)
    InboxFrame.ReAllButton:SetShown(numCanRe>1)


    --总，内容，提示
    local text=''
    if not hide then
        local allSenderText--总，发信人数
        if allSender>0 then
            if e.onlyChinese then
                allSenderText= '发信人'
            else
                allSenderText= ITEM_TEXT_FROM:gsub(',','')
                allSenderText= allSenderText:gsub('，','')
            end
            allSenderText= '|cnGREEN_FONT_COLOR:'..allSender..'|r'..allSenderText..' '
        end
        if totalItems>0 then
            text= '|cnGREEN_FONT_COLOR:'..totalItems..'|r'..(e.onlyChinese and '信件' or MAIL_LABEL)..' '--总，信件
                ..(allSenderText or '')--总，发信人数
                ..(allItemCount>0 and '|cnGREEN_FONT_COLOR:'..allItemCount..'|r'..(e.onlyChinese and '物品' or ITEMS)..' ' or '')--总，物品数
                ..(allMoney>0 and '|cnGREEN_FONT_COLOR:'..get_Money(allMoney)..'|r'..(e.onlyChinese and '可取' or WITHDRAW)..' ' or '')--总，可收取钱
                ..(allCODAmount>0 and '|cnRED_FONT_COLOR:'.. get_Money(allCODAmount)..'|r'..(e.onlyChinese and '付款' or COD)..' ' or '')--总，要付款钱
        end
    end
    InboxFrame.AllTipsLable:SetText(text)
end

























--提示，需要付钱, 可收取钱
--多物品，打开时
local function Set_OpenMail_Update()
    if not OpenMailFrame_IsValidMailID() then
        return
    end

    local sender, _, money, CODAmount
    local hide= Save().hide

    if not hide then
        sender, _, money, CODAmount= select(3, GetInboxHeaderInfo(InboxFrame.openMailID))
    end

    if sender then
        local newName= WoWTools_MailMixin:GetNameInfo(sender)
        if newName~=sender and not OpenMailFrame.sendTips and not hide then
            OpenMailFrame.sendTips= WoWTools_LabelMixin:Create(OpenMailFrame)
            OpenMailFrame.sendTips:SetPoint('BOTTOMLEFT', OpenMailSender.Name, 'TOPLEFT')
        end
        if OpenMailFrame.sendTips then
            OpenMailFrame.sendTips:SetText(newName==sender and '' or newName)
        end
    elseif OpenMailFrame.sendTips then
        OpenMailFrame.sendTips:SetText('')
    end

    local moneyPaga= CODAmount and CODAmount>0 and CODAmount or nil
    local moneyGet= money and money>0 and money or nil

    --提示，需要付钱
    if (moneyPaga or moneyGet) and not OpenMailFrame.CODAmountTips then
        OpenMailFrame.CODAmountTips= OpenMailFrame:CreateTexture(nil, 'OVERLAY')
        OpenMailFrame.CODAmountTips:SetSize(150, 25)
        OpenMailFrame.CODAmountTips:SetPoint('BOTTOM',0, 68)
        OpenMailFrame.CODAmountTips:SetAtlas('jailerstower-wayfinder-rewardbackground-selected')
        OpenMailFrame.moneyPagaTip= WoWTools_LabelMixin:Create(OpenMailFrame)
        OpenMailFrame.moneyPagaTip:SetPoint('CENTER', OpenMailFrame.CODAmountTips)

    end
    if OpenMailFrame.CODAmountTips then
        if moneyPaga then
            OpenMailFrame.CODAmountTips:SetVertexColor(1,0,0)
            OpenMailFrame.moneyPagaTip:SetTextColor(1,0,0)
        elseif moneyGet then
            OpenMailFrame.CODAmountTips:SetVertexColor(0,1,0)
            OpenMailFrame.moneyPagaTip:SetTextColor(0,1,0)
        end
        OpenMailFrame.CODAmountTips:SetShown((moneyPaga or moneyGet) and not hide)

        if (moneyPaga or moneyGet) then
            local text
            if moneyPaga then
                text= (e.onlyChinese and '付款' or COD)
            elseif moneyGet then
                text= (e.onlyChinese and '可取' or WITHDRAW)
            end
            text= text..' '..get_Money(moneyPaga or moneyGet)
            OpenMailFrame.moneyPagaTip:SetText(text)
        else
            OpenMailFrame.moneyPagaTip:SetText('')
        end
    end

    for i=1, ATTACHMENTS_MAX_RECEIVE do--物品，信息
        local attachmentButton = OpenMailFrame.OpenMailAttachments[i]
        if attachmentButton and attachmentButton:IsShown() then
            e.Set_Item_Info(attachmentButton, {itemLink= (not hide and HasInboxItem(InboxFrame.openMailID, i)) and GetInboxItemLink(InboxFrame.openMailID, i)})
        end
    end
end















--收信箱，物品，提示
local function Init()
    local showButton= WoWTools_ButtonMixin:Cbtn(InboxFrame, {size=22, icon='hide'})
    showButton:SetFrameStrata(MailFrame.TitleContainer:GetFrameStrata())
    showButton:SetFrameLevel(MailFrame.TitleContainer:GetFrameLevel()+1)
    showButton:SetPoint('LEFT', MailFrame.TitleContainer, -5, 0)
    showButton:SetAlpha(0.3)
    function showButton:set_texture()
        self:SetNormalAtlas(Save().hide and e.Icon.disabled or e.Icon.icon)
    end
    showButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Save().hide= not Save().hide and true or nil
            self:set_texture()
            WoWTools_MailMixin:RefreshAll()
        elseif d=='RightButton' then
            e.OpenPanelOpting(nil, WoWTools_MailMixin.addName)
        end
    end)

    showButton:SetScript('OnLeave', function(self)
        self:SetAlpha(0.3)
        e.tips:Hide()
    end)
    showButton:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MailMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(nil, true), e.Icon.left)--not e.onlyChinese and SHOW..'/'..HIDE or '显示/隐藏')
        e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
        e.tips:Show()
    end)
    showButton:set_texture()


    Create_DeleteAllButton()--删除所有信，按钮
    Create_ReAllButton()--退回，所有信，按钮
    Create_AllTipsLable()--总，内容，提示
    hooksecurefunc('InboxFrame_Update', Init_InboxFrame_Update)


    --提示，需要付钱, 可收取钱
    hooksecurefunc('OpenMail_Update', Set_OpenMail_Update)
end






function WoWTools_MailMixin:Init_InBox()--收信箱，物品，提示
    Init()
end
