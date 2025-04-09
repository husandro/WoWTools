--提示，背包，总数













local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(MainMenuBarBackpackButton,  {size=WoWToolsSave['Plus_MainMenu'].size, color=true})
    frame.Text:SetPoint('TOP', MainMenuBarBackpackButton, 0, -6)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local money=0
        if WoWToolsSave['Plus_MainMenu'].moneyWoW then
            for _, info in pairs(WoWTools_WoWDate or {}) do
                if info.Money then
                    money= money+ info.Money
                end
            end
        else
            money= GetMoney()
        end
        if money>=10000 then
            self.Text:SetText(WoWTools_Mixin:MK(money/1e4, 0))
        else
            self.Text:SetText(GetMoneyString(money,true))
        end
    end
    frame:RegisterEvent('PLAYER_MONEY')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)


    MainMenuBarBackpackButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        GameTooltip:AddLine(' ')

        local numPlayer, allMoney= 0, 0
        local tab={}
        for guid, info in pairs(WoWTools_WoWDate or {}) do
            if info.Money and info.Money>0 then
                numPlayer=numPlayer+1
                allMoney= allMoney + info.Money
                table.insert(tab, {
                    guid=guid,
                    faction=info.faction,
                    num=info.Money,
                })
            end
        end

        if numPlayer>0 then
            table.sort(tab, function(a,b) return a.num>b.num end)

            for index, info in pairs(tab) do
                GameTooltip:AddDoubleLine(
                    WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {faction=info.faction, reName=true, reRealm=true}),
                    C_CurrencyInfo.GetCoinTextureString(info.num)
                )
                if index>4 then
                    break
                end
            end

            GameTooltip:AddDoubleLine(
                '|cnGREEN_FONT_COLOR:'..numPlayer..WoWTools_DataMixin.Icon.wow2..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER),
                --(WoWTools_DataMixin.onlyChinese and '总计' or TOTAL)
                WoWTools_DataMixin.Icon.wow2..'|cnGREEN_FONT_COLOR:'..(allMoney >=10000 and WoWTools_Mixin:MK(allMoney/10000, 3)..'|A:Coin-Gold:0:0|a' or C_CurrencyInfo.GetCoinTextureString(allMoney))
            )
        end

        local account= C_Bank.FetchDepositedMoney(Enum.BankType.Account)
        if account and account>0 and GameTooltip.textLeft then
            GameTooltip.textLeft:SetText(
                '|A:questlog-questtypeicon-account:0:0|a|cff00ccff'
                ..(
                    account >=10000 and WoWTools_Mixin:MK(account/10000, 3)..'|A:Coin-Gold:8:8|a'
                    or C_CurrencyInfo.GetCoinTextureString(account)
                )
            )
        end

--背包，数量
        local num, use= 0, 0
        tab={}
        for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i)
            local numSlots= C_Container.GetContainerNumSlots(i) or 0
            if bagFamily == 0 and numSlots>0 and freeSlots then
                num= num + numSlots
                use= use+ freeSlots
                local icon
                if i== BACKPACK_CONTAINER then
                    icon= '|A:bag-main:0:0|a'
                else
                    local inventoryID = C_Container.ContainerIDToInventoryID(i)
                    local texture = inventoryID and GetInventoryItemTexture('player', inventoryID)
                    if texture then
                        icon= '|T'..texture..':0|t'
                    end
                end
                table.insert(tab, {
                    index='|cffff00ff'..(i+1)..'|r',
                    icon=icon,
                    num=numSlots,
                    freeSlots= freeSlots,
                    percent= format('%i%%', freeSlots/numSlots*100)
                })
                    --num= freeSlots>0 and '|cnGREEN_FONT_COLOR:'..num..'|r' or '|cnRED_FONT_COLOR:'..num..'|r'})
            end
        end

        GameTooltip:AddLine(' ')
        for i=1, #tab, 2 do
            local a= tab[i]
            local b= tab[i+1]
            GameTooltip:AddDoubleLine(
                a.index..') '..a.num..a.icon..a.freeSlots..' '..a.percent,
                b and (a.percent..' '..b.freeSlots..b.icon..b.num..' ('..b.index)
            )
        end

        if GameTooltip.textRight then
            GameTooltip.textRight:SetText(
                '|A:bags-button-autosort-up:18:18|a'
                ..(use>0 and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')
                ..use..'|r/'..num
                ..' '..format('%i%%', use/num*100)
            )
        end
        GameTooltip:Show()
    end)


    MainMenuBarBackpackButtonCount:SetShadowOffset(1, -1)
    WoWTools_ColorMixin:Setup(MainMenuBarBackpackButtonCount, {type='FontString'})--设置颜色

    hooksecurefunc(MainMenuBarBackpackButton, 'UpdateFreeSlots', function(self)
        local freeSlots=self.freeSlots
        if freeSlots then
            if freeSlots==0 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(1,0,0,1)
                freeSlots= '|cnRED_FONT_COLOR:'..freeSlots..'|r'
            elseif freeSlots<=5 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,1,0,1)
                freeSlots= '|cnGREEN_FONT_COLOR:'..freeSlots..'|r'
            else
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,0,0,0)
            end
            self.Count:SetText(freeSlots)
        else
            MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,0,0,0)
        end
    end)

    --收起，背包小按钮
    if C_CVar.GetCVarBool("expandBagBar") and C_CVar.GetCVarBool("combinedBags") then--MainMenuBarBagButtons.lua
        C_CVar.SetCVar("expandBagBar", '0')
    end

    --if not MainMenuBarBackpackButton.OnClick then
    MainMenuBarBackpackButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            ToggleAllBags()
        end
    end)

    Init=function()end
end













function WoWTools_MainMenuMixin:Init_Bag()--背包
    Init()
end