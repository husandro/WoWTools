
local function Save()
    return WoWToolsSave['ChatButton_Invite'] or {}
end






local ClearFoucsFrame
--Shift+点击设置焦点
--跟随，密语
--鼠标按键 1是左键、2是右键、3是中键


local function Init()
    local key= strlower(Save().focusKey)

    ClearFoucsFrame= WoWTools_ButtonMixin:Cbtn(nil, {
        isSecure=true,
        name='WoWToolsClearFocusButton'
    })--清除，焦点
    --ClearFoucsFrame:SetAttribute('type1','macro')
    --ClearFoucsFrame:SetAttribute('macrotext','/clearfocus')

    ClearFoucsFrame:SetAttribute('type1','focus')
    ClearFoucsFrame:SetAttribute('unit', nil)

    WoWTools_KeyMixin:SetButtonKey(ClearFoucsFrame, true, strupper(key)..'-BUTTON2', nil)--设置, 快捷键



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
            local unit= f.unit or f:GetAttribute('unit')
            if UnitExists(unit)
                and UnitIsPlayer(unit)
                and not UnitIsUnit('player', unit)
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
                --frame:SetAttribute(key..'-type1','macro')
                --frame:SetAttribute(key..'-macrotext1','/clearfocus')
                frame:SetAttribute(key..'-type1', 'focus')
                frame:SetAttribute('unit', nil)
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

    for _, frame in pairs(tab) do--设置焦点
        if frame then
            ClearFoucsFrame:set_key(frame)
            ClearFoucsFrame:set_say_follow(frame)
        end
    end

    tab=nil


    --设置单位焦点
    local btn= WoWTools_ButtonMixin:Cbtn(nil, {
        isSecure=true,
        name='WoWToolsOverFocusButton'
    })
    btn:SetAttribute("type1", "focus")
    btn:SetAttribute('unit', 'mouseover')
    WoWTools_KeyMixin:SetButtonKey(btn, true, strupper(key)..'-BUTTON1', nil)--设置, 快捷键


    --[[hooksecurefunc("CreateFrame", function(_, name, _, template)--为新的框架，加属性
        local frame= name and _G[name]
        if template
            and (
                template:find("SecureUnitButtonTemplate")
            )
            and frame
            and not frame:GetAttribute(ClearFoucsFrame.key..'-type1')
        then
        
            ClearFoucsFrame:set_key(frame)
            ClearFoucsFrame:set_say_follow(frame)
        end
    end)]]



    hooksecurefunc('CompactRaidGroup_InitializeForGroup', function(self)--, groupIndex)
        for i=1, MEMBERS_PER_RAID_GROUP do
            local frame= _G[self:GetName().."Member"..i]
            ClearFoucsFrame:set_key(frame)
            ClearFoucsFrame:set_say_follow(frame)
        end
    end)

    return true
end













function WoWTools_InviteMixin:Init_Focus()
    if Save().setFucus and Init() then
        Init=function()end
    end
end

