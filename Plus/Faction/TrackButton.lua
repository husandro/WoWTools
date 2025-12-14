
local function Save()
    return WoWToolsSave['Plus_Faction']
end

local TrackButton, Frame
local Name='WoWToolsFactionTrackButton'
local NumButton= 0

local function Set_TrackButton_Pushed(show, label)--TrackButton，提示
	TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
	if label then
		label:SetAlpha(show and 0.5 or 1)
	end
end




















local function get_Faction_Info(index, factionID)
	local data= WoWTools_FactionMixin:GetInfo(factionID, index, Save().toRightTrackText)
	factionID= data.factionID
	local name
	name= data.name

	if not factionID or not name or name==HIDE or (not data.isHeaderWithRep and data.isHeader) then
		return
	end


	local value= data.valueText
	local texture= data.texture
	local atlas= data.atlas
	local barColor= data.barColor
	local isCapped= data.isCapped
	local isParagon= data.isParagon


	if (isCapped and not isParagon and index)--声望已满，没有奖励
		or (Save().onlyIcon and not atlas and not texture)
	then
		return
	end

	local factionStandingtext
	if not data.isCapped then
		factionStandingtext= data.factionStandingtext
	end

	local text
	if Save().onlyIcon then--仅显示有图标
		name=nil
	else
		name= WoWTools_TextMixin:CN(name)
		name= name:match('%- (.+)') or name
	end

	if barColor then
		if value and not factionStandingtext then--值
			value= barColor:WrapTextInColorCode(value)
		end
		if factionStandingtext  then--等级
			factionStandingtext= barColor:WrapTextInColorCode(factionStandingtext)
		end
	elseif value then
		value= '|cffffffff'..value..'|r'
	end

	if Save().toRightTrackText then--向右平移 
		text= (name or '')
			..(data.hasRep and '|cnGREEN_FONT_COLOR:+|r' or '')--额外，声望
			..(name and ' ' or '')
			..(factionStandingtext or '')
			..(value and ' '..value or '')
			..(data.hasRewardPending or '')--有奖励

	else
		text=(data.hasRewardPending or '')--有奖励
			..(value or '')
			..(factionStandingtext and ' '..factionStandingtext or '')
			..(name and ' ' or '')
			..(data.hasRep and '|cnGREEN_FONT_COLOR:+|r' or '')--额外，声望
			..(name or '')
	end
	return text, texture, atlas, data
end






































local function Crated_Button(index)

    --[[local btn= WoWTools_ButtonMixin:Cbtn(TrackButton.Frame, {
		size=14,
		name=Name..index,
	})]]
	local btn= CreateFrame("Button", Name..index, Frame, 'WoWToolsButtonTemplate')
	btn:SetSize(16, 16)

    if Save().toTopTrack then
        btn:SetPoint('BOTTOM', _G[Name..(index-1)] or TrackButton, 'TOP')
    else
        btn:SetPoint('TOP', _G[Name..(index-1)] or TrackButton, 'BOTTOM')
    end
    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        if EmbeddedItemTooltip:IsShown() then
			EmbeddedItemTooltip:Hide()
		end
        Set_TrackButton_Pushed(false, self.text)--TrackButton，提示
		WoWTools_FactionMixin:Find(nil, nil)
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Faction(self)
        Set_TrackButton_Pushed(true, self.text)--TrackButton，提示
		WoWTools_FactionMixin:Find(self.factionID)
    end)

    btn.text= WoWTools_LabelMixin:Create(btn)
    function btn:set_text_point()
        if Save().toRightTrackText then
            self.text:SetPoint('LEFT', self, 'RIGHT', -3, 0)
        else
            self.text:SetPoint('RIGHT', self, 'LEFT',3, 0)
        end
        self.text:SetJustifyH(Save().toRightTrackText and 'LEFT' or 'RIGHT')
    end

    btn:set_text_point()

	NumButton= index

    return btn
end














--设置 Text
local function TrackButton_Settings()
	if not TrackButton:IsShown() or not Frame:IsShown()  then
		return
	end

	local faction={}
	if Save().indicato then
		for factionID in pairs(Save().factions) do
			local text, texture, atlas, data= get_Faction_Info(nil, factionID)
			if text then
				table.insert(faction, {text= text, texture=texture, atlas=atlas, data=data})
			end
		end
		table.sort(faction, function(a, b) return a.data.factionID > b.data.factionID end)
	else
		for index=1, C_Reputation.GetNumFactions() do
			local text, texture, atlas, data= get_Faction_Info(index, nil)
			if text then
				table.insert(faction, {text= text, texture=texture, atlas=atlas, data=data})
			end
		end
	end


	for index, tab in pairs(faction) do
		local btn= _G[Name..index] or Crated_Button(index)
		btn:SetShown(true)
		btn.text:SetText(tab.text)
		btn.factionID= tab.data.factionID
		btn.friendshipID= tab.data.friendshipID
		btn.isMajor= tab.data.isMajor
		btn.isParagon= tab.data.isParagon
		btn.name= tab.data.name

		if tab.texture then
			btn:SetNormalTexture(tab.texture)
		elseif tab.atlas then
			btn:SetNormalAtlas(tab.atlas)
		else
			btn:SetNormalTexture(0)
		end
	end

	for index= #faction+1, NumButton do
		local btn= _G[Name..index]
		btn.text:SetText('')
		btn:SetShown(false)
		btn:SetNormalTexture(0)
		btn.factionID= nil
		btn.isFriend= nil
		btn.isMajor= nil
		btn.isParagon= nil
		btn.name= nil
	end
end































local function Init_Menu(self, root)
	local sub, sub2
--显示
	sub=root:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
	function()
		return Save().btnstr
	end, function()
		Save().btnstr= not Save().btnstr and true or false
		self:set_Shown()
		WoWTools_FactionMixin:UpdatList()
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))
	end)

--向右平移
	sub:CreateDivider()
	sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT,
	function()
		return Save().toRightTrackText
	end, function()
		Save().toRightTrackText= not Save().toRightTrackText and true or false
		for index=1, NumButton do
			local btn= _G[Name..index]
			if btn then
				btn.text:ClearAllPoints()
				btn:set_text_point()
			end
		end
		WoWTools_FactionMixin:UpdatList()
	end)

--上
	sub:CreateCheckbox(
		'|A:bags-greenarrow:0:0|a'
		..(WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP),
	function()
		return Save().toTopTrack
	end, function()
		Save().toTopTrack= not Save().toTopTrack and true or nil
		for index= 1, NumButton do
			local btn=_G[Name..index]
			if btn then
				btn:ClearAllPoints()
				if Save().toTopTrack then
					btn:SetPoint('BOTTOM', _G[Name..(index-1)] or self, 'TOP')
				else
					btn:SetPoint('TOP', _G[Name..(index-1)] or self, 'BOTTOM')
				end
			end
		end
		WoWTools_FactionMixin:UpdatList()
	end)

--隐藏名称
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '隐藏名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, NAME),
	function()
		return Save().onlyIcon
	end, function()
		Save().onlyIcon= not Save().onlyIcon and true or nil
		WoWTools_FactionMixin:UpdatList()
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(
			WoWTools_DataMixin.onlyChinese and '仅显示有图标声望'
			or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FACTION, EMBLEM_SYMBOL))
		)
		WoWTools_FactionMixin:UpdatList()
	end)

--缩放
	WoWTools_MenuMixin:Scale(self, sub, function()
		return Save().scaleTrackButton or 1
	end, function(value)
		Save().scaleTrackButton= value
		self:settings()
	end)

--FrameStrata    
	WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
		return self:GetFrameStrata()==data
	end, function(data)
		Save().strata= data
		self:set_strata()
	end)


--自动隐藏
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE),
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		self:set_Shown()
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
	end)

--重置位置
	sub:CreateDivider()
	WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
		Save().point=nil
		self:ClearAllPoints()
		self:set_Point()
		print(
			WoWTools_FactionMixin.addName..WoWTools_DataMixin.Icon.icon2,
			WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
		)
	end)

	--打开选项界面
	root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_FactionMixin.addName})
end

















--初始，监视, 文本
local function Init()
	if not Save().btn then
		return
	end

	--[[TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {
		size=23,
		name='WoWToolsFactionTrackMainButton',
	})]]
	TrackButton= CreateFrame('Button', 'WoWToolsFactionTrackMainButton', UIParent, 'WoWToolsButtonTemplate')


	TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAtlas('Adventure-MissionEnd-Line')
    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetSize(12,10)

	Frame= CreateFrame('Frame', nil, TrackButton)
	Frame:SetPoint('BOTTOM')
	Frame:SetSize(1,1)

	function TrackButton:set_Shown()
		local hide= not Save().btn
		or (
		   not Save().notAutoHideTrack and (
				IsInInstance()
				or C_PetBattles.IsInBattle()
				or UnitInVehicle('player')
				or UnitAffectingCombat('player')
			)
	   )
	   	self:SetShown(not hide)
		Frame:SetShown(not hide and Save().btnstr)
		TrackButton_Settings()
		self:set_Texture()
	end




	TrackButton:SetScript('OnEvent', function(self, event)
		if event=='UPDATE_FACTION' then
			TrackButton_Settings()
		else
			self:set_Shown()
		end
	end)


	function TrackButton:set_Tooltips()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, WoWTools_DataMixin.Icon.left)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
		GameTooltip:Show()
	end

	function TrackButton:settings()
		Frame:SetScale(Save().scaleTrackButton or 1)

		self:UnregisterAllEvents()
		if Save().btn then
			self:RegisterEvent('UPDATE_FACTION')
			self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
			self:RegisterEvent('PLAYER_ENTERING_WORLD')
			self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')
			self:RegisterEvent('PLAYER_REGEN_DISABLED')
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
			self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
			self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
		end

	end

	function TrackButton:set_Texture()
		self.texture:SetAlpha(Save().btnstr and 0.3 or 0.7)
	end

	function TrackButton:set_Point()
		if Save().point then
			self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
		else
			self:SetPoint('TOPLEFT', 0, WoWTools_DataMixin.Player.husandro and 0 or -100)
		end
	end

	function TrackButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

	TrackButton:RegisterForDrag("RightButton")
	TrackButton:SetClampedToScreen(true);
	TrackButton:SetMovable(true);
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
		end
	end)
	TrackButton:SetScript("OnMouseUp", ResetCursor)

	TrackButton:SetScript("OnMouseDown", function(self, d)
		if d=='RightButton' and IsAltKeyDown() then
			SetCursor('UI_MOVE_CURSOR')

		elseif d=='LeftButton' and not IsModifierKeyDown() then--右击, 移动
			ToggleCharacter("ReputationFrame")


		elseif d=='RightButton' and not IsModifierKeyDown() then
			MenuUtil.CreateContextMenu(self, Init_Menu)
		end
		self:set_Tooltips()
	end)

	TrackButton:SetScript("OnLeave", function(self)
		ResetCursor()
		GameTooltip:Hide()
		self:set_Texture()
	end)
	TrackButton:SetScript("OnEnter", function(self)
		self:set_Tooltips()
		self.texture:SetAlpha(1)
		TrackButton_Settings()
	end)


	TrackButton:settings()
	TrackButton:set_Point()
	TrackButton:set_Shown()
	TrackButton:set_Texture()
	TrackButton:set_strata()
	TrackButton_Settings()



	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'OnEnter', function(self)--角色栏,声望
		local factionID= self.elementData and self.elementData.factionID
		if not factionID then
			return
		end
		for index= 1, NumButton do
			local btn= _G[Name..index]
			if btn then
				if factionID== btn.factionID then
					btn:SetScale(2)
				else
					btn:SetScale(1)
				end
			end
		end
    end)
	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'OnLeave', function()--角色栏,声望
		for index= 1, NumButton do
			local btn= _G[Name..index]
			if btn then
				btn:SetScale(1)
			end
		end
    end)

	WoWTools_DataMixin:Hook(ReputationFrame, 'Update', function()
		TrackButton_Settings()--更新, 监视, 文本
	end)

	Init=function()
		TrackButton:settings()
		TrackButton:set_Shown()
		TrackButton_Settings()
		TrackButton:set_Point()
	end
end











function WoWTools_FactionMixin:Init_TrackButton()
    Init()
end