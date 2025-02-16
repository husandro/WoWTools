--[[
WoWTools_RestData
WoWTools_EditText
WoWTools_Item
WoWTools_GetMapID
WoWTools_OK
]]



local id, e= ...

local function Get_UIMapIDs_Name(text)--从text取得uiMapID表
    local tab, reText={}, nil
    text:gsub('%d+', function(self)
        local uiMapID= tonumber(self)
        if uiMapID>0 and uiMapID< 2147483647 then
            local info= uiMapID and C_Map.GetMapInfo(uiMapID)
            if uiMapID and info and info.name and not tab[uiMapID] then--uiMapID<2147483647
                tab[uiMapID]=true
                reText= reText and reText..'|n' or ''
                reText= reText..uiMapID..' '..e.cn(info.name)
            end
        end
    end)
    return tab, reText
end







local function Init()




--重置, 数据
StaticPopupDialogs['WoWTools_RestData']= {
    text=WoWTools_Mixin.addName
        ..'|n|n%s|n|n|cnRED_FONT_COLOR:'
        ..(e.onlyChinese and "你想要将所有选项重置为默认状态吗？|n将会立即对所有设置生效。" or CONFIRM_RESET_SETTINGS)
        ..'|r|n|n',
    button1= e.onlyChinese and '重置' or RESET,
    button2= e.onlyChinese and '取消' or CANCEL,
    OnAccept=function(_, SetValue)
        SetValue()
    end,
    whileDead=true,
    hideOnEscape=true,
    exclusive=true,
    showAlert=true,
}
--StaticPopup_Show('WoWTools_RestData','aa', nil, function() print('c') end)











StaticPopupDialogs['WoWTools_EditText']={
    text=WoWTools_Mixin.addName..'|n|n%s|n',
    button1= e.onlyChinese and '修改' or EDIT,
    button2= e.onlyChinese and '取消' or CANCEL,
    button3= e.onlyChinese and '移除' or REMOVE,
    OnShow=function(self, data)
        self.editBox:SetAutoFocus(false)
        self.editBox:SetText(data.text or '')
        self.button3:SetShown(data.OnAlt and true or false)
        self.editBox:SetFocus(true)
        if data.OnShow then
            data.OnShow(self, data)
        end
    end,
    OnHide=function(self, data)
        if data.OnHide then
            data.OnHide(self, data)
        end
        self.editBox:SetText("")
        self.editBox:ClearFocus()
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
        if not self:IsVisible() then
            return
        end
        local text= self:GetText() or ''
        if data.EditBoxOnTextChanged then
            data.EditBoxOnTextChanged(self, data, text)
        end
        self:GetParent().button1:SetEnabled(text:gsub(' ', '')~='' and text~=data.text)
    end,
    EditBoxOnEscapePressed = function(self, data)
        local text=self:GetText()
        if data.text==text or text=='' then
            self:GetParent():Hide()
        end
    end,
    EditBoxOnEnterPressed = function(self, data)
        local parent = self:GetParent();
        if parent.button1:IsEnabled() then
            parent.data.SetValue(parent, data)
            parent:Hide();
        else
            self:ClearFocus()
        end
    end,
    hideOnEscape=true,
    hasEditBox=true,
    editBoxWidth=360,
}
--[[
StaticPopup_Show('WoWTools_EditText',
    (),
    nil,
    {
        text=,
        OnShow=function(s, data)
        end,
        SetValue= function(s)
        end,
        OnAlt=function(s, data)
        end,
        EditBoxOnTextChanged=function(s, data)
        end,
    }
)
]]







StaticPopupDialogs['WoWTools_Item'] = {
	text = WoWTools_Mixin.addName..'|n|n%s',
	button1 = e.onlyChinese and '添加' or ADD,
	button2 = e.onlyChinese and '取消' or CANCEL,
    button3 = e.onlyChinese and '移除' or REMOVE,
    OnShow=function(self, data)
        if data.OnShow then
            data.OnShow(self, data)
        end
        self.button3:SetShown(data.OnAlt and true or false)
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
    OnShow=function(self, data)
    end,
    SetValue = function(_, data)
    end,
    OnAlt = function(_, data)
    end
})
]]



StaticPopupDialogs['WoWTools_GetMapID'] = {--区域,设置对话框
        text=WoWTools_Mixin.addName..' '..(e.onlyChinese and '区域' or FLOOR)..'|n|n%s',
        button1=e.onlyChinese and '区域' or FLOOR,
        button2=e.onlyChinese and '取消' or CANCEL,
        button3=e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            self.editBox:SetAutoFocus(false)
            self.editBox:SetText(data.text or '')
            self.button3:SetShown(data.OnAlt and true or false)
            if data.OnShow then
                data.OnShow(self, data)
            end
            self.editBox:SetFocus()
        end,
        OnHide=function(self)
            self.editBox:SetText("")
            self.editBox:ClearFocus()
        end,
        OnAccept = function(self, data)
            local tab, text= Get_UIMapIDs_Name(self.editBox:GetText())
            data.SetValue(self, data, tab, text)
        end,
        OnAlt = function(self, data)
            if data.OnAlt then
                data.OnAlt(self, data)
            end
        end,
        EditBoxOnTextChanged=function(self, data)
            if not self:IsVisible() then
                return
            end
            local _, text= Get_UIMapIDs_Name(self:GetText())
            local frame= self:GetParent()
            local btn=frame.button1
            btn:SetEnabled((text and text~=data.text) and true or false)
            btn:SetText(text or (e.onlyChinese and '无' or NONE))
        end,
        EditBoxOnEscapePressed = function(self, data)
            local text=self:GetText()
            if data.text==text or text=='' then
                self:GetParent():Hide()
            end
        end,
        EditBoxOnEnterPressed = function(self, data)
            local p = self:GetParent();
            if p.button1:IsEnabled() then
                local tab, text= Get_UIMapIDs_Name(self.editBox:GetText())
                p.data.SetValue(p, data, tab, text)
                p:Hide();
            else
                self:ClearFocus()
            end
        end,
        hideOnEscape=true,
        hasEditBox=true,
        editBoxWidth=360,
       --hasItemFrame = true,
       -- showAlert=true,
    }





    StaticPopupDialogs['WoWTools_OK']={
        text =WoWTools_Mixin.addName..'|n|n%s',
        button1 = e.onlyChinese and '确定' or OKAY,
        button2 = e.onlyChinese and '取消' or CANCEL,
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
    }
--[[
StaticPopup_Show('WoWTools_OK',
    ,
    nil,
    {SetValue=function()
    end}
)
]]



    StaticPopupDialogs["WoWTools_Tooltips_LinkURL"] = {
        text= '|n|cffff00ff%s|r |cnGREEN_FONT_COLOR:Ctrl+C |r'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK),
        button1 = e.onlyChinese and '关闭' or CLOSE,
        OnShow = function(self, web)
            self.editBox:SetScript("OnKeyUp", function(s, key)
                if IsControlKeyDown() and key == "C" then
                    print(WoWTools_Mixin.addName, WoWTools_TooltipMixin.addName,
                            '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r',
                            s:GetText()
                        )
                    s:GetParent():Hide()
                end
            end)
            self.editBox:SetScript('OnCursorChanged', function(s)
                s:SetText(web)
                s:HighlightText()
            end)
            self.editBox:SetMaxLetters(0)
            self.editBox:SetWidth(self:GetWidth())
            self.editBox:SetFocus()
        end,
        OnHide= function(self)
            self.editBox:SetScript("OnKeyUp", nil)
            self.editBox:SetScript("OnCursorChanged", nil)
            self.editBox:SetText("")
            self.editBox:ClearFocus()
        end,
        EditBoxOnTextChanged= function (self, web)
            if not self:IsVisible() then
                return
            end
            self:SetText(web)
            self:HighlightText()
        end,
        EditBoxOnEnterPressed = function(self)
            local parent= self:GetParent()
            parent.button1:Click()
            parent:Hide()
        end,
        EditBoxOnEscapePressed = function(self2)
            self2:SetAutoFocus(false)
            self2:ClearFocus()
            self2:GetParent():Hide()
        end,
        hasEditBox = true,
        --editBoxWidth = 320,
        timeout = 0,
        whileDead=true, hideOnEscape=true, exclusive=true,
    }






    StaticPopupDialogs['WoWTools_Currency']= {
        text='|n|n|n',
        hasEditBox=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        OnShow=function(s, data)
            s.editBox:SetNumeric(true)
            s.editBox:SetNumber(data.GetValue() or 0)
        end,
        OnHide= function(s)
            s.editBox:ClearFocus()
        end,
        OnAccept= function(s, data)
            local currencyID= s.editBox:GetNumber()
            if currencyID and currencyID>0 then
                data.SetValue(currencyID)
            end
        end,
        EditBoxOnTextChanged=function(s, data)
            if not s:IsVisible() then
                return
            end
            local currencyID= s:GetNumber()
            local name, info, text, icon
            local p= s:GetParent()
            if currencyID>0 and currencyID<214748364 then
                name, info=WoWTools_CurrencyMixin:GetName(currencyID, nil, nil)
                text=(e.onlyChinese and '货币' or TOKENS)
                if info and name then
                    text= text..'|n|n'..name
                    icon=info.iconFileID
                end
                data.CheckValue(p.button1, currencyID)
            end
            p.text:SetText(text)
            p.button1:SetEnabled(name and info)
            p.AlertIcon:SetTexture(icon or 0)
        end,
        EditBoxOnEscapePressed = function(s)
            s:GetParent():Hide()
        end,
        whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true,
    }
    --[[
    StaticPopup_Show('WoWTools_Currency', nil, nil, {
    GetValue=function()
    end, CheckValue=function(button1, currencyID)
    end, SetValue=function(currencyID)
    end})
    ]]
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




local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Init()
        self:UnregisterEvent('ADDON_LOADED')
    end
end)