local e= select(2, ...)
local function Save()
    return WoWTools_ReputationMixin.Save
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
		or (WoWTools_ReputationMixin.onlyIcon and not atlas and not texture)
	then
		return
	end

	local factionStandingtext
	if not data.isCapped then
		factionStandingtext= data.factionStandingtext
	end

	local text
	if WoWTools_ReputationMixin.onlyIcon then--仅显示有图标
		name=nil
	else
		name= e.cn(name)
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






































local function Crated_Button(index, last)
    local btn= WoWTools_ButtonMixin:Cbtn(WoWTools_ReputationMixin.TrackButton.Frame, {size={14,14}, icon='hide'})
    if Save().toTopTrack then
        btn:SetPoint('BOTTOM', last or WoWTools_ReputationMixin.TrackButton, 'TOP')
    else
        btn:SetPoint('TOP', last or WoWTools_ReputationMixin.TrackButton, 'BOTTOM')
    end
    btn:SetScript('OnLeave', function(self)
        e.tips:Hide()
        if EmbeddedItemTooltip then EmbeddedItemTooltip:Hide() end
        WoWTools_ReputationMixin:Set_TrackButton_Pushed(false, self.text)--TrackButton，提示
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_FactionMixin:SetTooltip(self)
        WoWTools_ReputationMixin:Set_TrackButton_Pushed(true, self.text)--TrackButton，提示
    end)

    btn.text= WoWTools_LabelMixin:CreateLabel(btn, {color=true})
    function btn:set_text_point()
        if Save().toRightTrackText then
            self.text:SetPoint('LEFT', self, 'RIGHT', -3, 0)
        else
            self.text:SetPoint('RIGHT', self, 'LEFT',3, 0)
        end
        self.text:SetJustifyH(Save().toRightTrackText and 'LEFT' or 'RIGHT')
    end

    btn:set_text_point()
    WoWTools_ReputationMixin.TrackButton.btn[index]=btn

    return btn
end















--设置 Text
function WoWTools_ReputationMixin:TrackButton_Settings()
	if not self.TrackButton or not self.TrackButton:IsShown() or not self.TrackButton.Frame:IsShown() then
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

	local last
	for index, tab in pairs(faction) do
		local btn= self.TrackButton.btn[index] or Crated_Button(index, last)
		btn:SetShown(true)
		last=btn

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

	for index= #faction+1, #self.TrackButton.btn do
		local btn=self.TrackButton.btn[index]
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







function WoWTools_ReputationMixin:Set_TrackButton_Pushed(show, label)--TrackButton，提示
	if self.TrackButton then
        self.TrackButton:SetButtonState(show and 'PUSHED' or "NORMAL")
        if label then
            label:SetAlpha(show and 0.5 or 1)
        end
	end
end

