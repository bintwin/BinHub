local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library

local Theme = {
    MainBg = Color3.fromRGB(17, 17, 22),     -- Very dark grey (Sidebar and Main Area)
    CardBg = Color3.fromRGB(22, 22, 27),     -- Slightly lighter for Cards
    ActiveBg = Color3.fromRGB(29, 29, 35),   -- Sidebar active button background
    Accent = Color3.fromRGB(150, 132, 241),  -- Nebula purple #9684F1
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 169),
    DisabledText = Color3.fromRGB(100, 100, 110),
    Border = Color3.fromRGB(31, 31, 39),     -- Separator lines
    InputBg = Color3.fromRGB(26, 26, 33),    -- Unchecked box / Toggle off background
    InputOutline = Color3.fromRGB(58, 58, 70) -- Outline for checkboxes
}

local Lucide = {
    Return = "rbxassetid://10734933902", -- Use the curved arrow for Players (closest to their image)
    UserCircle = "rbxassetid://10709798485", 
    Check = "rbxassetid://10709790644",
    Settings = "rbxassetid://10734898355",
    ExternalLink = "rbxassetid://10709791437"
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
    MainFrame.Size = UDim2.new(0, 750, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = gui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    -- Removed the Drop Shadow completely based on Image 1
    
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
    
    -- Bottom Bar (No borders, just text integrated into the bottom)
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, 0, 0, 30)
    BottomBar.Position = UDim2.new(0, 0, 1, -30)
    BottomBar.BackgroundTransparency = 1
    BottomBar.Parent = MainFrame
    
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
    RightFooterText.Text = "32 days left, <font color=\"rgb(150,132,241)\">" .. FooterRight .. "</font>"
    RightFooterText.TextColor3 = Theme.DisabledText
    RightFooterText.Font = Enum.Font.GothamMedium
    RightFooterText.TextSize = 11
    RightFooterText.TextXAlignment = Enum.TextXAlignment.Right
    RightFooterText.Parent = BottomBar
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, -30)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame
    
    local SidebarBorder = Instance.new("Frame")
    SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    SidebarBorder.BackgroundColor3 = Theme.Border
    SidebarBorder.BorderSizePixel = 0
    SidebarBorder.Parent = Sidebar
    
    local TitleArea = Instance.new("Frame")
    TitleArea.Size = UDim2.new(1, 0, 0, 75)
    TitleArea.BackgroundTransparency = 1
    TitleArea.Parent = Sidebar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -25, 1, 0)
    TitleLabel.Position = UDim2.new(0, 25, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.RichText = true
    TitleLabel.Text = "<font color=\"rgb(150,132,241)\">" .. TitleFirst .. "</font>" .. TitleSecond
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleArea
    
    -- Removed title underline to match Image 1
    
    local CategoryContainer = Instance.new("ScrollingFrame")
    CategoryContainer.Name = "Categories"
    CategoryContainer.Size = UDim2.new(1, 0, 1, -75)
    CategoryContainer.Position = UDim2.new(0, 0, 0, 75)
    CategoryContainer.BackgroundTransparency = 1
    CategoryContainer.ScrollBarThickness = 0
    CategoryContainer.Parent = Sidebar
    
    local CategoryListLayout = Instance.new("UIListLayout")
    CategoryListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CategoryListLayout.Padding = UDim.new(0, 5)
    CategoryListLayout.Parent = CategoryContainer
    
    local CategoryPadding = Instance.new("UIPadding")
    CategoryPadding.PaddingLeft = UDim.new(0, 15)
    CategoryPadding.PaddingRight = UDim.new(0, 15)
    CategoryPadding.Parent = CategoryContainer
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -200, 1, -30)
    ContentContainer.Position = UDim2.new(0, 200, 0, 0)
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
        local Icon = options.Icon or Lucide.Return
        local SectionTitle = options.Section or "General"
        
        local hasSectionLabel = false
        for _, child in pairs(CategoryContainer:GetChildren()) do
            if child:IsA("TextLabel") and child.Text == SectionTitle then hasSectionLabel = true end
        end
        if not hasSectionLabel then
            local secLabel = Instance.new("TextLabel")
            secLabel.Size = UDim2.new(1, 0, 0, 24)
            secLabel.BackgroundTransparency = 1
            secLabel.Text = SectionTitle
            secLabel.TextColor3 = Theme.DisabledText
            secLabel.Font = Enum.Font.GothamMedium
            secLabel.TextSize = 11
            secLabel.TextXAlignment = Enum.TextXAlignment.Left
            secLabel.Parent = CategoryContainer
        end
        
        local CategoryBtn = Instance.new("TextButton")
        CategoryBtn.Size = UDim2.new(1, 0, 0, 32)
        CategoryBtn.BackgroundColor3 = Theme.ActiveBg
        CategoryBtn.BackgroundTransparency = 1
        CategoryBtn.Text = ""
        CategoryBtn.Parent = self.CategoryContainer
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = CategoryBtn
        
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 14, 0, 14)
        IconImg.Position = UDim2.new(0, 10, 0.5, -7)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = Icon
        IconImg.ImageColor3 = Theme.DisabledText
        IconImg.Parent = CategoryBtn
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -34, 1, 0)
        Label.Position = UDim2.new(0, 34, 0, 0)
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
        TopBar.Size = UDim2.new(1, 0, 0, 60)
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
        SubTabListLayout.Padding = UDim.new(0, 20)
        SubTabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        SubTabListLayout.Parent = SubTabContainer
        
        local SubTabPadding = Instance.new("UIPadding")
        SubTabPadding.PaddingLeft = UDim.new(0, 15) -- Aligned closely to the left
        SubTabPadding.Parent = SubTabContainer
        
        local TabsContent = Instance.new("Frame")
        TabsContent.Size = UDim2.new(1, 0, 1, -60)
        TabsContent.Position = UDim2.new(0, 0, 0, 60)
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
            local textWidth = string.len(tabName) * 8 + 10
            
            -- Simple text button without background pill
            local TabBtn = Instance.new("TextButton")
            TabBtn.Size = UDim2.new(0, textWidth, 1, 0)
            TabBtn.BackgroundTransparency = 1
            TabBtn.Text = tabName
            TabBtn.TextColor3 = Theme.DisabledText
            TabBtn.Font = Enum.Font.GothamBold
            TabBtn.TextSize = 13
            TabBtn.Parent = self.SubTabContainer
            
            local Underline = Instance.new("Frame")
            Underline.Size = UDim2.new(1, 0, 0, 2)
            Underline.Position = UDim2.new(0, 0, 1, -1) -- Spans the full width of the tab
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
            TabLayout.CellSize = UDim2.new(0.5, -10, 0, 230)
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
                    t.Button.TextColor3 = Theme.DisabledText
                    t.Underline.BackgroundTransparency = 1
                    t.Content.Visible = false
                end
                TabBtn.TextColor3 = Theme.Text
                Underline.BackgroundTransparency = 0
                TabContent.Visible = true
            end)
            
            if #self.Tabs == 1 then
                TabBtn.TextColor3 = Theme.Text
                Underline.BackgroundTransparency = 0
                TabContent.Visible = true
            end
            
            function TabObj:CreateSection(secName, secIcon)
                secIcon = secIcon or Lucide.UserCircle
                
                local SectionCard = Instance.new("Frame")
                SectionCard.BackgroundColor3 = Theme.CardBg
                SectionCard.BorderSizePixel = 0
                SectionCard.Parent = self.Content
                
                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 8)
                CardCorner.Parent = SectionCard
                
                local Header = Instance.new("Frame")
                Header.Size = UDim2.new(1, 0, 0, 42)
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
                
                -- Master Toggle (Wider and NO UIStroke based on Image 1)
                local MasterToggle = Instance.new("TextButton")
                MasterToggle.Size = UDim2.new(0, 38, 0, 20)
                MasterToggle.Position = UDim2.new(1, -48, 0.5, -10)
                MasterToggle.BackgroundColor3 = Theme.InputBg
                MasterToggle.Text = ""
                MasterToggle.AutoButtonColor = false
                MasterToggle.Parent = Header
                
                local MCorner = Instance.new("UICorner")
                MCorner.CornerRadius = UDim.new(1, 0)
                MCorner.Parent = MasterToggle
                
                local MCircle = Instance.new("Frame")
                MCircle.Size = UDim2.new(0, 14, 0, 14)
                MCircle.Position = UDim2.new(0, 3, 0.5, -7)
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
                        Position = masterState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                        BackgroundColor3 = masterState and Theme.Text or Theme.SubText
                    }):Play()
                end)
                
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, -24, 0, 1)
                Divider.Position = UDim2.new(0, 12, 0, 42)
                Divider.BackgroundColor3 = Theme.Border
                Divider.BorderSizePixel = 0
                Divider.Parent = SectionCard
                
                local ItemsContainer = Instance.new("ScrollingFrame")
                ItemsContainer.Size = UDim2.new(1, 0, 1, -43)
                ItemsContainer.Position = UDim2.new(0, 0, 0, 43)
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
                    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -60, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local CheckBtn = Instance.new("TextButton")
                    CheckBtn.Size = UDim2.new(0, 18, 0, 18)
                    CheckBtn.Position = UDim2.new(1, -30, 0.5, -9)
                    CheckBtn.BackgroundColor3 = Theme.InputBg
                    CheckBtn.Text = ""
                    CheckBtn.Parent = ItemFrame
                    
                    local CheckCorner = Instance.new("UICorner")
                    CheckCorner.CornerRadius = UDim.new(0, 4)
                    CheckCorner.Parent = CheckBtn
                    
                    local CheckStroke = Instance.new("UIStroke")
                    CheckStroke.Color = Theme.InputOutline
                    CheckStroke.Thickness = 1
                    CheckStroke.Parent = CheckBtn
                    
                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Size = UDim2.new(0, 14, 0, 14)
                    CheckIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = Lucide.Check
                    CheckIcon.ImageColor3 = Theme.Text
                    CheckIcon.Visible = state
                    CheckIcon.Parent = CheckBtn
                    
                    local function UpdateState()
                        CheckBtn.BackgroundColor3 = state and Theme.Accent or Theme.InputBg
                        CheckStroke.Transparency = state and 1 or 0
                        CheckIcon.Visible = state
                        if callback then callback(state) end
                    end
                    UpdateState()
                    
                    CheckBtn.MouseButton1Click:Connect(function()
                        state = not state
                        UpdateState()
                    end)
                end
                
                function SecObj:CreateDropdown(itemName, options, default, callback)
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0, 80, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local DropBtn = Instance.new("TextButton")
                    DropBtn.Size = UDim2.new(1, -110, 0, 26)
                    DropBtn.Position = UDim2.new(0, 95, 0.5, -13)
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
                    SelectedLabel.TextSize = 12
                    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    SelectedLabel.Parent = DropBtn
                    
                    local DropIcon = Instance.new("ImageLabel")
                    DropIcon.Size = UDim2.new(0, 12, 0, 12)
                    DropIcon.Position = UDim2.new(1, -18, 0.5, -6)
                    DropIcon.BackgroundTransparency = 1
                    DropIcon.Image = Lucide.ExternalLink
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
                        
                        local PopStroke = Instance.new("UIStroke")
                        PopStroke.Color = Theme.Border
                        PopStroke.Thickness = 1
                        PopStroke.Parent = PopupFrame
                        
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
                            OptBtn.TextSize = 13
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
                    Label.Size = UDim2.new(1, -30, 0, 16)
                    Label.Position = UDim2.new(0, 12, 0, 4)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName .. ": " .. tostring(default)
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local SliderBg = Instance.new("Frame")
                    SliderBg.Size = UDim2.new(1, -24, 0, 4)
                    SliderBg.Position = UDim2.new(0, 12, 0, 26)
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
                            Label.Text = itemName .. ": " .. tostring(val)
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
