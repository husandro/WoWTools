
local function Save()
    return WoWToolsSave['ChatButton_Invite'] or {}
end






local ClearFoucsFrame
--Shift+点击设置焦点
--跟随，密语
--鼠标按键 1是左键、2是右键、3是中键


local function Init()
    if not Save().setFucus then
        return
    end

    local key= strlower(Save().focusKey)
--清除，焦点
    ClearFoucsFrame= CreateFrame('Button', 'WoWToolsClearFocusButton', UIParent, 'SecureActionButtonTemplate')
    --WoWTools_ButtonMixin:Cbtn(nil, {isSecure=true,name='WoWToolsClearFocusButton'})
    ClearFoucsFrame:SetAttribute('type1','macro')
    ClearFoucsFrame:SetAttribute('macrotext1','/clearfocus')
--ClearFoucsFrame:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    ClearFoucsFrame:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown)
    --ClearFoucsFrame:SetAttribute('type1', 'focus')
    --ClearFoucsFrame:SetAttribute('unit1', 'player')
    --SetOverrideBindingClick(ClearFoucsFrame, true, strupper(key)..'-BUTTON2','WoWToolsClearFocusButton')

    WoWTools_KeyMixin:SetButtonKey(ClearFoucsFrame, true, strupper(key)..'-BUTTON2', nil)--设置, 快捷键


--设置单位焦点
    local btn= CreateFrame('Button', 'WoWToolsOverFocusButton', UIParent, 'SecureActionButtonTemplate')
    --WoWTools_ButtonMixin:Cbtn(nil, {isSecure=true,name='WoWToolsOverFocusButton'})
    btn:SetAttribute("type1", "focus")
    btn:SetAttribute('unit1', 'mouseover')
    btn:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown)
    WoWTools_KeyMixin:SetButtonKey(btn, true, strupper(key)..'-BUTTON1', nil)--设置, 快捷键





    ClearFoucsFrame.key= key
    ClearFoucsFrame.frames={}

    function ClearFoucsFrame:set_event(frame)
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        self.frames[frame]=true
    end

    --跟随，密语
    function ClearFoucsFrame:set_say_follow(frame)
        if not Save().setFrameFun or not frame or not frame:CanChangeAttribute() then--or not (frame.unit and frame:GetAttribute('unit')) then
            return
        end
        frame:EnableMouseWheel(true)
        frame:HookScript('OnMouseWheel', function(f, d)
            local unit= canaccessvalue(f.unit) and f.unit
            unit= unit or f:GetAttribute('unit') or f:GetAttribute('unit1')
            if WoWTools_UnitMixin:UnitIsUnit('player', unit)==false
                and unit
                and WoWTools_UnitMixin:UnitExists(unit)
                and UnitIsPlayer(unit)
                and UnitIsFriend('player', unit)
            then
                if d==1 then
                    WoWTools_ChatMixin:Say(nil, UnitName(unit), nil, nil)--密语
                elseif d==-1 then
                    FollowUnit(unit)--跟随
                end
            end
        end)
    end

    --设置, 属性
    function ClearFoucsFrame:set_key(frame)
        if not frame then
            return
        end
        if frame:CanChangeAttribute() then
            if frame==FocusFrame then
                frame:SetAttribute(key..'-type1','macro')
                frame:SetAttribute(key..'-macrotext1','/clearfocus')
                --[[frame:SetAttribute(key..'-type1', 'focus')
                frame:SetAttribute('unit1', nil)]]
            else
                frame:SetAttribute(self.key..'-type1', 'focus')--设置, 属性
            end
        else
            self:set_event(frame)
        end
    end

    ClearFoucsFrame:SetScript('OnEvent', function(self)
        for frame, _ in pairs(self.frames) do
            self:set_key(frame)
        end
        self.frames={}
        self:UnregisterAllEvents()
    end)



    local tab = {
        PlayerFrame,
        PetFrame,
        TargetFrame,
        TargetFrameToT,
        FocusFrameToT,
        FocusFrame,
    }


    for i=1, MAX_PARTY_MEMBERS do--队伍
        local member= 'MemberFrame'..i
        if PartyFrame and PartyFrame[member] then
            table.insert(tab, PartyFrame[member])
--UnitFrame.lua
            if PartyFrame[member].potFrame then
                table.insert(tab, PartyFrame[member].potFrame)
            end
        end
        table.insert(tab, _G['CompactPartyFrameMember'..i])

        local frame= _G['CompactPartyFrameMember'..i]
        if frame then
            table.insert(tab, frame)
        end
    end

    for i=1, MAX_BOSS_FRAMES do--boss
        local frame= _G['Boss'..i..'TargetFrame']
        if frame then
            table.insert(tab, frame)
--UnitFrame.lua
            if frame.BossButton then
                table.insert(tab, frame.BossButton)
            end
            if frame.TotButton then
                table.insert(tab, frame.TotButton)
            end
        end
    end

    do
        for _, frame in pairs(tab) do--设置焦点
            if frame then
                ClearFoucsFrame:set_key(frame)
                ClearFoucsFrame:set_say_follow(frame)
            end
        end
    end
    tab=nil


    WoWTools_DataMixin:Hook('CompactRaidGroup_InitializeForGroup', function(self)--, groupIndex)
        for i=1, MEMBERS_PER_RAID_GROUP do
            local frame= _G[self:GetName().."Member"..i]
            if frame then
                ClearFoucsFrame:set_key(frame)
                ClearFoucsFrame:set_say_follow(frame)
            end
        end
    end)

    Init=function()end
end













function WoWTools_InviteMixin:Init_Focus()
    Init()
end

