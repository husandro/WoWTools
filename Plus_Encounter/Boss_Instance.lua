local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end















local function Create_WorldBoss_Button(frame)
    local btn=WoWTools_ButtonMixin:Cbtn(nil, {name='WoWTools_EncounterInstanceBossButton', icon='hide', size={14,14}})
    btn:SetPoint('CENTER', -100, -100)
    e.Set_Move_Frame(btn, {notZoom=true})


    btn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
        e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.onlyChinese and '副本' or INSTANCE)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save().hideInstanceBossText), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.Player.L.size, (Save().EncounterJournalFontSize or 12)..e.Icon.mid)
        e.tips:Show()
    end)
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save().hideInstanceBossText= not Save().hideInstanceBossText and true or nil
            self.texture:SetShown(Save().hideInstanceBossText)
            self.Text:SetShown(not Save().hideInstanceBossText)
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
        WoWTools_LabelMixin:CreateLabel(nil, {size=size, changeFont=self.Text})--size, nil, self2.Text)
        print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '字体大小' or FONT_SIZE, size)
    end)

    btn.Text=WoWTools_LabelMixin:CreateLabel(btn, {size=Save().EncounterJournalFontSize, color=true})
    btn.Text:SetPoint('TOPLEFT')

    btn.texture=btn:CreateTexture()
    btn.texture:SetAllPoints()
    btn.texture:SetAtlas(e.Icon.disabled)
    btn.texture:SetShown(Save().hideInstanceBossText)

    return btn
end















local function Get_Text()
    if Save().hideInstanceBossText then
        return
    end

    local msg
    for guid, info in pairs(e.WoWDate or {}) do
        local text
        for bossName, tab in pairs(info.Instance.ins) do--ins={[名字]={[难度]=已击杀数}}
            text= text and text..'|n   '..bossName or '   '..bossName
            for difficultyName, killed in pairs(tab) do
                text= text..' '..difficultyName..' '..killed
            end
        end
        if text then
            msg=msg and msg..'|n' or ''
            msg= msg ..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true})..'|n'
            msg= msg.. text
        end
    end
    msg=msg or '...'
end












function WoWTools_EncounterMixin:InstanceBoss_Settings()--显示副本击杀数据
    if not Save().showInstanceBoss then
        if self.InstanceBossButton then
            self.InstanceBossButton.Text:SetText('')
            self.InstanceBossButton:SetShown(false)
        end
        return
    end

    self.InstanceBossButton= self.InstanceBossButton or Create_WorldBoss_Button()

    self.InstanceBossButton.Text:SetText(Get_Text() or '')

    self.InstanceBossButton:SetShown(true)
    self.InstanceBossButton.texture:SetShown(Save().hideInstanceBossText)
    self.InstanceBossButton.Text:SetShown(not Save().hideInstanceBossText)
end