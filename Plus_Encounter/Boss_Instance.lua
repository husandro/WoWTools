local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end
local Button


























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
    return msg
end







local function Create_WorldBoss_Button(frame)
    local btn= WoWTools_ButtonMixin:Cbtn(nil, {name='WoWTools_EncounterInstanceBossButton', icon='hide', size={14,14}})
    btn:SetPoint('CENTER', -100, -100)
    e.Set_Move_Frame(btn, {notZoom=true})

    function btn:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
        e.tips:AddDoubleLine(e.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL, e.onlyChinese and '副本' or INSTANCE)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save().hideInstanceBossText), e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.Player.L.size, (Save().InsFontSize or 12)..e.Icon.mid)
        e.tips:Show()
    end
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltip)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Save().hideInstanceBossText= not Save().hideInstanceBossText and true or nil
            self.Text:SetShown(not Save().hideInstanceBossText)
            self:set_texture()
            self:set_tooltip()
        end
    end)

    btn:SetScript('OnMouseWheel', function(self, d)
        local size=Save().InsFontSize or 12
        if d==1 then
            size=size+1
        else
            size=size-1
        end
        size= size<6 and 6 or size
        size= size>72 and 72 or size
        Save().InsFontSize=size
        WoWTools_LabelMixin:Create(nil, {size=size, changeFont=self.Text})--size, nil, self2.Text)        
        self:set_tooltip()
    end)

    btn.Text=WoWTools_LabelMixin:Create(btn, {size=Save().InsFontSize, color=true})
    btn.Text:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')

    btn.texture=btn:CreateTexture()
    btn.texture:SetAllPoints()
    btn.texture:SetAlpha(0.5)
    function btn:set_texture()
        btn.texture:SetAtlas(Save().hideInstanceBossText and e.Icon.disabled or e.Icon.icon)
    end
    btn:set_texture()

    WoWTools_EncounterMixin.InstanceBossButton= btn

    return btn
end





function WoWTools_EncounterMixin:InstanceBoss_Settings()--显示副本击杀数据
    if not Save().showInstanceBoss then
        if Button then
            Button.Text:SetText('')
            Button:SetShown(false)
        end
        return
    end

    Button= Button or Create_WorldBoss_Button()
    Button.Text:SetText(Get_Text() or '')

    Button:SetShown(true)
    Button.Text:SetShown(not Save().hideInstanceBossText)
end