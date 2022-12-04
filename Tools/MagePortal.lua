local className, _, classId = UnitClass('player')
local englishFaction = UnitFactionGroup('player')
if classId~=8 or not englishFaction or englishFaction=='Neutral' then--不是法师, 不加载
    return
end

local id, e= ...

local Tab
if englishFaction=='Horde' then--部落
    Tab={
        {spell=3567, spell2=11417, luce=true,},--传送门：奥格瑞玛
        {spell=3563, spell2=11418,},--传送门：幽暗城
        {spell=3566, spell2=11420,},--传送门：雷霆崖
        {spell=32272, spell2=32267,},--传送门：银月城
        {spell=49358, spell2=49361,},--传送门：斯通纳德
        {spell=35715, spell2=35717,},--传送门：沙塔斯
        {spell=53140, spell2=53142,},--传送门：达拉然-诺森德
        {spell=88344, spell2=88346,},--传送门：托尔巴拉德
        {spell=132627, spell2=132626,},--传送门：锦绣谷
        {spell=176242, spell2=176244,},--传送门：战争之矛
        {spell=224869, spell2=224871,},--传送门：达拉然-破碎群岛
        {spell=281404, spell2=281402,},--传送门：达萨罗
        {spell=344587, spell2=344597,},--传送门：奥利波斯
        {spell=395277, spell2=395289, luce=true},--传送门-瓦德拉肯
        {spell=120145,},--远古传送：达拉然
        {spell=193759,},--传送：守护者圣殿
    }
else
    Tab={
        {spell=3561, spell2=10059, luce=true,},--传送门：暴风城
        {spell=3562, spell2=11416,},--传送门：铁炉堡
        {spell=3565, spell2=11419,},--传送门：达纳苏斯
        {spell=32271, spell2=32266,},--传送门：埃索达
        {spell=49359, spell2=49360,},--传送门：塞拉摩
        {spell=33690, spell2=33691,},--传送门：沙塔斯
        {spell=53140, spell2=53142,},--传送门：达拉然-诺森德
        {spell=88342, spell2=88345,},--传送门：托尔巴拉德
        {spell=132621, spell2=132620,},--传送门：锦绣谷
        {spell=176248, spell2=176246,},--传送门：暴风之盾
        {spell=224869, spell2=224871,},--传送门：达拉然-破碎群岛
        {spell=281403, spell2=281400,},--传送门：伯拉勒斯
        {spell=344587, spell2=344597,},--传送门：奥利波斯
        {spell=395277, spell2=395289, luce=true},--传送门-瓦德拉肯
        {spell=120145,},--远古传送：达拉然,
        {spell=193759,},--传送：守护者圣殿,
    }
end

local find2
for _, tab in pairs(Tab) do
    if IsSpellKnown(tab.spell) then
        e.LoadSpellItemData(tab.spell, true)--加载法术, 物品数据
        if tab.spell2 and IsSpellKnown(tab.spell2) then
            e.LoadSpellItemData(tab.spell2, true)--加载法术, 物品数据
        end
        find2=true
    end
end
if not find2 then
    return
end

local addName=UNITNAME_SUMMON_TITLE14:format(className)
local Save={}
local panel=CreateFrame("Frame")

local function setCooldown(self, spellID)--设置冷却
    local start, duration, _, modRate = GetSpellCooldown(spellID)
    e.Ccool(self, start, duration, modRate, true, nil, true)--冷却条
end

local function setName(self)--设置名称
    if not Save.notShowName then
        if not self.text then
            self.text=e.Cstr(self, nil, nil, nil, not self.luce)
            self.text:SetPoint('RIGHT', self, 'LEFT')
        end
        local text=self.name:gsub('(.+):','')
        text=text:gsub('(.+)：','');
        text=text:gsub('(.+)-','');
        self.text:SetText(text)
    elseif self.text then
        self.text:SetText('')
    end
end

local function setLuce(self)--设置高亮
    if self.luce then
        self.border:SetAtlas('bag-border')
    else
        self.border:SetAtlas('bag-reagent-border')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    if not type then
        return
    end
    local info={--显示名称
        text=PROFESSIONS_FLYOUT_SHOW_NAME,
        checked= not Save.notShowName,
        func=function()
            if not Save.notShowName then
                Save.notShowName=true
            else
                Save.notShowName=false
            end
            for _, button in pairs(panel.button) do
                setName(button)--设置名称
            end
        end,
    }
    UIDropDownMenu_AddButton(info, level)

end

--####
--初始
--####
local function Init()
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel.button={}
    local find
    for index, tab in pairs(Tab) do
        if IsSpellKnown(tab.spell) then
            local button=e.Cbtn2(nil, e.toolsFrame, true, true)
            panel.button[index]=button
            e.ToolsSetButtonPoint(button, not find, true)--设置位置
            find=true

            local name,_,icon = GetSpellInfo(tab.spell)
            button:SetAttribute('type', 'spell')
            button:SetAttribute('spell', name or tab.spell)
            button.texture:SetTexture(icon)

            local text=name:gsub('(.+):','')
            text=text:gsub('(.+)：','');
            text=text:gsub('(.+)-','');
            button.name=text
            button.luce=tab.luce
            setName(button)--设置名称
            if tab.luce then
                button.border:SetAtlas('bag-border')--设置高亮
            end

            local rightSpell= tab.spell2 and IsSpellKnown(tab.spell2)
            if rightSpell then--右击
                name,_,icon = GetSpellInfo(tab.spell2)
                button:SetAttribute('type2', 'spell')
                button:SetAttribute('spell2', name or tab.spell2)

                local size= (e.toolsFrame.size or 30)/3
                button.texture2=button:CreateTexture(nil,'OVERLAY')
                button.texture2:SetPoint('TOPRIGHT',-6,-6)
                button.texture2:SetSize(size, size)
                button.texture2:SetTexture(icon)
                button.texture2:AddMaskTexture(button.mask)
                button:RegisterEvent('PLAYER_REGEN_DISABLED')
                button:RegisterEvent('PLAYER_REGEN_ENABLED')
                button:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                setCooldown(button, tab.spell2)--设置冷却
                button:SetScript("OnEvent", function(self, event)
                    if event=='SPELL_UPDATE_COOLDOWN' then
                        setCooldown(self, tab.spell2)
                    elseif event=='PLAYER_REGEN_DISABLED' then
                        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                    elseif event=='PLAYER_REGEN_ENABLED' then
                        self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                    end
                end)
            end

            button:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(tab.spell)
                if rightSpell and name then
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine((icon and '|T'..icon..':0|t' or '').. name..e.GetSpellCooldown(tab.spell2), e.Icon.right)
                end
                e.tips:AddDoubleLine(PROFESSIONS_FLYOUT_SHOW_NAME, e.Icon.mid)
                e.tips:Show()
            end)
           button:SetScript('OnLeave', function() e.tips:Hide() end)

           button:SetScript('OnMouseWheel', function(self, d)
                ToggleDropDownMenu(1,nil, panel.Menu, self, 0,0, {button=self})
           end)

           
        end
    end
end

--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.9, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
                else
                    Init()--初始
                    panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
                end
            end)
        else
            panel:UnregisterAllEvents()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
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