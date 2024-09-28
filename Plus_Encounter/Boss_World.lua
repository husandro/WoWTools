local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end



local function MoveFrame(frame, savePointName)
    frame:RegisterForDrag("RightButton")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
            ResetCursor()
            self:StopMovingOrSizing()
            Save[savePointName]={self:GetPoint(1)}
            Save[savePointName][2]= nil
    end)
    frame:SetScript('OnLeave', function(self)
        self:SetButtonState("NORMAL")
        GameTooltip_Hide()
    end)
    frame:EnableMouseWheel(true)
    frame:SetScript('OnMouseWheel', function(self, d)
        local size=Save().EncounterJournalFontSize or 12
        if d==1 then
            size=size+1
        else
            size=size-1
        end
        size= size<6 and 6 or size
        size= size>72 and 72 or size
        Save().EncounterJournalFontSize=size
        WoWTools_LabelMixin:CreateLabel(nil, {size=size, changeFont=self.Text})--size, nil, self2.Text)
        print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '字体大小' or FONT_SIZE, size)
    end)
end





local function Create_WorldBoss_Button(frame)
    frame.WorldBoss=WoWTools_ButtonMixin:Cbtn(nil, {icon='hide', size={14,14}})
    if Save().WorldBossPoint then
        frame.WorldBoss:SetPoint(Save().WorldBossPoint[1], UIParent, Save().WorldBossPoint[3], Save().WorldBossPoint[4], Save().WorldBossPoint[5])
    else
        if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
            frame.WorldBoss:SetPoint('BOTTOMRIGHT',EncounterJournal, 'TOPRIGHT', -65,5)
        else
            frame.WorldBoss:SetPoint('CENTER')
        end
    end
    frame.WorldBoss:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
        e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.onlyChinese and '世界BOSS和稀有怪'
            or format(COVENANT_RENOWN_TOAST_REWARD_COMBINER,
                    format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WORLD, 'BOSS')
                    ,GARRISON_MISSION_RARE
                )
        )
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save().hideWorldBossText), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or  NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.Player.L.size, (Save().EncounterJournalFontSize or 12)..e.Icon.mid)
        e.tips:Show()
    end)
    frame.WorldBoss:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            Save().hideWorldBossText= not Save().hideWorldBossText and true or nil
            self2.texture:SetShown(Save().hideWorldBossText)
            self2.Text:SetShown(not Save().hideWorldBossText)
        end
    end)
    MoveFrame(frame.WorldBoss, 'WorldBossPoint')

    frame.WorldBoss.Text=WoWTools_LabelMixin:CreateLabel(frame.WorldBoss, {size=Save().EncounterJournalFontSize, color=true})
    frame.WorldBoss.Text:SetPoint('TOPLEFT')

    frame.WorldBoss.texture=frame.WorldBoss:CreateTexture()
    frame.WorldBoss.texture:SetAllPoints()
    frame.WorldBoss.texture:SetAtlas(e.Icon.disabled)
end









function WoWTools_EncounterMixin:WorldBoss_Settings()--显示世界BOSS击杀数据Text
    if not Save().showWorldBoss then
        if self.WorldBoss then
            self.WorldBoss.Text:SetText('')
            self.WorldBoss:SetShown(false)
        end
        return
    end
    self.WorldBoss= self.WorldBoss or Create_WorldBoss_Button()

    local msg
    if not Save().hideWorldBossText then
        for guid, info in pairs(e.WoWDate or {}) do
            local text, numAll, find= nil, 0, nil
            for bossName, worldBossID in pairs(info.Worldboss.boss) do--世界BOSS
                numAll=numAll+1
                text= text and text ..' ' or '   '
                text= text..'|cnGREEN_FONT_COLOR:'..numAll..')|r'.. WoWTools_EncounterMixin:GetBossNameSort(bossName, worldBossID)
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
                msg= msg..'|n'..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true})
            end
        end
        msg= msg or '...'
    end
    self.WorldBoss.Text:SetText(msg or '')
    self.WorldBoss:SetShown(true)
    self.WorldBoss.texture:SetShown(Save().hideWorldBossText)
    self.WorldBoss.Text:SetShown(not Save().hideWorldBossText)
end









