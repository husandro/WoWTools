
local function Save()
    return WoWToolsSave['Plus_Tootips']
end





local wowheadText= 'https://www.wowhead.com/%s=%d'
local raiderioText= 'https://raider.io/characters/%s/%s/%s'

local wowheadIcon= '|TInterface\\AddOns\\WoWTools\\Source\\Texture\\Wowhead.tga:0|t'


--################
--取得网页，数据链接
--################
local function Init_WoWHeadText()
    local WoWHead= 'https://www.wowhead.com/'
    wowheadText= 'https://www.wowhead.com/%s=%d'
    raiderioText= 'https://raider.io/characters/%s/%s/%s'

    if WoWTools_DataMixin.onlyChinese or LOCALE_zhTW then
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

















local function Create_Button(tooltip)
    
    tooltip.WoWHeadButton=WoWTools_ButtonMixin:Cbtn(tooltip, {--取得网页，数据链接
        size=24,
        isUI=true,
        name=tooltip:GetName()..'_WoWToolsURLButton',
        atlas='questlegendary',
    })
    tooltip.WoWHeadButton:SetPoint('RIGHT',tooltip.CloseButton, 'LEFT')
    tooltip.WoWHeadButton:SetScript('OnClick', function(f)
        if f.type and f.id then
            WoWTools_TooltipMixin:Show_URL(true, f.type, f.id, f.name)
        end
    end)
    tooltip.WoWHeadButton:SetScript('OnLeave', GameTooltip_Hide)
    tooltip.WoWHeadButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOPRIGHT", 0, 18)
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            WoWTools_TooltipMixin.addName,
            'WoWHead URL'
        )
        GameTooltip:Show()
    end)
    function tooltip.WoWHeadButton:rest()
        self.type=nil
        self.id=nil
        self.name=nil
        self:SetShown(false)
    end


    tooltip.AchievementButton=WoWTools_ButtonMixin:Cbtn(tooltip, {--取得网页，数据链接
        size=24,
        isUI=true,
        name=tooltip:GetName()..'_WoWToolsAchievementButton',
        atlas='UI-HUD-MicroMenu-Achievements-Mouseover',
    })
    tooltip.AchievementButton:SetPoint('RIGHT', tooltip.WoWHeadButton, 'LEFT')
    tooltip.AchievementButton:SetScript('OnClick', function(f)
        if f.type and f.achievementID then
            WoWTools_LoadUIMixin:Achievement(f.achievementID)
        end
    end)
    tooltip.AchievementButton:SetScript('OnLeave', GameTooltip_Hide)
    tooltip.AchievementButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOPRIGHT", 0, 18)
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            WoWTools_TooltipMixin.addName,
            WoWTools_DataMixin.onlyChinese and '打开成就' or OBJECTIVES_VIEW_ACHIEVEMENT
        )
        GameTooltip:Show()
    end)
    function tooltip.AchievementButton:rest()
        self.type=nil
        self.id=nil
        self:SetShown(false)
    end
end








local function ItemRefTooltip_URL_Button(tooltip, tab)
    if not tooltip.WoWHeadButton then
        Create_Button(tooltip)
    end

    tooltip.WoWHeadButton.type= tab.type
    tooltip.WoWHeadButton.id= tab.id
    tooltip.WoWHeadButton.name= tab.name
    tooltip.WoWHeadButton:SetShown(tab.type and tab.id)

    tooltip.AchievementButton.type= tab.type
    tooltip.AchievementButton.achievementID= tab.id
    tooltip.AchievementButton:SetShown(tab.type=='achievement' and tab.id)
end




local function GameTooltip_URL(tooltip, tab)
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
                    BattlePetTooltipTemplate_AddTextLine(tooltip, (tab.col or '')..'|A:NPE_Icon:0:0|aCtrl+Shift '..wowheadIcon)
                end
            elseif tooltip== GameTooltip then
                tooltip:AddLine((tab.col or '')..'|A:NPE_Icon:0:0|aCtrl+Shift '..wowheadIcon)
            end
        end

    elseif tab.unitName then
        if IsControlKeyDown() and IsShiftKeyDown() then
            WoWTools_TooltipMixin:Show_URL(false, nil, tab.realm or WoWTools_DataMixin.Player.Realm, tab.unitName)
        else
            if tooltip then
                tooltip:SetText('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO |A:NPE_Icon:0:0|a Ctrl+Shift')
                --tooltip:Show(true)
            else
                GameTooltip:AddLine('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO |A:NPE_Icon:0:0|a Ctrl+Shift')
                --GameTooltip:Show(true)
            end
        end

    elseif tab.name and tooltip then
        if IsControlKeyDown() and IsShiftKeyDown() then
            WoWTools_TooltipMixin:Show_URL(nil, nil, nil, tab.name)
        else
            tooltip:AddLine((tab.col or '')..'|A:NPE_Icon:0:0|aCtrl+Shift '..wowheadIcon)
            --tooltip:Show()
        end
    end
end










--WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='npc', id=npc, name=name, isPetUI=false})--取得网页，数据链接 
function WoWTools_TooltipMixin:Set_Web_Link(tooltip, tab)
    if tooltip==ItemRefTooltip or tooltip==FloatingBattlePetTooltip then
        if tab.type and tab.id then
            ItemRefTooltip_URL_Button(tooltip, tab)
        end
        return
    end

    if not Save().ctrl or InCombatLockdown() then
        return
    end

    GameTooltip_URL(tooltip, tab)
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
        wowheadIcon..' WoWHead',
            nil,
            format(wowheadText, typeOrRegion or '', typeIDOrRealm or 0, name or '')
        )
    elseif isWoWHead==false then
        StaticPopup_Show("WoWTools_Tooltips_LinkURL",
            'Raider.IO',
            nil,
            format(raiderioText, typeOrRegion or GetCurrentRegionName() or '', typeIDOrRealm or WoWTools_DataMixin.Player.Realm, name)
        )
    else
        StaticPopup_Show("WoWTools_Tooltips_LinkURL", '', nil, name or '')
   end
end