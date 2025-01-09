local e= select(2, ...)
local function Save()
    return WoWTools_MailMixin.Save
end








local function Init()--字数
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
                text= text..' (|cffffffff'..(e.onlyChinese and '空格键' or KEY_SPACE)..'|r)'
            end
        end
        self.playerTipsLable:SetText(text)
        self:save_log()
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
end









function WoWTools_MailMixin:Init_Edit_Letter_Num()
    Init()
end