local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library

-- Exactly matched color palette from Image 5 reference
local Theme = {
    MainBg = Color3.fromRGB(14, 14, 18),      -- Darkest background (Sidebar & Main content)
    CardBg = Color3.fromRGB(19, 19, 24),      -- Slightly lighter for Cards
    BottomBarBg = Color3.fromRGB(16, 16, 20), -- Footer background
    ActiveBg = Color3.fromRGB(28, 28, 34),    -- Active tabs and sidebar buttons
    Accent = Color3.fromRGB(139, 122, 227),   -- Accurate Nebula purple
    Text = Color3.fromRGB(235, 235, 239),     -- Main text
    SubText = Color3.fromRGB(143, 143, 153),  -- Secondary text
    DisabledText = Color3.fromRGB(96, 96, 107),-- Inactive tabs
    CategoryText = Color3.fromRGB(74, 74, 85),-- "General" sidebar headers
    Border = Color3.fromRGB(28, 28, 34),      -- Separator lines
    InputBg = Color3.fromRGB(32, 32, 38),     -- Flat color for unchecked boxes/dropdowns
    InputOutline = Color3.fromRGB(60, 60, 70) -- Outline for unchecked inputs
}

local Icons = {
    Sidebar = "rbxassetid://7733799275", -- Reply/Arrow left
    User = "rbxassetid://14753064483",   -- Solid User Circle (Closest to reference)
    Check = "rbxassetid://7733779610",   
    Dropdown = "rbxassetid://7733765103",
    Settings = "rbxassetid://7734053495"
}

function Library:CreateWindow(options)
    options = options or {}
    local TitleFirst = options.TitleFirst or "nebula"
    local TitleSecond = options.TitleSecond or "tech"
    local FooterLeft = options.FooterLeft or "Milenium for Counter-Strike: Global Offensive"
    local FooterRight = options.FooterRight or "nebulatech"
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "BinHubV2"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    local success, _ = pcall(function() gui.Parent = CoreGui end)
    if not success then
        gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 720, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = gui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local Shadow = Instance.new("UIShadow")
    Shadow.BlurRadius = UDim.new(0, 12)
    Shadow.Color = Color3.fromRGB(0, 0, 0)
    Shadow.Offset = Vector2.new(0, 4)
    Shadow.Transparency = 0.5
    Shadow.Parent = MainFrame
    
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Restored Bottom Bar with accurate darker grey color and top border line
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, 0, 0, 32)
    BottomBar.Position = UDim2.new(0, 0, 1, -32)
    BottomBar.BackgroundColor3 = Theme.BottomBarBg
    BottomBar.BorderSizePixel = 0
    BottomBar.Parent = MainFrame
    
    local BottomCorner = Instance.new("UICorner")
    BottomCorner.CornerRadius = UDim.new(0, 8)
    BottomCorner.Parent = BottomBar
    
    local BottomCover = Instance.new("Frame")
    BottomCover.Size = UDim2.new(1, 0, 0, 10)
    BottomCover.Position = UDim2.new(0, 0, 0, 0)
    BottomCover.BackgroundColor3 = Theme.BottomBarBg
    BottomCover.BorderSizePixel = 0
    BottomCover.Parent = BottomBar
    
    local BottomBorder = Instance.new("Frame")
    BottomBorder.Size = UDim2.new(1, 0, 0, 1)
    BottomBorder.Position = UDim2.new(0, 0, 0, 0)
    BottomBorder.BackgroundColor3 = Theme.Border
    BottomBorder.BorderSizePixel = 0
    BottomBorder.Parent = BottomBar
    
    local LeftFooterText = Instance.new("TextLabel")
    LeftFooterText.Size = UDim2.new(0.5, -15, 1, 0)
    LeftFooterText.Position = UDim2.new(0, 15, 0, 0)
    LeftFooterText.BackgroundTransparency = 1
    LeftFooterText.Text = FooterLeft
    LeftFooterText.TextColor3 = Theme.DisabledText
    LeftFooterText.Font = Enum.Font.GothamMedium
    LeftFooterText.TextSize = 11
    LeftFooterText.TextXAlignment = Enum.TextXAlignment.Left
    LeftFooterText.Parent = BottomBar
    
    local RightFooterText = Instance.new("TextLabel")
    RightFooterText.Size = UDim2.new(0.5, -15, 1, 0)
    RightFooterText.Position = UDim2.new(0.5, 0, 0, 0)
    RightFooterText.BackgroundTransparency = 1
    RightFooterText.RichText = true
    RightFooterText.Text = "32 days left, <font color=\"rgb(139,122,227)\"><b>" .. FooterRight .. "</b></font>" -- Made nebulatech noticeably bolder in footer
    RightFooterText.TextColor3 = Theme.DisabledText
    RightFooterText.Font = Enum.Font.GothamMedium
    RightFooterText.TextSize = 11
    RightFooterText.TextXAlignment = Enum.TextXAlignment.Right
    RightFooterText.Parent = BottomBar
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, -32)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame
    
    local SidebarBorder = Instance.new("Frame")
    SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    SidebarBorder.BackgroundColor3 = Theme.Border
    SidebarBorder.BorderSizePixel = 0
    SidebarBorder.Parent = Sidebar
    
    local TitleArea = Instance.new("Frame")
    TitleArea.Size = UDim2.new(1, 0, 0, 65)
    TitleArea.BackgroundTransparency = 1
    TitleArea.Parent = Sidebar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.RichText = true
    TitleLabel.Text = "<font color=\"rgb(139,122,227)\">" .. TitleFirst .. "</font>" .. TitleSecond
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold -- Restored to GothamBold for precise match, GothamBlack was too thick
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleArea
    
    -- Explicity removed the underline from the title as requested by the user.
    
    local CategoryContainer = Instance.new("ScrollingFrame")
    CategoryContainer.Name = "Categories"
    CategoryContainer.Size = UDim2.new(1, 0, 1, -65)
    CategoryContainer.Position = UDim2.new(0, 0, 0, 65)
    CategoryContainer.BackgroundTransparency = 1
    CategoryContainer.ScrollBarThickness = 0
    CategoryContainer.Parent = Sidebar
    
    local CategoryListLayout = Instance.new("UIListLayout")
    CategoryListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CategoryListLayout.Padding = UDim.new(0, 4)
    CategoryListLayout.Parent = CategoryContainer
    
    local CategoryPadding = Instance.new("UIPadding")
    CategoryPadding.PaddingLeft = UDim.new(0, 15)
    CategoryPadding.PaddingRight = UDim.new(0, 15)
    CategoryPadding.Parent = CategoryContainer
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -180, 1, -32)
    ContentContainer.Position = UDim2.new(0, 180, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    local PopupContainer = Instance.new("Frame")
    PopupContainer.Name = "PopupContainer"
    PopupContainer.Size = UDim2.new(1, 0, 1, 0)
    PopupContainer.BackgroundTransparency = 1
    PopupContainer.ZIndex = 100
    PopupContainer.Visible = false
    PopupContainer.Parent = MainFrame
    
    local WindowObj = {
        Gui = gui,
        CategoryContainer = CategoryContainer,
        ContentContainer = ContentContainer,
        PopupContainer = PopupContainer,
        Categories = {}
    }
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            gui.Enabled = not gui.Enabled
        end
    end)
    
    function WindowObj:CreateCategory(options)
        options = options or {}
        local Name = options.Name or "Category"
        local Icon = options.Icon or Icons.Sidebar
        local SectionTitle = options.Section or "General"
        
        local hasSectionLabel = false
        for _, child in pairs(CategoryContainer:GetChildren()) do
            if child:IsA("TextLabel") and child.Text == SectionTitle then hasSectionLabel = true end
        end
        if not hasSectionLabel then
            local secLabel = Instance.new("TextLabel")
            secLabel.Size = UDim2.new(1, 0, 0, 26)
            secLabel.BackgroundTransparency = 1
            secLabel.Text = SectionTitle
            secLabel.TextColor3 = Theme.CategoryText -- Darker grey color
            secLabel.Font = Enum.Font.GothamBold     -- Noticeably bolder as requested
            secLabel.TextSize = 11
            secLabel.TextXAlignment = Enum.TextXAlignment.Left
            secLabel.Parent = CategoryContainer
        end
        
        local CategoryBtn = Instance.new("TextButton")
        CategoryBtn.Size = UDim2.new(1, 0, 0, 34)
        CategoryBtn.BackgroundColor3 = Theme.ActiveBg
        CategoryBtn.BackgroundTransparency = 1
        CategoryBtn.Text = ""
        CategoryBtn.Parent = self.CategoryContainer
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = CategoryBtn
        
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 14, 0, 14)
        IconImg.Position = UDim2.new(0, 12, 0.5, -7)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = Icon
        IconImg.ImageColor3 = Theme.DisabledText
        IconImg.Parent = CategoryBtn
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -38, 1, 0)
        Label.Position = UDim2.new(0, 38, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Theme.DisabledText
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = CategoryBtn
        
        local CategoryContent = Instance.new("Frame")
        CategoryContent.Size = UDim2.new(1, 0, 1, 0)
        CategoryContent.BackgroundTransparency = 1
        CategoryContent.Visible = false
        CategoryContent.Parent = self.ContentContainer
        
        -- Top Tabs Area
        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 52)
        TopBar.BackgroundTransparency = 1
        TopBar.Parent = CategoryContent
        
        local TopBarBorder = Instance.new("Frame")
        TopBarBorder.Size = UDim2.new(1, 0, 0, 1)
        TopBarBorder.Position = UDim2.new(0, 0, 1, -1)
        TopBarBorder.BackgroundColor3 = Theme.Border
        TopBarBorder.BorderSizePixel = 0
        TopBarBorder.Parent = TopBar
        
        local SubTabContainer = Instance.new("Frame")
        SubTabContainer.Size = UDim2.new(1, 0, 1, -1)
        SubTabContainer.BackgroundTransparency = 1
        SubTabContainer.Parent = TopBar
        
        local SubTabListLayout = Instance.new("UIListLayout")
        SubTabListLayout.FillDirection = Enum.FillDirection.Horizontal
        SubTabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubTabListLayout.Padding = UDim.new(0, 8)
        SubTabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        SubTabListLayout.Parent = SubTabContainer
        
        local SubTabPadding = Instance.new("UIPadding")
        SubTabPadding.PaddingLeft = UDim.new(0, 15)
        SubTabPadding.Parent = SubTabContainer
        
        local TabsContent = Instance.new("Frame")
        TabsContent.Size = UDim2.new(1, 0, 1, -52)
        TabsContent.Position = UDim2.new(0, 0, 0, 52)
        TabsContent.BackgroundTransparency = 1
        TabsContent.Parent = CategoryContent
        
        local CategoryObj = {
            Button = CategoryBtn,
            Content = CategoryContent,
            SubTabContainer = SubTabContainer,
            TabsContent = TabsContent,
            Tabs = {}
        }
        table.insert(self.Categories, CategoryObj)
        
        CategoryBtn.MouseButton1Click:Connect(function()
            for _, cat in pairs(self.Categories) do
                cat.Button.BackgroundTransparency = 1
                cat.Content.Visible = false
                cat.Button:FindFirstChild("TextLabel").TextColor3 = Theme.DisabledText
                cat.Button:FindFirstChild("ImageLabel").ImageColor3 = Theme.DisabledText
            end
            CategoryBtn.BackgroundTransparency = 0
            CategoryContent.Visible = true
            Label.TextColor3 = Theme.Text
            IconImg.ImageColor3 = Theme.Text
        end)
        
        if #self.Categories == 1 then
            CategoryBtn.BackgroundTransparency = 0
            CategoryContent.Visible = true
            Label.TextColor3 = Theme.Text
            IconImg.ImageColor3 = Theme.Text
        end
        
        function CategoryObj:CreateTab(tabName)
            local textWidth = string.len(tabName) * 8 + 24
            
            -- Restored Top Tab pill background shape to precisely match reference Image 5
            local TabBtn = Instance.new("TextButton")
            TabBtn.Size = UDim2.new(0, textWidth, 0, 32)
            TabBtn.BackgroundColor3 = Theme.ActiveBg
            TabBtn.BackgroundTransparency = 1
            TabBtn.Text = tabName
            TabBtn.TextColor3 = Theme.DisabledText
            TabBtn.Font = Enum.Font.GothamBold
            TabBtn.TextSize = 13
            TabBtn.Parent = self.SubTabContainer
            
            local TabCorner = Instance.new("UICorner")
            TabCorner.CornerRadius = UDim.new(0, 6)
            TabCorner.Parent = TabBtn
            
            local Underline = Instance.new("Frame")
            Underline.Size = UDim2.new(0, 24, 0, 2)
            Underline.Position = UDim2.new(0.5, -12, 1, -2)
            Underline.BackgroundColor3 = Theme.Accent
            Underline.BorderSizePixel = 0
            Underline.BackgroundTransparency = 1
            Underline.Parent = TabBtn
            
            local TabContent = Instance.new("ScrollingFrame")
            TabContent.Size = UDim2.new(1, 0, 1, 0)
            TabContent.BackgroundTransparency = 1
            TabContent.ScrollBarThickness = 0
            TabContent.Visible = false
            TabContent.Parent = self.TabsContent
            
            local TabPadding = Instance.new("UIPadding")
            TabPadding.PaddingTop = UDim.new(0, 15)
            TabPadding.PaddingBottom = UDim.new(0, 15)
            TabPadding.PaddingLeft = UDim.new(0, 15)
            TabPadding.PaddingRight = UDim.new(0, 15)
            TabPadding.Parent = TabContent
            
            local TabLayout = Instance.new("UIGridLayout")
            TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TabLayout.CellSize = UDim2.new(0.5, -8, 0, 240)
            TabLayout.CellPadding = UDim2.new(0, 15, 0, 15)
            TabLayout.Parent = TabContent
            
            TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 30)
            end)
            
            local TabObj = {
                Button = TabBtn,
                Content = TabContent,
                Underline = Underline
            }
            table.insert(self.Tabs, TabObj)
            
            TabBtn.MouseButton1Click:Connect(function()
                for _, t in pairs(self.Tabs) do
                    t.Button.BackgroundTransparency = 1
                    t.Button.TextColor3 = Theme.DisabledText
                    t.Underline.BackgroundTransparency = 1
                    t.Content.Visible = false
                end
                TabBtn.BackgroundTransparency = 0
                TabBtn.TextColor3 = Theme.Text
                Underline.BackgroundTransparency = 0
                TabContent.Visible = true
            end)
            
            if #self.Tabs == 1 then
                TabBtn.BackgroundTransparency = 0
                TabBtn.TextColor3 = Theme.Text
                Underline.BackgroundTransparency = 0
                TabContent.Visible = true
            end
            
            function TabObj:CreateSection(secName, secIcon)
                secIcon = secIcon or Icons.User
                
                local SectionCard = Instance.new("Frame")
                SectionCard.BackgroundColor3 = Theme.CardBg
                SectionCard.BorderSizePixel = 0
                SectionCard.Parent = self.Content
                
                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 8)
                CardCorner.Parent = SectionCard
                
                local Header = Instance.new("Frame")
                Header.Size = UDim2.new(1, 0, 0, 40)
                Header.BackgroundTransparency = 1
                Header.Parent = SectionCard
                
                local HIcon = Instance.new("ImageLabel")
                HIcon.Size = UDim2.new(0, 16, 0, 16)
                HIcon.Position = UDim2.new(0, 12, 0.5, -8)
                HIcon.BackgroundTransparency = 1
                HIcon.Image = secIcon
                HIcon.ImageColor3 = Theme.Accent
                HIcon.Parent = Header
                
                local HTitle = Instance.new("TextLabel")
                HTitle.Size = UDim2.new(1, -70, 1, 0)
                HTitle.Position = UDim2.new(0, 36, 0, 0)
                HTitle.BackgroundTransparency = 1
                HTitle.Text = secName
                HTitle.TextColor3 = Theme.Text
                HTitle.Font = Enum.Font.GothamBold
                HTitle.TextSize = 13
                HTitle.TextXAlignment = Enum.TextXAlignment.Left
                HTitle.Parent = Header
                
                local MasterToggle = Instance.new("TextButton")
                MasterToggle.Size = UDim2.new(0, 34, 0, 18)
                MasterToggle.Position = UDim2.new(1, -46, 0.5, -9)
                MasterToggle.BackgroundColor3 = Theme.InputBg
                MasterToggle.Text = ""
                MasterToggle.AutoButtonColor = false
                MasterToggle.Parent = Header
                
                local MCorner = Instance.new("UICorner")
                MCorner.CornerRadius = UDim.new(1, 0)
                MCorner.Parent = MasterToggle
                
                local MCircle = Instance.new("Frame")
                MCircle.Size = UDim2.new(0, 12, 0, 12)
                MCircle.Position = UDim2.new(0, 3, 0.5, -6)
                MCircle.BackgroundColor3 = Theme.SubText
                MCircle.Parent = MasterToggle
                
                local MCircleCorner = Instance.new("UICorner")
                MCircleCorner.CornerRadius = UDim.new(1, 0)
                MCircleCorner.Parent = MCircle
                
                local masterState = false
                MasterToggle.MouseButton1Click:Connect(function()
                    masterState = not masterState
                    TweenService:Create(MasterToggle, TweenInfo.new(0.2), {BackgroundColor3 = masterState and Theme.Accent or Theme.InputBg}):Play()
                    TweenService:Create(MCircle, TweenInfo.new(0.2), {
                        Position = masterState and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                        BackgroundColor3 = masterState and Color3.fromRGB(255,255,255) or Theme.SubText
                    }):Play()
                end)
                
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, -24, 0, 1)
                Divider.Position = UDim2.new(0, 12, 0, 40)
                Divider.BackgroundColor3 = Theme.Border
                Divider.BorderSizePixel = 0
                Divider.Parent = SectionCard
                
                local ItemsContainer = Instance.new("ScrollingFrame")
                ItemsContainer.Size = UDim2.new(1, 0, 1, -41)
                ItemsContainer.Position = UDim2.new(0, 0, 0, 41)
                ItemsContainer.BackgroundTransparency = 1
                ItemsContainer.ScrollBarThickness = 0
                ItemsContainer.Parent = SectionCard
                
                local ItemsLayout = Instance.new("UIListLayout")
                ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ItemsLayout.Padding = UDim.new(0, 0)
                ItemsLayout.Parent = ItemsContainer
                
                local SecObj = { Container = ItemsContainer }
                
                function SecObj:CreateCheckbox(itemName, default, callback)
                    local state = default or false
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 32)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -60, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local CheckBtn = Instance.new("TextButton")
                    CheckBtn.Size = UDim2.new(0, 16, 0, 16)
                    CheckBtn.Position = UDim2.new(1, -28, 0.5, -8)
                    CheckBtn.BackgroundColor3 = Theme.InputOutline
                    CheckBtn.Text = ""
                    CheckBtn.Parent = ItemFrame
                    
                    local CheckCorner = Instance.new("UICorner")
                    CheckCorner.CornerRadius = UDim.new(0, 4)
                    CheckCorner.Parent = CheckBtn
                    
                    local InnerCheck = Instance.new("Frame")
                    InnerCheck.Size = UDim2.new(1, -2, 1, -2)
                    InnerCheck.Position = UDim2.new(0, 1, 0, 1)
                    InnerCheck.BackgroundColor3 = Theme.InputBg
                    InnerCheck.Parent = CheckBtn
                    
                    local InnerCorner = Instance.new("UICorner")
                    InnerCorner.CornerRadius = UDim.new(0, 4)
                    InnerCorner.Parent = InnerCheck
                    
                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Size = UDim2.new(0, 12, 0, 12)
                    CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = Icons.Check
                    CheckIcon.ImageColor3 = Theme.Text
                    CheckIcon.Visible = state
                    CheckIcon.Parent = InnerCheck
                    
                    local function UpdateState()
                        if state then
                            CheckBtn.BackgroundColor3 = Theme.Accent
                            InnerCheck.BackgroundColor3 = Theme.Accent
                        else
                            CheckBtn.BackgroundColor3 = Theme.InputOutline
                            InnerCheck.BackgroundColor3 = Theme.InputBg
                        end
                        CheckIcon.Visible = state
                        if callback then callback(state) end
                    end
                    UpdateState()
                    
                    CheckBtn.MouseButton1Click:Connect(function()
                        state = not state
                        UpdateState()
                    end)
                end
                
                function SecObj:CreateColorCheckbox(itemName, defaultColor, defaultState, colorCallback, checkCallback)
                    local state = defaultState or false
                    local currentColor = defaultColor or Theme.Accent
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 32)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -80, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local ColorBox = Instance.new("TextButton")
                    ColorBox.Size = UDim2.new(0, 16, 0, 16)
                    ColorBox.Position = UDim2.new(1, -50, 0.5, -8)
                    ColorBox.BackgroundColor3 = currentColor
                    ColorBox.Text = ""
                    ColorBox.Parent = ItemFrame
                    
                    local ColorCorner = Instance.new("UICorner")
                    ColorCorner.CornerRadius = UDim.new(0, 4)
                    ColorCorner.Parent = ColorBox
                    
                    local CheckBtn = Instance.new("TextButton")
                    CheckBtn.Size = UDim2.new(0, 16, 0, 16)
                    CheckBtn.Position = UDim2.new(1, -28, 0.5, -8)
                    CheckBtn.BackgroundColor3 = Theme.InputOutline
                    CheckBtn.Text = ""
                    CheckBtn.Parent = ItemFrame
                    
                    local CheckCorner = Instance.new("UICorner")
                    CheckCorner.CornerRadius = UDim.new(0, 4)
                    CheckCorner.Parent = CheckBtn
                    
                    local InnerCheck = Instance.new("Frame")
                    InnerCheck.Size = UDim2.new(1, -2, 1, -2)
                    InnerCheck.Position = UDim2.new(0, 1, 0, 1)
                    InnerCheck.BackgroundColor3 = Theme.InputBg
                    InnerCheck.Parent = CheckBtn
                    
                    local InnerCorner = Instance.new("UICorner")
                    InnerCorner.CornerRadius = UDim.new(0, 4)
                    InnerCorner.Parent = InnerCheck
                    
                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Size = UDim2.new(0, 12, 0, 12)
                    CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = Icons.Check
                    CheckIcon.ImageColor3 = Theme.Text
                    CheckIcon.Visible = state
                    CheckIcon.Parent = InnerCheck
                    
                    local function UpdateCheckState()
                        if state then
                            CheckBtn.BackgroundColor3 = Theme.Accent
                            InnerCheck.BackgroundColor3 = Theme.Accent
                        else
                            CheckBtn.BackgroundColor3 = Theme.InputOutline
                            InnerCheck.BackgroundColor3 = Theme.InputBg
                        end
                        CheckIcon.Visible = state
                        if checkCallback then checkCallback(state) end
                    end
                    UpdateCheckState()
                    
                    CheckBtn.MouseButton1Click:Connect(function()
                        state = not state
                        UpdateCheckState()
                    end)
                    
                    ColorBox.MouseButton1Click:Connect(function()
                        PopupContainer.Visible = true
                        for _, child in pairs(PopupContainer:GetChildren()) do child:Destroy() end
                        
                        local absPos = ColorBox.AbsolutePosition
                        
                        local PickerFrame = Instance.new("Frame")
                        PickerFrame.Size = UDim2.new(0, 180, 0, 220)
                        PickerFrame.Position = UDim2.new(0, absPos.X - 60, 0, absPos.Y + 22)
                        PickerFrame.BackgroundColor3 = Theme.CardBg
                        PickerFrame.ZIndex = 102
                        PickerFrame.Parent = PopupContainer
                        
                        local PickCorner = Instance.new("UICorner")
                        PickCorner.CornerRadius = UDim.new(0, 8)
                        PickCorner.Parent = PickerFrame
                        
                        local PickShadow = Instance.new("UIShadow")
                        PickShadow.BlurRadius = UDim.new(0, 8)
                        PickShadow.Color = Color3.fromRGB(0, 0, 0)
                        PickShadow.Offset = Vector2.new(0, 2)
                        PickShadow.Transparency = 0.4
                        PickShadow.Parent = PickerFrame
                        
                        local hue, sat, val = 0.7, 0.8, 0.8
                        local r, g, b = currentColor.R, currentColor.G, currentColor.B
                        hue, sat, val = Color3.toHSV(currentColor)
                        
                        local SVBox = Instance.new("TextButton")
                        SVBox.Size = UDim2.new(1, -20, 0, 140)
                        SVBox.Position = UDim2.new(0, 10, 0, 10)
                        SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        SVBox.Text = ""
                        SVBox.ZIndex = 103
                        SVBox.Parent = PickerFrame
                        
                        local SVCorner = Instance.new("UICorner")
                        SVCorner.CornerRadius = UDim.new(0, 4)
                        SVCorner.Parent = SVBox
                        
                        local WhiteGrad = Instance.new("UIGradient")
                        WhiteGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                        })
                        WhiteGrad.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                        WhiteGrad.Parent = SVBox
                        
                        local BlackOverlay = Instance.new("Frame")
                        BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
                        BlackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        BlackOverlay.ZIndex = 104
                        BlackOverlay.Parent = SVBox
                        
                        local BlackCorner = Instance.new("UICorner")
                        BlackCorner.CornerRadius = UDim.new(0, 4)
                        BlackCorner.Parent = BlackOverlay
                        
                        local BlackGrad = Instance.new("UIGradient")
                        BlackGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
                        BlackGrad.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0)
                        })
                        BlackGrad.Rotation = 90
                        BlackGrad.Parent = BlackOverlay
                        
                        local SVCursor = Instance.new("Frame")
                        SVCursor.Size = UDim2.new(0, 10, 0, 10)
                        SVCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                        SVCursor.BackgroundTransparency = 1
                        SVCursor.ZIndex = 106
                        SVCursor.Parent = SVBox
                        
                        local CursorStroke = Instance.new("UICorner")
                        CursorStroke.CornerRadius = UDim.new(1, 0)
                        CursorStroke.Parent = SVCursor
                        
                        local CursorRing = Instance.new("UIStroke")
                        CursorRing.Color = Color3.fromRGB(255, 255, 255)
                        CursorRing.Thickness = 2
                        CursorRing.Parent = SVCursor
                        
                        local HueBar = Instance.new("TextButton")
                        HueBar.Size = UDim2.new(1, -20, 0, 12)
                        HueBar.Position = UDim2.new(0, 10, 0, 158)
                        HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        HueBar.Text = ""
                        HueBar.ZIndex = 103
                        HueBar.Parent = PickerFrame
                        
                        local HueCorner = Instance.new("UICorner")
                        HueCorner.CornerRadius = UDim.new(1, 0)
                        HueCorner.Parent = HueBar
                        
                        local HueGrad = Instance.new("UIGradient")
                        HueGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        })
                        HueGrad.Parent = HueBar
                        
                        local HueCursor = Instance.new("Frame")
                        HueCursor.Size = UDim2.new(0, 10, 0, 10)
                        HueCursor.Position = UDim2.new(hue, -5, 0.5, -5)
                        HueCursor.BackgroundTransparency = 1
                        HueCursor.ZIndex = 106
                        HueCursor.Parent = HueBar
                        
                        local HueCursorCorner = Instance.new("UICorner")
                        HueCursorCorner.CornerRadius = UDim.new(1, 0)
                        HueCursorCorner.Parent = HueCursor
                        
                        local HueCursorRing = Instance.new("UIStroke")
                        HueCursorRing.Color = Color3.fromRGB(255, 255, 255)
                        HueCursorRing.Thickness = 2
                        HueCursorRing.Parent = HueCursor
                        
                        local AlphaBar = Instance.new("TextButton")
                        AlphaBar.Size = UDim2.new(1, -20, 0, 12)
                        AlphaBar.Position = UDim2.new(0, 10, 0, 178)
                        AlphaBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        AlphaBar.Text = ""
                        AlphaBar.ZIndex = 103
                        AlphaBar.Parent = PickerFrame
                        
                        local AlphaCorner = Instance.new("UICorner")
                        AlphaCorner.CornerRadius = UDim.new(1, 0)
                        AlphaCorner.Parent = AlphaBar
                        
                        local AlphaGrad = Instance.new("UIGradient")
                        AlphaGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, 1))
                        })
                        AlphaGrad.Parent = AlphaBar
                        
                        local AlphaCursor = Instance.new("Frame")
                        AlphaCursor.Size = UDim2.new(0, 10, 0, 10)
                        AlphaCursor.Position = UDim2.new(val, -5, 0.5, -5)
                        AlphaCursor.BackgroundTransparency = 1
                        AlphaCursor.ZIndex = 106
                        AlphaCursor.Parent = AlphaBar
                        
                        local AlphaCursorCorner = Instance.new("UICorner")
                        AlphaCursorCorner.CornerRadius = UDim.new(1, 0)
                        AlphaCursorCorner.Parent = AlphaCursor
                        
                        local AlphaCursorRing = Instance.new("UIStroke")
                        AlphaCursorRing.Color = Color3.fromRGB(255, 255, 255)
                        AlphaCursorRing.Thickness = 2
                        AlphaCursorRing.Parent = AlphaCursor
                        
                        local function applyColor()
                            local c = Color3.fromHSV(hue, sat, val)
                            currentColor = c
                            ColorBox.BackgroundColor3 = c
                            SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                            AlphaGrad.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                                ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, 1))
                            })
                            if colorCallback then colorCallback(c) end
                        end
                        
                        local svDrag = false
                        SVBox.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = true end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if svDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                local mx = math.clamp((inp.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                                local my = math.clamp((inp.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                                sat = mx
                                val = 1 - my
                                SVCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                                applyColor()
                            end
                        end)
                        
                        local hueDrag = false
                        HueBar.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if hueDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                hue = math.clamp((inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                                HueCursor.Position = UDim2.new(hue, -5, 0.5, -5)
                                applyColor()
                            end
                        end)
                        
                        local alphaDrag = false
                        AlphaBar.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then alphaDrag = true end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then alphaDrag = false end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if alphaDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                val = math.clamp((inp.Position.X - AlphaBar.AbsolutePosition.X) / AlphaBar.AbsoluteSize.X, 0, 1)
                                AlphaCursor.Position = UDim2.new(val, -5, 0.5, -5)
                                applyColor()
                            end
                        end)
                        
                        local CloseBtn = Instance.new("TextButton")
                        CloseBtn.Size = UDim2.new(1, 0, 1, 0)
                        CloseBtn.BackgroundTransparency = 1
                        CloseBtn.Text = ""
                        CloseBtn.ZIndex = 99
                        CloseBtn.Parent = PopupContainer
                        CloseBtn.MouseButton1Click:Connect(function()
                            PopupContainer.Visible = false
                            PopupContainer:ClearAllChildren()
                        end)
                    end)
                end
                
                function SecObj:CreateSettingsRow(itemName, defaultColor, defaultState, colorCallback, settingsCallback, checkCallback)
                    local state = defaultState or false
                    local currentColor = defaultColor or Theme.Accent
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 32)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -100, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local ColorBox = Instance.new("TextButton")
                    ColorBox.Size = UDim2.new(0, 16, 0, 16)
                    ColorBox.Position = UDim2.new(1, -72, 0.5, -8)
                    ColorBox.BackgroundColor3 = currentColor
                    ColorBox.Text = ""
                    ColorBox.Parent = ItemFrame
                    
                    local ColorCorner = Instance.new("UICorner")
                    ColorCorner.CornerRadius = UDim.new(0, 4)
                    ColorCorner.Parent = ColorBox
                    
                    local GearBtn = Instance.new("ImageButton")
                    GearBtn.Size = UDim2.new(0, 14, 0, 14)
                    GearBtn.Position = UDim2.new(1, -50, 0.5, -7)
                    GearBtn.BackgroundTransparency = 1
                    GearBtn.Image = Icons.Settings
                    GearBtn.ImageColor3 = Theme.SubText
                    GearBtn.Parent = ItemFrame
                    
                    GearBtn.MouseButton1Click:Connect(function()
                        if settingsCallback then settingsCallback() end
                    end)
                    
                    local CheckBtn = Instance.new("TextButton")
                    CheckBtn.Size = UDim2.new(0, 16, 0, 16)
                    CheckBtn.Position = UDim2.new(1, -28, 0.5, -8)
                    CheckBtn.BackgroundColor3 = Theme.InputOutline
                    CheckBtn.Text = ""
                    CheckBtn.Parent = ItemFrame
                    
                    local CheckCorner = Instance.new("UICorner")
                    CheckCorner.CornerRadius = UDim.new(0, 4)
                    CheckCorner.Parent = CheckBtn
                    
                    local InnerCheck = Instance.new("Frame")
                    InnerCheck.Size = UDim2.new(1, -2, 1, -2)
                    InnerCheck.Position = UDim2.new(0, 1, 0, 1)
                    InnerCheck.BackgroundColor3 = Theme.InputBg
                    InnerCheck.Parent = CheckBtn
                    
                    local InnerCorner = Instance.new("UICorner")
                    InnerCorner.CornerRadius = UDim.new(0, 4)
                    InnerCorner.Parent = InnerCheck
                    
                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Size = UDim2.new(0, 12, 0, 12)
                    CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = Icons.Check
                    CheckIcon.ImageColor3 = Theme.Text
                    CheckIcon.Visible = state
                    CheckIcon.Parent = InnerCheck
                    
                    local function UpdateCheckState()
                        if state then
                            CheckBtn.BackgroundColor3 = Theme.Accent
                            InnerCheck.BackgroundColor3 = Theme.Accent
                        else
                            CheckBtn.BackgroundColor3 = Theme.InputOutline
                            InnerCheck.BackgroundColor3 = Theme.InputBg
                        end
                        CheckIcon.Visible = state
                        if checkCallback then checkCallback(state) end
                    end
                    UpdateCheckState()
                    
                    CheckBtn.MouseButton1Click:Connect(function()
                        state = not state
                        UpdateCheckState()
                    end)
                    
                    ColorBox.MouseButton1Click:Connect(function()
                        PopupContainer.Visible = true
                        for _, child in pairs(PopupContainer:GetChildren()) do child:Destroy() end
                        
                        local absPos = ColorBox.AbsolutePosition
                        
                        local PickerFrame = Instance.new("Frame")
                        PickerFrame.Size = UDim2.new(0, 180, 0, 220)
                        PickerFrame.Position = UDim2.new(0, absPos.X - 60, 0, absPos.Y + 22)
                        PickerFrame.BackgroundColor3 = Theme.CardBg
                        PickerFrame.ZIndex = 102
                        PickerFrame.Parent = PopupContainer
                        
                        local PickCorner = Instance.new("UICorner")
                        PickCorner.CornerRadius = UDim.new(0, 8)
                        PickCorner.Parent = PickerFrame
                        
                        local PickShadow = Instance.new("UIShadow")
                        PickShadow.BlurRadius = UDim.new(0, 8)
                        PickShadow.Color = Color3.fromRGB(0, 0, 0)
                        PickShadow.Offset = Vector2.new(0, 2)
                        PickShadow.Transparency = 0.4
                        PickShadow.Parent = PickerFrame
                        
                        local hue, sat, val = Color3.toHSV(currentColor)
                        
                        local SVBox = Instance.new("TextButton")
                        SVBox.Size = UDim2.new(1, -20, 0, 140)
                        SVBox.Position = UDim2.new(0, 10, 0, 10)
                        SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        SVBox.Text = ""
                        SVBox.ZIndex = 103
                        SVBox.Parent = PickerFrame
                        
                        local SVCorner = Instance.new("UICorner")
                        SVCorner.CornerRadius = UDim.new(0, 4)
                        SVCorner.Parent = SVBox
                        
                        local WhiteGrad = Instance.new("UIGradient")
                        WhiteGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                        })
                        WhiteGrad.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                        WhiteGrad.Parent = SVBox
                        
                        local BlackOverlay = Instance.new("Frame")
                        BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
                        BlackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        BlackOverlay.ZIndex = 104
                        BlackOverlay.Parent = SVBox
                        
                        local BlackCorner = Instance.new("UICorner")
                        BlackCorner.CornerRadius = UDim.new(0, 4)
                        BlackCorner.Parent = BlackOverlay
                        
                        local BlackGrad = Instance.new("UIGradient")
                        BlackGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
                        BlackGrad.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0)
                        })
                        BlackGrad.Rotation = 90
                        BlackGrad.Parent = BlackOverlay
                        
                        local SVCursor = Instance.new("Frame")
                        SVCursor.Size = UDim2.new(0, 10, 0, 10)
                        SVCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                        SVCursor.BackgroundTransparency = 1
                        SVCursor.ZIndex = 106
                        SVCursor.Parent = SVBox
                        
                        local CursorCorner = Instance.new("UICorner")
                        CursorCorner.CornerRadius = UDim.new(1, 0)
                        CursorCorner.Parent = SVCursor
                        
                        local CursorRing = Instance.new("UIStroke")
                        CursorRing.Color = Color3.fromRGB(255, 255, 255)
                        CursorRing.Thickness = 2
                        CursorRing.Parent = SVCursor
                        
                        local HueBar = Instance.new("TextButton")
                        HueBar.Size = UDim2.new(1, -20, 0, 12)
                        HueBar.Position = UDim2.new(0, 10, 0, 158)
                        HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        HueBar.Text = ""
                        HueBar.ZIndex = 103
                        HueBar.Parent = PickerFrame
                        
                        local HueCorner = Instance.new("UICorner")
                        HueCorner.CornerRadius = UDim.new(1, 0)
                        HueCorner.Parent = HueBar
                        
                        local HueGrad = Instance.new("UIGradient")
                        HueGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        })
                        HueGrad.Parent = HueBar
                        
                        local HueCursor = Instance.new("Frame")
                        HueCursor.Size = UDim2.new(0, 10, 0, 10)
                        HueCursor.Position = UDim2.new(hue, -5, 0.5, -5)
                        HueCursor.BackgroundTransparency = 1
                        HueCursor.ZIndex = 106
                        HueCursor.Parent = HueBar
                        
                        local HueCursorCorner = Instance.new("UICorner")
                        HueCursorCorner.CornerRadius = UDim.new(1, 0)
                        HueCursorCorner.Parent = HueCursor
                        
                        local HueCursorRing = Instance.new("UIStroke")
                        HueCursorRing.Color = Color3.fromRGB(255, 255, 255)
                        HueCursorRing.Thickness = 2
                        HueCursorRing.Parent = HueCursor
                        
                        local AlphaBar = Instance.new("TextButton")
                        AlphaBar.Size = UDim2.new(1, -20, 0, 12)
                        AlphaBar.Position = UDim2.new(0, 10, 0, 178)
                        AlphaBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        AlphaBar.Text = ""
                        AlphaBar.ZIndex = 103
                        AlphaBar.Parent = PickerFrame
                        
                        local AlphaCorner = Instance.new("UICorner")
                        AlphaCorner.CornerRadius = UDim.new(1, 0)
                        AlphaCorner.Parent = AlphaBar
                        
                        local AlphaGrad = Instance.new("UIGradient")
                        AlphaGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, 1))
                        })
                        AlphaGrad.Parent = AlphaBar
                        
                        local AlphaCursor = Instance.new("Frame")
                        AlphaCursor.Size = UDim2.new(0, 10, 0, 10)
                        AlphaCursor.Position = UDim2.new(val, -5, 0.5, -5)
                        AlphaCursor.BackgroundTransparency = 1
                        AlphaCursor.ZIndex = 106
                        AlphaCursor.Parent = AlphaBar
                        
                        local AlphaCursorCorner = Instance.new("UICorner")
                        AlphaCursorCorner.CornerRadius = UDim.new(1, 0)
                        AlphaCursorCorner.Parent = AlphaCursor
                        
                        local AlphaCursorRing = Instance.new("UIStroke")
                        AlphaCursorRing.Color = Color3.fromRGB(255, 255, 255)
                        AlphaCursorRing.Thickness = 2
                        AlphaCursorRing.Parent = AlphaCursor
                        
                        local function applyColor()
                            local c = Color3.fromHSV(hue, sat, val)
                            currentColor = c
                            ColorBox.BackgroundColor3 = c
                            SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                            AlphaGrad.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                                ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, 1))
                            })
                            if colorCallback then colorCallback(c) end
                        end
                        
                        local svDrag = false
                        SVBox.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = true end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if svDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                sat = math.clamp((inp.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                                val = 1 - math.clamp((inp.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                                SVCursor.Position = UDim2.new(sat, -5, 1 - val, -5)
                                applyColor()
                            end
                        end)
                        
                        local hueDrag = false
                        HueBar.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = true end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if hueDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                hue = math.clamp((inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                                HueCursor.Position = UDim2.new(hue, -5, 0.5, -5)
                                applyColor()
                            end
                        end)
                        
                        local alphaDrag = false
                        AlphaBar.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then alphaDrag = true end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then alphaDrag = false end
                        end)
                        UserInputService.InputChanged:Connect(function(inp)
                            if alphaDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                                val = math.clamp((inp.Position.X - AlphaBar.AbsolutePosition.X) / AlphaBar.AbsoluteSize.X, 0, 1)
                                AlphaCursor.Position = UDim2.new(val, -5, 0.5, -5)
                                applyColor()
                            end
                        end)
                        
                        local CloseBtn = Instance.new("TextButton")
                        CloseBtn.Size = UDim2.new(1, 0, 1, 0)
                        CloseBtn.BackgroundTransparency = 1
                        CloseBtn.Text = ""
                        CloseBtn.ZIndex = 99
                        CloseBtn.Parent = PopupContainer
                        CloseBtn.MouseButton1Click:Connect(function()
                            PopupContainer.Visible = false
                            PopupContainer:ClearAllChildren()
                        end)
                    end)
                end
                
                function SecObj:CreateDropdown(itemName, options, default, callback)
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 32)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0, 80, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local DropBtn = Instance.new("TextButton")
                    DropBtn.Size = UDim2.new(1, -110, 0, 24)
                    DropBtn.Position = UDim2.new(0, 95, 0.5, -12)
                    DropBtn.BackgroundColor3 = Theme.InputBg
                    DropBtn.Text = ""
                    DropBtn.Parent = ItemFrame
                    
                    local DropCorner = Instance.new("UICorner")
                    DropCorner.CornerRadius = UDim.new(0, 4)
                    DropCorner.Parent = DropBtn
                    
                    local SelectedLabel = Instance.new("TextLabel")
                    SelectedLabel.Size = UDim2.new(1, -25, 1, 0)
                    SelectedLabel.Position = UDim2.new(0, 10, 0, 0)
                    SelectedLabel.BackgroundTransparency = 1
                    SelectedLabel.Text = default or options[1] or ""
                    SelectedLabel.TextColor3 = Theme.SubText
                    SelectedLabel.Font = Enum.Font.GothamMedium
                    SelectedLabel.TextSize = 11
                    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    SelectedLabel.Parent = DropBtn
                    
                    local DropIcon = Instance.new("ImageLabel")
                    DropIcon.Size = UDim2.new(0, 12, 0, 12)
                    DropIcon.Position = UDim2.new(1, -18, 0.5, -6)
                    DropIcon.BackgroundTransparency = 1
                    DropIcon.Image = Icons.Dropdown
                    DropIcon.ImageColor3 = Theme.SubText
                    DropIcon.Parent = DropBtn
                    
                    DropBtn.MouseButton1Click:Connect(function()
                        PopupContainer.Visible = true
                        for _, child in pairs(PopupContainer:GetChildren()) do child:Destroy() end
                        
                        local absolutePos = DropBtn.AbsolutePosition
                        local absoluteSize = DropBtn.AbsoluteSize
                        
                        local PopupFrame = Instance.new("Frame")
                        PopupFrame.Size = UDim2.new(0, absoluteSize.X, 0, math.min(#options * 26 + 10, 140))
                        PopupFrame.Position = UDim2.new(0, absolutePos.X, 0, absolutePos.Y + absoluteSize.Y + 4)
                        PopupFrame.BackgroundColor3 = Theme.CardBg
                        PopupFrame.Parent = PopupContainer
                        
                        local PopCorner = Instance.new("UICorner")
                        PopCorner.CornerRadius = UDim.new(0, 6)
                        PopCorner.Parent = PopupFrame
                        
                        local PopScroll = Instance.new("ScrollingFrame")
                        PopScroll.Size = UDim2.new(1, 0, 1, -10)
                        PopScroll.Position = UDim2.new(0, 0, 0, 5)
                        PopScroll.BackgroundTransparency = 1
                        PopScroll.ScrollBarThickness = 0
                        PopScroll.Parent = PopupFrame
                        
                        local PopLayout = Instance.new("UIListLayout")
                        PopLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        PopLayout.Parent = PopScroll
                        
                        for _, opt in ipairs(options) do
                            local OptBtn = Instance.new("TextButton")
                            OptBtn.Size = UDim2.new(1, 0, 0, 26)
                            OptBtn.BackgroundTransparency = 1
                            OptBtn.Text = "  " .. opt
                            OptBtn.TextColor3 = (opt == SelectedLabel.Text) and Theme.Accent or Theme.DisabledText
                            OptBtn.Font = Enum.Font.GothamMedium
                            OptBtn.TextSize = 12
                            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                            OptBtn.Parent = PopScroll
                            
                            OptBtn.MouseButton1Click:Connect(function()
                                SelectedLabel.Text = opt
                                if callback then callback(opt) end
                                PopupContainer.Visible = false
                                PopupFrame:Destroy()
                            end)
                        end
                        PopScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 26)
                        
                        local CloseBtn = Instance.new("TextButton")
                        CloseBtn.Size = UDim2.new(1, 0, 1, 0)
                        CloseBtn.BackgroundTransparency = 1
                        CloseBtn.Text = ""
                        CloseBtn.ZIndex = 99
                        CloseBtn.Parent = PopupContainer
                        CloseBtn.MouseButton1Click:Connect(function()
                            PopupContainer.Visible = false
                            PopupContainer:ClearAllChildren()
                        end)
                        PopupFrame.ZIndex = 101
                    end)
                end
                
                function SecObj:CreateSlider(itemName, min, max, default, callback)
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 42)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -50, 0, 16)
                    Label.Position = UDim2.new(0, 12, 0, 4)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local ValueLabel = Instance.new("TextLabel")
                    ValueLabel.Size = UDim2.new(0, 40, 0, 16)
                    ValueLabel.Position = UDim2.new(1, -52, 0, 4)
                    ValueLabel.BackgroundTransparency = 1
                    ValueLabel.Text = tostring(default)
                    ValueLabel.TextColor3 = Theme.SubText
                    ValueLabel.Font = Enum.Font.GothamMedium
                    ValueLabel.TextSize = 12
                    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValueLabel.Parent = ItemFrame
                    
                    local SliderBg = Instance.new("Frame")
                    SliderBg.Size = UDim2.new(1, -24, 0, 4)
                    SliderBg.Position = UDim2.new(0, 12, 0, 28)
                    SliderBg.BackgroundColor3 = Theme.InputBg
                    SliderBg.Parent = ItemFrame
                    
                    local BgCorner = Instance.new("UICorner")
                    BgCorner.CornerRadius = UDim.new(1, 0)
                    BgCorner.Parent = SliderBg
                    
                    local SliderFill = Instance.new("Frame")
                    local pct = (default - min) / (max - min)
                    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
                    SliderFill.BackgroundColor3 = Theme.Accent
                    SliderFill.Parent = SliderBg
                    
                    local FillCorner = Instance.new("UICorner")
                    FillCorner.CornerRadius = UDim.new(1, 0)
                    FillCorner.Parent = SliderFill
                    
                    local Knob = Instance.new("Frame")
                    Knob.Size = UDim2.new(0, 10, 0, 10)
                    Knob.Position = UDim2.new(1, -5, 0.5, -5)
                    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Knob.Parent = SliderFill
                    
                    local KnobCorner = Instance.new("UICorner")
                    KnobCorner.CornerRadius = UDim.new(1, 0)
                    KnobCorner.Parent = Knob
                    
                    local SliderBtn = Instance.new("TextButton")
                    SliderBtn.Size = UDim2.new(1, 0, 1, 14)
                    SliderBtn.Position = UDim2.new(0, 0, 0, -7)
                    SliderBtn.BackgroundTransparency = 1
                    SliderBtn.Text = ""
                    SliderBtn.Parent = SliderBg
                    
                    local dragging = false
                    SliderBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local mouseX = input.Position.X
                            local sliderX = SliderBg.AbsolutePosition.X
                            local sliderW = SliderBg.AbsoluteSize.X
                            local percent = math.clamp((mouseX - sliderX) / sliderW, 0, 1)
                            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                            local val = math.floor(min + (max - min) * percent)
                            ValueLabel.Text = tostring(val)
                            if callback then callback(val) end
                        end
                    end)
                end
                
                return SecObj
            end
            
            return TabObj
        end
        
        return CategoryObj
    end
    
    return WindowObj
end

return Library
