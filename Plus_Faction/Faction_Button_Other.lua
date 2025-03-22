local e= select(2, ...)

local isGo
local function set_expand_collapse(show)
    if isGo then
        return
    end
    isGo=true
    for index=1, C_Reputation.GetNumFactions() do
        local data= C_Reputation.GetFactionDataByIndex(index) or {}
        if data.isHeader then
            if show then
                if data.isCollapsed then
                    C_Reputation.ExpandFactionHeader(index);
                end
            else
                if not data.isCollapsed then
                    C_Reputation.CollapseFactionHeader(index);
                end
            end
        end
    end
    isGo=nil
end




local function Init_Search(self)
	local numList= C_Reputation.GetNumFactions()
	if numList==0 then
		return
	end

	local factionID, name

	local currID=math.max(self:GetNumber() or 0)
	currID= math.min(currID, 2147483647)

	local text= self:GetText()
	local info = currID>0 and C_Reputation.GetFactionDataByID(currID)
	if info then
		if info.factionID then
			factionID= info.factionID
		else
			return
		end
	else
		text= text:gsub(' ', '')
		if text~='' then
			name=text
		else
			return
		end
	end

	--local findHeader=true
	local find, find2
	local cur1, cur2


	for index=1, numList, 1 do
		local data= C_Reputation.GetFactionDataByIndex(index) or {}

		if factionID== data.factionID or data.name==name then
			find= index
			cur1= data.factionID
			--break

		elseif name and data.name:find(name) then
			find2= index
			cur2= data.factionID
		end

		if data.isHeader and data.isCollapsed then
			C_Reputation.ExpandFactionHeader(index)
			WoWTools_CurrencyMixin:UpdateTokenFrame()
		end
	end


	find= find or find2
	cur1= cur1 or cur2


	if find and cur1 then

		ReputationFrame.ScrollBox:ScrollToElementDataIndex(find)


		for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames() or {}) do
			if frame.Content and frame.elementData then
				if frame.elementData.factionID==cur1 then
					frame.Content.BackgroundHighlight:SetAlpha(0.2)
				else
					frame.Content.BackgroundHighlight:SetAlpha(0)
				end
			end
		end

	end


end









local function Init()


	local down= WoWTools_ButtonMixin:Cbtn(WoWTools_FactionMixin.Button, {size=22, atlas='NPE_ArrowDown'})--texture='Interface\\Buttons\\UI-MinusButton-Up'})--展开所有
    WoWTools_FactionMixin.down= down
	down:SetPoint("RIGHT", ReputationFrame.filterDropdown, 'LEFT',-2,0)
	down:SetScript("OnClick", function()
		set_expand_collapse(true)
	end)
	down:SetScript("OnLeave", GameTooltip_Hide)
	down:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_Mixin.onlyChinese and '展开选项|A:editmode-down-arrow:16:11:0:-7|a' or HUD_EDIT_MODE_EXPAND_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:Show()
	end)

	local up= WoWTools_ButtonMixin:Cbtn(down, {size=22, atlas='NPE_ArrowUp'})--texture='Interface\\Buttons\\UI-PlusButton-Up'})--收起所有
	up:SetPoint("RIGHT", down, 'LEFT', -2, 0)
	up:SetScript("OnClick", function()
		set_expand_collapse(false)
	end)
	up:SetScript("OnLeave", GameTooltip_Hide)
	up:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(' ', WoWTools_Mixin.onlyChinese and '收起选项|A:editmode-up-arrow:16:11:0:3|a' or HUD_EDIT_MODE_COLLAPSE_OPTIONS)
		GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:Show()
	end)

	local edit= WoWTools_EditBoxMixin:Create(up, {name='WoWTools_PlusFactionSearchBox', instructions= WoWTools_Mixin.onlyChinese and '搜索' or SEARCH, Template='SearchBoxTemplate'})
	edit:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	edit:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')
	edit:SetAlpha(0.3)
	edit:SetScript('OnTextChanged', Init_Search)
	edit:SetScript('OnEnterPressed', Init_Search)
	edit:HookScript('OnEditFocusLost', function(self) self:SetAlpha(0.3) end)
	edit:HookScript('OnEditFocusGained', function(self) self:SetAlpha(1) end)
	edit:SetSize(180, 23)

	--edit.Instructions:SetText(WoWTools_Mixin.onlyChinese and '搜索' or SEARCH)
    WoWTools_EditBoxMixin:HookInstructions(edit)

    WoWTools_FactionMixin.Button:settings()
end






function WoWTools_FactionMixin:Init_Other_Button()
    Init()
end