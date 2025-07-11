
local function Save()
    return WoWToolsSave['Adventure_Journal']
end
local Button

















local function Get_Text()
    if Save().hideWorldBossText then
        return
    end
    local msg
    for guid, info in pairs(WoWTools_WoWDate or {}) do
        local text, numAll, find= nil, 0, nil
        for bossName, worldBossID in pairs(info.Worldboss.boss) do--世界BOSS
            numAll=numAll+1
            text= text and text ..' ' or '   '
            text= text..'|cnGREEN_FONT_COLOR:'..numAll..')|r'.. WoWTools_EncounterMixin:GetBossNameSort(bossName)
        end
        if text then
            msg= msg and msg..'|n' or ''
            msg= msg..text
            find= true
        end

        text, numAll= nil, 0
        for bossName, _ in pairs(info.Rare.boss) do--稀有怪
            numAll=numAll+1
            text= text and text ..' ' or '   '
            text= text..'|cnGREEN_FONT_COLOR:'..numAll..')|r'.. WoWTools_EncounterMixin:GetBossNameSort(bossName)
        end
        if text then
            msg= msg and msg..'|n' or ''
            msg= msg..text
            find= true
        end
        if find then
            msg= msg..'|n'..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=info.faction, reName=true, reRealm=true})
        end
    end
    msg= msg or '...'
    return msg
end








local function Create_WorldBoss_Button()
    local btn=WoWTools_ButtonMixin:Cbtn(nil, {name='WoWTools_EncounterWorldBossButton', size=14})
    btn:SetPoint('CENTER', -50, -100)
    WoWTools_MoveMixin:Setup(btn, {notZoom=true})

    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, WoWTools_DataMixin.onlyChinese and '世界BOSS和稀有怪'
            or format(COVENANT_RENOWN_TOAST_REWARD_COMBINER,
                    format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WORLD, 'BOSS')
                    ,GARRISON_MISSION_RARE
                )
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(not Save().hideWorldBossText), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or  NPE_MOVE, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE, (Save().EncounterJournalFontSize or 12)..WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
    end
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltip)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save().hideWorldBossText= not Save().hideWorldBossText and true or nil
            self.Text:SetShown(not Save().hideWorldBossText)
            self:set_texture()
            self:set_tooltip()
        end
    end)

    btn:SetScript('OnMouseWheel', function(self, d)
        local size=Save().EncounterJournalFontSize or 12
        if d==1 then
            size=size+1
        else
            size=size-1
        end
        size= size<6 and 6 or size
        size= size>72 and 72 or size
        Save().EncounterJournalFontSize=size
        WoWTools_LabelMixin:Create(nil, {size=size, changeFont=self.Text})--size, nil, self.Text)
        self:set_tooltip()
    end)

    btn.Text=WoWTools_LabelMixin:Create(btn, {size=Save().EncounterJournalFontSize, color=true})
    btn.Text:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')

    btn.texture=btn:CreateTexture()
    btn.texture:SetAllPoints()
    btn.texture:SetAlpha(0.5)
    function btn:set_texture()
        if Save().hideWorldBossText then
            self.texture:SetAtlas('talents-button-reset')
        else
            self.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        end
    end



    btn:set_texture()
    WoWTools_EncounterMixin.WorldBossButton= btn
    return btn
end











function WoWTools_EncounterMixin:WorldBoss_Settings()--显示世界BOSS击杀数据Text
    if not Save().showWorldBoss then
        if Button then
            Button.Text:SetText('')
            Button:SetShown(false)
        end
        return
    end
    Button= Button or Create_WorldBoss_Button()

    Button.Text:SetText(Get_Text() or '')

    Button:SetShown(true)
    Button.Text:SetShown(not Save().hideWorldBossText)
end




