local e= select(2, ...)

local function Save()
    return WoWTools_AttributesMixin.Save
end






local function Init()
    local button= WoWTools_ButtonMixin:Cbtn(nil, {icon='hide', size={22,22}, isType2=true, name='WoWTools_AttributesButton'})
    WoWTools_AttributesMixin.Button= button

    button.frame= CreateFrame("Frame",nil,button)

    button.texture= button:CreateTexture(nil, 'BORDER')
    button.texture:SetSize(18,18)
    button.texture:SetPoint('CENTER')

    button.classPortrait= button:CreateTexture(nil, 'OVERLAY', nil)--加个外框
    button.classPortrait:SetPoint('CENTER',1,-1)
    button.classPortrait:SetSize(24,24)
    button.classPortrait:SetAtlas('bag-reagent-border')
    button.classPortrait:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

    function button:get_Att_Text_Chat()--属性，内容
        local text=''
        local specIndex= GetSpecialization()
        if specIndex then
            local specID= GetSpecializationInfo(specIndex)
            if specID then
                local specTab= C_SpecializationInfo.GetSpellsDisplay(specID) or {}
                for _, spellID in pairs (specTab) do
                    local link= C_Spell.GetSpellLink(spellID)
                    if link then
                        text= link
                        break
                    end
                end
            end
        end
        text= text..'HP'..WoWTools_Mixin:MK(UnitHealthMax('player'), 0)

        for _, info in pairs(WoWTools_AttributesMixin:Get_Tabs()) do
            local frame=button[info.name]
            if not info.hide and info.name~='SPEED' and frame and frame:IsShown() and frame.value and frame.value>0 then
                local value= frame.text:GetText()
                if value then
                    text= text..', '..info.text..value
                end
            end
        end
        return text
    end

    function button:get_sendTextTips()
        local text
        if ChatEdit_GetActiveWindow() then
            text= e.onlyChinese and '编辑' or EDIT
        elseif UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
            text= (e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..': '.. GetUnitName('target', true)
        elseif not UnitIsDeadOrGhost('player') and IsInInstance() then
            text= (e.onlyChinese and '说' or SAY)
        elseif IsInRaid() then
            text= e.onlyChinese and '说: 团队' or (SAY..': '..CHAT_MSG_RAID)
        elseif IsInGroup() then
            text= e.onlyChinese and '说: 队伍' or (SAY..': '..CHAT_MSG_PARTY)
        else
            text= (e.onlyChinese and '说' or SAY)
        end
        return text
    end

    function button:send_Att_Chat()--发送信息
        local text= self:get_Att_Text_Chat()
        if ChatEdit_GetActiveWindow() then
            ChatEdit_InsertLink(text)
        else
            local name
            if UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
                name= GetUnitName('target', true)
            end
            WoWTools_ChatMixin:Chat(text, name, nil)
        end
    end

    function button:set_Show_Hide()--显示， 隐藏
        self.frame:SetShown(not Save().hide)
        self.texture:SetAlpha(Save().hide and 1 or Save().buttonAlpha or 0.3)
        self.classPortrait:SetAlpha(Save().hide and 1 or Save().buttonAlpha or 0)
        self:SetScale(Save().buttonScale or 1)
    end

    function button:set_Point()--设置, 位置
        self:ClearAllPoints()
        if Save().point then
            button:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
        elseif e.Player.husandro then
            button:SetPoint('LEFT', PlayerFrame, 'RIGHT', 25, 35)
        else
            button:SetPoint('LEFT', 23, 180)
        end
    end


    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)
    button:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save().point={self:GetPoint(1)}
        Save().point[2]=nil
    end)



    function button:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_AttributesMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '重置' or RESET, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.GetShowHide(not Save().hide), e.Icon.mid)
        e.tips:AddDoubleLine(self:get_sendTextTips(), 'Shift+'..e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:Show()
    end





    button:SetScript("OnMouseUp", ResetCursor)
    button:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='LeftButton' and not IsModifierKeyDown() then
            WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
            print(e.addName, WoWTools_AttributesMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET)..'|r', e.onlyChinese and '数值' or STATUS_TEXT_VALUE)

        elseif d=='RightButton' and IsShiftKeyDown() then
            self:send_Att_Chat()--发送信息

        elseif d=='RightButton' and not IsModifierKeyDown() then
            WoWTools_AttributesMixin:Init_Menu(self)

        end
        self:set_tooltip()
    end)



    button:SetScript('OnMouseWheel', function(self, d)
        if d==1 then
            Save().hide= true
        elseif d==-1 then
            Save().hide= nil
        end
        self:set_Show_Hide()--显示， 隐藏
        self:set_tooltip()
    end)

    button:SetScript("OnLeave",function(self) ResetCursor() e.tips:Hide() self:set_Show_Hide() end)

    button:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self.texture:SetAlpha(1)
        self.classPortrait:SetAlpha(1)
    end)


    function button:settings()
        if Save().hideInPetBattle then
            self:SetShown(
                not C_PetBattles.IsInBattle()
                and not UnitHasVehicleUI('player')
            )
        else
            self:SetShown(true)
        end
    end
    function button:set_event()
        self:UnregisterAllEvents()
        if Save().hideInPetBattle then
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('UNIT_ENTERED_VEHICLE')
            self:RegisterEvent('UNIT_EXITED_VEHICLE')
        end
    end
    button:SetScript('OnEvent', button.settings)








    button:set_event()
    button:settings()
    button:set_Point()--设置, 位置
    button:set_Show_Hide()--显示， 隐藏
















    C_Timer.After(4, function()
        button.frame:SetPoint('BOTTOM')
        button.frame:SetSize(1, 1)
        if Save().scale and Save().scale~=1 then--缩放
            button.frame:SetScale(Save().scale)
        end
        button.frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')

        button.frame:RegisterEvent('PLAYER_AVG_ITEM_LEVEL_UPDATE')
        button.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        button.frame:RegisterEvent('PLAYER_TALENT_UPDATE')
        button.frame:RegisterEvent('CHALLENGE_MODE_START')
        button.frame:RegisterEvent('SOCKET_INFO_SUCCESS')
        button.frame:RegisterEvent('SOCKET_INFO_UPDATE')
       -- button.frame:RegisterEvent('PLAYER_LEVEL_CHANGED')

        button.frame:RegisterUnitEvent('UNIT_DEFENSE', "player")
        button.frame:RegisterUnitEvent('UNIT_DAMAGE', 'player')
        button.frame:RegisterUnitEvent('UNIT_RANGEDDAMAGE', 'player')

        button.frame:RegisterUnitEvent('UNIT_AURA', 'player')

        button.frame:SetScript("OnEvent", function(_, event)
            if event=='PLAYER_SPECIALIZATION_CHANGED' then
                WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
            elseif event=='AVOIDANCE_UPDATE'
                or event=='LIFESTEAL_UPDATE'
                or event=='UNIT_DAMAGE'
                or event=='UNIT_DEFENSE'
                or event=='UNIT_RANGEDDAMAGE'
                or event=='UNIT_AURA' then
                WoWTools_AttributesMixin:Frame_Init()--初始， 或设置
            else
                WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
            end
        end)

        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)
end












function WoWTools_AttributesMixin:Create_Button()
    Init()
end