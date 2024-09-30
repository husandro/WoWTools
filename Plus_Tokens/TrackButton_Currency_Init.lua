local e= select(2, ...)

local function Save()
    return WoWTools_TokensMixin.Save
end
local TrackButton












local function Init_TrackButton()
	if Save().Hide or TrackButton then
		if TrackButton then
			TrackButton:set_event()
			TrackButton:set_shown()
		end
		return
	end


	TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {name='WoWTools_PlusTe', atlas='hide', size={18,18}, isType2=true})
	WoWTools_TokensMixin.TrackButton= TrackButton

	TrackButton.texture= TrackButton:CreateTexture()
	TrackButton.texture:SetAllPoints()
	TrackButton.texture:SetAlpha(0.5)

	function TrackButton:set_point()
		self:ClearAllPoints()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		elseif e.Player.husandro then
			self:SetPoint('TOPLEFT')
		else
			self:SetPoint('TOPLEFT', TokenFrame, 'TOPRIGHT',0, -35)
		end
	end

	function TrackButton:set_texture(icon)
		if icon and icon>0 then
			self.texture:SetTexture(icon)
		elseif Save().str then
			self.texture:SetTexture(0)
		else
			self.texture:SetAtlas(e.Icon.icon)
		end
	end

	function TrackButton:set_shown()--显示,隐藏
		local hide= Save().Hide
		 	or (
				not Save().notAutoHideTrack and (
					IsInInstance()
					or C_PetBattles.IsInBattle()					
					or UnitHasVehicleUI('player')
					or UnitAffectingCombat('player')
				)
			)
		if self:CanChangeAttribute() then
			self:SetShown(not hide)
		end
	end

	function TrackButton:set_event()
		if Save().Hide then
			self:UnregisterAllEvents()
		else
			self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
			self:RegisterEvent('PLAYER_ENTERING_WORLD')
			self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')
			self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
			self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
			self:RegisterEvent('PLAYER_REGEN_DISABLED')
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end

	TrackButton:SetScript('OnEvent', TrackButton.set_shown)


	function TrackButton:set_scale()
		if self.Frame:CanChangeAttribute() then
			self.Frame:SetScale(Save().scaleTrackButton or 1)
		end
	end



	function TrackButton:set_Tooltips()
		if Save().toRightTrackText then
			e.tips:SetOwner(self, "ANCHOR_RIGHT")
		else
			e.tips:SetOwner(self, "ANCHOR_LEFT")
		end
		e.tips:ClearLines()

		local infoType, itemID, itemLink = GetCursorInfo()
		if infoType=='item' and itemID then
			e.tips:SetItemByID(itemID)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(itemLink or ('itemID'..itemID),
					Save().item[itemID] and
						('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
					or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
			)
			self:set_texture(C_Item.GetItemIconByID(itemID))
		else
			local canFrame= self.Frame:CanChangeAttribute() and '|cnGREEN_FONT_COLOR:' or ''
			e.tips:AddDoubleLine(e.addName, WoWTools_TokensMixin.addName)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, e.Icon.left)
			e.tips:AddDoubleLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..' '..e.GetShowHide(Save().str), e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '移动' or NPE_MOVE), 'Atl+'..e.Icon.right)
			e.tips:AddLine(' ')
			e.tips:AddDoubleLine(canFrame..(e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '追踪' or TRACKING)
		end
		e.tips:Show()
	end

	

	TrackButton:RegisterForDrag("RightButton")
	TrackButton:SetClampedToScreen(true)
	TrackButton:SetMovable(true)
	TrackButton:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	TrackButton:SetScript("OnDragStop", function(self)
		ResetCursor()
		self:StopMovingOrSizing()
		Save().point={self:GetPoint(1)}
		Save().point[2]=nil
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)
	
	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then--右击,移动
			SetCursor('UI_MOVE_CURSOR')
			return
		end

		local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
			Save().item[itemID]= not Save().item[itemID] and true or nil
			print(e.addName, WoWTools_TokensMixin.addName, e.onlyChinese and '追踪' or TRACKING,
					Save().item[itemID] and
					('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', e.Icon.select))
					or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
					itemLink or itemID)
			ClearCursor()
			WoWTools_TokensMixin:Set_TrackButton_Text()

		elseif d=='LeftButton' and not IsModifierKeyDown() then
			ToggleCharacter("TokenFrame")--打开货币

		elseif d=='RightButton' and not IsModifierKeyDown() then
			WoWTools_TokensMixin:Init_Menu(self)
			--WoWTools_TokensMixin:Init_TrackButton_Menu(self)
		end
	end)


	TrackButton:SetScript("OnEnter", function(self)
		if (Save().itemButtonUse and not UnitAffectingCombat('player')) or not Save().itemButtonUse then
			WoWTools_TokensMixin:Set_TrackButton_Text()
			self:set_shown()
		end
		self:set_Tooltips()
		self.texture:SetAlpha(1)
	end)
	TrackButton:SetScript('OnMouseUp', ResetCursor)
	TrackButton:SetScript("OnLeave", function(self)
		e.tips:Hide()
		self:set_texture()
		self.texture:SetAlpha(0.5)
	end)









	TrackButton.btn={}
	TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
	TrackButton.Frame:SetSize(1,1)
	TrackButton.Frame:SetPoint('BOTTOM')



	TrackButton.Frame:SetScript('OnShow', function()
		WoWTools_TokensMixin:Set_TrackButton_Text()
	end)

	TrackButton.Frame:RegisterEvent('BAG_UPDATE_DELAYED')
	TrackButton.Frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	TrackButton.Frame:SetScript('OnEvent', function(self, event)
		if event=='PLAYER_REGEN_ENABLED' then
			self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		WoWTools_TokensMixin:Set_TrackButton_Text()
	end)
	function TrackButton.Frame:set_shown()
		if Save().itemButtonUse and not UnitAffectingCombat('player') or not Save().itemButtonUse then
			self:SetShown(Save().str)
		end
	end
	TrackButton.Frame:set_shown()

	function TrackButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end
	TrackButton:set_strata()
	TrackButton:set_point()
	TrackButton:set_scale()
	TrackButton:set_event()
	TrackButton:set_shown()
	TrackButton:set_texture()

	
	WoWTools_TokensMixin:Set_TrackButton_Text()
end


















function WoWTools_TokensMixin:Init_TrackButton()
    Init_TrackButton()
end

