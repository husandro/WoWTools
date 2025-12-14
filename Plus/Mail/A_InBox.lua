local function Save()
    return WoWToolsSave['Plus_Mail']
end

local AUCTION_REMOVED_MAIL_SUBJECT= WoWTools_TextMixin:Magic(AUCTION_REMOVED_MAIL_SUBJECT) --= "拍卖取消：%s";










local function get_Money(num)
    local text
    if num and num>0 then
        if num>=1e4 then
            text= WoWTools_DataMixin:MK(num/1e4, 2)..'|TInterface/moneyframe/ui-goldicon:0|t'
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
        delOrRe= '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)..'|r'
    else
        delOrRe= '|cFFFF00FF'..(WoWTools_DataMixin.onlyChinese and '退信' or MAIL_RETURN)..'|r'
    end

    if canDelete and (not money or money==0) and (not CODAmount or CODAmount==0) and (not itemCount or itemCount) then
        DeleteInboxItem(openMailID)
    else
        InboxFrame.openMailID= openMailID
        OpenMailFrame.itemName= (itemCount and itemCount>0) and itemName or nil
        OpenMailFrame.money= money
        WoWTools_DataMixin:Call('OpenMail_Delete')--删除，或退信 MailFrame.lua
    end

    print(
        WoWTools_DataMixin.Icon.icon2..'|cFFFF00FF'..openMailID..')|r',
        ((icon and not itemName) and '|T'..icon..':0|t' or '')..delOrRe,
        WoWTools_UnitMixin:GetLink(nil, nil, sender, false),
        subject,
        itemName or '',
        (money and money>0) and GetMoneyString(money, true) or '',
        (CODAmount and CODAmount>0) and GetMoneyString(CODAmount, true) or '',
        text and '|n'..text or ''
    )
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

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, (WoWTools_DataMixin.onlyChinese and '收件箱' or INBOX)..' Plus')
    local num=0
    local findReTips--显示第一个，退回信里，的物品
    for i=1, select(2, GetInboxNumItems()) do
        local canDelete=InboxItemCanDelete(i)
        local packageIcon, stationeryIcon, sender, subject, money, CODAmount, _, itemCount, wasRead, _, _, _, _, _, firstItemLink = GetInboxHeaderInfo(i)
        local moneyPaga= (CODAmount and CODAmount>0) and CODAmount or nil
        local moneyGet= (money and money>0) and money or nil
        local itemLink= find_itemLink(itemCount, i, firstItemLink)--查找，信件里的第一个物品，超链接
        if (canDelete and del and not moneyPaga and not moneyGet and not itemLink) or (not del and not canDelete) then
            GameTooltip:AddDoubleLine((i<10 and ' ' or '')
                                    ..i..') |T'..(packageIcon or stationeryIcon)..':0|t'
                                    ..WoWTools_MailMixin:GetNameInfo(sender)
                                    ..(not wasRead and ' |cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未读' or COMMUNITIES_FRAME_JUMP_TO_UNREAD) or '')
                                , subject)

            if not canDelete and (itemCount and itemCount>0) and not findReTips then--物品，提示
                local allCount=0
                for itemIndex= 1, itemCount do
                    local itemIndexLink= GetInboxItemLink(i, itemIndex)
                    if itemIndexLink then
                        local texture, count = select(3, GetInboxItem(i, itemIndex))
                        allCount= allCount+ (count or 1)
                        GameTooltip:AddDoubleLine(' ','|cnGREEN_FONT_COLOR:'..(count or 1)..'x|r '..(texture and '|T'..texture..':0|t' or '')..itemIndexLink..' ('..itemIndex)
                    end
                end
                if allCount>1 then
                    GameTooltip:AddDoubleLine(' ', '#'..WoWTools_DataMixin:MK(allCount, 3))
                end
                GameTooltip:AddLine(' ')
            end

            if not findReTips then--显示，所有，选中提示
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
    GameTooltip:AddDoubleLine(' ',
                        del and '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)..'|r |cnGREEN_FONT_COLOR:#'..num
                        or ('|cFFFF00FF'..(WoWTools_DataMixin.onlyChinese and '退信' or MAIL_RETURN)..'|r |cnGREEN_FONT_COLOR:#'..num)
                    )
    GameTooltip:Show()
end



local function eventEnter(self, get)--enter 提示，删除，或退信，按钮
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, (WoWTools_DataMixin.onlyChinese and '收件箱' or INBOX)..' Plus')
    GameTooltip:AddLine(' ')
    local packageIcon, stationeryIcon, _, _, _, _, _, itemCount = GetInboxHeaderInfo(self.openMailID)
    local allCount=0
    if itemCount then
        for itemIndex= 1, itemCount do
            local itemIndexLink= GetInboxItemLink(self.openMailID, itemIndex)
            if itemIndexLink then
                local texture, count = select(3, GetInboxItem(self.openMailID, itemIndex))
                texture = texture or select(5, C_Item.GetItemInfoInstant(itemIndexLink))
                allCount= allCount+ (count or 1)
                GameTooltip:AddLine((itemIndex<10 and ' ' or '')..itemIndex..') '..(texture and '|T'..texture..':0|t' or '')..itemIndexLink..'|cnGREEN_FONT_COLOR: x'..(count or 1)..'|r')
            end
        end
        GameTooltip:AddLine(' ')
    end
    local text= GetInboxText(self.openMailID)
    if text and text:gsub(' ', '')~='' then
        GameTooltip:AddLine(text, nil,nil,nil, true)
        GameTooltip:AddLine(' ')
    end

    local text2
    if get then
        text2= WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW
    elseif self.canDelete then
        text2= WoWTools_DataMixin.onlyChinese and '删除' or DELETE
    else
        text2= WoWTools_DataMixin.onlyChinese and '退信' or MAIL_RETURN
    end
    local icon= packageIcon or stationeryIcon
    GameTooltip:AddLine('|cffff00ff'..self.openMailID..' |r'..(icon and '|T'..icon..':0|t')..text2..(allCount>1 and ' |cnGREEN_FONT_COLOR:'..WoWTools_DataMixin:MK(allCount,3)..'|r'..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS) or ''))
    GameTooltip:Show()
end














--删除所有信，按钮
local function Create_DeleteAllButton()
    InboxFrame.DeleteAllButton= WoWTools_ButtonMixin:Cbtn(InboxFrame, {
        size=25,
        atlas='xmarksthespot',
        name='WoWToolsInboxDeleteAllButton'
    })
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
        GameTooltip:Hide()
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
    InboxFrame.ReAllButton= WoWTools_ButtonMixin:Cbtn(InboxFrame, {
        size=25,
        atlas='common-icon-undo',
        name= 'WoWToolsInboxReAllButton'
    })
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
        GameTooltip:Hide()
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
















--删除，或退信，按钮
local function Create_Unit_Button(btn, i)
    if btn.DeleteButton then
        return
    end

    --btn.expireTimeButton= _G['MailItem'..i..'ExpireTime']
    local lable= _G['MailItem'..i ..'ButtonCOD']
    if lable then
        lable:SetText("")
    end

    btn.countLable= _G['MailItem'..i..'ButtonCount']

    --发信人，提示, 点击回复
    lable=_G["MailItem"..i.."Sender"]
    btn.senderLable= lable

    lable:SetScript('OnMouseDown', function(self)
        if (self.playerName or self.sender) and self.canReply  then
            OpenMailSender.Name:SetText(self.playerName or self.sender)
            OpenMailSubject:SetText(self.subject)
            InboxFrame.openMailID= self.openMailID
            WoWTools_DataMixin:Call('OpenMail_Reply')--回复
        end
        self:SetAlpha(1)
    end)
    lable:SetScript('OnEnter', function(self)
        if (self.playerName or self.sender) and self.canReply  then
            GameTooltip:SetOwner(self:GetParent(), "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, (WoWTools_DataMixin.onlyChinese and '收件箱' or INBOX)..' Plus')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '回复' or REPLY_MESSAGE, self.playerName or self.sender)
            GameTooltip:Show()
        end
        self:SetAlpha(0.3)
    end)
    lable:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)

--信件，索引，提示
    btn.indexText= WoWTools_LabelMixin:Create(btn, {alpha= 0.5})
    btn.indexText:SetPoint('RIGHT', btn, 'LEFT',-2,0)

--提示，需要付钱, 可收取钱
    btn.typeTexture= btn:CreateTexture(nil, 'OVERLAY')--图片
    btn.typeTexture:SetSize(150, 16)
    btn.typeTexture:SetPoint('BOTTOM', _G['MailItem'..i], 0,-4)
    btn.typeTexture:SetAtlas('jailerstower-wayfinder-rewardbackground-selected')
    btn.typeTexture:SetAlpha(0.75)
    --btn.typeTexture:EnableMouse(true)
    btn.typeText= WoWTools_LabelMixin:Create(btn)--文本
    btn.typeText:SetPoint('CENTER', btn.typeTexture)
    --btn.typeText:EnableMouse(true)

    btn.DeleteButton= WoWTools_ButtonMixin:Cbtn(btn, {size=18, name='WoWToolsMailItem'..i..'DeleteButton'})
    btn.DeleteButton:SetPoint('BOTTOMRIGHT', _G['MailItem'..i], -4, 0)

    btn.DeleteButton:SetScript('OnClick', function(self)--OpenMail_Delete()
        return_delete_InBox(self.openMailID)--删除，或退信
        C_Timer.After(0.3, function()
            if self:IsMouseOver() then
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
        GameTooltip:Hide()
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
    btn.outItemOrMoney= WoWTools_ButtonMixin:Cbtn(btn, {size={22, 20}, atlas='Cursor_OpenHand_32'})
    btn.outItemOrMoney:SetPoint('RIGHT', btn.DeleteButton, 'LEFT', -22, 0)
    btn.outItemOrMoney:SetScript('OnClick', function(self)
        WoWTools_DataMixin:Call('InboxFrame_OnModifiedClick', self:GetParent(), self.openMailID)
    end)
    btn.outItemOrMoney:SetScript('OnLeave' ,function(self)
        self:GetParent().enterTipTexture:SetShown(false)
        GameTooltip:Hide()
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
        self.typeTexture:SetShown(false)
        self.typeText:SetText('')
        self.outItemOrMoney:SetShown(false)
        self.DeleteButton:SetShown(false)
        WoWTools_ItemMixin:SetupInfo(self)
    end

end















local function Init_InboxFrame_Update()
    local hide= Save().hide

    for i=1, INBOXITEMS_TO_DISPLAY do
        local btn=_G["MailItem"..i.."Button"]

        if hide or not btn:IsShown() or not btn.index then
            if btn.clear_all_date then
                btn:clear_all_date()
            end
            btn:GetParent():SetAlpha(0)
        else

            Create_Unit_Button(btn, i)

            local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem, wasRead, wasReturned, textCreated, canReply, isGM, firstItemQuantity, firstItemLink= GetInboxHeaderInfo(btn.index)

            local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(btn.index)

            local isCOD = CODAmount and CODAmount>0
            local isAuctionHouse= invoiceType~=nil or sender==BUTTON_LAG_AUCTIONHOUSE--拍卖行
            local isSelf= sender==WoWTools_DataMixin.Player.Name

            if hasItem and hasItem>1 then
                btn.countLable:SetText('|cffffd100'..hasItem..'|r')
                btn.countLable:SetShown(true)
            end
            --发信人，提示, 点击回复
            btn.senderLable.canReply= canReply
            btn.senderLable.sender= sender
            btn.senderLable.subject= subject
            btn.senderLable.openMailID= btn.index
            btn.senderLable.playerName= (invoiceType=='buyer' or invoiceType=='seller') and playerName or nil

            if sender and not isGM and not isSelf and not isAuctionHouse then
                btn.senderLable:EnableMouse(true)
                btn.senderLable:SetText(playerName and sender..'  '..WoWTools_MailMixin:GetNameInfo(playerName) or WoWTools_MailMixin:GetNameInfo(sender))--发信人，提示 
            else
                btn.senderLable:EnableMouse(false)
            end

            --信件，索引，提示
            btn.indexText:SetText(btn.index or '')

            --提示，需要付钱, 可收取钱
            local text=''
            if isAuctionHouse then--拍卖行，黄色
                btn.typeTexture:SetVertexColor(1,1,0)
                btn.typeText:SetTextColor(1,1,0)
                text= invoiceType=='buyer' and '|A:UI-HUD-Minimap-Zoom-Out:0:0|a'--卖
                        or (subject and subject:match(AUCTION_REMOVED_MAIL_SUBJECT) and '|A:common-icon-undo:0:0|a')
                        or '|A:UI-HUD-Minimap-Zoom-In:0:0|a'--买

            elseif isCOD then--付款，红色
                btn.typeTexture:SetVertexColor(1,0,0)
                btn.typeText:SetTextColor(1,0,0)
                text= WoWTools_DataMixin.onlyChinese and '付款' or COD

            elseif isGM or isSelf then--GM, 自已,系统功能，如角色直升, 紫色
                btn.typeTexture:SetVertexColor(0,0.5,1)
                btn.typeText:SetTextColor(0,0.5,1)
                text= isGM and 'GM' or WoWTools_DataMixin.Icon.Player

            else--绿色
                btn.typeTexture:SetVertexColor(0,1,0)
                btn.typeText:SetTextColor(0,1,0)
                if money and money>0 then
                    text= WoWTools_DataMixin.onlyChinese and '可取' or WITHDRAW
                end
            end


            if bid>0 or deposit>0 or consignment>0 then
                text= text..get_Money(bid + deposit - consignment)
            else
                text= text..get_Money(isCOD and CODAmount or money)
            end
            btn.typeTexture:SetShown(hasItem and hasItem>0 or text~='')
            btn.typeText:SetText(text)

            --删除，或退信，按钮，设置参数
            btn.DeleteButton:SetNormalTexture(InboxItemCanDelete(btn.index) and 'xmarksthespot' or 'common-icon-undo')
            btn.DeleteButton.openMailID= btn.index
            btn.DeleteButton:SetShown(not isAuctionHouse)

            btn.DeleteButton.numItemLabel:SetText(hasItem and hasItem>1 and hasItem or '')

            btn.outItemOrMoney.openMailID= btn.index
            btn.outItemOrMoney:SetShown((money or hasItem) and not isCOD)

            WoWTools_ItemMixin:SetupInfo(btn, firstItemLink and {itemLink=firstItemLink} or nil)
            btn:GetParent():SetAlpha(1)
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
            if WoWTools_DataMixin.onlyChinese then
                allSenderText= '发信人'
            else
                allSenderText= ITEM_TEXT_FROM:gsub(',','')
                allSenderText= allSenderText:gsub('，','')
            end
            allSenderText= '|cnGREEN_FONT_COLOR:'..allSender..'|r'..allSenderText..' '
        end
        if totalItems>0 then
            text= '|cnGREEN_FONT_COLOR:'..totalItems..'|r'..(WoWTools_DataMixin.onlyChinese and '信件' or MAIL_LABEL)..' '--总，信件
                ..(allSenderText or '')--总，发信人数
                ..(allItemCount>0 and '|cnGREEN_FONT_COLOR:'..allItemCount..'|r'..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS)..' ' or '')--总，物品数
                ..(allMoney>0 and '|cnGREEN_FONT_COLOR:'..get_Money(allMoney)..'|r'..(WoWTools_DataMixin.onlyChinese and '可取' or WITHDRAW)..' ' or '')--总，可收取钱
                ..(allCODAmount>0 and '|cnWARNING_FONT_COLOR:'.. get_Money(allCODAmount)..'|r'..(WoWTools_DataMixin.onlyChinese and '付款' or COD)..' ' or '')--总，要付款钱
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
                text= (WoWTools_DataMixin.onlyChinese and '付款' or COD)
            elseif moneyGet then
                text= (WoWTools_DataMixin.onlyChinese and '可取' or WITHDRAW)
            end
            text= text..' '..get_Money(moneyPaga or moneyGet)
            OpenMailFrame.moneyPagaTip:SetText(text)
        else
            OpenMailFrame.moneyPagaTip:SetText('')
        end
    end

    local btn
    for i=1, ATTACHMENTS_MAX_RECEIVE do--物品，信息
        btn = OpenMailFrame.OpenMailAttachments[i]
        if btn and btn:IsShown() then
           local itemLink= (not hide and HasInboxItem(InboxFrame.openMailID, i)) and GetInboxItemLink(InboxFrame.openMailID, i) or nil
            WoWTools_ItemMixin:SetupInfo(btn, itemLink and {itemLink= itemLink} or nil)
        end
    end
end















--收信箱，物品，提示
local function Init()
    if Save().hide then
        return
    end

    Create_DeleteAllButton()--删除所有信，按钮
    Create_ReAllButton()--退回，所有信，按钮

--总，内容，提示
    InboxFrame.AllTipsLable= WoWTools_LabelMixin:Create(InboxFrame)
    InboxFrame.AllTipsLable:SetPoint('BOTTOM', InboxFrame, 'TOP', 0, 6)
    --MailFrameTrialError:ClearAllPoints()--你需要升级你的账号才能开启这项功能。

    Init_InboxFrame_Update()
    WoWTools_DataMixin:Hook('InboxFrame_Update', function()
        Init_InboxFrame_Update()
    end)

    MailFrame:HookScript('OnHide', function()--隐藏时，清除数据
        for i=1, INBOXITEMS_TO_DISPLAY do
            local btn=_G["MailItem"..i.."Button"]
            if btn and btn.clear_all_date then
                btn:clear_all_date()
            end
        end
    end)


    --提示，需要付钱, 可收取钱
    WoWTools_DataMixin:Hook('OpenMail_Update', function()
        Set_OpenMail_Update()
    end)

    Init=function()
        WoWTools_MailMixin:RefreshAll()
    end
end






function WoWTools_MailMixin:Init_InBox()--收信箱，物品，提示
    Init()
end
