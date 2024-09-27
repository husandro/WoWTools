
local function Save()
    return WoWTools_CursorMixin.Save
end


--Cursor, 模块
local create_Particle = function(self)
    local part = self.Pool[#self.Pool]
    if part then
        self.Pool[#self.Pool] = nil
        self.Used[#self.Used + 1] = part
        part.life = Save().duration
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        part.x = x / scale + Save().X
        part.y = y / scale + Save().Y
        if self.egim < 0 then
            self.egim = floor(self.egim + 360)
        end
        self.egim = floor(self.egim)
        part.a = - self.egim
        part.vx = 1
        part.vy = 1

        part.va = math.random(-(Save().rotate), Save().rotate)
        part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
        part:Show()
    end
    return part
end

local delete_Particle = function(self, part, index)
    part:Hide()
    self.Pool[#self.Pool + 1] = table.remove(self.Used, index)
end


local update_Particle = function(part,  delta)
    part.life = part.life - delta

    if (part.life < 0) then
        return true
    end

    part.vy = part.vy - Save().gravity * delta
    part.x = part.x + part.vx * delta
    part.y = part.y + part.vy * delta

    --if Save().rotate then
        part.a = part.a + part.va + delta
        part:SetRotation(math.rad(part.a))
    --end

    local scale = math.max(0.1, part.life / Save().duration)

    part:SetRotation(math.rad(part.a))
    part:SetSize(Save().size * scale, Save().size * scale)
    part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
end


local nowX, nowY = 0, 0
local set_Cursor_Update = function(self, elapsed)
    self.elapsed= (self.elapsed or Save().rate) + elapsed
    if self.elapsed> Save().rate then
        self.elapsed=0
        local oldX, oldY = nowX, nowY
        nowX, nowY = GetCursorPosition()

        local x = nowX - oldX
        local y = nowY - oldY

        if math.sqrt(x * x + y * y) > Save().minDistance then
            self.egim = atan2((nowX - oldX) ,  (nowY - oldY))
            create_Particle(self)
        end

        for i = #self.Used, 1, -1 do
            if (update_Particle(self.Used[i], elapsed)) then
                delete_Particle(self, self.Used[i], i)
            end
        end
    end
end



local function set_Cursor_Texture(self, atlas, texture, onlyRandomTexture)
    if atlas then
        self:SetAtlas(atlas)
    else
        self:SetTexture(texture)
    end

    if not Save().notUseColor then
        self:SetVertexColor(WoWTools_CursorMixin.Color.r, WoWTools_CursorMixin.Color.g, WoWTools_CursorMixin.Color.b, WoWTools_CursorMixin.Color.a)
    end

    if not onlyRandomTexture then
        self:SetSize(Save().size, Save().size)
        self.life = 0
        self:SetAlpha(Save().alpha)
        self:Hide()
    end
end
















--Cursor, 初始化
local function Init()
    Frame= CreateFrame('Frame')
    WoWTools_CursorMixin.CursorFrame= Frame

    Frame.egim=0
    WoWTools_CursorMixin:Cursor_Settings()
    Frame:SetScript('OnUpdate', set_Cursor_Update)

    WoWTools_CursorMixin:Cursor_SetEvent()--随机, 图片，事件

    Frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_STARTED_MOVING' or event=='GLOBAL_MOUSE_DOWN' then
            WoWTools_CursorMixin:Cursor_Settings(true)--初始，设置

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:RegisterEvent('PLAYER_STARTED_MOVING')
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
            self:UnregisterEvent('PLAYER_STARTED_MOVING')
        end
    end)
end












function WoWTools_CursorMixin:GetTextureType(texture)--取得格式, atlas 或 texture
    if texture then
         texture= strupper(texture)
         if not texture:find('ADDONS') then
             return true, '|A:'..texture..':0:0|a'
         else
             return false, '|T'..texture..':0|t'
         end
     end
 end






 function WoWTools_CursorMixin:Cursor_SetEvent()--随机, 图片，事件
    if not self.CursorFrame then
        return
    end
    if Save().randomTexture and not Save().disabled then
        self.CursorFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
        self.CursorFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
        if  UnitAffectingCombat('player') then
            self.CursorFrame:RegisterEvent('PLAYER_STARTED_MOVING')
            self.CursorFrame:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        else
            self.CursorFrame:RegisterEvent('GLOBAL_MOUSE_DOWN')
            self.CursorFrame:UnregisterEvent('PLAYER_STARTED_MOVING')
        end
    else
       self.CursorFrame:UnregisterAllEvents()
    end
end





--初始, 设置, Cursor
function WoWTools_CursorMixin:Cursor_Settings(onlyRandomTexture)
    if not self.CursorFrame then
        return
    end
    local atlasIndex= Save().randomTexture and random(1, #(Save().Atlas)) or Save().atlasIndex
    local atlas,texture
    if WoWTools_CursorMixin:GetTextureType(Save().Atlas[atlasIndex]) then
        atlas= Save().Atlas[atlasIndex]
    else
        texture= Save().Atlas[atlasIndex]
    end
    if not atlas and not texture then
        atlas= WoWTools_CursorMixin.DefaultTexture
    end

    local max= self.CursorFrame.Pool and #self.CursorFrame.Pool or Save().maxParticles
    self.CursorFrame.Pool = self.CursorFrame.Pool or {}
    for i = 1, max do
        if not self.CursorFrame.Pool[i] then
            self.CursorFrame.Pool[i] = UIParent:CreateTexture()
            self.CursorFrame.Pool[i]:SetBlendMode('ADD')
        end
        set_Cursor_Texture(self.CursorFrame.Pool[i], atlas, texture, onlyRandomTexture)
    end

    if self.CursorFrame.Used then
        for i=1, #self.CursorFrame.Used do
            set_Cursor_Texture(self.CursorFrame.Used[i], atlas, texture, onlyRandomTexture)
        end
    else
        self.CursorFrame.Used = {}
    end
end






function WoWTools_CursorMixin:Init_Cursor()
    Init()
end