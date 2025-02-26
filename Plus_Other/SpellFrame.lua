local id, e = ...
local addName
local Save={}









--天赋, 点数 Blizzard_SharedTalentButtonTemplates.lua Blizzard_ClassTalentButtonTemplates.lua
local function set_UpdateSpendText(btn)
    local info= btn.nodeInfo-- C_Traits.GetNodeInfo btn:GetSpellID()
    local text
    if info then
        if info.currentRank and info.maxRanks and info.currentRank>0 and info.maxRanks~= info.currentRank then
            text= '/'..info.maxRanks
        end
        if text and not btn.maxText then
            btn.maxText= WoWTools_LabelMixin:Create(btn, {fontType=btn.SpendText})--nil, btn.SpendText)
            btn.maxText:SetPoint('LEFT', btn.SpendText, 'RIGHT')
            btn.maxText:SetTextColor(1, 0, 1)
            btn.maxText:EnableMouse(true)
            btn.maxText:SetScript('OnLeave', GameTooltip_Hide)
            btn.maxText:SetScript('OnEnter', function(self)
                if self.maxRanks then
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self.maxRanks)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(WoWTools_Mixin.addName, addName)
                    e.tips:Show()
                end
            end)
        end
    end
    if btn.maxText then
        btn.maxText.maxRanks= info and info.maxRanks
        btn.maxText:SetText(text or '')
    end
end



















--法术按键, 颜色 ActionButton.lua
local function set_ActionButton_UpdateRangeIndicator(frame, checksRange, inRange)
    if not frame.setHooksecurefunc and frame.UpdateUsable then
        hooksecurefunc(frame, 'UpdateUsable', function(self, _, isUsable)
            if IsUsableAction(self.action) and ActionHasRange(self.action) and IsActionInRange(self.action)==false then
                self.icon:SetVertexColor(1,0,0)
            end
        end)
        frame.setHooksecurefunc= true
    end

    if ( frame.HotKey:GetText() == RANGE_INDICATOR ) then
        if ( checksRange ) then
            if ( inRange ) then
                if frame.UpdateUsable then
                    frame:UpdateUsable()
                end
            else
                frame.icon:SetVertexColor(1,0,0)
            end
        end
    else
        if ( checksRange and not inRange ) then
            frame.icon:SetVertexColor(1,0,0)
        elseif frame.UpdateUsable then
            frame:UpdateUsable()
        end
    end

end





















--天赋，添加专精按钮
local function Init_Spec_Button()
    local numSpec= GetNumSpecializations(false, false) or 0
    if not C_SpecializationInfo.IsInitialized() or numSpec==0 then
        return
    end

    for index=1, numSpec do
        local btn= WoWTools_ButtonMixin:Cbtn(PlayerSpellsFrame.TalentsFrame, {
                texture= select(4, GetSpecializationInfo(index, false, false, nil, UnitSex("player"))),
                size=164/numSpec,
                name='WoWTools_Other_SpecButton'..index
            })

        btn:SetFrameStrata('HIGH')
        if index==1 then
            btn:SetPoint('BOTTOMLEFT', PlayerSpellsFrame.TalentsFrame.ApplyButton, 'TOPLEFT', 0, 4)
        else
            btn:SetPoint('LEFT', _G['WoWTools_Other_SpecButton'..(index-1)], 'RIGHT')
        end

        btn.RoleIcon= btn:CreateTexture(nil, 'OVERLAY')
        btn.RoleIcon:SetSize(18,18)
        btn.RoleIcon:SetPoint('BOTTOMRIGHT',-1, 1)
        btn.RoleIcon:SetAtlas(GetMicroIconForRoleEnum(GetSpecializationRoleEnum(index, false, false)), TextureKitConstants.IgnoreAtlasSize)

        btn.SelectIcon= btn:CreateTexture(nil, 'OVERLAY')
        btn.SelectIcon:SetAllPoints()
        btn.SelectIcon:SetAtlas('ChromieTime-Button-Selection')
        btn.SelectIcon:SetVertexColor(0,1,0)

        function btn:IsActive()
            return GetSpecialization(nil, false, 1)==self.specIndex
        end
        function btn:Settings()
            self.SelectIcon:SetShown(self:IsActive())
        end

        function btn:Set_Active()
            if not self:IsActive() and InCombatLockdown() then--PlayerSpellsFrame.TalentsFrame:IsCommitInProgress()
                C_SpecializationInfo.SetSpecialization(self.specIndex)
            end
        end

        btn:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                self:Set_Active()
            elseif d=='RightButton' then
                MenuUtil.CreateContextMenu(self, function(_, root)
                    local sub= root:CreateButton(
                        '|T'..(select(4, GetSpecializationInfo(self.specIndex, false, false, nil, UnitSex("player"))) or 0)..':0|t'
                        ..((self:IsActive() or UnitAffectingCombat('player')) and '|cff828282' or '')
                        ..(e.onlyChinese and '激活' or SPEC_ACTIVE),
                    function()
                        self:Set_Active()
                    end, {specIndex= self.specIndex})
                    WoWTools_SetTooltipMixin:Set_Menu(sub)

                    root:CreateDivider()
--打开选项界面
                    WoWTools_MenuMixin:OpenOptions(root, {name=addName, category=WoWTools_OtherMixin.Category})
                end)
            end
        end)

        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript('OnEnter', function(self)
            WoWTools_SetTooltipMixin:Frame(self, GameTooltip, {
                specIndex= self.specIndex,
                tooltip= function(tooltip)
                    tooltip:AddLine(' ')
                    local col= ((UnitAffectingCombat('player') or self:IsActive()) and '|cff828282' or '|cffffffff')
                    tooltip:AddDoubleLine(
                        col..(e.onlyChinese and '激活' or SPEC_ACTIVE)
                        ..e.Icon.left,

                        col..e.Icon.right..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..addName
                    )
                end
            })
        end)

        btn:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
        btn:SetScript('OnEvent', btn.Settings)

        btn.specIndex= index
        btn:Settings()
    end
end


















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Frame')]= nil
            Save= WoWToolsSave['Other_SpellFrame'] or Save

            addName= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'..(e.onlyChinese and '法术Frame' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Frame'))

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                tooltip= e.onlyChinese and '法术距离, 颜色'
                        or (
                            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, TRACKER_SORT_PROXIMITY)..': '.. COLOR

                    ),
                Value= not Save.disabled,
                GetValue=function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            if Save.disabled then
                self:UnregisterEvent(event)
            else
    --法术按键, 颜色
                hooksecurefunc('ActionButton_UpdateRangeIndicator', set_ActionButton_UpdateRangeIndicator)
            end

        elseif arg1=='Blizzard_PlayerSpells' then--天赋
            hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', set_UpdateSpendText)--天赋, 点数 

            Init_Spec_Button()

            hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
                frame.Button.ActionBarHighlight:SetVertexColor(0,1,0)
                if (frame.spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout) then
                    frame.Button.Arrow:SetVertexColor(1,0,1)
                    frame.Button.Border:SetVertexColor(1,0,1)
                else
                    frame.Button.Arrow:SetVertexColor(1,1,1)
                    frame.Button.Border:SetVertexColor(1,1,1)
                end
            end)
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Other_SpellFrame']=Save
        end
    end
end)