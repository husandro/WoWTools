local id, e = ...
local Save={}
local addName= SOCKET_GEMS


local Buttons={}
local Frame


local SpellsTab={
    433397,--/取出宝石
}

for _, spellID in pairs(SpellsTab) do
    e.LoadDate({id=spellID, type='spell'})
end




local function set_Gem()--Blizzard_ItemSocketingUI.lua MAX_NUM_SOCKETS
    if not ItemSocketingFrame or not ItemSocketingFrame:IsVisible() then
        return
    end

    local items={}
    local gem1007= select(2, GetSocketItemInfo())== 4638590 --204000, 204030

      for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info
                and info.hyperlink
                and info.itemID
                and info.quality
                and (
                        (gem1007 and info.itemID>=204000 and info.itemID<=204030)
                    or (not gem1007 and (info.itemID<204000 or info.itemID>204030))
                )
            then
                local level= GetDetailedItemLevelInfo(info.hyperlink) or 0
                local classID, _, _, expacID= select(12, C_Item.GetItemInfo(info.hyperlink))

                if classID==3
                    and (e.Player.levelMax and e.ExpansionLevel== expacID or not e.Player.levelMax)--最高等级
                then
                    table.insert(items, {
                        info= info,
                        bag= bag,
                        slot=slot,
                        level= level,
                    })
                end
            end
        end
    end


    table.sort(items, function(a, b)
        if a.info.quality== b.info.quality then
           return a.level>b.level
        else
           return a.info.quality>b.info.quality
        end
    end)
    local x, y= 10, -4
    for index=1, #items do
        local btn=Buttons[index]
        if select(2, math.modf(index /10))==0 then
            x=10
            y=y -40
        elseif index>1 then
            x= x -40
        end
        if not btn then
            btn= e.Cbtn(ItemSocketingFrame, {button='ItemButton', icon='hide'})
            btn:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT', x, y)
            btn:SetScript('OnClick', function(self, d)
                if self.bag and self.slot then
                    if d=='LeftButton' then
                        C_Container.PickupContainerItem(self.bag, self.slot)
                    elseif d=='RightButton' then
                        ClearCursor()
                    end
                end
            end)
            btn:SetScript('OnEnter', function(self)
                if self.bag and self.slot then
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetBagItem(self.bag, self.slot)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, e.cn(addName))
                    e.tips:Show()
                    e.FindBagItem(true, {bag=self.bag, slot=self.slot})
                end
            end)
            btn:SetScript('OnLeave', function()
                GameTooltip_Hide()
                e.FindBagItem()
            end)

            btn.level=e.Cstr(btn)
            btn.level:SetPoint('TOPRIGHT')

            table.insert(Buttons, btn)
        end

        local info= items[index].info
        btn.level:SetText(items[index].level>1 and items[index].level or '')

        btn.bag= items[index].bag
        btn.slot= items[index].slot

        btn:SetItem(info.hyperlink)
        btn:SetItemButtonCount(C_Item.GetItemCount(info.hyperlink))
        btn:SetAlpha(info.isLocked and 0.3 or 1)
        btn:SetShown(true)

        e.Get_Gem_Stats({bag={bag=items[index].bag, slot=items[index].slot}}, nil, btn)
    end

    for index= #items+1, #Buttons, 1 do
        Buttons[index]:SetShown(false)
        Buttons[index]:Reset()
    end
end





























--433397/取出宝石
local function Init_Spell_Button()
    if UnitAffectingCombat('player') then
        return
    end

    local spellID
    for _, spell in pairs(SpellsTab) do
        if IsSpellKnownOrOverridesKnown(spell) then
            spellID=spell
            break
        end
    end

    local btn = ItemSocketingFrame.SpellButton
    if not btn and spellID then
        btn= e.Cbtn(ItemSocketingFrame, {size={32,32}, icon='hide', type=true})
        btn:SetAttribute("type1", "spell")
        btn:Hide()
        btn:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 'BOTTOMRIGHT', 2, 35)
        btn.texture= btn:CreateTexture(nil, 'OVERLAY')
        btn.texture:SetAllPoints(btn)
        btn.count=e.Cstr(btn, {color={r=1,g=1,b=1}})--nil,nil,nil,true)
        btn.count:SetPoint('BOTTOMRIGHT',-2, 9)

        function btn:set_count()
            local num, max= GetSpellCharges(self.spellID)
            self.count:SetText((max and max>1) and num or '')
            self.texture:SetDesaturated(num and num>0)
        end
        btn:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:SetSpellByID(self.spellID)
            e.tips:Show()
        end)
        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript("OnEvent", function(self, event)
            if event=='SPELL_UPDATE_USABLE' then
                self:set_count()
            elseif event=='SPELL_UPDATE_COOLDOWN' then
                e.SetItemSpellCool({frame=self, spell=self.spellID})
            end
        end)

        btn:SetScript('OnShow', function(self)
            self:RegisterEvent('SPELL_UPDATE_USABLE')
            self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
            e.SetItemSpellCool({frame=self, spell=self.spellID})
            self:set_count()
        end)
        btn:SetScript('OnHide', btn.UnregisterAllEvents)

        function btn:set()
           local show = self.spellID and IsSpellKnownOrOverridesKnown(self.spellID) and self:CanChangeAttribute()
           if show then
                local name, _, icon = GetSpellInfo(self.spellID)
                self:SetAttribute("spell1", name or spellID)
                self.texture:SetTexture(icon or nil)
            end
            if not UnitAffectingCombat('player') then
                self:SetShown(show)
            end
        end
    end
    if btn then
        btn.spellID= spellID
        btn:set()
    end
end



local function Init()
    Frame= CreateFrame("Frame")
    ItemSocketingFrame:HookScript('OnShow', function()
        local tab={
            'BAG_UPDATE_DELAYED',
            'BAG_UPDATE',
            'ITEM_UNLOCKED',
            'ITEM_LOCKED',
            'SOCKET_INFO_UPDATE',
        }
        FrameUtil.RegisterFrameForEvents(Frame, tab)
        set_Gem()
    end)
    ItemSocketingFrame:HookScript('OnHide', function()
        Frame:UnregisterAllEvents()
        for index= 1, #Buttons do
            Buttons[index]:Reset()
        end
    end)
    Frame:SetScript('OnEvent', set_Gem)

    Init_Spell_Button()
    ItemSocketingFrame:HookScript('OnShow', Init_Spell_Button)
end















local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= '|T4555592:0|t'..(e.onlyChinese and '镶嵌宝石' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })
            if Save.disabled then
                panel:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_ItemSocketingUI' then
            Init()
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)

















--[[
    panel:RegisterEvent('SOCKET_INFO_CLOSE')
panel:RegisterEvent('SOCKET_INFO_UPDATE')
panel:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
    local ExtraActionButton1Point--记录打开10.07 宝石戒指, 额外技能条,位置
elseif arg1=='Blizzard_ItemSocketingUI' then--10.07 原石宝石，提示
ItemSocketingFrame.setTipsFrame= CreateFrame("Frame", nil, ItemSocketingFrame)
ItemSocketingFrame.setTipsFrame:SetFrameStrata('HIGH')

local x,y,n= 54,-22,0
for i=204000, 204030 do
    local classID= select(6, C_Item.GetItemInfoInstant(i))
    if classID==3 then
        e.LoadDate({id=i, type='item'})
        local icon= C_Item.GetItemIconByID(i)
        if icon then
            local texture= ItemSocketingFrame.setTipsFrame:CreateTexture()
            texture:SetSize(20,20)
            texture:SetTexture(icon)
            texture:EnableMouse(true)
            texture.id= i
            texture:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetItemByID(self2.id)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
            end)
            texture:SetScript('OnLeave', GameTooltip_Hide)
            n=n+1

            texture:SetPoint('TOPLEFT', ItemSocketingFrame, 'TOPLEFT',x, y)
            local one,two= math.modf(n / 14)
            if two==0 and one==1 then
                x=-2
                y=y -20
            else
                x=x+20
            end
        end
    end
end
ItemSocketingFrame.setTipsFrame:SetShown(select(2,GetSocketItemInfo())== 4638590)--10.07 原石宝石，提示

 elseif event=='SOCKET_INFO_UPDATE' then
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
        set_Gem()

        local gem1007= select(2, GetSocketItemInfo())== 4638590
        if ItemSocketingFrame.setTipsFrame then
            ItemSocketingFrame.setTipsFrame:SetShown(gem1007)--10.07 原石宝石，提示
        end

        if not IsInInstance() and gem1007 and ExtraActionButton1 and ExtraActionButton1:IsShown() and ExtraActionButton1.icon and ItemSocketingFrame and ItemSocketingFrame:IsVisible() then
            local icon= ExtraActionButton1.icon:GetTexture()
            if icon==4638590 or icon==876370 then
                if not ExtraActionButton1Point then
                    ExtraActionButton1Point= {ExtraActionButton1:GetPoint(1)}--记录打开10.07 宝石戒指, 额外技能条,位置
                    ExtraActionButton1:ClearAllPoints()
                    ExtraActionButton1:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 'BOTTOMRIGHT', 0, 30)
                end
            end
        end

    elseif event=='SOCKET_INFO_CLOSE' then
        panel:UnregisterEvent('BAG_UPDATE_DELAYED')
        if ItemSocketingFrame and ItemSocketingFrame.setTipsFrame then
            ItemSocketingFrame.setTipsFrame:SetShown(false)--10.07 原石宝石，提示
        end
        if ExtraActionButton1Point then--记录打开10.07 宝石戒指, 额外技能条,位置
            ExtraActionButton1:ClearAllPoints()
            ExtraActionButton1:SetPoint(ExtraActionButton1Point[1], ExtraActionButton1Point[2], ExtraActionButton1Point[3], ExtraActionButton1Point[4], ExtraActionButton1Point[5])
            ExtraActionButton1Point=nil
        end
]]