local e= select(2, ...)

local Frame












local function Create_Texture(r,g,b,a, atlas)
	local texture= Frame:CreateTexture()
	texture:SetSize(23, 23)
	texture:EnableMouse(true)
	a=a or 1
	texture.r, texture.g, texture.b, texture.a= r, g, b, a
	texture:SetScript('OnMouseDown', function(self)
		WoWTools_ColorMixin:Set_Edit_Text(self.r, self.g, self.b, self.a, self.textCode)
		self:SetAlpha(0.1)
	end)
	texture:SetScript('OnMouseUp', function(self) self:SetAlpha(0.7) end)
	texture:SetScript('OnEnter', function(self)
		local col= '|c'..WoWTools_ColorMixin:RGBtoHEX(self.r, self.g, self.b, self.a)
		e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(col..WoWTools_Mixin.addName, col..WoWTools_ColorMixin.addName)
		if self.tooltip then
			e.tips:AddLine(' ')
			e.tips:AddLine(self.tooltip)
		end
		e.tips:AddDoubleLine(col..'r'..format('%.2f',self.r)..' g'..format('%.2f',self.g)..' b'..format('%.2f',self.b), col..'a'..(self.a and format('%.2f',self.a) or 1))
		e.tips:Show()
		self:SetAlpha(0.7)
	end)
	texture:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
	if atlas then
		texture:SetAtlas(atlas)
	else
		texture:SetColorTexture(r, g, b)
	end
	return texture
end



























local function Init()
    Frame= CreateFrame("Frame", 'WoWToolsColorPickerFramePlus', ColorPickerFrame)
    Frame:SetPoint('BOTTOMRIGHT')
    Frame:SetSize(1,1)

--右边
--职业 ColorUtil.lua
    local colorTab={}
    local size, x, y, n= 23, 0, -15, 1
    for className, col in pairs(RAID_CLASS_COLORS) do
        local text= col.r..col.g..col.b.. (col.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(col.r, col.g, col.b, col.a, WoWTools_UnitMixin:GetClassIcon(nil, className, true))
            texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
            local hex= col:GenerateHexColor()
            texture.tooltip= '|c'..hex..'RAID_CLASS_COLORS["'..className..'"]'
            if n==7 then
                n=0
                x= x+ size
                y= -15
            else
                y= y- size
            end
            n=n+1
        end
    end

--物品 UIParent.lua
    size, x, y, n= 16, x+size, -15, 0
    for index, col in pairs(ITEM_QUALITY_COLORS) do
        local text= col.r..col.g..col.b.. (col.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(col.r, col.g, col.b, col.a)
            texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
            texture.tooltip= col.hex..e.cn(_G["ITEM_QUALITY" .. index.. "_DESC"])..'|nITEM_QUALITY' ..index.. '_DESC'
            if n==10 then
                n=0
                x= x+ size
                y= -15
            else
                y= y- size
            end
            n=n+1
        end
    end

--SharedColorConstants.lua
    n=n+1
    for name, col in pairs(MATERIAL_TEXT_COLOR_TABLE) do
        local text= col.r..col.g..col.b.. (col.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(col.r, col.g, col.b, col.a)
            texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
            texture.tooltip= 'MATERIAL_TEXT_COLOR_TABLE'..'["'..name..'"]'
            if n==9 then
                n=0
                x= x+ size
                y= -15
            else
                y= y- size
            end
            n=n+1
        end
    end

--SharedColorConstants.lua
    for name, col in pairs(MATERIAL_TITLETEXT_COLOR_TABLE) do
        local text= col.r..col.g..col.b.. (col.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(col.r, col.g, col.b, col.a)
            texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
            texture.tooltip= 'MATERIAL_TITLETEXT_COLOR_TABLE'..'["'..name..'"]'
            if n==10 then
                n=0
                x= x+ size
                y= -15
            else
                y= y- size
            end
            n=n+1
        end
    end

--SharedColorConstants.lua
    for name, col in pairs(COVENANT_COLORS) do
        if type(name)~='number' then
            local text= col.r..col.g..col.b.. (col.a or 1)
            if not colorTab[text] then
            colorTab[text]= true
                local texture= Create_Texture(col.r, col.g, col.b, col.a)
                texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
                texture.tooltip= 'COVENANT_COLORS'..'["'..name..'"]'
                if n==10 then
                    n=0
                    x= x+ size
                    y= -15
                else
                    y= y- size
                end
                n=n+1
            end
        end
    end

--SharedColorConstants.lua
    for name, col in pairs(PLAYER_FACTION_COLORS) do
        local text= col.r..col.g..col.b.. (col.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(col.r, col.g, col.b, col.a)
            texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
            texture.tooltip= 'PLAYER_FACTION_COLORS'..'['..name..']'
            if n==10 then
                n=0
                x= x+ size
                y= -15
            else
                y= y- size
            end
            n=n+1
        end
    end





--上面
--Color.lua
    size, x, y, n= 16, -70, -3, 1
    local Y=0
    local DBColors = C_UIColor.GetColors() or {}
    table.sort(DBColors, function(a,b)
        return a.color.r> b.color.r
    end)
    for _, dbColor in ipairs(DBColors) do
        local text= dbColor.color.r.. dbColor.color.g.. dbColor.color.b.. (dbColor.color.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(dbColor.color.r, dbColor.color.g, dbColor.color.b, dbColor.color.a)
            texture.textCode= dbColor.baseTag
            texture:SetPoint('BOTTOMLEFT', ColorPickerFrame.Header, 'TOPLEFT', x, y)
            if n==20 then
                n=0
                y=y +size
                x=-70
                Y=Y+1
            else
                x=x +size
            end
            n=n+1
            if Y>5 then
                break
            end
        end
    end



    

--颜色 选择器2
	if WoWTools_ColorMixin.selectType2 then
		x, y, n= -102, y+3, 1
		for r=0, 1, 0.2 do
			for g=0, 1, 0.2 do
				for b=0, 1, 0.2 do
					local texture= Create_Texture(r, g, b)
					texture:SetPoint('BOTTOMLEFT', ColorPickerFrame.Header, 'TOPLEFT', x, y)
					if n==24 then
						n=0
						y=y +size
						x=-102
					else
						x=x +size
					end
					n=n+1
				end
			end
		end
	end
end













function WoWTools_ColorMixin:Init_SelectColor()
    Init()
end