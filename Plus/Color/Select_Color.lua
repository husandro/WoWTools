
local size= 23






local function Set_Color(r, g, b, a)--, textCode)
    if r and g and b then
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
        ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1)
    end
end









local function Create_Texture(r,g,b,a, atlas)
	local texture= _G['WoWToolsColorPickerFrameButton'].frame:CreateTexture()
	texture:SetSize(size, size)
	texture:EnableMouse(true)

    a=a or 1
	texture.r, texture.g, texture.b, texture.a= r, g, b, a

	texture:SetScript('OnMouseDown', function(self, d)
        if d~=self.notClick then
		    Set_Color(self.r, self.g, self.b, 1)--, self.textCode)
        end
		self:SetAlpha(0.1)
	end)

	texture:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.7)
    end)
	texture:SetScript('OnEnter', function(self)
		local col= '|c'..WoWTools_ColorMixin:RGBtoHEX(self.r or 1, self.g or 1, self.b or 1, self.a or 1)
		GameTooltip:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(col..WoWTools_DataMixin.addName, col..WoWTools_ColorMixin.addName)

		GameTooltip:AddDoubleLine(
            '|cffff4800r|r|cffffffff=|r'..tonumber(format('%.2f',self.r))
            ..'  |cff00ff00g|r|cffffffff=|r'..tonumber(format('%.2f',self.g))
            ..'  |cff0000ffb|r|cffffffff=|r'..tonumber(format('%.2f',self.b)),

            'a'..(self.a and tonumber(format('%.2f',self.a) or 1))
            ..(self.a and self.a<1 and '|cnGREEN_FONT_COLOR: / 1|r' or '')
        )
        if self.textCode then
            GameTooltip:AddLine(self.textCode)
        end
        if self.tooltip then
            if type(self.tooltip)=='function' then
                self.tooltip(self)
            else
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine(self.tooltip)
            end
		end
		GameTooltip:Show()
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


--右边
--职业 ColorUtil.lua
    local colorTab={}
    local x, y, n= 0, -22, 1
    for index = 1, GetNumClasses() do
        if (index == 10) and (GetClassicExpansionLevel() <= LE_EXPANSION_CATACLYSM) then
            -- We have an annoying gap between warlock and druid
            index = 11
        end
        local classFile = select(2, GetClassInfo(index))
        if classFile then
            local r, g, b= GetClassColor(classFile)
            if r and g and b then

                colorTab[r..g..b..'1']= true

                local texture= Create_Texture(
                    r,g,b,1,
                    WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile, {reAtlas=true})
                )
                texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)

                if RAID_CLASS_COLORS[classFile] then
                    texture.tooltip= 'RAID_CLASS_COLORS["'..classFile..'"]'
                end

                if n==7 then
                    n=0
                    x= x+ size
                    y= -22
                else
                    y= y- size
                end
                n=n+1
            end
        end
    end

--物品 UIParent.lua
    size, x, y, n= 16, x+size, -32, 0

    for index = 0, Enum.ItemQualityMeta.NumValues - 1 do
        local r,g,b= WoWTools_ItemMixin:GetColor(index)
        colorTab[r..g..b..1]= true
        local texture= Create_Texture(r,g,b,1)
        texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
        texture.tooltip= (WoWTools_ItemMixin.QualityText[index] or '')..'|nITEM_QUALITY' ..index.. '_DESC'
        texture.quality= index

        texture:SetScript('OnShow', function(self)
            WoWTools_ItemMixin:GetColor(self.quality, {texture=self})
        end)

        y= y- size
    end

--SharedColorConstants.lua
    size, x, y, n= 16, x+size, -15, 0
    for name, col in pairs(MATERIAL_TEXT_COLOR_TABLE) do
        local text= col.r..col.g..col.b.. (col.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(col.r, col.g, col.b, col.a)
            texture:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', x, y)
            texture.tooltip= 'MATERIAL_TEXT_COLOR_TABLE'..'["'..name..'"]'

            y= y- size
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
    size, x, y, n= 16, -88, -3, 1
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
                x=-88
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
	if WoWToolsSave['Plus_Color'].selectType2 then
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

    colorTab=nil
    Init=function()end
end













function WoWTools_ColorMixin:Init_SelectColor()
    Init()
end




function WoWTools_ColorMixin:Create_Texture(...)
    return Create_Texture(...)
end












