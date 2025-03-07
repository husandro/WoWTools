--释放, 复活
local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end
local Frame




local function Settings(self)

    self:UnregisterAllEvents()

    if Save().ReMe then
        self:RegisterEvent('PLAYER_ENTERING_WORLD')


        if WoWTools_MapMixin:IsInPvPArea() then
            self:RegisterEvent('PLAYER_DEAD')
            self:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')

        elseif
            Save().ReMe_AllZone and
            (not IsInInstance() or not IsInGroup('LE_PARTY_CATEGORY_HOME'))
        then
            self:RegisterEvent('PLAYER_DEAD')
            self:RegisterEvent('CORPSE_IN_RANGE')
            self:RegisterEvent('CORPSE_OUT_OF_RANGE')
        end
    end
end








local function Event(self, event)

    if event=='PLAYER_ENTERING_WORLD' then
        Settings(self)

    elseif event=='PLAYER_DEAD' then
        if HasNoReleaseAura() then
            return
        end

        RepopMe()--死后将你的幽灵释放到墓地。

        if WoWTools_MapMixin:IsInPvPArea() then
            print(WoWTools_LFDMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '释放' or BATTLE_PET_RELEASE)..'|r')

        else

            print(
                WoWTools_LFDMixin.addName,
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '释放' or BATTLE_PET_RELEASE)..'|r', SecondsToTime(GetCorpseRecoveryDelay() or 0)
            )
        end


    elseif event=='AREA_SPIRIT_HEALER_IN_RANGE' then

        AcceptAreaSpiritHeal()--在范围内时在战场上注册灵魂治疗师的复活计时器

        print(WoWTools_LFDMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复活' or RESURRECT))

        local time= GetAreaSpiritHealerTime()
        if time>0 then
            print(e.onlyChinese and '|cffff2020灵魂医者|r' or SPIRIT_HEALER_RELEASE_RED, SecondsToTime(time))
        end

    elseif event=='CORPSE_IN_RANGE' then
        local time= GetCorpseRecoveryDelay()
        if time==0 then

            C_Timer.After(1, function()
                RetrieveCorpse()--当玩家站在它的尸体附近时复活。
                print(
                    WoWTools_LFDMixin.addName,
                    '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复活' or RESURRECT)
                )
            end)
            self:SetShown(false)

        else

            print(
                WoWTools_LFDMixin.addName,
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复活' or RESURRECT)..'|r', SecondsToTime(time)
            )
            print('|cffff00ffAlt', e.onlyChinese and '取消' or  CANCEL)
            self:SetShown(true)

        end

    elseif event=='CORPSE_OUT_OF_RANGE' then
        self:SetShown(false)

    end
end



local function Set_Updata(self)
    if IsModifierKeyDown() then
        print(
            WoWTools_LFDMixin.addName,
            '|cnGREEN_FONT_COLOR:'..((e.onlyChinese and '取消复活' or CANCEL)..'|r' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CANCEL, RESURRECT))
        )
        self:Hide()

    elseif GetCorpseRecoveryDelay()==0 then
        C_Timer.After(1, function() RetrieveCorpse() end)--当玩家站在它的尸体附近时复活。
        self:Hide()
    end
end





local function Init()
    if Frame or not Save().ReMe then
        if Frame then
            Settings(Frame)
        end
    else
        Frame= CreateFrame('Frame')
        Frame:Hide()
        Frame:SetScript('OnEvent', Event)
        Frame:SetScript('OnUpdate', Set_Updata)
        Settings(Frame)
    end
end







function WoWTools_LFDMixin:Init_RepopMe()--释放, 复活
    Init()
end
