local id, e = ...
local addName=UNITNAME_SUMMON_TITLE14:format(PLAYER_DIFFICULTY5)--挑战的传送门 'ChallengersPath'
local panel=CreateFrame("Frame")
local buttons={}
local Save={}

local FBList={--{spell=数字, ins=副本ID 数字 journalInstanceID, name=自定义名称 字符}
    {spell=367416, ins=1194},--街头商贩之路(集市)
    {spell=354469, ins=1189},--石头守望者之路(雷文德斯)
    {spell=354465, ins=1185},--罪魂之路(雷文德斯) 
    {spell=354468, ins=1188},--狡诈之神之路(炽蓝仙野) 
    {spell=354464, ins=1184},--雾林之路(炽蓝仙野)
    {spell=354462, ins=1182},--勇者之路(晋升堡垒) 
    {spell=354466, ins=1186},--升腾者之路(晋升堡垒) 
    {spell=354463, ins=1183},--瘟疫之路(玛卓克萨斯) 
    {spell=354467, ins=1187},--不败之路(玛卓克萨斯)
    {spell=373190, ins=1190},--纳斯利亚堡
    {spell=373191, ins=1193},--统御圣所
    {spell=373192, ins=1195},--初诞者圣墓

    {spell=159895, ins=385},--血槌之路
    {spell=159896, ins=558},--铁船之路(码头)
    {spell=159897, ins=547},--警戒者之路
    {spell=159898, ins=476},--通天之路
    {spell=159899, ins=537},--新月之路
    {spell=159900, ins=536},--暗轨之路(车站)
    {spell=159901, ins=556},--青翠之路
    {spell=159902, ins=559},--火山之路

    {spell=131222, ins=321},--魔古皇帝之路
    {spell=131204, ins=313},--青龙之路
    {spell=131205, ins=302},--烈酒之路
    {spell=131206, ins=312},--影踪派之路
    {spell=131225, ins=303},--残阳之路
    {spell=131231, ins=311},--血色利刃之路 血色大厅
    {spell=131229, ins=316},--血色法冠之路
    {spell=131232, ins=246},--通灵师之路
    {spell=131228, ins=324},--玄牛之路

    {spell=373262, ins=860},--堕落守护者之路(卡拉赞)
    {spell=373274, ins=1178},--机械王子之路(麦卡贡)

    {spell=393764, ins=721},--[英灵殿]
    {spell=393283, ins=1204},--[注能大厅]
    {spell=393279, ins=1203},--[碧蓝魔馆]
    {spell=393276, ins=1199},--[奈萨鲁斯]
    {spell=393267, ins=1196},--[蕨皮山谷]
    {spell=393262, ins=1198},--[诺库德阻击战]
    {spell=393256, ins=1202},--利爪防御者之路[红玉新生法池]
    {spell=393222, ins=1197},--看护者遗产之路 [奥达曼：提尔的遗产]
    {spell=393766, ins=800},--大魔导师之路(群星庭院)
    {spell=393273, ins=1201},--巨龙学位之路(艾杰斯亚学院)
  
    {spell=396129, ins=1196},--传送：蕨皮山谷
    {spell=396130, ins=1204},--传送：注能大厅
    {spell=396128, ins=1199},--传送：奈萨鲁斯
    {spell=396127, ins=1197},--传送：奥达曼：提尔的遗产
    {spell=272262, ins=1001},--传送到自由镇
    {spell=272269, ins=1022},--传送：地渊孢林
    {spell=205379, ins=767},--传送：奈萨里奥的巢穴
    {spell=88775, ins=68},--传送到旋云之巅
}

for _, tab in pairs(FBList) do
    if tab and tab.spell and IsSpellKnown(tab.spell) then
        e.LoadDate({id=tab.spell, type='spell'})
    end
end

--####
--初始
--####
local function Init()
    local find
    for _, tab in pairs(FBList) do
        if IsSpellKnown(tab.spell) then--or not IsSpellKnown(tab.spell) then
            buttons[tab.spell]=e.Cbtn2(nil, e.toolsFrame, true)

            local name, _, icon = GetSpellInfo(tab.spell)
            buttons[tab.spell]:SetAttribute('type', 'spell')--设置属性
            buttons[tab.spell]:SetAttribute('spell', name or tab.spell)
            buttons[tab.spell].texture:SetTexture(icon)

            e.ToolsSetButtonPoint(buttons[tab.spell], not find)--设置位置
            find=true

            name = tab.ins and EJ_GetInstanceInfo(tab.ins) or name--设置名称
            if name then
                name = tab.name or e.WA_Utf8Sub(name, 2, 5)
                if not buttons[tab.spell].name then
                    buttons[tab.spell].name=e.Cstr(buttons[tab.spell], {size=10, color=true, justifyH='CENTER'})--size, nil, nil, true, nil,'CENTER')
                end
                buttons[tab.spell].name:SetPoint('CENTER',0,-5)
                buttons[tab.spell].name:SetText(name)
            end

            buttons[tab.spell]:SetScript("OnEnter",function(self)--设置事件
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(tab.spell)
                e.tips:AddLine(' ')
                --[[local insName, _, _, buttonImage1 = EJ_GetInstanceInfo(tab.ins)
                if tab.ins then
                    e.tips:AddDoubleLine((buttonImage1 and '|T'..buttonImage1..':0|t' or '')..(insName or ('journalInstanceID: '..tab.ins)), ADVENTURE_JOURNAL..e.Icon.right)
                end]]
                --e.tips:AddDoubleLine(e.onlyChinese and '菜单' or MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.mid)
                e.tips:Show()
            end)
            buttons[tab.spell]:SetScript('OnLeave', function() e.tips:Hide() end)

            --[[buttons[tab.spell]:SetScript('OnMouseDown', function(self, d)
                if d=='RightButton' then
                    ToggleEncounterJournal();
                end
                if d=='RightButton' and tab.ins then
                    local frame=EncounterJournal;
                    if not frame or not frame:IsShown() then
                        ToggleEncounterJournal();
                    end
                    securecall('NavBar_Reset', EncounterJournal.navBar)
                    securecall('EncounterJournal_DisplayInstance', tab.ins)
                end
            end)]]
            buttons[tab.spell]:RegisterEvent('PLAYER_REGEN_DISABLED')--设置, 冷却
            buttons[tab.spell]:RegisterEvent('PLAYER_REGEN_ENABLED')
            buttons[tab.spell]:RegisterEvent('SPELL_UPDATE_COOLDOWN')
            buttons[tab.spell]:SetScript("OnEvent", function(self, event, arg1)
                if event=='PLAYER_REGEN_DISABLED' then
                    self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
                elseif event=='PLAYER_REGEN_ENABLED' then
                    self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                elseif event=='SPELL_UPDATE_COOLDOWN' then
                    e.SetItemSpellCool(self, nil, tab.spell)--冷却
                end
            end)
            buttons[tab.spell]:SetScript('OnShow', function(self)
                e.SetItemSpellCool(self, nil, tab.spell)--冷却
            end)
            e.SetItemSpellCool(buttons[tab.spell], nil, tab.spell)--冷却
            buttons[tab.spell].cooldown:SetAlpha(0.5)
        end
    end
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            --Save= WoWToolsSave[addName..'Tools'] or Save
            Save={}

            if not e.toolsFrame.disabled then
                C_Timer.After(2.6, function()
                    if UnitAffectingCombat('player') then
                        panel.combat= true
                    else
                        Init()--初始
                        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
                    end
                end)
                panel:UnregisterEvent('ADDON_LOADED')
            else
                FBList=nil
                panel:UnregisterAllEvents()
            end
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            Init()
            panel.combat=nil
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)