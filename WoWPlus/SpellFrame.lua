local id, e = ...
local addName= SPELLS..'Frame'
local Save={}
local panel=CreateFrame("Frame")


--#########
--天赋, 点数
--Blizzard_SharedTalentButtonTemplates.lua
--Blizzard_ClassTalentButtonTemplates.lua
local function set_UpdateSpendText(self)
    local info= self.nodeInfo
    local text
    if info and info.currentRank and info.maxRanks and info.currentRank>0 and info.maxRanks~= info.currentRank then
        text= '/'..info.maxRanks
    end
    if text and not self.maxText then
        self.maxText= e.Cstr(self, {fontType=self.SpendText})--nil, self.SpendText)
        self.maxText:SetPoint('LEFT', self.SpendText, 'RIGHT')
        self.maxText:SetTextColor(1, 0, 1)
        self.maxText:EnableMouse(true)
        self.maxText:SetScript('OnLeave', function() e.tips:Hide() end)
        self.maxText:SetScript('OnEnter', function(self2)
            if self2.maxRanks then
                e.tips:SetOwner(self2, "ANCHOR_RIGHT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine(e.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self2.maxRanks)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show();
            end
        end)
    end
    if self.maxText then
        self.maxText.maxRanks= info and info.maxRanks
        self.maxText:SetText(text or '')
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
    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', function(self, reason)
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
                self.icon:SetVertexColor(RED_FONT_COLOR:GetRGB());
            elseif self.action then
                local isUsable, notEnoughMana = IsUsableAction(self.action);
                if ( isUsable ) then
                    self.icon:SetVertexColor(1.0, 1.0, 1.0);
                elseif ( notEnoughMana ) then
                    self.icon:SetVertexColor(0.5, 0.5, 1.0);
                else
                    self.icon:SetVertexColor(0.4, 0.4, 0.4);
                end
            end
        end
    end)
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel('|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'..(e.onlyChinese and '法术Frame' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_RIGHT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine(e.onlyChinese and '法术距离' or SPELLS..TRACKER_SORT_PROXIMITY, e.onlyChinese and '颜色' or COLOR)
                e.tips:AddDoubleLine(e.onlyChinese and '法术弹出框' or SPELLS..' Flyout', e.onlyChinese and '名称' or LFG_LIST_TITLE)
                e.tips:Show();
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

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

--[[
--UpdateButton
hooksecurefunc('SpellBookFrame_Update', function()
    if SpellBookFrame.bookType ~= BOOKTYPE_SPELL then
        return
    end
    local spellSlot;
    for i = 1, SPELLS_PER_PAGE do
        local btn = _G["SpellButton" .. i];
        if btn then
            if not btn.setScript then
                hooksecurefunc(btn, 'UpdateButton', function(self)
                
                end)
            end
            btn:SetShown(true)
        end
        local slotType = select(2,SpellBook_GetSpellBookSlot(btn));
        if (slotType == "FUTURESPELL") then
            btn:SetShown(true)
        end
	end    
end)]]