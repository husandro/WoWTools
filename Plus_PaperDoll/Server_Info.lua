--显示服务器名称
local e= select(2, ...)
local Label





local function Init_Label()
    local frame= CreateFrame("Frame", nil, PaperDollItemsFrame)
    frame:SetSize(1,1)
    frame:SetPoint('LEFT', CharacterFrame.TitleContainer, 22,0)
    frame:SetFrameStrata(CharacterFrame.TitleContainer:GetFrameStrata())
    frame:SetFrameLevel(CharacterFrame.TitleContainer:GetFrameLevel()+1)


    Label= WoWTools_LabelMixin:Create(frame, {
        color= GameLimitedMode_IsActive() and {r=0,g=1,b=1} or {r=1,g=1,b=1},
        mouse=true,
    })

    Label:SetPoint('LEFT')
    Label:SetAlpha(1)

    Label:SetScript("OnLeave",function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    Label:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_PaperDollMixin.addName)
        GameTooltip:AddLine(' ')
        local server= e.Get_Region(e.Player.realm, nil, nil)--服务器，EU， US {col=, text=, realm=}
        GameTooltip:AddDoubleLine(e.onlyChinese and '服务器:' or FRIENDS_LIST_REALM, server and server.col..' '..server.realm)
        local ok2
        for k, v in pairs(GetAutoCompleteRealms()) do
            if v==e.Player.realm then
                GameTooltip:AddDoubleLine(v..'|A:auctionhouse-icon-favorite:0:0|a', k, 0,1,0)
            else
                GameTooltip:AddDoubleLine(v, k)
            end
            ok2=true
        end
        if not ok2 then
            GameTooltip:AddDoubleLine(e.onlyChinese and '唯一' or ITEM_UNIQUE, e.Player.realm)
        end

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('realmID', GetRealmID())
        GameTooltip:AddDoubleLine('regionID: '..e.Player.region,  GetCurrentRegionName())

        GameTooltip:AddLine(' ')
        if GameLimitedMode_IsActive() then
            local rLevel, rMoney, profCap = GetRestrictedAccountData()
            GameTooltip:AddLine(e.onlyChinese and '受限制' or CHAT_MSG_RESTRICTED, 1,0,0)
            GameTooltip:AddDoubleLine(e.onlyChinese and '等级' or LEVEL, rLevel, 1,0,0, 1,0,0)
            GameTooltip:AddDoubleLine(e.onlyChinese and '钱' or MONEY, GetMoneyString(rMoney), 1,0,0, 1,0,0)
            GameTooltip:AddDoubleLine(e.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION, profCap, 1,0,0, 1,0,0)

        end

        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
end








local function Settings()
    local ser=GetAutoCompleteRealms() or {}
    local server= e.Get_Region(e.Player.realm, nil, nil)
    local num= #ser
    local text= (num>1 and '|cnGREEN_FONT_COLOR:'..num..'|r ' or '')
            ..e.Player.realm..(server and ' '..server.col or '')
    Label:SetText(text or '')
end










--显示服务器名称
function WoWTools_PaperDollMixin:Init_ServerInfo()
    Init_Label()
    Settings()
end


function WoWTools_PaperDollMixin:Settings_ServerInfo()
    if WoWTools_PaperDollMixin.Save.hide then
        Label:SetText('')
    else
        Settings()
    end
end