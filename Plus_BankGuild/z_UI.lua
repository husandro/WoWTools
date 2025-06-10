local function Init(self)
    GuildBankFrame.Emblem.Left:Hide()
    GuildBankFrame.Emblem.Right:Hide()

    self:SetAlphaColor(GuildBankFrame.TopLeftCorner, nil, nil, true)
    self:SetAlphaColor(GuildBankFrame.TopRightCorner, nil, nil, true)
    self:SetAlphaColor(GuildBankFrame.BotLeftCorner, nil, nil, true)
    self:SetAlphaColor(GuildBankFrame.BotRightCorner, nil, nil, true)

    self:SetAlphaColor(GuildBankFrame.LeftBorder, nil, nil, true)
    self:SetAlphaColor(GuildBankFrame.RightBorder, nil, nil, true)
    self:SetAlphaColor(GuildBankFrame.TopBorder, nil, nil, true)
    self:SetAlphaColor(GuildBankFrame.BottomBorder, nil, nil, true)

    GuildBankFrame.BlackBG:ClearAllPoints()
    GuildBankFrame.BlackBG:SetAllPoints()

    self:HideTexture(GuildBankFrame.TitleBg)
    self:HideTexture(GuildBankFrame.RedMarbleBG)
    GuildBankFrame.MoneyFrameBG:DisableDrawLayer('BACKGROUND')



    self:HideTexture(GuildBankFrameBottomOuter)
    self:HideTexture(GuildBankFrameTopOuter)
    self:HideTexture(GuildBankFrameLeftOuter)
    self:HideTexture(GuildBankFrameRightOuter)

    self:HideTexture(GuildBankFrameBottomLeftOuter)
    self:HideTexture(GuildBankFrameBottomRightOuter)
    self:HideTexture(GuildBankFrameTopLeftOuter)
    self:HideTexture(GuildBankFrameTopRightOuter)

    self:HideTexture(GuildBankFrameLeftInner)
    self:HideTexture(GuildBankFrameRightInner)
    self:HideTexture(GuildBankFrameTopInner)
    self:HideTexture(GuildBankFrameBottomInner)

    self:HideTexture(GuildBankFrameBottomLeftInner)
    self:HideTexture(GuildBankFrameBottomRightInner)
    self:HideTexture(GuildBankFrameTopLeftInner)
    self:HideTexture(GuildBankFrameTopRightInner)

    self:HideTexture(GuildBankFrame.TabLimitBG)
    self:HideTexture(GuildBankFrame.TabLimitBGLeft)
    self:HideTexture(GuildBankFrame.TabLimitBGRight)
    self:SetEditBox(GuildItemSearchBox)

    self:HideTexture(GuildBankFrame.TabTitleBG)
    self:HideTexture(GuildBankFrame.TabTitleBGLeft)
    self:HideTexture(GuildBankFrame.TabTitleBGRight)

    for i=1, 7 do
        local frame= GuildBankFrame['Column'..i]
        if frame then
            self:HideTexture(frame.Background)
        end
        self:SetFrame(_G['GuildBankFrameTab'..i], {notAlpha=true})
    end


    self:SetScrollBar(GuildBankFrame.Log)
    self:SetScrollBar(GuildBankInfoScrollFrame)


    for i=1, MAX_GUILDBANK_TABS do
		local btn= GuildBankFrame.BankTabs[i].Button
        btn.NormalTexture:SetTexture(0)

        btn= _G['GuildBankTab'..i]
        if btn then
            self:SetFrame(btn, {alpha=0})
        end
    end

    self:Init_BGMenu_Frame(GuildBankFrame, {enabled=true,
        isNewButton=true,
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', GuildBankFrame.CloseButton, 'LEFT', -48, 0)
        end,
        settings=function(texture)
            GuildBankFrame.BlackBG:SetShown(not texture)
        end
    })

    Init=function()end
end


function WoWTools_TextureMixin.Events:Blizzard_GuildBankUI()--成就
    Init(self)
end
function WoWTools_GuildBankMixin:Init_UI()
    Init(WoWTools_TextureMixin)
end