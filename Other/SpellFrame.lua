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
                    e.tips:SetOwner(self, "ANCHOR_RIGHT");
                    e.tips:ClearLines();
                    e.tips:AddDoubleLine(e.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self.maxRanks)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, e.cn(addName))
                    e.tips:Show();
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
        local text
        if self.spellID and not IsPassiveSpell(self.spellID) then
            local des= GetSpellDescription(self.spellID)
            if des then
                des= e.cn(des)
                text= des:match('|cff00ccff(.-)|r')
                    or des:match('传送至(.-)入口处')--传送至永茂林地入口处。
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
            text= text or select(2, GetCallPetSpellInfo(self.spellID))
            text= text~='' and text or nil
            text= text or GetSpellInfo(self.spellID)
            text= e.cn(text)
            if text then

                if not self.Text then
                    self.Text=e.Cstr(self);
                else
                    self.Text:ClearAllPoints();
                end
                text=text:match('%-(.+)') or text
                text=text:match('：(.+)') or text
                text=text:match(':(.+)') or text
                text=text:gsub(' %d','')
                text=text:gsub(SUMMONS,'');
                local p=self:GetPoint(1);
                if p=='TOP' or p=='BOTTOM' then
                    self.Text:SetPoint('RIGHT', self, 'LEFT', -2, 0);
                else
                    self.Text:SetPoint('BOTTOM', self, 'TOP', 0, 4);
                    text=Vstr(text);
                end
            end
        end
        if self.Text then self.Text:SetText( text or "") end
    end)

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
                    frame.icon:SetVertexColor(1,0,0);
                end
            end
        else
            if ( checksRange and not inRange ) then
                frame.icon:SetVertexColor(1,0,0);
            elseif frame.UpdateUsable then
                frame:UpdateUsable()
            end
        end

    end)


end
        --[[
            
        
        local isNotInRange= checksRange and inRange==false
        if not frame.isNotInRange then
            frame.isNotInRange= frame:CreateTexture(nil, 'OVERLAY')
            frame.isNotInRange:SetAtlas('jailerstower-wayfinder-rewardbackground-mouseover')
           -- frame.isNotInRange:SetVertexColor(1,0,0)
            frame.isNotInRange:SetAllPoints(frame)
        end
        if frame.isNotInRange then
           -- frame.isNotInRange:SetShown(isNotInRange)
        end
        
        if not frame.UpdateUsable then
            return
        end
        if not frame.setHooksecurefunc then
            hooksecurefunc(frame, 'UpdateUsable', function(self)
                if self.action and ActionHasRange(self.action) and IsUsableAction(self.action) then
                    if not UnitExists('target')  then
                        self.icon:SetVertexColor(1, 0, 1)
                    elseif not IsActionInRange(self.action) then
                        self.icon:SetVertexColor(1,0,0)
                    end
                end
            end)
            frame.setHooksecurefunc= true
        end
        frame:UpdateUsable()
        if checksRange then
           if not inRange then
                self.icon:SetVertexColor(RED_FONT_COLOR:GetRGB())
           else--if self.action then
                self:UpdateUsable()
            end
        --end]]


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

