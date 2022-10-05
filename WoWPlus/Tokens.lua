local id, e = ...
local addName=TOKENS
local Save={updateTips=true, disabled=true}
local Frame=TokenFrame
local sel=CreateFrame("Button",nil, Frame, 'UIPanelButtonTemplate')--禁用,开启

local Icon={
	up="Interface\\Buttons\\UI-PlusButton-Up",
	down="Interface\\Buttons\\UI-MinusButton-Up",
}

local function strSetText()
	if not Save.str or not sel.btn then
		if sel.btn then
			sel.btn.str:SetText('')
		end
		return
	end
	local m=''
    for i=1, C_CurrencyInfo.GetCurrencyListSize() do
        local info = C_CurrencyInfo.GetCurrencyListInfo(i)
        if  info.name==UNUSED then
			break
		end
        if (info.isHeader and  info.isHeaderExpanded) or  not info.isHeader then
			local t=''
			if info.isHeader then
				if Save.nameShow then
                	t='|A:'..e.Icon.icon..':0:0|a|cffffffff'..info.name..'|r'
				end
            elseif info.quantity then
				t= Save.nameShow and '   ' or t
                if Save.showID then--显示ID
					local link=C_CurrencyInfo.GetCurrencyListLink(i)
					local id =link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
					t= id and t..id..' ' or t
				end
                t=info.iconFileID and t..'|T'..info.iconFileID..':0|t' or t --图标
				t=Save.nameShow and t..info.name..' ' or t--名称
                if info.maxuantity and info.maxuantity>0 then
					if info.quantity==info.maxuantity then--最大数量
                    	t=t..'|cnRED_FONT_COLOR:'..e.MK(info.quantity, 3)..'|r'..e.Icon.disabled
					else
						t=t..e.MK(info.quantity, 3)..' /'..e.MK(info.maxQuantity)
					end
                else
                    t=t..e.MK(info.quantity, 3)--数量
                end
               	if info.useTotalEarnedForMaxQty  then--CD收入
					local cd=' ('..info.quantityEarnedThisWeek..'/'..info.maxWeeklyQuantity..')'
					if info.maxWeeklyQuantity==info.quantityEarnedThisWeek then
						t=t..'|cnRED_FONT_COLOR:'..cd..'|r'
					else
						t=t..'|cnGREEN_FONT_COLOR:'..cd..'|r'
                    end
				end
				if info.useTotalEarnedForMaxQty and info.totalEarned and info.maxQuantity and info.maxQuantity>0 then
					local cd=e.MK(info.maxQuantity- info.totalEarned)
					if info.totalEarned ==info.maxQuantity or info.quantity==info.maxQuantity then
						t=t..' |cnRED_FONT_COLOR:+'..cd..'|r'
					else
						t=t..' |cnGREEN_FONT_COLOR:+'..cd..'|r'
					end
            	end
        	end
			m= t~=''and m..t..'|n' or m
    	end
	end
	sel.btn.str:SetText(m)
end

hooksecurefunc('TokenFrame_Update',strSetText)

local function Set()
	sel:SetNormalAtlas(not Save.disabled and e.Icon.icon or e.Icon.disabled)

	if not Save.disabled and not sel.btn then--监视声望按钮
		sel.btn=e.Cbtn(UIParent, nil, Save.str)
		sel.btn:SetSize(18, 18)
		if Save.point then
			sel.btn:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
		else
			sel.btn:SetPoint('TOPLEFT', Frame, 'TOPRIGHT',0, -35)
		end
		sel.btn:RegisterForDrag("RightButton")
		sel.btn:SetClampedToScreen(true);
		sel.btn:SetMovable(true);
		sel.btn:SetScript("OnDragStart", function(self2, d) if d=='RightButton' and not IsModifierKeyDown() then self2:StartMoving() end end)
		sel.btn:SetScript("OnDragStop", function(self2)
				ResetCursor()
				self2:StopMovingOrSizing()
				Save.point={self2:GetPoint(1)}
				print(addName..': |cnGREEN_FONT_COLOR:Alt+'..e.Icon.right..KEY_BUTTON2..'|r: '.. TRANSMOGRIFY_TOOLTIP_REVERT);
		end)
		sel.btn:SetScript("OnMouseUp", function() ResetCursor() end)
		sel.btn:SetScript("OnMouseDown", function(self2, d)
			local key=IsModifierKeyDown()
			if d=='RightButton' and IsAltKeyDown() then--alt+右击, 还原位置
				Save.point=nil
				self2:ClearAllPoints()
				self2:SetPoint('TOPLEFT', Frame, 'TOPRIGHT',0, -40)

			elseif d=='RightButton' and not key then--右击,移动
				SetCursor('UI_MOVE_CURSOR')

			elseif d=='LeftButton' and not key then--点击,显示隐藏
				if Save.str then
					Save.str=nil
				else
					Save.str=true
				end
				sel.btn:SetNormalAtlas(Save.str and e.Icon.icon or e.Icon.disabled)
				print(addName..': '..e.GetShowHide(Save.str))
				strSetText()
			elseif d=='LeftButton' and IsAltKeyDown() then--显示名称
				if Save.nameShow then
					Save.nameShow=nil
				else
					Save.nameShow=true
				end
				strSetText()
				print(SHOW..NAME..': ', e.GetShowHide(Save.nameShow))
			elseif d=='LeftButton' and IsControlKeyDown() then --显示ID
				if Save.showID then
					Save.showID=nil
				else
					Save.showID=true
				end
				print(SHOW..' ID: ', e.GetShowHide(Save.showID))
				strSetText()
			end
		end)
		sel.btn:SetScript("OnEnter",function(self2)
			if UnitAffectingCombat('player') then
				return
			end
			e.tips:SetOwner(self2, "ANCHOR_LEFT");
			e.tips:ClearLines();
			e.tips:AddDoubleLine(id, addName)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(addName..': '..e.GetShowHide(Save.str), e.Icon.left)
			e.tips:AddDoubleLine(BINDING_NAME_TOGGLECURRENCY, e.Icon.mid)
			e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(SHOW..NAME..': '..e.GetShowHide(Save.nameShow), 'Alt + '..e.Icon.left)
			e.tips:AddDoubleLine(addName..' ID: '..e.GetShowHide(Save.showID), 'Ctrl + '..e.Icon.left)
			e.tips:Show();
		end)
		sel.btn:SetScript("OnLeave", function() ResetCursor()  e.tips:Hide() end);
		sel.btn:EnableMouseWheel(true)
		sel.btn:SetScript("OnMouseWheel", function (self2, d)
			ToggleCharacter("TokenFrame")--打开货币
		end)

		sel.btn.str=e.Cstr(sel.btn)--内容显示文本
		sel.btn.str:SetPoint('TOPLEFT',3,-3)
	end

	--展开,合起
	if not Save.hideUpDown and not sel.down then
		sel.down=e.Cbtn(sel, true);
		sel.down:SetPoint('RIGHT', sel, 'LEFT', -2,0)
		sel.down:SetSize(18,18);
		sel.down:SetNormalTexture(Icon.down)
		sel.down:SetScript("OnMouseDown", function(self)
				for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
					local info = C_CurrencyInfo.GetCurrencyListInfo(i)
					if info  and info.isHeader and not info.isHeaderExpanded then
						C_CurrencyInfo.ExpandCurrencyList(i,true);
					end
				end
				TokenFrame_Update()
		end)
		sel.up=e.Cbtn(sel, true)
		sel.up:SetPoint('RIGHT', sel.down, 'LEFT',-2,0)
		sel.up:SetSize(18,18);
		sel.up:SetNormalTexture(Icon.up)
		sel.up:SetScript("OnMouseDown", function(self)
				for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
					local info = C_CurrencyInfo.GetCurrencyListInfo(i);
					if info  and info.isHeader and info.isHeaderExpanded then
						C_CurrencyInfo.ExpandCurrencyList(i, false);
					end
				end
				TokenFrame_Update();
		end)
		sel.bag=e.Cbtn(sel,true)
		sel.bag:SetPoint('RIGHT', sel.up, 'LEFT',-2,0)
		sel.bag:SetSize(18,18);
		sel.bag:SetNormalAtlas(e.Icon.bag)
		sel.bag:SetScript("OnMouseDown", function(self)
				for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
					local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
					if info then
						local link=C_CurrencyInfo.GetCurrencyLink(info.currencyTypesID) or info.name
						--C_CurrencyInfo.SetCurrencyBackpack(index, false)
						print(link)
					end
				end
				ToggleAllBags()
				TokenFrame_Update();
		end)
		sel.bag:SetScript('OnEnter', function(self2)
			e.tips:SetOwner(self2, "ANCHOR_LEFT")
			e.tips:ClearLines()
			e.tips:AddLine(SHOW_ON_BACKPACK..': '..GetNumWatchedTokens())
			for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
				local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
				if info and info.name and info.iconFileID then
					e.tips:AddLine('|T'..info.iconFileID..':0|t'..info.name)
				end
			end
			e.tips:Show()
		end)
		sel.bag:SetScript('OnLeave', function() e.tips:Hide() end)
	end

	if sel.down then
		sel.down:SetShown(not Save.hideUpDown)
		sel.up:SetShown(not Save.hideUpDown)
		sel.bag:SetShown(not Save.hideUpDown)
	end
	if sel.btn then
		sel.btn:SetShown(not Save.disabled)
		sel.btn:SetNormalAtlas(Save.str and e.Icon.icon or e.Icon.disabled)
	end
	strSetText()
end
sel:SetScript('OnClick', function (self, d)
	if d=='LeftButton' and not IsModifierKeyDown() then
		if Save.disabled then
			Save.disabled=nil
		else
			Save.disabled=true
		end
		print(addName, e.GetEnabeleDisable(not Save.disabled))
		Set()
	elseif d=='LeftButton' and IsAltKeyDown then--展开所有
		if Save.hideUpDown then
			Save.hideUpDown=nil
		else
			Save.hideUpDown=true
		end
		Set()
		print('|T'..Icon.up..':0|t|T'..Icon.down..':0|t', e.GetShowHide(not Save.hideUpDown))
	elseif d=='RightButton' then
		if Save.updateTips then
			Save.updateTips=nil
		else
			Save.updateTips=true
		end
		print(addName, UPDATE..': ', e.GetEnabeleDisable(Save.updateTips))
	end
end)
sel:RegisterForClicks("LeftButtonDown","RightButtonDown")
sel:SetSize(18, 18)
sel:SetPoint("TOPRIGHT", Frame, 'TOPRIGHT',-6,-35)
sel:SetScript("OnEnter", function(self2)
	e.tips:SetOwner(self2, "ANCHOR_LEFT")
    e.tips:ClearLines()
	e.tips:AddLine(id, addName)
	e.tips:AddLine(' ')
	e.tips:AddDoubleLine(addName..': '..e.GetEnabeleDisable(not Save.disabled), e.Icon.left)
	e.tips:AddDoubleLine(UPDATE..': '..e.GetEnabeleDisable(Save.updateTips), e.Icon.right)
	e.tips:AddLine(' ')
	e.tips:AddDoubleLine('|T'..Icon.up..':0|t|T'..Icon.down..':0|t '..e.GetShowHide(not Save.hideUpDown), 'Alt + '..e.Icon.left)
    e.tips:Show()
end)
sel:SetScript('OnLeave', function ()
	e.tips:Hide()
end)
--[[
local function setUpdat(currencyType)
	local info = currencyType and C_CurrencyInfo.GetCurrencyInfo(currencyType)
	if not Save.updateTips or not info or not info.quantity then
		return
	end
	local link=C_CurrencyInfo.GetCurrencyLink(currencyType)
	local m=((not link and info.iconFileID) and '|T'..info.iconFileID..':0|t' or '')..(link or info.name or '')
	m=m..' '..e.MK(info.quality, 3)
	if info.maxQuantity and info.maxQuantity>0 then
		if info.maxQuantity==info.quantity then
			m=m..' /'..'|cnRED_FONT_COLOR:'..e.MK(info.maxQuantity)..'|r'
		else
			m=m..' /'..e.MK(info.maxQuantity)
		end
	end
	if info.useTotalEarnedForMaxQty  then--CD收入
		local cd=' ('..info.quantityEarnedThisWeek..'/'..info.maxWeeklyQuantity..')'
		if info.maxWeeklyQuantity==info.quantityEarnedThisWeek then
			m=m..'|cnRED_FONT_COLOR:'..cd..'|r'
		else
			m=m..'|cnGREEN_FONT_COLOR:'..cd..'|r'
		end
	end
	if info.useTotalEarnedForMaxQty and info.totalEarned and info.maxQuantity and info.maxQuantity>0 then
		local cd=e.MK(info.maxQuantity- info.totalEarned)
		if info.totalEarned ==info.maxQuantity or info.quantity==info.maxQuantity then
			m=m..' |cnRED_FONT_COLOR:+'..cd..'|r'
		else
			m=m..' |cnGREEN_FONT_COLOR:+'..cd..'|r'
		end
	end
	print(m)
end
]]
sel:RegisterEvent("ADDON_LOADED")
sel:RegisterEvent("PLAYER_LOGOUT")
--sel:RegisterEvent('CURRENCY_DISPLAY_UPDATE')

sel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
		Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
		Set()
    elseif event == "PLAYER_LOGOUT" then
		if not e.ClearAllSave then
			if not WoWToolsSave then WoWToolsSave={} end
			WoWToolsSave[addName]=Save
		end
	--elseif event=='CURRENCY_DISPLAY_UPDATE' then
		--setUpdat(arg1)
	end
end)