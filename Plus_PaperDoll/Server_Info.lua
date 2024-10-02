--显示服务器名称
local e= select(2, ...)
local Label





local function Create_Label()
    Label= WoWTools_LabelMixin:CreateLabel(PaperDollItemsFrame.ShowHideButton, {color= GameLimitedMode_IsActive() and {r=0,g=1,b=0} or true, mouse=true, justifyH='RIGHT'})--显示服务器名称
    Label:SetPoint('LEFT', PaperDollItemsFrame.ShowHideButton, 'RIGHT',2,0)
    Label:SetScript("OnLeave",function(self) e.tips:Hide() self:GetParent():set_alpha(false) end)
    Label:SetScript("OnEnter",function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local server= e.Get_Region(e.Player.realm, nil, nil)--服务器，EU， US {col=, text=, realm=}
        e.tips:AddDoubleLine(e.onlyChinese and '服务器:' or FRIENDS_LIST_REALM, server and server.col..' '..server.realm)
        local ok2
        for k, v in pairs(GetAutoCompleteRealms()) do
            if v==e.Player.realm then
                e.tips:AddDoubleLine(v..'|A:auctionhouse-icon-favorite:0:0|a', k, 0,1,0)
            else
                e.tips:AddDoubleLine(v, k)
            end
            ok2=true
        end
        if not ok2 then
            e.tips:AddDoubleLine(e.onlyChinese and '唯一' or ITEM_UNIQUE, e.Player.realm)
        end

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('realmID', GetRealmID())
        e.tips:AddDoubleLine('regionID: '..e.Player.region,  GetCurrentRegionName())

        e.tips:AddLine(' ')
        if GameLimitedMode_IsActive() then
            local rLevel, rMoney, profCap = GetRestrictedAccountData()
            e.tips:AddLine(e.onlyChinese and '受限制' or CHAT_MSG_RESTRICTED, 1,0,0)
            e.tips:AddDoubleLine(e.onlyChinese and '等级' or LEVEL, rLevel, 1,0,0, 1,0,0)
            e.tips:AddDoubleLine(e.onlyChinese and '钱' or MONEY, GetMoneyString(rMoney), 1,0,0, 1,0,0)
            e.tips:AddDoubleLine(e.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION, profCap, 1,0,0, 1,0,0)
            e.tips:AddLine(' ')
        end
        e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
        e.tips:Show()
        self:GetParent():set_alpha(true)
    end)
end








local function Init()
    if WoWTools_PaperDollMixin.Save.hide then
        if  Label then
            Label:SetText('')
        end
        return
    end

    if not Label then
        Create_Label()
    end

    local ser=GetAutoCompleteRealms() or {}
    local server= e.Get_Region(e.Player.realm, nil, nil)
    local text= (#ser>1 and '|cnGREEN_FONT_COLOR:'..#ser..' ' or '')..e.Player.col..e.Player.realm..'|r'..(server and ' '..server.col or '')
    Label:SetText(text or '')
end










--显示服务器名称
function WoWTools_PaperDollMixin:Set_Server_Info()
    Init()
end