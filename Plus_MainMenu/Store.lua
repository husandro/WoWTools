








--商店
local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(StoreMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text:SetPoint('TOP', StoreMicroButton, 0,  -3)

    frame.Text2= WoWTools_LabelMixin:Create(StoreMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text2:SetPoint('BOTTOM', StoreMicroButton, 0, 3)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text2)

    StoreMicroButton.Text2= frame.Text2

    function frame:settings()
        local text
        local price= C_WowTokenPublic.GetCurrentMarketPrice() or 0
        if price>0 then
            text= WoWTools_Mixin:MK(price/10000, 0)
        end
        self.Text:SetText(text or '')
    end
    frame:RegisterEvent('TOKEN_MARKET_PRICE_UPDATED')
    frame:SetScript('OnEvent', frame.settings)
    C_WowTokenPublic.UpdateMarketPrice()
    C_Timer.After(2, function() frame:settings() end)

    StoreMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('|A:token-choice-wow:0:0|a'..WoWTools_Mixin:MK(price/10000,4), C_CurrencyInfo.GetCoinTextureString(price) )
            GameTooltip:AddLine(' ')
        end
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for guid, info in pairs(WoWTools_WoWDate or {}) do
            local tab=info.Item[122284]
            if tab and guid then
                GameTooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), '|A:Banker:0:0|a'..(tab.bank==0 and '|cff9e9e9e'..tab.bank..'|r' or tab.bank)..' '..'|A:bag-main:0:0|a'..(tab.bag==0 and '|cff9e9e9e'..tab.bag..'|r' or tab.bag))
                bagAll=bagAll +tab.bag
                bankAll=bankAll +tab.bank
                numPlayer=numPlayer +1
            end
        end

        local all= bagAll+ bankAll
        GameTooltip:AddDoubleLine('|A:groupfinder-waitdot:0:0|a'..numPlayer, '|T1120721:0|t'..all)

        --AccountStoreFrame WOWLABS_BINDING_HEADER 
        --Constants.MajorFactionsConsts.PLUNDERSTORM_MAJOR_FACTION_ID
        if AccountStoreFrame then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(
                (C_AccountStore.GetStoreFrontState(Constants.AccountStoreConsts.PlunderstormStoreFrontID) ~= Enum.AccountStoreState.Available and '|cff828282'
                    or (UnitAffectingCombat('player') and '|cnRED_FONT_COLOR:')
                    or '|cffffffff'
                )
                ..(WoWTools_Mixin.onlyChinese and '霸业商店' or PLUNDERSTORM_PLUNDER_STORE_TITLE)..'|r'
                ..WoWTools_DataMixin.Icon.mid,

                WoWTools_CurrencyMixin:GetName(
                    C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID) or 3139, nil, nil
                )
            )
        end

        GameTooltip:Show()

        self.Text2:SetText(all>0 and all or '')
    end)


    StoreMicroButton:EnableMouseWheel(true)
    StoreMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() or not AccountStoreFrame then
            return
        end
        if AccountStoreFrame and not AccountStoreFrame:IsShown() then
            AccountStoreUtil.ToggleAccountStore()
        end
    end)




    local all=0
    for guid, info in pairs(WoWTools_WoWDate or {}) do
        local tab=info.Item[122284]
        if tab and guid then
            GameTooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), '|A:Banker:0:0|a'..(tab.bank==0 and '|cff9e9e9e'..tab.bank..'|r' or tab.bank)..' '..'|A:bag-main:0:0|a'..(tab.bag==0 and '|cff9e9e9e'..tab.bag..'|r' or tab.bag))
            all= all +tab.bag +tab.bank
        end
    end
    if all>0 then
        frame.Text2:SetText(all)
    end


end







function WoWTools_MainMenuMixin:Init_Store()--商店
    Init()
end