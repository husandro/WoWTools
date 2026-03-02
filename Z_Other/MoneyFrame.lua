
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

    WoWTools_DataMixin:Hook('MoneyFrame_Update', function(frameName, money)
        local frame= GetMoneyFrame(frameName)
        if not frame
            or (frame.HasAnySecretAspect and frame:GetParent():HasAnySecretAspect())
            or issecretvalue(money)
            or not money
        then
            return
        end

        local gold = money and floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD)) or 0

        if gold>=1000 then
            local goldButton = frame.GoldButton

            local bit= gold<1e4 and 3 or gold<1e8 and 4 or 5
            local goldText= WoWTools_DataMixin:MK(gold, bit)
            if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") then
                goldButton:SetText(goldText..(WoWTools_DataMixin.onlyChinese and '金' or GOLD_AMOUNT_SYMBOL))
            else
                goldButton:SetText(goldText)
            end
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
        else
            Init=function()end
        end

        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)
