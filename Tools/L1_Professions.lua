local id, e= ...
local addName




--##########
--TOOLS，按钮
--##########
local function Init_Tools_Button()
    --11版本

    local tab={GetProfessions()}--local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    for index, type in pairs(tab) do
        if type then --and index~=4 and index~=3 then
            local name, _, _, _, numAbilities, spelloffset = GetProfessionInfo(type)
            local info= C_Spell.GetSpellInfo(spelloffset+ 1, 'spell') or {}

            local icon= info.iconID
            local spellID= info.spellID
            local btn= e.Cbtn2({
                name='WoWToolsToolsProfessions'..name,
                parent= e.toolsFrame,
                click=true,-- right left
                notSecureActionButton=nil,
                notTexture=nil,
                showTexture=true,
                sizi=nil,
            })

         

            btn.spellID = spellID
            btn.name = name
            btn.index= index


            btn:SetAttribute("type1", "spell")
            btn:SetAttribute("spell", spellID)
            btn.texture:SetTexture(icon)
            btn.texture:SetShown(true)

            function btn:set_tooltip()
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spellID)
                if self.index==5 then
                    local link= C_Spell.GetSpellLink(818)
                    local texture= C_Spell.GetSpellTexture(818)
                    if link and texture then
                        local text= '|T'..texture..':0|t'.. link
                        if PlayerHasToy(134020) then--玩具,大厨的帽子
                            local link2,_,_,_,_,_,_,_, texture2 = select(2, C_Item.GetItemInfo(134020))
                            if link2 and texture2 then
                                text=text..'|T'..texture2..':0|t'..link2
                            end
                        end
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(text, e.Icon.right)
                    end
                elseif self.spellID2 then
                    local link= C_Spell.GetSpellLink(self.spellID2)
                    local texture= C_Spell.GetSpellTexture(self.spellID2)
                    if link and texture then
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine('|T'..texture..':0|t'.. link, e.Icon.right)
                    end
                end

                if (self.index==3 or self.index==4) and not UnitAffectingCombat('player') then
                    e.tips:AddDoubleLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, 'F', 0,1,0, 0,1,0)
                    e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.Icon.mid..(e.onlyChinese and '滚轮向上滚动' or KEY_MOUSEWHEELUP))
                    e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.mid..(e.onlyChinese and '轮向下滚动' or KEY_MOUSEWHEELDOWN))
                end
                e.tips:Show()
            end
            btn:SetScript('OnLeave', GameTooltip_Hide)
            btn:SetScript('OnEnter', btn.set_tooltip)


            if index==3 or index==4 then--钓鱼，考古， 设置清除快捷键
                function btn:set_key_text(text)
                    self.text:SetText(text)
                    if self.keyButton then
                        self.keyButton:set_text()
                    end
                end
                function btn:set_OnMouseWheel(d)
                    if d==1 then
                        e.SetButtonKey(self, true,'F', 'RightButton')
                        self:RegisterEvent('PLAYER_REGEN_ENABLED')
                        self:RegisterEvent('PLAYER_REGEN_DISABLED')
                        print(e.addName, WoWTools_ProfessionMixin.addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '设置' or SETTINGS), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF')

                    elseif d==-1 then
                        e.SetButtonKey(self)
                        self:UnregisterEvent('PLAYER_REGEN_DISABLED')
                        self:UnregisterEvent('PLAYER_REGEN_ENABLED')

                        print(e.addName, WoWTools_ProfessionMixin.addName,'|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                    end
                    self:set_tooltip()
                    self:set_key_text(d==1 and 'F' or '')
                end
                btn:SetScript('OnMouseWheel', btn.set_OnMouseWheel)
                btn:SetScript("OnEvent", function(self, event)
                    if event=='PLAYER_REGEN_ENABLED' then
                        e.SetButtonKey(self, true,'F', 'RightButton')
                        print(e.addName, WoWTools_ProfessionMixin.addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '设置' or SETTINGS), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF|r')
                    elseif event=='PLAYER_REGEN_DISABLED' then
                        e.SetButtonKey(self)
                        print(e.addName, WoWTools_ProfessionMixin.addName,'|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                    end
                    self:set_key_text(event=='PLAYER_REGEN_ENABLED' and 'F' or '')
                end)
                btn.text=WoWTools_LabelMixin:CreateLabel(btn, {color={r=1,g=0,b=0}})--nil,nil,nil,{1,0,0})
                btn.text:SetPoint('TOPRIGHT',-4,0)

                if index==3 then
                    ArcheologyButton= btn
                end
            end

            if index==5 then--烹饪用火
                local name2=IsSpellKnownOrOverridesKnown(818) and C_Spell.GetSpellName(818)
                if name2 then
                    local text=''
                    if PlayerHasToy(134020) then--玩具,大厨的帽子
                        local toyname=C_Item.GetItemNameByID('134020')
                        if toyname then
                            text= '/use '..toyname..'|n'
                        end
                    end
                    text=text..'/cast [@player]'..name2
                    if not btn.textureRight then
                        btn.textureRight= btn:CreateTexture(nil,'OVERLAY')
                        btn.textureRight:SetPoint('RIGHT',btn.border,'RIGHT',-6,0)
                        btn.textureRight:SetSize(8,8)
                        btn.textureRight:SetTexture(135805)
                        btn:SetScript('OnShow',function(self)
                            e.SetItemSpellCool(self, {sepll=818})
                        end)
                    end
                    btn:SetAttribute('type2', 'macro')
                    btn:SetAttribute("macrotext2", text)
                end
            elseif numAbilities and numAbilities>1 then
                local info2= C_Spell.GetSpellInfo(spelloffset+ 2, 'spell') or {}
                local icon2= info2.iconID
                local spellID2= info2.spellID
                if icon2 and spellID2 and icon2~=icon then
                    if not btn.textureRight then
                        btn.textureRight= btn:CreateTexture(nil,'OVERLAY')
                        btn.textureRight:SetPoint('RIGHT',btn.border,'RIGHT',-6,0)
                        btn.textureRight:SetSize(8,8)
                    end
                    btn.textureRight:SetTexture(icon2)
                end
                btn:SetAttribute("type2", "spell")
                btn:SetAttribute("spell2", spellID2)
                btn.spellID2= spellID2
            end
        end
    end
end







--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            --旧版本
            addName='|A:collections-icon-favorites:0:0|a'..(e.onlyChinese and '使用玩具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_RANDOM3:gsub('/',''), TOY))


            if WoWTools_ToolsButtonMixin:GetButton() then
                
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_Profession']=Save
        end
    end
end)