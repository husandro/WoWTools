local id, e = ...
local Save={}
local addName= SOCKET_GEMS

local Buttons={}
local Frame
local SpellsTab={
    433397,--取出宝石
    --405805,--拔出始源之石
}

--[[local ActionTab={
    [405805]=true,--405805/拔出始源之石
}]]

for _, spellID in pairs(SpellsTab) do
    e.LoadDate({id=spellID, type='spell'})
end

local AUCTION_CATEGORY_GEMS= AUCTION_CATEGORY_GEMS
local CurTypeGemTab={}--当前，宝石，类型

local function Get_Item_Color(itemLink)
    local r,g,b
    if itemLink then
        local itemQuality= select(3, C_Item.GetItemInfo(itemLink))
        if itemQuality then
            r,g,b = C_Item.GetItemQualityColor(itemQuality)
        end
    end
    return r or 1, g or 1, b or 1
end



--[[local GEM_TYPE_INFO =	{
    Yellow = EMPTY_SOCKET_YELLOW,--黄色插槽',
    Red = EMPTY_SOCKET_RED,--红色插槽',
    Blue = EMPTY_SOCKET_BLUE,--蓝色插槽',
    Hydraulic = EMPTY_SOCKET_HYDRAULIC,--染煞',
    Cogwheel = EMPTY_SOCKET_COGWHEEL,--齿轮插槽',
    Meta = EMPTY_SOCKET_META,--多彩插槽',
    Prismatic =EMPTY_SOCKET_PRISMATIC,--棱彩插槽',
    PunchcardRed = EMPTY_SOCKET_PUNCHCARDRED,--红色打孔卡插槽',
    PunchcardYellow = EMPTY_SOCKET_PUNCHCARDYELLOW,--黄色打孔卡插槽',
    PunchcardBlue = EMPTY_SOCKET_PUNCHCARDBLUE,--蓝色打孔卡插槽',
    Domination = EMPTY_SOCKET_DOMINATION,--统御插槽',
    Cypher = EMPTY_SOCKET_CYPHER,--晶态插槽',
    Tinker = EMPTY_SOCKET_TINKER,--匠械插槽',
    Primordial = EMPTY_SOCKET_PRIMORDIAL,--始源镶孔',
}--EMPTY_SOCKET_NO_COLOR,--棱彩插槽]]


local function creatd_button(index)
    local btn= e.Cbtn(Frame, {button='ItemButton', icon='hide'})
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            C_Container.PickupContainerItem(self.bagID, self.slotID)
        elseif d=='RightButton' then
            ClearCursor()
        end
    end)

    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(ItemSocketingFrame, 'ANCHOR_BOTTOMRIGHT')
        e.tips:ClearLines()
        e.tips:SetBagItem(self.bagID, self.slotID)
        e.tips:Show()
        e.FindBagItem(true, {bag={bag=self.bagID, slot=self.slotID}})

    end)
    btn:SetScript('OnLeave', function()
        GameTooltip_Hide()
        e.FindBagItem()
    end)

    btn.level=e.Cstr(btn)
    btn.level:SetPoint('TOPRIGHT')
    btn.type= e.Cstr(btn)
    btn.type:SetPoint('LEFT', btn, 'RIGHT')
    Buttons[index]= btn
    return btn
end


local function set_Gem()--Blizzard_ItemSocketingUI.lua MAX_NUM_SOCKETS
    local items={}
   
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info
                and info.hyperlink
                and info.itemID
                and info.quality
                --[[and (
                        (gem1007 and info.itemID>=204000 and info.itemID<=204030)
                    or (not gem1007 and (info.itemID<204000 or info.itemID>204030))
                )]]
            then
                local level= GetDetailedItemLevelInfo(info.hyperlink) or 0
                local classID, subclassID, _, expacID= select(12, C_Item.GetItemInfo(info.hyperlink))

                if classID==3
                    and (e.Is_Timerunning or (e.Player.levelMax and e.ExpansionLevel== expacID or not e.Player.levelMax))--最高等级
                then
                    local type
                    if e.Is_Timerunning then
                        local date= e.GetTooltipData({hyperLink=info.hyperlink, index=2})
                        type= date.indexText and date.indexText:match('|c........(.-)|r') or date.indexText
                    else
                        type=e.cn(C_Item.GetItemSubClassInfo(classID, subclassID))
                    end
                    type=type or ' '
                    items[type]= items[type] or {}
                    table.insert(items[type], {
                        info= info,
                        bag=bag,
                        slot=slot,
                        level= level or 0,
                        expacID= expacID or 0,
                    })
                end
            end
        end
    end



    for _, tab in pairs(items) do
        table.sort(tab, function(a, b)
            if a.expacID> b.expacID then
                return true
            elseif a.info.quality== b.info.quality then
                return a.level>b.level
            else
                return a.info.quality>b.info.quality
            end
        end)
    end



    local x, y, index= 0, 0, 1

    for type, tab in pairs(items) do
        for i, info in pairs(tab) do
            local btn= Buttons[index] or creatd_button(index)
            btn:ClearAllPoints()
            btn:SetPoint('TOPRIGHT', x, y)
            if i==1 then
                local findGem
                local gemName= type:gsub(AUCTION_CATEGORY_GEMS, '')
                for name in pairs(CurTypeGemTab or {}) do
                    if name:find(gemName) then
                        type= format('|cnGREEN_FONT_COLOR:%s|r', type or '')
                        findGem=true
                        break
                    end
                end
                btn.type:SetText(type or '')
                btn.type:SetScale(findGem and 1.35 or 1)
            else
                btn.type:SetText('')
            end
            local itemLink= info.info.hyperlink
            btn.level:SetText(info.level>1 and info.level or '')
            btn.level:SetTextColor(Get_Item_Color(itemLink))
            btn:SetItem(itemLink)
            btn.bagID= info.bag
            btn.slotID= info.slot
            btn:SetItemButtonCount(info.info.stackCount)
            btn:SetAlpha(info.info.isLocked and 0.3 or 1)
            btn:SetShown(true)
            e.Get_Gem_Stats(btn, itemLink)
            x=x-40--34
            index= index+1
        end
        x=0
        y=y-40--34
    end


    for i= index+1, #Buttons, 1 do
        Buttons[i]:SetShown(false)
        Buttons[i]:Reset()
        Buttons[i].type:SetText('')
        Buttons[i].level:SetText('')
    end
end




















--433397/取出宝石
local SpellButton
local function Init_Spell_Button()
    if UnitAffectingCombat('player') or SpellButton then
        if SpellButton then SpellButton:set() end
        return
    end

    SpellButton= e.Cbtn(Frame, {size={32,32}, icon='hide', type=true})
    SpellButton:Hide()
    SpellButton:SetPoint('BOTTOMRIGHT', -14, 46)
    SpellButton.texture= SpellButton:CreateTexture(nil, 'OVERLAY')
    SpellButton.texture:SetAllPoints(SpellButton)
    SpellButton.count=e.Cstr(SpellButton, {color={r=1,g=1,b=1}})--nil,nil,nil,true)
    SpellButton.count:SetPoint('BOTTOMRIGHT',-2, 9)

    function SpellButton:set_count()
        local num, max
        if self.spellID then
            num, max= GetSpellCharges(self.spellID)
        end
        self.count:SetText((max and max>1) and num or '')
        self.texture:SetDesaturated(num and num>0)
    end
    SpellButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        if self.spellID then
            e.tips:SetSpellByID(self.spellID)
        elseif self.action then
            e.tips:SetAction(self.action)
        end
        e.tips:Show()
    end)
    SpellButton:SetScript('OnLeave', GameTooltip_Hide)
    SpellButton:SetScript("OnEvent", function(self, event)
        if event=='SPELL_UPDATE_USABLE' then
            self:set_count()
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            e.SetItemSpellCool({frame=self, spell=self.spellID})
        elseif event=='ACTIONBAR_UPDATE_STATE' then
            self:set()
        end
    end)

    SpellButton:SetScript('OnShow', function(self)
        self:RegisterEvent('SPELL_UPDATE_USABLE')
        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        e.SetItemSpellCool({frame=self, spell=self.spellID})
        self:set_count()
    end)
    SpellButton:SetScript('OnHide', function(self)
        self:UnregisterEvent('SPELL_UPDATE_USABLE')
        self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
    end)



    function SpellButton:set()
        if not self:CanChangeAttribute() then
            return
        end

        local spellID, action
        for _, spell in pairs(SpellsTab) do
            if IsSpellKnownOrOverridesKnown(spell) then
                local name, _, icon = GetSpellInfo(spell)
                self:SetAttribute("type", "spell")
                self:SetAttribute("spell", name or spell)
                self:SetAttribute("action", nil)
                self.texture:SetTexture(icon or 0)
                spellID=spell
                break
            end
        end
        if not spellID and HasExtraActionBar() then
            local i = 1
            local slot = i + ((GetExtraBarIndex() or 19) - 1) * (NUM_ACTIONBAR_BUTTONS or 12)
            local actionType, spell = GetActionInfo(slot)
            if actionType== "spell" and spell then--and ActionTab[spell] then
                self:SetAttribute("type", "action")
                self:SetAttribute("action", slot)
                self:SetAttribute("spell", nil)
                self.texture:SetTexture(GetActionTexture(slot) or 0)
                action= slot
                spellID= spell
            end
        end
        if not UnitAffectingCombat('player') then
            self:SetShown((spellID or action) and true or false)
        end
        self.spellID= spellID
        self.action= action
    end

    SpellButton:set()
    ItemSocketingFrame:HookScript('OnShow', function()
        SpellButton:RegisterEvent('ACTIONBAR_UPDATE_STATE')
        SpellButton:set()
    end)
    ItemSocketingFrame:HookScript('OnHide', function()
        SpellButton:UnregisterAllEvents()
    end)
end





local function set_point()
    ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollChild:GetWidth()-18, true)--调整，宽度
    ItemSocketingDescription:SetSocketedItem()
end


local function Init()



    Frame= CreateFrame("Frame", nil, ItemSocketingFrame)
    Frame:SetPoint('BOTTOMRIGHT', 0, -10)
    Frame:SetSize(1,1)
    Frame:SetScript('OnHide', function() CurTypeGemTab={} end)

    ItemSocketingScrollFrame:SetPoint('BOTTOMRIGHT', -22, 90)    
    ItemSocketingScrollChild:ClearAllPoints()
    ItemSocketingScrollChild:SetPoint('TOPLEFT')
    ItemSocketingScrollChild:SetPoint('TOPRIGHT', -18, -254)
    ItemSocketingDescription:SetPoint('LEFT')

    ItemSocketingSocket3Left:ClearAllPoints()
    ItemSocketingSocket2Left:ClearAllPoints()
    ItemSocketingSocket1Left:ClearAllPoints()
    ItemSocketingSocket1Right:ClearAllPoints()
    ItemSocketingSocket2Right:ClearAllPoints()
    ItemSocketingSocket3Right:ClearAllPoints()
    ItemSocketingFrame['SocketFrame-Left']:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOM',0, 77)
    ItemSocketingFrame['SocketFrame-Right']:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 'BOTTOM', 0, 26)


    e.Set_Move_Frame(ItemSocketingFrame, {needSize=true, needMove=true, setSize=true, minW=338, minH=424, sizeRestFunc=function(btn)
        btn.target:SetSize(338, 424)
        set_point()
    end, sizeUpdateFunc=set_point})

    hooksecurefunc('ItemSocketingFrame_Update', function()
        local numSockets = GetNumSockets() or 0
        CurTypeGemTab={}
        for i, btn in ipairs(ItemSocketingFrame.Sockets) do--插槽，名称
            if ( i <= numSockets ) then
                local name= GetSocketTypes(i)
                name= name and _G['EMPTY_SOCKET_'..string.upper(name)]
                if name then
                    local text= EMPTY_SOCKET_BLUE:gsub(BLUE_GEM, '')
                    if text and text~='' then
                        name= name:gsub(text, '')
                    end
                    CurTypeGemTab[name]=true
                end
                if not btn.type then
                    btn.type=e.Cstr(btn)
                    btn.type:SetPoint('BOTTOM', btn, 'TOP', 0, 2)
                    btn.qualityTexture= btn:CreateTexture(nil, 'OVERLAY')
                    btn.qualityTexture:SetPoint('RIGHT', btn, 'LEFT',15,-8)
                    btn.qualityTexture:SetSize(30,30)
                    btn.levelText=e.Cstr(btn)
                    btn.levelText:SetPoint('CENTER')
                    btn.leftText=e.Cstr(btn)
                    btn.leftText:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')
                    btn.rightText=e.Cstr(btn)
                    btn.rightText:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT')
                end
                local itemLink= GetNewSocketLink(i) or GetExistingSocketLink(i)
                local left, right= e.Get_Gem_Stats(nil, itemLink)
                local atlas
                if itemLink then
                    local quality= C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemLink) or C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemLink)
                    if quality then
                        atlas = ("Professions-Icon-Quality-Tier%d-Inv"):format(quality);
                    end
                end

                btn.type:SetText(name or '')
                btn.leftText:SetText(left or '')
                btn.rightText:SetText(right or '')
                btn.levelText:SetText(itemLink and GetDetailedItemLevelInfo(itemLink) or '')
                btn.levelText:SetTextColor(Get_Item_Color(itemLink))
                if atlas then
                    btn.qualityTexture:SetAtlas(atlas)
                else
                    btn.qualityTexture:SetTexture(0)
                end
            end
        end

        if numSockets==1 then--宝石，位置
            ItemSocketingSocket1:ClearAllPoints()
            ItemSocketingSocket1:SetPoint('BOTTOM', 0, 33)
        elseif numSockets==2 then
            ItemSocketingSocket1:ClearAllPoints()
            ItemSocketingSocket1:SetPoint('BOTTOM', -60, 33)
            ItemSocketingSocket2:ClearAllPoints()
            ItemSocketingSocket2:SetPoint('BOTTOM', 60, 33)
        elseif numSockets==3 then
            ItemSocketingSocket1:ClearAllPoints()
            ItemSocketingSocket1:SetPoint('BOTTOMLEFT', 50, 33)
            ItemSocketingSocket2:ClearAllPoints()
            ItemSocketingSocket2:SetPoint('BOTTOM', 0, 33)
            ItemSocketingSocket3:ClearAllPoints()
            ItemSocketingSocket3:SetPoint('BOTTOMRIGHT', -50, 33)
        end
        set_point()
        set_Gem()
    end)



    Init_Spell_Button()
end















local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
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
                self:UnregisterEvent('ADDON_LOADED')
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

 local gem1007= select(2, GetSocketItemInfo())== 4638590 --204000, 204030

    local findGem
    local gemType={}
    for i= 1, GetNumSockets() or 0 do
        local type= GetSocketTypes(i)
        if type then
            local name= GEM_TYPE_INFO[type]
            if name then
                gemType[name]=true
            end
        end
    end



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

function PaperDollItemSocketDisplayMixin:SetItem(item)
	-- Currently only showing socket display for timerunning characters
	local showSocketDisplay = item ~= nil and PlayerGetTimerunningSeasonID() ~= nil
	self:SetShown(showSocketDisplay)

	if not showSocketDisplay then
		return
	end

	local numSockets = C_Item.GetItemNumSockets(item)
	for index, slot in ipairs(self.Slots) do
		slot:SetShown(index <= numSockets)

		-- Can get gemID without the gem being loaded in item sparse (can't use GetItemGem)
		local gemID = C_Item.GetItemGemID(item, index)
		local hasGem = gemID ~= nil

		slot.Gem:SetShown(hasGem)

		if hasGem then
			local gemItem = Item:CreateFromItemID(gemID)

			-- Prevent edge case a different gem was previously shown, but new gem not cached yet
			if not gemItem:IsItemDataCached() then
				slot.Gem:SetTexture()
			end

			-- Icon requires item sparse, need to use a callback if not loaded
			gemItem:ContinueOnItemLoad(function()
				local gemIcon = C_Item.GetItemIconByID(gemID)
				slot.Gem:SetTexture(gemIcon)
			end)
		end
	end

	self:Layout()
end]]
