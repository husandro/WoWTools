local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Frame')
local Save={}
local panel=CreateFrame("Frame")
local Initializer
local SpellTab={}--e.ChallengesSpellTabs










--[[local function Vstr(t)--垂直文字
    local len = select(2, t:gsub("[^\128-\193]", ""))
    if(len == #t) then
        return t:gsub(".", "%1|n")
    else
        return t:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
    end
end]]




















--天赋, 点数 Blizzard_SharedTalentButtonTemplates.lua Blizzard_ClassTalentButtonTemplates.lua
local function set_UpdateSpendText(btn)
    local info= btn.nodeInfo-- C_Traits.GetNodeInfo btn:GetSpellID()
    local text
    if info then
        if info.currentRank and info.maxRanks and info.currentRank>0 and info.maxRanks~= info.currentRank then
            text= '/'..info.maxRanks
        end
        if text and not btn.maxText then
            btn.maxText= WoWTools_LabelMixin:Create(btn, {fontType=btn.SpendText})--nil, btn.SpendText)
            btn.maxText:SetPoint('LEFT', btn.SpendText, 'RIGHT')
            btn.maxText:SetTextColor(1, 0, 1)
            btn.maxText:EnableMouse(true)
            btn.maxText:SetScript('OnLeave', GameTooltip_Hide)
            btn.maxText:SetScript('OnEnter', function(self)
                if self.maxRanks then
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self.maxRanks)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.addName, Initializer:GetName())
                    e.tips:Show()
                end
            end)
        end
    end
    if btn.maxText then
        btn.maxText.maxRanks= info and info.maxRanks
        btn.maxText:SetText(text or '')
    end
end



















--法术按键, 颜色 ActionButton.lua
local function set_ActionButton_UpdateRangeIndicator(frame, checksRange, inRange)
    if not frame.setHooksecurefunc and frame.UpdateUsable then
        hooksecurefunc(frame, 'UpdateUsable', function(self, _, isUsable)
            if IsUsableAction(self.action) and ActionHasRange(self.action) and IsActionInRange(self.action)==false then
                self.icon:SetVertexColor(1,0,0)
            end
        end)
        frame.setHooksecurefunc= true
    end

    if ( frame.HotKey:GetText() == RANGE_INDICATOR ) then
        if ( checksRange ) then
            if ( inRange ) then
                if frame.UpdateUsable then
                    frame:UpdateUsable()
                end
            else
                frame.icon:SetVertexColor(1,0,0)
            end
        end
    else
        if ( checksRange and not inRange ) then
            frame.icon:SetVertexColor(1,0,0)
        elseif frame.UpdateUsable then
            frame:UpdateUsable()
        end
    end

end




































--Flyout, 技能，提示
local function set_SpellFlyoutButton_UpdateGlyphState(self)
    local text= SpellTab[self.spellID]
    if not text and self.spellID and not C_Spell.IsSpellPassive(self.spellID) then


        local des= C_Spell.GetSpellDescription(self.spellID)
        des= e.cn(des)
        if des then
            text= des:match('|cff00ccff(.-)|r')
                or des:match('传送至(.-)入口处')--传送至永茂林地入口处。
                or des:match('传送到(.-)的入口')--传送到自由镇的入口
                or des:match('将施法者传送到(.-)入口')--将施法者传送到青龙寺入口。

                or des:match('Teleportiert zum Eingang des (.-)%.')--Teleportiert zum Eingang des Immergrünen Flors.
                or des:match('Teleport to the entrance to (.-)%.')--Teleport to the entrance to The Everbloom.
                or des:match('Teletransporte a la entrada del (.-)%.')--Teletransporte a la entrada del Vergel Eterno.
                or des:match('Téléporte à l’entrée de la (.-)%.')--Téléporte à l’entrée de la Flore éternelle.

                or des:match('Teletrasporta all\'ingresso di (.-)%.')--Teletrasporta all'ingresso di Verdeterno.
                or des:match('Teletrasporta all\'ingresso del (.-)%.')
                or des:match('Teletrasporta all\'ingresso dell\'(.-)%.')

                or des:match('Teleporta para a entrada de (.-)')--Teleporta para a entrada de Floretérnia.
                or des:match('Телепортирует заклинателя в (.-)%.')--Телепортирует заклинателя в Вечное Цветение.
                or des:match('(.-) 입구로 순간이동합니다')--상록숲 입구로 순간이동합니다.
        end
        if not text then
            text= e.cn(C_Spell.GetSpellName(self.spellID), {spellID=self.spellID, isName=true})
            if not text then
                text= select(2, GetCallPetSpellInfo(self.spellID))
                text= e.cn(text)
            end
            text=text:match('%-(.+)') or text
            text=text:match('：(.+)') or text
            text=text:match(':(.+)') or text
            text=text:gsub(' %d','')
            text=text:gsub(SUMMONS,'')
        end
    end
    if text then
        if not self.Text then
            self.Text=WoWTools_LabelMixin:Create(self, {color={r=1,g=1,b=1}, justifyH='CENTER'})
            self.TextBg= self:CreateTexture(nil, 'BACKGROUND')
            self.TextBg:SetPoint('TOPLEFT', self.Text,-1, 1)
            self.TextBg:SetPoint('BOTTOMRIGHT', self.Text, 1,-1 )
            self.TextBg:SetAtlas('ChallengeMode-guild-background')
        else
            self.Text:ClearAllPoints()
        end

        local p=self:GetPoint(1)
        if p=='TOP' or p=='BOTTOM' then
            self.Text:SetPoint('RIGHT', self, 'LEFT',-1, 0)--, 0, 0)
        else
            self.Text:SetPoint('BOTTOM', self, 'TOP', 0,1)--, 2, 4)
            text= WoWTools_TextMixin:Vstr(text)--垂直文字
        end
    end
    if self.Text then
        self.Text:SetText(text or "")
    end
end

















function Init_All_Flyout()
    --if not e.Player.levelMax or e.Is_Timerunning then return end
    --https://wago.tools/db2/SpellFlyout?build=11.0.0.55288&locale=zhCN
    local tab={
        232,--'英雄之路：地心之战--11
        231,--英雄之路：巨龙时代团队副本
        227,--巨龙时代 10

        220,--暗影国度 9
        222,--英雄之路：暗影国度团队副本

        223,--争霸艾泽拉斯 8
        224,--军团再临 7
        96,--德拉诺这王 6
        84,--熊猫人之谜 5
        230,--大地的裂变 4
        --巫妖王之怒 3
        --燃烧的远征 2
        --经典旧世 1
    }
    local y= -145
    for _, flyoutID in pairs(tab) do--1024 MAX_SPELLS
        local numSlots, isKnown= select(3, GetFlyoutInfo(flyoutID))
        local btn= WoWTools_ButtonMixin:Cbtn(PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame, {texture=519384, size=32, alpha=isKnown and 0.1 or 0.5})

        btn:SetPoint('TOPLEFT', 22, y)
        btn:SetScript('OnLeave', function(self) self:SetAlpha(isKnown and 0.1 or 0.5) e.tips:Hide() end)
        btn:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()

            local name, description, numSlots2= GetFlyoutInfo(self.flyoutID)
            e.tips:AddLine(name, 1,1,1)
            e.tips:AddLine(description, nil,nil,nil,true)
            e.tips:AddLine(' ')

            for slot= 1, numSlots2 do
                local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(self.flyoutID, slot)
                local spellID= overrideSpellID or flyoutSpellID
                if spellID then
                    e.LoadData({id=spellID, type='spell'})
                    local name2= e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
                    local icon= C_Spell.GetSpellTexture(spellID)
                    if name2 and icon then
                        e.tips:AddDoubleLine('|T'..icon..':0|t'..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..e.cn(name2)..'|r', (not isKnown2 and '|cnRED_FONT_COLOR:' or '').. spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
                    else
                        e.tips:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnRED_FONT_COLOR:' or '')..spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
                    end
                end
            end

            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('flyoutID '..self.flyoutID, Initializer:GetName(), 1,1,1, 1,1,1)
            e.tips:Show()
            self:SetAlpha(1)
        end)

        btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
        btn.Text:SetPoint('CENTER')
        btn.Text:SetText(numSlots or '')

        btn.isKnown= isKnown
        btn.flyoutID= flyoutID
        y= y-46

    end
    
end














local function Init_Blizzard_PlayerSpells()
    hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', set_UpdateSpendText)--天赋, 点数 
    Init_All_Flyout()
end










--初始化
local function Init()
    --法术按键, 颜色
    hooksecurefunc('ActionButton_UpdateRangeIndicator', set_ActionButton_UpdateRangeIndicator)

    --Flyout, 技能，提示
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', set_SpellFlyoutButton_UpdateGlyphState)
    hooksecurefunc(SpellFlyout, 'Toggle',  GameTooltip_Hide)--隐藏

    --挑战传送门数据 --Flyout, 挑战传送门数据e.ChallengesSpellTabs，仅限 不是中文
    if e.onlyChinese then
        C_Timer.After(4, function()
            for _, info in pairs(e.ChallengesSpellTabs or {}) do
                if info.spell and info.name then--local name= EJ_GetInstanceInfo(info.ins)
                    SpellTab[info.spell]=info.name
                end
            end
        end)
    end

end















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'..(e.onlyChinese and '法术Frame' or addName),
                tooltip= e.onlyChinese and '法术距离, 颜色|n法术弹出框'
                        or (
                            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, TRACKER_SORT_PROXIMITY)..': '.. COLOR
                            ..'|n'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Flyout')..': '..LFG_LIST_TITLE
                            ..'|n...'
                    ),
                Value= not Save.disabled,
                GetValue=function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })


            if Save.disabled then
                self:UnregisterEvent('ADDON_LOADED')
            else
                Init()
                if C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
                    Init_Blizzard_PlayerSpells()
                    self:UnregisterEvent('ADDON_LOADED')
                end
            end

        --[[elseif arg1=='Blizzard_ClassTalentUI' then--天赋
            if not Save.disabled then
                hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', set_UpdateSpendText)--天赋, 点数 
            end]]

        elseif arg1=='Blizzard_PlayerSpells' then--天赋
            Init_Blizzard_PlayerSpells()
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)

