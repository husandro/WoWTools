local id, e= ...
local Save= {
    name={},
    scale=1.5,
    alp= true,
}
local addName= 'Explosives'
local panel= CreateFrame('Frame')
local button

local function set_Events(show)
    if button then
        if show then
            button:RegisterEvent('NAME_PLATE_CREATED')
            button:RegisterEvent('NAME_PLATE_UNIT_ADDED')
            button:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
        else
            button:UnregisterAllEvents()
        end
        button:SetShown(show)
    end
end


local function set_Count()
    local all, frames= 0, {}
    local nameplates= C_NamePlate.GetNamePlates() or {}
    for _, info in pairs(nameplates) do
        local unit = info.namePlateUnitToken or (info.UnitFrame and info.UnitFrame.unit)
        local guid= UnitExists(unit) and UnitGUID(unit)
        if guid then
            if select(6, strsplit("-", guid))== '120651' then
                all= all+ 1
                if Save.mark and not GetRaidTargetIndex(unit) then --标记
                    local t=9- all
                    if t>0 then
                        SetRaidTarget(unit, t)
                    end
                end

                local frame=info.UnitFrame
                if frame then
                    if Save.alp then
                        if frame:GetAlpha()~=1 then
                            frame:SetAlpha(1)
                        end
                    end
                    if Save.scale and frame:GetScale()~=Save.scale then
                        frame:SetScale(Save.scale)
                    end
                end

            elseif (Save.alp or Save.scale) and info.UnitFrame then
                table.insert(frames, info.UnitFrame)
            end
        end
    end

print(all)
    for _, frame in pairs(frames) do
        if all>0 then
            if Save.alp and frame:GetAlpha()~=0 then
                frame:SetAlpha(0)
            end
            if Save.scale and frame:GetScale()~=0.1 then
                frame:SetScale(0.1)
            end
        else
            if Save.alp and frame:GetAlpha()~=1 then
                frame:SetAlpha(1)
            end
            if Save.scale and frame:GetScale()~=1 then
                frame:SetScale(1)
            end
        end
    end
    button.count:SetText(all>0 and all or '')
end

local function set_Button()
    --[[
    if not IsInInstance() or not C_ChallengeMode.IsChallengeModeActive() then
        set_Events(false)
        return
    end
    
    local tab= select(2,  C_ChallengeMode.GetSlottedKeystoneInfo()) or {}
    local find
    for _, affixID in pairs(tab) do
        if affixID== 13 then
            find= true
        end
    end
    
    if not find then
        set_Events(false)
        return
    end
]]
    if not button then
        button= e.Cbtn(nil, nil, nil, nil, nil, true, {35,35})
        if Save.point then
            button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            button:SetPoint('CENTER', -430, 0)
        end
        button:SetNormalTexture(2175503)
        button:SetClampedToScreen(true)
        button:SetMovable(true)
        button:RegisterForDrag("RightButton")
        button:SetScript("OnDragStart", function(self) self:StartMoving() end)
        button:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            Save.point={self:GetPoint(1)}
            Save.point[2]=nil
            ResetCursor()
        end)
        button:SetScript("OnEvent", set_Count)
        button.count= e.Cstr(button, 32, nil, nil, {1,1,1}, nil, 'CENTER')
        button.count:SetPoint('CENTER')
    end

    set_Events(true)
end

--#####
--初始化
--#####
local function Init()
    --[[local tab={
        ['enUS']= 'Explosives',
        ['koKR']= '폭발물',
        ['frFR']= 'Explosifs',
        ['deDE']= 'Sprengstoff',
        ['zhCN']= '爆炸物',
        ['esES']= 'Explosivos',
        ['zhTW']= '爆炸物',
        ['esMX']= 'Explosivos',
        --['ruRU']= nil,
        ['ptBR']= 'Explosivos',
        ['itIT']= 'Esplosivi',
    }
    panel.Name= tab[e.Player.Lo] or Save.name[e.Player.Lo]
    ]]
end

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('CHALLENGE_MODE_START')
panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local check= e.CPanel((e.onlyChinse and '爆炸物' or addName)..'|T134337:0|t', not Save.disabled, nil, true)
            check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需求重新加载' or REQUIRES_RELOAD)
            end)
            check:SetScript('OnEnter', function(self2)
                local name, description, filedataid= C_ChallengeMode.GetAffixInfo(13)
                if name and description then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(name, filedataid and '|T'..filedataid ..':0|t' or ' ')
                    e.tips:AddLine(description, nil,nil,nil,true)
                    e.tips:Show()
                end
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)

            if not Save.disabled then
                C_Timer.After(2, function()
                    local affixIDs= C_MythicPlus.GetCurrentAffixes()
                    local find
                    for _, tab in pairs(affixIDs) do
                        if tab and tab.id==13 then
                            find=true
                            break
                        end
                    end
                    if find then
                        Init()
                        panel:UnregisterEvent('ADDON_LOADED')
                    else
                        check.text:SetTextColor(0.8,0.8,0.8)
                        panel:UnregisterAllEvents()
                    end
                end)
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='CHALLENGE_MODE_START' or event=='PLAYER_ENTERING_WORLD' then
        set_Button()
    end
end)