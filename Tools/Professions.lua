local id, e = ...
local addName= PROFESSIONS_TRACKER_HEADER_PROFESSION
local Save={setButton=true}
local panel=CreateFrame("Frame")

local function set_ProfessionsFrame_Button()--专业界面, 按钮
    local setButton= e.Cbtn(ProfessionsFrame.TitleContainer, nil, not Save.notProfessionsFrameButtuon, nil, nil, nil, {20, 20})
    setButton:SetPoint('RIGHT', ProfessionsFrameTitleText, 'RIGHT', 0, 2)
    setButton:SetScript('OnMouseDown', function(self)
        Save.notProfessionsFrameButtuon= not Save.notProfessionsFrameButtuon and true or nil
        setButton.frame:SetShown(not Save.notProfessionsFrameButtuon)
        self:SetNormalAtlas(Save.notProfessionsFrameButtuon and e.Icon.disabled or e.Icon.icon)
    end)
    setButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, 'Tools')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(addName, e.GetShowHide(not Save.notProfessionsFrameButtuon)..e.Icon.left)
        e.tips:Show()
    end)
    setButton:SetScript('OnLeave', function() e.tips:Hide() end)

    setButton.frame= CreateFrame("Frame",nil, setButton)
    setButton.frame:SetShown(not Save.notProfessionsFrameButtuon)

    local last
    for k, index in pairs({GetProfessions()}) do
        if k~=3 then
            local name, icon, _, _, _, _, skillLine = GetProfessionInfo(index)
            if name and icon and skillLine then
                local button=e.Cbtn(setButton.frame, nil, nil, nil, nil, true, {32, 32})
                button:SetNormalTexture(icon)
                if not last then
                    button:SetPoint('BOTTOMLEFT', ProfessionsFrame, 'BOTTOMRIGHT',0, 35)
                else
                    button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0,2)
                end
                button:SetScript('OnMouseDown', function(self2)
                    C_TradeSkillUI.OpenTradeSkill(skillLine)
                end)
                button:SetScript('OnEnter', function(self2)
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT");
                    e.tips:ClearLines();
                    e.tips:SetText(name)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, 'Tools')
                    e.tips:Show();
                end)
                button:SetScript('OnLeave',function() e.tips:Hide() end)
                last= button
            end
        end
    end
end

--####
--初始
--####
local function Init()
    panel.buttons={}
    local tab={GetProfessions()}--local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    for index, type in pairs(tab) do
        local spellID, icon
        if type then --and index~=4 and index~=3 then
            --local name, icon = GetProfessionInfo(type)
            local name, _, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier, specializationIndex, specializationOffset = GetProfessionInfo(type)
            _, _, icon, _, _, _, spellID= GetSpellInfo(spelloffset+ 1, 'spell')

            if not panel.buttons[index] and spellID and icon and name then
                panel.buttons[index]=e.Cbtn2(id..addName..name, e.toolsFrame)
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
                        elseif self.spellID2 then
                            local link= GetSpellLink(self.spellID2)
                            local texture= GetSpellTexture(self.spellID2)
                            if link and texture then
                                e.tips:AddLine(' ')
                                e.tips:AddDoubleLine('|T'..texture..':0|t'.. link, e.Icon.right)
                            end
                        end

                        if self.index==3 or self.index==4 then
                            e.tips:AddDoubleLine(e.onlyChinse and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, 'F', 0,1,0, 0,1,0)
                            e.tips:AddDoubleLine(e.onlyChinse and '设置' or SETTINGS, e.Icon.mid..(e.onlyChinse and '滚轮向上滚动' or KEY_MOUSEWHEELUP))
                            e.tips:AddDoubleLine(e.onlyChinse and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.mid..(e.onlyChinse and '轮向下滚动' or KEY_MOUSEWHEELDOWN))
                        end
                        e.tips:Show()
                    end
                end)
                panel.buttons[index]:SetScript('OnLeave', function() e.tips:Hide() end)

                if index==3 or index==4 then--钓鱼，考古， 设置清除快捷键
                    panel.buttons[index]:SetScript('OnMouseWheel', function(self, d)
                        if d==1 then
                            e.SetButtonKey(self, true,'F', 'RightButton')
                            panel.buttons[index]:RegisterEvent('PLAYER_REGEN_ENABLED')
                            panel.buttons[index]:RegisterEvent('PLAYER_REGEN_DISABLED')
                            print(id, addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '设置' or SETTINGS), self.name, e.onlyChinse and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF')
                            self.text:SetText('F')
                        elseif d==-1 then
                            e.SetButtonKey(self)
                            panel.buttons[index]:UnregisterEvent('PLAYER_REGEN_DISABLED')
                            panel.buttons[index]:UnregisterEvent('PLAYER_REGEN_ENABLED')
                            self.text:SetText('')
                            print(id, addName,'|cnRED_FONT_COLOR:'..(e.onlyChinse and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinse and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                        end
                    end)
                    panel.buttons[index]:SetScript("OnEvent", function(self, event)
                        if event=='PLAYER_REGEN_ENABLED' then
                            e.SetButtonKey(self, true,'F', 'RightButton')
                            print(id, addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '设置' or SETTINGS), self.name, e.onlyChinse and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF|r')
                        elseif event=='PLAYER_REGEN_DISABLED' then
                            e.SetButtonKey(self)
                            print(id, addName,'|cnRED_FONT_COLOR:'..(e.onlyChinse and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinse and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                        end
                    end)
                    panel.buttons[index].text=e.Cstr(panel.buttons[index], nil,nil,nil,{1,0,0})
                    panel.buttons[index].text:SetPoint('TOPRIGHT',-4,0)
                end
            end
            if panel.buttons[index] then
                panel.buttons[index].spellID = spellID
                panel.buttons[index].name = name
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
                elseif numAbilities and numAbilities>1 then
                    local _, _, icon2, _, _, _, spellID2= GetSpellInfo(spelloffset+ 2, 'spell')
                    if icon2 and spellID2 and icon2~=icon then
                        if not panel.buttons[index].textureRight then
                            panel.buttons[index].textureRight= panel.buttons[index]:CreateTexture(nil,'OVERLAY')
                            panel.buttons[index].textureRight:SetPoint('RIGHT',panel.buttons[index].border,'RIGHT',-6,0)
                            panel.buttons[index].textureRight:SetSize(8,8)
                            panel.buttons[index]:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
                        end
                        panel.buttons[index].textureRight:SetTexture(icon2)
                    end
                    panel.buttons[index]:SetAttribute("type2","spell")
                    panel.buttons[index]:SetAttribute("spell2", spellID2)
                    panel.buttons[index].spellID2= spellID2
                else
                    panel.buttons[index].spellID2=nil
                    panel.buttons[index].index=nil
                end
                panel.buttons[index]:SetAttribute("spell", spellID)
                panel.buttons[index].texture:SetTexture(icon)
            end
        end
        if panel.buttons[index] then
            panel.buttons[index]:SetShown(spellID and icon)
        end
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.5, function()
                set_ProfessionsFrame_Button()--专业界面, 按钮
                if UnitAffectingCombat('player') then
                    panel.combat= true
                    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                else
                    Init()--初始
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