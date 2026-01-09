--清除所有，要发送物品










local function Init()
    local clearSendItem= CreateFrame('Button', 'WoWToolsMailClearSendItemsButton', SendMailFrame, 'WoWToolsButtonTemplate')
    clearSendItem:SetNormalAtlas('bags-button-autosort-up')
    --WoWTools_ButtonMixin:Cbtn(SendMailFrame, {size=22, atlas='bags-button-autosort-up'})
    clearSendItem:SetPoint('BOTTOMRIGHT', SendMailAttachment7, 'TOPRIGHT')--,0, -4)
    clearSendItem.Text= clearSendItem:CreateFontString(nil, 'BORDER', 'GameFontNormal')--WoWTools_LabelMixin:Create(clearSendItem)
    clearSendItem.Text:SetPoint('BOTTOMRIGHT', clearSendItem, 'BOTTOMLEFT',0, 4)
    clearSendItem:SetScript('OnClick', function()
        for i= 1, ATTACHMENTS_MAX_SEND do
            if HasSendMailItem(i) then
                ClickSendMailItemButton(i, true)
            end
        end
    end)
    clearSendItem:SetScript('OnHide', function(self)
        self:SetButtonState('NORMAL')
    end)
    clearSendItem:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetButtonState('NORMAL')
    end)
    clearSendItem.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)


    WoWTools_DataMixin:Hook('SendMailFrame_Update', function()--发信箱，物品，信息
        local hasItem, btn, num= nil, nil, 0
        for i=1, ATTACHMENTS_MAX_SEND do
            btn = SendMailFrame.SendMailAttachments[i]
            hasItem= HasSendMailItem(i)
            if hasItem then
                num= num+ (select(4, GetSendMailItem(i)) or 1)
            end
            if btn:IsShown() then
                WoWTools_ItemMixin:SetupInfo(btn, hasItem and {itemLink=GetSendMailItemLink(i)} or nil)
                btn:SetAlpha(hasItem and 1 or 0.3)
            end
        end

        clearSendItem.Text:SetText(num>0 and num or '')
        clearSendItem:SetShown(num>0)
    end)

    for _, btn in pairs(SendMailFrame.SendMailAttachments or {}) do
        btn:HookScript('OnLeave', function() WoWTools_BagMixin:Find(false, nil) end)
        btn:HookScript('OnEnter', function(self)
            WoWTools_BagMixin:Find(true, {itemLink=GetSendMailItemLink(self:GetID())})
        end)
    end

    local btn= _G['SendMailAttachment'..ATTACHMENTS_MAX_SEND]--最大数，提示
    if btn then
        btn.max= btn:CreateTexture(nil, 'OVERLAY')
        btn.max:SetSize(20, 30)
        btn.max:SetAtlas('poi-traveldirections-arrow2')
        btn.max:SetAlpha(0.5)
        btn.max:SetPoint('LEFT', btn, 'RIGHT', -2, 0)
    end
    for i=1, ATTACHMENTS_MAX_SEND do--索引，提示
        btn= _G['SendMailAttachment'..i]
        if btn then
            btn.indexLable= WoWTools_LabelMixin:Create(btn, {layer='BORDER'})
            btn.indexLable:SetPoint('CENTER')
            btn.indexLable:SetAlpha(0.3)
            btn.indexLable:SetText(i)
            for _, region in pairs({btn:GetRegions()}) do--背景，透明度
                if region:IsObjectType('Texture')then
                    region:SetAlpha(0.5)
                    break
                end
            end
        end
    end

    Init=function()end
end












function WoWTools_MailMixin:Init_Clear_All_Send_Items()--清除所有，要发送物品
    Init()
end