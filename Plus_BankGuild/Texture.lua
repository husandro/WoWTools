local e= select(2, ...)


local function Init()

    GuildBankFrame.Emblem.Left:Hide()
    GuildBankFrame.Emblem.Right:Hide()

    local mixin= WoWTools_TextureMixin

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

    mixin:HideTexture(GuildBankFrame.TitleBg)
    mixin:HideTexture(GuildBankFrame.RedMarbleBG)
    GuildBankFrame.MoneyFrameBG:DisableDrawLayer('BACKGROUND')



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
end














function WoWTools_GuildBankMixin:Init_Guild_Texture()
    Init()
end
