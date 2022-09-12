local id, e = ...
--[[local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
    elseif event == "PLAYER_LOGOUT" then
    end
end)]]

e.col='|c'..select(4,GetClassColor(UnitClassBase('player')))

e.Icon={
    right='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
    left='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
    --mid='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',
    setHighlightAtlas='bags-newitem',
    setPushedAtlas='bags-glow-heirloom',
    normal='Lightlink-ball',
    gossip='transmog-icon-chat',--对话图标
    qest='campaignavailablequesticon',

}
e.Player={
  ser=GetRealmName(),
};

e.Cstr=function(f, str)
    local b=str or f:CreateFontString(nil, 'OVERLAY')
    b:SetFontObject('GameFontNormal')
    b:SetShadowOffset(2, -2)
    b:SetShadowColor(0, 0, 0)
    return b
end

e.Cbtn = function(self, s, texture)
    local b=CreateFrame("Button",nil, self)
    if s then
      b:SetSize(s, s)
    else
      b:SetAllPoints(self)
    end
    b:SetHighlightAtlas(e.Icon.setHighlightAtlas)
    b:SetPushedAtlas(e.Icon.setPushedAtlas)
    if texture then
    if C_Texture.GetAtlasInfo(texture) then
      b:SetNormalAtlas(texture)
    else
      b:SetNormalTexture(texture)
    end
  end
    return b
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
