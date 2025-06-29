local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local savedPosition = nil
-- Criação da GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
local dragFrame = Instance.new("Frame")
dragFrame.Size = UDim2.new(0, 120, 0, 40) -- do tamanho de 2 teclas horizontais e 1 vertical
dragFrame.Position = UDim2.new(0, 100, 0, 100)
dragFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dragFrame.BackgroundTransparency = 0.2
dragFrame.BorderSizePixel = 0
dragFrame.Draggable = true
dragFrame.Active = true
dragFrame.Parent = screenGui
-- Botão "Set"
local setButton = Instance.new("TextButton")
setButton.Size = UDim2.new(0, 50, 1, 0)
setButton.Position = UDim2.new(0, 0, 0, 0)
setButton.Text = "Set"
setButton.TextColor3 = Color3.new(1,1,1)
setButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
setButton.Parent = dragFrame
-- Botão "To"
local toButton = Instance.new("TextButton")
toButton.Size = UDim2.new(0, 50, 1, 0)
toButton.Position = UDim2.new(0, 60, 0, 0)
toButton.Text = "To"
toButton.TextColor3 = Color3.new(1,1,1)
toButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toButton.Parent = dragFrame
-- Função para salvar posição
setButton.MouseButton1Click:Connect(function()
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		savedPosition = character.HumanoidRootPart.Position
		print("Posição salva:", savedPosition)
	end
end)
-- Função para teletransportar
toButton.MouseButton1Click:Connect(function()
	if savedPosition then
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(savedPosition)
			print("Teleportado para:", savedPosition)
		end
	end
end)
