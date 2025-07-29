--显示服务器名称
local Label





local function Init_Label()
    local frame= CreateFrame("Frame", nil, PaperDollItemsFrame)
    frame:SetSize(1,1)
    frame:SetPoint('LEFT', CharacterFrame.TitleContainer, 22,0)
    frame:SetFrameStrata(CharacterFrame.TitleContainer:GetFrameStrata())
    frame:SetFrameLevel(CharacterFrame.TitleContainer:GetFrameLevel()+1)


    Label= WoWTools_LabelMixin:Create(frame, {
        name='WoWToolsServerInfoText',
        color= GameLimitedMode_IsActive() and {r=0,g=1,b=1} or {r=1,g=1,b=1},
        mouse=true,
    })

    Label:SetPoint('LEFT')
    --Label:SetAlpha(1)

    Label:SetScript("OnLeave",function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    Label:SetScript("OnEnter",function(self)
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
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '等级' or LEVEL, rLevel, 1,0,0, 1,0,0)
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '钱' or MONEY, GetMoneyString(rMoney), 1,0,0, 1,0,0)
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION, profCap, 1,0,0, 1,0,0)

        end

        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
end








local function Settings()
    local ser=GetAutoCompleteRealms() or {}

    local server= WoWTools_RealmMixin:Get_Region(WoWTools_DataMixin.Player.Realm, nil, nil)

    local num= #ser

    local text= (num>1 and '|cnGREEN_FONT_COLOR:'..num..'|r ' or '')
            ..WoWTools_DataMixin.Player.Realm
            ..(server and ' '..server.col or '')

    Label:SetText(text or '')
end










--显示服务器名称
function WoWTools_PaperDollMixin:Init_ServerInfo()
    Init_Label()
    Settings()
end


function WoWTools_PaperDollMixin:Settings_ServerInfo()
    if WoWToolsSave['Plus_PaperDoll'].hide then
        Label:SetText('')
    else
        Settings()
    end
end