local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library

local Theme = {
    Background = Color3.fromRGB(15, 15, 17),
    CardBg = Color3.fromRGB(20, 20, 23),
    ActiveBg = Color3.fromRGB(28, 28, 33),
    Accent = Color3.fromRGB(123, 97, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(130, 130, 130),
    DisabledText = Color3.fromRGB(80, 80, 80),
    Stroke = Color3.fromRGB(30, 30, 35)
}

function Library:CreateWindow(options)
    options = options or {}
    local TitleFirst = options.TitleFirst or "bin"
    local TitleSecond = options.TitleSecond or "hub"
    local FooterLeft = options.FooterLeft or "Universal Script"
    local FooterRight = options.FooterRight or "binhub"
    
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
    MainFrame.Size = UDim2.new(0, 800, 0, 560)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -280)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = gui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Drop shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Image = "rbxassetid://13169223794"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.4
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(40, 40, 60, 60)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    -- Dragging logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Bottom Bar
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, 0, 0, 25)
    BottomBar.Position = UDim2.new(0, 0, 1, -25)
    BottomBar.BackgroundTransparency = 1
    BottomBar.Parent = MainFrame
    
    local LeftFooterText = Instance.new("TextLabel")
    LeftFooterText.Size = UDim2.new(0.5, -20, 1, 0)
    LeftFooterText.Position = UDim2.new(0, 20, 0, 0)
    LeftFooterText.BackgroundTransparency = 1
    LeftFooterText.Text = FooterLeft
    LeftFooterText.TextColor3 = Theme.SubText
    LeftFooterText.Font = Enum.Font.Gotham
    LeftFooterText.TextSize = 12
    LeftFooterText.TextXAlignment = Enum.TextXAlignment.Left
    LeftFooterText.Parent = BottomBar
    
    local RightFooterText = Instance.new("TextLabel")
    RightFooterText.Size = UDim2.new(0.5, -20, 1, 0)
    RightFooterText.Position = UDim2.new(0.5, 0, 0, 0)
    RightFooterText.BackgroundTransparency = 1
    RightFooterText.Text = "32 days left, "
    RightFooterText.TextColor3 = Theme.SubText
    RightFooterText.Font = Enum.Font.Gotham
    RightFooterText.TextSize = 12
    RightFooterText.TextXAlignment = Enum.TextXAlignment.Right
    RightFooterText.Parent = BottomBar
    
    local RightFooterHighlight = Instance.new("TextLabel")
    RightFooterHighlight.Size = UDim2.new(1, 0, 1, 0)
    RightFooterHighlight.Position = UDim2.new(0, 0, 0, 0)
    RightFooterHighlight.BackgroundTransparency = 1
    RightFooterHighlight.Text = FooterRight
    RightFooterHighlight.TextColor3 = Theme.Accent
    RightFooterHighlight.Font = Enum.Font.Gotham
    RightFooterHighlight.TextSize = 12
    RightFooterHighlight.TextXAlignment = Enum.TextXAlignment.Right
    RightFooterHighlight.Parent = RightFooterText
    
    -- We can align the highlight perfectly by using a UIListLayout or just rich text. Let's use RichText.
    RightFooterText.RichText = true
    RightFooterText.Text = "32 days left, <font color=\"rgb(123, 97, 255)\">" .. FooterRight .. "</font>"
    RightFooterHighlight:Destroy()
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 220, 1, -25)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainFrame
    
    local TitleArea = Instance.new("Frame")
    TitleArea.Size = UDim2.new(1, 0, 0, 80)
    TitleArea.BackgroundTransparency = 1
    TitleArea.Parent = Sidebar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -30, 1, 0)
    TitleLabel.Position = UDim2.new(0, 30, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.RichText = true
    TitleLabel.Text = "<font color=\"rgb(123, 97, 255)\">" .. TitleFirst .. "</font>" .. TitleSecond
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleArea
    
    -- Calculate text bounds for underline. Approximating based on length.
    local underlineWidth = string.len(TitleFirst) * 12
    local TitleUnderline = Instance.new("Frame")
    TitleUnderline.Size = UDim2.new(0, underlineWidth, 0, 2)
    TitleUnderline.Position = UDim2.new(0, 30, 0, 52)
    TitleUnderline.BackgroundColor3 = Theme.Accent
    TitleUnderline.BorderSizePixel = 0
    TitleUnderline.Parent = TitleArea
    
    local CategoryContainer = Instance.new("ScrollingFrame")
    CategoryContainer.Name = "Categories"
    CategoryContainer.Size = UDim2.new(1, 0, 1, -80)
    CategoryContainer.Position = UDim2.new(0, 0, 0, 80)
    CategoryContainer.BackgroundTransparency = 1
    CategoryContainer.ScrollBarThickness = 0
    CategoryContainer.Parent = Sidebar
    
    local CategoryListLayout = Instance.new("UIListLayout")
    CategoryListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CategoryListLayout.Padding = UDim.new(0, 5)
    CategoryListLayout.Parent = CategoryContainer
    
    local CategoryPadding = Instance.new("UIPadding")
    CategoryPadding.PaddingLeft = UDim.new(0, 20)
    CategoryPadding.PaddingRight = UDim.new(0, 20)
    CategoryPadding.Parent = CategoryContainer
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -220, 1, -25)
    ContentContainer.Position = UDim2.new(0, 220, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Popup Container (For dropdowns/colorpickers)
    local PopupContainer = Instance.new("Frame")
    PopupContainer.Size = UDim2.new(1, 0, 1, 0)
    PopupContainer.BackgroundTransparency = 1
    PopupContainer.ZIndex = 100
    PopupContainer.Parent = MainFrame
    
    local WindowObj = {
        Gui = gui,
        MainFrame = MainFrame,
        CategoryContainer = CategoryContainer,
        ContentContainer = ContentContainer,
        PopupContainer = PopupContainer,
        Categories = {}
    }
    
    -- Keybind Toggle
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            gui.Enabled = not gui.Enabled
        end
    end)
    
    -- Create Category
    function WindowObj:CreateCategory(options)
        options = options or {}
        local Name = options.Name or "Category"
        local Icon = options.Icon or "rbxassetid://6031280882"
        local SectionTitle = options.Section or "General"
        
        -- Create section label if not exists
        local hasSectionLabel = false
        for _, child in pairs(CategoryContainer:GetChildren()) do
            if child:IsA("TextLabel") and child.Text == SectionTitle then
                hasSectionLabel = true
            end
        end
        if not hasSectionLabel then
            local secLabel = Instance.new("TextLabel")
            secLabel.Size = UDim2.new(1, 0, 0, 25)
            secLabel.BackgroundTransparency = 1
            secLabel.Text = SectionTitle
            secLabel.TextColor3 = Theme.DisabledText
            secLabel.Font = Enum.Font.GothamMedium
            secLabel.TextSize = 12
            secLabel.TextXAlignment = Enum.TextXAlignment.Left
            secLabel.Parent = CategoryContainer
        end
        
        local CategoryBtn = Instance.new("TextButton")
        CategoryBtn.Size = UDim2.new(1, 0, 0, 36)
        CategoryBtn.BackgroundColor3 = Theme.ActiveBg
        CategoryBtn.BackgroundTransparency = 1
        CategoryBtn.Text = ""
        CategoryBtn.Parent = self.CategoryContainer
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = CategoryBtn
        
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 16, 0, 16)
        IconImg.Position = UDim2.new(0, 10, 0.5, -8)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = Icon
        IconImg.ImageColor3 = Theme.SubText
        IconImg.Parent = CategoryBtn
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -35, 1, 0)
        Label.Position = UDim2.new(0, 35, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Theme.SubText
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = CategoryBtn
        
        local CategoryContent = Instance.new("Frame")
        CategoryContent.Size = UDim2.new(1, 0, 1, 0)
        CategoryContent.BackgroundTransparency = 1
        CategoryContent.Visible = false
        CategoryContent.Parent = self.ContentContainer
        
        local SubTabContainer = Instance.new("Frame")
        SubTabContainer.Size = UDim2.new(1, 0, 0, 60)
        SubTabContainer.BackgroundTransparency = 1
        SubTabContainer.Parent = CategoryContent
        
        local SubTabListLayout = Instance.new("UIListLayout")
        SubTabListLayout.FillDirection = Enum.FillDirection.Horizontal
        SubTabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubTabListLayout.Padding = UDim.new(0, 10)
        SubTabListLayout.Parent = SubTabContainer
        
        local SubTabPadding = Instance.new("UIPadding")
        SubTabPadding.PaddingTop = UDim.new(0, 15)
        SubTabPadding.PaddingRight = UDim.new(0, 15)
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
                cat.Button:FindFirstChild("TextLabel").TextColor3 = Theme.SubText
                cat.Button:FindFirstChild("ImageLabel").ImageColor3 = Theme.SubText
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
            local TabBtn = Instance.new("TextButton")
            TabBtn.Size = UDim2.new(0, 80, 0, 32)
            TabBtn.BackgroundColor3 = Theme.ActiveBg
            TabBtn.BackgroundTransparency = 1
            TabBtn.Text = tabName
            TabBtn.TextColor3 = Theme.DisabledText
            TabBtn.Font = Enum.Font.GothamMedium
            TabBtn.TextSize = 13
            TabBtn.Parent = self.SubTabContainer
            
            -- Adjust width based on text
            TabBtn.Size = UDim2.new(0, string.len(tabName) * 8 + 30, 0, 32)
            
            local TabCorner = Instance.new("UICorner")
            TabCorner.CornerRadius = UDim.new(0, 6)
            TabCorner.Parent = TabBtn
            
            local Underline = Instance.new("Frame")
            Underline.Size = UDim2.new(0, 24, 0, 2)
            Underline.Position = UDim2.new(0.5, -12, 1, -6)
            Underline.BackgroundColor3 = Theme.Accent
            Underline.BorderSizePixel = 0
            Underline.BackgroundTransparency = 1
            Underline.Parent = TabBtn
            
            local TabCornerUL = Instance.new("UICorner")
            TabCornerUL.CornerRadius = UDim.new(1, 0)
            TabCornerUL.Parent = Underline
            
            local TabContent = Instance.new("ScrollingFrame")
            TabContent.Size = UDim2.new(1, -20, 1, -10)
            TabContent.BackgroundTransparency = 1
            TabContent.ScrollBarThickness = 0
            TabContent.Visible = false
            TabContent.Parent = self.TabsContent
            
            local TabLayout = Instance.new("UIGridLayout")
            TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TabLayout.CellSize = UDim2.new(0.5, -10, 0, 320)
            TabLayout.CellPadding = UDim2.new(0, 15, 0, 15)
            TabLayout.Parent = TabContent
            
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
                secIcon = secIcon or "rbxassetid://6031280882" -- General user icon
                
                local SectionCard = Instance.new("Frame")
                SectionCard.BackgroundColor3 = Theme.CardBg
                SectionCard.BorderSizePixel = 0
                SectionCard.Parent = self.Content
                
                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 10)
                CardCorner.Parent = SectionCard
                
                local Header = Instance.new("Frame")
                Header.Size = UDim2.new(1, 0, 0, 45)
                Header.BackgroundTransparency = 1
                Header.Parent = SectionCard
                
                local HIcon = Instance.new("ImageLabel")
                HIcon.Size = UDim2.new(0, 20, 0, 20)
                HIcon.Position = UDim2.new(0, 15, 0.5, -10)
                HIcon.BackgroundTransparency = 1
                HIcon.Image = secIcon
                HIcon.ImageColor3 = Theme.Accent
                HIcon.Parent = Header
                
                local HTitle = Instance.new("TextLabel")
                HTitle.Size = UDim2.new(1, -50, 1, 0)
                HTitle.Position = UDim2.new(0, 45, 0, 0)
                HTitle.BackgroundTransparency = 1
                HTitle.Text = secName
                HTitle.TextColor3 = Theme.Text
                HTitle.Font = Enum.Font.GothamBold
                HTitle.TextSize = 14
                HTitle.TextXAlignment = Enum.TextXAlignment.Left
                HTitle.Parent = Header
                
                -- Master Toggle
                local MasterToggle = Instance.new("TextButton")
                MasterToggle.Size = UDim2.new(0, 36, 0, 18)
                MasterToggle.Position = UDim2.new(1, -50, 0.5, -9)
                MasterToggle.BackgroundColor3 = Theme.ActiveBg
                MasterToggle.Text = ""
                MasterToggle.AutoButtonColor = false
                MasterToggle.Parent = Header
                
                local MCorner = Instance.new("UICorner")
                MCorner.CornerRadius = UDim.new(1, 0)
                MCorner.Parent = MasterToggle
                
                local MCircle = Instance.new("Frame")
                MCircle.Size = UDim2.new(0, 14, 0, 14)
                MCircle.Position = UDim2.new(0, 2, 0.5, -7)
                MCircle.BackgroundColor3 = Theme.DisabledText
                MCircle.Parent = MasterToggle
                
                local MCircleCorner = Instance.new("UICorner")
                MCircleCorner.CornerRadius = UDim.new(1, 0)
                MCircleCorner.Parent = MCircle
                
                local masterState = false
                MasterToggle.MouseButton1Click:Connect(function()
                    masterState = not masterState
                    TweenService:Create(MasterToggle, TweenInfo.new(0.2), {BackgroundColor3 = masterState and Theme.Accent or Theme.ActiveBg}):Play()
                    TweenService:Create(MCircle, TweenInfo.new(0.2), {
                        Position = masterState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                        BackgroundColor3 = masterState and Theme.Text or Theme.DisabledText
                    }):Play()
                end)
                
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Divider.Position = UDim2.new(0, 0, 0, 45)
                Divider.BackgroundColor3 = Theme.Stroke
                Divider.BorderSizePixel = 0
                Divider.Parent = SectionCard
                
                local ItemsContainer = Instance.new("ScrollingFrame")
                ItemsContainer.Size = UDim2.new(1, -30, 1, -55)
                ItemsContainer.Position = UDim2.new(0, 15, 0, 55)
                ItemsContainer.BackgroundTransparency = 1
                ItemsContainer.ScrollBarThickness = 0
                ItemsContainer.Parent = SectionCard
                
                local ItemsLayout = Instance.new("UIListLayout")
                ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ItemsLayout.Padding = UDim.new(0, 12)
                ItemsLayout.Parent = ItemsContainer
                
                local SecObj = { Container = ItemsContainer }
                
                function SecObj:CreateCheckbox(itemName, default, callback)
                    local state = default or false
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 20)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -40, 1, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.SubText
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local CheckBtn = Instance.new("TextButton")
                    CheckBtn.Size = UDim2.new(0, 18, 0, 18)
                    CheckBtn.Position = UDim2.new(1, -18, 0.5, -9)
                    CheckBtn.BackgroundColor3 = Theme.CardBg
                    CheckBtn.Text = ""
                    CheckBtn.Parent = ItemFrame
                    
                    local CheckCorner = Instance.new("UICorner")
                    CheckCorner.CornerRadius = UDim.new(0, 4)
                    CheckCorner.Parent = CheckBtn
                    
                    local CheckStroke = Instance.new("UIStroke")
                    CheckStroke.Color = Theme.Stroke
                    CheckStroke.Thickness = 1
                    CheckStroke.Parent = CheckBtn
                    
                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Size = UDim2.new(1, -6, 1, -6)
                    CheckIcon.Position = UDim2.new(0, 3, 0, 3)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = "rbxassetid://6031068420"
                    CheckIcon.ImageColor3 = Theme.Text
                    CheckIcon.Visible = state
                    CheckIcon.Parent = CheckBtn
                    
                    local function UpdateState()
                        CheckBtn.BackgroundColor3 = state and Theme.Accent or Theme.CardBg
                        CheckStroke.Color = state and Theme.Accent or Theme.Stroke
                        CheckIcon.Visible = state
                        Label.TextColor3 = state and Theme.Text or Theme.SubText
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
                    ItemFrame.Size = UDim2.new(1, 0, 0, 20)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0, 80, 1, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.Text
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local DropBtn = Instance.new("TextButton")
                    DropBtn.Size = UDim2.new(1, -90, 1, 0)
                    DropBtn.Position = UDim2.new(0, 90, 0, 0)
                    DropBtn.BackgroundColor3 = Theme.ActiveBg
                    DropBtn.Text = ""
                    DropBtn.Parent = ItemFrame
                    
                    local DropCorner = Instance.new("UICorner")
                    DropCorner.CornerRadius = UDim.new(0, 4)
                    DropCorner.Parent = DropBtn
                    
                    local SelectedLabel = Instance.new("TextLabel")
                    SelectedLabel.Size = UDim2.new(1, -25, 1, 0)
                    SelectedLabel.Position = UDim2.new(0, 5, 0, 0)
                    SelectedLabel.BackgroundTransparency = 1
                    SelectedLabel.Text = default or options[1] or ""
                    SelectedLabel.TextColor3 = Theme.DisabledText
                    SelectedLabel.Font = Enum.Font.Gotham
                    SelectedLabel.TextSize = 12
                    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    SelectedLabel.Parent = DropBtn
                    
                    local DropIcon = Instance.new("ImageLabel")
                    DropIcon.Size = UDim2.new(0, 12, 0, 12)
                    DropIcon.Position = UDim2.new(1, -18, 0.5, -6)
                    DropIcon.BackgroundTransparency = 1
                    DropIcon.Image = "rbxassetid://6031094678" -- Open icon
                    DropIcon.ImageColor3 = Theme.DisabledText
                    DropIcon.Parent = DropBtn
                    
                    -- Popup Logic
                    DropBtn.MouseButton1Click:Connect(function()
                        for _, child in pairs(PopupContainer:GetChildren()) do child:Destroy() end
                        
                        local absolutePos = DropBtn.AbsolutePosition
                        local absoluteSize = DropBtn.AbsoluteSize
                        
                        local PopupFrame = Instance.new("Frame")
                        PopupFrame.Size = UDim2.new(0, absoluteSize.X, 0, math.min(#options * 25 + 10, 150))
                        PopupFrame.Position = UDim2.new(0, absolutePos.X, 0, absolutePos.Y + absoluteSize.Y + 5)
                        PopupFrame.BackgroundColor3 = Theme.ActiveBg
                        PopupFrame.Parent = PopupContainer
                        
                        local PopCorner = Instance.new("UICorner")
                        PopCorner.CornerRadius = UDim.new(0, 6)
                        PopCorner.Parent = PopupFrame
                        
                        local PopStroke = Instance.new("UIStroke")
                        PopStroke.Color = Theme.Stroke
                        PopStroke.Thickness = 1
                        PopStroke.Parent = PopupFrame
                        
                        local PopScroll = Instance.new("ScrollingFrame")
                        PopScroll.Size = UDim2.new(1, 0, 1, 0)
                        PopScroll.BackgroundTransparency = 1
                        PopScroll.ScrollBarThickness = 2
                        PopScroll.Parent = PopupFrame
                        
                        local PopLayout = Instance.new("UIListLayout")
                        PopLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        PopLayout.Padding = UDim.new(0, 0)
                        PopLayout.Parent = PopScroll
                        
                        for _, opt in ipairs(options) do
                            local OptBtn = Instance.new("TextButton")
                            OptBtn.Size = UDim2.new(1, 0, 0, 25)
                            OptBtn.BackgroundTransparency = 1
                            OptBtn.Text = "  " .. opt
                            OptBtn.TextColor3 = (opt == SelectedLabel.Text) and Theme.Accent or Theme.SubText
                            OptBtn.Font = Enum.Font.GothamMedium
                            OptBtn.TextSize = 12
                            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                            OptBtn.Parent = PopScroll
                            
                            OptBtn.MouseButton1Click:Connect(function()
                                SelectedLabel.Text = opt
                                if callback then callback(opt) end
                                PopupFrame:Destroy()
                            end)
                        end
                        PopScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
                        
                        -- Close when clicking outside
                        local CloseBtn = Instance.new("TextButton")
                        CloseBtn.Size = UDim2.new(1, 0, 1, 0)
                        CloseBtn.BackgroundTransparency = 1
                        CloseBtn.Text = ""
                        CloseBtn.ZIndex = 99
                        CloseBtn.Parent = PopupContainer
                        CloseBtn.MouseButton1Click:Connect(function()
                            PopupContainer:ClearAllChildren()
                        end)
                        PopupFrame.ZIndex = 101
                    end)
                end
                
                function SecObj:CreateSlider(itemName, min, max, default, callback)
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, 0, 0, 20)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName .. ": " .. tostring(default)
                    Label.TextColor3 = Theme.SubText
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local SliderBg = Instance.new("Frame")
                    SliderBg.Size = UDim2.new(1, 0, 0, 6)
                    SliderBg.Position = UDim2.new(0, 0, 0, 26)
                    SliderBg.BackgroundColor3 = Theme.ActiveBg
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
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
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
                            Label.TextColor3 = Theme.Text
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
