local e= select(2, ...)
e.LeftButtonDown = C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'LeftButtonDown' or 'LeftButtonUp'
e.RightButtonDown= C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 'RightButtonDown' or 'RightButtonUp'
e.ExpansionLevel= GetExpansionLevel()--版本数据
e.Is_Timerunning= PlayerGetTimerunningSeasonID()-- 1=幻境新生：潘达利亚
e.WoWDate={}--战网，数据
e.StausText={}--属性，截取表 API_Panel.lua
e.ChallengesSpellTabs={}--Challenges.lua
e.onlyChinese= LOCALE_zhCN and true or false
--e.tips=GameTooltip

WoWTools_Mixin={
    addName= '|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r',
    onlyChinese= e.onlyChinese,
}
--WoWTools_Mixin.onlyChinese
--WoWTools_Mixin.addName
--[[
AccountUtil.lua
FriendsFrame.lua
BnetShared.lua 
BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_APP = "App";
BNET_CLIENT_HEROES = "Hero";
BNET_CLIENT_CLNT = "CLNT";

function WoWTools_Mixin:GetWoWTexture()
    local texture
    C_Texture.GetTitleIconTexture(BNET_CLIENT_WOW, Enum.TitleIconVersion.Small, function(success, icon)
        if success and texture then
            texture= icon
        end
    end)
    return texture
end
]]




--[[
QueryGuildBankLog(tab)
QueryGuildBankTab(tab)
QueryGuildBankText(tab)
]]
function WoWTools_Mixin:Load(tab)--WoWTools_Mixin:Load({id=, type=''})--加载 item quest spell, uiMapID
    if not tab or not tab.id then
        return
    end
    if tab.type=='quest' then --WoWTools_Mixin:Load({id=, type='quest'})
        C_QuestLog.RequestLoadQuestByID(tab.id)
        if not HaveQuestRewardData(tab.id) then
            C_TaskQuest.RequestPreloadRewardData(tab.id)
        end

    elseif tab.type=='spell' then--WoWTools_Mixin:Load({id=, type='spell'})
        local spellID= tab.id
        if type(tab.id)=='string' then
            spellID= (C_Spell.GetSpellInfo(tab.id) or {}).spellID
        end
        if spellID and not C_Spell.IsSpellDataCached(spellID) then
            C_Spell.RequestLoadSpellData(spellID)
        end

    elseif tab.type=='item' then--WoWTools_Mixin:Load({id=, type='item'})
        local item= tab.itemLink or tab.id-- tab.id or (tab.itemLink and tab.itemLink:match('|Hitem:(%d+):'))
        if item and not C_Item.IsItemDataCachedByID(item) then
            C_Item.RequestLoadItemDataByID(item)
        end
    elseif tab.type=='itemLocation' then
        if not C_Item.IsItemDataCached(tab.id) then
            C_Item.RequestLoadItemData(tab.id)
        end

    elseif tab.type=='mapChallengeModeID' then--WoWTools_Mixin:Load({id=, type='mapChallengeModeID'})
        C_ChallengeMode.RequestLeaders(tab.id)

    elseif tab.typ=='club' then--WoWTools_Mixin:Load({id=, type='club'})
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
    WoWTools_Mixin:Load({id=itemID, type='item'})
end
for _, spellID in pairs(spellLoadTab) do
    WoWTools_Mixin:Load({id=spellID, type='spell'})
end















function WoWTools_Mixin:MK(number, bit)
    if not number then
        return
    end
    bit = bit or 1

    local text= ''
    if number>=1e6 then
        number= number/1e6
        text= 'm'
    elseif number>= 1e4 and e.onlyChinese then
        number= number/1e4
        text='w'
    elseif number>=1e3 then
        number= number/1e3
        text= 'k'
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
function WoWTools_Mixin:GetExpansionText(expacID, questID)
    if not expacID and questID then
        expacID= GetQuestExpansion(questID)
    end

    local text= expacID and e.cn(_G['EXPANSION_NAME'..expacID])
    if text then
        text= (WoWTools_TextureMixin:GetWoWLog(expacID) or '')..' '..text..' '..(expacID+1)
        if e.ExpansionLevel < expacID then
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




function WoWTools_Mixin:Reload(isControlKeyDown)
    --if not (UnitAffectingCombat('player') and e.IsEncouter_Start) or not IsInInstance() then
    if not issecure() then
        if isControlKeyDown and IsControlKeyDown() or not isControlKeyDown then
            C_UI.Reload()
        end
    else
        print(WoWTools_Mixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
    end
end



--距离
local LibRangeCheck = LibStub("LibRangeCheck-3.0", true)
function e.GetRange(unit, checkVisible)--WA Prototypes.lua
    return LibRangeCheck:GetRange(unit, checkVisible)
end

--距离
function e.CheckRange(unit, range, operator)
    local min, max= LibRangeCheck:GetRange(unit, true)
    if (operator) then-- == "<=") then
        return (max or 999) <= range
    else
        return (min or 0) >= range
    end
end


function e.Get_CVar_Tooltips(info)--取得CVar信息 e.Get_CVar_Tooltips({name= ,msg=, value=})
    return (info.msg and info.msg..'|n' or '')..info.name..'|n'
    ..(info.value and C_CVar.GetCVar(info.name)== info.value and format('|A:%s:0:0|a', e.Icon.select) or '')
    ..(info.value and (e.onlyChinese and '设置' or SETTINGS)..info.value..' ' or '')
    ..'('..(e.onlyChinese and '当前' or REFORGE_CURRENT)..'|cnGREEN_FONT_COLOR:'..format('%.1f',C_CVar.GetCVar(info.name))..'|r |r'
    ..(e.onlyChinese and '默认' or DEFAULT)..'|cffff00ff'..format('%.1f', C_CVar.GetCVarDefault(info.name))..')|r'
end





function e.PlaySound(soundKitID, setPlayerSound)--播放, 声音 SoundKitConstants.lua e.PlaySound()--播放, 声音
    if not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0' or (not setPlayerSound and not e.setPlayerSound) then
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










function e.Get_RaidTargetTexture(index, unit)--取得图片
    if unit then
        index= GetRaidTargetIndex(unit)
    end
    if not index or index<1 or index>NUM_WORLD_RAID_MARKERS then
        return ''
    else
        return '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..index..':0|t'
    end
end











--Cooldown.xml

function e.Ccool(self, start, duration, modRate, HideCountdownNumbers, Reverse, setSwipeTexture, hideDrawBling)--冷却条
    if not self then
        return
    elseif not duration or duration<=0 then
        if self.cooldown then
            self.cooldown:Clear()
        end
        return
    end
    if not self.cooldown then
        self.cooldown= CreateFrame("Cooldown", nil, self, 'CooldownFrameTemplate')
         self.cooldown:SetFrameLevel(self:GetFrameLevel()+5)
        self.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
        self.cooldown:SetDrawBling(not hideDrawBling)--闪光
        self.cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
        self.cooldown:SetHideCountdownNumbers(HideCountdownNumbers)--隐藏数字
        self.cooldown:SetReverse(Reverse)--控制冷却动画的方向
        self.cooldown:SetAlpha(0.7)
        self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
        if setSwipeTexture then
            self.cooldown:SetSwipeTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')--圆框架
        end
        self:HookScript('OnHide', function(self2)
            if self2.cooldown then
                self2.cooldown:Clear()
            end
        end)
    end
    start=start or GetTime()
    self.cooldown:SetCooldown(start, duration, modRate)
end

function e.SetItemSpellCool(frame, tab)--{item=, spell=, type=, isUnit=true} type=true圆形，false方形
    if not frame or not tab then
        return
    end

    local item= tab.item
    local spell= tab.spell
    local type= tab.type
    local unit= tab.unit

    if unit then
        local texture, startTime, endTime, duration, channel

        if UnitExists(unit) then
            texture, startTime, endTime= select(3, UnitChannelInfo(unit))

            if not (texture and startTime and endTime) then
                texture, startTime, endTime= select(3, UnitCastingInfo(unit))
            else
                channel= true
            end
            if texture and startTime and endTime then
                duration= (endTime - startTime) / 1000
                e.Ccool(frame, nil, duration, nil, true, channel, nil,nil)
                return texture
            end
            e.Ccool(frame)
        end

    elseif item then
        local startTime, duration = C_Item.GetItemCooldown(item)

        e.Ccool(frame, startTime, duration, nil, true, nil, not type)
    elseif spell then
        local data= C_Spell.GetSpellCooldown(spell) or {}
        e.Ccool(frame, data.startTime, data.duration, data.modRate, true, nil, not type)--冷却条

    elseif frame.cooldown then
        e.Ccool(frame)
    end
end

--[[
Cooldown.lua
CooldownFrame_Set(self.SpellButton.Cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled)
CooldownFrame_Clear(self.SpellButton.Cooldown);
CooldownFrame_SetDisplayAsPercentage(self, percentage)
]]

function e.GetSpellItemCooldown(spellID, itemID)--法术,物品,冷却
    if spellID then
        if not C_Spell.GetOverrideSpell(spellID) then
            return
        end
        local data= C_Spell.GetSpellCooldown(spellID)
        if data then
            if data.duration>0 then
                local t= GetTime()
                while t<data.startTime do
                    t= t+86400
                end
                t= t-data.startTime
                t= data.duration-t
                t= t<0 and 0 or t
                return '|cnRED_FONT_COLOR:'..SecondsToTime(t)..'|r'

            elseif data.isEnabled==false then
                return '|cff9e9e9e'..(e.onlyChinese and '即时冷却' or SPELL_RECAST_TIME_INSTANT)..'|r'
            end
        end
    elseif itemID then
        local startTime, duration, enable = C_Item.GetItemCooldown(itemID)
        if duration and duration>0 then
            local t= GetTime()
            while t<startTime do
                t= t+86400
            end
            t= t-startTime
            t= duration-t
            t= t<0 and 0 or t
            if enable==false then
                return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '即时冷却' or SPELL_RECAST_TIME_INSTANT)..'|r'
            else
                return '|cnRED_FONT_COLOR:'..SecondsToTime(t)..'|r'
            end
        end
    end
end











