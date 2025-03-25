
local function Save()
    return WoWToolsSave['Plus_Cursor']
end

local CursorFrame
local Pool, Used={}, {}
local maxParticles, duration, rotate, size, minDistance, egim, rate, randomTexture, gravity



--Cursor, 模块
local function Create_Particle()
    local part = Pool[#Pool]
    if part then
        Pool[#Pool] = nil
        Used[#Used + 1] = part
        part.life = duration
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        part.x = x / scale + Save().X
        part.y = y / scale + Save().Y
        if egim  < 0 then
            egim  = floor(egim  + 360)
        end
        egim  = floor(egim )
        part.a = - egim
        part.vx = 1
        part.vy = 1

        part.va = math.random(-rotate, rotate)
        part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
        part:Show()
    end
    return part
end

local function delete_Particle(part, index)
    part:Hide()
    Pool[#Pool + 1] = table.remove(Used, index)
end


local function update_Particle(part,  delta)
    part.life = part.life - delta

    if (part.life < 0) then
        return true
    end

    part.vy = part.vy - gravity * delta
    part.x = part.x + part.vx * delta
    part.y = part.y + part.vy * delta


    part.a = part.a + part.va + delta
    part:SetRotation(math.rad(part.a))


    local scale = math.max(0.1, part.life / duration)

    part:SetRotation(math.rad(part.a))
    part:SetSize(size * scale, size * scale)
    part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
end





local nowX, nowY = 0, 0
local Elapsed=1
local function OnUpdate(_, elapsed)
    Elapsed= Elapsed + elapsed
    if Elapsed> rate then
        Elapsed=0
        local oldX, oldY = nowX, nowY
        nowX, nowY = GetCursorPosition()

        local x = nowX - oldX
        local y = nowY - oldY

        if math.sqrt(x * x + y * y) > minDistance then
            egim  = atan2((nowX - oldX) ,  (nowY - oldY))
            Create_Particle()
        end

        for i = #Used, 1, -1 do
            if (update_Particle(Used[i], elapsed)) then
                delete_Particle( Used[i], i)
            end
        end
    end
end

































local function Set_Texture(self, atlas, texture, isInit)
    if atlas then
        self:SetAtlas(atlas)
    else
        self:SetTexture(texture)
    end
    if isInit then
        self:SetVertexColor(WoWTools_CursorMixin.Color.r, WoWTools_CursorMixin.Color.g, WoWTools_CursorMixin.Color.b, WoWTools_CursorMixin.Color.a)
        self:SetSize(size, size)
        self.life = 0
        self:SetAlpha(Save().alpha)
        self:Hide()
    end
end



local function Init_Texture(isInit)
    local atlasIndex= randomTexture and random(1, #(Save().Atlas)) or Save().atlasIndex

    local atlas, texture

    if WoWTools_TextureMixin:IsAtlas(Save().Atlas[atlasIndex]) then
        atlas= Save().Atlas[atlasIndex]
    else
        texture= Save().Atlas[atlasIndex]
    end
    if not atlas and not texture then
        atlas= WoWTools_CursorMixin.DefaultTexture
    end

    local max= math.max(#Pool+#Used, maxParticles)

    for i = 1, max do
        if not Pool[i] then
            Pool[i] = UIParent:CreateTexture()
            Pool[i]:SetBlendMode('ADD')
        end
        Set_Texture(Pool[i], atlas, texture, isInit)
    end

    for i=1, #Used do
        Set_Texture(Used[i], atlas, texture, isInit)
    end
end


local function Cursor_Settings()
    maxParticles= Save().maxParticles
    duration= Save().duration
    rotate= Save().rotate
    size= Save().size
    egim=0
    rate= Save().rate or 1
    randomTexture= Save().randomTexture
    minDistance=  Save().minDistance
    gravity= Save().gravity


--事件
    CursorFrame:UnregisterAllEvents()

    if Save().disabledCursor then
        for i = 1, #Pool do
            Pool[i]:Hide()
        end
        for i=1, #Used do
            Used[i]:Hide()
        end
        CursorFrame:SetShown(false)
        return


    elseif randomTexture then
        CursorFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
        CursorFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
        if UnitAffectingCombat('player') then
            CursorFrame:RegisterEvent('PLAYER_STARTED_MOVING')
            CursorFrame:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        else
            CursorFrame:RegisterEvent('GLOBAL_MOUSE_DOWN')
            CursorFrame:UnregisterEvent('PLAYER_STARTED_MOVING')
        end
    end

    do
        Init_Texture(true)
    end

    for i=math.max(#Pool+#Used, maxParticles)+1, #Pool, 1 do
        Pool[i]:Hide()
    end

    CursorFrame:SetShown(true)
end



--Cursor, 初始化
local function Init()
    if Save().disabledCursor then
        return
    end


    CursorFrame= CreateFrame('Frame', 'WoWToolsCursorFrame', UIParent)

    CursorFrame:SetScript('OnUpdate', OnUpdate)

    CursorFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_STARTED_MOVING' or event=='GLOBAL_MOUSE_DOWN' then
            Init_Texture(false)--初始，设置

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:RegisterEvent('PLAYER_STARTED_MOVING')
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
            self:UnregisterEvent('PLAYER_STARTED_MOVING')
        end
    end)

    Cursor_Settings()

    Init= function()
        Cursor_Settings()
    end
end







--初始, 设置, Cursor
function WoWTools_CursorMixin:Cursor_Settings()
    Init()
end





