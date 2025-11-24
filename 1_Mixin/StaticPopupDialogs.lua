--[[
WoWTools_RestData
WoWTools_EditText
WoWTools_Item
WoWTools_GetMapID
WoWTools_OK

exclusive=boolean 当显示任何其他弹出窗口时，隐藏，
whileDead=boolean 即使玩家是鬼魂也会显示对话框
acceptDelay=numberi 5秒后启用
compactItemFrame = boolean
hideOnEscape = 1,
timeout = 0,
]]




local function Get_UIMapIDs_Name(text)--从text取得uiMapID表
    local tab, reText={}, nil
    text:gsub('%d+', function(self)
        local uiMapID= tonumber(self)
        if uiMapID>0 and uiMapID< 2147483647 then
            local info= uiMapID and C_Map.GetMapInfo(uiMapID)
            if uiMapID and info and info.name and not tab[uiMapID] then--uiMapID<2147483647
                tab[uiMapID]=true
                reText= reText and reText..'|n' or ''
                reText= reText..uiMapID..' '..WoWTools_TextMixin:CN(info.name)
            end
        end
    end)
    return tab, reText
end







local function Init()
    StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].acceptDelay=3

--重置, 数据
StaticPopupDialogs['WoWTools_RestData']= {
    text=WoWTools_DataMixin.addName
        ..'|n|n%s|n|n|cnWARNING_FONT_COLOR:'
        ..(WoWTools_DataMixin.onlyChinese and "你想要将所有选项重置为默认状态吗？|n将会立即对所有设置生效。" or CONFIRM_RESET_SETTINGS)
        ..'|r|n|n',
    button1= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
    button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
    OnAccept=function(_, SetValue)
        SetValue()
    end,
    whileDead=true,
    hideOnEscape=true,
    exclusive=true,
    showAlert=true,
    acceptDelay= 1,
}











StaticPopupDialogs['WoWTools_EditText']={
    text=WoWTools_DataMixin.addName..'|n|n%s|n',
    button1= WoWTools_DataMixin.onlyChinese and '修改' or EDIT,
    button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
    button3= WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
    OnShow=function(self, data)
        local edit= self.editBox or self:GetEditBox()
        edit:SetAutoFocus(false)
        edit:SetText(data.text or '')

        local b3= self.button3 or self:GetButton3()
        b3:SetShown(data.OnAlt and true or false)

        if data.OnShow then
            data.OnShow(self, data)
        end

        edit:SetFocus()
    end,
    OnHide=function(self, data)
        if data.OnHide then
            data.OnHide(self, data)
        end
        local edit= self.editBox or self:GetEditBox()
        edit:SetText("")
        edit:ClearFocus()
    end,
    OnAccept=function(self, data)
        data.SetValue(self, data)
    end,
    OnAlt=function(self, data)
        if data.OnAlt then
            data.OnAlt(self, data)
        end
    end,
    EditBoxOnTextChanged=function(self, data)
        local text= self:GetText() or ''
        local p= self:GetParent()

        local b1= p.button1 or p:GetButton1()
        b1:SetEnabled(text:gsub(' ', '')~='' and text~=data.text)

        if data.EditBoxOnTextChanged then
            data.EditBoxOnTextChanged(self, data, text)
        end
    end,
    EditBoxOnEscapePressed = function(self)
        self:ClearFocus()
        self:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(self, data)
        self:ClearFocus()
        local p = self:GetParent();
        local b1= p.button1 or p:GetButton1()
        if b1:IsEnabled() then
            if data.SetValue then
                data.SetValue(p, data)
            end
            p:Hide()
        end
    end,
    hideOnEscape=true,
    hasEditBox=true,
    editBoxWidth=360,
}
--[[
StaticPopup_Show('WoWTools_EditText',
    (name or ''),
    nil,
    {
        text=editBox内容,
        OnShow=function(s, data)
        end,
        SetValue= function(s)
        end,
        OnAlt=function(s, data)
        end,
        EditBoxOnTextChanged=function(s, data, text)
        end,
    }
)
]]







StaticPopupDialogs['WoWTools_Item'] = {
	text = WoWTools_DataMixin.addName..'|n|n%s',
	button1 = WoWTools_DataMixin.onlyChinese and '添加' or ADD,
	button2 = WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
    button3 = WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
    OnShow=function(self, data)
        if data.OnShow then
            data.OnShow(self, data)
        end
        local b3= self.button3 or self:GetButton3()
        b3:SetShown(data.OnAlt and true or false)
    end,
	OnAccept =function(self, data)
        data.SetValue(self, data)
    end,
    OnAlt=function(self, data)
        if data.OnAlt then
            data.OnAlt(self, data)
        end
    end,
	exclusive = true,
	hasItemFrame = true,
    hideOnEscape=true,
	--fullScreenCover = true,
};
--[[
local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(info.itemLink or info.itemID)
StaticPopup_Show('WoWTools_Item',addName, nil, {
    link= itemLink,
    itemID=info.itemID,
    name= itemName,
    color= {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()},
    texture= itemTexture,
    count=C_Item.GetItemCount(info.itemID, true, false, true,true),
    OnShow=function(s, data)
    end,
    SetValue = function(_, data)
    end,
    OnAlt = function(_, data)
    end
})
]]



StaticPopupDialogs['WoWTools_GetMapID'] = {--区域,设置对话框
        text=WoWTools_DataMixin.addName..' '..(WoWTools_DataMixin.onlyChinese and '区域' or FLOOR)..'|n|n%s',
        button1=WoWTools_DataMixin.onlyChinese and '区域' or FLOOR,
        button2=WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        button3=WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            local edit= self.editBox or self:GetEditBox()
            edit:SetAutoFocus(false)
            edit:SetText(data.text or '')

            local b3= self.button3 or self:GetButton3()
            b3:SetShown(data.OnAlt and true or false)

            if data.OnShow then
                data.OnShow(self, data)
            end

            edit:SetFocus()
        end,
        OnHide=function(self)
            local edit= self.editBox or self:GetEditBox()
            edit:SetText("")
            edit:ClearFocus()
        end,
        OnAccept = function(self, data)
            local edit= self.editBox or self:GetEditBox()
            local tab, text= Get_UIMapIDs_Name(edit:GetText())
            data.SetValue(self, data, tab, text)
        end,
        OnAlt = function(self, data)
            if data.OnAlt then
                data.OnAlt(self, data)
            end
        end,
        EditBoxOnTextChanged=function(self, data)
            local _, text= Get_UIMapIDs_Name(self:GetText())
            local p= self:GetParent()
            local b1= p.button1 or p:GetButton1()
            b1:SetEnabled((text and text~=data.text) and true or false)
            b1:SetText(text or (WoWTools_DataMixin.onlyChinese and '无' or NONE))
        end,
        EditBoxOnEscapePressed = function(self)
            self:ClearFocus()
            self:GetParent():Hide()
        end,
        EditBoxOnEnterPressed = function(self, data)
            self:ClearFocus()
            local p = self:GetParent();
            local b1= p.button1 or p:GetButton1()
            if b1:IsEnabled() then
                local tab, text= Get_UIMapIDs_Name(self:GetText())
                if data and data.SetValue then
                    data.SetValue(p, data, tab, text)
                end
                p:Hide()
            end
        end,
        hideOnEscape=true,
        hasEditBox=true,
        editBoxWidth=360,
       --hasItemFrame = true,
       -- showAlert=true,
    }





    StaticPopupDialogs['WoWTools_OK']={
        text =WoWTools_DataMixin.addName..'|n|n%s',
        button1 = WoWTools_DataMixin.onlyChinese and '确定' or OKAY,
        button2 = WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow=function(self, data)
            if data.OnShow then
                data.OnShow(self, data)
            end
        end,
        OnAccept=function(self, data)
            data.SetValue(self, data)
        end,
        whileDead=true,
        hideOnEscape=true,
        exclusive=true,
        showAlert=true,
        acceptDelay=1,
    }
--[[
StaticPopup_Show('WoWTools_OK',
data.name,
nil,
{SetValue=function()

end})
]]



    StaticPopupDialogs["WoWTools_Tooltips_LinkURL"] = {
        text= '|n|cffff00ff%s|r |cnGREEN_FONT_COLOR:Ctrl+C |r'..(WoWTools_DataMixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK),
        button1 = WoWTools_DataMixin.onlyChinese and '关闭' or CLOSE,
        OnShow = function(self, web)
            local edit= self.editBox or self:GetEditBox()
            edit:SetScript("OnKeyUp", function(s, key)
                if IsControlKeyDown() and key == "C" then
                    print(
                        WoWTools_TooltipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r',
                        s:GetText()
                    )
                    s:GetParent():Hide()
                end
            end)
            edit:SetScript('OnCursorChanged', function(s)
                if s:GetText()~=web then
                    s:SetText(web)
                end
                --s:HighlightText()
            end)
            edit:SetMaxLetters(0)
            edit:SetFocus()
        end,
        OnHide= function(self)
            local edit= self.editBox or self:GetEditBox()
            edit:SetScript("OnKeyUp", nil)
            edit:SetScript("OnCursorChanged", nil)
            edit:SetText("")
            edit:ClearFocus()
        end,
        EditBoxOnTextChanged= function (self, web)
            self:SetText(web)
            self:HighlightText()
        end,
        EditBoxOnEnterPressed = function(self)
            self:ClearFocus()
            self:GetParent():Hide()
        end,
        EditBoxOnEscapePressed = function(self)
            self:ClearFocus()
            self:GetParent():Hide()
        end,
        hasEditBox = true,
        editBoxWidth = 320,
        timeout = 0,
        whileDead=true, hideOnEscape=true, exclusive=true,
    }






    StaticPopupDialogs['WoWTools_Currency']= {
        text='|n|n|n',
        hasEditBox=true,
        button1= WoWTools_DataMixin.onlyChinese and '添加' or ADD,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnShow=function(self, data)
            local edit= self.editBox or self:GetEditBox()
            edit:SetNumeric(true)
            edit:SetNumber(data.GetValue() or 0)
        end,
        OnHide= function(s)
            local edit= s.editBox or s:GetEditBox()
            edit:SetNumeric(false)
            edit:ClearFocus()
        end,
        OnAccept= function(self, data)
            local edit= self.editBox or self:GetEditBox()
            local currencyID= edit:GetNumber()
            if currencyID and currencyID>0 then
                data.SetValue(currencyID)
            end
        end,
        EditBoxOnTextChanged=function(self, data)
            local p= self:GetParent()
            local b1= p.button1 or p:GetButton1()
            local currencyID= self:GetNumber()
            local name, info, text, icon
            if currencyID>0 and currencyID<214748364 then
                name, info=WoWTools_CurrencyMixin:GetName(currencyID, nil, nil)
                text=(WoWTools_DataMixin.onlyChinese and '货币' or TOKENS)
                if info and name then
                    text= text..'|n|n'..name
                    icon=info.iconFileID
                end
                data.CheckValue(b1, currencyID)
            end
            p.text:SetText(text)
            b1:SetEnabled(name and info)
            p.AlertIcon:SetTexture(icon or 0)
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true,
    }




    Init=function()end
end









--[[
local product = self:GetSelectedProduct();
local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(product.itemID);
local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
local markup = CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 16, 16, 0, 1, 0, 1);

local data = {};
data.product = product;
data.link = itemLink;
data.name = product.name;
data.color = {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()};
data.texture = itemTexture;
StaticPopup_Show("PERKS_PROGRAM_CONFIRM_PURCHASE", product.price, markup, data);
]]



EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", function(owner)
    Init()
    EventRegistry:UnregisterCallback('PLAYER_LOGIN', owner)
end)