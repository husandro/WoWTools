local id, e = ...
local addName=TOKENS
local Save={Hide=true, str=true}
local panel= e.Cbtn(TokenFrame, true, nil,nil,nil, true, {18,18})

local function strSetText()
	if not Save.str or not panel.btn then
		if panel.btn then
			panel.btn.text:SetText('')
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
					local id2 =link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
					t= id2 and t..id2..' ' or t
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
	panel.btn.text:SetText(m)
end

local function set_CURRENCY_DISPLAY_UPDATE()
	if Save.Hide then
		panel:UnregisterEvent('CURRENCY_DISPLAY_UPDATE')
	else
		panel:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	end
end

local function Set()
	panel:SetNormalAtlas(not Save.Hide and e.Icon.icon or e.Icon.disabled)
	set_CURRENCY_DISPLAY_UPDATE()--注册, 事情
	if not Save.Hide and not panel.btn then--监视声望按钮
		panel.btn=e.Cbtn(UIParent, nil, Save.str)
		panel.btn:SetSize(18, 18)
		if Save.point then
			panel.btn:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
		else
			panel.btn:SetPoint('TOPLEFT', TokenFrame, 'TOPRIGHT',0, -35)
		end
		panel.btn:RegisterForDrag("RightButton")
		panel.btn:SetClampedToScreen(true);
		panel.btn:SetMovable(true);
		panel.btn:SetScript("OnDragStart", function(self2, d) if d=='RightButton' and not IsModifierKeyDown() then self2:StartMoving() end end)
		panel.btn:SetScript("OnDragStop", function(self2)
				ResetCursor()
				self2:StopMovingOrSizing()
				Save.point={self2:GetPoint(1)}
				Save.point[2]=nil
		end)
		panel.btn:SetScript("OnMouseUp", function() ResetCursor() end)
		panel.btn:SetScript("OnMouseDown", function(self2, d)
			local key=IsModifierKeyDown()
			if d=='RightButton' and not key then--右击,移动
				SetCursor('UI_MOVE_CURSOR')

			elseif d=='LeftButton' and not key then--点击,显示隐藏
				Save.str= not Save.str and true or nil
				panel.btn:SetNormalAtlas(Save.str and e.Icon.icon or e.Icon.disabled)
				print(id, addName, e.GetShowHide(Save.str))
				strSetText()
				set_CURRENCY_DISPLAY_UPDATE()--注册, 事情

			elseif d=='LeftButton' and IsAltKeyDown() then--显示名称
				Save.nameShow= not Save.nameShow and true or nil
				strSetText()
				print(id, addName, SHOW, NAME, e.GetShowHide(Save.nameShow))

			elseif d=='LeftButton' and IsControlKeyDown() then --显示ID
				Save.showID= not Save.showID and true or nil
				print(id, addName, SHOW, 'ID', e.GetShowHide(Save.showID))
				strSetText()
			end
		end)
		panel.btn:SetScript("OnEnter",function(self2)
			e.tips:SetOwner(self2, "ANCHOR_LEFT");
			e.tips:ClearLines();
			e.tips:AddDoubleLine((e.onlyChinse and '文本' or LOCALE_TEXT_LABEL)..': '..e.GetShowHide(Save.str),e.Icon.left)
			e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.onlyChinse and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, e.Icon.mid)
			e.tips:AddDoubleLine((e.onlyChinse and '字体大小' or FONT_SIZE)..(Save.size or 12), 'Alt+'..e.Icon.mid)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine((e.onlyChinse and '名称' or NAME)..': '..e.GetShowHide(Save.nameShow), 'Alt+'..e.Icon.left)
			e.tips:AddDoubleLine('ID: '..e.GetShowHide(Save.showID), 'Ctrl+'..e.Icon.left)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(id, addName)
			e.tips:Show();
		end)
		panel.btn:SetScript("OnLeave", function() ResetCursor()  e.tips:Hide() end);
		panel.btn:EnableMouseWheel(true)
		panel.btn:SetScript("OnMouseWheel", function (self2, d)
			if IsAltKeyDown() then
				local n= Save.size or 12
				if d==1 then
					n= n+ 1
				elseif d==-1 then
					n= n- 1
				end
				n= n<6 and 6 or n
				n= n>32 and 32 or n
				Save.size=n
				e.Cstr(nil, n, nil, panel.btn.text, true)
				print(id, addName, e.onlyChinse and '文本' or LOCALE_TEXT_LABEL, e.onlyChinse and '字体大小' or FONT_SIZE, n)
			else
				if d==1 and not TokenFrame:IsVisible() or d==-1 and TokenFrame:IsVisible() then
					ToggleCharacter("TokenFrame")--打开货币
				end
			end
		end)

		panel.btn.text=e.Cstr(panel.btn, Save.size, nil, nil, true)--内容显示文本
		panel.btn.text:SetPoint('TOPLEFT',3,-3)
	end

	--展开,合起
	if not Save.hideUpDown and not panel.down then
		panel.down=e.Cbtn(panel, true);
		panel.down:SetPoint('RIGHT', panel, 'LEFT', -2,0)
		panel.down:SetSize(18,18);
		panel.down:SetNormalTexture('Interface\\Buttons\\UI-MinusButton-Up')
		panel.down:SetScript("OnMouseDown", function(self)
				for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
					local info = C_CurrencyInfo.GetCurrencyListInfo(i)
					if info  and info.isHeader and not info.isHeaderExpanded then
						C_CurrencyInfo.ExpandCurrencyList(i,true);
					end
				end
				TokenFrame_Update()
		end)
		panel.up=e.Cbtn(panel, true)
		panel.up:SetPoint('RIGHT', panel.down, 'LEFT',-2,0)
		panel.up:SetSize(18,18);
		panel.up:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
		panel.up:SetScript("OnMouseDown", function(self)
				for i=1, C_CurrencyInfo.GetCurrencyListSize() do--展开所有
					local info = C_CurrencyInfo.GetCurrencyListInfo(i);
					if info  and info.isHeader and info.isHeaderExpanded then
						C_CurrencyInfo.ExpandCurrencyList(i, false);
					end
				end
				TokenFrame_Update();
		end)
		panel.bag=e.Cbtn(panel,true)
		panel.bag:SetPoint('RIGHT', panel.up, 'LEFT',-2,0)
		panel.bag:SetSize(18,18);
		panel.bag:SetNormalAtlas(e.Icon.bag)
		panel.bag:SetScript("OnMouseDown", function(self)
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
		panel.bag:SetScript('OnEnter', function(self2)
			e.tips:SetOwner(self2, "ANCHOR_LEFT")
			e.tips:ClearLines()
			e.tips:AddDoubleLine(e.onlyChinse and '在行囊上显示' or SHOW_ON_BACKPACK, GetNumWatchedTokens())
			for index=1, BackpackTokenFrame:GetMaxTokensWatched() do--Blizzard_TokenUI.lua
				local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
				if info and info.name and info.iconFileID then
					e.tips:AddDoubleLine(info.name, '|T'..info.iconFileID..':0|t')
				end
			end
			e.tips:Show()
		end)
		panel.bag:SetScript('OnLeave', function() e.tips:Hide() end)
	end

	if panel.down then
		panel.down:SetShown(not Save.hideUpDown)
		panel.up:SetShown(not Save.hideUpDown)
		panel.bag:SetShown(not Save.hideUpDown)
	end
	if panel.btn then
		panel.btn:SetShown(not Save.Hide)
		panel.btn:SetNormalAtlas(Save.str and e.Icon.icon or e.Icon.disabled)
	end
	strSetText()
end

--######
--初始化
--######
local function Init()
	panel:SetPoint("TOPRIGHT", TokenFrame, 'TOPRIGHT',-6,-35)
	panel:SetScript('OnMouseDown', function (self, d)
		if d=='LeftButton' then
			Save.Hide= not Save.Hide and true or nil
			print(id, addName, e.GetEnabeleDisable(not Save.Hide))
			Set()
		elseif d=='RightButton' then--展开所有
			Save.hideUpDown= not Save.hideUpDown and true or nil
			Set()
			print(id, addName, '|TInterface\\Buttons\\UI-PlusButton-Up:0|t|TInterface\\Buttons\\UI-MinusButton-Up:0|t', e.GetShowHide(not Save.hideUpDown))
		end
	end)
	panel:SetScript("OnEnter", function(self2)
		e.tips:SetOwner(self2, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(id, addName)
		e.tips:AddLine(' ')
		e.tips:AddDoubleLine((e.onlyChinse and '文本' or  LOCALE_TEXT_LABEL)..': '..e.GetEnabeleDisable(not Save.Hide),e.Icon.left)
		e.tips:AddDoubleLine('|TInterface\\Buttons\\UI-PlusButton-Up:0|t|TInterface\\Buttons\\UI-MinusButton-Up:0|t '..e.GetShowHide(not Save.hideUpDown), 'Alt+'..e.Icon.left)
		e.tips:Show()
	end)
	panel:SetScript('OnLeave', function ()
		e.tips:Hide()
	end)

	Set()
	hooksecurefunc('TokenFrame_Update',strSetText)--设置, 文本
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '货币' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
				Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

	elseif event=='CURRENCY_DISPLAY_UPDATE' then
		strSetText()
	end
end)