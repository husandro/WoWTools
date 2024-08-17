local id, e= ...
if e.Player.class~='MAGE' then
    return
end
local Tab
if e.Player.faction=='Horde' then--部落
    Tab={
        {spell=3567, spell2=11417, name='奥格瑞玛', luce=true,},
        {spell=3563, spell2=11418, name='幽暗城'},
        {spell=3566, spell2=11420, name='雷霆崖'},
        {spell=32272, spell2=32267, name='银月城'},
        {spell=49358, spell2=49361, name='斯通纳德'},
        {spell=35715, spell2=35717, name='沙塔斯'},
        {spell=53140, spell2=53142, name='诺森德'},
        {spell=88344, spell2=88346, name='托尔巴拉德'},
        {spell=132627, spell2=132626, name='锦绣谷'},
        {spell=176242, spell2=176244, name='战争之矛'},
        {spell=224869, spell2=224871, name='破碎群岛'},
        {spell=281404, spell2=281402, name='达萨罗'},
        {spell=344587, spell2=344597, name='奥利波斯'},
        {spell=395277, spell2=395289,  name='瓦德拉肯', luce=true},
        {spell=120145, name='远古传送'},
        {spell=193759, name='守护者圣殿'},
    }
elseif e.Player.faction=='Alliance' then
    Tab={
        {spell=3561, spell2=10059,  name='暴风城', luce=true,},
        {spell=3562, spell2=11416, name='铁炉堡'},
        {spell=3565, spell2=11419, name='达纳苏斯'},
        {spell=32271, spell2=32266, name='埃索达'},
        {spell=49359, spell2=49360, name='塞拉摩'},
        {spell=33690, spell2=33691, name='沙塔斯'},
        {spell=53140, spell2=53142, name='诺森德'},
        {spell=88342, spell2=88345, name='托尔巴拉德'},
        {spell=132621, spell2=132620, name='锦绣谷'},
        {spell=176248, spell2=176246, name='暴风之盾'},
        {spell=224869, spell2=224871, name='破碎群岛'},
        {spell=281403, spell2=281400, name='伯拉勒斯'},
        {spell=344587, spell2=344597, name='奥利波斯'},
        {spell=395277, spell2=395289,  name='瓦德拉肯', luce=true},
        {spell=120145, name='远古传送'},
        {spell=193759, name='守护者圣殿'},
    }
else
    return
end

local addName= format(UNITNAME_SUMMON_TITLE14, UnitClass('player'))
local Save={}
local panel=CreateFrame("Frame")

for _, tab in pairs(Tab) do
    e.LoadDate({id=tab.spell, type='spell'})
    e.LoadDate({id=tab.spell2, type='spell'})
end


--####
--初始
--####
local function Init()
    local find
    for _, tab in pairs(Tab) do
        local name= C_Spell.GetSpellName(tab.spell)
        local icon= C_Spell.GetSpellTexture(tab.spell)

        local btn=WoWTools_ToolsButtonMixin:CreateButton(
            'MagePortal'..tab.spell,
            ('|T'..(icon or 0)..':0|t')..(name or tab.spell),
             true, false, not find, true
        )
        if btn then
            find=true

            btn.spell= tab.spell
            btn.spell2= tab.spell2
            
            btn:SetAttribute('type', 'spell')--设置属性
            btn:SetAttribute('spell', name or tab.spell)
            btn.texture:SetTexture(icon)

            btn.text=e.Cstr(btn, {color= not tab.luce})
            btn.text:SetPoint('RIGHT', btn, 'LEFT')

            if e.onlyChinese then
                btn.text:SetText(tab.name)
            else
                local text=name:gsub('(.+):','')
                text=text:gsub('(.+)：','');
                text=text:gsub('(.+)-','');
                btn.text:SetText(text)
            end

            if tab.luce then
                btn.border:SetAtlas('bag-border')--设置高亮
            end

            if tab.spell2 then--and IsSpellKnownOrOverridesKnown(tab.spell2) then--右击
                local name2= C_Spell.GetSpellName(tab.spell2)
                local icon2= C_Spell.GetSpellTexture(tab.spell2)

                btn:SetAttribute('type2', 'spell')
                btn:SetAttribute('spell2', name2 or tab.spell2)

                btn.texture2= btn:CreateTexture(nil,'OVERLAY')
                btn.texture2:SetPoint('TOPRIGHT',-6,-6)
                btn.texture2:SetSize(10, 10)
                btn.texture2:SetTexture(icon2)
                btn.texture2:AddMaskTexture(btn.mask)
                btn:SetScript('OnShow', function(self2)
                    self2:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                    e.SetItemSpellCool(btn, {spell=self2.spell2})--设置冷却
                end)
                btn:SetScript('OnHide', function(self2)
                    self2:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                end)
                btn:SetScript("OnEvent", function(self, event)
                    if event=='SPELL_UPDATE_COOLDOWN' then
                        e.SetItemSpellCool(self, {spell=self.spell2})--设置冷却
                    end
                end)
            end

            function btn:set_sepll_known()
                self:SetAlpha((GameTooltip:IsOwned(self) or IsSpellKnownOrOverridesKnown(self.spell)) and 1 or 0.1)
            end
            btn:SetScript('OnLeave', function(self)
                GameTooltip_Hide()
                self:set_sepll_known()
            end)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spell)
                if not IsSpellKnownOrOverridesKnown(self.spell) then
                    e.tips:AddLine(format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB))
                end
                if self.spell2 then
                    e.tips:AddLine(' ')
                    local link= icon and '|T'..icon..':0|t' or ''
                    link= link.. (C_Spell.GetSpellLink(self.spell2) or C_Spell.GetSpellName(self.spell2) or ('spellID'..self.spell2))
                    link= link .. (e.GetSpellItemCooldown(self.spell2, nil) or '')
                    e.tips:AddDoubleLine(link,
                        format('%s%s',
                            IsSpellKnownOrOverridesKnown(self.spell2) and '' or format('|cnRED_FONT_COLOR:%s|r',e.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB),
                            e.Icon.right)
                        )
                end
                e.tips:Show()
                self:set_sepll_known()
            end)

            btn:set_sepll_known()
        end
    end

    Tab=nil
end

--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save

            if WoWTools_ToolsButtonMixin:GetButton() then                
                C_Timer.After(4, Init)
                panel:UnregisterEvent('ADDON_LOADED')
            else
                panel:UnregisterAllEvents()
                Tab=nil
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            panel.combat=nil
            Init()
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)