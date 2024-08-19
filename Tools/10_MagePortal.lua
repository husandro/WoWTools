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
        {spell=395277, spell2=395289,  name='瓦德拉肯'},
        {spell=446540, spell2=446534, name='多恩诺嘉尔', luce=true},
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
        {spell=395277, spell2=395289,  name='瓦德拉肯'},
        {spell=446540, spell2=446534, name='多恩诺嘉尔', luce=true},
        {spell=120145, name='远古传送'},
        {spell=193759, name='守护者圣殿'},
    }
else
    return
end








local addName

local Save={
    isLeft=true,
    showText=true,
    --disabled
}



for _, tab in pairs(Tab) do
    e.LoadDate({id=tab.spell, type='spell'})
    e.LoadDate({id=tab.spell2, type='spell'})
end




local function Init_Options(category, layout)
    e.AddPanel_Header(layout, addName)
    local initializer=e.AddPanel_Check({
        category= category,
        name= '|cff28a3ff'..(e.onlyChinese and '启用' or ENABLE)..'|r',
        tooltip= addName,
        GetValue= function() return not Save.disabled end,
        SetValue= function()
            Save.disabled= not Save.disabled and true or nil
        end
    })

    e.AddPanel_Check({
        category= category,
        name= '|cff28a3ff'..(e.onlyChinese and '位置: 放左边' or (CHOOSE_LOCATION..': '..HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT ))..'|r',
        tooltip= addName,
        GetValue= function() return Save.isLeft end,
        SetValue= function()
            Save.isLeft= not Save.isLeft and true or nil
        end
    }, initializer)

    e.AddPanel_Check({
        category= category,
        name= '|cff28a3ff'..(e.onlyChinese and '显示名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, NAME))..'|r',
        tooltip= addName,
        GetValue= function() return Save.showText end,
        SetValue= function()
            Save.showText= not Save.showText and true or nil
        end
    }, initializer)

end





--####
--初始
--####
local function Init()


    local name, icon, btn
    for index, tab in pairs(Tab) do
        name= C_Spell.GetSpellName(tab.spell)
        icon= C_Spell.GetSpellTexture(tab.spell)

        btn=WoWTools_ToolsButtonMixin:CreateButton({
            name='MagePortal_Spell_'..tab.spell,
            tooltip='|T626001:0|t'..('|T'..(icon or 0)..':0|t')..(e.cn(name, {spellID=tab.spell, isName=true}) or tab.spell),
            setParent=true,
            point=Save.isLeft and 'LEFT' or 'RIGHT',
            isNewLine= index==1 and Save.isLeft,
            isOnlyLine= index~=1 and Save.isLeft,
            disabledOptions=true,
        })

        if btn then
            btn.spellID= tab.spell
            btn.spellID2= tab.spell2

            if Save.showText then
                btn.text=e.Cstr(btn, {color= not tab.luce})
                if Save.isLeft then
                    btn.text:SetPoint('RIGHT', btn, 'LEFT')
                else
                    btn.text:SetPoint('LEFT', btn, 'RIGHT')
                end
                if e.onlyChinese then
                    btn.text:SetText(tab.name)
                end
            end

            if tab.luce then
                btn.border:SetAtlas('bag-border')--设置高亮
            end

            if btn.spellID2 then
                btn.texture2= btn:CreateTexture(nil,'OVERLAY')
                btn.texture2:SetPoint('TOPRIGHT',-6,-6)
                btn.texture2:SetSize(10, 10)
                btn.texture2:AddMaskTexture(btn.mask)
                btn:SetScript('OnShow', function(self)
                    self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                    e.SetItemSpellCool(btn, {spell=self.spellID2})--设置冷却
                end)
                btn:SetScript('OnHide', function(self)
                    self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                end)
            end

            btn:SetScript("OnEvent", function(self, event, arg1)
                if event=='SPELL_UPDATE_COOLDOWN' then
                    e.SetItemSpellCool(self, {spell=self.spellID2})--设置冷却
                elseif event=='SPELL_DATA_LOAD_RESULT' and (arg1==self.spellID or arg1==self.spellID2) then
                    if self:CanChangeAttribute() then
                        if self:settings() then
                            self:UnregisterEvent('SPELL_DATA_LOAD_RESULT')
                        end
                    else
                        self:RegisterEvent('PLAYER_REGEN_ENABLED')
                    end
                elseif event=='PLAYER_REGEN_ENABLED' then
                    if self:settings() then
                        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
                    end
                end
            end)


            function btn:settings()
                local name1= C_Spell.GetSpellName(self.spellID)
                local icon1= C_Spell.GetSpellTexture(self.spellID)
                local done=false
                if name1 and icon1 then
                    self:SetAttribute('type', 'spell')--设置属性
                    self:SetAttribute('spell', name1)
                    if icon1 then
                        self.texture:SetTexture(icon1)
                    end

                    if not e.onlyChinese and self.text then
                        name1= e.cn(name1, {spellID=self.spellID, isName=true})
                        name1=name1:gsub('(.+):','')
                        name1=name1:gsub('(.+)：','');
                        name1=name1:gsub('(.+)-','');
                        self.text:SetText(name1)
                    end
                    done=true
                end

                if self.spellID2 then
                    local name2= C_Spell.GetSpellName(self.spellID2)
                    local icon2= C_Spell.GetSpellTexture(self.spellID2)
                    if name2 and icon2 then
                        self:SetAttribute('type2', 'spell')
                        self:SetAttribute('spell2', name2)
                        self.texture2:SetTexture(icon2)
                        done=true
                    else
                        done=false
                    end
                end
                return done
            end

            if not btn:settings() then
                btn:RegisterEvent('SPELL_DATA_LOAD_RESULT')
            end

            function btn:set_sepll_known()
               self:SetAlpha((GameTooltip:IsOwned(self) or IsSpellKnownOrOverridesKnown(self.spellID)) and 1 or 0.1)
            end
            btn:SetScript('OnLeave', function(self)
                e.tips:Hide()
                self:set_sepll_known()
            end)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spellID)
                if not IsSpellKnownOrOverridesKnown(self.spellID) then
                    e.tips:AddLine(format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB))
                end
                if self.spellID2 then
                    e.tips:AddLine(' ')
                    local link= '|T'..(C_Spell.GetSpellTexture(self.spellID2) or 0)..':0|t'
                    link= link.. (C_Spell.GetSpellLink(self.spellID2) or C_Spell.GetSpellName(self.spellID2) or ('spellID'..self.spellID2))
                    link= link .. (e.GetSpellItemCooldown(self.spellID2, nil) or '')
                    e.tips:AddDoubleLine(link,
                        format('%s%s',
                            IsSpellKnownOrOverridesKnown(self.spellID2) and '' or format('|cnRED_FONT_COLOR:%s|r',e.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB),
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
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then

            Save= WoWToolsSave['Tools_MagePortal'] or Save

            if not Save.disabled and  WoWTools_ToolsButtonMixin:GetButton() then
                addName= '|T626001:0|t|cff28a3ff'..(e.onlyChinese and '法师传送门' or format(UNITNAME_SUMMON_TITLE14, UnitClass('player'))..'|r')

                if Save.isLeft then
                    C_Timer.After(4, function()
                        if UnitAffectingCombat('player') then
                            self:RegisterEvent('PLAYER_REGEN_ENABLED')
                        else
                            Init()
                        end
                    end)
                else
                    Init()
                end

            else
                Tab=nil
            end
            self:UnregisterEvent('ADDON_LOADED')

            C_Timer.After(4, function()
                WoWTools_ToolsButtonMixin:AddOptions(Init_Options)
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_MagePortal']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if self.combat then
            self.combat=nil
            Init()
        end
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)