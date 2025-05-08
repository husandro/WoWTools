
if WoWTools_DataMixin.Player.Class~='MAGE' then
    return
end

local Tab={}
if WoWTools_DataMixin.Player.Faction=='Horde' then--部落
    Tab={
        {spell=446540, spell2=446534, name='多恩诺嘉尔', luce=true},
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
        {spell=120145, name='远古传送'},
        {spell=193759, name='守护者圣殿'},
    }
elseif WoWTools_DataMixin.Player.Faction=='Alliance' then
    Tab={
        {spell=446540, spell2=446534, name='多恩诺嘉尔', luce=true},
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
        {spell=120145, name='远古传送'},
        {spell=193759, name='守护者圣殿'},
    }
else
    return
end

for _, tab in pairs(Tab) do
    WoWTools_Mixin:Load({id=tab.spell, type='spell'})
    WoWTools_Mixin:Load({id=tab.spell2, type='spell'})
end

local P_Save={
    isLeft=true,
    showText=true,
    --disabled
}

local function Save()
    return WoWToolsSave['Tools_MagePortal']
end

local Buttons
local addName









local function Get_Spell_Label(spellID, text)
    if text then
        text= WoWTools_TextMixin:CN(text, {spellID=spellID, isName=true})
        text=text:gsub('(.+):','')
        text=text:gsub('(.+)：','');
        text=text:gsub('(.+)-','');
        return text
    end
end





local function Set_Button_Label(btn)
    if Save().showText then
        if not btn.text then
            btn.text=WoWTools_LabelMixin:Create(btn, {color= not btn.luce})
        end
        btn.text:ClearAllPoints(0)
        if Save().isLeft then
            btn.text:SetPoint('RIGHT', btn, 'LEFT')
        else
            btn.text:SetPoint('LEFT', btn, 'RIGHT')
        end
        btn.text:SetText(btn.name1 or '')
    elseif btn.text then
        btn.text:SetText('')
    end
end

local function Set_Button_All_Label()
    for _, btn in pairs(Buttons) do
        Set_Button_Label(btn)
    end
end





















local function Init_Options(category, layout)
    WoWTools_PanelMixin:Header(layout, addName)
    local initializer=WoWTools_PanelMixin:OnlyCheck({
        category= category,
        name= '|cff3fc6ea'..(WoWTools_DataMixin.onlyChinese and '启用' or ENABLE)..'|r',
        tooltip= addName,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
        end
    })

    WoWTools_PanelMixin:OnlyCheck({
        category= category,
        name= '|cff3fc6ea'..(WoWTools_DataMixin.onlyChinese and '位置: 放左边' or (CHOOSE_LOCATION..': '..HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT ))..'|r',
        tooltip= addName,
        GetValue= function() return Save().isLeft end,
        SetValue= function()
            Save().isLeft= not Save().isLeft and true or nil
            WoWTools_ToolsMixin:RestAllPoint()--重置所有按钮位置
            Set_Button_All_Label()
        end
    }, initializer)

    WoWTools_PanelMixin:OnlyCheck({
        category= category,
        name= '|cff3fc6ea'..(WoWTools_DataMixin.onlyChinese and '显示名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, NAME))..'|r',
        tooltip= addName,
        GetValue= function() return Save().showText end,
        SetValue= function()
            Save().showText= not Save().showText and true or nil
            Set_Button_All_Label()
        end
    }, initializer)

end














local function Init_Button(tab)
    local name= C_Spell.GetSpellName(tab.spell)
    local icon= C_Spell.GetSpellTexture(tab.spell)

    local btn=WoWTools_ToolsMixin:CreateButton({
        name='MagePortal_Spell_'..tab.spell,
        tooltip='|T626001:0|t'..('|T'..(icon or 0)..':0|t')..(WoWTools_TextMixin:CN(name, {spellID=tab.spell, isName=true}) or tab.spell),
        isLeftOnlyLine=function()
            return Save().isLeft
        end,
        disabledOptions=true,
    })

    if not btn then
        return
    end

    btn.spellID= tab.spell
    btn.spellID2= tab.spell2
    btn.luce= tab.luce
    btn.name1= WoWTools_DataMixin.onlyChinese and tab.name

    function btn:set_cool()
        if self:IsVisible() then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID2})--设置冷却
        else
            WoWTools_CooldownMixin:SetFrame(self)
        end
    end

    function btn:set_alpha()
        self:SetAlpha((GameTooltip:IsOwned(self) or IsSpellKnownOrOverridesKnown(self.spellID)) and 1 or 0.3)
    end

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
            self.name1= self.name1 or Get_Spell_Label(self.spellID, name1)
            done=true
        end

        if self.spellID2 then
            local name2= C_Spell.GetSpellName(self.spellID2)
            local icon2= C_Spell.GetSpellTexture(self.spellID2)
            if name2 and icon2 then
                self:SetAttribute('type2', 'spell')
                self:SetAttribute('spell2', name2)
                self.texture2:SetTexture(icon2)
                self.name2= self.name2 or name2
                done=true
            else
                done=false
            end
        end
        Set_Button_Label(self)
        return done
    end

    --[[if Save().showText then
        btn.text=WoWTools_LabelMixin:Create(btn, {color= not tab.luce})
        if Save().isLeft then
            btn.text:SetPoint('RIGHT', btn, 'LEFT')
        else
            btn.text:SetPoint('LEFT', btn, 'RIGHT')
        end
        if WoWTools_DataMixin.onlyChinese then
            btn.text:SetText(tab.name)
        end
    end]]

    if tab.luce then
        btn.border:SetAtlas('bag-border')--设置高亮
    end
    btn.luce= tab.luce


    if btn.spellID2 then
        btn.texture2= btn:CreateTexture(nil,'OVERLAY')
        btn.texture2:SetPoint('TOPRIGHT',-6,-6)
        btn.texture2:SetSize(10, 10)
        btn.texture2:AddMaskTexture(btn.IconMask)
        btn:SetScript('OnShow', function(self)
            self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
            self:set_cool()
            self:set_alpha()
        end)
        btn:SetScript('OnHide', function(self)
            self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
            self:set_cool()
        end)
        btn:set_cool()
        if btn:IsVisible() then
            btn:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        end

    else
        btn:SetScript('OnShow', function(self)
            self:set_alpha()
        end)
    end

    btn:SetScript("OnEvent", function(self, event, arg1)
        if event=='SPELL_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID2})--设置冷却

        elseif event=='SPELL_DATA_LOAD_RESULT' then
            if (arg1==self.spellID or arg1==self.spellID2) then
                if self:CanChangeAttribute() then
                    if self:settings() then
                        self:UnregisterEvent('SPELL_DATA_LOAD_RESULT')
                    end
                else
                    self:RegisterEvent('PLAYER_REGEN_ENABLED')
                end
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            if self:settings() then
                self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            end
        end
    end)







    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_alpha()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(self.spellID)
        if not IsSpellKnownOrOverridesKnown(self.spellID) then
            GameTooltip:AddLine(format('|cnRED_FONT_COLOR:%s|r', WoWTools_DataMixin.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB))
        end
        if self.spellID2 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(
                '|T'..(C_Spell.GetSpellTexture(self.spellID2) or 0)..':0|t'
                ..(WoWTools_TextMixin:CN(C_Spell.GetSpellLink(self.spellID2), {spellID=self.spellID2, isName=true}) or ('spellID'..self.spellID2))
                ..(WoWTools_CooldownMixin:GetText(self.spellID2, nil) or ''),
                format('%s%s',
                    IsSpellKnownOrOverridesKnown(self.spellID2) and '' or format('|cnRED_FONT_COLOR:%s|r',WoWTools_DataMixin.onlyChinese and '未学习' or TRADE_SKILLS_UNLEARNED_TAB),
                    WoWTools_DataMixin.Icon.right)
                )
        end
        GameTooltip:Show()
        self:set_alpha()
        self:set_cool()
    end)

    if not btn:settings() then
        btn:RegisterEvent('SPELL_DATA_LOAD_RESULT')
    end
    C_Timer.After(2, function()
        btn:set_alpha()
    end)
    table.insert(Buttons, btn)
end

















--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("LOADING_SCREEN_DISABLED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Tools_MagePortal']= WoWToolsSave['Tools_MagePortal'] or P_Save

            if not Save().disabled and WoWTools_ToolsMixin.Button then
                addName= '|T626001:0|t|cff3fc6ea'..(WoWTools_DataMixin.onlyChinese and '法师传送门' or format(UNITNAME_SUMMON_TITLE14, UnitClass('player'))..'|r')
            else
                Tab={}
            end
            self:UnregisterEvent('ADDON_LOADED')

            WoWTools_ToolsMixin:AddOptions(Init_Options)

        end

    elseif event=='LOADING_SCREEN_DISABLED' then
        Buttons={}
        for _, tab in pairs(Tab) do
            Init_Button(tab)
        end
        Tab={}
        self:UnregisterEvent(event)
    end
end)