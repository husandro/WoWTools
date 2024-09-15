local e= select(2, ...)
local function Save()
    return WoWTools_TooltipMixin.Save
end





local wowheadText= 'https://www.wowhead.com/%s=%d'
local raiderioText= 'https://raider.io/characters/%s/%s/%s'




--################
--取得网页，数据链接
--################
local function Init_WoWHeadText()
    local WoWHead= 'https://www.wowhead.com/'
    wowheadText= 'https://www.wowhead.com/%s=%d'
    raiderioText= 'https://raider.io/characters/%s/%s/%s'

    if e.onlyChinese or LOCALE_zhTW then
        WoWHead= 'https://www.wowhead.com/cn/'
        if not LOCALE_zhCN then
            wowheadText= 'https://www.wowhead.com/cn/%s=%d'
        else
            wowheadText= 'https://www.wowhead.com/cn/%s=%d/%s'
        end
        raiderioText= 'https://raider.io/cn/characters/%s/%s/%s'

    elseif LOCALE_deDE then
        WoWHead= 'https://www.wowhead.com/de/'
        wowheadText= 'https://www.wowhead.com/de/%s=%d/%s'
        raiderioText= 'https://raider.io/de/characters/%s/%s/%s'

    elseif LOCALE_esES or LOCALE_esMX then
        WoWHead= 'https://www.wowhead.com/es/'
        wowheadText= 'https://www.wowhead.com/es/%s=%d/%s'
        raiderioText= 'https://raider.io/es/characters/%s/%s/%s'

    elseif LOCALE_frFR then
        WoWHead= 'https://www.wowhead.com/fr/'
        wowheadText= 'https://www.wowhead.com/fr/%s=%d/%s'
        raiderioText= 'https://raider.io/fr/characters/%s/%s/%s'

    elseif LOCALE_itIT then
        WoWHead= 'https://www.wowhead.com/it/'
        wowheadText= 'https://www.wowhead.com/it/%s=%d/%s'
        raiderioText= 'https://raider.io/it/characters/%s/%s/%s'

    elseif LOCALE_ptBR then
        WoWHead= 'https://www.wowhead.com/pt/'
        wowheadText= 'https://www.wowhead.com/pt/%s=%d/%s'
        raiderioText= 'https://raider.io/br/characters/%s/%s/%s'

    elseif LOCALE_ruRU then
        WoWHead= 'https://www.wowhead.com/ru/'
        wowheadText= 'https://www.wowhead.com/ru/%s=%d/%s'
        raiderioText= 'https://raider.io/ru/characters/%s/%s/%s'

    elseif LOCALE_koKR then
        WoWHead= 'https://www.wowhead.com/ko/'
        wowheadText= 'https://www.wowhead.com/ko/%s=%d/%s'
        raiderioText= 'https://raider.io/kr/characters/%s/%s/%s'
    end

    WoWTools_TooltipMixin.WoWHead= WoWHead
end























function WoWTools_TooltipMixin:Set_Web_Link(tooltip, tab)
    if tooltip==ItemRefTooltip or tooltip==FloatingBattlePetTooltip then
        if tab.type and tab.id then
            if not tooltip.WoWHeadButton then
                tooltip.WoWHeadButton=WoWTools_ButtonMixin:Cbtn(tooltip, {size={20,20}, type=false})--取得网页，数据链接
                tooltip.WoWHeadButton:SetPoint('RIGHT',tooltip.CloseButton, 'LEFT',0,2)
                tooltip.WoWHeadButton:SetNormalAtlas('questlegendary')
                tooltip.WoWHeadButton:SetScript('OnClick', function(f)
                    if f.type and f.id then
                        WoWTools_TooltipMixin:Show_URL(true, f.type, f.id, f.name)
                    end
                end)
                function tooltip.WoWHeadButton:rest()
                    self.type=nil
                    self.id=nil
                    self.name=nil
                    self:SetShown(false)
                end
            end
            tooltip.WoWHeadButton.type= tab.type
            tooltip.WoWHeadButton.id= tab.id
            tooltip.WoWHeadButton.name= tab.name
            tooltip.WoWHeadButton:SetShown(true)
        end
        return
    end
    if not Save.ctrl or UnitAffectingCombat('player')  then
        return
    end

    if tab.id then
        if tab.type=='quest' then
            if not tab.name then
                local index= C_QuestLog.GetLogIndexForQuestID(tab.id)
                local info= index and C_QuestLog.GetInfo(index)
                tab.name= info and info.title
            end
        end
        if IsControlKeyDown() and IsShiftKeyDown() then
            WoWTools_TooltipMixin:Show_URL(true, tab.type, tab.id, tab.name)
        else
            if tab.isPetUI then
                if tooltip then
                    BattlePetTooltipTemplate_AddTextLine(tooltip, 'wowhead  Ctrl+Shift')
                end
            elseif tooltip== e.tips then
                tooltip:AddDoubleLine((tab.col or '')..'WoWHead', (tab.col or '')..'Ctrl+Shift')
            end
        end

    elseif tab.unitName then
        if IsControlKeyDown() and IsShiftKeyDown() then
            WoWTools_TooltipMixin:Show_URL(false, nil, tab.realm or e.Player.realm, tab.unitName)
        else
            if tooltip then
                tooltip:SetText('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO Ctrl+Shift')
                tooltip:Show(true)
            else
                e.tips:AddDoubleLine('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO', (tab.col or '')..'Ctrl+Shift')
                e.tips:Show(true)
            end
        end

    elseif tab.name and tooltip then
        if IsControlKeyDown() and IsShiftKeyDown() then
            WoWTools_TooltipMixin:Show_URL(nil, nil, nil, tab.name)
        else
            tooltip:AddDoubleLine((tab.col or '')..'WoWHead', (tab.col or '')..'Ctrl+Shift')
            tooltip:Show()
        end
    end
end






















function WoWTools_TooltipMixin:Init_WoWHeadText()
    Init_WoWHeadText()
end





function WoWTools_TooltipMixin:Show_URL(isWoWHead, typeOrRegion, typeIDOrRealm, name)
    if isWoWHead==true then
        if typeIDOrRealm and type(typeIDOrRealm)~='number' then
            typeIDOrRealm= tonumber(typeIDOrRealm)
        end
        StaticPopup_Show("WoWTools_Tooltips_LinkURL",
            'WoWHead',
            nil,
            format(wowheadText, typeOrRegion or '', typeIDOrRealm or 0, name or '')
        )
    elseif isWoWHead==false then
        StaticPopup_Show("WoWTools_Tooltips_LinkURL",
            'Raider.IO',
            nil,
            format(raiderioText, typeOrRegion or GetCurrentRegionName() or '', typeIDOrRealm or e.Player.realm, name)
        )
    else
        StaticPopup_Show("WoWTools_Tooltips_LinkURL", '', nil, name or '')
   end
end