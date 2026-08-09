local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library

-- Nebulatech / Milenium inspired theme
local Theme = {
    MainBg = Color3.fromRGB(12, 12, 15),
    SidebarBg = Color3.fromRGB(10, 10, 13),
    CardBg = Color3.fromRGB(15, 15, 18),
    CardBgHover = Color3.fromRGB(18, 18, 22),
    ActiveBg = Color3.fromRGB(29, 29, 33),
    Accent = Color3.fromRGB(145, 132, 238),
    AccentDark = Color3.fromRGB(49, 38, 112),
    Text = Color3.fromRGB(231, 231, 236),
    SubText = Color3.fromRGB(151, 151, 160),
    DisabledText = Color3.fromRGB(78, 78, 87),
    Border = Color3.fromRGB(29, 29, 34),
    BorderSoft = Color3.fromRGB(23, 23, 28),
    InputBg = Color3.fromRGB(15, 15, 18),
    InputOutline = Color3.fromRGB(53, 53, 60),
    PopupBg = Color3.fromRGB(28, 28, 33),
    White = Color3.fromRGB(241, 241, 244),
}

local Icons = {
    Sidebar = "rbxassetid://7733799275",
    User = "rbxassetid://7733658504",
    Check = "rbxassetid://7733779610",
    Dropdown = "rbxassetid://7733765103",
    Gear = "rbxassetid://7734053495",
}

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = parent
    return p
end

local function tween(obj, properties, duration)
    TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    ):Play()
end

local function textLabel(parent, text, size, font, color, align)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextSize = size or 13
    label.Font = font or Enum.Font.GothamMedium
    label.TextColor3 = color or Theme.Text
    label.TextXAlignment = align or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function divider(parent, y)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(1, -24, 0, 1)
    d.Position = UDim2.new(0, 12, 0, y)
    d.BorderSizePixel = 0
    d.BackgroundColor3 = Theme.BorderSoft
    d.Parent = parent
    return d
end

local function makeShadow(parent, sizeOffset, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    shadow.Size = UDim2.new(1, sizeOffset or 34, 1, sizeOffset or 34)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.35
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = math.max(parent.ZIndex - 1, 0)
    shadow.Parent = parent
    return shadow
end

function Library:CreateWindow(options)
    options = options or {}

    local TitleFirst = options.TitleFirst or "nebula"
    local TitleSecond = options.TitleSecond or "tech"
    local FooterLeft = options.FooterLeft or "Milenium for Counter-Strike: Global Offensive"
    local FooterRight = options.FooterRight or "nebulatech"

    local gui = Instance.new("ScreenGui")
    gui.Name = "BinHubV2"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)

    local ok = pcall(function()
        gui.Parent = CoreGui
    end)

    if not ok then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(744, 566)
    MainFrame.Position = UDim2.new(0.5, -372, 0.5, -283)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Active = true
    MainFrame.ZIndex = 5
    MainFrame.Parent = gui
    corner(MainFrame, 9)
    stroke(MainFrame, Color3.fromRGB(31, 31, 36), 1, 0.15)
    makeShadow(MainFrame, 48, 0.24)

    -- A second softer shadow gives the same heavy blurred edge seen in the reference.
    local softShadow = Instance.new("ImageLabel")
    softShadow.Name = "SoftShadow"
    softShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    softShadow.Position = UDim2.new(0.5, 0, 0.5, 11)
    softShadow.Size = UDim2.new(1, 76, 1, 76)
    softShadow.BackgroundTransparency = 1
    softShadow.Image = "rbxassetid://1316045217"
    softShadow.ImageColor3 = Color3.new(0, 0, 0)
    softShadow.ImageTransparency = 0.63
    softShadow.ScaleType = Enum.ScaleType.Slice
    softShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    softShadow.ZIndex = 3
    softShadow.Parent = MainFrame

    local clippingFrame = Instance.new("Frame")
    clippingFrame.Name = "Clip"
    clippingFrame.Size = UDim2.fromScale(1, 1)
    clippingFrame.BackgroundTransparency = 1
    clippingFrame.ClipsDescendants = true
    clippingFrame.ZIndex = 5
    clippingFrame.Parent = MainFrame
    corner(clippingFrame, 9)

    -- Sidebar background
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 204, 1, -28)
    Sidebar.BackgroundColor3 = Theme.SidebarBg
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 6
    Sidebar.Parent = clippingFrame

    local SideBorder = Instance.new("Frame")
    SideBorder.Size = UDim2.new(0, 1, 1, 0)
    SideBorder.Position = UDim2.new(1, -1, 0, 0)
    SideBorder.BackgroundColor3 = Theme.BorderSoft
    SideBorder.BorderSizePixel = 0
    SideBorder.ZIndex = 7
    SideBorder.Parent = Sidebar

    -- Logo
    local TitleArea = Instance.new("Frame")
    TitleArea.Size = UDim2.new(1, 0, 0, 70)
    TitleArea.BackgroundTransparency = 1
    TitleArea.ZIndex = 7
    TitleArea.Parent = Sidebar

    local title = textLabel(TitleArea, "", 22, Enum.Font.GothamBlack, Theme.White)
    title.RichText = true
    title.Text = string.format(
        '<font color="rgb(%d,%d,%d)">%s</font>%s',
        math.floor(Theme.Accent.R * 255),
        math.floor(Theme.Accent.G * 255),
        math.floor(Theme.Accent.B * 255),
        TitleFirst,
        TitleSecond
    )
    title.Size = UDim2.new(1, -32, 0, 34)
    title.Position = UDim2.new(0, 31, 0, 17)
    title.ZIndex = 8

    local logoUnderline = Instance.new("Frame")
    logoUnderline.Size = UDim2.fromOffset(76, 2)
    logoUnderline.Position = UDim2.new(0, 32, 0, 50)
    logoUnderline.BackgroundColor3 = Theme.Accent
    logoUnderline.BorderSizePixel = 0
    logoUnderline.ZIndex = 8
    logoUnderline.Parent = TitleArea
    corner(logoUnderline, 2)

    -- Categories
    local CategoryContainer = Instance.new("ScrollingFrame")
    CategoryContainer.Name = "Categories"
    CategoryContainer.Size = UDim2.new(1, 0, 1, -70)
    CategoryContainer.Position = UDim2.new(0, 0, 0, 70)
    CategoryContainer.BackgroundTransparency = 1
    CategoryContainer.BorderSizePixel = 0
    CategoryContainer.ScrollBarThickness = 0
    CategoryContainer.CanvasSize = UDim2.new()
    CategoryContainer.ZIndex = 7
    CategoryContainer.Parent = Sidebar
    padding(CategoryContainer, 14, 14, 0, 12)

    local CategoryListLayout = Instance.new("UIListLayout")
    CategoryListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CategoryListLayout.Padding = UDim.new(0, 4)
    CategoryListLayout.Parent = CategoryContainer

    CategoryListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        CategoryContainer.CanvasSize = UDim2.new(0, 0, 0, CategoryListLayout.AbsoluteContentSize.Y + 12)
    end)

    -- Content area
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -204, 1, -28)
    ContentContainer.Position = UDim2.new(0, 204, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 6
    ContentContainer.Parent = clippingFrame

    -- Footer
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, 0, 0, 28)
    Footer.Position = UDim2.new(0, 0, 1, -28)
    Footer.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    Footer.BorderSizePixel = 0
    Footer.ZIndex = 7
    Footer.Parent = clippingFrame

    local FooterLine = Instance.new("Frame")
    FooterLine.Size = UDim2.new(1, 0, 0, 1)
    FooterLine.BackgroundColor3 = Theme.BorderSoft
    FooterLine.BorderSizePixel = 0
    FooterLine.ZIndex = 8
    FooterLine.Parent = Footer

    local leftFooter = textLabel(Footer, FooterLeft, 10, Enum.Font.GothamMedium, Theme.DisabledText)
    leftFooter.Size = UDim2.new(0.62, -16, 1, 0)
    leftFooter.Position = UDim2.new(0, 14, 0, 0)
    leftFooter.ZIndex = 8

    local rightFooter = textLabel(Footer, "", 10, Enum.Font.GothamMedium, Theme.DisabledText, Enum.TextXAlignment.Right)
    rightFooter.RichText = true
    rightFooter.Text = string.format(
        '32 days left, <font color="rgb(%d,%d,%d)"><b>%s</b></font>',
        math.floor(Theme.Accent.R * 255),
        math.floor(Theme.Accent.G * 255),
        math.floor(Theme.Accent.B * 255),
        FooterRight
    )
    rightFooter.Size = UDim2.new(0.38, -14, 1, 0)
    rightFooter.Position = UDim2.new(0.62, 0, 0, 0)
    rightFooter.ZIndex = 8

    -- Popup overlay. It lives in MainFrame so dropdowns can sit above all cards.
    local PopupContainer = Instance.new("Frame")
    PopupContainer.Name = "PopupContainer"
    PopupContainer.Size = UDim2.fromScale(1, 1)
    PopupContainer.BackgroundTransparency = 1
    PopupContainer.Visible = false
    PopupContainer.ZIndex = 500
    PopupContainer.Parent = MainFrame

    local WindowObj = {
        Gui = gui,
        MainFrame = MainFrame,
        CategoryContainer = CategoryContainer,
        ContentContainer = ContentContainer,
        PopupContainer = PopupContainer,
        Categories = {},
    }

    -- Dragging
    local dragging = false
    local dragStart
    local startPos
    local dragInput

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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.RightControl then
            gui.Enabled = not gui.Enabled
        end
    end)

    function WindowObj:CreateCategory(options2)
        options2 = options2 or {}

        local Name = options2.Name or "Category"
        local Icon = options2.Icon or Icons.Sidebar
        local SectionTitle = options2.Section or "General"

        local alreadyHasSection = false
        for _, child in ipairs(self.CategoryContainer:GetChildren()) do
            if child:IsA("TextLabel") and child.Name == "SectionLabel" and child.Text == SectionTitle then
                alreadyHasSection = true
                break
            end
        end

        if not alreadyHasSection then
            local sec = textLabel(self.CategoryContainer, SectionTitle, 11, Enum.Font.GothamMedium, Theme.DisabledText)
            sec.Name = "SectionLabel"
            sec.Size = UDim2.new(1, 0, 0, 22)
            sec.ZIndex = 8
            sec.LayoutOrder = #self.Categories * 10
        end

        local CategoryBtn = Instance.new("TextButton")
        CategoryBtn.Name = Name .. "Category"
        CategoryBtn.Size = UDim2.new(1, 0, 0, 36)
        CategoryBtn.BackgroundColor3 = Theme.ActiveBg
        CategoryBtn.BackgroundTransparency = 1
        CategoryBtn.BorderSizePixel = 0
        CategoryBtn.Text = ""
        CategoryBtn.AutoButtonColor = false
        CategoryBtn.ZIndex = 8
        CategoryBtn.Parent = self.CategoryContainer
        corner(CategoryBtn, 6)

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.fromOffset(18, 18)
        icon.Position = UDim2.new(0, 12, 0.5, -9)
        icon.BackgroundTransparency = 1
        icon.Image = Icon
        icon.ImageColor3 = Theme.DisabledText
        icon.ZIndex = 9
        icon.Parent = CategoryBtn

        local label = textLabel(CategoryBtn, Name, 13, Enum.Font.GothamBold, Theme.DisabledText)
        label.Size = UDim2.new(1, -44, 1, 0)
        label.Position = UDim2.new(0, 44, 0, 0)
        label.ZIndex = 9

        local CategoryContent = Instance.new("Frame")
        CategoryContent.Name = Name .. "Content"
        CategoryContent.Size = UDim2.fromScale(1, 1)
        CategoryContent.BackgroundTransparency = 1
        CategoryContent.Visible = false
        CategoryContent.ZIndex = 7
        CategoryContent.Parent = self.ContentContainer

        -- Tabs bar
        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Size = UDim2.new(1, 0, 0, 58)
        TopBar.BackgroundTransparency = 1
        TopBar.ZIndex = 8
        TopBar.Parent = CategoryContent

        local TopBarLine = Instance.new("Frame")
        TopBarLine.Size = UDim2.new(1, 0, 0, 1)
        TopBarLine.Position = UDim2.new(0, 0, 1, -1)
        TopBarLine.BackgroundColor3 = Theme.BorderSoft
        TopBarLine.BorderSizePixel = 0
        TopBarLine.ZIndex = 8
        TopBarLine.Parent = TopBar

        local SubTabContainer = Instance.new("Frame")
        SubTabContainer.Name = "SubTabs"
        SubTabContainer.Size = UDim2.new(1, -24, 1, -1)
        SubTabContainer.Position = UDim2.new(0, 12, 0, 0)
        SubTabContainer.BackgroundTransparency = 1
        SubTabContainer.ZIndex = 9
        SubTabContainer.Parent = TopBar

        local tabList = Instance.new("UIListLayout")
        tabList.FillDirection = Enum.FillDirection.Horizontal
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Padding = UDim.new(0, 10)
        tabList.VerticalAlignment = Enum.VerticalAlignment.Center
        tabList.Parent = SubTabContainer

        local TabsContent = Instance.new("Frame")
        TabsContent.Name = "TabsContent"
        TabsContent.Size = UDim2.new(1, 0, 1, -58)
        TabsContent.Position = UDim2.new(0, 0, 0, 58)
        TabsContent.BackgroundTransparency = 1
        TabsContent.ZIndex = 7
        TabsContent.Parent = CategoryContent

        local CategoryObj = {
            Button = CategoryBtn,
            Content = CategoryContent,
            Label = label,
            Icon = icon,
            SubTabContainer = SubTabContainer,
            TabsContent = TabsContent,
            Tabs = {},
        }

        table.insert(self.Categories, CategoryObj)

        local function setCategorySelected(selected)
            if selected then
                tween(CategoryBtn, {BackgroundTransparency = 0}, 0.12)
                label.TextColor3 = Theme.Text
                icon.ImageColor3 = Theme.Accent
            else
                tween(CategoryBtn, {BackgroundTransparency = 1}, 0.12)
                label.TextColor3 = Theme.DisabledText
                icon.ImageColor3 = Theme.DisabledText
            end
            CategoryContent.Visible = selected
        end

        CategoryBtn.MouseEnter:Connect(function()
            if not CategoryContent.Visible then
                tween(CategoryBtn, {BackgroundTransparency = 0.55}, 0.12)
            end
        end)

        CategoryBtn.MouseLeave:Connect(function()
            if not CategoryContent.Visible then
                tween(CategoryBtn, {BackgroundTransparency = 1}, 0.12)
            end
        end)

        CategoryBtn.MouseButton1Click:Connect(function()
            for _, cat in ipairs(self.Categories) do
                cat.Content.Visible = false
                cat.Button.BackgroundTransparency = 1
                cat.Label.TextColor3 = Theme.DisabledText
                cat.Icon.ImageColor3 = Theme.DisabledText
            end
            setCategorySelected(true)
        end)

        if #self.Categories == 1 then
            setCategorySelected(true)
        end

        function CategoryObj:CreateTab(tabName)
            local TabBtn = Instance.new("TextButton")
            TabBtn.Name = tabName .. "Tab"
            TabBtn.AutomaticSize = Enum.AutomaticSize.X
            TabBtn.Size = UDim2.new(0, 0, 0, 38)
            TabBtn.BackgroundColor3 = Theme.ActiveBg
            TabBtn.BackgroundTransparency = 1
            TabBtn.BorderSizePixel = 0
            TabBtn.AutoButtonColor = false
            TabBtn.Text = tabName
            TabBtn.TextColor3 = Theme.DisabledText
            TabBtn.TextSize = 13
            TabBtn.Font = Enum.Font.GothamBold
            TabBtn.ZIndex = 10
            TabBtn.Parent = self.SubTabContainer
            padding(TabBtn, 14, 14, 0, 0)
            corner(TabBtn, 5)

            local Underline = Instance.new("Frame")
            Underline.Size = UDim2.new(1, -26, 0, 2)
            Underline.Position = UDim2.new(0, 13, 1, -2)
            Underline.BackgroundColor3 = Theme.Accent
            Underline.BorderSizePixel = 0
            Underline.BackgroundTransparency = 1
            Underline.ZIndex = 11
            Underline.Parent = TabBtn
            corner(Underline, 2)

            local TabContent = Instance.new("ScrollingFrame")
            TabContent.Name = tabName .. "TabContent"
            TabContent.Size = UDim2.fromScale(1, 1)
            TabContent.BackgroundTransparency = 1
            TabContent.BorderSizePixel = 0
            TabContent.ScrollBarThickness = 0
            TabContent.CanvasSize = UDim2.new()
            TabContent.Visible = false
            TabContent.ZIndex = 8
            TabContent.Parent = self.TabsContent
            padding(TabContent, 12, 12, 11, 12)

            local TabLayout = Instance.new("UIGridLayout")
            TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TabLayout.FillDirection = Enum.FillDirection.Horizontal
            TabLayout.CellSize = UDim2.new(0.5, -7, 0, 242)
            TabLayout.CellPadding = UDim2.new(0, 12, 0, 12)
            TabLayout.Parent = TabContent

            TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 24)
            end)

            local TabObj = {
                Button = TabBtn,
                Content = TabContent,
                Underline = Underline,
                Sections = {},
            }

            table.insert(self.Tabs, TabObj)

            local function selectTab()
                for _, t in ipairs(self.Tabs) do
                    t.Button.BackgroundTransparency = 1
                    t.Button.TextColor3 = Theme.DisabledText
                    t.Underline.BackgroundTransparency = 1
                    t.Content.Visible = false
                end

                TabBtn.BackgroundTransparency = 0
                TabBtn.TextColor3 = Theme.Text
                Underline.BackgroundTransparency = 0
                TabContent.Visible = true
            end

            TabBtn.MouseButton1Click:Connect(selectTab)

            TabBtn.MouseEnter:Connect(function()
                if not TabContent.Visible then
                    TabBtn.TextColor3 = Theme.SubText
                end
            end)

            TabBtn.MouseLeave:Connect(function()
                if not TabContent.Visible then
                    TabBtn.TextColor3 = Theme.DisabledText
                end
            end)

            if #self.Tabs == 1 then
                selectTab()
            end

            function TabObj:CreateSection(secName, secIcon)
                secIcon = secIcon or Icons.User

                local SectionCard = Instance.new("Frame")
                SectionCard.Name = secName .. "Section"
                SectionCard.BackgroundColor3 = Theme.CardBg
                SectionCard.BorderSizePixel = 0
                SectionCard.ZIndex = 9
                SectionCard.Parent = self.Content
                corner(SectionCard, 5)
                stroke(SectionCard, Theme.BorderSoft, 1, 0)

                local Header = Instance.new("Frame")
                Header.Name = "Header"
                Header.Size = UDim2.new(1, 0, 0, 38)
                Header.BackgroundTransparency = 1
                Header.ZIndex = 10
                Header.Parent = SectionCard

                local HIcon = Instance.new("ImageLabel")
                HIcon.Size = UDim2.fromOffset(19, 19)
                HIcon.Position = UDim2.new(0, 12, 0.5, -9)
                HIcon.BackgroundTransparency = 1
                HIcon.Image = secIcon
                HIcon.ImageColor3 = Theme.Accent
                HIcon.ZIndex = 11
                HIcon.Parent = Header

                local HTitle = textLabel(Header, secName, 13, Enum.Font.GothamBold, Theme.Text)
                HTitle.Size = UDim2.new(1, -94, 1, 0)
                HTitle.Position = UDim2.new(0, 38, 0, 0)
                HTitle.ZIndex = 11

                -- Section master toggle. This visually matches the screenshots.
                local MasterToggle = Instance.new("TextButton")
                MasterToggle.Name = "MasterToggle"
                MasterToggle.Size = UDim2.fromOffset(39, 20)
                MasterToggle.Position = UDim2.new(1, -50, 0.5, -10)
                MasterToggle.BackgroundColor3 = Theme.InputBg
                MasterToggle.BorderSizePixel = 0
                MasterToggle.AutoButtonColor = false
                MasterToggle.Text = ""
                MasterToggle.ZIndex = 11
                MasterToggle.Parent = Header
                corner(MasterToggle, 10)
                stroke(MasterToggle, Theme.InputOutline, 1, 0.35)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(14, 14)
                knob.Position = UDim2.new(0, 3, 0.5, -7)
                knob.BackgroundColor3 = Color3.fromRGB(78, 78, 82)
                knob.BorderSizePixel = 0
                knob.ZIndex = 12
                knob.Parent = MasterToggle
                corner(knob, 7)

                local masterState = false
                local masterChangedCallbacks = {}

                local function updateMaster(animated)
                    local t = animated and 0.16 or 0
                    tween(MasterToggle, {
                        BackgroundColor3 = masterState and Theme.Accent or Theme.InputBg,
                    }, t)
                    tween(knob, {
                        Position = masterState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                        BackgroundColor3 = masterState and Theme.White or Color3.fromRGB(78, 78, 82),
                    }, t)

                    for _, cb in ipairs(masterChangedCallbacks) do
                        pcall(cb, masterState)
                    end
                end

                MasterToggle.MouseButton1Click:Connect(function()
                    masterState = not masterState
                    updateMaster(true)
                end)

                divider(SectionCard, 38)

                local ItemsContainer = Instance.new("ScrollingFrame")
                ItemsContainer.Name = "Items"
                ItemsContainer.Size = UDim2.new(1, 0, 1, -39)
                ItemsContainer.Position = UDim2.new(0, 0, 0, 39)
                ItemsContainer.BackgroundTransparency = 1
                ItemsContainer.BorderSizePixel = 0
                ItemsContainer.ScrollBarThickness = 0
                ItemsContainer.CanvasSize = UDim2.new()
                ItemsContainer.ZIndex = 10
                ItemsContainer.Parent = SectionCard

                local ItemsLayout = Instance.new("UIListLayout")
                ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ItemsLayout.Padding = UDim.new(0, 0)
                ItemsLayout.Parent = ItemsContainer

                ItemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, ItemsLayout.AbsoluteContentSize.Y)
                end)

                local SecObj = {
                    Container = ItemsContainer,
                    Card = SectionCard,
                }

                function SecObj:SetMaster(state)
                    masterState = state and true or false
                    updateMaster(true)
                end

                function SecObj:OnMasterChanged(callback)
                    if typeof(callback) == "function" then
                        table.insert(masterChangedCallbacks, callback)
                    end
                end

                local function rowDivider(row)
                    local line = Instance.new("Frame")
                    line.Size = UDim2.new(1, -24, 0, 1)
                    line.Position = UDim2.new(0, 12, 1, -1)
                    line.BackgroundColor3 = Theme.BorderSoft
                    line.BorderSizePixel = 0
                    line.ZIndex = 11
                    line.Parent = row
                end

                function SecObj:CreateCheckbox(itemName, default, callback)
                    local state = default and true or false

                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Name = itemName .. "Row"
                    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.ZIndex = 11
                    ItemFrame.Parent = self.Container

                    local Label = textLabel(ItemFrame, itemName, 13, Enum.Font.GothamMedium, Theme.Text)
                    Label.Size = UDim2.new(1, -58, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.ZIndex = 12

                    local CheckBtn = Instance.new("TextButton")
                    CheckBtn.Size = UDim2.fromOffset(18, 18)
                    CheckBtn.Position = UDim2.new(1, -30, 0.5, -9)
                    CheckBtn.BackgroundColor3 = Theme.InputBg
                    CheckBtn.BorderSizePixel = 0
                    CheckBtn.AutoButtonColor = false
                    CheckBtn.Text = ""
                    CheckBtn.ZIndex = 12
                    CheckBtn.Parent = ItemFrame
                    corner(CheckBtn, 3)
                    local checkStroke = stroke(CheckBtn, Theme.InputOutline, 1, 0)

                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Size = UDim2.fromOffset(12, 12)
                    CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = Icons.Check
                    CheckIcon.ImageColor3 = Theme.White
                    CheckIcon.Visible = state
                    CheckIcon.ZIndex = 13
                    CheckIcon.Parent = CheckBtn

                    local function update(runCallback)
                        if state then
                            CheckBtn.BackgroundColor3 = Theme.Accent
                            checkStroke.Color = Theme.Accent
                            CheckIcon.Visible = true
                        else
                            CheckBtn.BackgroundColor3 = Theme.InputBg
                            checkStroke.Color = Theme.InputOutline
                            CheckIcon.Visible = false
                        end

                        if runCallback and callback then
                            pcall(callback, state)
                        end
                    end

                    CheckBtn.MouseButton1Click:Connect(function()
                        state = not state
                        update(true)
                    end)

                    rowDivider(ItemFrame)
                    update(true)

                    return {
                        Set = function(_, value)
                            state = value and true or false
                            update(true)
                        end,
                        Get = function()
                            return state
                        end,
                    }
                end

                function SecObj:CreateSlider(itemName, min, max, default, callback)
                    min = tonumber(min) or 0
                    max = tonumber(max) or 100
                    default = math.clamp(tonumber(default) or min, min, max)
                    local value = default

                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Name = itemName .. "Row"
                    ItemFrame.Size = UDim2.new(1, 0, 0, 48)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.ZIndex = 11
                    ItemFrame.Parent = self.Container

                    local Label = textLabel(ItemFrame, itemName, 12, Enum.Font.GothamMedium, Theme.Text)
                    Label.Size = UDim2.new(0.62, -12, 0, 22)
                    Label.Position = UDim2.new(0, 12, 0, 2)
                    Label.ZIndex = 12

                    local ValueLabel = textLabel(ItemFrame, tostring(value), 11, Enum.Font.GothamMedium, Theme.SubText, Enum.TextXAlignment.Right)
                    ValueLabel.Size = UDim2.new(0.38, -12, 0, 22)
                    ValueLabel.Position = UDim2.new(0.62, 0, 0, 2)
                    ValueLabel.ZIndex = 12

                    local SliderBg = Instance.new("Frame")
                    SliderBg.Size = UDim2.new(1, -24, 0, 4)
                    SliderBg.Position = UDim2.new(0, 12, 0, 31)
                    SliderBg.BackgroundColor3 = Color3.fromRGB(29, 29, 34)
                    SliderBg.BorderSizePixel = 0
                    SliderBg.ZIndex = 12
                    SliderBg.Parent = ItemFrame
                    corner(SliderBg, 2)

                    local SliderFill = Instance.new("Frame")
                    SliderFill.BackgroundColor3 = Theme.Accent
                    SliderFill.BorderSizePixel = 0
                    SliderFill.ZIndex = 13
                    SliderFill.Parent = SliderBg
                    corner(SliderFill, 2)

                    local SliderKnob = Instance.new("Frame")
                    SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                    SliderKnob.Size = UDim2.fromOffset(10, 10)
                    SliderKnob.BackgroundColor3 = Theme.White
                    SliderKnob.BorderSizePixel = 0
                    SliderKnob.ZIndex = 14
                    SliderKnob.Parent = SliderBg
                    corner(SliderKnob, 5)
                    stroke(SliderKnob, Theme.Accent, 2, 0)

                    local SliderBtn = Instance.new("TextButton")
                    SliderBtn.Size = UDim2.new(1, 0, 0, 22)
                    SliderBtn.Position = UDim2.new(0, 0, 0.5, -11)
                    SliderBtn.BackgroundTransparency = 1
                    SliderBtn.Text = ""
                    SliderBtn.ZIndex = 15
                    SliderBtn.Parent = SliderBg

                    local draggingSlider = false

                    local function setValue(newValue, runCallback)
                        value = math.clamp(newValue, min, max)
                        if math.floor(value) == value then
                            value = math.floor(value)
                        end

                        local percent = (value - min) / math.max(max - min, 1)
                        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
                        ValueLabel.Text = tostring(value)

                        if runCallback and callback then
                            pcall(callback, value)
                        end
                    end

                    local function setFromInput(input)
                        local sliderX = SliderBg.AbsolutePosition.X
                        local sliderWidth = SliderBg.AbsoluteSize.X
                        if sliderWidth <= 0 then
                            return
                        end

                        local percent = math.clamp((input.Position.X - sliderX) / sliderWidth, 0, 1)
                        local newValue = math.floor(min + ((max - min) * percent) + 0.5)
                        setValue(newValue, true)
                    end

                    SliderBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSlider = true
                            setFromInput(input)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            setFromInput(input)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            draggingSlider = false
                        end
                    end)

                    rowDivider(ItemFrame)
                    setValue(value, true)

                    return {
                        Set = function(_, v)
                            setValue(tonumber(v) or min, true)
                        end,
                        Get = function()
                            return value
                        end,
                    }
                end

                function SecObj:CreateDropdown(itemName, options, default, callback)
                    options = options or {}
                    local selected = default or options[1] or ""

                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Name = itemName .. "Row"
                    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.ZIndex = 11
                    ItemFrame.Parent = self.Container

                    local Label = textLabel(ItemFrame, itemName, 13, Enum.Font.GothamMedium, Theme.Text)
                    Label.Size = UDim2.new(0, 88, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.ZIndex = 12

                    local DropBtn = Instance.new("TextButton")
                    DropBtn.Size = UDim2.new(1, -112, 0, 24)
                    DropBtn.Position = UDim2.new(0, 100, 0.5, -12)
                    DropBtn.BackgroundColor3 = Theme.InputBg
                    DropBtn.BorderSizePixel = 0
                    DropBtn.AutoButtonColor = false
                    DropBtn.Text = ""
                    DropBtn.ClipsDescendants = true
                    DropBtn.ZIndex = 12
                    DropBtn.Parent = ItemFrame
                    corner(DropBtn, 3)
                    stroke(DropBtn, Theme.BorderSoft, 1, 0)

                    local SelectedLabel = textLabel(DropBtn, selected, 11, Enum.Font.GothamMedium, Theme.DisabledText)
                    SelectedLabel.Size = UDim2.new(1, -24, 1, 0)
                    SelectedLabel.Position = UDim2.new(0, 7, 0, 0)
                    SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    SelectedLabel.ZIndex = 13

                    local DropIcon = Instance.new("ImageLabel")
                    DropIcon.Size = UDim2.fromOffset(10, 10)
                    DropIcon.Position = UDim2.new(1, -16, 0.5, -5)
                    DropIcon.BackgroundTransparency = 1
                    DropIcon.Image = Icons.Dropdown
                    DropIcon.ImageColor3 = Theme.DisabledText
                    DropIcon.ZIndex = 13
                    DropIcon.Parent = DropBtn

                    local function closePopup()
                        WindowObj.PopupContainer.Visible = false
                        WindowObj.PopupContainer:ClearAllChildren()
                    end

                    local function openPopup()
                        closePopup()
                        WindowObj.PopupContainer.Visible = true

                        local blocker = Instance.new("TextButton")
                        blocker.Size = UDim2.fromScale(1, 1)
                        blocker.BackgroundTransparency = 1
                        blocker.Text = ""
                        blocker.AutoButtonColor = false
                        blocker.ZIndex = 500
                        blocker.Parent = WindowObj.PopupContainer
                        blocker.MouseButton1Click:Connect(closePopup)

                        local mainAbs = MainFrame.AbsolutePosition
                        local dropAbs = DropBtn.AbsolutePosition
                        local dropSize = DropBtn.AbsoluteSize
                        local localX = dropAbs.X - mainAbs.X
                        local localY = dropAbs.Y - mainAbs.Y
                        local popupHeight = math.min(#options * 25 + 8, 142)

                        local Popup = Instance.new("Frame")
                        Popup.Name = "DropdownPopup"
                        Popup.Size = UDim2.fromOffset(math.max(dropSize.X, 132), popupHeight)
                        Popup.Position = UDim2.fromOffset(localX, localY + dropSize.Y + 4)
                        Popup.BackgroundColor3 = Theme.PopupBg
                        Popup.BorderSizePixel = 0
                        Popup.ZIndex = 510
                        Popup.Parent = WindowObj.PopupContainer
                        corner(Popup, 3)
                        stroke(Popup, Theme.Border, 1, 0)
                        makeShadow(Popup, 26, 0.45).ZIndex = 509

                        local List = Instance.new("ScrollingFrame")
                        List.Size = UDim2.new(1, -2, 1, -8)
                        List.Position = UDim2.new(0, 1, 0, 4)
                        List.BackgroundTransparency = 1
                        List.BorderSizePixel = 0
                        List.ScrollBarThickness = 2
                        List.ScrollBarImageColor3 = Theme.Accent
                        List.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
                        List.ZIndex = 511
                        List.Parent = Popup

                        local listLayout = Instance.new("UIListLayout")
                        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        listLayout.Parent = List

                        for _, option in ipairs(options) do
                            local OptionBtn = Instance.new("TextButton")
                            OptionBtn.Size = UDim2.new(1, 0, 0, 25)
                            OptionBtn.BackgroundColor3 = Theme.ActiveBg
                            OptionBtn.BackgroundTransparency = 1
                            OptionBtn.BorderSizePixel = 0
                            OptionBtn.AutoButtonColor = false
                            OptionBtn.Text = option
                            OptionBtn.TextSize = 12
                            OptionBtn.Font = Enum.Font.GothamMedium
                            OptionBtn.TextColor3 = option == selected and Theme.Accent or Theme.DisabledText
                            OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                            OptionBtn.ZIndex = 512
                            OptionBtn.Parent = List
                            padding(OptionBtn, 9, 6, 0, 0)

                            OptionBtn.MouseEnter:Connect(function()
                                OptionBtn.BackgroundTransparency = 0.5
                                if option ~= selected then
                                    OptionBtn.TextColor3 = Theme.SubText
                                end
                            end)

                            OptionBtn.MouseLeave:Connect(function()
                                OptionBtn.BackgroundTransparency = 1
                                OptionBtn.TextColor3 = option == selected and Theme.Accent or Theme.DisabledText
                            end)

                            OptionBtn.MouseButton1Click:Connect(function()
                                selected = option
                                SelectedLabel.Text = selected
                                if callback then
                                    pcall(callback, selected)
                                end
                                closePopup()
                            end)
                        end
                    end

                    DropBtn.MouseButton1Click:Connect(openPopup)
                    rowDivider(ItemFrame)

                    if callback then
                        pcall(callback, selected)
                    end

                    return {
                        Set = function(_, value)
                            if table.find(options, value) then
                                selected = value
                                SelectedLabel.Text = value
                                if callback then
                                    pcall(callback, selected)
                                end
                            end
                        end,
                        Get = function()
                            return selected
                        end,
                    }
                end

                -- Optional visual row matching the small color swatches in the reference UI.
                function SecObj:CreateColor(itemName, defaultColor, callback)
                    local current = defaultColor or Theme.Accent

                    local ItemFrame = Instance.new("Frame")
                    ItemFrame.Name = itemName .. "Row"
                    ItemFrame.Size = UDim2.new(1, 0, 0, 36)
                    ItemFrame.BackgroundTransparency = 1
                    ItemFrame.ZIndex = 11
                    ItemFrame.Parent = self.Container

                    local Label = textLabel(ItemFrame, itemName, 13, Enum.Font.GothamMedium, Theme.Text)
                    Label.Size = UDim2.new(1, -80, 1, 0)
                    Label.Position = UDim2.new(0, 12, 0, 0)
                    Label.ZIndex = 12

                    local Swatch = Instance.new("TextButton")
                    Swatch.Size = UDim2.fromOffset(18, 18)
                    Swatch.Position = UDim2.new(1, -56, 0.5, -9)
                    Swatch.BackgroundColor3 = current
                    Swatch.BorderSizePixel = 0
                    Swatch.Text = ""
                    Swatch.AutoButtonColor = false
                    Swatch.ZIndex = 12
                    Swatch.Parent = ItemFrame
                    corner(Swatch, 3)
                    stroke(Swatch, Color3.fromRGB(210, 210, 214), 1, 0.2)

                    local function openPicker()
                        WindowObj.PopupContainer:ClearAllChildren()
                        WindowObj.PopupContainer.Visible = true

                        local blocker = Instance.new("TextButton")
                        blocker.Size = UDim2.fromScale(1, 1)
                        blocker.BackgroundTransparency = 1
                        blocker.Text = ""
                        blocker.ZIndex = 500
                        blocker.Parent = WindowObj.PopupContainer
                        blocker.MouseButton1Click:Connect(function()
                            WindowObj.PopupContainer.Visible = false
                            WindowObj.PopupContainer:ClearAllChildren()
                        end)

                        local mainAbs = MainFrame.AbsolutePosition
                        local swatchAbs = Swatch.AbsolutePosition
                        local localX = swatchAbs.X - mainAbs.X
                        local localY = swatchAbs.Y - mainAbs.Y

                        local Picker = Instance.new("Frame")
                        Picker.Size = UDim2.fromOffset(164, 186)
                        Picker.Position = UDim2.fromOffset(localX + 25, localY - 20)
                        Picker.BackgroundColor3 = Theme.PopupBg
                        Picker.BorderSizePixel = 0
                        Picker.ZIndex = 510
                        Picker.Parent = WindowObj.PopupContainer
                        corner(Picker, 4)
                        stroke(Picker, Theme.Border, 1, 0)
                        makeShadow(Picker, 28, 0.42).ZIndex = 509

                        local sv = Instance.new("ImageButton")
                        sv.Size = UDim2.new(1, -12, 0, 118)
                        sv.Position = UDim2.new(0, 6, 0, 6)
                        sv.BackgroundColor3 = Color3.fromHSV(0.68, 1, 1)
                        sv.BorderSizePixel = 0
                        sv.AutoButtonColor = false
                        sv.Image = "rbxassetid://4155801252"
                        sv.ZIndex = 511
                        sv.Parent = Picker

                        local hue = Instance.new("ImageButton")
                        hue.Size = UDim2.new(1, -12, 0, 9)
                        hue.Position = UDim2.new(0, 6, 0, 132)
                        hue.BackgroundColor3 = Color3.new(1, 1, 1)
                        hue.BorderSizePixel = 0
                        hue.AutoButtonColor = false
                        hue.Image = "rbxassetid://3641079629"
                        hue.ZIndex = 511
                        hue.Parent = Picker

                        local preview = Instance.new("Frame")
                        preview.Size = UDim2.new(1, -12, 0, 24)
                        preview.Position = UDim2.new(0, 6, 1, -32)
                        preview.BackgroundColor3 = current
                        preview.BorderSizePixel = 0
                        preview.ZIndex = 511
                        preview.Parent = Picker
                        corner(preview, 2)

                        local h, s, v = current:ToHSV()

                        local function apply()
                            current = Color3.fromHSV(h, s, v)
                            Swatch.BackgroundColor3 = current
                            preview.BackgroundColor3 = current
                            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                            if callback then
                                pcall(callback, current)
                            end
                        end

                        local function updateSV(input)
                            local pos = sv.AbsolutePosition
                            local size = sv.AbsoluteSize
                            s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                            v = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                            apply()
                        end

                        local function updateHue(input)
                            local pos = hue.AbsolutePosition
                            local size = hue.AbsoluteSize
                            h = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                            apply()
                        end

                        local draggingSV = false
                        local draggingHue = false

                        sv.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                draggingSV = true
                                updateSV(input)
                            end
                        end)

                        hue.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                draggingHue = true
                                updateHue(input)
                            end
                        end)

                        UserInputService.InputChanged:Connect(function(input)
                            if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                                updateSV(input)
                            elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                                updateHue(input)
                            end
                        end)

                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                draggingSV = false
                                draggingHue = false
                            end
                        end)

                        apply()
                    end

                    Swatch.MouseButton1Click:Connect(openPicker)
                    rowDivider(ItemFrame)

                    return {
                        Set = function(_, color)
                            if typeof(color) == "Color3" then
                                current = color
                                Swatch.BackgroundColor3 = current
                                if callback then
                                    pcall(callback, current)
                                end
                            end
                        end,
                        Get = function()
                            return current
                        end,
                    }
                end

                table.insert(self.Sections, SecObj)
                return SecObj
            end

            return TabObj
        end

        return CategoryObj
    end

    return WindowObj
end

return Library
