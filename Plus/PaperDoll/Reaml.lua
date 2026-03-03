--显示服务器名称
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end





local function Init()
    if Save().notRealm then
        return
    end


    local wow= CreateFrame("Button", 'WoWToolsPaperDollWoWButton', PaperDollItemsFrame, 'WoWToolsButtonTemplate')
    wow:SetPoint('LEFT', CharacterFrame.TitleContainer, -5, 0)
    wow:SetFrameStrata(CharacterFrame.TitleContainer:GetFrameStrata())
    wow:SetFrameLevel(CharacterFrame.TitleContainer:GetFrameLevel()+1)
    wow:SetSize(20, 20)
    wow:SetNormalTexture(1120721)
    WoWTools_ButtonMixin:AddMask(wow, true, wow:GetNormalTexture())
    wow.itemID= 122284
    wow:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Frame(self)
    end)
    wow:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:OpenWoWItemListFrame('Item')--战团，物品列表
    end)
    wow.text= wow:CreateFontString('WoWToolsPaperDollRealmLabel', 'ARTWORK', 'WoWToolsFont2')
    wow.text:SetPoint("BOTTOMRIGHT", -1, 1)
    WoWTools_ColorMixin:SetLabelColor(wow.text)
    function wow:settings()
        local count= WoWTools_ItemMixin:GetWoWCount(122284, nil, true)
        wow.text:SetText(
            (count>0 and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup())
            ..count
        )
    end
    wow:SetScript('OnShow', wow.settings)
    wow:settings()





    local btn= CreateFrame("Button", 'WoWToolsPaperDollRealmButton', wow, 'WoWToolsButtonTemplate')
    btn:SetSize(32,16)
    WoWTools_TextureMixin:GetWoWLog(GetClampedCurrentExpansionLevel(), btn)
    btn:SetPoint('LEFT', wow, 'RIGHT')

    function btn:tooltip()
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
        local client= GetClientDisplayExpansionLevel()
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '版本' or GAME_VERSION_LABEL,
            client..' '..(WoWTools_TextureMixin:GetWoWLog(client) or '')..WoWTools_TextMixin:CN(_G['EXPANSION_NAME'..client]),
            nil,nil,nil, 1,1,1
        )
        if curExp~=client then
            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT ,
                curExp..' '..(WoWTools_TextureMixin:GetWoWLog(curExp) or '')..WoWTools_TextMixin:CN(_G['EXPANSION_NAME'..curExp]),
                1,0,0, 1,0,0
            )
        end

        if GameLimitedMode_IsActive() then
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
    end











    btn.text= btn:CreateFontString('WoWToolsPaperDollRealmLabel', 'ARTWORK', 'WoWToolsFont')
    btn.text:SetPoint('LEFT', btn, 'RIGHT')
    WoWTools_ColorMixin:SetLabelColor(btn.text)
    local ser= GetAutoCompleteRealms() or {}
    local server= WoWTools_RealmMixin:Get_Region(WoWTools_DataMixin.Player.Realm, nil, nil)
    local num= #ser
    btn.text:SetText(
        (GameLimitedMode_IsActive() and '|cnWARNING_FONT_COLOR:' or '')
        ..(num>1 and num..' ' or '')
        ..WoWTools_DataMixin.Player.Realm
        ..(server and ' '..server.col or '')
    )
















    Init=function()
        _G['WoWToolsPaperDollWoWButton']:SetShown(not Save().notRealm)
    end
end















--显示服务器名称
function WoWTools_PaperDollMixin:Init_Reaml()
    Init()
end