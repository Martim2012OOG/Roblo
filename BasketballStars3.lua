-- Serviços
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variáveis de controle
local guiEnabled = false
local ballRadius = 8
local savedRadius = ballRadius
local searchDistance = 25
local assistRadius = 3
local velocityForce = 25
local maxCooldown = 5
local minCooldown = 1
local visualBalls = {}
local hitCooldown = {}
local playerNearBall = false
local goalParts = {}
local lastScan = 0
local scanInterval = 5
local charRoot
local lastUpdate = 0
local updateInterval = 0.1

-- Interface (GUI)
local gui = Instance.new("ScreenGui")
gui.Name = "GuidanceUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 30)
toggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleButton.Text = "Enable Guidance"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.TextSize = 14
toggleButton.Parent = frame

local corner2 = Instance.new("UICorner", toggleButton)
corner2.CornerRadius = UDim.new(0, 6)

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0.9, 0, 0, 20)
radiusLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
radiusLabel.Text = "Radius: " .. ballRadius
radiusLabel.TextColor3 = Color3.new(1, 1, 1)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Font = Enum.Font.Gotham
radiusLabel.TextSize = 14
radiusLabel.Parent = frame

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(0.9, 0, 0, 30)
radiusBox.Position = UDim2.new(0.05, 0, 0.6, 0)
radiusBox.Text = tostring(ballRadius)
radiusBox.TextColor3 = Color3.new(1, 1, 1)
radiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 14
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = frame

local corner3 = Instance.new("UICorner", radiusBox)
corner3.CornerRadius = UDim.new(0, 6)

-- Funções auxiliares

local function scanGoals()
    goalParts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Goal" then
            table.insert(goalParts, obj)
        end
    end
    lastScan = tick()
    return goalParts
end

local function clearVisuals()
    for _, v in ipairs(visualBalls) do
        if v and v.Parent then
            v:Destroy()
        end
    end
    table.clear(visualBalls)
end

local function createVisualMarkers()
    clearVisuals()
    if not guiEnabled then return end

    local goals = (tick() - lastScan > scanInterval) and scanGoals() or goalParts

    for _, goal in ipairs(goals) do
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Ball
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.8
        part.Color = Color3.new(1, 0, 0)
        part.Material = Enum.Material.Neon
        part.Size = Vector3.new(ballRadius * 2, ballRadius * 2, ballRadius * 2)
        part.Position = goal.Position
        part.Name = "GoalVisualSphere"
        part.Parent = Workspace
        table.insert(visualBalls, part)
    end
end

local function removeForces(part)
    for _, v in ipairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") then
            v:Destroy()
        end
    end
end

local function assistToGoal()
    local now = tick()
    if now - lastUpdate < updateInterval then return end
    lastUpdate = now

    if not charRoot or not charRoot.Parent then
        if LocalPlayer.Character then
            charRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        if not charRoot then return end
    end

    local goals = (tick() - lastScan > scanInterval) and scanGoals() or goalParts
    local foundAnyBall = false

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" then
            foundAnyBall = true

            if hitCooldown[obj] and tick() < hitCooldown[obj] then continue end

            for _, goal in ipairs(goals) do
                local goalPos = goal.Position + Vector3.new(0, 1, 0)
                if (obj.Position - goalPos).Magnitude < ballRadius then
                    local dir = (goalPos - obj.Position).Unit

                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = dir * velocityForce
                    bv.MaxForce = Vector3.new(4000, 4000, 4000)
                    bv.P = 1000
                    bv.Parent = obj

                    task.delay(math.clamp(ballRadius * 0.025, 0.1, 0.4), function()
                        removeForces(obj)
                    end)

                    hitCooldown[obj] = tick() + math.clamp(ballRadius * 0.375, minCooldown, maxCooldown)
                    break
                end
            end
        end
    end

    if not foundAnyBall then
        table.clear(hitCooldown)
    end
end

-- Loop principal
RunService.Heartbeat:Connect(function()
    if not guiEnabled then return end

    if not charRoot or not charRoot.Parent then
        if LocalPlayer.Character then
            charRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        if not charRoot then return end
    end

    local nearestGoal
    local goals = (tick() - lastScan > scanInterval) and scanGoals() or goalParts
    local minDist = searchDistance

    for _, goal in ipairs(goals) do
        local dist = (charRoot.Position - goal.Position).Magnitude
        if dist < minDist then
            nearestGoal = goal
            minDist = dist
        end
    end

    if nearestGoal and not playerNearBall then
        playerNearBall = true
        savedRadius = ballRadius
        ballRadius = assistRadius
        radiusLabel.Text = "Radius: " .. ballRadius
        radiusBox.Text = tostring(ballRadius)
        createVisualMarkers()
    elseif not nearestGoal and playerNearBall then
        playerNearBall = false
        ballRadius = savedRadius
        radiusLabel.Text = "Radius: " .. ballRadius
        radiusBox.Text = tostring(ballRadius)
        createVisualMarkers()
    end

    assistToGoal()
end)

-- GUI Interações

toggleButton.MouseButton1Click:Connect(function()
    guiEnabled = not guiEnabled
    toggleButton.Text = guiEnabled and "Disable Guidance" or "Enable Guidance"
    createVisualMarkers()
end)

radiusBox.FocusLost:Connect(function()
    local newRadius = tonumber(radiusBox.Text)
    if newRadius and newRadius > 0 then
        ballRadius = newRadius
        savedRadius = newRadius
        radiusLabel.Text = "Radius: " .. ballRadius
        radiusBox.Text = tostring(ballRadius)
        createVisualMarkers()
    else
        radiusBox.Text = tostring(ballRadius)
    end
end)

-- Inicializa busca
scanGoals()
