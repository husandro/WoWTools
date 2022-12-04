local id, e = ...
local addName= PROFESSIONS_TRACKER_HEADER_PROFESSION
local panel=CreateFrame("Frame")

--####
--初始
--####
local function Init()
    panel.buttons={}
    local tab={GetProfessions()}--local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    for index, type in pairs(tab) do
        if type and index~=4 and index~=3 then
            --local name, icon = GetProfessionInfo(type)
            local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier, specializationIndex, specializationOffset = GetProfessionInfo(type)

            if not panel.buttons[index] then
                panel.buttons[index]=e.Cbtn2(nil, e.toolsFrame)
                e.ToolsSetButtonPoint(panel.buttons[index])--设置位置
                panel.buttons[index]:SetAttribute("type1", "spell")
                panel.buttons[index].texture:SetShown(true)
                e.toolsFrame.last=panel.buttons[index]

                panel.buttons[index]:SetScript('OnEnter', function(self)
                    if self.spellID then
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(self.spellID)
                        if self.index==5 then
                            local link= GetSpellLink(818)
                            local texture= GetSpellTexture(818)
                            if link and texture then
                                local text= '|T'..texture..':0|t'.. link
                                if PlayerHasToy(134020) then--玩具,大厨的帽子
                                    local link2,_,_,_,_,_,_,_, texture2 = select(2, GetItemInfo(134020))
                                    if link2 and texture2 then
                                        text=text..'|T'..texture2..':0|t'..link2
                                    end
                                end
                                e.tips:AddLine(' ')
                                e.tips:AddDoubleLine(text, e.Icon.right)
                            end
                        end
                        e.tips:Show()
                    end
                end)
                panel.buttons[index]:SetScript('OnLeave', function() e.tips:Hide() end)
            end
            panel.buttons[index].spellID = select(7, GetSpellInfo(spelloffset+1, 'spell'))
            panel.buttons[index].index= index

            if index==5 then--烹饪用火
                local name2=IsSpellKnown(818) and GetSpellInfo(818)
                if name2 then
                    local text=''
                    if PlayerHasToy(134020) then--玩具,大厨的帽子
                        local toyname=C_Item.GetItemNameByID('134020')
                        if toyname then
                            text= '/use '..toyname..'\n'
                        end
                    end
                    text=text..'/cast [@player]'..name2
                    if not panel.buttons[index].textureRight then
                        panel.buttons[index].textureRight= panel.buttons[index]:CreateTexture(nil,'OVERLAY')
                        panel.buttons[index].textureRight:SetPoint('RIGHT',panel.buttons[index].border,'RIGHT',-6,0)
                        panel.buttons[index].textureRight:SetSize(8,8)
                        panel.buttons[index].textureRight:SetTexture(135805)
                        panel.buttons[index]:SetScript('OnShow',function(self)
                            local start, duration, _, modRate = GetSpellCooldown(818)
                            e.Ccool(self, start, duration, modRate)--冷却条
                        end)
                    end
                    panel.buttons[index]:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
                    panel.buttons[index]:SetAttribute('type2', 'macro')
                    panel.buttons[index]:SetAttribute("macrotext2", text)
                end
            else
                panel.buttons[index].index=nil
            end
            panel.buttons[index]:SetAttribute("spell", name)
            panel.buttons[index].texture:SetTexture(icon)

        end

        if panel.buttons[index] then
            panel.buttons[index]:SetShown(type)
        end
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_REGEN_ENABLED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.5, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
                else
                    Init()--初始
                    panel:UnregisterEvent("PLAYER_REGEN_ENABLED")
                end
            end)
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            panel.combat=nil
            Init()--初始
        end
        panel:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)