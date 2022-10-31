local id, e = ...
local addName= PROFESSIONS_TRACKER_HEADER_PROFESSION
local panel=CreateFrame("Frame")

--######
--设置专业按钮
local function setButton()
    --local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    local tab={GetProfessions()}
    for index, type in pairs(tab) do
        if type then
            local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier, specializationIndex, specializationOffset = GetProfessionInfo(index)

            if not panel.buttons[index] then
                panel.buttons[index]=e.Cbtn2(nil, e.toolsFrame)
                panel.buttons[index]:SetPoint('BOTTOMLEFT', e.toolsFrame.last or e.toolsFrame, 'TOPLEFT')
                panel.buttons[index]:SetAttribute("type1", "spell")
                panel.buttons[index]:SetAttribute("type2", "spell")
                e.toolsFrame.last=panel.buttons[index]
            end

        end
        if panel.buttons[index] then
            panel.buttons[index]:SetShown(type)
        end
    end

end

--####
--初始
--####
local function Init()
    panel.buttons={}
    setButton()--设置专业按钮
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
        if not e.toolsFrame.disabled then
            Init()--初始
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")


    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)