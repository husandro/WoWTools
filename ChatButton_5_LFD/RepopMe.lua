--仅限战场，释放, 复活
local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end
local Frame










local function Init()
    Frame= CreateFrame('Frame')

    function Frame:set_event()
        self:UnregisterAllEvents()

        if Save().ReMe then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')

            if WoWTools_MapMixin:IsInPvPArea() or WoWTools_LFDMixin.ReMe_AllZone then--WoWTools_LFDMixin.ReMe_AllZone所有地区
                self:RegisterEvent('CORPSE_IN_RANGE')
                self:RegisterEvent('PLAYER_DEAD')
                self:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')
            end
        end
    end
    

    Frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_event()
        else
        print(event)
            if event=='PLAYER_DEAD' then
                print(
                    WoWTools_Mixin.addName,
                    WoWTools_LFDMixin.addName,
                    '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '释放, 复活' or (BATTLE_PET_RELEASE..', '..RESURRECT))
                )
            end
            RepopMe()--死后将你的幽灵释放到墓地。
            RetrieveCorpse()--当玩家站在它的尸体附近时复活。
            AcceptAreaSpiritHeal()--在范围内时在战场上注册灵魂治疗师的复活计时器
        end
    end)

    Frame:set_event()
end









function WoWTools_LFDMixin:Init_RepopMe()--仅限战场，释放, 复活
    Init()
end

function WoWTools_LFDMixin:RepopMe_SetEvent()
    Frame:set_event()
end
