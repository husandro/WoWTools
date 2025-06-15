

local function Save()
    return WoWToolsSave['Currency2']
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


	TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {name='WoWToolsCurrencyTrackButton', size=23})
	WoWTools_CurrencyMixin.TrackButton= TrackButton


	TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')

    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetSize(12,10)

	function TrackButton:set_point()
		self:ClearAllPoints()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		else
			self:SetPoint('TOPLEFT', 200, WoWTools_DataMixin.Player.husandro and 0 or -100)
		end
	end

	function TrackButton:set_texture(icon)
		if icon and icon>0 then
			self.texture:SetTexture(icon)
			self.texture:SetPoint('TOPLEFT',0,0)
			self.texture:SetPoint('BOTTOMRIGHT',0,0)
		else
			self.texture:SetAtlas('Adventure-MissionEnd-Line')
			self.texture:SetPoint('TOPLEFT', 6,-6)
			self.texture:SetPoint('BOTTOMRIGHT',-6,6)
			self.texture:SetAlpha(Save().str and 0.3 or 0.7)
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



	function TrackButton:set_Tooltip()
		if Save().toRightTrackText then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		else
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		end
		GameTooltip:ClearLines()

		local infoType, itemID, itemLink = GetCursorInfo()
		if infoType=='item' and itemID then
			GameTooltip:SetItemByID(itemID)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(itemLink or ('itemID'..itemID),
					Save().item[itemID] and
						('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a')
					or ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
			)
			self:set_texture(C_Item.GetItemIconByID(itemID))
		else
			local canFrame= self.Frame:CanChangeAttribute() and '|cnGREEN_FONT_COLOR:' or ''
			GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CurrencyMixin.addName)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭货币页面' or BINDING_NAME_TOGGLECURRENCY, WoWTools_DataMixin.Icon.left)
			GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), WoWTools_DataMixin.Icon.right)
			GameTooltip:AddDoubleLine(canFrame..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE), 'Atl+'..WoWTools_DataMixin.Icon.right)
			GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(Save().str, true), WoWTools_DataMixin.Icon.mid)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(canFrame..(WoWTools_DataMixin.onlyChinese and '拖曳' or DRAG_MODEL)..WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '物品' or ITEMS), WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
		end
		GameTooltip:Show()
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
        if WoWTools_FrameMixin:IsInSchermo(self) then
			Save().point={self:GetPoint(1)}
			Save().point[2]=nil
        else
            print(
                WoWTools_DataMixin.addName,
                '|cnRED_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
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
			print(WoWTools_DataMixin.Icon.icon2..WoWTools_CurrencyMixin.addName, WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING,
					Save().item[itemID] and
					('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
					or ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..'|A:common-icon-redx:0:0|a'),
					itemLink or itemID)
			ClearCursor()
			WoWTools_CurrencyMixin:Set_TrackButton_Text()

		elseif d=='LeftButton' and not IsModifierKeyDown() then
			ToggleCharacter("TokenFrame")--打开货币

		elseif d=='RightButton' and not IsModifierKeyDown() then
			WoWTools_CurrencyMixin:Init_Menu(self)
			--WoWTools_CurrencyMixin:Init_TrackButton_Menu(self)
		end
	end)


	TrackButton:SetScript("OnEnter", function(self)
		if (Save().itemButtonUse and not UnitAffectingCombat('player')) or not Save().itemButtonUse then
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
			self:set_shown()
		end
		self:set_Tooltip()
		self.texture:SetAlpha(1)
	end)
	TrackButton:SetScript('OnMouseUp', ResetCursor)
	TrackButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:set_texture()
	end)
	TrackButton:SetScript('OnMouseWheel', function(self, d)
		if Save().itemButtonUse and not UnitAffectingCombat('player') or not Save().itemButtonUse then
			Save().str= d==-1
			self:set_texture()
			self.Frame:set_shown()
			self:set_Tooltip()
		end
	end)








	TrackButton.btn={}
	TrackButton.Frame= CreateFrame('Frame', nil, TrackButton)
	TrackButton.Frame:SetSize(1,1)
	TrackButton.Frame:SetPoint('BOTTOM')



	TrackButton.Frame:SetScript('OnShow', function()
		WoWTools_CurrencyMixin:Set_TrackButton_Text()
	end)

	TrackButton.Frame:RegisterEvent('BAG_UPDATE_DELAYED')
	TrackButton.Frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
	TrackButton.Frame:SetScript('OnEvent', function(self, event)
		if event=='PLAYER_REGEN_ENABLED' then
			self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		WoWTools_CurrencyMixin:Set_TrackButton_Text()
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


	WoWTools_CurrencyMixin:Set_TrackButton_Text()

	hooksecurefunc(TokenFrame, 'Update', function(frame)
		if WoWTools_CurrencyMixin.TrackButton then
			WoWTools_CurrencyMixin:Set_TrackButton_Text()
		else
			WoWTools_CurrencyMixin:Init_TrackButton()
		end
	end)
end


















function WoWTools_CurrencyMixin:Init_TrackButton()
    Init_TrackButton()
end

