
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
        local iconWidth = MONEY_ICON_WIDTH;
        local spacing = MONEY_BUTTON_SPACING;
        if frame.small then
            iconWidth = MONEY_ICON_WIDTH_SMALL;
            spacing = MONEY_BUTTON_SPACING_SMALL;
        end

        if frame.userScaledTextScale then
            iconWidth = iconWidth * frame.userScaledTextScale;
            spacing = spacing * frame.userScaledTextScale;
        end

        return iconWidth, spacing;
    end

    WoWTools_DataMixin:Hook('MoneyFrame_Update', function(frameName, money)
        local gold = money and floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD)) or 0
        local frame = gold>=1000 and GetMoneyFrame(frameName)
        if frame then
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
        WoWToolsSave['Other_MoneyFrame']= WoWToolsSave['Other_MoneyFrame'] or {disabled= not (LOCALE_zhCN and WoWTools_DataMixin.Player.husandro) and true or nil}

        --添加控制面板
        WoWTools_PanelMixin:OnlyCheck({
            name= '|A:auctionhouse-icon-coin-gold:0:0|a'..(WoWTools_DataMixin.onlyChinese and '钱' or MONEY)..' mk',
            Value= not WoWToolsSave['Other_MoneyFrame'].disabled,
            GetValue=function() return not WoWToolsSave['Other_MoneyFrame'].disabled end,
            SetValue= function()
                WoWToolsSave['Other_MoneyFrame'].disabled= not WoWToolsSave['Other_MoneyFrame'].disabled and true or nil
                Init()
            end,
            tooltip=WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
            layout= WoWTools_OtherMixin.Layout,
            category= WoWTools_OtherMixin.Category,
        })

        if not WoWToolsSave['Other_MoneyFrame'].disabled then
            Init()
        end
        self:UnregisterEvent(event)
        self:SetScript('OnEvent', nil)
    end
end)