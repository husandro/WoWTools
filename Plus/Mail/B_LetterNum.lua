local function Save()
    return WoWToolsSave['Plus_Mail']
end








local function Init()--字数
    --清除，收件人
    SendMailNameEditBox.clearButton= WoWTools_ButtonMixin:Cbtn(SendMailNameEditBox, {
        size=22,
        atlas='bags-button-autosort-up',
        name= 'WoWToolsClearSendMailNameButton'
    })

    SendMailNameEditBox.clearButton:SetPoint('RIGHT', SendMailNameEditBox, 'LEFT', -4, 0)
    SendMailNameEditBox.clearButton:SetScript('OnLeave', GameTooltip_Hide)
    SendMailNameEditBox.clearButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, 'UI Plus')
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, WoWTools_DataMixin.onlyChinese and '收件人' or MAIL_TO_LABEL)
        GameTooltip:Show()
    end)
    SendMailNameEditBox.clearButton:SetScript('OnClick', function(self)
        self:GetParent():SetText('')
        WoWTools_MailMixin:RefreshAll()
    end)

--收件人
    SendMailNameEditBox.playerTipsLable= WoWTools_LabelMixin:Create(SendMailNameEditBox, {justifyH='CENTER', size=10})
    SendMailNameEditBox.playerTipsLable:SetPoint('BOTTOM', SendMailNameEditBox, 'TOP',0,-3)
    function SendMailNameEditBox:save_log()--保存内容
        Save().lastSendPlayer= Save().logSendInfo and WoWTools_UnitMixin:GetFullName(self:GetText()) or nil--收件人
    end
    SendMailNameEditBox:HookScript('OnTextChanged', function(self)
        local name= WoWTools_UnitMixin:GetFullName(self:GetText())
        local text= WoWTools_MailMixin:GetRealmInfo(name) or ''
        if text=='' then
            text= WoWTools_MailMixin:GetNameInfo(name) or text
            if (LOCALE_koKR or LOCALE_zhCN or LOCALE_zhTW or LOCALE_ruRU) and self:GetText():find(' ') then
                text= text..' (|cffffffff'..(WoWTools_DataMixin.onlyChinese and '空格键' or KEY_SPACE)..'|r)'
            end
        end
        self.playerTipsLable:SetText(text)
        self:save_log()

        self.clearButton:SetShown(self:HasText())
    end)

--清除，主题
    SendMailSubjectEditBox.clearButton= WoWTools_ButtonMixin:Cbtn(SendMailSubjectEditBox, {
        size=22,
        atlas='bags-button-autosort-up',
        name= 'WoWToolsClearSendMailSubjectButton'
    })

    SendMailSubjectEditBox.clearButton:SetPoint('RIGHT', SendMailSubjectEditBox, 'LEFT', -4, 0)
    SendMailSubjectEditBox.clearButton:SetScript('OnLeave', GameTooltip_Hide)
    SendMailSubjectEditBox.clearButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, 'UI Plus')
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, WoWTools_DataMixin.onlyChinese and '收件人' or MAIL_TO_LABEL)
        GameTooltip:Show()
    end)
    SendMailSubjectEditBox.clearButton:SetScript('OnClick', function(self)
        self:GetParent():SetText('')
    end)

--主题
    SendMailSubjectEditBox.numLetters= WoWTools_LabelMixin:Create(SendMailSubjectEditBox)
    SendMailSubjectEditBox.numLetters:SetPoint('RIGHT')
    SendMailSubjectEditBox.numLetters:SetAlpha(0)
    function SendMailSubjectEditBox:save_log()--保存内容
        local text
        if Save().logSendInfo then
            text= self:GetText() or ''
            if text==EMOTE56_CMD1:gsub('/','') or text:gsub(' ', '')== '' then text= nil end
        end
        Save().lastSendSub=text
    end
    SendMailSubjectEditBox:HookScript('OnTextChanged', function(self)
        self.numLetters:SetFormattedText('%d/%d', self:GetNumLetters() or 0, self:GetMaxLetters() or 0)
        self:save_log()
        self.clearButton:SetShown(self:HasText())
    end)
    SendMailSubjectEditBox:HookScript('OnEditFocusGained', function(self)
        self.numLetters:SetAlpha(1)
    end)
    SendMailSubjectEditBox:HookScript('OnEditFocusLost', function(self)
        self.numLetters:SetAlpha(0)
    end)

    --内容
    SendMailBodyEditBox.numLetters= WoWTools_LabelMixin:Create(SendMailBodyEditBox)
    SendMailBodyEditBox.numLetters:SetPoint('BOTTOMRIGHT')
    SendMailBodyEditBox.numLetters:SetAlpha(0)
    function SendMailBodyEditBox:wowtools_settings()
        local has= self:HasFocus()
        local alpha= has and 1 or 0.5
        SendStationeryBackgroundLeft:SetAlpha(alpha)--背景，透明度
        SendStationeryBackgroundRight:SetAlpha(alpha)
        self.numLetters:SetAlpha(has and 1 or 0)
    end
    function SendMailBodyEditBox:save_log()--保存内容
        local text
        if Save().logSendInfo then
            text= self:GetText() or ''
            if text:gsub(' ', '')== '' then text= nil end
        end
        Save().lastSendBody=text
    end
    SendMailBodyEditBox:HookScript('OnTextChanged', function(self)
        self.numLetters:SetFormattedText('%d/%d', self:GetNumLetters() or 0, self:GetMaxLetters() or 0)
        self.numLetters:SetFormattedText('%d/%d', self:GetNumLetters() or 0, self:GetMaxLetters() or 0)
        self:save_log()
    end)
    SendMailBodyEditBox:HookScript('OnEditFocusGained', SendMailBodyEditBox.wowtools_settings)
    SendMailBodyEditBox:HookScript('OnEditFocusLost', SendMailBodyEditBox.wowtools_settings)
    SendMailBodyEditBox:wowtools_settings()

    Init=function()end
end









function WoWTools_MailMixin:Init_Edit_Letter_Num()
    Init()
end