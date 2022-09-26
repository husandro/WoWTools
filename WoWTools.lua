local id, e = ...
e.L=e.L or {}--多语言
e.tips=GameTooltip

e.Race=function(unit, race, sex)--玩家种族图标
    race =unit and select(2,UnitRace(unit)) or race
    if race=='Scourge' then
      race='Undead'
    elseif race=='HighmountainTauren' then
      race='highmountain'
    elseif race=='ZandalariTroll' then
      race='zandalari'
    elseif race=='LightforgedDraenei' then
      race='lightforged'
    end
    sex= unit and UnitSex(unit) or sex
    sex= sex==2 and 'male' or 'female'
    return '|A:raceicon128-'..race..'-'..sex..':0:0|a'
end

e.Player={
  server=GetRealmName(),
  col='|c'..select(4,GetClassColor(UnitClassBase('player'))),
  zh= GetLocale()== "zhCN",
  Lo=GetLocale(),
  class=UnitClassBase('player'),
  --MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion()
}

e.Icon={
  icon='orderhalltalents-done-glow',

  disabled='talents-button-reset',
  select='GarrMission_EncounterBar-CheckMark',--绿色√
  select2='|A:GarrMission_EncounterBar-CheckMark:0:0|a',--绿色√
  selectYellow='Adventures-Checkmark',--黄色√
  X2='|A:xmarksthespot:0:0|a',

  right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
  left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
  mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',

  pushed='Forge-ColorSwatchHighlight',--移过时
  highlight='Forge-ColorSwatchSelection',--点击时

  transmogHide2='|A:transmog-icon-hidden:0:0|a',--不可幻化
  okTransmog2='|T132288:0|t',--可幻化

  map='poi-islands-table',
  map2='|A:poi-islands-table:0:0|a',
  wow2='|A:Icon-WoW:0:0|a',

  horde2='|A:charcreatetest-logo-horde:0:0|a',
  alliance2='|A:charcreatetest-logo-alliance:0:0|a',

  number='services-number-',
  number2='|A:services-number-%d:0:0|a',
  clock='socialqueuing-icon-clock',
  clock2='|A:socialqueuing-icon-clock:0:0|a',

  player=e.Race('player'),
}

e.GetNpcID = function(unit)--NPC ID
  if UnitExists(unit) then
    local guid=UnitGUID(unit)
    if guid then
      return select(6,  strsplit("-", guid));
    end
  end
end

e.MK=function(k,b)
  b=b or 1
  if k>=1e6 then
    k=string.format('%.'..b..'fm',k/1e6)
  elseif k>= 1e4 and e.Player.zh then
    k=string.format('%.'..b..'fw',k/1e4) elseif k>=1e3 then k=string.format('%.'..b..'fk',k/1e3) else k=string.format('%i',k) end return k end--加k 9.1

e.GetShowHide = function(sh)
	if sh then
		return '|cnGREEN_FONT_COLOR:'..SHOW..'|r'
	else
		return '|cnRED_FONT_COLOR:'..HIDE..'|r'
	end
end

e.GetEnabeleDisable = function (ed)--启用或禁用字符
  if ed then
    return '|cnGREEN_FONT_COLOR:'..ENABLE..'|r'
  else
    return '|cnRED_FONT_COLOR:'..DISABLE..'|r'
  end
end

e.WA_Utf8Sub = function(input, size)
    local output = ""
    if type(input) ~= "string" then
      return output
    end
    local i = 1
    while (size > 0) do
      local byte = input:byte(i)
      if not byte then
        return output
      end
      if byte < 128 then
        -- ASCII byte
        output = output .. input:sub(i, i)
        size = size - 1
      elseif byte < 192 then
        -- Continuation bytes
        output = output .. input:sub(i, i)
      elseif byte < 244 then
        -- Start bytes
        output = output .. input:sub(i, i)
        size = size - 1
      end
      i = i + 1
    end
    while (true) do
      local byte = input:byte(i)
      if byte and byte >= 128 and byte < 192 then
        output = output .. input:sub(i, i)
      else
        break
      end
      i = i + 1
    end
    return output
end

e.Cstr=function(self, size, fontType, ChangeFont, color)
  local b=ChangeFont or self:CreateFontString(nil, 'OVERLAY')
  if fontType then
    b:SetFont(fontType:GetFont())
    b:SetTextColor(fontType:GetTextColor())
    b:SetFontObject(fontType:GetFontObject())
    b:SetShadowColor(fontType:GetShadowColor())
    b:SetShadowOffset(fontType:GetShadowOffset())
  else
    b:SetFont('Fonts\\ARHei.ttf', size or 12, 'OUTLINE')
    b:SetShadowOffset(2, -2)
    --b:SetShadowColor(0, 0, 0)
    b:SetJustifyH('LEFT')
    if color then
      b:SetTextColor(color.r, color.g, color.b)
    else
      b:SetTextColor(1, 0.45, 0.04)
    end
  end
  return b
end

e.CeditBox= function(self, width, height)
  width = width or 400
  height= height or 400

  local editBox = CreateFrame("EditBox", nil, self)
  editBox:SetSize(width, height)
  editBox:SetAutoFocus(false)
  editBox:SetFontObject("ChatFontNormal")
  editBox:SetMultiLine(true)

  local tex=editBox:CreateTexture(nil, "BACKGROUND")
  tex:SetAtlas('_Adventures-Mission-Highlight-Mid')
  tex:SetAllPoints(editBox)
  return editBox
end

e.Cbtn= function(self, Template, value, SecureAction, name)
  local b
  if Template then
    b=CreateFrame('Button', name, self, 'UIPanelButtonTemplate')
  elseif SecureAction then
    b=CreateFrame("Button", name, self, "SecureActionButtonTemplate");
    b:SetHighlightAtlas(e.Icon.highlight)
    b:SetPushedAtlas(e.Icon.pushed)
  else
    b=CreateFrame('Button', name, self)
    b:SetHighlightAtlas(e.Icon.highlight)
    b:SetPushedAtlas(e.Icon.pushed)
    if value then
      b:SetNormalAtlas(e.Icon.icon)
    else
      b:SetNormalAtlas(e.Icon.disabled)
    end
  end
  b:RegisterForClicks("LeftButtonDown","RightButtonDown")
  return b
end

e.Ccool=function(self, start, duration, modRate, HideCountdownNumbers, Reverse)--冷却条
  if not self.cool then
    self.cool= CreateFrame("Cooldown", nil, self, 'CooldownFrameTemplate')
    self.cool:SetDrawEdge(true)
    if HideCountdownNumbers then
        self.cool:SetHideCountdownNumbers(true)
    end
    if Reverse then--控制冷却动画的方向
      self.cool:SetReverse(true)
    end
  end
  self.cool:SetCooldown(start, duration, modRate)
end

e.SetButtonKey = function(self, set, key, click)--设置清除快捷键
  if set then
    SetOverrideBindingClick(self, true, key, self:GetName(), click or 'LeftButton')
  else
    ClearOverrideBindings(self)
  end
end