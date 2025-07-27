
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local gui = Instance.new("ScreenGui")
gui.Name = "GhostModeGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "ActivateGhost"
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 20
button.Text = "Enable Ghost Mode"
button.Parent = gui
button.Active = true
button.Selectable = false

local dragging = false
local dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    button.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(0, 220, 0, 220)
controlsFrame.Position = UDim2.new(0, 20, 1, -240)
controlsFrame.BackgroundTransparency = 0.5
controlsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
controlsFrame.Visible = false
controlsFrame.Parent = gui

local function createButton(name, pos, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 30
    btn.Text = text
    btn.AutoButtonColor = true
    btn.Parent = controlsFrame
    return btn
end

local btnUp = createButton("Up", UDim2.new(0, 80, 0, 0), "↑")
local btnDown = createButton("Down", UDim2.new(0, 80, 0, 140), "↓")
local btnLeft = createButton("Left", UDim2.new(0, 0, 0, 70), "←")
local btnRight = createButton("Right", UDim2.new(0, 160, 0, 70), "→")

local moveDirection = Vector3.new()
local speed = 50
local hrp = nil
local humanoid = nil

local function setDirection(dir)
    if dir == "Up" then
        moveDirection = Vector3.new(0, 0, -1)
    elseif dir == "Down" then
        moveDirection = Vector3.new(0, 0, 1)
    elseif dir == "Left" then
        moveDirection = Vector3.new(-1, 0, 0)
    elseif dir == "Right" then
        moveDirection = Vector3.new(1, 0, 0)
    end
end

local function clearDirection()
    moveDirection = Vector3.new()
end

btnUp.TouchStarted:Connect(function() setDirection("Up") end)
btnUp.TouchEnded:Connect(clearDirection)
btnDown.TouchStarted:Connect(function() setDirection("Down") end)
btnDown.TouchEnded:Connect(clearDirection)
btnLeft.TouchStarted:Connect(function() setDirection("Left") end)
btnLeft.TouchEnded:Connect(clearDirection)
btnRight.TouchStarted:Connect(function() setDirection("Right") end)
btnRight.TouchEnded:Connect(clearDirection)

RunService.Heartbeat:Connect(function()
    if isMobile and hrp then
        local cam = workspace.CurrentCamera
        local move = cam.CFrame:VectorToWorldSpace(moveDirection)
        hrp.Velocity = move * speed
    end
end)

local function waitForCharacter()
    while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChildOfClass("Humanoid") do
        task.wait()
    end
    return player.Character
end

local function activateGhost()
    local character = waitForCharacter()
    humanoid = character:FindFirstChildOfClass("Humanoid")
    hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then
        warn("Humanoid or HumanoidRootPart missing")
        return
    end

    humanoid.Health = 0
    workspace.CurrentCamera.CameraSubject = hrp
    controlsFrame.Visible = true
end

button.MouseButton1Click:Connect(function()
    if isMobile then
        activateGhost()
    else
        button.Text = "Mobile Only!"
        task.wait(2)
        button.Text = "Enable Ghost Mode"
    end
end)
Add ghostmode script
