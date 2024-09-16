--[[
CreateBackground(frame, tab)
]]

WoWTools_TextureMixin={}

local e= select(2, ...)

function WoWTools_TextureMixin:CreateBackground(frame, tab)
    if not frame.Background then
        tab= tab or {}
        
        local point= tab.point
        local isAllPoint= tab.isAllPoint
        local alpha= tab.alpha or 0.5

        frame.Background= frame:CreateTexture(nil, 'BACKGROUND')
        if isAllPoint==true then
            frame.Background:SetAllPoints()
        elseif type(point)=='function' then
            point(frame.Background)
        end

        frame.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
        frame.Background:SetAlpha(alpha or 0.5)
        frame.Background:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
    end
    return frame.Background
end
--[[
--显示背景 Background
WoWTools_TextureMixin:CreateBackground(frame, alpha)
]]






function WoWTools_TextureMixin:IsAtlas(texture)--Atlas or Texture
    local isAtlas, textureID, icon
    if texture and texture~='' then
        local t= type(texture)
        if t=='number' then
            if texture>0 then
                isAtlas, textureID, icon= false, texture, format('|T%d:0|t', texture)
            end
        elseif t=='string' then
            texture= texture:gsub(' ', '')
            if texture~='' then
                local atlasInfo= C_Texture.GetAtlasInfo(texture)
                isAtlas= atlasInfo and true or false
                textureID= texture
                icon= isAtlas and format('|A:%s:0:0|a', texture) or format('|T%s:0|t', texture)
            end
        end
    end
    return isAtlas, textureID, icon
end