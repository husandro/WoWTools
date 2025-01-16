--专业
local e= select(2, ...)




local function Init()
    ProfessionMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end

        local prof1, prof2, _, fishing= GetProfessions()
        local prof1Text, prof2Text, fishingText, name, icon

        local bat= UnitAffectingCombat('player')

        if prof1 and prof1>0 then
            name, icon= GetProfessionInfo(prof1)
            if name then
                prof1Text='|T'..(icon or 0)..':0|t'..(bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..name..'|r'..e.Icon.mid..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
            end
        end

        if fishing and fishing>0 then
            name, icon= GetProfessionInfo(fishing)
            if name then
                fishingText='|T'..(icon or 0)..':0|t'..(bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..name..'|r'..e.Icon.right
            end
        end

        if prof2 and prof2>0 then
            name, icon= GetProfessionInfo(prof2)
            if name then
                prof2Text='|T'..(icon or 0)..':0|t'..(bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..name..'|r'..e.Icon.mid..(e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
            end
        end
        
        if prof1Text or prof2Text or fishingText then
            e.tips:AddLine(' ')
            if prof1Text then
                e.tips:AddLine(prof1Text)
            end
            if fishingText then
                e.tips:AddLine(fishingText)
            end
            if prof2Text then
                e.tips:AddLine(prof2Text)
            end
            e.tips:Show()
        end
    end)

    ProfessionMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            local fishing= select(4, GetProfessions())
            if fishing and fishing>0 then
                local skillLine = select(7, GetProfessionInfo(fishing))
                if skillLine and skillLine>0 then
                    do
                        if ProfessionsBookFrame and ProfessionsBookFrame:IsShown() then
                            ToggleProfessionsBook()
                        end
                    end
                    C_TradeSkillUI.OpenTradeSkill(skillLine)
                end
            end
        end
    end)

    ProfessionMicroButton:EnableMouseWheel(true)
    ProfessionMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        local prof1, prof2= GetProfessions()
        local index= d==1 and prof1 or prof2
        local skillLine = index and index>0 and select(7, GetProfessionInfo(index))
        if skillLine and skillLine>0 then
            do
                if ProfessionsBookFrame and ProfessionsBookFrame:IsShown() then
                    ToggleProfessionsBook()
                end
            end
            C_TradeSkillUI.OpenTradeSkill(skillLine)
        end
    end)
end





function WoWTools_PlusMainMenuMixin:Init_Professions()
    Init()
end