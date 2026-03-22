
local function Save()
    return WoWToolsSave['ChatButton_Invite'] or {}
end
--Shift+点击设置焦点
--跟随，密语
--鼠标按键 1是左键、2是右键、3是中键



function WoWTools_InviteMixin:SetFocusButton(frame)
    if not frame or not Save().setFucus or frame.isSetFoucs then
        return

    elseif not frame:CanChangeAttribute() then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:SetFocusButton(frame)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
        return
    end

--设置，焦点
    local key= strlower(Save().focusKey or 'Shift')
    if frame==FocusFrame then--清除，焦点
        frame:SetAttribute(key..'-type1','macro')
        frame:SetAttribute(key..'-macrotext1','/clearfocus')
    else
        frame:SetAttribute(key..'-type1', 'focus')
        frame:SetAttribute(key..'-type2', 'macro')
        frame:SetAttribute(key..'-macrotext2', '/clearfocus')
    end

    frame.isSetFoucs= true

--跟随，密语 
    if not Save().setFrameFun then
        return
    end

    frame:EnableMouseWheel(true)
    frame:HookScript('OnMouseWheel', function(f, d)
        local unit= f.unit
        if WoWTools_UnitMixin:UnitIsUnit('player', unit)==false
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





--设置单位焦点 跟随 密语
local function Init()
    if not Save().setFucus then
        return
    end

    local key= strlower(Save().focusKey or 'Shift')
--清除，焦点
    local clear= CreateFrame('Button', 'WoWToolsClearFocusButton', UIParent, 'SecureActionButtonTemplate')
    clear:SetAttribute('type','macro')
    clear:SetAttribute('macrotext','/clearfocus')
    clear:RegisterForClicks(WoWTools_DataMixin.RightButtonDown)
    WoWTools_KeyMixin:SetButtonKey(clear, true, strupper(key)..'-BUTTON2', nil)

--设置单位焦点
    local over= CreateFrame('Button', 'WoWToolsOverFocusButton', UIParent, 'SecureActionButtonTemplate')
    over:SetAttribute("type", "focus")
    over:SetAttribute('unit', 'mouseover')

    over:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown)--, WoWTools_DataMixin.RightButtonDown)
    WoWTools_KeyMixin:SetButtonKey(over, true, strupper(key)..'-BUTTON1', nil)



    WoWTools_InviteMixin:SetFocusButton(PlayerFrame)
    WoWTools_InviteMixin:SetFocusButton(PetFrame)
    WoWTools_InviteMixin:SetFocusButton(TargetFrame)
    WoWTools_InviteMixin:SetFocusButton(TargetFrameToT)
    WoWTools_InviteMixin:SetFocusButton(FocusFrame)
    WoWTools_InviteMixin:SetFocusButton(FocusFrameToT)

    for i=1, MAX_PARTY_MEMBERS do--队伍        
        WoWTools_InviteMixin:SetFocusButton(PartyFrame['MemberFrame'..i])
        WoWTools_InviteMixin:SetFocusButton(_G['CompactPartyFrameMember'..i])
    end

    for i=1, MAX_BOSS_FRAMES do--boss
        WoWTools_InviteMixin:SetFocusButton(_G['Boss'..i..'TargetFrame'])

    end

    WoWTools_DataMixin:Hook('CompactRaidGroup_InitializeForGroup', function(self)
        for i=1, MEMBERS_PER_RAID_GROUP do
            WoWTools_InviteMixin:SetFocusButton(_G[self:GetName().."Member"..i])
        end
    end)

    Init=function()end
end













function WoWTools_InviteMixin:Init_Focus()
    Init()
end

