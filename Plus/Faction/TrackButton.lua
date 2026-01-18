
local function Save()
    return WoWToolsSave['Plus_Faction']
end

local TrackButton, Frame
local Name='WoWToolsFactionTrackButton'
local NumButton= 0

local function Set_TrackButton_Pushed(show, label)--TrackButton，提示
	
end




















local function get_Faction_Info(factionID)
	local data= WoWTools_FactionMixin:GetInfo(factionID, not Save().toRightTrackText) or {}




	if not data.factionID
		or not data.isUnlocked
		or (data.isCapped and not data.isParagon) --声望已满，没有奖励
		or (Save().onlyIcon and not (data.atlas or data.texture))
		or (Save().onlyMajor and not data.isMajor)
		or not (data.factionStandingtext or data.valueText)
	then
		return
	end

--名称
	local name
	if Save().onlyIcon then--仅显示有图标
		name=nil
	elseif data.name then
		name= WoWTools_TextMixin:CN(data.name)
		name= name:match('%- (.+)') or name
	end
--等级
	local factionStandingtext
	if not data.isCapped and data.isUnlocked then
		factionStandingtext= data.factionStandingtext
	end

--值
	local value= data.valueText

--有奖励
	local hasRewardPending= data.hasRewardPending or ''

	local text
	if Save().toRightTrackText then--向右平移 

		text= factionStandingtext

		if value then
			text= (text or '')..(text and ' ' or '')..value
		end

		if text then
			if not data.isCapped then
				text= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(text)
			elseif data.color then
				text= data.color:WrapTextInColorCode(text)
			end
		end
		if hasRewardPending then
			text= (text or '')..hasRewardPending
		end
		if name then
			text= name..(text and ' '..text or '')
		end

	else
		text= value
		if factionStandingtext then
			text= (text or '')..(text and ' ' or '').. factionStandingtext
		end
		if text then
			if not data.isCapped then
				text= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(text)
			elseif data.color then
				text= data.color:WrapTextInColorCode(text)
			end
		end
		if name then
			text= (text or '')..(text and ' ' or '')..name
		end
		if hasRewardPending then
			text= hasRewardPending..(text or '')
		end
	end


	return text, data.texture, data.atlas, data
end






































local function Crated_Button(index)

	local btn= CreateFrame("Button", Name..index, Frame, 'WoWToolsButtonTemplate')
	--btn:SetSize(16, 16)

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
		TrackButton:SetButtonState( "NORMAL")
		self.text:SetAlpha(1)
		WoWTools_FactionMixin:Find(nil, nil)
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Faction(self)
        Set_TrackButton_Pushed(true, self.text)--TrackButton，提示
		TrackButton:SetButtonState('PUSHED')
		self.text:SetAlpha(0.5)
		WoWTools_FactionMixin:Find(self.factionID)
    end)

	btn:SetScript('OnClick', function(self)
		WoWTools_LoadUIMixin:OpenFaction(self.factionID)
	end)

    btn.text= btn:CreateFontString(nil, 'BORDER', 'GameFontNormal')--  WoWTools_LabelMixin:Create(btn)
    function btn:set_text_point()
		self.text:ClearAllPoints()
        if Save().toRightTrackText then
            self.text:SetPoint('LEFT', self, 'RIGHT', -3, 0)
        else
            self.text:SetPoint('RIGHT', self, 'LEFT',3, 0)
        end
        self.text:SetJustifyH(Save().toRightTrackText and 'LEFT' or 'RIGHT')
    end

	btn.canClickForOptions= true

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
		for factionID in pairs(Save().factions or {}) do
			local text, texture, atlas= get_Faction_Info(factionID)
			if text then
				table.insert(faction, {text= text, texture=texture, atlas=atlas, factionID=factionID})
			end
		end
		table.sort(faction, function(a, b) return a.factionID > b.factionID end)
	else--if Save().onlyMajor then

		for index=1, C_Reputation.GetNumFactions() do
			local info= C_Reputation.GetFactionDataByIndex(index) or {}
			if info.name==HIDE then
				break
			else
				local text, texture, atlas= get_Faction_Info(info.factionID)
				if text then
					table.insert(faction, {text= text, texture=texture, atlas=atlas, factionID=info.factionID})
				end
			end
		end
	end


	local bgWidth= 0
	for index, tab in pairs(faction) do
		local btn= _G[Name..index] or Crated_Button(index)
		btn:SetShown(true)
		btn.text:SetText(tab.text)
		btn.factionID= tab.factionID

		if tab.texture then
			btn:SetNormalTexture(tab.texture)
		elseif tab.atlas then
			btn:SetNormalAtlas(tab.atlas)
		else
			btn:SetNormalTexture(0)
		end

		bgWidth= math.max(btn.text:GetWidth()+16, bgWidth)
	end

	TrackButton.numButton= #faction
	TrackButton.bgWidth= bgWidth
	TrackButton:set_bg()

	for index= #faction+1, NumButton do
		local btn= _G[Name..index]
		btn.text:SetText('')
		btn:SetShown(false)
		btn:SetNormalTexture(0)
		btn.factionID= nil
	end

	faction=nil
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
		TrackButton_Settings()
	end)
	sub:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))
	end)

--向右平移
	sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT,
	function()
		return Save().toRightTrackText
	end, function()
		Save().toRightTrackText= not Save().toRightTrackText and true or false
		for index=1, NumButton do
			local btn= _G[Name..index]
			if btn then
				btn:set_text_point()
			end
		end
		TrackButton_Settings()
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
		TrackButton_Settings()
	end)

--隐藏名称
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME,
	function()
		return not Save().onlyIcon
	end, function()
		Save().onlyIcon= not Save().onlyIcon and true or nil
		TrackButton_Settings()
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(
			WoWTools_DataMixin.onlyChinese and '仅显示有图标声望'
			or format(LFG_LIST_CROSS_FACTION, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FACTION, EMBLEM_SYMBOL))
		)
		TrackButton_Settings()
	end)
--仅限名望
	sub2= sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '仅限名望' or format(LFG_LIST_CROSS_FACTION, JOURNEYS_RENOWN_LABEL or LANDING_PAGE_RENOWN_LABEL),
	function()
		return Save().onlyMajor
	end, function()
		Save().onlyMajor= not Save().onlyMajor and true or nil
		TrackButton_Settings()
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

--背景, 透明度
	WoWTools_MenuMixin:BgAplha(sub,
	function()--GetValue
		return Save().trackBgAlpha or 0.5
	end, function(value)--SetValue
		Save().trackBgAlpha= value
		self:set_bgalpha()
	end, function()--RestFunc
		Save().bgAlpha= nil
		self:set_bgalpha()
	end)--onlyRoot

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


	TrackButton= CreateFrame('Button', 'WoWToolsFactionTrackMainButton', UIParent, 'WoWToolsButtonTemplate')

	Frame= CreateFrame('Frame', nil, TrackButton)
	Frame:SetPoint('BOTTOM')
	Frame:SetSize(1,1)

	TrackButton.Bg= Frame:CreateTexture(nil, "BACKGROUND")
	TrackButton.numButton=0--这个是总数量
	TrackButton.NumButton=0--物品按钮，总数量
	TrackButton.bgWidth=0
	function TrackButton:set_bgalpha()
		self.Bg:SetColorTexture(0, 0, 0, Save().trackBgAlpha or 0.5)
	end
	function TrackButton:set_bg()
		self.Bg:ClearAllPoints()
		if self.numButton==0 then
			return
		end
		if Save().toTopTrack then
			if Save().toRightTrackText then
				self.Bg:SetPoint("TOPLEFT", _G[Name..self.numButton], -1, 1)
				self.Bg:SetPoint('BOTTOMLEFT', _G[Name..1], -1, -1)
			else
				self.Bg:SetPoint("TOPRIGHT", _G[Name..self.numButton], 1, 1)
				self.Bg:SetPoint('BOTTOMRIGHT', _G[Name..1], 1, -1)
			end
		else
			if Save().toRightTrackText then
				self.Bg:SetPoint('TOPLEFT', _G[Name..1], -1, 1)
				self.Bg:SetPoint('BOTTOMLEFT', _G[Name..self.numButton], -1, -1)
			else
				self.Bg:SetPoint('TOPRIGHT', _G[Name..1], 1, 1)
				self.Bg:SetPoint('BOTTOMRIGHT', _G[Name..self.numButton], 1, -1)
			end
		end
		self.Bg:SetWidth(self.bgWidth+1)
	end

	TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetAtlas('Adventure-MissionEnd-Line')
    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetSize(20,10)



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
		self:set_alpha()
	end




	TrackButton:SetScript('OnEvent', function(self, event)
		if event=='UPDATE_FACTION' then
			TrackButton_Settings()
		else
			self:set_Shown()
		end
	end)


	function TrackButton:set_tooltip()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(WoWTools_FactionMixin.addName..WoWTools_DataMixin.Icon.icon2)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '打开/关闭声望界面' or BINDING_NAME_TOGGLECHARACTER2, WoWTools_DataMixin.Icon.left)
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(Frame:IsShown(), true)..' |cffffffff#'..self.numButton, WoWTools_DataMixin.Icon.mid)
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

	function TrackButton:set_alpha()
		self.texture:SetAlpha(Save().btnstr and 0.3 or 1)
	end

	function TrackButton:set_Point()
		local p= Save().point
		if p and p[1] then
			self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
		elseif WoWTools_DataMixin.Player.husandro then
			self:SetPoint('TOPLEFT')
		else
			self:SetPoint('CENTER')
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
		self:set_tooltip()
	end)

	TrackButton:SetScript('OnMouseWheel', function(self, d)
		Save().btnstr= d==1
		self:set_Shown()
		TrackButton_Settings()
		self:set_tooltip()
	end)


	TrackButton:SetScript("OnEnter", function(self)
		self.texture:SetAlpha(1)
		self:set_tooltip()
		TrackButton_Settings()
	end)



	TrackButton:settings()
	TrackButton:set_Point()
	TrackButton:set_Shown()
	TrackButton:set_alpha()
	TrackButton:set_strata()
	TrackButton:set_bgalpha()
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