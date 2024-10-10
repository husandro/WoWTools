--Blizzard_TrainerUI
local e= select(2, ...)
local function Save()
    return WoWTools_ProfessionMixin.Save
end









--添一个,全学,专业, 按钮, 插件 TrainAll 
local function Init()
    ClassTrainerFrame.BuyAll= WoWTools_ButtonMixin:Cbtn(ClassTrainerFrame, {type=false, size={ClassTrainerTrainButton:GetSize()}})
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
        e.tips:AddDoubleLine(e.addName, WoWTools_ProfessionMixin.addName)
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
                    print(e.addName, WoWTools_ProfessionMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '金币不足' or NOT_ENOUGH_GOLD), C_CurrencyInfo.GetCoinTextureString(money))
                    break
                end
            end
		end
        C_Timer.After(0.5, function()
            for i, link in pairs(tab) do
                print('|cffff00ff'..i..'|r)', link)
            end
            print(e.addName, 'Tools', WoWTools_ProfessionMixin.addName, '|cffff00ff'..num..'|r '..(e.onlyChinese and '学习' or LEARN), (cost>0 and '|cnGREEN_FONT_COLOR:' or '')..C_CurrencyInfo.GetCoinTextureString(cost))
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
        ClassTrainerFrame.BuyAll:SetShown(not Save().disabledClassTrainer)
	end)

    local btn2= WoWTools_ButtonMixin:Cbtn(ClassTrainerFrame.TitleContainer, {icon= not Save().disabledClassTrainer})
    if _G['MoveZoomInButtonPerClassTrainerFrame'] then
        btn2:SetPoint('RIGHT', _G['MoveZoomInButtonPerClassTrainerFrame'], 'LEFT')
    else
        btn2:SetPoint('LEFT', ClassTrainerFrame.TitleContainer, -5, -1)
    end
    btn2:SetSize(20,20)
    btn2:SetAlpha(0.5)
    btn2:SetScript('OnClick', function(self2)
        Save().disabledClassTrainer= not Save().disabledClassTrainer and true or nil
        ClassTrainerFrame.BuyAll:SetShown(not Save().disabledClassTrainer)
        self2:SetNormalAtlas(Save().disabledClassTrainer and e.Icon.disabled or e.Icon.icon)
    end)
    btn2:SetScript("OnEnter",function(self2)
		e.tips:SetOwner(ClassTrainerFrame.TitleContainer, "ANCHOR_TOPLEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '全部学习' or (ALL..' '.. LEARN), e.GetShowHide(not Save().disabledClassTrainer))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.addName, WoWTools_ProfessionMixin.addName)
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












function WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()
    Init()
end