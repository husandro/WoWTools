---@diagnostic disable: undefined-global, redefined-local, assign-type-mismatch, undefined-field, inject-field, missing-parameter, redundant-parameter, unused-local, trailing-space, param-type-mismatch, duplicate-set-field

local id, e= ...
if not WoWTools_DataMixin.Player.IsMaxLevel then
    return
end

local Save= {
    mark= WoWTools_DataMixin.Player.husandro,
    sound= WoWTools_DataMixin.Player.husandro,
    hide= WoWTools_DataMixin.Player.husandro,
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
            button:RegisterEvent('PLAYER_TARGET_CHANGED')
        else
            button:UnregisterAllEvents()
        end
        button:SetShown(show)
    end
end

local function set_Plate(self, hide)
    if hide then
        if self:GetAlpha()>0 then self:SetAlpha(0) end
        if self:GetScale()>0.1 then self:SetScale(0.1) end
    else
        if self:GetAlpha()<1 then self:SetAlpha(1) end
        if self:GetScale()<1 then self:SetScale(1) end
    end
end

local playerSound--播放，声音
local function set_Count(self, event)
    if event=='PLAYER_TARGET_CHANGED' then
        local plate= UnitExists('target') and C_NamePlate.GetNamePlateForUnit('target', issecure())
        if plate and plate.UnitFrame then
            if plate.UnitFrame:GetAlpha()<1 then plate.UnitFrame:SetAlpha(1) end
            if plate.UnitFrame:GetScale()<1 then plate.UnitFrame:SetScale(1) end
        end
    else
        local all, frames= 0, {}
        local nameplates= C_NamePlate.GetNamePlates(issecure()) or {}
        for _, plate in pairs(nameplates) do
            local unit =plate.UnitFrame and plate.UnitFrame.unit-- or plate.namePlateUnitToken
            local guid= UnitExists(unit) and UnitGUID(unit)
            if guid then--if select(6, strsplit("-", guid))== '120651' then
                if guid:match('Creature%-.-%-.-%-.-%-.-%-(%d+)%-') == '120651' then
                    all= all+ 1
                    if Save.mark and not GetRaidTargetIndex(unit) then --标记
                        local t=9- all
                        if t>0 then
                            SetRaidTarget(unit, t)
                        end
                    end

                    if Save.hide then--显示，爆炸物
                        set_Plate(plate.UnitFrame, nil)
                    end

                elseif Save.hide then
                    table.insert(frames, plate.UnitFrame)--隐藏，不是爆炸物
                end
            end
        end

        for _, plate in pairs(frames) do
            if plate then
                if all>0 then--隐藏，不是爆炸物
                    set_Plate(plate, true)
                else--显示，不是爆炸物
                    set_Plate(plate, nil)
                end
            end
        end

        if Save.sound then--播放，声音
            if all>0 then
                if not playerSound then
                    WoWTools_Mixin:PlaySound(nil, true)
                    playerSound= true
                end
            else
                playerSound= nil
            end
        end

        self.count:SetText(all>0 and all or '')
        self:SetAlpha(all>0 and 1 or 0.3)
    end
end

local function set_Rest()
    local nameplates= C_NamePlate.GetNamePlates(issecure()) or {}
    for _, plate in pairs(nameplates) do
        if plate and plate.UnitFrame then
            set_Plate(plate.UnitFrame, nil)--显示
        end
    end
end

--#####
--主菜单
--#####
local function Init_Menu(self, level, type)
    local info= {
        text= WoWTools_Mixin.onlyChinese and '透明度' or 'Alpha',
        checked= Save.hide,
        func= function()
            Save.hide= not Save.hide and true or nil
            if not Save.hide then
                set_Rest()
            end
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info= {
        text= WoWTools_Mixin.onlyChinese and '队伍标记' or BINDING_HEADER_RAID_TARGET,
        checked= Save.mark,
        func= function()
            Save.mark= not Save.mark and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info= {
        text= WoWTools_Mixin.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY,
        checked= Save.sound,
        icon= 'chatframe-button-icon-voicechat',
        disabled= not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0',
        func= function()
            Save.sound= not Save.sound and true or nil
            if Save.sound then
                WoWTools_Mixin:PlaySound(nil, true)
            end
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

local function set_Button()
    if not IsInInstance() or not C_ChallengeMode.IsChallengeModeActive() then
        set_Events(false)
        return
    end
    if not button then
        button= WoWTools_ButtonMixin:Cbtn(nil, {size=35})
        if Save.point then
            button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            button:SetPoint('CENTER', -430, 0)
        end
        button:SetNormalTexture(2175503)
        button:SetClampedToScreen(true)
        button:SetMovable(true)
        button:RegisterForDrag("RightButton")
        button:SetAlpha(0.3)
        button:SetScript("OnDragStart", function(self) self:StartMoving() end)
        button:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            Save.point={self:GetPoint(1)}
            Save.point[2]=nil
            ResetCursor()
        end)
        button:SetScript("OnEvent", set_Count)
        button:SetScript("OnMouseUp", function() ResetCursor() end)
        button:SetScript("OnMouseDown", function(self, d)
            if d=='RightButton' and not IsModifierKeyDown() then
                SetCursor('UI_MOVE_CURSOR');
            elseif d=='LeftButton' then
                if not self.Menu then
                    self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                    e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
                end
                e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
            end
        end)
        button:SetScript('OnEnter', function(self2)
            local name, description, filedataid= C_ChallengeMode.GetAffixInfo(13)
            if not UnitAffectingCombat('player') and name and description then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(name, filedataid and '|T'..filedataid ..':0|t' or ' ')
                GameTooltip:AddLine(description, nil,nil,nil,true)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left, (WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE)..WoWTools_DataMixin.Icon.right)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_TextMixin:CN(addName))
                GameTooltip:Show()
            end
        end)
        button:SetScript('OnLeave', function() GameTooltip:Hide() ResetCursor() end)

        button.count= WoWTools_LabelMixin:Create(button, {size=32, color={r=1,g=1,b=1}, justifyH='CENTER'})--32, nil, nil, {1,1,1}, nil, 'CENTER')
        button.count:SetPoint('CENTER')


    end

    set_Events(true)
end


panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= '|T2175503:0|t'..(WoWTools_Mixin.onlyChinese and '爆炸物' or addName),
                tooltip= select(2, C_ChallengeMode.GetAffixInfo(13)),
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(WoWTools_Mixin.addName, WoWTools_TextMixin:CN(addName), WoWTools_TextMixin:GetEnabeleDisable(not Save.disabled), WoWTools_Mixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            --[[添加控制面板        
            local check= WoWTools_PanelMixin:OnlyCheck((WoWTools_Mixin.onlyChinese and '爆炸物' or addName)..'|T2175503:0|t', not Save.disabled, nil, true)
            check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(WoWTools_Mixin.addName, WoWTools_TextMixin:CN(addName), WoWTools_TextMixin:GetEnabeleDisable(not Save.disabled), WoWTools_Mixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)
            check:SetScript('OnEnter', function(self2)
                local name, description, filedataid= C_ChallengeMode.GetAffixInfo(13)
                if name and description then
                    GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddDoubleLine(name, filedataid and '|T'..filedataid ..':0|t' or ' ')
                    GameTooltip:AddLine(description, nil,nil,nil,true)
                    GameTooltip:Show()
                end
            end)
            check:SetScript('OnLeave', GameTooltip_Hide)]]

            if not Save.disabled then
                C_Timer.After(2, function()
                    local affixIDs= C_MythicPlus.GetCurrentAffixes() or {}
                    local find
                    for _, tab in pairs(affixIDs) do
                        if tab and tab.id==13 then
                            find=true
                            break
                        end
                    end
                    if find then
                        set_Button()
                        panel:RegisterEvent('CHALLENGE_MODE_START')
                        panel:RegisterEvent('PLAYER_ENTERING_WORLD')
                        panel:UnregisterEvent('ADDON_LOADED')
                    else
                        --check.text:SetTextColor(0.5,0.5,0.5)
                        panel:UnregisterAllEvents()
                    end
                end)
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='CHALLENGE_MODE_START' or event=='PLAYER_ENTERING_WORLD' then
        C_Timer.After(1, set_Button)
    end
end)