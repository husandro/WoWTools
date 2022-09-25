local id, e = ...
local Save={}
local addName=TRADE_SKILLS
local panel=e.Cbtn(ProfessionsFrame.TitleContainer, nil, true)
panel:SetPoint('RIGHT', ProfessionsFrameTitleText, 'RIGHT', 10, 2)
panel:SetSize(20,20)
panel.professionInfoStr=e.Cstr(panel)
panel.professionInfoStr:SetPoint('RIGHT', panel, 'LEFT')
panel:SetScript('OnClick', function(self, d)
    if d=='LeftButton' then
        if Save.disabled then
            Save.disabled=nil
        else
            Save.disabled=true
            panel.professionInfoStr:SetText('')
        end
        panel:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
        print(id, addName,e.GetEnabeleDisable(not Save.disabled))
    end
end)
panel:SetScript('OnEnter', function(self)
    e.tips:SetOwner(self, "ANCHOR_RIGHT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine('professionID: ', self.professionID)
    e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disabed),e.Icon.left)
    e.tips:Show()
end)
hooksecurefunc(ProfessionsFrame,'SetProfessionInfo', function(self, professionInfo)
    panel.professionID=professionInfo.professionID
    if not Save.disabed then
        panel.professionInfoStr:SetText(professionInfo and professionInfo.professionID or '')
    end
end)

local function setProfessionsBtn()
    local professions= {GetProfessions()}
    local last
    for k, index in pairs( professions) do
        if k~=3 then
            local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier, specializationIndex, specializationOffset = GetProfessionInfo(index)
            if name and icon and not panel['professionBtn'..index] then
                panel['professionBtn'..index]=e.Cbtn(panel)
                if not last then
                    panel['professionBtn'..index]:SetPoint('TOPLEFT', ProfessionsFrame, 'TOPRIGHT',0, -20)
                else
                    panel['professionBtn'..index]:SetPoint('TOPLEFT', last, 'BOTTOMLEFT')
                end
                panel['professionBtn'..index]:SetSize(32,32)
                panel['professionBtn'..index]:SetScript('OnClick', function(self2)
                    C_TradeSkillUI.OpenTradeSkill(self2.skillLine)
                end)
                last=panel['professionBtn'..index]
            end
            panel['professionBtn'..index].skillLine=skillLine
            panel['professionBtn'..index]:SetNormalTexture(icon)
            --[[
            if k==5 then
                panel.professionBtnFuoco = e.Cbtn(panel, nil, nil, true)
                panel.professionBtnFuoco:SetSize(32, 32)
                panel.professionBtnFuoco:SetNormalTexture(135805)
                panel.professionBtnFuoco:SetAttribute('type', 'item')
                panel.professionBtnFuoco:SetAttribute('item', 6948)
                panel.professionBtnFuoco:SetPoint('LEFT', last, 'RIGHT')
            end
            ]]
        end
    end

end

--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            panel:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
            setProfessionsBtn()
    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
    end
end)