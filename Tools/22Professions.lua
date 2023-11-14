local id, e = ...
local addName= PROFESSIONS_TRACKER_HEADER_PROFESSION
local Save={
    setButton=true,
    --disabledClassTrainer=true,--隐藏，全学，按钮
    --disabledEnchant=true,--禁用，自动放入，附魔纸
    --disabled--禁用，按钮
}
local panel=CreateFrame("Frame")















--##########
--TOOLS，按钮
--##########
local function Init_Tools_Button()
    local tab={GetProfessions()}--local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    for index, type in pairs(tab) do
        if type then --and index~=4 and index~=3 then
            local name, _, _, _, numAbilities, spelloffset = GetProfessionInfo(type)
            local _, _, icon, _, _, _, spellID= GetSpellInfo(spelloffset+ 1, 'spell')


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

            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spellID)
                if self.index==5 then
                    local link= GetSpellLink(818)
                    local texture= GetSpellTexture(818)
                    if link and texture then
                        local text= '|T'..texture..':0|t'.. link
                        if PlayerHasToy(134020) then--玩具,大厨的帽子
                            local link2,_,_,_,_,_,_,_, texture2 = select(2, GetItemInfo(134020))
                            if link2 and texture2 then
                                text=text..'|T'..texture2..':0|t'..link2
                            end
                        end
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(text, e.Icon.right)
                    end
                elseif self.spellID2 then
                    local link= GetSpellLink(self.spellID2)
                    local texture= GetSpellTexture(self.spellID2)
                    if link and texture then
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine('|T'..texture..':0|t'.. link, e.Icon.right)
                    end
                end

                if self.index==3 or self.index==4 then
                    e.tips:AddDoubleLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, 'F', 0,1,0, 0,1,0)
                    e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.Icon.mid..(e.onlyChinese and '滚轮向上滚动' or KEY_MOUSEWHEELUP))
                    e.tips:AddDoubleLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, e.Icon.mid..(e.onlyChinese and '轮向下滚动' or KEY_MOUSEWHEELDOWN))
                end
                e.tips:Show()
            end)
            btn:SetScript('OnLeave', function() e.tips:Hide() end)

            if index==3 or index==4 then--钓鱼，考古， 设置清除快捷键
                btn:SetScript('OnMouseWheel', function(self, d)
                    if d==1 then
                        e.SetButtonKey(self, true,'F', 'RightButton')
                        self:RegisterEvent('PLAYER_REGEN_ENABLED')
                        self:RegisterEvent('PLAYER_REGEN_DISABLED')
                        print(id, addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '设置' or SETTINGS), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF')
                        self.text:SetText('F')
                    elseif d==-1 then
                        e.SetButtonKey(self)
                        self:UnregisterEvent('PLAYER_REGEN_DISABLED')
                        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
                        self.text:SetText('')
                        print(id, addName,'|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                    end
                end)
                btn:SetScript("OnEvent", function(self, event)
                    if event=='PLAYER_REGEN_ENABLED' then
                        e.SetButtonKey(self, true,'F', 'RightButton')
                        print(id, addName,'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '设置' or SETTINGS), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, '|cffff00ffF|r')
                    elseif event=='PLAYER_REGEN_DISABLED' then
                        e.SetButtonKey(self)
                        print(id, addName,'|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), self.name, e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
                    end
                end)
                btn.text=e.Cstr(btn, {color={r=1,g=0,b=0}})--nil,nil,nil,{1,0,0})
                btn.text:SetPoint('TOPRIGHT',-4,0)
            end

            if index==5 then--烹饪用火
                local name2=IsSpellKnown(818) and GetSpellInfo(818)
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
                            e.SetItemSpellCool({frame=self, sepll=818})
                        end)
                    end
                    btn:SetAttribute('type2', 'macro')
                    btn:SetAttribute("macrotext2", text)
                end
            elseif numAbilities and numAbilities>1 then
                local _, _, icon2, _, _, _, spellID2= GetSpellInfo(spelloffset+ 2, 'spell')
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
                local name2= GetSpellInfo(818)
                if name2 then
                    local btn= e.Cbtn(button, {type= true, texture=135805 ,size={32, 32}})
                    btn:SetPoint('LEFT', button, 'RIGHT',2,0)

                    btn:SetScript('OnShow',function(self)
                        e.SetItemSpellCool({frame=self, sepll=818})
                        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                    end)
                    btn:SetScript('OnHide', function(self)
                        self:UnregisterAllEvents()
                    end)
                    btn:SetScript('OnEvent', function(self)
                        e.SetItemSpellCool({frame=self, sepll=818})
                    end)
                    btn:SetScript('OnLeave', function() e.tips:Hide() end)
                    btn:SetScript('OnEnter', function(self)
                        e.tips:SetOwner(self, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(818)
                        e.tips:AddLine(' ')
                        e.tips:AddLine(self.macrotext)
                        e.tips:Show()
                    end)

                    local text=''
                    --if PlayerHasToy(134020) then--玩具,大厨的帽子
                        local toyname=C_Item.GetItemNameByID('134020')
                        if toyname then
                            text= '/use '..toyname..'|n'
                            btn.rightTexture= btn:CreateTexture(nil, 'OVERLAY')
                            btn.rightTexture:SetPoint('TOPRIGHT')
                            btn.rightTexture:SetSize(16,16)
                            btn.rightTexture:SetTexture(236571)
                        end
                    --end
                    text=text..'/cast [@player]'..name2

                    btn:SetAttribute('type', 'macro')
                    btn:SetAttribute("macrotext", text)
                    btn.macrotext= text
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
        local text= GetCoinTextureString(self.cost)
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
        e.tips:AddDoubleLine(id, addName)
		e.tips:Show()
	end)
	ClassTrainerFrame.BuyAll:SetScript("OnLeave",function() e.tips:Hide() end)

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
                    print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '金币不足' or NOT_ENOUGH_GOLD), GetCoinTextureString(money))
                    break
                end
            end
		end
        C_Timer.After(0.5, function()
            for i, link in pairs(tab) do
                print('|cffff00ff'..i..'|r)', link)
            end
            print(id, 'Tools', addName, '|cffff00ff'..num..'|r '..(e.onlyChinese and '学习' or LEARN), (cost>0 and '|cnGREEN_FONT_COLOR:' or '')..GetCoinTextureString(cost))
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
        e.tips:AddDoubleLine(id, addName)
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
        print(id, addName, e.GetEnabeleDisable(not Save.disabled),  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    btn2:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, 'Tools')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(addName, e.GetEnabeleDisable(not Save.disabled)..e.Icon.left)
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


    Init_ProfessionsFrame_Button()--专业界面, 按钮


    --###
    --数量
    --Blizzard_Professions.lua
    hooksecurefunc(Professions,'SetupOutputIconCommon', function(outputIcon, quantityMin, quantityMax, icon, itemIDOrLink, quality)
        local num
        if itemIDOrLink and not Save.disabled then
            num= GetItemCount(itemIDOrLink, true)
            local itemID= GetItemInfoInstant(itemIDOrLink)
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
        local recipeID = elementData.data.recipeInfo.recipeID
        if recipeID then
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:SetRecipeResultItem(recipeID)
            e.tips:AddLine(' ')
            local text= C_TradeSkillUI.GetRecipeSourceText(recipeID)
            if text and text~='' then
                e.tips:AddLine(text)
                e.tips:AddLine(' ')
            end
            e.tips:AddDoubleLine('recipeID', recipeID)
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end
    end)


    --专业，列表，增加图标
    hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'Init', function(self, node)
        local elementData = node:GetData();
        local recipeInfo = Professions.GetHighestLearnedRecipe(elementData.recipeInfo) or elementData.recipeInfo

        local icon = recipeInfo and recipeInfo.icon
        if icon and not self.texture then
            self.texture= self:CreateTexture()
            self.texture:SetPoint('RIGHT')
            self.texture:SetSize(22,22)
        end

        if self.texture then
            self.texture:SetTexture(icon or 0)
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
                e.tips:AddDoubleLine(id, addName)
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
                e.tips:AddDoubleLine(id,addName)
                e.tips:Show()
            end)
            button:SetScript('OnLeave', function() e.tips:Hide() end)
            self.DetailedView.SpendAllPointsButton= button
        end
        button:SetShown(self.DetailedView.SpendPointsButton:IsShown())
        button:SetEnabled(self.DetailedView.SpendPointsButton:IsEnabled())
        button.nodeID= self:GetDetailedPanelNodeID();
        button.configID= self:GetConfigID()
    end)
end
























local function Init()
    --########################
    --自动输入，忘却，文字，专业
    --########################
    local btn2= e.Cbtn(SpellBookProfessionFrame, {size={22,22}, icon='hide'})
    btn2:SetPoint('TOP', SpellBookFramePortrait, 'BOTTOM')
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
        e.tips:AddDoubleLine(id, addName)
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

















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save

            if not e.toolsFrame.disabled then
                C_Timer.After(2.2, function()
                    if UnitAffectingCombat('player') then
                        panel.combat= true
                        panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        Init_Tools_Button()
                    end
                end)
            end

            if not Save.disabled then
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1== 'Blizzard_TrainerUI' then
            set_Blizzard_TrainerU()--添一个,全学,专业, 按钮

        elseif arg1== 'Blizzard_Professions' then --10.1.5
            Init_ProfessionsFrame()--初始
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            panel.combat=nil
            Init_Tools_Button()--初始
        end
        panel:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)