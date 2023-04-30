local id, e= ...
if e.Player.class~='MAGE' then
    return
end
local Tab
if e.Player.faction=='Horde' then--部落
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
elseif e.Player.faction=='Alliance' then
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
else
    return
end

local addName=UNITNAME_SUMMON_TITLE14:format(UnitClass('player'))
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
        if IsSpellKnown(tab.spell) then
            local button=e.Cbtn2(nil, e.toolsFrame, true, true)

            e.ToolsSetButtonPoint(button, not find, true)--设置位置
            find=true

            button.spell= tab.spell
            button.spell2= tab.spell2
            local name,_,icon = GetSpellInfo(tab.spell)

            button:SetAttribute('type', 'spell')--设置属性
            button:SetAttribute('spell', name or tab.spell)
            button.texture:SetTexture(icon)

            button.text=e.Cstr(button, {color= not tab.luce})
            button.text:SetPoint('RIGHT', button, 'LEFT')
            local text=name:gsub('(.+):','')
            text=text:gsub('(.+)：','');
            text=text:gsub('(.+)-','');
            button.text:SetText(text)

            if tab.luce then
                button.border:SetAtlas('bag-border')--设置高亮
            end

            if tab.spell2 and IsSpellKnown(tab.spell2) then--右击
                name,_,icon = GetSpellInfo(tab.spell2)
                button:SetAttribute('type2', 'spell')
                button:SetAttribute('spell2', name or tab.spell2)

                button.texture2=button:CreateTexture(nil,'OVERLAY')
                button.texture2:SetPoint('TOPRIGHT',-6,-6)
                button.texture2:SetSize(10, 10)
                button.texture2:SetTexture(icon)
                button.texture2:AddMaskTexture(button.mask)
                button:RegisterEvent('PLAYER_REGEN_DISABLED')
                button:RegisterEvent('PLAYER_REGEN_ENABLED')
                button:RegisterEvent('SPELL_UPDATE_COOLDOWN')

                e.SetItemSpellCool(button, nil, tab.spell)--设置冷却

                button:SetScript("OnEvent", function(self, event)
                    if event=='SPELL_UPDATE_COOLDOWN' then
                        e.SetItemSpellCool(self, nil, self.spell2)--设置冷却
                    elseif event=='PLAYER_REGEN_DISABLED' then
                        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                    elseif event=='PLAYER_REGEN_ENABLED' then
                        self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                    end
                end)
            end

            button.spell= tab.spell
            button.spell2= tab.spell2
            button:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spell)
                if self.spell2 then
                    e.tips:AddLine(' ')
                    local link= icon and '|T'..icon..':0|t' or ''
                    link= link.. (GetSpellLink(self.spell2) or GetSpellInfo(self.spell2) or ('spellID'..self.spell2))
                    link= link .. (e.GetSpellItemCooldown(self.spell2, nil) or '')
                    e.tips:AddDoubleLine(link, e.Icon.right)
                end
                e.tips:Show()
            end)
            button:SetScript('OnLeave', function() e.tips:Hide() end)
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
            if not e.toolsFrame.disabled then
                C_Timer.After(2.7, function()
                    if UnitAffectingCombat('player') then
                        panel.combat= true
                    else
                        Init()--初始
                        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
                    end
                end)
                panel:UnregisterEvent('ADDON_LOADED')
            else
                panel:UnregisterAllEvents()
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