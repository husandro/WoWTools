local e= select(2, ...)
local function Save()
    return WoWTools_MarkerMixin.Save
end

local AutoReadyTime--时间
local PlayerNameText--就绪名称

local Checks--选项
local AltCanellText--Alt, 取消提示



local function Get_LeftTime()
    if ReadyCheckListenerFrame.time then
        return select(2, WoWTools_TimeMixin:Info(nil, false, nil, ReadyCheckListenerFrame.time))
    end
end






--设置，就绪，未就绪
local function Set_Ready(timeLeft)

    if AutoReadyTime then
        AutoReadyTime:Cancel()
    end

    if Save().autoReady then
        print(
            WoWTools_MarkerMixin.addName,
            WoWTools_MarkerMixin:Get_ReadyTextIcon(),
            '|cffff00ffAlt', e.onlyChinese and '取消' or CANCEL
        )

        timeLeft= Save().autoReadySeconds or 3
        if not timeLeft then
            local time= Get_LeftTime()
            if time then
                timeLeft= math.mix(timeLeft, time)
            end
        end

        AutoReadyTime= C_Timer.NewTimer(timeLeft, function()
            ConfirmReadyCheck(Save().autoReady==1 and 1 or nil)
            ReadyCheckFrame:SetShown(false)
        end)
    end

    e.Ccool(ReadyCheckListenerFrame, nil, timeLeft or Get_LeftTime() or 35, nil, true, true)--冷却条
end












local function Init_UI()
    if PlayerNameText then
        return
    end

    ReadyCheckFrame:SetHeight(120)--100
    ReadyCheckFrameText:SetPoint('TOP', 20, -45)--="TOP" x="20" y="-37"/>

--就位，玩家，提示
    PlayerNameText= WoWTools_LabelMixin:Create(ReadyCheckListenerFrame, {name='ReadyCheckFramePlayerNameText', justifyH='CENTER'})
    PlayerNameText:SetPoint('BOTTOM', ReadyCheckFrameText, 'TOP', 0, 2)

    Checks={}

    local check
    for i=0, 2 do
        check= CreateFrame('CheckButton', 'WoWToolsChatButtonMarkersReadyCheckButton'..i, ReadyCheckListenerFrame, 'InterfaceOptionsCheckButtonTemplate')
        check:SetPoint('RIGHT', ReadyCheckListenerFrame, 'LEFT', -2, 20-(i*20))
        check.value= i>0 and i or nil

        check.Text:SetText(
            WoWTools_MarkerMixin:Get_ReadyTextIcon(i)
            or (e.onlyChinese and '无' or NONE)
        )
        check.Text:ClearAllPoints()
        check.Text:SetPoint('RIGHT', check, 'LEFT')


        check:SetScript('OnShow', function(self)
            self:SetChecked(self.value== Save().autoReady)
        end)

        check:SetScript('OnMouseDown', function(self)
            Save().autoReady= self.value
            Set_Ready()--设置，就绪，未就绪
            WoWTools_MarkerMixin.MarkerButton:settings()
            for _, btn in pairs(Checks) do
                if btn~=self then
                    btn:SetChecked(false)
                end
            end
            AltCanellText:set_shown()
        end)

        check:SetScript('OnLeave', GameTooltip_Hide)
        check:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self.Text, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(WoWTools_Mixin.addName)
            GameTooltip:AddLine(WoWTools_MarkerMixin.addName)
            GameTooltip:Show()
        end)

        table.insert(Checks, check)
    end

    AltCanellText= WoWTools_LabelMixin:Create(ReadyCheckListenerFrame)
    AltCanellText:SetPoint('TOPRIGHT', check, 'BOTTOMLEFT', 0,-2)
    AltCanellText:SetText('Alt '..(e.onlyChinese and '取消' or CANCEL))
    function AltCanellText:set_shown()
        AltCanellText:SetShown(Save().autoReady)
    end
    AltCanellText:set_shown()
end










--自动就绪
local function Init()

    hooksecurefunc('ShowReadyCheck', function(initiator, timeLeft)--ReadyCheckListenerFrame
        if timeLeft then
            ReadyCheckListenerFrame.time= timeLeft+ GetTime()
        end

        e.PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音

        --initiator= initiator or ReadyCheckFrame.initiator

        if not initiator then-- or UnitIsUnit("player", initiator) then
            return
        end


        Init_UI()


        local name= WoWTools_UnitMixin:GetPlayerInfo(nil, nil, initiator, {reName=true})
        PlayerNameText:SetText(name~='' and name or initiator)

        local _, difficultyID
        difficultyID = select(3, GetInstanceInfo())
        if ( not difficultyID or difficultyID == 0 ) then
            if UnitInRaid("player") then
                difficultyID = GetRaidDifficultyID()
            else
                difficultyID = GetDungeonDifficultyID()
            end
        end

        local difficultyName, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(difficultyID)
        if ( toggleDifficultyID and toggleDifficultyID > 0 ) then
            difficultyName=  WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID) or difficultyName
            ReadyCheckFrameText:SetFormattedText(
                (e.onlyChinese and "%s正在进行就位确认。\n团队副本难度: |cnGREEN_FONT_COLOR:" or READY_CHECK_MESSAGE..'|n'..RAID_DIFFICULTY..': ')
                ..difficultyName..'|r', '')
        else
           ReadyCheckFrameText:SetFormattedText(e.onlyChinese and '%s正在进行就位确认。' or READY_CHECK_MESSAGE, '')
       end

        Set_Ready(timeLeft)--设置，就绪，未就绪
    end)



    

    ReadyCheckListenerFrame:HookScript('OnHide', function(self)
        if PlayerNameText then
            PlayerNameText:SetText("")
        end
        if AutoReadyTime then
            AutoReadyTime:Cancel()
        end
        e.Ccool(self)
        self.time= nil
    end)


    ReadyCheckListenerFrame:HookScript('OnUpdate', function(self)
        if AutoReadyTime
            and not AutoReadyTime:IsCancelled()
            and IsModifierKeyDown()
        then

            AutoReadyTime:Cancel()

            print(
                WoWTools_MarkerMixin.addName,
                WoWTools_MarkerMixin:Get_ReadyTextIcon(),
                '|cff00ff00'..(e.onlyChinese and '取消' or CANCEL)
            )

            e.Ccool(ReadyCheckListenerFrame, nil, Get_LeftTime(), nil, true, true)--冷却条
        end
    end)

end


--ReadyCheckFrame
--ReadyCheckListenerFrame


function WoWTools_MarkerMixin:Init_AutoReady()
    Init()
end
