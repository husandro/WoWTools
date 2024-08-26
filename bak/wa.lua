local Faction= UnitFactionGroup("player")
local Tab
if Faction=='Horde' then--部落
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
elseif Faction=='Alliance' then
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
end

if Tab then
do
for _, info in pairs(Tab) do
C_Spell.RequestLoadSpellData(info.spell)
if info.spell2 then
C_Spell.RequestLoadSpellData(info.spell2)
end
end
end

local Button= _G['WoWtools_MagePortal_WA'] 
if not Button then
    Button=CreateFrame("Button", 'WoWtools_MagePortal_WA', aura_env.region, "SecureActionButtonTemplate");
    Button:SetHighlightAtlas('Forge-ColorSwatchSelection');
    Button:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress')
    Button.Frame= CreateFrame("Frame")
    Button.Frame:SetAllPoints()
    Button.Frame:Hide()
    Button:SetScript("OnMouseDown", function(self)
        self.Frame:SetShown(not self:IsShown())
    end)

    Button:RegisterEvent('PLAYER_REGEN_DISABLED')
    Button:RegisterEvent('PLAYER_REGEN_ENABLED')
    Button:SetScript('OnEvent', function(self, event)
        self:SetShown(event=='PLAYER_REGEN_ENABLED')
    end)

    Button.btn={}
    local ActionButtonUseKeyDown=C_CVar.GetCVarBool("ActionButtonUseKeyDown")
    local LeftButtonDown = ActionButtonUseKeyDown and 'LeftButtonDown' or 'LeftButtonUp'
    local RightButtonDown= ActionButtonUseKeyDown and 'RightButtonDown' or 'RightButtonUp'
    for index, info in pairs(Tab) do
        B= CreateFrame("Button", nil, Button.Frame, "SecureActionButtonTemplate");
        B:RegisterForClicks(LeftButtonDown, RightButtonDown);
        B:SetHighlightAtlas('Forge-ColorSwatchSelection');
        B:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress');
        B:SetNormalTexture(C_Spell.GetSpellTexture(info.spell) or 0);
        B:SetAttribute('type1', 'spell');
        B:SetAttribute('spell1', info.spell)
        B:SetAttribute('type2', 'spell');
        B:SetAttribute('spell2', info.spell2)
        B:SetPoint('BOTTOM', index==1 and Button or Button.btn[index-1], 'TOP')
        B.spell=info.spell
        B.spell2=info.spell2
        table.insert(Button.btn, B)
        if info.spell2 then
            B.texture= B:CreateTexture(nil, "ARTWORK")
            B.texture:SetSize(12,12)
            B.texture:SetPoint('TOPRIGHT')
        end
        B:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self.spell)
            if self.spell2 then
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(
                    ('|T'..(C_Spell.GetSpellTexture(self.spell2) or 0)..':0|t')
                    ..(C_Spell.GetSpellName(self.spell2) or ''),
                    '|A:newplayertutorial-icon-mouse-rightbutton:0:0|a'
                )
            end
            GameTooltip:Show()
        end)
        
        B.text= B:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        B.text:SetPoint('RIGHT', B, 'LEFT')
        B.text:SetTextColor(0.25, 0.78, 0.92)
        B.text:SetText(LOCALE_zhCN and info.name or C_Spell.GetSpellName(info.spell) or '')
    end
end

Button:ClearAllPoints()
Button:SetAllPoints(aura_env.region)
local w,h= Button:GetSize()
for _, btn in pairs(Button.btn) do
    btn:SetSize(w,h)
end

end