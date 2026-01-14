
--更改, 金, mk
local function Init()

    local function GetMoneyFrame(frameOrName)
        local argType = type(frameOrName);
        if argType == "table" then
            return frameOrName;
        elseif argType == "string" then
            return _G[frameOrName];
        end
        return nil
    end
    local function MoneyFrame_GetIconSizeData(frame)
        local iconWidth = MONEY_ICON_WIDTH or 19
        local spacing = MONEY_BUTTON_SPACING or -4
        if frame.small then
            iconWidth = MONEY_ICON_WIDTH_SMALL or 13
            spacing = MONEY_BUTTON_SPACING_SMALL or -4
        end

        if frame.userScaledTextScale then
            iconWidth = iconWidth * frame.userScaledTextScale;
            spacing = spacing * frame.userScaledTextScale;
        end

        return iconWidth, spacing;
    end

    WoWTools_DataMixin:Hook('MoneyFrame_Update', function(frameName, money)
        if not canaccessvalue(money)
            or not money
            or not canaccessvalue(frameName)
            or not frameName
        then
            return
        end

        local gold = money and floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD)) or 0
        local frame = gold>=1000 and GetMoneyFrame(frameName)
        if frame and not frame:GetParent():HasAnySecretAspect() then
            local goldButton = frame.GoldButton

            local bit= gold<1e4 and 3 or gold<1e8 and 4 or 5
            local goldText= WoWTools_DataMixin:MK(gold, bit)
            if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") then
                goldButton:SetText(goldText..(WoWTools_DataMixin.onlyChinese and '金' or GOLD_AMOUNT_SYMBOL))
                goldButton:SetWidth(goldButton:GetTextWidth())
            else
                goldButton:SetText(goldText)
                local iconWidth= MoneyFrame_GetIconSizeData(frame)
                goldButton:SetWidth(goldButton:GetTextWidth()+iconWidth)
            end
            frame:SetWidth(
                goldButton:GetWidth()+12
                +(frame.SilverButton:IsShown() and frame.SilverButton:GetWidth() or 0)
                +(frame.CopperButton:IsShown() and frame.CopperButton:GetWidth() or 0)
            )
        end
    end)

    Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWTools' then
        if WoWTools_OtherMixin:AddOption(
            'MoneyFrame',
            '|A:auctionhouse-icon-coin-gold:0:0|a'..(WoWTools_DataMixin.onlyChinese and '钱' or MONEY)..' mk',
            nil
        ) then
            Init()
        end

        Init=function()end

        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)
