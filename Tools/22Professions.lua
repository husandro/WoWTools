if PlayerGetTimerunningSeasonID() then
    return
end

local id, e = ...
local addName= PROFESSIONS_TRACKER_HEADER_PROFESSION
local Save={
    setButton=true,
    --disabledClassTrainer=true,--隐藏，全学，按钮
    --disabledEnchant=true,--禁用，自动放入，附魔纸
    --disabled--禁用，按钮
    ArcheologySound=true, --考古学
}

local panel=CreateFrame("Frame")
local ArcheologyButton
local UNLEARN_SKILL_CONFIRMATION= UNLEARN_SKILL_CONFIRMATION








--##########
--TOOLS，按钮
--##########
local function Init_Tools_Button()
    --11版本
    
    local tab={GetProfessions()}--local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    for index, type in pairs(tab) do
        if type then --and index~=4 and index~=3 then
            local name, _, _, _, numAbilities, spelloffset = GetProfessionInfo(type)
            local info= C_Spell.GetSpellInfo(spelloffset+ 1, 'spell') or {}

            local icon= info.iconID
            local spellID= info.spellID
            local btn= e.Cbtn2({
                name=id..addName..name,
                parent= e.toolsFrame,
                click=true,-- right left
                notSecureActionButton=nil,
                notTexture=nil,
                showTexture=true,
                sizi=nil,
            })

            e.ToolsSetButtonPoint(btn)--设置位置

            btn.spellID = spellID
            btn.name = name
            btn.index= index


            btn:SetAttribute("type1", "spell")
            btn:SetAttribute("spell", spellID)
            btn.texture:SetTexture(icon)
            btn.texture:SetShown(true)

            function btn:set_tooltip()
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spellID)
                if self.index==5 then
                    local link= C_Spell.GetSpellLink(818)
                    local texture= C_Spell.GetSpellTexture(818)
                    if link and texture then
                        local text= '|T'..texture..':0|t'.. link
                        if PlayerHasToy(134020) then--玩具,大厨的帽子
                            local link2,_,_,_,_,_,_,_, texture2 = select(2, C_Item.GetItemInfo(134020))
                            if link2 and texture2 then
                                text=text..'|T'..texture2..':0|t'..link2
                            end
                        end
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(text, e.Icon.right)
                    end
                elseif self.spellID2 then
                    local link= C_Spell.GetSpellLink(self.spellID2)
                    local texture= C_Spell.GetSpellTexture(self.spellID2)
                    if link and texture then
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine('|T'..texture..':0|t'.. link, e.Icon.right)
                    end
                end

                if (self.index==3 or self.index==4) and not UnitAffectingCombat('player') then
                    e.tips:AddDoubleLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, 'F', 0,1,0, 0,1,0)
                    e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.Icon.mid..(e.onlyChinese and '滚轮向上滚动' or KEY_MOUSEWHEELUP))
                    e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.mid..(e.onlyChinese and '轮向下滚动' or KEY_MOUSEWHEELDOWN))
                end
                e.tips:Show()
            end
            btn:SetScript('OnLeave', GameTooltip_Hide)
            btn:SetScript('OnEnter', btn.set_tooltip)


            if index==3 or index==4 then--钓鱼，考古， 设置清除快捷键
                function btn:set_key_text(text)
                    self.text:SetText(text)
                    if self.keyButton then
                        self.keyButton:set_text()
                    end
                end
                function btn:set_OnMouseWheel(d)
                    if d==1 then
                        e.SetButtonKey(self, true,'F', 'RightButton')
                        self:RegisterEvent('PLAYER_REGEN_ENABLED')
                        self:RegisterEvent('PLAYER_REGEN_DISABLED')
                        print(id, e.cn(addName),'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '设置' or SETTINGS), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF')

                    elseif d==-1 then
                        e.SetButtonKey(self)
                        self:UnregisterEvent('PLAYER_REGEN_DISABLED')
                        self:UnregisterEvent('PLAYER_REGEN_ENABLED')

                        print(id, e.cn(addName),'|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                    end
                    self:set_tooltip()
                    self:set_key_text(d==1 and 'F' or '')
                end
                btn:SetScript('OnMouseWheel', btn.set_OnMouseWheel)
                btn:SetScript("OnEvent", function(self, event)
                    if event=='PLAYER_REGEN_ENABLED' then
                        e.SetButtonKey(self, true,'F', 'RightButton')
                        print(id, e.cn(addName),'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '设置' or SETTINGS), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF|r')
                    elseif event=='PLAYER_REGEN_DISABLED' then
                        e.SetButtonKey(self)
                        print(id, e.cn(addName),'|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                    end
                    self:set_key_text(event=='PLAYER_REGEN_ENABLED' and 'F' or '')
                end)
                btn.text=e.Cstr(btn, {color={r=1,g=0,b=0}})--nil,nil,nil,{1,0,0})
                btn.text:SetPoint('TOPRIGHT',-4,0)

                if index==3 then
                    ArcheologyButton= btn
                end
            end

            if index==5 then--烹饪用火
                local name2=IsSpellKnownOrOverridesKnown(818) and C_Spell.GetSpellName(818)
                if name2 then
                    local text=''
                    if PlayerHasToy(134020) then--玩具,大厨的帽子
                        local toyname=C_Item.GetItemNameByID('134020')
                        if toyname then
                            text= '/use '..toyname..'|n'
                        end
                    end
                    text=text..'/cast [@player]'..name2
                    if not btn.textureRight then
                        btn.textureRight= btn:CreateTexture(nil,'OVERLAY')
                        btn.textureRight:SetPoint('RIGHT',btn.border,'RIGHT',-6,0)
                        btn.textureRight:SetSize(8,8)
                        btn.textureRight:SetTexture(135805)
                        btn:SetScript('OnShow',function(self)
                            e.SetItemSpellCool(self, {sepll=818})
                        end)
                    end
                    btn:SetAttribute('type2', 'macro')
                    btn:SetAttribute("macrotext2", text)
                end
            elseif numAbilities and numAbilities>1 then
                local info2= C_Spell.GetSpellInfo(spelloffset+ 2, 'spell') or {}
                local icon2= info2.iconID
                local spellID2= info2.spellID
                if icon2 and spellID2 and icon2~=icon then
                    if not btn.textureRight then
                        btn.textureRight= btn:CreateTexture(nil,'OVERLAY')
                        btn.textureRight:SetPoint('RIGHT',btn.border,'RIGHT',-6,0)
                        btn.textureRight:SetSize(8,8)
                    end
                    btn.textureRight:SetTexture(icon2)
                end
                btn:SetAttribute("type2", "spell")
                btn:SetAttribute("spell2", spellID2)
                btn.spellID2= spellID2
            end
        end
    end
end




















--#############
--专业界面, 按钮
--#############
local function Init_ProfessionsFrame_Button()
    local last
    local tab={GetProfessions()}--prof1, prof2, archaeology, fishing, cooking
    if tab[3]==10 and #tab>3 then
        local archaeology=tab[3]--10
        table.remove(tab, 3)
        table.insert(tab, archaeology)
    end
    for k , index in pairs(tab) do
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(index)
        if icon and skillLine then
            local button= e.Cbtn(ProfessionsFrame, {icon='hide',size={32, 32}})
            button:SetNormalTexture(icon)
            if not last then
                button:SetPoint('BOTTOMLEFT', ProfessionsFrame, 'BOTTOMRIGHT',0, 35)
            elseif k==3 then
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0, 17)
            elseif skillLine==794 then
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0, 37)
            else
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0,2)
            end
            button:SetScript('OnMouseDown', function(self)
                C_TradeSkillUI.OpenTradeSkill(self.skillLine)
            end)
            button:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(self.name, 'skillLine '..self.skillLine)
                e.tips:AddDoubleLine(id, 'Tools')
                e.tips:Show();
            end)
            button:SetScript('OnLeave',function(self)
                e.tips:Hide()
                self:SetButtonState('NORMAL')
            end)
            button.name= name
            button.skillLine= skillLine

            if skillLine==185 then--烹饪用火
                local name2= C_Spell.GetSpellName(818)
                if name2 then
                    local btn= e.Cbtn(button, {type= true, texture=135805 ,size={32, 32}})
                    btn:SetPoint('LEFT', button, 'RIGHT',2,0)

                    function btn:set_event()
                        e.SetItemSpellCool(self, {spell=818})
                    end
                    function btn:settings()
                        if self:IsVisible() then
                            self:set_event()
                            self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                        else
                            self:UnregisterAllEvents()
                        end
                    end
                    btn:SetScript('OnEvent', btn.set_event)
                    btn:SetScript('OnShow', btn.settings)
                    btn:SetScript('OnHide', btn.settings)
                    btn:settings()

                  
                    btn:SetScript('OnLeave', GameTooltip_Hide)
                    btn:SetScript('OnEnter', function(self)
                        e.tips:SetOwner(self, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(818)
                        
                        if self.toyName then
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine('|T236571:0|t|cnGREEN_FONT_COLOR:'..self.toyName, e.Icon.right)
                        end
                        e.tips:Show()
                    end)

                    btn:SetAttribute('type1', 'spell')
                    btn:SetAttribute('spell1', name2)
                    btn:SetAttribute('unit', 'player')

                    local toyName=C_Item.GetItemNameByID(134020)--玩具,大厨的帽子
                    btn:SetAttribute('type2', 'item')
                    btn:SetAttribute('item2', toyName)
                    btn.toyName= toyName
                end
            end
            last= button
        end
    end
end

















--添一个,全学,专业, 按钮, 插件 TrainAll 
local function set_Blizzard_TrainerU()
    if Save.disabled then
        return
    end

    ClassTrainerFrame.BuyAll= e.Cbtn(ClassTrainerFrame, {type=false, size={ClassTrainerTrainButton:GetSize()}})
    ClassTrainerFrame.BuyAll:SetPoint('RIGHT', ClassTrainerTrainButton, 'LEFT',-2,0)
    ClassTrainerFrame.BuyAll.name=e.onlyChinese and '全部' or ALL
    ClassTrainerFrame.BuyAll.all= 0
    ClassTrainerFrame.BuyAll.cost= 0
	ClassTrainerFrame.BuyAll:SetText(ClassTrainerFrame.BuyAll.name)
    ClassTrainerFrame.BuyAll:SetScript("OnEnter",function(self)
        local text= C_CurrencyInfo.GetCoinTextureString(self.cost)
        if self.cost< GetMoney() then
            text= '|cnGREEN_FONT_COLOR:'..text..'|r'
        else
            text= '|cnGREEN_FONT_COLOR:'..text..'|r'
        end
		e.tips:SetOwner(self,"ANCHOR_BOTTOMLEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '全部' or ALL, e.onlyChinese and '学习' or LEARN)
		e.tips:AddDoubleLine(text, (e.onlyChinese and '可用' or AVAILABLE)..': '..'|cnGREEN_FONT_COLOR:'..self.all..'|r')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
		e.tips:Show()
	end)
	ClassTrainerFrame.BuyAll:SetScript("OnLeave",GameTooltip_Hide)

	ClassTrainerFrame.BuyAll:SetScript("OnClick",function()
        local index= WOW_PROJECT_ID==WOW_PROJECT_MAINLINE and 2 or 3
        local num, cost= 0, 0
        local tab={}
		for i=1,GetNumTrainerServices() do
			if select(index, GetTrainerServiceInfo(i))=="available" then
                local money= GetTrainerServiceCost(i) or 0
                if money<= GetMoney() then
                    local link=GetTrainerServiceItemLink(i) or GetTrainerServiceInfo(i)
                    BuyTrainerService(i)
                    cost= cost +money
                    num= num +1
                    if link then
                        table.insert(tab, link)
                    end
                else
                    print(id, e.cn(addName), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '金币不足' or NOT_ENOUGH_GOLD), C_CurrencyInfo.GetCoinTextureString(money))
                    break
                end
            end
		end
        C_Timer.After(0.5, function()
            for i, link in pairs(tab) do
                print('|cffff00ff'..i..'|r)', link)
            end
            print(id, 'Tools', e.cn(addName), '|cffff00ff'..num..'|r '..(e.onlyChinese and '学习' or LEARN), (cost>0 and '|cnGREEN_FONT_COLOR:' or '')..C_CurrencyInfo.GetCoinTextureString(cost))
        end)
	end)

	hooksecurefunc("ClassTrainerFrame_Update",function()--Blizzard_TrainerUI.lua 
        --local show= IsTradeskillTrainer()
        local index= WOW_PROJECT_ID==WOW_PROJECT_MAINLINE and 2 or 3
        ClassTrainerFrame.BuyAll.all=0
        ClassTrainerFrame.BuyAll.cost=0
        local tradeSkillStepIndex = GetTrainerServiceStepIndex();
        local category= tradeSkillStepIndex and select(index, GetTrainerServiceInfo(tradeSkillStepIndex))

        if tradeSkillStepIndex and (category=='used' or category=='available') then
            for i=1, GetNumTrainerServices() do
                if select(index, GetTrainerServiceInfo(i))=="available" then
                    ClassTrainerFrame.BuyAll.all= ClassTrainerFrame.BuyAll.all +1
                    ClassTrainerFrame.BuyAll.cost= ClassTrainerFrame.BuyAll.cost +(GetTrainerServiceCost(i) or 0)
                end
            end
        end

        ClassTrainerFrame.BuyAll:SetEnabled(ClassTrainerFrame.BuyAll.all>0)
        local text= ClassTrainerFrame.BuyAll.all..' '..ClassTrainerFrame.BuyAll.name
        text= (ClassTrainerFrame.BuyAll.all>0 and ClassTrainerFrame.BuyAll.cost>GetMoney() and '|cnRED_FONT_COLOR:' or '')..text
        ClassTrainerFrame.BuyAll:SetText(text)
        ClassTrainerFrame.BuyAll:SetShown(not Save.disabledClassTrainer)
	end)

    local btn2= e.Cbtn(ClassTrainerFrame.TitleContainer, {icon= not Save.disabledClassTrainer})
    if _G['MoveZoomInButtonPerClassTrainerFrame'] then
        btn2:SetPoint('RIGHT', _G['MoveZoomInButtonPerClassTrainerFrame'], 'LEFT')
    else
        btn2:SetPoint('LEFT', ClassTrainerFrame.TitleContainer, -5, -1)
    end
    btn2:SetSize(20,20)
    btn2:SetAlpha(0.5)
    btn2:SetScript('OnClick', function(self2)
        Save.disabledClassTrainer= not Save.disabledClassTrainer and true or nil
        ClassTrainerFrame.BuyAll:SetShown(not Save.disabledClassTrainer)
        self2:SetNormalAtlas(Save.disabledClassTrainer and e.Icon.disabled or e.Icon.icon)
    end)
    btn2:SetScript("OnEnter",function(self2)
		e.tips:SetOwner(ClassTrainerFrame.TitleContainer, "ANCHOR_TOPLEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '全部学习' or (ALL..' '.. LEARN), e.GetShowHide(not Save.disabledClassTrainer))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
		e.tips:Show()
        self2:SetAlpha(1)
        ClassTrainerFrame.BuyAll:SetButtonState('PUSHED')
	end)
	btn2:SetScript("OnLeave",function(self2)
        e.tips:Hide()
        self2:SetAlpha(0.5)
        ClassTrainerFrame.BuyAll:SetButtonState('NORMAL')
    end)
    --[[hooksecurefunc('ClassTrainerFrame_InitServiceButton', function(skillButton, elementData,...)
        local skillIndex = elementData.skillIndex;
        local isTradeSkill = elementData.isTradeSkill;
        local serviceName, serviceType, texture, reqLevel = GetTrainerServiceInfo(skillIndex);
    end)]]


    --增加物品，品质，颜色
    hooksecurefunc('ClassTrainerFrame_InitServiceButton', function(skillButton, elementData)        
        local itemLink= GetTrainerServiceItemLink(elementData.skillIndex)
        local r,g,b
        if itemLink then
            local quality= C_Item.GetItemQualityByID(itemLink)
            if quality then
                r,g,b= C_Item.GetItemQualityColor(quality)
            end
        end
        skillButton.name:SetTextColor(r or 1, g or 1, b or 1)
    end)
end



















--####
--初始
--####
local function Init_ProfessionsFrame()
    local btn2= e.Cbtn(ProfessionsFrame.TitleContainer, {icon=not Save.disabled, size={20, 20}})
    if _G['MoveZoomInButtonPerProfessionsFrame'] then
        btn2:SetPoint('LEFT', _G['MoveZoomInButtonPerProfessionsFrame'], 'RIGHT')
    else
        btn2:SetPoint('RIGHT', ProfessionsFrameTitleText, 'RIGHT', -24, 2)
    end
    btn2:SetScript('OnMouseDown', function(self2)
        Save.disabled= not Save.disabled and true or nil
        self2:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
        print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled),  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    btn2:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.toolsFrame.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.cn(addName), e.GetEnabeleDisable(not Save.disabled)..e.Icon.left)
        e.tips:Show()
        self2:SetAlpha(1)
    end)
    btn2:SetScript('OnLeave', function(self2)
        e.tips:Hide()
        self2:SetAlpha(0.5)
    end)
    btn2:SetAlpha(0.5)

    if Save.disabled then
        return
    end


    do
        Init_ProfessionsFrame_Button()--专业界面, 按钮
    end

    --###
    --数量
    --Blizzard_Professions.lua  ProfessionsRecipeSchematicFormMixin:Init
    hooksecurefunc(Professions,'SetupOutputIconCommon', function(outputIcon, quantityMin, quantityMax, icon, itemIDOrLink, quality)
        local num
        if itemIDOrLink and not Save.disabled then
            num= C_Item.GetItemCount(itemIDOrLink, true, false, true)
            local itemID= C_Item.GetItemInfoInstant(itemIDOrLink)
            if itemID then
                local all= 0--帐号数据
                for guid, info in pairs(e.WoWDate or {}) do
                    if guid and info and guid~=e.Player.guid then
                        local tab=info.Item[itemID]
                        if tab and tab.bag and tab.bank then
                           all= all+1
                        end
                    end
                end
                if all>0 then
                    num= num..' (+'..all..')'
                end
            end
        end
        if not outputIcon.countBag and num then
            outputIcon.countBag= e.Cstr(outputIcon, {color={r=0,g=1,b=0}, justifyH='CENTER'})--nil, nil, nil, {0,1,0}, nil, 'CENTER')
            outputIcon.countBag:SetPoint('BOTTOM', outputIcon, 'TOP',0,5)
        end
        if outputIcon.countBag then
            outputIcon.countBag:SetText(num or '')
        end
    end)


    --##################
    --移过，列表，物品提示
    --Blizzard_ProfessionsRecipeList.lua
    hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'OnEnter', function(self)
        local elementData = self:GetElementData()
        local info= elementData and elementData.data and elementData.data.recipeInfo
        if not info or not info.recipeID then
            return
        end
        
        local tradeSkillID, _, parentTradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(info.recipeID)
        e.tips:SetOwner(self, "ANCHOR_LEFT", -18, 0)
        e.tips:ClearLines()
        e.tips:SetRecipeResultItem(info.recipeID, {}, nil, info.unlockedRecipeLevel)
        e.tips:AddLine(' ')

        local text= e.cn(nil, {recipeID=info.recipeID}) or C_TradeSkillUI.GetRecipeSourceText(info.recipeID)
        if text then
            e.tips:AddLine(text, nil, nil, nil, true)
            e.tips:AddLine(' ')
        end
        e.tips:AddLine(info.categoryID and 'categoryID '..info.categoryID, tradeSkillID and 'tradeSkillID '..tradeSkillID or (info.sourceType and 'sourceType'..info.sourceType))
        e.tips:AddDoubleLine('recipeID '..info.recipeID, parentTradeSkillID and 'parentTradeSkillID '..parentTradeSkillID)
        if info.itemLevel or info.skillLineAbilityID then
            e.tips:AddDoubleLine(info.skillLineAbilityID and 'skillLineAbilityID '..info.skillLineAbilityID,  info.itemLevel and info.itemLevel>1 and format(e.onlyChinese and '物品等级%d' or ITEM_LEVEL, info.itemLevel))
        end
        e.tips:AddDoubleLine(e.toolsFrame.addName, e.cn(addName))
        e.tips:Show()
    end)


    --专业，列表，增加图标, 颜色
    hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'Init', function(self, node)
        local elementData = node:GetData();
        local recipeInfo = Professions.GetHighestLearnedRecipe(elementData.recipeInfo) or elementData.recipeInfo
        if not recipeInfo then
            return
        end
        if recipeInfo.icon and not self.texture then
            self.texture= self:CreateTexture(nil, 'OVERLAY')
            self.texture:SetPoint('RIGHT',2,0)
            self.texture:SetSize(22,22)
        end
        if self.texture then
            self.texture:SetTexture(recipeInfo.icon or 0)
        end

        local r,g,b--颜色        
        if recipeInfo.learned or recipeInfo.isRecraf then
            local link= recipeInfo.hyperlink        
            local quality= link and C_Item.GetItemQualityByID(link)
            if quality then
                r,g,b=C_Item.GetItemQualityColor(quality)
            end
            self.Label:SetTextColor(r or 1, g or 0.82, b or 0)
        else
            self.Label:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        end
    end)


    --######
    --附魔纸
    --Blizzard_ProfessionsRecipeSchematicForm.lua
    hooksecurefunc(ProfessionsFrame.CraftingPage.SchematicForm, 'Init', function(self, recipeInfo, isRecraftOverride)
        local recipeID = recipeInfo and recipeInfo.recipeID
        local isEnchant = recipeID and (self.recipeSchematic.recipeType == Enum.TradeskillRecipeType.Enchant) and not C_TradeSkillUI.IsRuneforging()

        if not isEnchant
            or not self.enchantSlot
            or not self.enchantSlot:IsShown()
            or Save.disabled--禁用，按钮
            or ItemUtil.GetCraftingReagentCount(38682)==0--没有， 附魔纸
        then
            if self.enchantSlot and self.enchantSlot.btn then
                self.enchantSlot.btn:SetShown(false)
            end
            return
        end

        local btn= self.enchantSlot.btn
        if not btn then
            btn= e.Cbtn(self.enchantSlot, {size={16,16}, icon= not Save.disabledEnchant})
            btn:SetPoint('TOPLEFT', self.enchantSlot, 'BOTTOMLEFT')
            btn:SetAlpha(0.3)
            btn:SetScript('OnClick', function(self2)
                Save.disabledEnchant= not Save.disabledEnchant and true or nil
                self2:SetNormalAtlas(Save.disabledEnchant and e.Icon.disabled or e.Icon.icon)
            end)
            btn:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.3) end)
            btn:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetItemByID(38682)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinese and '自动加入' or AUTO_JOIN, e.GetEnabeleDisable(not Save.disabledEnchant))
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
                self2:SetAlpha(1)
            end)
            self.enchantSlot.btn=btn
        end
        btn:SetShown(true)


        if Save.disabledEnchant then
            return
        end

        local candidateGUIDs = C_TradeSkillUI.GetEnchantItems(recipeID);
        for index, item in ipairs(ItemUtil.TransformItemGUIDsToItems(candidateGUIDs)) do
            if candidateGUIDs[index] and item and item:GetItemID()== 38682 then--附魔纸
                local itemLocal= Item:CreateFromItemGUID(candidateGUIDs[index])
                if itemLocal then
                    self.transaction:SetEnchantAllocation(itemLocal);
                    self.enchantSlot:SetItem(itemLocal);
                    self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
                    break
                end
            end
        end
    end)


    --Blizzard_ProfessionsSpecializations.lua
    --全加点，专精，
    hooksecurefunc(ProfessionsFrame.SpecPage, 'UpdateDetailedPanel', function(self, setLocked)
        local button=self.DetailedView.SpendAllPointsButton
        if not button then
            button= e.Cbtn(self.DetailedView.SpendPointsButton, {type=false, size={80, 22}})
            button:SetPoint('LEFT', self.DetailedView.SpendPointsButton, 'RIGHT',40,0)
            button:SetText(e.onlyChinese and '全部' or ALL)
            button:SetScript('OnClick', function(self2)
                local parent= self2:GetParent()
                while parent:IsEnabled() do
                    local success= C_Traits.PurchaseRank(self2.configID, self2.nodeID)
                    if not success then
                        return
                    end
                end
            end)
            button:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_TOPLEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(not e.onlyChinese and PROFESSIONS_SPECS_ADD_KNOWLEDGE or "运用知识", e.onlyChinese and '全部' or ALL)
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
            end)
            button:SetScript('OnLeave', GameTooltip_Hide)
            self.DetailedView.SpendAllPointsButton= button
        end
        button:SetShown(self.DetailedView.SpendPointsButton:IsShown())
        button:SetEnabled(self.DetailedView.SpendPointsButton:IsEnabled())
        button.nodeID= self:GetDetailedPanelNodeID();
        button.configID= self:GetConfigID()
    end)


    --可加点数， 提示
    hooksecurefunc(ProfessionsSpecPathMixin, 'UpdateProgressBar', function(self)
        if not self.ProgressBar:IsShown() then
            return
        end
        local currRank, maxRank = self:GetRanks()
        local text
        if currRank and maxRank then
            if currRank<maxRank then
                text= '+'..(maxRank-currRank)
            else
                text= '|A:auctionhouse-icon-favorite:0:0|a'
            end
        end
        if text and not self.SpendText2 then
            self.SpendText2= e.Cstr(self, {color={r=1, g=0, b=1}})
            self.SpendText2:SetPoint('LEFT', self.SpendText, 'RIGHT')
        end
        if self.SpendText2 then
            self.SpendText2:SetText(text or '')
        end
    end)
end






local function Init_Archaeology()

    --提示
    hooksecurefunc(ArchaeologyFrame.completedPage, 'UpdateFrame', function(self)
        if not IsArtifactCompletionHistoryAvailable() then
            return
        end
        for i=1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
            local btn=  self["artifact"..i]
            if btn and btn:IsShown() then
                local name, _, rarity, _, _,  _, _, _, _, completionCount = GetArtifactInfoByRace(btn.raceIndex, btn.projectIndex);
                local raceName = GetArchaeologyRaceInfo(btn.raceIndex)
                if raceName and name and completionCount and completionCount>0 then
                    local sub= raceName
                    if rarity == 0 then
                        name= '|cffffffff'..name..'|r'
                        sub= sub.."-|cffffffff"..(e.onlyChinese and '普通' or ITEM_QUALITY1_DESC).."|r"
                    else
                        name='|cff0070dd'..name..'|r'
                        sub= sub.."-|cff0070dd"..(e.onlyChinese and '精良' or ITEM_QUALITY3_DESC).."|r"
                    end
                    btn.artifactName:SetText(name)
                    btn.artifactSubText:SetText(sub..' |cnGREEN_FONT_COLOR:'..completionCount..'|r')
                end
            end
        end
    end)

    --增加一个按钮， 提示物品
    e.LoadDate({id=87399, type='item'})
    hooksecurefunc('ArchaeologyFrame_CurrentArtifactUpdate', function()
        local itemID= select(3, GetArchaeologyRaceInfo(ArchaeologyFrame.artifactPage.raceID))
        local btn= ArchaeologyFrame.artifactPage.tipsButton
        if itemID then
            if not btn then
                btn= e.Cbtn(ArchaeologyFrame.artifactPage, {button='ItemButton', icon='hide'})
                btn:SetPoint('RIGHT', ArchaeologyFrameArtifactPageSolveFrameStatusBar, 'LEFT', -39, 0)
                btn:SetScript('OnLeave', function() e.tips:Hide() end)
                btn:SetScript('OnEnter', function(frame)
                    e.tips:SetOwner(frame, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    if frame.itemID then
                        e.tips:SetItemByID(frame.itemID)
                    end
                    e.tips:AddLine(id, e.cn(addName))
                    e.tips:Show()
                end)

                btn.btn2= e.Cbtn(ArchaeologyFrame.artifactPage, {button='ItemButton', icon='hide'})
                btn.btn2:SetPoint('BOTTOM', btn, 'TOP', 0, 7)
                btn.btn2:SetScript('OnLeave', function() e.tips:Hide() end)
                btn.btn2:SetScript('OnEnter', function(frame)
                    e.tips:SetOwner(frame, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetItemByID(87399)
                    e.tips:AddLine(id, e.cn(addName))
                    e.tips:Show()
                end)

                function btn:set_Event()
                    if self:IsShown() then
                        self:RegisterEvent('BAG_UPDATE_DELAYED')
                    else
                        self:UnregisterAllEvents()
                        self:Reset()
                    end
                end
                btn:SetScript("OnShow", btn.set_Event)
                btn:SetScript("OnHide", btn.set_Event)
                function btn:set_Item()
                    local num
                    if self.itemID then
                        self:SetItem(self.itemID)
                        num= C_Item.GetItemCount(self.itemID, true, false, true)
                        self:SetItemButtonCount(num)
                        self:SetAlpha(num==0 and 0.3 or 1)
                    end
                    self.btn2:SetItem(87399)
                    num= C_Item.GetItemCount(87399, true, false, true)
                    self.btn2:SetItemButtonCount(num)
                    self.btn2:SetAlpha(num==0 and 0.3 or 1)
                end
                btn:SetScript('OnEvent', btn.set_Item)
                ArchaeologyFrame.artifactPage.tipsButton= btn
            end
            btn.itemID= itemID
            btn:set_Item()
            btn:set_Event()
        end
        if btn then
            btn:SetShown((itemID and ArchaeologyFrame:IsVisible()) and true or false)
        end
    end)

    ArchaeologyFrameInfoButton:SetFrameStrata('DIALOG')
end











--专业书
local function Init_ProfessionsBook()
    --########################
    --自动输入，忘却，文字，专业
    --########################
    local btn2= e.Cbtn(ProfessionsBookFrame, {size={22,22}, icon='hide'})
    btn2:SetPoint('TOP', ProfessionsBookFramePortrait, 'BOTTOM')
    function btn2:set_alpha()
        self:SetAlpha(Save.wangquePrefessionText and 1 or 0.3)
        self:SetNormalAtlas(not Save.wangquePrefessionText and e.Icon.icon or e.Icon.disabled)
    end
    function btn2:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((e.onlyChinese and '自动输入 ‘忘却’' or (TRADE_SKILLS ..': '..UNLEARN_SKILL_CONFIRMATION))..e.GetEnabeleDisable(Save.wangquePrefessionText), (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '你确定要忘却%s并遗忘所有已经学会的配方？如果你选择回到此专业，你的专精知识将依然存在。|n|n在框内输入 \"忘却\" 以确认。' or UNLEARN_SKILL, nil,nil,nil, true)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        self:SetAlpha(1)
    end
    btn2:SetScript("OnDoubleClick", function(self)
        Save.wangquePrefessionText= not Save.wangquePrefessionText and true or nil
        self:set_alpha()
        self:set_tooltips()
    end)
    btn2:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha()end)
    btn2:SetScript('OnEnter', btn2.set_tooltips)
    btn2:set_alpha()

    hooksecurefunc(StaticPopupDialogs["UNLEARN_SKILL"], "OnShow",function(self)
        if Save.wangquePrefessionText then
            self.editBox:SetText(UNLEARN_SKILL_CONFIRMATION);
        end
    end)
end










local function Init()



    ArcheologyDigsiteProgressBar:HookScript('OnShow', function(frame)
        if not frame.tipsButton then
            frame.tipsButton= e.Cbtn(frame, {size={20,20}, icon='hide'})
            frame.tipsButton:SetPoint('RIGHT', frame, 'LEFT', 0, -4)
            function frame.tipsButton:set_atlas()
                self:SetNormalAtlas(Save.ArcheologySound and 'chatframe-button-icon-voicechat' or 'chatframe-button-icon-speaker-off')
            end
            function frame.tipsButton:set_tooltips()
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '声音提示' or  SOUND, e.GetEnabeleDisable(Save.ArcheologySound))
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
            end
            frame.tipsButton:SetAlpha(0.3)
            frame.tipsButton:SetScript('OnLeave', function(self) GameTooltip_Hide() self:SetAlpha(0.3) end)
            frame.tipsButton:SetScript('OnEnter', function(self)
                self:set_tooltips()
                self:SetAlpha(1)
            end)

            function frame.tipsButton:play_sound()
                e.PlaySound()
                e.Set_HelpTips({frame=ArcheologyDigsiteProgressBar, point='left', topoint=self, size={40,40}, color={r=1,g=0,b=0,a=1}, show=true, hideTime=3, y=0})--设置，提示
            end

            frame.tipsButton:SetScript('OnClick', function(self)
                Save.ArcheologySound= not Save.ArcheologySound and true or nil
                self:set_atlas()
                self:set_event()
                self:set_tooltips()
                if Save.ArcheologySound then
                    self:play_sound()
                end
            end)

            function frame.tipsButton:set_event()
                print(self:IsVisible() , Save.ArcheologySound)
                if self:IsVisible() and Save.ArcheologySound then
                    self:RegisterUnitEvent('UNIT_AURA', 'player')
                else
                    self:UnregisterAllEvents()
                end
            end
            frame.tipsButton:SetScript('OnEvent', function(self, _, _, tab)
                if tab and tab.addedAuras then
                    for _, info in pairs(tab.addedAuras) do
                        if info.spellId==210837 then
                            self:play_sound()
                            break
                        end
                    end
                end
            end)
            frame.tipsButton:SetScript('OnShow', frame.tipsButton.set_event)
            frame.tipsButton:SetScript('OnHide', frame.tipsButton.set_event)

            frame.tipsButton:set_event()
            frame.tipsButton:set_atlas()

            ArcheologyDigsiteProgressBar:HookScript('OnHide', function(self)
                self.tipsButton:set_event()
            end)
        end

        if ArcheologyButton and not ArcheologyButton.keyButton then
            ArcheologyButton.keyButton= e.Cbtn(frame, {size={20,20}, icon='hide'})
            ArcheologyButton.keyButton:SetPoint('LEFT', frame, 'RIGHT', 0, -4)
            ArcheologyButton.keyButton.text=e.Cstr(ArcheologyButton.keyButton, {color={r=0, g=1, b=0}, size=14})
            ArcheologyButton.keyButton.text:SetPoint('CENTER')

            ArcheologyButton.keyButton:SetScript('OnLeave', GameTooltip_Hide)
            ArcheologyButton.keyButton:SetScript('OnEnter', ArcheologyButton.set_tooltip)

            ArcheologyButton.keyButton:SetScript('OnMouseWheel', function(_, d)
                if not UnitAffectingCombat('player') then
                    ArcheologyButton:set_OnMouseWheel(d)
                end
            end)

            ArcheologyButton.keyButton.index=3
            ArcheologyButton.keyButton.spellID= ArcheologyButton.spellID
            ArcheologyButton.keyButton.index= ArcheologyButton.index

            function ArcheologyButton.keyButton:set_text()
                local text= ArcheologyButton.text:GetText() or ''
                self.text:SetText(text)
                if text=='' then
                    self:SetNormalAtlas('newplayertutorial-icon-key')
                else
                    self:SetNormalTexture(134435)
                end
                self:SetAlpha(text=='' and 0.3 or 1)
            end

            ArcheologyButton.keyButton:set_text()
        end

    end)
end

















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save

            --[[if not e.toolsFrame.disabled or e.Is_Timerunning then
                --ProfessionsFrame_LoadUI()
                --ProfessionsCustomerOrders_LoadUI()
                -C_Timer.After(2.2, function()
                    if UnitAffectingCombat('player') then
                        self.combat= true
                        self:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        Init_Tools_Button()
                    end
                end)
            end]]

            if not Save.disabled then
                Init()
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1== 'Blizzard_TrainerUI' then
            set_Blizzard_TrainerU()--添一个,全学,专业, 按钮

        elseif arg1== 'Blizzard_Professions' then --10.1.5
            Init_ProfessionsFrame()--初始
        elseif arg1=='Blizzard_ArchaeologyUI' then
            Init_Archaeology()
        elseif arg1=='Blizzard_ProfessionsBook' then--专业书
            Init_ProfessionsBook()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if self.combat then
            self.combat=nil
            Init_Tools_Button()--初始
        end
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)