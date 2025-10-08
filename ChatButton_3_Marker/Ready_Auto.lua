
local function Save()
    return WoWToolsSave['ChatButton_Markers'] or {}
end

local function Get_LeftTime()
    if ReadyCheckListenerFrame.time then
        return select(2, WoWTools_TimeMixin:Info(nil, false, nil, ReadyCheckListenerFrame.time))
    end
end

local AutoReadyTime--时间
local PlayerNameText--就绪名称

local Checks={}--选项
local AltCanellText--Alt, 取消提示









--设置，就绪，未就绪
local function Set_Ready(timeLeft)

    if AutoReadyTime then
        AutoReadyTime:Cancel()
        AutoReadyTime= nil
    end

    local autoReady= Save().autoReady

    if autoReady then
        print(
            WoWTools_MarkerMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_MarkerMixin:Get_ReadyTextAtlas(autoReady),
            '|cffff00ffAlt', WoWTools_DataMixin.onlyChinese and '取消' or CANCEL
        )

        timeLeft= Save().autoReadySeconds or 3

        if not timeLeft then
            local time= Get_LeftTime()
            if time then
                timeLeft= math.mix(timeLeft, time)
            end
        end

        AutoReadyTime= C_Timer.NewTimer(timeLeft, function()
            if ReadyCheckFrame:IsShown() then
                ConfirmReadyCheck(autoReady==1 and 1 or nil)
                ReadyCheckFrame:SetShown(false)
            end
        end)
    end

    WoWTools_CooldownMixin:Setup(ReadyCheckListenerFrame, nil, timeLeft or Get_LeftTime() or 35, nil, true, true)--冷却条
end












local function Init_UI()
    ReadyCheckFrame:SetHeight(120)--100
    ReadyCheckFrameText:SetPoint('TOP', 20, -45)--="TOP" x="20" y="-37"/>

--就位，玩家，提示
    PlayerNameText= WoWTools_LabelMixin:Create(ReadyCheckListenerFrame, {
        name='ReadyCheckFramePlayerNameText',
        justifyH='CENTER'
    })
    PlayerNameText:SetPoint('BOTTOM', ReadyCheckFrameText, 'TOP', 0, 2)




    for i=0, 2 do
        Checks[i]= WoWTools_ButtonMixin:Cbtn(ReadyCheckListenerFrame, {
            name='WoWToolsChatButtonMarkersReadyCheckButton'..i,
            isCheck=true,
            text= WoWTools_MarkerMixin:Get_ReadyTextAtlas(i) or (WoWTools_DataMixin.onlyChinese and '无' or NONE),
            isRightText=true,
        })

        Checks[i]:SetPoint('RIGHT', ReadyCheckListenerFrame, 'LEFT', -2, 20-(i*20))
        Checks[i].value= i>0 and i or nil

        Checks[i]:SetScript('OnShow', function(self)
            self:SetChecked(self.value== Save().autoReady)
        end)

        Checks[i].settings= function(self)
            Save().autoReady= self.value
            Set_Ready()--设置，就绪，未就绪
            WoWTools_ChatMixin:GetButtonForName('Markers'):settings()
            for _, btn in pairs(Checks) do
                if btn~=self then
                    btn:SetChecked(false)
                end
            end
            AltCanellText:set_shown()
        end
        Checks[i].tooltip= function(_, tooltip)
            tooltip:AddLine(WoWTools_DataMixin.addName)
            tooltip:AddLine(WoWTools_MarkerMixin.addName)
        end

        --table.insert(Checks, check)
    end

    AltCanellText= WoWTools_LabelMixin:Create(ReadyCheckListenerFrame)
    AltCanellText:SetPoint('TOPRIGHT', Checks[2], 'BOTTOMLEFT', 0,-2)
    AltCanellText:SetText('Alt '..(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL))

    function AltCanellText:set_shown()
        AltCanellText:SetShown(Save().autoReady)
    end
    AltCanellText:set_shown()

    Init_UI=function()end
end










--自动就绪
local function Init()

    WoWTools_DataMixin:Hook('ShowReadyCheck', function(initiator, timeLeft)--ReadyCheckListenerFrame
        if timeLeft then
            ReadyCheckListenerFrame.time= timeLeft+ GetTime()
        end

        WoWTools_DataMixin:PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音

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
                (WoWTools_DataMixin.onlyChinese and "%s正在进行就位确认。\n团队副本难度: |cnGREEN_FONT_COLOR:" or READY_CHECK_MESSAGE..'|n'..RAID_DIFFICULTY..': ')
                ..difficultyName..'|r', '')
        else
           ReadyCheckFrameText:SetFormattedText(WoWTools_DataMixin.onlyChinese and '%s正在进行就位确认。' or READY_CHECK_MESSAGE, '')
       end

        Set_Ready(timeLeft)--设置，就绪，未就绪
    end)





    ReadyCheckListenerFrame:HookScript('OnHide', function(self)
        if PlayerNameText then
            PlayerNameText:SetText("")
        end
        if AutoReadyTime then
            AutoReadyTime:Cancel()
            AutoReadyTime= nil
        end
        self.time= nil
    end)


    ReadyCheckListenerFrame:HookScript('OnUpdate', function(self)
        if AutoReadyTime
            and not AutoReadyTime:IsCancelled()
            and IsModifierKeyDown()
        then

            AutoReadyTime:Cancel()
            AutoReadyTime= nil

            print(
                WoWTools_MarkerMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_MarkerMixin:Get_ReadyTextAtlas(),
                '|cff00ff00'..(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL)
            )

            WoWTools_CooldownMixin:Setup(self, nil, Get_LeftTime(), nil, true, true)--冷却条
        end
    end)

     Init=function()end
end


--ReadyCheckFrame
--ReadyCheckListenerFrame


function WoWTools_MarkerMixin:Init_AutoReady()
    Init()
end
