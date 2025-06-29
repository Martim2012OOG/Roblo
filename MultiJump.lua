-- GUI com botão ON/OFF e Multi Jump funcional
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Criar GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Multi Jump"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

local onButton = Instance.new("TextButton", frame)
onButton.Text = "ON"
onButton.Size = UDim2.new(0.5, -5, 0, 40)
onButton.Position = UDim2.new(0, 5, 0, 50)
onButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
onButton.TextColor3 = Color3.fromRGB(255, 255, 255)
onButton.Font = Enum.Font.SourceSansBold
onButton.TextSize = 18

local offButton = Instance.new("TextButton", frame)
offButton.Text = "OFF"
offButton.Size = UDim2.new(0.5, -5, 0, 40)
offButton.Position = UDim2.new(0.5, 5, 0, 50)
offButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
offButton.TextColor3 = Color3.fromRGB(255, 255, 255)
offButton.Font = Enum.Font.SourceSansBold
offButton.TextSize = 18

-- Multi Jump Lógica
local enabled = false
local jumps = 0
local maxJumps = 9999999999999 -- valor alto = praticamente infinito
local jumpTick = tick()

humanoid.StateChanged:Connect(function(_, new)
	if new == Enum.HumanoidStateType.Landed then
		jumps = 0
	end
end)

UIS.JumpRequest:Connect(function()
	if enabled and jumps < maxJumps and tick() - jumpTick > 0.2 then
		jumpTick = tick()
		jumps += 1
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Botões
onButton.MouseButton1Click:Connect(function()
	enabled = true
end)

offButton.MouseButton1Click:Connect(function()
	enabled = false
end)

-- Atualizar se o personagem for resetado
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	jumps = 0
end)
