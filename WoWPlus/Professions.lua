local id, e = ...
local Save={}
local addName=TRADE_SKILLS
local panel=e.Cbtn(ProfessionsFrame.TitleContainer, nil, true)
panel:SetPoint('RIGHT', ProfessionsFrameTitleText, 'RIGHT', 0, 2)
panel:SetSize(20,20)
panel.professionInfoStr=e.Cstr(panel)
panel.professionInfoStr:SetPoint('RIGHT', panel, 'LEFT')


hooksecurefunc(ProfessionsFrame,'SetProfessionInfo', function(self, professionInfo)
    panel.professionID=professionInfo.professionID
    if not Save.disabled then
        panel.professionInfoStr:SetText(professionInfo and professionInfo.professionID or '')
    end
end)

local function setProfessions()
    if UnitAffectingCombat('player') then
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    if Save.disabled or not ProfessionsFrame or not ProfessionsFrame:IsVisible() then
        for k=1,7 do
            if panel['profession'..k] then
                panel['profession'..k]:SetShown(false)
            end
        end
        if panel.profession6 then
            panel.profession6:UnregisterAllEvents()
        end
        return
    end
    local professions= {GetProfessions()}
    local last
    for k, index in pairs( professions) do
        if k~=3 then
            local name, icon, _, _, _, _, skillLine = GetProfessionInfo(index)
            if name and icon then
                if not panel['profession'..k] then
                    panel['profession'..k]=e.Cbtn(panel)
                    if not last then
                        panel['profession'..k]:SetPoint('BOTTOMLEFT', ProfessionsFrame, 'BOTTOMRIGHT',0, 35)
                    else
                        panel['profession'..k]:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0,2)
                    end
                    panel['profession'..k]:SetSize(32,32)
                    panel['profession'..k]:SetScript('OnMouseDown', function(self2)
                        C_TradeSkillUI.OpenTradeSkill(self2.skillLine)
                    end)
                    panel['profession'..k]:SetScript('OnEnter', function(self2)
                        e.tips:SetOwner(self2, "ANCHOR_RIGHT");
                        e.tips:ClearLines();
                        e.tips:SetText(self2.name)
                        e.tips:Show();
                    end)
                    panel['profession'..k]:SetScript('OnLeave',function() e.tips:Hide() end)
                    last=panel['profession'..k]
                end
                panel['profession'..k].skillLine=skillLine
                panel['profession'..k].name=name
                panel['profession'..k]:SetNormalTexture(icon)
                local info = C_TradeSkillUI.GetBaseProfessionInfo()
                if info and info.professionName==name then
                    panel['profession'..k]:LockHighlight()
                else
                    panel['profession'..k]:UnlockHighlight()
                end

                if k==5 and not UnitAffectingCombat('player') then
                    if not panel.profession6 then--烹饪用火
                        local spellID=818
                        panel.profession6 = e.Cbtn(panel, nil, nil, true)
                        panel.profession6:RegisterForClicks(e.LeftButtonDown)
                        panel.profession6:SetPoint('LEFT', panel.profession5, 'RIGHT',2, 0)
                        panel.profession6:SetSize(32, 32)
                        panel.profession6:SetNormalTexture(135805)
                        panel.profession6:SetScript('OnEnter', function(self2)
                            e.tips:SetOwner(self2, "ANCHOR_RIGHT");
                            e.tips:ClearLines();
                            e.tips:SetSpellByID(spellID)
                            e.tips:Show();
                        end)
                        panel.profession6:SetScript('OnLeave',function() e.tips:Hide() end)
                        local name2=GetSpellInfo(spellID)
                        if not name2 then
                            name2='/cast [@player]'..name2
                            panel.profession6:SetAttribute("type", "macro")
                            panel.profession6:SetAttribute("macrotext", name2)
                        else
                            panel.profession6:SetAttribute('type', 'spell')
                            panel.profession6:SetAttribute('unit', 'player')
                            panel.profession6:SetAttribute('spell', spellID)
                        end
                        panel.profession6:SetScript('OnEvent', function(self2, event, unitTarget, castGUID, spellID2)
                            if spellID2==spellID then
                                C_Timer.After(0.4, function()
                                    local start, duration, _ , modRate = GetSpellCooldown(spellID)
                                    e.Ccool(self2, start, duration, modRate)--冷却条
                                end)
                            end
                        end)
                        local start, duration, _ , modRate = GetSpellCooldown(818)
                        e.Ccool(panel.profession6, start, duration, modRate, nil, nil)--冷却条

                        if PlayerHasToy(134020) and not panel.profession7 then--玩具,大厨的帽子
                            name2=C_Item.GetItemNameByID(134020)
                            if name2 then
                                panel.profession7 = e.Cbtn(panel.profession6, nil, nil, true)
                                panel.profession7:SetPoint('LEFT', panel.profession6, 'RIGHT', 2,0)
                                panel.profession7:SetSize(32, 32)
                                panel.profession7:SetNormalTexture(236571)

                                panel.profession7:SetAttribute('type', 'item')
                                panel.profession7:SetAttribute('item', name2)
                                panel.profession7:SetScript('OnEnter', function(self2)
                                    e.tips:SetOwner(self2, "ANCHOR_RIGHT");
                                    e.tips:ClearLines();
                                    e.tips:SetToyByItemID(134020)
                                    e.tips:Show();
                                end)
                                panel.profession7:SetScript('OnLeave',function() e.tips:Hide() end)
                            end
                        end
                    end
                    if panel.profession7 then
                        panel.profession7:SetShown(true)
                    end
                end
            end
            if panel['profession'..k] then
                panel['profession'..k]:SetShown(name and icon)
            end
        end
    end
    if panel.profession6 then
        panel.profession6:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
        panel.profession6:SetShown(true)
    end
end

panel:SetScript('OnMouseDown', function(self, d)
    if d=='LeftButton' then
        if Save.disabled then
            Save.disabled=nil
        else
            Save.disabled=true
            panel.professionInfoStr:SetText('')
        end
        panel:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
        print(id, addName,e.GetEnabeleDisable(not Save.disabled))
        setProfessions()
    end
end)
panel:SetScript('OnEnter', function(self)
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine('professionID: ', self.professionID)
    e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disabled),e.Icon.left)
    e.tips:Show()
end)
--[[
local function setFMkey(self, set)--设置清除快捷键
    if set then
        e.SetButtonKey(panel.FM, true, 'F' )
        self.key:SetText('F')
        panel.FM:RegisterEvent('BAG_UPDATE_DELAYED')
        panel.FM:RegisterEvent('PLAYER_REGEN_DISABLED')
        panel.FM:RegisterEvent('TRADE_SKILL_CLOSE')
        panel.FM:SetShown(true)
        self.bagNum:SetText(GetItemCount(38682))
    else
        e.SetButtonKey(panel.FM, false)
        self.key:SetText('')
        panel.FM:UnregisterAllEvents()
        panel.FM:SetShown(false)
    end
end
local function setFM()
    local info = C_TradeSkillUI.GetBaseProfessionInfo()
    local bat = UnitAffectingCombat('player')
    if Save.disabled or bat or not info or info.professionName~=ENSCRIBE then
        if panel.FM and not bat then
            setFMkey(panel.FM, false)
        end
        return
    end
    if not panel.FM then
        panel.FM=e.Cbtn(ProfessionsFrame.CraftingPage.CreateButton, nil, nil, true, id..'ProfessionsFM')
        panel.FM:SetNormalTexture(237050)
        panel.FM:SetSize(35, 35)
        panel.FM:SetPoint('TOP', ProfessionsFrame.CraftingPage.CreateButton, 'BOTTOM')
        panel.FM:SetAttribute("type", "item")
        panel.FM:SetAttribute("target-item", C_Item.GetItemNameByID(38682))--附魔羊皮纸
        panel.FM.bagNum=e.Cstr(panel.FM, 16)
        panel.FM.bagNum:SetPoint('BOTTOMRIGHT')
        panel.FM.bagNum:SetText(GetItemCount(38682))
        panel.FM.key=e.Cstr(panel.FM, 20)
        panel.FM.key:SetPoint('TOPRIGHT')
        panel.FM:SetScript('OnEvent',function(self2, event)
            if event=='BAG_UPDATE_DELAYED' then
                self2.bagNum:SetText(GetItemCount(38682))
            else
                setFMkey(self2,false)--设置快捷键
            end
        end)
        panel.FM:SetScript("OnMouseDown", function()
            ProfessionsFrame.CraftingPage.CreateButton:Click()
        end)
    end
    setFMkey(panel.FM, true)--设置快捷键
end
]]

--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
--panel:RegisterEvent('TRADE_SKILL_CLOSE')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            panel:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='TRADE_SKILL_LIST_UPDATE' then-- or event=='TRADE_SKILL_CLOSE' then
        setProfessions()
        --setFM()
    elseif event=='PLAYER_REGEN_ENABLED' then
        setProfessions()
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)