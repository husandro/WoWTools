local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Frame')
local Save={}
local panel=CreateFrame("Frame")


--#########
--天赋, 点数
--Blizzard_SharedTalentButtonTemplates.lua
--Blizzard_ClassTalentButtonTemplates.lua
local function set_UpdateSpendText(btn)
    local info= btn.nodeInfo-- C_Traits.GetNodeInfo btn:GetSpellID()
    local text
    if info then
        if info.currentRank and info.maxRanks and info.currentRank>0 and info.maxRanks~= info.currentRank then
            text= '/'..info.maxRanks
        end
        if text and not btn.maxText then
            btn.maxText= e.Cstr(btn, {fontType=btn.SpendText})--nil, btn.SpendText)
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
                    e.tips:AddDoubleLine(id, e.cn(addName))
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


--######
--初始化
--######

local function Vstr(t)--垂直文字
    local len = select(2, t:gsub("[^\128-\193]", ""))
    if(len == #t) then
        return t:gsub(".", "%1|n")
    else
        return t:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
    end
end

local SpellTab={}--e.ChallengesSpellTabs
local function Init()

--[[
传送至永茂林地入口处。
Teleportiert zum Eingang des Immergrünen Flors.
Teleport to the entrance to The Everbloom.
Teletransporte a la entrada del Vergel Eterno.
Téléporte à l’entrée de la Flore éternelle.
Teletrasporta all'ingresso di Verdeterno.
Teleporta para a entrada de Floretérnia.
Телепортирует заклинателя в Вечное Цветение.
상록숲 입구로 순간이동합니다.
( ) . % + - * ? [ ^ $
]]
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', function(self)
        local text= SpellTab[self.spellID]
        if not text and self.spellID and not IsPassiveSpell(self.spellID) then
            local des= GetSpellDescription(self.spellID)
            if des then
                des= e.cn(des)
                text= des:match('|cff00ccff(.-)|r')
                    or des:match('传送至(.-)入口处')--传送至永茂林地入口处。
                    or des:match('传送到(.-)的入口')--传送到自由镇的入口
                    or des:match('将施法者传送到(.-)入口')--将施法者传送到青龙寺入口。
            end
            if not text then
                text= select(2, GetCallPetSpellInfo(self.spellID))
                text= text~='' and text or nil
                text= text or GetSpellInfo(self.spellID)
                text= e.cn(text)
                text=text:match('%-(.+)') or text
                text=text:match('：(.+)') or text
                text=text:match(':(.+)') or text
                text=text:gsub(' %d','')
                text=text:gsub(SUMMONS,'')
            end
        end
        if text then
            if not self.Text then
                self.Text=e.Cstr(self, {color={r=1,g=1,b=1}, justifyH='CENTER'})
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
                text=Vstr(text)
            end
        end
        if self.Text then
            self.Text:SetText(text or "")
        end
    end)

    SpellFlyout:HookScript('OnShow', function()
        e.tips:Hide()
    end)

    --添加，挑战，数据
    if not e.onlyChinese then
        C_Timer.After(2, function()
            for _, info in pairs(e.ChallengesSpellTabs) do
                if info.spell and info.ins then
                    local name= EJ_GetInstanceInfo(info.ins)
                    if name then
                        SpellTab[info.spell]=name
                    end
                end
            end
            local tab={--没找到，数据
            {131228, 324},--'玄牛之路', '传送至|cff00ccff围攻砮皂寺|r入口处'},
            {131222, 321},--'魔古皇帝之路', '传送至|cff00ccff魔古山宫殿|r入口处。'},
            {131225, 303},--'残阳之路', '传送至|cff00ccff残阳关|r入口处。'},
            {131206, 321},--'影踪派之路', '将施法者传送到|cff00ccff影踪禅院|r入口。'},
            {131205, 302},--'烈酒之路', '将施法者传送到|cff00ccff风暴烈酒酿造厂|r入口。'},
            {131232, 246},--'通灵师之路', '传送至|cff00ccff通灵学院|r入口处。'},
            {131231, 311},--'血色利刃之路', '传送至|cff00ccff血色大厅|r入口处。'},
            {131229, 316},--'血色法冠之路', '传送至|cff00ccff血色修道院|r入口处。'},


            {159895, 385},--'血槌之路', '传送至|cff00ccff血槌炉渣矿井|r入口处。'},
            {159902, 559},--'火山之路', '传送至|cff00ccff黑石塔上层|r入口处。'},
            {159898, 476},--'通天之路', '传送至|cff00ccff通天峰|r入口处。'},
            {159897, 547},--'警戒者之路', '传送至|cff00ccff奥金顿|r入口处。'},


            {354463, 1183},--'瘟疫之路', '传送到|cff00ccff凋魂之殇|r的入口。'},
            {354468, 1184},--'雾林之路', '传送到|cff00ccff塞兹仙林的迷雾|r的入口。'},
            {354469, 1189},--'石头守望者之路', '传送至|cff00ccff赤红深渊|r入口。'},
            {354465, 1185},--'罪魂之路', '传送到|cff00ccff赎罪大厅|r的入口。'},
            {354467, 1187},--'不败之路', '传送到|cff00ccff伤逝剧场|r的入口。'},
            {354462, 1182},--'勇者之路', '传送到|cff00ccff通灵战潮|r的入口。'},
            {354466, 1186},--'晋升者之路', '传送到|cff00ccff晋升高塔|r的入口。'},
            }
            for _, info in pairs(tab) do
                local name= EJ_GetInstanceInfo(info[2])
                if name then
                    SpellTab[info[1]]=name
                end
            end
        end)
    end



    --#############
    --法术按键, 颜色
    --#############
    hooksecurefunc('ActionButton_UpdateRangeIndicator', function(frame, checksRange, inRange)--ActionButton.lua
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

    end)

   
end
        


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'..(e.onlyChinese and '法术Frame' or addName),
                tooltip= e.onlyChinese and '法术距离, 颜色|n法术弹出框'
                        or (
                            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, TRACKER_SORT_PROXIMITY)..': '.. COLOR
                            ..'|n'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Flyout')..': '..LFG_LIST_TITLE
                            ..'|n...'
                    ),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_ClassTalentUI' then--天赋
            hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', set_UpdateSpendText)--天赋, 点数
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)

--[[ https://wago.io/dungeonports
    -- Non rimuovere questo commento, fa parte di quest'aura:DF_AA_PORT 2
aura_env.spellID = 393273

-- Non rimuovere questo commento, fa parte di quest'aura:DF_AV_PORT 2
aura_env.spellID = 393279

-- Non rimuovere questo commento, fa parte di quest'aura:DF_BH_PORT 2
aura_env.spellID = 393267

-- Non rimuovere questo commento, fa parte di quest'aura:DF_HOI_PORT 2
aura_env.spellID = 393283

-- Non rimuovere questo commento, fa parte di quest'aura:DF_NELT_PORT 2
aura_env.spellID = 393276

-- Non rimuovere questo commento, fa parte di quest'aura:DF_NO_PORT 2
aura_env.spellID = 393262

-- Non rimuovere questo commento, fa parte di quest'aura:DF_RLP_PORT 2
aura_env.spellID = 393256

-- Non rimuovere questo commento, fa parte di quest'aura:DF_ULD_PORT 2
aura_env.spellID = 393222

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S1_COS_PORT
aura_env.spellID = 393766

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S1_HOV_PORT
aura_env.spellID = 393764

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S1_SBG_PORT
aura_env.spellID = 159899

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S1_TJS_PORT
aura_env.spellID = 131204

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S2_VP_PORT
aura_env.spellID = 410080

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S2_NL_PORT
aura_env.spellID = 410078

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S2_FH_PORT
aura_env.spellID = 410071

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S2_UNDR_PORT
aura_env.spellID = 410074

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_AD_PORT
aura_env.spellID = 424187

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_BRH_PORT
aura_env.spellID = 424153

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_DHT_PORT
aura_env.spellID = 424163

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_EB_PORT
aura_env.spellID = 159901

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_FALL_PORT
aura_env.spellID = 424197

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_RISE_PORT
aura_env.spellID = 424197

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_TOTT_PORT
aura_env.spellID = 424142

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_WM_PORT
aura_env.spellID = 424167

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_Background
aura_env.active = false

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_TOTT
aura_env.spellID = 424142

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_VP
aura_env.spellID = 410080

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_TJS
aura_env.spellID = 131204

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SONT
aura_env.spellID = 131228

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_MSP
aura_env.spellID = 131222

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_GOTSS
aura_env.spellID = 131225

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SPM
aura_env.spellID = 131206

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SSB
aura_env.spellID = 131205

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SCHOLO
aura_env.spellID = 131232

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SH
aura_env.spellID = 131231

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SM
aura_env.spellID = 131229

-- Non rimuovere questo commento, fa parte di quest'aura:DF_S3_EB_PORT 2
aura_env.spellID = 159901

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SBG
aura_env.spellID = 159899

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_GD
aura_env.spellID = 159900

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_ID
aura_env.spellID = 159896

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_BSM
aura_env.spellID = 159895

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_UBS
aura_env.spellID = 159902

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SKY
aura_env.spellID = 159898

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_AUCH
aura_env.spellID = 159897

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_DHT
aura_env.spellID = 424163

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_BRH
aura_env.spellID = 424153

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_NL
aura_env.spellID = 410078

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_HOV
aura_env.spellID = 393764

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_COS
aura_env.spellID = 393766

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_KARA
aura_env.spellID = 373262

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_WM
aura_env.spellID = 424167

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_AD
aura_env.spellID = 424187

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_UNDR
aura_env.spellID = 410074

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_FH
aura_env.spellID = 410071

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_MECHA
aura_env.spellID = 373274

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_PF
aura_env.spellID = 354463

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_MISTS
aura_env.spellID = 354464

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_DOS
aura_env.spellID = 354468

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SD
aura_env.spellID = 354469

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_HOA
aura_env.spellID = 354465

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_TOP
aura_env.spellID = 354467

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_NW
aura_env.spellID = 354462

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_SOA
aura_env.spellID = 354466 

-- Non rimuovere questo commento, fa parte di quest'aura:M+TP_PL_TAZ
aura_env.spellID = 367416


]]