local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library

local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    Sidebar = Color3.fromRGB(20, 20, 24),
    CardBg = Color3.fromRGB(22, 22, 26),
    Accent = Color3.fromRGB(123, 97, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 160),
    Stroke = Color3.fromRGB(35, 35, 40)
}

function Library:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "binhub"
    
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
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = gui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
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
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar
    
    -- Hide right corners of sidebar
    local HideCorner = Instance.new("Frame")
    HideCorner.Size = UDim2.new(0, 10, 1, 0)
    HideCorner.Position = UDim2.new(1, -10, 0, 0)
    HideCorner.BackgroundColor3 = Theme.Sidebar
    HideCorner.BorderSizePixel = 0
    HideCorner.Parent = Sidebar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 60)
    Title.Position = UDim2.new(0, 20, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = WindowName
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Sidebar
    
    local TitleUnderline = Instance.new("Frame")
    TitleUnderline.Size = UDim2.new(0, 45, 0, 2)
    TitleUnderline.Position = UDim2.new(0, 20, 0, 45)
    TitleUnderline.BackgroundColor3 = Theme.Accent
    TitleUnderline.BorderSizePixel = 0
    TitleUnderline.Parent = Sidebar
    
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
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -180, 1, 0)
    ContentContainer.Position = UDim2.new(0, 180, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    local WindowObj = {
        Gui = gui,
        MainFrame = MainFrame,
        CategoryContainer = CategoryContainer,
        ContentContainer = ContentContainer,
        CurrentCategory = nil,
        Categories = {}
    }
    
    -- Keybind Toggle
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            gui.Enabled = not gui.Enabled
        end
    end)
    
    function WindowObj:CreateCategory(options)
        options = options or {}
        local Name = options.Name or "Category"
        local Icon = options.Icon or "rbxassetid://6034287525"
        
        local CategoryBtn = Instance.new("TextButton")
        CategoryBtn.Size = UDim2.new(1, -20, 0, 35)
        CategoryBtn.Position = UDim2.new(0, 10, 0, 0)
        CategoryBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        CategoryBtn.BackgroundTransparency = 1
        CategoryBtn.Text = ""
        CategoryBtn.Parent = self.CategoryContainer
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = CategoryBtn
        
        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 16, 0, 16)
        IconImg.Position = UDim2.new(0, 10, 0.5, -8)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = Icon
        IconImg.ImageColor3 = Theme.SubText
        IconImg.Parent = CategoryBtn
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -40, 1, 0)
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
        SubTabContainer.Size = UDim2.new(1, 0, 0, 50)
        SubTabContainer.BackgroundTransparency = 1
        SubTabContainer.Parent = CategoryContent
        
        local SubTabListLayout = Instance.new("UIListLayout")
        SubTabListLayout.FillDirection = Enum.FillDirection.Horizontal
        SubTabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubTabListLayout.Padding = UDim.new(0, 20)
        SubTabListLayout.Parent = SubTabContainer
        
        local SubTabPadding = Instance.new("UIPadding")
        SubTabPadding.PaddingLeft = UDim.new(0, 20)
        SubTabPadding.PaddingTop = UDim.new(0, 15)
        SubTabPadding.Parent = SubTabContainer
        
        local TabsContent = Instance.new("Frame")
        TabsContent.Size = UDim2.new(1, 0, 1, -50)
        TabsContent.Position = UDim2.new(0, 0, 0, 50)
        TabsContent.BackgroundTransparency = 1
        TabsContent.Parent = CategoryContent
        
        local CategoryObj = {
            Button = CategoryBtn,
            Content = CategoryContent,
            SubTabContainer = SubTabContainer,
            TabsContent = TabsContent,
            Tabs = {},
            CurrentTab = nil
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
            TabBtn.Size = UDim2.new(0, 0, 1, 0)
            TabBtn.AutomaticSize = Enum.AutomaticSize.X
            TabBtn.BackgroundTransparency = 1
            TabBtn.Text = tabName
            TabBtn.TextColor3 = Theme.SubText
            TabBtn.Font = Enum.Font.GothamMedium
            TabBtn.TextSize = 14
            TabBtn.Parent = self.SubTabContainer
            
            local Underline = Instance.new("Frame")
            Underline.Size = UDim2.new(1, 0, 0, 2)
            Underline.Position = UDim2.new(0, 0, 1, 5)
            Underline.BackgroundColor3 = Theme.Accent
            Underline.BorderSizePixel = 0
            Underline.BackgroundTransparency = 1
            Underline.Parent = TabBtn
            
            local TabContent = Instance.new("ScrollingFrame")
            TabContent.Size = UDim2.new(1, -20, 1, -20)
            TabContent.Position = UDim2.new(0, 20, 0, 0)
            TabContent.BackgroundTransparency = 1
            TabContent.ScrollBarThickness = 0
            TabContent.Visible = false
            TabContent.Parent = self.TabsContent
            
            local TabLayout = Instance.new("UIGridLayout")
            TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TabLayout.CellSize = UDim2.new(0.5, -10, 0, 300)
            TabLayout.CellPadding = UDim2.new(0, 10, 0, 10)
            TabLayout.Parent = TabContent
            
            local TabObj = {
                Button = TabBtn,
                Content = TabContent,
                Underline = Underline,
                Sections = {}
            }
            table.insert(self.Tabs, TabObj)
            
            TabBtn.MouseButton1Click:Connect(function()
                for _, t in pairs(self.Tabs) do
                    t.Button.TextColor3 = Theme.SubText
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
                secIcon = secIcon or "rbxassetid://7733964719" -- User icon default
                
                local SectionCard = Instance.new("Frame")
                SectionCard.BackgroundColor3 = Theme.CardBg
                SectionCard.BorderSizePixel = 0
                SectionCard.Parent = self.Content
                
                local CardCorner = Instance.new("UICorner")
                CardCorner.CornerRadius = UDim.new(0, 8)
                CardCorner.Parent = SectionCard
                
                local CardStroke = Instance.new("UIStroke")
                CardStroke.Color = Theme.Stroke
                CardStroke.Thickness = 1
                CardStroke.Parent = SectionCard
                
                local Header = Instance.new("Frame")
                Header.Size = UDim2.new(1, 0, 0, 40)
                Header.BackgroundTransparency = 1
                Header.Parent = SectionCard
                
                local HIcon = Instance.new("ImageLabel")
                HIcon.Size = UDim2.new(0, 16, 0, 16)
                HIcon.Position = UDim2.new(0, 15, 0.5, -8)
                HIcon.BackgroundTransparency = 1
                HIcon.Image = secIcon
                HIcon.ImageColor3 = Theme.Accent
                HIcon.Parent = Header
                
                local HTitle = Instance.new("TextLabel")
                HTitle.Size = UDim2.new(1, -40, 1, 0)
                HTitle.Position = UDim2.new(0, 40, 0, 0)
                HTitle.BackgroundTransparency = 1
                HTitle.Text = secName
                HTitle.TextColor3 = Theme.Text
                HTitle.Font = Enum.Font.GothamBold
                HTitle.TextSize = 14
                HTitle.TextXAlignment = Enum.TextXAlignment.Left
                HTitle.Parent = Header
                
                -- Master Toggle for Card (Visual only as requested)
                local MasterToggle = Instance.new("Frame")
                MasterToggle.Size = UDim2.new(0, 36, 0, 18)
                MasterToggle.Position = UDim2.new(1, -50, 0.5, -9)
                MasterToggle.BackgroundColor3 = Theme.Accent
                MasterToggle.Parent = Header
                
                local MCorner = Instance.new("UICorner")
                MCorner.CornerRadius = UDim.new(1, 0)
                MCorner.Parent = MasterToggle
                
                local MCircle = Instance.new("Frame")
                MCircle.Size = UDim2.new(0, 14, 0, 14)
                MCircle.Position = UDim2.new(1, -16, 0.5, -7)
                MCircle.BackgroundColor3 = Theme.Text
                MCircle.Parent = MasterToggle
                
                local MCircleCorner = Instance.new("UICorner")
                MCircleCorner.CornerRadius = UDim.new(1, 0)
                MCircleCorner.Parent = MCircle
                
                local ItemsContainer = Instance.new("ScrollingFrame")
                ItemsContainer.Size = UDim2.new(1, -20, 1, -50)
                ItemsContainer.Position = UDim2.new(0, 10, 0, 45)
                ItemsContainer.BackgroundTransparency = 1
                ItemsContainer.ScrollBarThickness = 0
                ItemsContainer.Parent = SectionCard
                
                local ItemsLayout = Instance.new("UIListLayout")
                ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ItemsLayout.Padding = UDim.new(0, 10)
                ItemsLayout.Parent = ItemsContainer
                
                local SecObj = {
                    Container = ItemsContainer
                }
                
                function SecObj:CreateCheckbox(itemName, default, callback)
                    local state = default or false
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 24)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.Parent = self.Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -30, 1, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = itemName
                    Label.TextColor3 = Theme.SubText
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ItemFrame
                    
                    local CheckBtn = Instance.new("TextButton")
                    CheckBtn.Size = UDim2.new(0, 16, 0, 16)
                    CheckBtn.Position = UDim2.new(1, -16, 0.5, -8)
                    CheckBtn.BackgroundColor3 = state and Theme.Accent or Theme.Background
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
                    CheckIcon.Size = UDim2.new(1, -4, 1, -4)
                    CheckIcon.Position = UDim2.new(0, 2, 0, 2)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = "rbxassetid://6031068420"
                    CheckIcon.ImageColor3 = Theme.Text
                    CheckIcon.Visible = state
                    CheckIcon.Parent = CheckBtn
                    
                    local function UpdateState()
                        CheckBtn.BackgroundColor3 = state and Theme.Accent or Theme.Background
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
                
                function SecObj:CreateSlider(itemName, min, max, default, callback)
                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Size = UDim2.new(1, 0, 0, 40)
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
                    SliderBg.Size = UDim2.new(1, 0, 0, 4)
                    SliderBg.Position = UDim2.new(0, 0, 0, 28)
                    SliderBg.BackgroundColor3 = Theme.Background
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
                    SliderBtn.Size = UDim2.new(1, 0, 1, 10)
                    SliderBtn.Position = UDim2.new(0, 0, 0, -5)
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
                
                -- Returns the section so we can add to it
                return SecObj
            end
            
            return TabObj
        end
        
        return CategoryObj
    end
    
    return WindowObj
end

return Library
