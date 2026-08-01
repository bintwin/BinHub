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
    return "rbxassetid://0"
end

function UILibrary:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "BinHUb"
    local ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    
    local ConfigFolder = "BinHUb_Configs"
    local ConfigFile = ConfigFolder .. "/" .. WindowName .. ".json"
    
    local ConfigData = {}
    
    -- Load Config
    if isfolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and type(result) == "table" then
            ConfigData = result
        end
    end
    
    local function SaveConfig()
        if writefile then
            writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
        end
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "BinHub_UI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    local toggleKeyName = ToggleKey.Name
    if ConfigData["Settings_ToggleKey"] then
        toggleKeyName = ConfigData["Settings_ToggleKey"]
    end
    
    local LucideIcons = {}
    pcall(function()
        local req = (syn and syn.request) or (http and http.request) or request
        if req then
            local res = req({Url = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/Icons.lua", Method = "GET"})
            if res.Success then
                for name, id in string.gmatch(res.Body, '%["lucide%-(.-)"%]%s*=%s*"([^"]+)"') do
                    LucideIcons[name] = id
                end
            end
        end
    end)

    local function GetIcon(name)
        if not name then return nil end
        if string.find(name, "rbxassetid") then return name end
        return LucideIcons[name] or ""
    end
    
    -- Global UI Toggle
    local toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode.Name == toggleKeyName then
            gui.Enabled = not gui.Enabled
        end
    end)
    
    local WindowConnections = {toggleConnection}
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = gui
    
    local UIStrokeMain = Instance.new("UIStroke")
    UIStrokeMain.Color = Color3.fromRGB(60, 60, 60)
    UIStrokeMain.Thickness = 1
    UIStrokeMain.Parent = MainFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local BgImage = Instance.new("ImageLabel")
    BgImage.Name = "MarbleBG"
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.BackgroundTransparency = 1
    BgImage.Image = getMarbleImage()
    BgImage.ImageTransparency = 0.88
    BgImage.ScaleType = Enum.ScaleType.Crop
    BgImage.Parent = MainFrame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 8)
    BgCorner.Parent = BgImage

    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame
    
    local TopbarLine = Instance.new("Frame")
    TopbarLine.Size = UDim2.new(1, 0, 0, 1)
    TopbarLine.Position = UDim2.new(0, 0, 1, -1)
    TopbarLine.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    TopbarLine.BorderSizePixel = 0
    TopbarLine.Parent = Topbar
    
    local dragging, dragInput, dragStart, startPos
    
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
    
    local dragConnection = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    table.insert(WindowConnections, dragConnection)
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = WindowName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar
    
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 16, 0, 16)
    CloseBtn.Position = UDim2.new(1, -25, 0.5, -8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = GetIcon("x")
    CloseBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.Parent = Topbar
    
    CloseBtn.MouseButton1Click:Connect(function()
        for _, conn in ipairs(WindowConnections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        local Mouse = game.Players.LocalPlayer:GetMouse()
        Mouse.Icon = ""
        gui:Destroy()
    end)
    
    CloseBtn.MouseEnter:Connect(function() CloseBtn.ImageColor3 = Color3.fromRGB(255, 255, 255) end)
    CloseBtn.MouseLeave:Connect(function() CloseBtn.ImageColor3 = Color3.fromRGB(200, 200, 200) end)

    local isMinimized = false
    local MinBtn = Instance.new("ImageButton")
    MinBtn.Name = "Minimize"
    MinBtn.Size = UDim2.new(0, 16, 0, 16)
    MinBtn.Position = UDim2.new(1, -50, 0.5, -8)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Image = GetIcon("minus")
    MinBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
    MinBtn.Parent = Topbar
    
    MinBtn.MouseEnter:Connect(function() MinBtn.ImageColor3 = Color3.fromRGB(255, 255, 255) end)
    MinBtn.MouseLeave:Connect(function() MinBtn.ImageColor3 = Color3.fromRGB(200, 200, 200) end)
    
    local ContentWrapper = Instance.new("Frame")
    ContentWrapper.Name = "ContentWrapper"
    ContentWrapper.Size = UDim2.new(1, 0, 1, -30)
    ContentWrapper.Position = UDim2.new(0, 0, 0, 30)
    ContentWrapper.BackgroundTransparency = 1
    ContentWrapper.Parent = MainFrame
    
    local preMinimizeSize = UDim2.new(0, 600, 0, 400)
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            preMinimizeSize = MainFrame.Size
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, preMinimizeSize.X.Offset, 0, 30)}):Play()
            ContentWrapper.Visible = false
        else
            ContentWrapper.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = preMinimizeSize}):Play()
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = ContentWrapper
    
    local Mouse = game.Players.LocalPlayer:GetMouse()
    local function createResizer(name, size, pos, cursorId, isHorizontal, isNegative)
        local Resizer = Instance.new("TextButton")
        Resizer.Name = name
        Resizer.Size = size
        Resizer.Position = pos
        Resizer.BackgroundTransparency = 1
        Resizer.Text = ""
        Resizer.ZIndex = 100
        Resizer.Parent = MainFrame
        
        local resizing = false
        local dragStartMouse = nil
        local dragStartSize = nil
        local dragStartPos = nil
        
        local downConn = Resizer.InputBegan:Connect(function(input)
            if not isMinimized and input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                dragStartMouse = UserInputService:GetMouseLocation()
                dragStartSize = MainFrame.Size
                dragStartPos = MainFrame.Position
            end
        end)
        
        local upConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and resizing then
                resizing = false
            end
        end)
        
        local moveConn = UserInputService.InputChanged:Connect(function(input)
            if not isMinimized and resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local currentMouse = UserInputService:GetMouseLocation()
                local delta = currentMouse - dragStartMouse
                
                if isHorizontal then
                    if isNegative then
                        local newWidth = math.max(400, dragStartSize.X.Offset - delta.X)
                        local diff = newWidth - dragStartSize.X.Offset
                        MainFrame.Size = UDim2.new(0, newWidth, 0, MainFrame.Size.Y.Offset)
                        MainFrame.Position = UDim2.new(0, dragStartPos.X.Offset - diff, 0, MainFrame.Position.Y.Offset)
                    else
                        local newWidth = math.max(400, dragStartSize.X.Offset + delta.X)
                        MainFrame.Size = UDim2.new(0, newWidth, 0, MainFrame.Size.Y.Offset)
                    end
                else
                    if isNegative then
                        local newHeight = math.max(300, dragStartSize.Y.Offset - delta.Y)
                        local diff = newHeight - dragStartSize.Y.Offset
                        MainFrame.Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, newHeight)
                        MainFrame.Position = UDim2.new(0, MainFrame.Position.X.Offset, 0, dragStartPos.Y.Offset - diff)
                    else
                        local newHeight = math.max(300, dragStartSize.Y.Offset + delta.Y)
                        MainFrame.Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, newHeight)
                    end
                end
            end
        end)
        
        table.insert(WindowConnections, downConn)
        table.insert(WindowConnections, upConn)
        table.insert(WindowConnections, moveConn)
    end
    
    createResizer("RightResize", UDim2.new(0, 5, 1, 0), UDim2.new(1, -5, 0, 0), "130851509084818", true, false)
    createResizer("LeftResize", UDim2.new(0, 5, 1, 0), UDim2.new(0, 0, 0, 0), "130851509084818", true, true)
    createResizer("BottomResize", UDim2.new(1, 0, 0, 5), UDim2.new(0, 0, 1, -5), "106139089446755", false, false)
    createResizer("TopResize", UDim2.new(1, 0, 0, 5), UDim2.new(0, 0, 0, 0), "106139089446755", false, true)
    
    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -50)
    TabContainer.Position = UDim2.new(0, 0, 0, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 10)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.VerticalAlignment = Enum.VerticalAlignment.Top
    TabList.Parent = TabContainer
    
    local CustomCursor = Instance.new("ImageLabel")
    CustomCursor.Size = UDim2.new(0, 32, 0, 32)
    CustomCursor.BackgroundTransparency = 1
    CustomCursor.ZIndex = 10000
    CustomCursor.Visible = false
    CustomCursor.Parent = gui
    
    local isDraggingAny = false
    
    local hoverCheckConn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = UserInputService:GetMouseLocation()
            local mx, my = pos.X, pos.Y
            
            local isCurrentlyResizing = false
            local activeCursor = nil
            
            -- Check if we are actively resizing right now
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                -- Need to determine which cursor to show based on what we are resizing
                -- Since resizing state is local to each resizer, we'll just evaluate it globally based on mouse position
            end
            
            -- Evaluate hover math
            if not isMinimized then
                local fx, fy = MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y
                local fw, fh = MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y
                local edge = 5
                
                if mx >= fx and mx <= fx + edge and my >= fy and my <= fy + fh then
                    activeCursor = "130851509084818"
                elseif mx >= fx + fw - edge and mx <= fx + fw and my >= fy and my <= fy + fh then
                    activeCursor = "130851509084818"
                elseif mx >= fx and mx <= fx + fw and my >= fy and my <= fy + edge then
                    activeCursor = "106139089446755"
                elseif mx >= fx and mx <= fx + fw and my >= fy + fh - edge and my <= fy + fh then
                    activeCursor = "106139089446755"
                end
            end
            
            if activeCursor then
                UserInputService.MouseIconEnabled = false
                
                if activeCursor == "106139089446755" then
                    CustomCursor.Image = "rbxassetid://130851509084818"
                    CustomCursor.Rotation = 90
                else
                    CustomCursor.Image = "rbxassetid://" .. activeCursor
                    CustomCursor.Rotation = 0
                end
                
                CustomCursor.Position = UDim2.new(0, mx - 16, 0, my - 16)
                CustomCursor.Visible = true
            else
                UserInputService.MouseIconEnabled = true
                CustomCursor.Visible = false
            end
        end
    end)
    table.insert(WindowConnections, hoverCheckConn)

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
    ProfileName.TextSize = 13
    ProfileName.Font = Enum.Font.GothamBold
    ProfileName.TextXAlignment = Enum.TextXAlignment.Left
    ProfileName.Parent = ProfileFrame
    
    local SubName = Instance.new("TextLabel")
    SubName.Size = UDim2.new(1, -50, 0, 15)
    SubName.Position = UDim2.new(0, 45, 0.5, 0)
    SubName.BackgroundTransparency = 1
    SubName.Text = "Lifetime"
    SubName.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubName.TextSize = 11
    SubName.Font = Enum.Font.GothamSemibold
    SubName.TextXAlignment = Enum.TextXAlignment.Left
    SubName.Parent = ProfileFrame

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -150, 1, 0)
    ContentArea.Position = UDim2.new(0, 150, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = ContentWrapper

    local WindowObj = {
        CurrentTab = nil,
        Tabs = {}
    }
    local firstTab = true
    
    function WindowObj:CreateTab(name, iconId)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.Size = UDim2.new(1, -20, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn
        
        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.FillDirection = Enum.FillDirection.Horizontal
        TabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        TabContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        TabContentLayout.Padding = UDim.new(0, 10)
        TabContentLayout.Parent = TabBtn
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 12)
        TabPadding.Parent = TabBtn

        local IconLabel = nil
        if iconId then
            IconLabel = Instance.new("ImageLabel")
            IconLabel.Size = UDim2.new(0, 16, 0, 16)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = GetIcon(iconId)
            IconLabel.ImageColor3 = Color3.fromRGB(150, 150, 150)
            IconLabel.Parent = TabBtn
        end

        local TabText = Instance.new("TextLabel")
        TabText.BackgroundTransparency = 1
        TabText.Size = UDim2.new(0, 0, 1, 0)
        TabText.AutomaticSize = Enum.AutomaticSize.X
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabText.Font = Enum.Font.Gotham
        TabText.TextSize = 13
        TabText.Parent = TabBtn
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 2
        TabContent.BorderSizePixel = 0
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 15)
        Padding.PaddingLeft = UDim.new(0, 15)
        Padding.PaddingRight = UDim.new(0, 15)
        Padding.PaddingBottom = UDim.new(0, 15)
        Padding.Parent = TabContent
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 10)
        ListLayout.Parent = TabContent
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, child in ipairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundTransparency = 1
                    local txt = child:FindFirstChildOfClass("TextLabel")
                    local img = child:FindFirstChildOfClass("ImageLabel")
                    if txt then txt.TextColor3 = Color3.fromRGB(150, 150, 150) end
                    if img then img.ImageColor3 = Color3.fromRGB(150, 150, 150) end
                end
            end
            for _, child in ipairs(ContentArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            TabBtn.BackgroundTransparency = 0.5
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            if IconLabel then IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255) end
            TabContent.Visible = true
            WindowObj.CurrentTab = name
        end)
        
        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= name then
                TabText.TextColor3 = Color3.fromRGB(220, 220, 220)
                if IconLabel then IconLabel.ImageColor3 = Color3.fromRGB(220, 220, 220) end
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= name then
                TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
                if IconLabel then IconLabel.ImageColor3 = Color3.fromRGB(150, 150, 150) end
            end
        end)
        
        if firstTab then
            TabBtn.BackgroundTransparency = 0.5
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            if IconLabel then IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255) end
            TabContent.Visible = true
            WindowObj.CurrentTab = name
            firstTab = false
        end
        
        TabContent.ChildAdded:Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
        end)
        
        local Elements = {}
        
        function Elements:CreateTextSection(text)
            local Section = Instance.new("TextLabel")
            Section.Size = UDim2.new(1, -6, 0, 20)
            Section.BackgroundTransparency = 1
            Section.Text = text
            Section.TextColor3 = Color3.fromRGB(255, 255, 255)
            Section.Font = Enum.Font.GothamBold
            Section.TextSize = 14
            Section.TextXAlignment = Enum.TextXAlignment.Left
            Section.Parent = TabContent
        end
        
        function Elements:CreateButton(name, callback)
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, -6, 0, 35)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Btn.Text = name
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 13
            Btn.Font = Enum.Font.Gotham
            Btn.Parent = ButtonFrame
            ButtonFrame.Parent = TabContent
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Btn
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(50, 50, 50)
            Stroke.Thickness = 1
            Stroke.Parent = Btn
            
            Btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end
        
        function Elements:CreateToggle(name, default, callback, flag)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -6, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ToggleFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = ToggleFrame
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(50, 50, 50)
            Stroke.Thickness = 1
            Stroke.Parent = ToggleFrame
            
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
            
            local state = default or false
            if flag and ConfigData[flag] ~= nil then
                state = ConfigData[flag]
            end
            
            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 20, 0, 20)
            Indicator.Position = UDim2.new(1, -30, 0.5, -10)
            Indicator.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
            Indicator.Parent = ToggleFrame
            
            local IndCorner = Instance.new("UICorner")
            IndCorner.CornerRadius = UDim.new(0, 4)
            IndCorner.Parent = Indicator
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = ToggleFrame
            
            local function fire()
                TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
                if flag then
                    ConfigData[flag] = state
                    SaveConfig()
                end
                if callback then callback(state) end
            end
            
            Btn.MouseButton1Click:Connect(function()
                state = not state
                fire()
            end)
            
            if state ~= default then
                if callback then callback(state) end
            end
        end

        function Elements:CreateDropdown(name, options, default, callback, flag)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, -6, 0, 35)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            DropdownFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = DropdownFrame
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(50, 50, 50)
            Stroke.Thickness = 1
            Stroke.Parent = DropdownFrame
            
            local currentVal = default
            if flag and ConfigData[flag] ~= nil then
                currentVal = ConfigData[flag]
            end
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name .. ": " .. (currentVal or "Select")
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            
            local open = false
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = DropdownFrame
            
            local ListFrame = Instance.new("Frame")
            ListFrame.Size = UDim2.new(1, 0, 0, #options * 30)
            ListFrame.Position = UDim2.new(0, 0, 1, 5)
            ListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            ListFrame.Visible = false
            ListFrame.ZIndex = 5
            ListFrame.Parent = DropdownFrame
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 6)
            ListCorner.Parent = ListFrame
            
            local ListStroke = Instance.new("UIStroke")
            ListStroke.Color = Color3.fromRGB(50, 50, 50)
            ListStroke.Thickness = 1
            ListStroke.Parent = ListFrame
            
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
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
                    if flag then
                        ConfigData[flag] = opt
                        SaveConfig()
                    end
                    if callback then callback(opt) end
                end)
            end
            
            Btn.MouseButton1Click:Connect(function()
                open = not open
                ListFrame.Visible = open
                if open then
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20 + (#options*30))
                else
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
                end
            end)
            
            if currentVal ~= default then
                if callback then callback(currentVal) end
            end
        end
        
        function Elements:CreateSlider(name, min, max, default, callback, flag)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -6, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            SliderFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = SliderFrame
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(50, 50, 50)
            Stroke.Thickness = 1
            Stroke.Parent = SliderFrame
            
            local currentVal = default
            if flag and ConfigData[flag] ~= nil then
                currentVal = ConfigData[flag]
            end
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 0, 25)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 25)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(currentVal)
            ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValueLabel.TextSize = 13
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -20, 0, 6)
            Track.Position = UDim2.new(0, 10, 0, 38)
            Track.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Track.Parent = SliderFrame
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((currentVal - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
            
            local sliderDragConnection = UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local rel = math.clamp((mousePos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(rel, 0, 1, 0)
                    local val = math.floor(min + (max - min) * rel)
                    ValueLabel.Text = tostring(val)
                    if flag then
                        ConfigData[flag] = val
                        SaveConfig()
                    end
                    if callback then callback(val) end
                end
            end)
            table.insert(WindowConnections, sliderDragConnection)
            
            if currentVal ~= default then
                if callback then callback(currentVal) end
            end
        end
        
        function Elements:CreateKeybind(name, defaultKey, callback, flag, onChangeCallback)
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Size = UDim2.new(1, -6, 0, 35)
            KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            KeyFrame.Parent = TabContent
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = KeyFrame
            
            local Stroke = Instance.new("UIStroke")
            Stroke.Color = Color3.fromRGB(50, 50, 50)
            Stroke.Thickness = 1
            Stroke.Parent = KeyFrame
            
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
            
            local currentKeyName = defaultKey.Name
            if flag and ConfigData[flag] ~= nil then
                currentKeyName = ConfigData[flag]
            end
            
            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 80, 0, 25)
            KeyBtn.Position = UDim2.new(1, -90, 0.5, -12.5)
            KeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            KeyBtn.Text = currentKeyName
            KeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            KeyBtn.TextSize = 12
            KeyBtn.Font = Enum.Font.Gotham
            KeyBtn.Parent = KeyFrame
            
            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 4)
            KeyCorner.Parent = KeyBtn
            
            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = Color3.fromRGB(50, 50, 50)
            KeyStroke.Thickness = 1
            KeyStroke.Parent = KeyBtn
            
            local listening = false
            
            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
            end)
            
            local keybindConnection = UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKeyName = input.KeyCode.Name
                    KeyBtn.Text = currentKeyName
                    if flag then
                        ConfigData[flag] = currentKeyName
                        SaveConfig()
                    end
                    listening = false
                    if onChangeCallback then onChangeCallback(currentKeyName) end
                elseif not listening and input.KeyCode.Name == currentKeyName then
                    if callback then callback() end
                end
            end)
            table.insert(WindowConnections, keybindConnection)
        end
        
        function WindowObj:SetToggleKey(keyName)
            toggleKeyName = keyName
        end
        
        return Elements
    end

    return WindowObj
end

return UILibrary
