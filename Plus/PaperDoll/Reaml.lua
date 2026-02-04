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
            server and server.col..' '..server.realm or WoWTools_DataMixin.Player.Realm,
            nil,nil,nil, 1,1,1
        )

        GameTooltip:AddLine(' ')
        local ok2
        for k, v in pairs(GetAutoCompleteRealms() or {}) do
            if v==WoWTools_DataMixin.Player.Realm then
                GameTooltip:AddDoubleLine(v..'|A:auctionhouse-icon-favorite:0:0|a', k, 0,1,0, 0,1,0)
            else
                GameTooltip:AddDoubleLine(v, k, nil,nil,nil, 1,1,1)
            end
            ok2=true
        end
        if not ok2 then
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '唯一' or ITEM_UNIQUE, WoWTools_DataMixin.Player.Realm, 0,1,0, 0,1,0)
        end

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('realmID', GetRealmID(), nil,nil,nil, 1,1,1)
        GameTooltip:AddDoubleLine('regionID |cffffffff',  WoWTools_DataMixin.Player.Region..' '..GetCurrentRegionName(), nil,nil,nil, 1,1,1)

        local curExp= GetExpansionLevel()
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '扩展' or 'Expansion',
            curExp..' '..(WoWTools_TextureMixin:GetWoWLog(curExp) or '')..WoWTools_TextMixin:CN(_G['EXPANSION_NAME'..curExp]),
            nil,nil,nil, 1,1,1
        )


        --BAG_FILTER_CURRENT_EXPANSION = "仅限当前内容";

        if GameLimitedMode_IsActive() then
            GameTooltip:AddLine(' ')
            local rLevel, rMoney, profCap = GetRestrictedAccountData()
            GameTooltip_AddErrorLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '受限制' or CHAT_MSG_RESTRICTED)

            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '等级' or LEVEL,
                rLevel,
                1,0,0, 1,1,1
            )
            if rMoney then
                GameTooltip:AddDoubleLine(
                    WoWTools_DataMixin.onlyChinese and '钱' or MONEY,
                    GetMoneyString(rMoney),
                    1,0,0, 1,1,1
                )
            end

            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION,
                profCap,
                1,0,0, 1,1,1
            )

        end

        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)


    local ser= GetAutoCompleteRealms() or {}
    local server= WoWTools_RealmMixin:Get_Region(WoWTools_DataMixin.Player.Realm, nil, nil)
    local num= #ser
    frame.text:SetText(
        (GameLimitedMode_IsActive() and '|cnWARNING_FONT_COLOR:' or '')
        ..(num>1 and num..' ' or '')
        ..WoWTools_DataMixin.Player.Realm
        ..(server and ' '..server.col or '')
    )


    frame.texture= frame:CreateTexture(nil, 'ARTWORK')
    frame.texture:SetPoint('LEFT', frame.text, 'RIGHT', 2, 0)
    frame.texture:SetSize(16,16)
    frame.texture:EnableMouse(true)
    frame.texture:SetTexture(1120721)
    frame.texture.itemID= 122284
    frame.texture:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)

    frame.texture:SetScript("OnEnter",function(self)
        WoWTools_SetTooltipMixin:Frame(self)
        self:SetAlpha(0.3)
    end)

    frame.text2= frame:CreateFontString('WoWToolsPaperDollRealmLabel', 'ARTWORK', 'GameFontNormal')
    frame.text2:SetPoint('LEFT', frame.texture, 'RIGHT', 2, 0)
    WoWTools_ColorMixin:SetLabelColor(frame.text2)


    function frame:settings()
        local all, numPlayer= WoWTools_ItemMixin:GetWoWCount(122284)
        frame.text2:SetText(all..(numPlayer>1 and '('..numPlayer..')' or ''))
    end

    frame:SetScript('OnShow', frame.settings)

    frame:settings()

    Init=function()
        _G['WoWToolsPaperDollRealmFrame']:SetShown(not Save().notRealm)
    end
end















--显示服务器名称
function WoWTools_PaperDollMixin:Init_Reaml()
    Init()
end