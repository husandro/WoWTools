local function Save()
    return WoWToolsSave['Plus_GuildBank']
end


local MAX_GUILDBANK_SLOTS_PER_TAB = 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14






local function Init_Button()
--按钮，边框
    local plusIndex= Save().plusIndex

    for slotID=1, MAX_GUILDBANK_SLOTS_PER_TAB do
        local btnIndex = mod(slotID, NUM_SLOTS_PER_GUILDBANK_GROUP)
        if btnIndex == 0 then
            btnIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
        end
        local column = ceil((slotID-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP)
        local btn= GuildBankFrame.Columns[column].Buttons[btnIndex]
        if btn then
            if not btn.indexText then
--索引
                WoWTools_TextureMixin:SetAlphaColor(btn.NormalTexture, nil, true, 0.2)
                btn.indexText= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1, a=0.3}})
                btn.indexText:SetPoint('CENTER')
--物品信息
                hooksecurefunc(btn, 'SetMatchesSearch', function(self)
                    WoWTools_ItemMixin:SetupInfo(self, {
                        guidBank= Save().plusItem and {tab=GetCurrentGuildBankTab(), slot=self:GetID()} or nil
                    })
                end)
            end
            btn.indexText:SetText(plusIndex and slotID or '')
        end
    end
end














local TabData={}--系统只记录当前tabID数据

local function UpdateTabs(self)
    local currentIndex= GetCurrentGuildBankTab()--当前 Tab
    local plusTab= Save().plusTab

    for tabID= 1, GetNumGuildBankTabs(), 1 do

        local btn= self.BankTabs[tabID].Button

        if not btn.Name then
            btn.Name= WoWTools_LabelMixin:Create(btn, {color=true})
            btn.Name:SetPoint('BOTTOM', 0, -6)

            btn.FlagsText= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}})
            btn.FlagsText:SetPoint('LEFT', btn, 'RIGHT')
        end

        local name, _, isViewable, canDeposit, numWithdrawals, remainingWithdrawals= GetGuildBankTabInfo(tabID)

        if isViewable and plusTab then
            local isCurrent= currentIndex==tabID
            local accessIcon, access= WoWTools_GuildBankMixin:Get_Access()
            local remaining--%s的每日提取额度剩余

            if isCurrent then
                if remainingWithdrawals==0 then
                    remaining= '|cff6262620'
                elseif remainingWithdrawals>0 then
                    remaining= remainingWithdrawals
                else
                    remaining= '|A:Adventures-Infinite:0:0|a'--∞
                end
                TabData[tabID]=remaining
            else
                remaining= TabData[tabID]
            end

            btn.Name:SetText(not isCurrent and WoWTools_TextMixin:sub(name, 3, 6) or '')

            btn.FlagsText:SetText(
                (accessIcon or '')..(remaining or '')
            )
            btn.tooltip= name
                ..'|n'..(accessIcon or '')..access
                ..(remaining and
                    '|n|cnGREEN_FONT_COLOR:'
                    ..(WoWTools_DataMixin.onlyChinese and '提取数量：' or GUILDBANK_WITHDRAW)
                    ..remaining
                    or ''
                )
        else
            btn.Name:SetText('')
            btn.FlagsText:SetText('')
        end
    end
end











local function Init()
    Init_Button()


    hooksecurefunc(GuildBankFrame, 'UpdateTabs', function(self)
        UpdateTabs(self)
    end)


    Init=function()
        Init_Button()
    end
end


function WoWTools_GuildBankMixin:Init_Plus()
    Init()
end
