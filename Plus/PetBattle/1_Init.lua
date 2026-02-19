local P_Save={
    
}



local function Save()
    return WoWToolsSave['Plus_PetBattle2']
end








local function Init_Panel()
    if Save().disabled then
        return
    end

    WoWTools_PanelMixin:Header(WoWTools_PetBattleMixin.Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)

--技能按钮
    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName6,
        GetValue= function() return not Save().AbilityButton.disabled end,
        SetValue= function()
            Save().AbilityButton.disabled= not Save().AbilityButton.disabled and true or nil
            WoWTools_PetBattleMixin:Init_AbilityButton()
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().AbilityButton= {disabled= Save().AbilityButton.disabled}
            WoWTools_PetBattleMixin:Init_AbilityButton()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName6, WoWTools_DataMixin.onlyChinese and '重置' or RESET)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= WoWTools_PetBattleMixin.Layout,
        category= WoWTools_PetBattleMixin.Category,
    })

--宠物类型, TypeButton
    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName4,
        GetValue= function() return not Save().TypeButton.disabled end,
        SetValue= function()
            Save().TypeButton.disabled= not Save().TypeButton.disabled and true or nil
            WoWTools_PetBattleMixin:Init_TypeButton()
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().TypeButton= {
                disabled=Save().TypeButton.disabled,
                showBackground=true,
            }
            WoWTools_PetBattleMixin:Init_TypeButton()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= WoWTools_PetBattleMixin.addName,
        layout= WoWTools_PetBattleMixin.Layout,
        category= WoWTools_PetBattleMixin.Category,
    })

    WoWTools_PanelMixin:Header(WoWTools_PetBattleMixin.Layout, WoWTools_DataMixin.onlyChinese and '其它' or OTHER)


--点击移动按钮
    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_PetBattleMixin.addName3,
        GetValue= function() return not Save().ClickMoveButton.disabled end,
        SetValue= function()
            Save().ClickMoveButton.disabled= not Save().ClickMoveButton.disabled and true or nil
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
        buttonFunc= function()
            Save().ClickMoveButton= {
                disabled= Save().ClickMoveButton.disabled,
                PlayerFrame=true,
                lock_autoInteract=WoWTools_DataMixin.Player.husandro and '1' or nil,
                lock_cameraSmoothStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
                lock_cameraSmoothTrackingStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
            }
            WoWTools_PetBattleMixin:ClickToMove_Button()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_PetBattleMixin.addName3, WoWTools_DataMixin.onlyChinese and '重置' or RESET)
        end,
        layout= WoWTools_PetBattleMixin.Layout,
        category= WoWTools_PetBattleMixin.Category,
    })


    Init_Panel=function()end
end



--点击移动按钮 SetParent
    --[[WoWTools_PanelMixin:OnlyCheck({
        name= 'PlayerFrame',
        tooltip='|nSetParent(\'PlayerFrame\')|n|n'..WoWTools_PetBattleMixin.addName3,
        GetValue= function() return Save().ClickMoveButton.PlayerFrame end,
        SetValue= function()
            Save().ClickMoveButton.PlayerFrame = not Save().ClickMoveButton.PlayerFrame and true or false
            WoWTools_PetBattleMixin:ClickToMove_Button()
        end,
        layout= WoWTools_PetBattleMixin.Layout,
        category= WoWTools_PetBattleMixin.Category,
    }, sub)]]




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)

    if arg1== 'WoWTools' then

        WoWToolsSave['Plus_PetBattle2']= WoWToolsSave['Plus_PetBattle2'] or {--clickToMove= WoWTools_DataMixin.Player.husandro,--禁用, 点击移动
            ClickMoveButton={
                PlayerFrame=true,
                lock_autoInteract=WoWTools_DataMixin.Player.husandro and '1' or nil,
                lock_cameraSmoothStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
                lock_cameraSmoothTrackingStyle= WoWTools_DataMixin.Player.husandro and '0' or nil,
            },
            TypeButton={
                showBackground=true,
            },
            Plus={},
            AbilityButton={}
        }

        WoWTools_PetBattleMixin.addName= '|A:WildBattlePetCapturable:0:0|a'..(WoWTools_DataMixin.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)
        WoWTools_PetBattleMixin.addName3= '|A:transmog-gearSlot-unassigned-feet:0:0|a'..(WoWTools_DataMixin.onlyChinese and '点击移动按钮'or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLICK_TO_MOVE, 'Button'))
        WoWTools_PetBattleMixin.addName4= '|A:WildBattlePetCapturable:0:0|a'..(WoWTools_DataMixin.onlyChinese and '宠物类型' or PET_FAMILIES)
        WoWTools_PetBattleMixin.addName6= '|A:plunderstorm-icon-offensive:0:0|a'..(WoWTools_DataMixin.onlyChinese and '技能按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PET_BATTLE_ABILITIES_LABEL, 'Button'))


        WoWTools_PetBattleMixin.Category, WoWTools_PetBattleMixin.Layout= WoWTools_PanelMixin:AddSubCategory({
            name=WoWTools_PetBattleMixin.addName,
            disabled= Save().disabled,
        })

        WoWTools_PanelMixin:Check_Button({
            checkName= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
            GetValue= function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
                Init_Panel()
                WoWTools_PetBattleMixin:Init_TypeButton()--宠物，类型
                WoWTools_PetBattleMixin:Init_AbilityButton()--宠物对战，技能按钮
                WoWTools_PetBattleMixin:ClickToMove_Button()--点击移动，按钮
            end,
            buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
            buttonFunc= function()
                StaticPopup_Show('WoWTools_RestData',
                    WoWTools_PetBattleMixin.addName,
                    nil,
                function()
                    WoWToolsSave['Plus_PetBattle2']= nil
                end)
            end,
            tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
            layout= WoWTools_PetBattleMixin.Layout,
            category= WoWTools_PetBattleMixin.Category,
        })

        if not Save().disabled then
            WoWTools_PetBattleMixin:Init_TypeButton()--宠物，类型
            WoWTools_PetBattleMixin:Init_AbilityButton()--宠物对战，技能按钮
            WoWTools_PetBattleMixin:ClickToMove_Button()--点击移动，按钮
        end

        if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
            Init_Panel()
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end

    elseif arg1=='Blizzard_Settings' and Save() then
        Init_Panel()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)