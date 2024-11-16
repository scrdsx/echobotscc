local License = "KEYAUTH-hdA8vl-bBp5b3-V8R8zR-uIHgNw-KXiqFP-8B9InH" --* Your License to use this script.

print(' KeyAuth Lua Example - https://github.com/mazk5145/')
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LuaName = "KeyAuth Lua Example"

StarterGui:SetCore("SendNotification", {
	Title = LuaName,
	Text = "Intializing Authentication...",
	Duration = 5
})

--* Configuration *--
local initialized = false
local sessionid = ""


--* Application Details *--
Name = "Echobotscc" --* Application Name
Ownerid = "pIZcfcgqTd" --* OwnerID
APPVersion = "1.0"     --* Application Version

local req = game:HttpGet('https://keyauth.win/api/1.1/?name=' .. Name .. '&ownerid=' .. Ownerid .. '&type=init&ver=' .. APPVersion)

if req == "KeyAuth_Invalid" then 
   print(" Error: Application not found.")

   StarterGui:SetCore("SendNotification", {
	   Title = LuaName,
	   Text = " Error: Application not found.",
	   Duration = 3
   })

   return false
end

local data = HttpService:JSONDecode(req)

if data.success == true then
   initialized = true
   sessionid = data.sessionid
   --print(req)
elseif (data.message == "invalidver") then
   print(" Error: Wrong application version..")

   StarterGui:SetCore("SendNotification", {
	   Title = LuaName,
	   Text = " Error: Wrong application version..",
	   Duration = 3
   })

   return false
else
   print(" Error: " .. data.message)
   return false
end

print("\n\n Licensing... \n")
local req = game:HttpGet('https://keyauth.win/api/1.1/?name=' .. Name .. '&ownerid=' .. Ownerid .. '&type=license&key=' .. License ..'&ver=' .. APPVersion .. '&sessionid=' .. sessionid)
local data = HttpService:JSONDecode(req)


if data.success == false then 
    StarterGui:SetCore("SendNotification", {
	    Title = LuaName,
	    Text = " Error: " .. data.message,
	    Duration = 5
    })

    return false
end

StarterGui:SetCore("SendNotification", {
	Title = LuaName,
	Text = " Successfully Authorized :)",
	Duration = 5
})


--* Your code here *--

-- Create the ScreenGui for the Executor (same as before)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RequireExecutorGUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create a frame with smooth edges (movable)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 400, 0, 250) -- Adjust size as needed
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Set rounded corners for smooth edges
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20) -- 20 is the curve radius, adjust as needed
corner.Parent = frame

-- Create the TextBox for input
local textBox = Instance.new("TextBox")
textBox.Name = "ScriptInputBox"
textBox.Size = UDim2.new(0, 350, 0, 50)
textBox.Position = UDim2.new(0, 25, 0, 50)
textBox.PlaceholderText = "Enter require path here..."
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textBox.BorderSizePixel = 0
textBox.ClearTextOnFocus = false
textBox.TextScaled = true
textBox.Parent = frame

-- Create a label to show the result of the execution
local resultLabel = Instance.new("TextLabel")
resultLabel.Name = "ResultLabel"
resultLabel.Size = UDim2.new(0, 350, 0, 30)
resultLabel.Position = UDim2.new(0, 25, 0, 200)
resultLabel.Text = "Waiting for input..."
resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resultLabel.BackgroundTransparency = 1
resultLabel.TextScaled = true
resultLabel.Parent = frame

-- Create the TextButton to "Execute Require"
local executeButton = Instance.new("TextButton")
executeButton.Name = "ExecuteButton"
executeButton.Size = UDim2.new(0, 150, 0, 40)
executeButton.Position = UDim2.new(0, 125, 0, 150)
executeButton.Text = "Execute Require"
executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeButton.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
executeButton.BorderSizePixel = 0
executeButton.TextScaled = true
executeButton.Parent = frame

-- Make the frame movable
local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Function to execute the require command
local function executeRequire(modulePath)
    -- Try to require the module using the path
    local success, result = pcall(function()
        local module = game:GetService("ReplicatedStorage"):FindFirstChild(modulePath) or
                       game:GetService("ServerScriptService"):FindFirstChild(modulePath)
        if module and module:IsA("ModuleScript") then
            local moduleInstance = require(module)
            return moduleInstance
        else
            error("Module not found or invalid path.")
        end
    end)

    if success then
        resultLabel.Text = "Module executed successfully!"
        resultLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green text
    else
        resultLabel.Text = "Error: " .. result
        resultLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red text
    end
end

-- Function to handle button click for executing require
executeButton.MouseButton1Click:Connect(function()
    local modulePath = textBox.Text
    if modulePath ~= "" then
        executeRequire(modulePath)
    else
        resultLabel.Text = "Please enter a module path."
        resultLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Rejoin function (listens for the ,rejoin command in chat)
game.Players.LocalPlayer.Chatted:Connect(function(message)
    if message:lower() == ",rejoin" then
        -- Rejoin the game using TeleportService
        local teleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local player = game.Players.LocalPlayer
        teleportService:Teleport(placeId, player)
    end
end)