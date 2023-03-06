local id, e= ...
local addName= MOUSE_LABEL-- = "鼠标"
local Save={
    texture1='Interface\\Addons\\WoWTools\\Sesource\\Mouse\\Aura121.tag',
    texture2='Interface\\Addons\\WoWTools\\Sesource\\Mouse\\Aura122.tag',
    texture3='Interface\\Addons\\WoWTools\\Sesource\\Mouse\\Aura123.tag',
    color={r=e.Player.r, g=e.Player.g, b= e.Player.b, a=1},
    blend_mode= 4,
    size=32,--8 64
    gravity=512, -- -512 512
    duration=0.4,--0.1 4
    frame_rate=60,--15 214
    rotate=15,-- 0 32

}
local panel= CreateFrame("Frame")

local max_particles = 1024
local min_distance = 3
local cursor_old_x, cursor_old_y = 0, 0
local cursor_now_x, cursor_now_y = 0, 0
local egim= 0

local blend_modes ={
    "DISABLE",
    "BLEND",
    "ALPHAKEY",
    "ADD",
    "MOD",
}

local create_Particle = function(self)
    if (#self.particles_pool < 1 ) then
        return
    end
    local part = self.particles_pool[#self.particles_pool]
    self.particles_pool[#self.particles_pool] = nil
    self.particles_used[#self.particles_used + 1] = part
    part.life = Save.duration
    local scale = UIParent:GetEffectiveScale()
    local x, y = GetCursorPosition()
    part.x = x / scale
    part.y = y / scale
    if egim < 0 then
        egim = floor(egim + 360)
    end
    egim = floor(egim)
    part.a = - egim
    part.vx = 1
    part.vy = 1

    local rot = Save.rotate
    part.va = math.random(-rot, rot)

    part:SetVertexColor(Save.color.r, Save.color.g, Save.color.b, Save.color.a)
    part:SetTexture(Save.texture1)
    part:SetBlendMode(blend_modes[Save.blend_mode])
    part:SetSize(Save.size, Save.size)
    part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
    part:Show()

    return part
end

local delete_Particle = function(self, part, index)
    part:Hide()
    self.particles_pool[#self.particles_pool + 1] = table.remove(self.particles_used, index)
end

local update_Particle = function(self, part, index, delta)
    part.life = part.life - delta

    if (part.life < 0) then
        return true
    end
--[[
    if (self.config["rainbow"]) then
        local index2 = math.floor(part.life / self.config["duration"] * #rainbow_colors)
        local color = rainbow_colors[index2 + 1]
        part:SetVertexColor(color[1], color[2], color[3], color[4])
    end]]

    part.vy = part.vy - Save.gravity * delta
    part.x = part.x + part.vx * delta
    part.y = part.y + part.vy * delta

    if Save.rotate then
        part.a = part.a + part.va + delta
        part:SetRotation(math.rad(part.a))
    end

    local size_scale = math.max(0.1, part.life / Save.duration)

    part:SetRotation(math.rad(part.a))
    part:SetSize(Save.size * size_scale, Save.size * size_scale)
    part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
end

local get_Time = function(self)
    local time= GetTime()
    if (self.time_start == nil) then
        self.time_start = time
    end
    return time - self.time_start
end

local set_Update = function(self)
    local now = get_Time(self)
    local delta = now - (self.time_old or 0)
    self.time_old = now

    self.accumulator = (self.accumulator or 0) + delta

    local rate = 1.0 / Save.frame_rate

    if (self.accumulator >= rate) then
        self.accumulator = 0

        cursor_old_x, cursor_old_y = cursor_now_x, cursor_now_y
        cursor_now_x, cursor_now_y = GetCursorPosition()

        local x = cursor_now_x - cursor_old_x
        local y = cursor_now_y - cursor_old_y
        local m = math.sqrt(x * x + y * y)
        local d = min_distance

        if (m > d) then
            egim = atan2((cursor_now_x - cursor_old_x) ,  (cursor_now_y - cursor_old_y))

            create_Particle(self)
        end

        for i = #self.particles_used, 1, -1 do
            if (update_Particle(self, self.particles_used[i], i, delta)) then
                delete_Particle(self, self.particles_used[i], i)
            end
        end
    end
end

local function frame_Inst(self)
    self.particles_pool = {}
    self.particles_used = {}
    for i = 1, max_particles, 1 do
        self.particles_pool[i] = UIParent:CreateTexture(nil, "BACKGROUND", nil, -8)
        self.particles_pool[i]:SetTexture(Save.texture1)
        self.particles_pool[i]:SetBlendMode("ADD")
        self.particles_pool[i]:SetSize(32, 32)
        self.particles_pool[i].life = 0
        self.particles_pool[i]:Hide()
    end
end

--#####
--初始化
--#####
local function Init()
    frame_Inst(panel)
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            if not Save.disabled then
                Init()
                panel:SetScript('OnUpdate', set_Update)
            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent("PLAYER_LOGOUT")
        end
    end
end)