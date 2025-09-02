function WoWTools_DataMixin:Call(func, ...)
    if func then
        securecallfunction(func, ...)
    elseif WoWTools_DataMixin.Player.husandro then
        print('Call 没有发现', func, ...)
    end
end



--[[
AccountUtil.lua
FriendsFrame.lua
BnetShared.lua 
BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_APP = "App";
BNET_CLIENT_HEROES = "Hero";
BNET_CLIENT_CLNT = "CLNT";

function WoWTools_DataMixin:GetWoWTexture()
    local texture
    C_Texture.GetTitleIconTexture(BNET_CLIENT_WOW, Enum.TitleIconVersion.Small, function(success, icon)
        if success and texture then
            texture= icon
        end
    end)
    return texture
end
]]





function WoWTools_DataMixin:Load(tab)--WoWTools_DataMixin:Load({id=, type=''})--加载 item quest spell, uiMapID
    if not tab or not tab.id then
        return
    end
    if tab.type=='quest' then --WoWTools_DataMixin:Load({id=, type='quest'})
        C_QuestLog.RequestLoadQuestByID(tab.id)
        if not HaveQuestRewardData(tab.id) then
            C_TaskQuest.RequestPreloadRewardData(tab.id)
        end

    elseif tab.type=='spell' then--WoWTools_DataMixin:Load({id=, type='spell'})
        local spellID= tab.id
        if type(tab.id)=='string' then
            spellID= (C_Spell.GetSpellInfo(tab.id) or {}).spellID
        end
        if spellID and not C_Spell.IsSpellDataCached(spellID) then
            C_Spell.RequestLoadSpellData(spellID)
        end

    elseif tab.type=='item' then--WoWTools_DataMixin:Load({id=, type='item'})
        local item= tab.itemLink or tab.id-- tab.id or (tab.itemLink and tab.itemLink:match('|Hitem:(%d+):'))
        if item and not C_Item.IsItemDataCachedByID(item) then
            C_Item.RequestLoadItemDataByID(item)
        end
    elseif tab.type=='itemLocation' then
        if not C_Item.IsItemDataCached(tab.id) then
            C_Item.RequestLoadItemData(tab.id)
        end

    elseif tab.type=='mapChallengeModeID' then--WoWTools_DataMixin:Load({id=, type='mapChallengeModeID'})
        C_ChallengeMode.RequestLeaders(tab.id)

    elseif tab.typ=='club' then--WoWTools_DataMixin:Load({id=, type='club'})
        return C_ClubFinder.RequestPostingInformationFromClubId(tab.id)
        --C_Club.RequestTickets(tab.id)
    end
end


local itemLoadTab={--加载法术,或物品数据
        134020,--玩具,大厨的帽子
        --6948,--炉石
        --140192,--达拉然炉石
        --110560,--要塞炉石
        5512,--治疗石
        8529,--诺格弗格药剂
        226373,--/恒久诺格弗格药剂
        38682,--附魔纸
        5512--治疗石
    }
local spellLoadTab={
    113509,--魔法汉堡
    818,--火    
    179244,--[召唤司机]
    179245,--[召唤司机]
    33388,--初级骑术
    33391,--中级骑术
    34090,--高级骑术
    34091,--专家级骑术
    90265,--大师级骑术
    783,--旅行形态
    436854,--切换飞行模式 C_MountJournal.GetDynamicFlightModeSpellID()
    404468,--/飞行模式：稳定
    80451,--勘测
}


for _, itemID in pairs(itemLoadTab) do
    WoWTools_DataMixin:Load({id=itemID, type='item'})
end
for _, spellID in pairs(spellLoadTab) do
    WoWTools_DataMixin:Load({id=spellID, type='spell'})
end















function WoWTools_DataMixin:MK(number, bit)
    if not number then
        return
    end
    bit = bit or 1

    local text= ''
    if number>=1e6 then
        number= number/1e6
        text='m'-- '|cffff00ffm|r'
    elseif number>= 1e4 and WoWTools_DataMixin.onlyChinese then
        number= number/1e4
        text='w'--'|cff00ff00w|r'
    elseif number>=1e3 then
        number= number/1e3
        text='k'-- '|cffffffffk|r'
    end
    if bit==0 then
        number= math.modf(number)
        number= number==0 and 0 or number
        return number..text--format('%i', number)..text
    else
        local num, point= math.modf(number)
        if point==0 then
            return num..text
        else---0.5/10^bit
            return format('%0.'..bit..'f', number)..text
        end
    end
end








--版本
function WoWTools_DataMixin:GetExpansionText(expacID, questID)
    if not expacID and questID then
        expacID= GetQuestExpansion(questID)
    end

    local text= expacID and WoWTools_TextMixin:CN(_G['EXPANSION_NAME'..expacID])
    if text then
        text= (WoWTools_TextureMixin:GetWoWLog(expacID) or '')..' '..text..' '..(expacID+1)
        if WoWTools_DataMixin.ExpansionLevel < expacID then
            text='|cff828282'..text..'|r'
        end
        return text
    end
end




--[[
function e.Is_Chinese_Text(str)--字符中，是否有汉字
    if str then
        for i = 1, #str do
            local uchar = string.byte(str, i)
            -- 如果字符不是单字节ASCII字符（即不在0x00-0x7F之间）
            if uchar > 0x7F then
                -- 这里可以添加更精确的检查来确保是汉字，但简单起见，我们假设所有非ASCII字符都是汉字
                return true
            end
        end
        return false
    end
end
]]




function WoWTools_DataMixin:Reload(isControlKeyDown)
    --if not (UnitAffectingCombat('player') and e.IsEncouter_Start) or not IsInInstance() then
    if not issecure() then
        if isControlKeyDown and IsControlKeyDown() or not isControlKeyDown then
            C_UI.Reload()
        end
    else
        print(WoWTools_DataMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
    end
end





function WoWTools_DataMixin:Get_CVar_Tooltips(info)--取得CVar信息 WoWTools_DataMixin:Get_CVar_Tooltips({name= ,msg=, value=})
    return (info.msg and info.msg..'|n' or '')..info.name..'|n'
    ..(info.value and C_CVar.GetCVar(info.name)== info.value and format('|A:%s:0:0|a', 'common-icon-checkmark') or '')
    ..(info.value and (WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)..info.value..' ' or '')
    ..'('..(WoWTools_DataMixin.onlyChinese and '当前' or REFORGE_CURRENT)..'|cnGREEN_FONT_COLOR:'..format('%.1f',C_CVar.GetCVar(info.name))..'|r |r'
    ..(WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)..'|cffff00ff'..format('%.1f', C_CVar.GetCVarDefault(info.name))..')|r'
end





function WoWTools_DataMixin:PlaySound(soundKitID, setPlayerSound)--播放, 声音 SoundKitConstants.lua WoWTools_DataMixin:PlaySound()--播放, 声音
    if not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0' or (not setPlayerSound and not WoWTools_DataMixin.IsSetPlayerSound) then
        return
    end
    local channel

    if C_CVar.GetCVarBool('Sound_EnableDialog') and C_CVar.GetCVar("Sound_DialogVolume")~='0' then
        channel= 'Dialog'
    elseif C_CVar.GetCVarBool('Sound_EnableAmbience') and C_CVar.GetCVar("Sound_AmbienceVolume")~='0' then
        channel= 'Ambience'
    elseif C_CVar.GetCVarBool('Sound_EnableSFX') and C_CVar.GetCVar("Sound_SFXVolume")~='0' then
        channel= 'SFX'
    elseif C_CVar.GetCVarBool('Sound_EnableMusic') and C_CVar.GetCVar("Sound_MusicVolume")~='0' then
        channel= 'Music'
    else
        channel= 'Master'
    end
    local success, voHandle= PlaySound(soundKitID or SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD, channel)--SOUNDKIT.READY_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.IG_PLAYER_INVITE
    return success, voHandle
end





--添加，Check 和 划条
function WoWTools_DataMixin:GetFormatter1to10(value, minValue, maxValue)
    if value and minValue and maxValue then
        return RoundToSignificantDigits(((value-minValue)/(maxValue-minValue) * (maxValue- minValue)) + minValue, maxValue)
    end
    return value
end
--[[local function GetFormatter1to10(minValue, maxValue)
    return function(value)
        return WoWTools_DataMixin:GetFormatter1to10(value, minValue, maxValue)
    end
end]]







--WoWTools_DataMixin:StaticPopup_FindVisible('PARTY_INVITE')
function WoWTools_DataMixin:StaticPopup_FindVisible(which)
    local info = StaticPopupDialogs[which];
	if info then
        for index = 1, STATICPOPUP_NUMDIALOGS or 4, 1 do--4
            local frame = _G["StaticPopup"..index]--StaticPopup_GetDialog(index)
            if frame and frame:IsShown() and (frame.which == which) then-- and (not info.multiple or (frame.data == data)) ) then
                return frame, frame.timeleft--StaticPopup1
            end
        end
    end
end




















