local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local UILibrary = {}
UILibrary.__index = UILibrary

-- Utility to download and use the marble image
local function getMarbleImage()
    local url = "https://media.istockphoto.com/id/1206595316/photo/black-white-marble-oil-ink-liquid-swirl-texture-for-do-ceramic-counter-dark-abstract-light.jpg?s=612x612&w=0&k=20&c=dWNp830dceYPnyqTAFbnVNlyxcU8hzvLr4u1ux3O9M0="
    local filename = "marble_bg.jpg"
    
    if isfile and writefile and getcustomasset then
        if not isfile(filename) then
            local response = game:HttpGet(url)
            writefile(filename, response)
        end
        return getcustomasset(filename)
    end
    return "rbxassetid://0" -- Fallback if executor doesn't support custom assets
end

function UILibrary:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "BinHUb"
    
    local gui = Instance.new("ScreenGui")
    gui.Name = WindowName
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try to put in CoreGui to hide from game
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = gui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Background Marble Image
    local BgImage = Instance.new("ImageLabel")
    BgImage.Name = "MarbleBG"
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.BackgroundTransparency = 1
    BgImage.Image = getMarbleImage()
    BgImage.ImageTransparency = 0.85
    BgImage.ScaleType = Enum.ScaleType.Crop
    BgImage.Parent = MainFrame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 8)
    BgCorner.Parent = BgImage

    -- Topbar (Draggable)
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = WindowName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Topbar
    
    CloseBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 130, 1, -30)
    Sidebar.Position = UDim2.new(0, 0, 0, 30)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer
    
    -- Profile Section
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Name = "Profile"
    ProfileFrame.Size = UDim2.new(1, 0, 0, 50)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -50)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Sidebar
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 30, 0, 30)
    Avatar.Position = UDim2.new(0, 10, 0.5, -15)
    Avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. game.Players.LocalPlayer.UserId .. "&w=48&h=48"
    Avatar.Parent = ProfileFrame
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = Avatar
    
    local ProfileName = Instance.new("TextLabel")
    ProfileName.Size = UDim2.new(1, -50, 0, 15)
    ProfileName.Position = UDim2.new(0, 45, 0.5, -15)
    ProfileName.BackgroundTransparency = 1
    ProfileName.Text = string.sub(game.Players.LocalPlayer.Name, 1, 8) .. "..."
    ProfileName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProfileName.TextSize = 12
    ProfileName.Font = Enum.Font.GothamSemibold
    ProfileName.TextXAlignment = Enum.TextXAlignment.Left
    ProfileName.Parent = ProfileFrame
    
    local SubName = Instance.new("TextLabel")
    SubName.Size = UDim2.new(1, -50, 0, 15)
    SubName.Position = UDim2.new(0, 45, 0.5, 0)
    SubName.BackgroundTransparency = 1
    SubName.Text = "Lifetime"
    SubName.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubName.TextSize = 10
    SubName.Font = Enum.Font.Gotham
    SubName.TextXAlignment = Enum.TextXAlignment.Left
    SubName.Parent = ProfileFrame

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -130, 1, -30)
    ContentArea.Position = UDim2.new(0, 130, 0, 30)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }

    function Window:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 14
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.Parent = TabContainer
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 2
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent
        
        TabContent.ChildAdded:Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
                t.Content.Visible = false
            end
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = tabName
        end)
        
        local TabData = {
            Button = TabBtn,
            Content = TabContent
        }
        
        Window.Tabs[tabName] = TabData
        
        if not Window.CurrentTab then
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Window.CurrentTab = tabName
        end
        
        local Elements = {}
        
        function Elements:CreateTextSection(text)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, 0, 0, 20)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = text
            SectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            SectionLabel.TextSize = 14
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = TabContent
        end
        
        function Elements:CreateButton(name, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Btn.Text = name
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 13
            Btn.Font = Enum.Font.Gotham
            Btn.Parent = TabContent
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Btn
            
            Btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end
        
        function Elements:CreateToggle(name, default, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ToggleFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = ToggleFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 20, 0, 20)
            Indicator.Position = UDim2.new(1, -30, 0.5, -10)
            Indicator.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(50, 50, 50)
            Indicator.Parent = ToggleFrame
            
            local IndCorner = Instance.new("UICorner")
            IndCorner.CornerRadius = UDim.new(0, 4)
            IndCorner.Parent = Indicator
            
            local state = default or false
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = ToggleFrame
            
            Btn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(50, 50, 50)}):Play()
                if callback then callback(state) end
            end)
        end

        function Elements:CreateDropdown(name, options, default, callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 35)
            DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            DropFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = DropFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name .. ": " .. (default or "Select")
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropFrame
            
            local open = false
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = DropFrame
            
            local ListFrame = Instance.new("Frame")
            ListFrame.Size = UDim2.new(1, 0, 0, #options * 30)
            ListFrame.Position = UDim2.new(0, 0, 1, 5)
            ListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            ListFrame.Visible = false
            ListFrame.ZIndex = 5
            ListFrame.Parent = DropFrame
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 6)
            ListCorner.Parent = ListFrame
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = ListFrame
            
            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 30)
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = opt
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptBtn.TextSize = 13
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.ZIndex = 6
                OptBtn.Parent = ListFrame
                
                OptBtn.MouseButton1Click:Connect(function()
                    Label.Text = name .. ": " .. opt
                    open = false
                    ListFrame.Visible = false
                    if callback then callback(opt) end
                end)
            end
            
            Btn.MouseButton1Click:Connect(function()
                open = not open
                ListFrame.Visible = open
                if open then
                    -- adjust frame size for scroll container
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20 + (#options*30))
                else
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
                end
            end)
        end
        
        function Elements:CreateSlider(name, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            SliderFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = SliderFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValueLabel.TextSize = 13
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -20, 0, 6)
            Track.Position = UDim2.new(0, 10, 0, 35)
            Track.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Track.Parent = SliderFrame
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            Fill.Parent = Track
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Track
            
            local dragging = false
            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            Btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local rel = math.clamp((mousePos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(rel, 0, 1, 0)
                    local val = math.floor(min + (max - min) * rel)
                    ValueLabel.Text = tostring(val)
                    if callback then callback(val) end
                end
            end)
        end
        
        function Elements:CreateKeybind(name, defaultKey, callback)
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Size = UDim2.new(1, 0, 0, 35)
            KeyFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            KeyFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = KeyFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -100, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = KeyFrame
            
            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 80, 0, 25)
            KeyBtn.Position = UDim2.new(1, -90, 0.5, -12.5)
            KeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            KeyBtn.Text = defaultKey.Name
            KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            KeyBtn.TextSize = 12
            KeyBtn.Font = Enum.Font.Gotham
            KeyBtn.Parent = KeyFrame
            
            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 4)
            KeyCorner.Parent = KeyBtn
            
            local currentKey = defaultKey
            local listening = false
            
            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeyBtn.Text = currentKey.Name
                    listening = false
                elseif not listening and input.KeyCode == currentKey then
                    if callback then callback() end
                end
            end)
        end
        
        return Elements
    end

    return Window
end

return UILibrary
