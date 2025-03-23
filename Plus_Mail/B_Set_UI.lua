if GameLimitedMode_IsActive() then
    return
end



local function Save()
    return WoWTools_MailMixin.Save
end









local P_INBOXITEMS_TO_DISPLAY= INBOXITEMS_TO_DISPLAY--7

local function Set_Inbox_btn_Point(btn, index)--设置，模板，内容，位置
    if not btn then
        return
    end

    btn:SetPoint('RIGHT', -17, 0)

    _G['MailItem'..index..'Sender']:SetPoint('RIGHT', -40, 0)
    _G['MailItem'..index..'Subject']:SetPoint('RIGHT', -2, 0)

    for i, region in pairs({btn:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            if i==3 then
                region:ClearAllPoints()
                region:SetPoint('BOTTOMLEFT')
                region:SetPoint('TOPRIGHT')
                region:SetAtlas('ClickCastList-ButtonBackground')
            else
                region:SetTexture(0)
            end
        end
    end
end

local function Set_Inbox_Button()--显示，隐藏，建立，收件，物品
    for i=P_INBOXITEMS_TO_DISPLAY +1, INBOXITEMS_TO_DISPLAY, 1 do
        local btn= _G['MailItem'..i]
        if not btn then
            btn= CreateFrame('Frame', 'MailItem'..i, InboxFrame, 'MailItemTemplate')
            btn:SetPoint('TOPLEFT', _G['MailItem'..(i-1)], 'BOTTOMLEFT')
            Set_Inbox_btn_Point(btn, i)--设置，模板，内容，位置
        end
        
        btn:SetShown(true)
    end

    local index= INBOXITEMS_TO_DISPLAY+1--隐藏    
    while _G['MailItem'..index] do
        local btn= _G['MailItem'..index]
        btn:SetShown(false)
        if btn.clear_all_date then
            btn:clear_all_date()
        end
        index= index+1
    end
    --InboxFrameBg:SetShown(Save().INBOXITEMS_TO_DISPLAY)--因为图片，大小不一样，所有这样处理
end


















local function Init()
    MailFrameInset.Bg:SetTexture(0)

--收件箱
    InboxFrame:SetPoint('RIGHT')
    for i= 1, INBOXITEMS_TO_DISPLAY do--7
        Set_Inbox_btn_Point(_G['MailItem'..i], i)--设置，模板，内容，位置
    end

    InboxFrame:SetPoint('BOTTOMRIGHT')
    InboxPrevPageButton:ClearAllPoints()
    InboxPrevPageButton:SetPoint('BOTTOMLEFT', 10, 10)
    InboxNextPageButton:SetPoint('BOTTOMRIGHT', -10, 10)
    OpenAllMail:ClearAllPoints()--全部打开
    OpenAllMail:SetPoint('BOTTOM', 0, 10)

    --InboxFrameBg:SetAtlas('QuestBG-Parchment')
    --InboxFrameBg:SetAlpha(0.3)
    InboxFrameBg:SetTexture(0)
    --InboxFrameBg:SetPoint('BOTTOMRIGHT', -4,4)

--发件箱
    SendMailFrame:SetPoint('BOTTOMRIGHT', 384-338, 424-512)
    SendMailHorizontalBarLeft:ClearAllPoints()
    SendMailHorizontalBarLeft:SetPoint('BOTTOMLEFT', SendMailMoneyButton, 'TOPLEFT', -14, -4)
    SendMailHorizontalBarLeft:SetPoint('RIGHT', MailFrame, -80, 0)
    SendMailHorizontalBarLeft2:SetPoint('RIGHT', MailFrame, -80, 0)

    SendMailScrollFrame:SetPoint('RIGHT', MailFrame, -34, 0)
    SendMailScrollFrame:SetPoint('BOTTOM', SendMailHorizontalBarLeft2, 'TOP')
    SendMailScrollChildFrame:SetPoint('BOTTOMRIGHT')
    SendStationeryBackgroundLeft:SetPoint('BOTTOMRIGHT', -42, -4)
    SendStationeryBackgroundRight:SetPoint('BOTTOM',0,-4)

    SendMailBodyEditBox:SetPoint('BOTTOMRIGHT', SendMailScrollFrame)



    SendMailSubjectEditBox:SetPoint('RIGHT', MailFrame, -28, 0)--主题
    SendMailSubjectEditBoxMiddle:SetPoint('RIGHT', -8, 0)
    SendMailNameEditBox:SetPoint("TOPLEFT", 80, -30)
    SendMailNameEditBox:SetPoint('RIGHT', -75, -30)
    SendMailNameEditBoxMiddle:SetPoint('RIGHT',-8,0)
    --SendMailNameEditBox:SetPoint('TOPLEFT', 122, -30 )--x="90" y="-30
    --SendMailNameEditBox:SetPoint('RIGHT', SendMailCostMoneyFrame, 'LEFT', -54, 0)--收件人
    --SendMailNameEditBoxMiddle:SetPoint('RIGHT', -8, 0)


    SendMailCostMoneyFrame:ClearAllPoints()
    SendMailCostMoneyFrame:SetPoint('TOPLEFT', SendMailScrollFrame)
    SendMailBodyEditBox:HookScript('OnEditFocusGained', function()
        SendMailCostMoneyFrame:Hide()
    end)
    SendMailBodyEditBox:HookScript('OnEditFocusLost', function()
        SendMailCostMoneyFrame:Show()
    end)
    SendMailCostMoneyFrame:SetScript('OnLeave', GameTooltip_Hide)--隐藏， 邮资：，文本
    SendMailCostMoneyFrame:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, 'UI Plus')
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '邮资：' or SEND_MAIL_COST)
        GameTooltip:Show()
    end)
    if SendMailCostMoneyFrame then
        local frames= {SendMailCostMoneyFrame:GetRegions()}
        for _, text in pairs(frames) do
            if text:GetObjectType()=="FontString" and text:GetText()==SEND_MAIL_COST then
                text:SetText('')
                text:Hide()
                break
            end
        end
    end




--收件人：
    for _, region in pairs({SendMailNameEditBox:GetRegions()}) do
        if region:GetObjectType()=='FontString' and region:GetText()==MAIL_TO_LABEL then
            region:SetText('')
            break
        end
    end
    WoWTools_EditBoxMixin:SetInstructions(SendMailNameEditBox, WoWTools_Mixin.onlyChinese and '收件人' or MAIL_TO_LABEL:gsub(HEADER_COLON,''))
    WoWTools_EditBoxMixin:HookInstructions(SendMailNameEditBox)

--主题
    for _, region in pairs({SendMailSubjectEditBox:GetRegions()}) do
        if region:GetObjectType()=='FontString'  then
            local text= region:GetText()
            if text==MAIL_SUBJECT_LABEL or text=='主题：' then
                region:SetText('')
                break
            end
        end
    end
    WoWTools_EditBoxMixin:SetInstructions(SendMailSubjectEditBox, WoWTools_Mixin.onlyChinese and '主题' or MAIL_SUBJECT_LABEL:gsub(HEADER_COLON,''))
    WoWTools_EditBoxMixin:HookInstructions(SendMailSubjectEditBox)

    hooksecurefunc('SendMailRadioButton_OnClick', function(index)
        if ( index == 1 ) then
            SendMailMoneyText:SetTextColor(1,0,0)--Text(AMOUNT_TO_SEND)
        else
            SendMailMoneyText:SetTextColor(0,1,0)--(COD_AMOUNT);
        end
    end)
end













local function Set_Move()
    if not Save().hideUIPlus then

        WoWTools_MoveMixin:Setup(MailFrame, {
            --needSize=true, needMove=true,
            setSize=true, minW=338, minH=424,
        initFunc=function(btn)
            if Save().INBOXITEMS_TO_DISPLAY then
                INBOXITEMS_TO_DISPLAY= Save().INBOXITEMS_TO_DISPLAY
                Set_Inbox_Button()--显示，隐藏，建立，收件，物品    
            end
        end, sizeUpdateFunc=function(btn)
            local h= btn.targetFrame:GetHeight()-424
            local num= P_INBOXITEMS_TO_DISPLAY
            if h>45 then
                num= num+ math.modf(h/45)
            end
            INBOXITEMS_TO_DISPLAY=num
            Set_Inbox_Button()--显示，隐藏，建立，收件，物品
            Save().INBOXITEMS_TO_DISPLAY= num>P_INBOXITEMS_TO_DISPLAY and num or nil
            WoWTools_MailMixin:RefreshAll()
        end, sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(338, 424)
            Save().INBOXITEMS_TO_DISPLAY=nil
            INBOXITEMS_TO_DISPLAY= P_INBOXITEMS_TO_DISPLAY
            Set_Inbox_Button()--显示，隐藏，建立，收件，物品
            WoWTools_MailMixin:RefreshAll()
        end})

        WoWTools_MoveMixin:Setup(SendMailFrame, {frame=MailFrame})
        WoWTools_MoveMixin:Setup(MailFrame.TitleContainer, {frame=MailFrame})

    else
        WoWTools_MoveMixin:Setup(MailFrame)
        WoWTools_MoveMixin:Setup(SendMailFrame, {frame=MailFrame})
        WoWTools_MoveMixin:Setup(MailFrame.TitleContainer, {frame=MailFrame})
    end
end









function WoWTools_MailMixin:Init_UI()--收信箱，物品，提示
    if not self.Save.hideUIPlus then
        Init()
    end
    Set_Move()
end
