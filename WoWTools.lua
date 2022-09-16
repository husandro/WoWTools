local id, e = ...

e.Icon={
  icon='orderhalltalents-done-glow',

  disabled='talents-button-reset',
  select='GarrMission_EncounterBar-CheckMark',--绿色√
  select2='Adventures-Checkmark',--黄色√

  right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
  left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
  mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',

  pushed='Forge-ColorSwatchHighlight',--移过时
  highlight='Forge-ColorSwatchSelection',--点击时

  transmogHide='|A:transmog-icon-hidden:0:0|a',--不可幻化
  okTransmog='|T132288:0|t',--可幻化
}

e.GetNpcID = function(unit)--NPC ID
  if UnitExists(unit) then
    local guid=UnitGUID(unit)
    if guid then
      return select(6,  strsplit("-", guid));
    end
  end
end

e.GetShowHide = function(sh)
	if sh then
		return '|cnGREEN_FONT_COLOR:'..SHOW..'|r/'..HIDE
	else
		return SHOW..'/|cnRED_FONT_COLOR:'..HIDE..'|r'
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

e.Cstr=function(self)
  local b=self:CreateFontString(nil, 'OVERLAY')
    b:SetFont('Fonts\\ARHei.ttf', 12, 'OUTLINE')
    b:SetShadowOffset(2, -2)
    --b:SetShadowColor(0, 0, 0)
    b:SetJustifyH('LEFT')
    b:SetTextColor(1, 0.45, 0.04)
    return b
end

e.CeditBotx= function(self, width, height)
  width = width or 400
  height=height or 400
  
  

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

e.Cbtn= function(self)
  local b=CreateFrame('Button', nil, self, 'UIPanelButtonTemplate')
  b:SetSize(80,28)
  return b
end
