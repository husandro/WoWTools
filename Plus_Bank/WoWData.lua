local function Save()
    return WoWToolsSave['Plus_Bank2'] or {}
end


--[itemID]={num=数量,quality=品质}}
local function Save_Items(self)
    local guid= WoWTools_DataMixin.Player.GUID

    WoWTools_WoWDate[guid].Bank={}
    for _, tabData in ipairs(self.purchasedBankTabData or {}) do
        if tabData.ID and tabData.ID~=-1 then
            local numSlot= C_Container.GetContainerNumSlots(tabData.ID)
            for slotID=1, numSlot do
                local data= C_Container.GetContainerItemInfo(tabData.ID, slotID)
                if data and data.itemID then

                    local stackCount= data.stackCount or 1
                    local quality= data.quality or 1

                    if not WoWTools_WoWDate[guid].Bank[data.itemID] then
                        WoWTools_WoWDate[guid].Bank[data.itemID]= {
                            quality= quality,
                            num= stackCount
                        }

                    else
                        WoWTools_WoWDate[guid].Bank[data.itemID]={
                            quality= quality,
                            num= WoWTools_WoWDate[guid].Bank[data.itemID].num+ stackCount
                        }
                    end
                end
            end
        end
    end
end











local function Init()
    local wow= WoWTools_ItemMixin:Create_WoWButton(BankFrameCloseButton, {
        name='WoWToolsPlusBankWoWButton',
        tooltip=function(tooltip)
            tooltip:AddLine(
                '|A:BonusLoot-Chest:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '保存物品' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, ITEMS))
                ..WoWTools_DataMixin.Icon.right
                ..WoWTools_TextMixin:GetEnabeleDisable(Save().saveWoWData)
            )
        end,
        click=function(self, d, click)
            if d=='LeftButton' then
                click()
            else
                MenuUtil.CreateContextMenu(self, function(_, root)
                    local sub=root:CreateCheckbox(
                        '|A:BonusLoot-Chest:0:0|a'
                        ..(WoWTools_DataMixin.onlyChinese and '保存物品' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, ITEMS)),
                    function()
                        return Save().saveWoWData
                    end, function()
                        self:set_click()
                    end)
                    sub:SetTooltip(function(tooltip)
                        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '记录' or GUILD_BANK_LOG)
                    end)

                    root:CreateSpacer()

                    WoWTools_ItemMixin:OpenWoWItemListMenu(self, root, 'Bank')
                end)
            end
        end,
        type='Bank',
    })
    wow:SetPoint('RIGHT', BankFrameCloseButton, 'LEFT', -25,0)
    wow:GetNormalTexture():SetVertexColor(1,1,1)
    function wow:settings()
        local saveWoWData= Save().saveWoWData
        local icon= self:GetNormalTexture()
        icon:SetDesaturated(not saveWoWData)
        icon:SetAlpha(saveWoWData and 1 or 0.3)
    end
    function wow:set_click()
        Save().saveWoWData= not Save().saveWoWData and true or nil
        self:settings()
        BankPanel:Clean()
    end
    wow:settings()










    BankPanel:HookScript('OnShow', function(self)
        if Save().saveWoWData and C_Bank.AreAnyBankTypesViewable() then
            for _ in ipairs(WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank) do
                return
            end
            Save_Items(self)
        end
    end)

    hooksecurefunc(BankPanel, 'Clean', function(self)
        if self.bankType~=Enum.BankType.Character or not C_Bank.AreAnyBankTypesViewable() then
            return
        end

        if Save().saveWoWData then
            Save_Items(self)
        else
            WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank={}
        end
    end)


    Init=function()end
end










EventRegistry:RegisterFrameEventAndCallback("BANKFRAME_OPENED", function(owner)
    Init()
    EventRegistry:UnregisterCallback('BANKFRAME_OPENED', owner)
end)

