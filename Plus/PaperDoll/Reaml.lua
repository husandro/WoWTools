--显示服务器名称
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end





local function Init()
    if Save().notRealm then
        return
    end

    local frame= CreateFrame("Frame", 'WoWToolsPaperDollRealmFrame', PaperDollItemsFrame)
    frame:SetSize(1,1)
    frame:SetPoint('LEFT', CharacterFrame.TitleContainer, 2, 0)
    frame:SetFrameStrata(CharacterFrame.TitleContainer:GetFrameStrata())
    frame:SetFrameLevel(CharacterFrame.TitleContainer:GetFrameLevel()+1)

    frame.text= frame:CreateFontString('WoWToolsPaperDollRealmLabel', 'ARTWORK', 'GameFontNormal')
    frame.text:SetPoint('LEFT')
    frame.text:EnableMouse(true)
    WoWTools_ColorMixin:SetLabelColor(frame.text)





    frame.text:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)

    frame.text:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        local server= WoWTools_RealmMixin:Get_Region(WoWTools_DataMixin.Player.Realm, nil, nil)--服务器，EU， US {col=, text=, realm=}
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '服务器:' or FRIENDS_LIST_REALM),
            server and server.col..' '..server.realm
        )

        local ok2
        for k, v in pairs(GetAutoCompleteRealms()) do
            if v==WoWTools_DataMixin.Player.Realm then
                GameTooltip:AddDoubleLine(v..'|A:auctionhouse-icon-favorite:0:0|a', k, 0,1,0)
            else
                GameTooltip:AddDoubleLine(v, k)
            end
            ok2=true
        end
        if not ok2 then
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '唯一' or ITEM_UNIQUE, WoWTools_DataMixin.Player.Realm)
        end

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('realmID', GetRealmID())
        GameTooltip:AddDoubleLine('regionID '..WoWTools_DataMixin.Player.Region,  GetCurrentRegionName())


        if GameLimitedMode_IsActive() then
            GameTooltip:AddLine(' ')
            local rLevel, rMoney, profCap = GetRestrictedAccountData()
            GameTooltip_AddErrorLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '受限制' or CHAT_MSG_RESTRICTED)
            GameTooltip_AddErrorLine(
                GameTooltip,
                (WoWTools_DataMixin.onlyChinese and '等级' or LEVEL)..' |cffffffff'..(rLevel or '')
            )
            GameTooltip_AddErrorLine(
                GameTooltip,
                (WoWTools_DataMixin.onlyChinese and '钱' or MONEY)..' |cffffffff'..(rMoney and GetMoneyString(rMoney) or '')
            )
            GameTooltip_AddErrorLine(
                GameTooltip,
                (WoWTools_DataMixin.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION)..' |cffffffff'..(profCap or '')
            )
        end
        
        GameTooltip:AddLine(' ')

        C_WowTokenPublic.UpdateMarketPrice()

        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            GameTooltip:AddDoubleLine('|A:token-choice-wow:0:0|a'..WoWTools_DataMixin:MK(price/10000,4), C_CurrencyInfo.GetCoinTextureString(price))
        end

        GameTooltip:AddLine(WoWTools_ItemMixin:GetName(122284))

        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
--[[
C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('|A:token-choice-wow:0:0|a'..WoWTools_DataMixin:MK(price/10000,4), C_CurrencyInfo.GetCoinTextureString(price) )
            GameTooltip:AddLine(' ')
        end
        local bagAll,bankAll,numPlayer= 0,0,0--帐号数据
        for guid, info in pairs(WoWTools_WoWDate or {}) do
            local tab=info.Item[122284]
            if tab and guid then
                GameTooltip:AddDoubleLine(
                    WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=info.faction, reName=true, reRealm=true}),

                    '|A:Banker:0:0|a'..(tab.bank==0 and '|cff626262'..tab.bank..'|r' or tab.bank)
                    ..' '
                    ..'|A:bag-main:0:0|a'..(tab.bag==0 and '|cff626262'..tab.bag..'|r' or tab.bag)
                )
                bagAll=bagAll +tab.bag
                bankAll=bankAll +tab.bank
                numPlayer=numPlayer +1
            end
        end

        local all= bagAll+ bankAll
        GameTooltip:AddDoubleLine('|A:groupfinder-waitdot:0:0|a'..numPlayer, '|T1120721:0|t'..all)
]]

    function frame:settings()
        local ser= GetAutoCompleteRealms() or {}
        local server= WoWTools_RealmMixin:Get_Region(WoWTools_DataMixin.Player.Realm, nil, nil)
        local num= #ser

        local all= WoWTools_ItemMixin:GetWoWCount(122284)

        frame.text:SetText(
            (GameLimitedMode_IsActive() and '|cnWARNING_FONT_COLOR:' or '')
            ..(num>1 and num..' ' or '')
            ..WoWTools_DataMixin.Player.Realm
            ..(server and ' '..server.col or '')
            ..'|A:shop-header-menu-iconShop:0:0:0:-2|a'
            ..all
        )
    end

    frame:settings()

    Init=function()
        _G['WoWToolsPaperDollRealmFrame']:SetShown(not Save().notRealm)
    end
end















--显示服务器名称
function WoWTools_PaperDollMixin:Init_Reaml()
    Init()
end