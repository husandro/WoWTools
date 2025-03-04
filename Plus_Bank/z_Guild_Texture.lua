local e= select(2, ...)


local function Init(mixin)
    --[[GuildBankFrame.Emblem:SetPoint('BOTTOMLEFT', GuildBankFrame, 'TOPLEFT')
    GuildBankFrame.Emblem:SetPoint('BOTTOMRIGHT', GuildBankFrame, 'TOPRIGHT')
    GuildBankFrame.Emblem.Left:SetPoint('TOPRIGHT', GuildBankFrame.Emblem, 'TOP')]]
    GuildBankFrame.Emblem.Left:Hide()
    GuildBankFrame.Emblem.Right:Hide()

    mixin= mixin or WoWTools_TextureMixin

    mixin:SetAlphaColor(GuildBankFrame.TopLeftCorner, nil, nil, true)
    mixin:SetAlphaColor(GuildBankFrame.TopRightCorner, nil, nil, true)
    mixin:SetAlphaColor(GuildBankFrame.BotLeftCorner, nil, nil, true)
    mixin:SetAlphaColor(GuildBankFrame.BotRightCorner, nil, nil, true)

    mixin:SetAlphaColor(GuildBankFrame.LeftBorder, nil, nil, true)
    mixin:SetAlphaColor(GuildBankFrame.RightBorder, nil, nil, true)
    mixin:SetAlphaColor(GuildBankFrame.TopBorder, nil, nil, true)
    mixin:SetAlphaColor(GuildBankFrame.BottomBorder, nil, nil, true)

    GuildBankFrame.BlackBG:ClearAllPoints()
    GuildBankFrame.BlackBG:SetAllPoints()
    mixin:SetAlphaColor(GuildBankFrame.BlackBG, nil, nil, true)

    mixin:HideTexture(GuildBankFrame.TitleBg)
    mixin:HideTexture(GuildBankFrame.RedMarbleBG)
    GuildBankFrame.MoneyFrameBG:DisableDrawLayer('BACKGROUND')

    GuildBankFrame.TabTitle:SetPoint('CENTER', GuildBankFrame.TabTitleBG, 0,8)

    mixin:HideTexture(GuildBankFrameBottomOuter)
    mixin:HideTexture(GuildBankFrameTopOuter)
    mixin:HideTexture(GuildBankFrameLeftOuter)
    mixin:HideTexture(GuildBankFrameRightOuter)

    mixin:HideTexture(GuildBankFrameBottomLeftOuter)
    mixin:HideTexture(GuildBankFrameBottomRightOuter)
    mixin:HideTexture(GuildBankFrameTopLeftOuter)
    mixin:HideTexture(GuildBankFrameTopRightOuter)
    
    mixin:HideTexture(GuildBankFrameLeftInner)
    mixin:HideTexture(GuildBankFrameRightInner)
    mixin:HideTexture(GuildBankFrameTopInner)
    mixin:HideTexture(GuildBankFrameBottomInner)

    mixin:HideTexture(GuildBankFrameBottomLeftInner)
    mixin:HideTexture(GuildBankFrameBottomRightInner)
    mixin:HideTexture(GuildBankFrameTopLeftInner)
    mixin:HideTexture(GuildBankFrameTopRightInner)

    mixin:HideTexture(GuildBankFrame.TabLimitBG)
    mixin:HideTexture(GuildBankFrame.TabLimitBGLeft)
    mixin:HideTexture(GuildBankFrame.TabLimitBGRight)
    mixin:SetSearchBox(GuildItemSearchBox)

    mixin:HideTexture(GuildBankFrame.TabTitleBG)
    mixin:HideTexture(GuildBankFrame.TabTitleBGLeft)
    mixin:HideTexture(GuildBankFrame.TabTitleBGRight)

    for i=1, 7 do
        local frame= GuildBankFrame['Column'..i]
        if frame then
            mixin:HideTexture(frame.Background)
        end
        mixin:SetFrame(_G['GuildBankFrameTab'..i], {notAlpha=true})
    end

    --[[local MAX_GUILDBANK_SLOTS_PER_TAB = 98;
    local NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
    hooksecurefunc(GuildBankFrame,'Update', function(self2)--Blizzard_GuildBankUI.lua
        if ( self2.mode == "bank" ) then
            local tab = GetCurrentGuildBankTab() or 1
            for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
                if ( index == 0 ) then
                    index = NUM_SLOTS_PER_GUILDBANK_GROUP;
                end
                local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
                local button = self2.Columns[column].Buttons[index];
                if button and button.NormalTexture then
                    local texture= GetGuildBankItemInfo(tab, i)
                    button.NormalTexture:SetAlpha(texture and 1 or 0.2)
                end
            end
        end
    end)]]

    mixin:SetScrollBar(GuildBankFrame.Log)
    mixin:SetScrollBar(GuildBankInfoScrollFrame)


    for i=1, MAX_GUILDBANK_TABS do
		local btn= GuildBankFrame.BankTabs[i].Button
        btn.NormalTexture:SetTexture(0)

        btn= _G['GuildBankTab'..i]
        if btn then
            WoWTools_TextureMixin:SetFrame(btn, {alpha=0})
        end
    end


--"%s的每日提取额度剩余：|cffffffff%s|r"
GuildBankFrame.LimitLabel:ClearAllPoints()
--GuildBankFrame.LimitLabel:SetPoint('BOTTOMLEFT', GuildBankFrame.Column1.Button1, 'TOPLEFT', 0, 4)
GuildBankFrame.LimitLabel:SetPoint('TOP', GuildBankFrame.TabTitle, 'BOTTOM', 0, -2)



    return true
end














function WoWTools_BankMixin:Init_Guild_Texture(mixin)
    if Init(mixin) then
        Init=function() end
    end
end
