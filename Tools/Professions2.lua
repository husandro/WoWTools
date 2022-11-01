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
            local name, icon = GetProfessionInfo(type)
            if not panel.buttons[index] then
                panel.buttons[index]=e.Cbtn2(nil, e.toolsFrame)
                panel.buttons[index]:SetPoint('BOTTOMRIGHT', e.toolsFrame.last , 'TOPRIGHT')
                panel.buttons[index]:SetAttribute("type1", "spell")
                panel.buttons[index].texture:SetShown(true)
                e.toolsFrame.last=panel.buttons[index]
            end
            if index==5 then--烹饪用火
                local name2=GetSpellInfo(818)
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
                    panel.buttons[index]:RegisterForClicks("LeftButtonDown","RightButtonDown")
                    panel.buttons[index]:SetAttribute('type2', 'macro')
                    panel.buttons[index]:SetAttribute("macrotext2", text)
                end
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
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(2, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
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
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            panel.combat=nil
            Init()--初始
        end
        panel:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)