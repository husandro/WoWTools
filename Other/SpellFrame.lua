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
            btn.maxText:SetScript('OnLeave', function() e.tips:Hide() end)
            btn.maxText:SetScript('OnEnter', function(self)
                if self.maxRanks then
                    e.tips:SetOwner(self, "ANCHOR_RIGHT");
                    e.tips:ClearLines();
                    e.tips:AddDoubleLine(e.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self.maxRanks)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName)
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
local function Init()
    local Vstr=function(t)--垂直文字
        local len = select(2, t:gsub("[^\128-\193]", ""))
        if(len == #t) then
            return t:gsub(".", "%1|n")
        else
            return t:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
        end
    end
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', function(self)
            if self.spellID then
                local spellName = GetSpellInfo(self.spellID);
                local petName = select(2, GetCallPetSpellInfo(self.spellID));
                if petName=='' then petName=nil end

                local text=petName or spellName;
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
                    self.Text:SetText(text);
                    return
                end
            end
            if self.Text then self.TextSetText('') end
    end)

    --#############
    --法术按键, 颜色
    --#############
    hooksecurefunc('ActionButton_UpdateRangeIndicator', function(self, checksRange, inRange)--ActionButton.lua
        if checksRange then
           if not inRange then
                self.icon:SetVertexColor(RED_FONT_COLOR:GetRGB())
           elseif self.action then
                self:UpdateUsable()
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
                tooltip= e.onlyChinese and '法术距离, 颜色|n法术弹出框, 名称|n...'
                        or (
                            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, TRACKER_SORT_PROXIMITY)..': '.. COLOR
                            ..'|n'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Flyout')..': '..LFG_LIST_TITLE
                            ..'|n...'
                    ),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_ClassTalentUI' then--天赋
            hooksecurefunc(ClassTalentButtonSpendMixin,'UpdateSpendText', set_UpdateSpendText)--天赋, 点数
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)

