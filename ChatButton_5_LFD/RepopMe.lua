--仅限战场，释放, 复活
local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end
local Frame




local function Settings(self)

    self:UnregisterAllEvents()

    if Save().ReMe then
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:RegisterEvent('PLAYER_DEAD')

        if WoWTools_MapMixin:IsInPvPArea() then
            self:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')

        elseif  Save().ReMe_AllZone then
            self:RegisterEvent('CORPSE_IN_RANGE')
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
            local time= GetReleaseTimeRemaining() or 0
            print(
                WoWTools_LFDMixin.addName,
                '|cnRED_FONT_COLOR:'..(e.onlyChinese and '所有地区' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, VIDEO_OPTIONS_EVERYTHING, ZONE))..'|r',
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复活' or RESURRECT)..'|r', WoWTools_TimeMixin:SecondsToClock(time)
            )
        end


    elseif event=='AREA_SPIRIT_HEALER_IN_RANGE' then

        AcceptAreaSpiritHeal()--在范围内时在战场上注册灵魂治疗师的复活计时器

        print(WoWTools_LFDMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复活' or RESURRECT))

        local time= GetAreaSpiritHealerTime()
        if time>0 then
            print(e.onlyChinese and '|cffff2020灵魂医者|r' or SPIRIT_HEALER_RELEASE_RED, WoWTools_TimeMixin:SecondsToClock(time))
        end

    elseif event=='CORPSE_IN_RANGE' then
        local time= GetReleaseTimeRemaining() or 0
        if time==0 then
            RetrieveCorpse()--当玩家站在它的尸体附近时复活。
            print(
                WoWTools_ChatButtonMixin.addName,
                WoWTools_LFDMixin.addName,
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复活' or RESURRECT)
            )
        else
            print(
                WoWTools_LFDMixin.addName,
                '|cnRED_FONT_COLOR:'..(e.onlyChinese and '所有地区' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, VIDEO_OPTIONS_EVERYTHING, ZONE))..'|r',
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复活' or RESURRECT)..'|r', WoWTools_TimeMixin:SecondsToClock(time)
            )
            print('|cffff00ffAlt', e.onlyChinese and '取消' or  CANCEL)
        end
        self:SetShown(time>0)
    end
end



local function Set_Updata(self)
    if IsModifierKeyDown() then
        print(WoWTools_LFDMixin.addName, e.onlyChinese and '取消' or  CANCEL, e.onlyChinese and '复活' or RESURRECT)
        self:Hide()

    elseif GetReleaseTimeRemaining()==0 then
        RetrieveCorpse()--当玩家站在它的尸体附近时复活。
    end
end





local function Init()
    if Frame then
        Settings(Frame)
    else
        Frame= CreateFrame('Frame')
        Frame:Hide()
        Frame:SetScript('OnEvent', Event)
        Frame:SetScript('OnUpdate', Set_Updata)
        Settings(Frame)
    end
end







function WoWTools_LFDMixin:Init_RepopMe()--仅限战场，释放, 复活
    Init()
end
