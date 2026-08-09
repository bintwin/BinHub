local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library

local clr = {
    bg = Color3.fromRGB(18, 18, 21),
    cardBg = Color3.fromRGB(24, 24, 28),
    tabActiveBg = Color3.fromRGB(32, 32, 38),
    purple = Color3.fromRGB(113, 90, 235),
    white = Color3.fromRGB(235, 235, 235),
    gray = Color3.fromRGB(150, 150, 155),
    dimGray = Color3.fromRGB(85, 85, 90),
    darkGray = Color3.fromRGB(40, 40, 45),
    line = Color3.fromRGB(30, 30, 34),
    bottomBar = Color3.fromRGB(14, 14, 16),
    checkOff = Color3.fromRGB(28, 28, 33),
    toggleOff = Color3.fromRGB(28, 28, 33)
}

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local titleA = cfg.TitleFirst or "bin"
    local titleB = cfg.TitleSecond or "hub"
    local footL = cfg.FooterLeft or "Milenium for Counter-Strike: Global Offensive"
    local footR = cfg.FooterRight or "binhub"

    local gui = Instance.new("ScreenGui")
    gui.Name = "BinHubV2"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then
        gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 780, 0, 530)
    main.Position = UDim2.new(0.5, -390, 0.5, -265)
    main.BackgroundColor3 = clr.bg
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- Shadow (big blurred dark image behind)
    local shd = Instance.new("ImageLabel")
    shd.Name = "Shd"
    shd.AnchorPoint = Vector2.new(0.5, 0.5)
    shd.BackgroundTransparency = 1
    shd.Position = UDim2.new(0.5, 0, 0.5, 4)
    shd.Size = UDim2.new(1, 60, 1, 60)
    shd.Image = "rbxassetid://4743306508"
    shd.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shd.ImageTransparency = 0.15
    shd.ScaleType = Enum.ScaleType.Slice
    shd.SliceCenter = Rect.new(15, 15, 285, 285)
    shd.ZIndex = -1
    shd.Parent = main

    -- Drag
    local drgn, drgI, drgS, drgP
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drgn = true; drgS = i.Position; drgP = main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drgn = false end end)
        end
    end)
    main.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then drgI = i end end)
    UserInputService.InputChanged:Connect(function(i)
        if i == drgI and drgn then
            local d = i.Position - drgS
            main.Position = UDim2.new(drgP.X.Scale, drgP.X.Offset + d.X, drgP.Y.Scale, drgP.Y.Offset + d.Y)
        end
    end)

    -- ============ BOTTOM BAR ============
    local btm = Instance.new("Frame")
    btm.Size = UDim2.new(1, 0, 0, 28)
    btm.Position = UDim2.new(0, 0, 1, -28)
    btm.BackgroundColor3 = clr.bottomBar
    btm.BorderSizePixel = 0
    btm.Parent = main
    Instance.new("UICorner", btm).CornerRadius = UDim.new(0, 10)
    local btmHide = Instance.new("Frame")
    btmHide.Size = UDim2.new(1, 0, 0, 12)
    btmHide.BackgroundColor3 = clr.bottomBar
    btmHide.BorderSizePixel = 0
    btmHide.Parent = btm
    local btmBorder = Instance.new("Frame")
    btmBorder.Size = UDim2.new(1, 0, 0, 1)
    btmBorder.BackgroundColor3 = clr.line
    btmBorder.BorderSizePixel = 0
    btmBorder.Parent = btm

    local fL = Instance.new("TextLabel")
    fL.Size = UDim2.new(0.5, -15, 1, 0)
    fL.Position = UDim2.new(0, 15, 0, 0)
    fL.BackgroundTransparency = 1
    fL.Text = footL
    fL.TextColor3 = clr.dimGray
    fL.Font = Enum.Font.Gotham
    fL.TextSize = 11
    fL.TextXAlignment = Enum.TextXAlignment.Left
    fL.Parent = btm

    local fR = Instance.new("TextLabel")
    fR.Size = UDim2.new(0.5, -15, 1, 0)
    fR.Position = UDim2.new(0.5, 0, 0, 0)
    fR.BackgroundTransparency = 1
    fR.RichText = true
    fR.Text = "32 days left, <font color=\"#715AEB\">" .. footR .. "</font>"
    fR.TextColor3 = clr.dimGray
    fR.Font = Enum.Font.Gotham
    fR.TextSize = 11
    fR.TextXAlignment = Enum.TextXAlignment.Right
    fR.Parent = btm

    -- ============ SIDEBAR ============
    local sbar = Instance.new("Frame")
    sbar.Name = "Sidebar"
    sbar.Size = UDim2.new(0, 200, 1, -28)
    sbar.BackgroundTransparency = 1
    sbar.Parent = main

    -- Sidebar right border
    local sbarLine = Instance.new("Frame")
    sbarLine.Size = UDim2.new(0, 1, 1, 0)
    sbarLine.Position = UDim2.new(1, 0, 0, 0)
    sbarLine.BackgroundColor3 = clr.line
    sbarLine.BorderSizePixel = 0
    sbarLine.Parent = sbar

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -30, 0, 30)
    titleLbl.Position = UDim2.new(0, 25, 0, 22)
    titleLbl.BackgroundTransparency = 1
    titleLbl.RichText = true
    titleLbl.Text = "<i><u><font color=\"#715AEB\">" .. titleA .. "</font></u></i>" .. titleB
    titleLbl.TextColor3 = clr.white
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 22
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = sbar

    -- Category scroll
    local catScroll = Instance.new("ScrollingFrame")
    catScroll.Size = UDim2.new(1, 0, 1, -75)
    catScroll.Position = UDim2.new(0, 0, 0, 75)
    catScroll.BackgroundTransparency = 1
    catScroll.ScrollBarThickness = 0
    catScroll.Parent = sbar
    local catLayout = Instance.new("UIListLayout")
    catLayout.SortOrder = Enum.SortOrder.LayoutOrder
    catLayout.Padding = UDim.new(0, 3)
    catLayout.Parent = catScroll
    local catPad = Instance.new("UIPadding")
    catPad.PaddingLeft = UDim.new(0, 18)
    catPad.PaddingRight = UDim.new(0, 18)
    catPad.Parent = catScroll

    -- ============ CONTENT AREA ============
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -201, 1, -28)
    content.Position = UDim2.new(0, 201, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- Popup overlay
    local popups = Instance.new("Frame")
    popups.Size = UDim2.new(1, 0, 1, 0)
    popups.BackgroundTransparency = 1
    popups.ZIndex = 90
    popups.Parent = main

    local winObj = {
        gui = gui, main = main, catScroll = catScroll,
        content = content, popups = popups, cats = {}
    }

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.RightControl then gui.Enabled = not gui.Enabled end
    end)

    -- ============ CATEGORY ============
    function winObj:CreateCategory(opts)
        opts = opts or {}
        local catName = opts.Name or "Players"
        local catIcon = opts.Icon or "rbxassetid://6034287525"
        local sectionText = opts.Section or "General"

        -- Section header
        local hasHeader = false
        for _, ch in pairs(catScroll:GetChildren()) do
            if ch:IsA("TextLabel") and ch.Text == sectionText then hasHeader = true end
        end
        if not hasHeader then
            local hdr = Instance.new("TextLabel")
            hdr.Size = UDim2.new(1, 0, 0, 26)
            hdr.BackgroundTransparency = 1
            hdr.Text = sectionText
            hdr.TextColor3 = clr.dimGray
            hdr.Font = Enum.Font.GothamMedium
            hdr.TextSize = 12
            hdr.TextXAlignment = Enum.TextXAlignment.Left
            hdr.Parent = catScroll
        end

        local catBtn = Instance.new("TextButton")
        catBtn.Size = UDim2.new(1, 0, 0, 34)
        catBtn.BackgroundColor3 = clr.tabActiveBg
        catBtn.BackgroundTransparency = 1
        catBtn.Text = ""
        catBtn.Parent = catScroll
        Instance.new("UICorner", catBtn).CornerRadius = UDim.new(0, 8)

        local icn = Instance.new("ImageLabel")
        icn.Size = UDim2.new(0, 15, 0, 15)
        icn.Position = UDim2.new(0, 10, 0.5, -7)
        icn.BackgroundTransparency = 1
        icn.Image = catIcon
        icn.ImageColor3 = clr.gray
        icn.Parent = catBtn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -38, 1, 0)
        lbl.Position = UDim2.new(0, 34, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = catName
        lbl.TextColor3 = clr.gray
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = catBtn

        -- Category page
        local catPage = Instance.new("Frame")
        catPage.Size = UDim2.new(1, 0, 1, 0)
        catPage.BackgroundTransparency = 1
        catPage.Visible = false
        catPage.Parent = content

        -- Subtab bar at top
        local subBar = Instance.new("Frame")
        subBar.Size = UDim2.new(1, 0, 0, 55)
        subBar.BackgroundTransparency = 1
        subBar.Parent = catPage

        local subBarLine = Instance.new("Frame")
        subBarLine.Size = UDim2.new(1, 0, 0, 1)
        subBarLine.Position = UDim2.new(0, 0, 1, -1)
        subBarLine.BackgroundColor3 = clr.line
        subBarLine.BorderSizePixel = 0
        subBarLine.Parent = subBar

        local subBarInner = Instance.new("Frame")
        subBarInner.Size = UDim2.new(1, -25, 1, -1)
        subBarInner.Position = UDim2.new(0, 15, 0, 0)
        subBarInner.BackgroundTransparency = 1
        subBarInner.Parent = subBar
        local subLay = Instance.new("UIListLayout")
        subLay.FillDirection = Enum.FillDirection.Horizontal
        subLay.VerticalAlignment = Enum.VerticalAlignment.Center
        subLay.SortOrder = Enum.SortOrder.LayoutOrder
        subLay.Padding = UDim.new(0, 8)
        subLay.Parent = subBarInner

        local tabHolder = Instance.new("Frame")
        tabHolder.Size = UDim2.new(1, 0, 1, -55)
        tabHolder.Position = UDim2.new(0, 0, 0, 55)
        tabHolder.BackgroundTransparency = 1
        tabHolder.Parent = catPage

        local catObj = {
            btn = catBtn, page = catPage,
            subBarInner = subBarInner, tabHolder = tabHolder,
            tabs = {}
        }
        table.insert(self.cats, catObj)

        catBtn.MouseButton1Click:Connect(function()
            for _, c in pairs(self.cats) do
                c.btn.BackgroundTransparency = 1
                c.page.Visible = false
                for _, ch in pairs(c.btn:GetChildren()) do
                    if ch:IsA("TextLabel") then ch.TextColor3 = clr.gray; ch.Font = Enum.Font.GothamMedium end
                    if ch:IsA("ImageLabel") then ch.ImageColor3 = clr.gray end
                end
            end
            catBtn.BackgroundTransparency = 0
            catPage.Visible = true
            lbl.TextColor3 = clr.white
            lbl.Font = Enum.Font.GothamBold
            icn.ImageColor3 = clr.white
        end)

        if #self.cats == 1 then
            catBtn.BackgroundTransparency = 0
            catPage.Visible = true
            lbl.TextColor3 = clr.white
            lbl.Font = Enum.Font.GothamBold
            icn.ImageColor3 = clr.white
        end

        -- ============ TAB (SubTab) ============
        function catObj:CreateTab(name)
            local tw = #name * 8 + 26
            local tabBtn = Instance.new("TextButton")
            tabBtn.Size = UDim2.new(0, tw, 0, 32)
            tabBtn.BackgroundColor3 = clr.tabActiveBg
            tabBtn.BackgroundTransparency = 1
            tabBtn.Text = name
            tabBtn.TextColor3 = clr.dimGray
            tabBtn.Font = Enum.Font.GothamMedium
            tabBtn.TextSize = 13
            tabBtn.Parent = self.subBarInner
            Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 7)

            local uline = Instance.new("Frame")
            uline.Size = UDim2.new(0, 22, 0, 2)
            uline.Position = UDim2.new(0.5, -11, 1, -7)
            uline.BackgroundColor3 = clr.purple
            uline.BorderSizePixel = 0
            uline.Visible = false
            uline.Parent = tabBtn
            Instance.new("UICorner", uline).CornerRadius = UDim.new(1, 0)

            local tabPage = Instance.new("ScrollingFrame")
            tabPage.Size = UDim2.new(1, 0, 1, 0)
            tabPage.BackgroundTransparency = 1
            tabPage.ScrollBarThickness = 2
            tabPage.ScrollBarImageColor3 = clr.darkGray
            tabPage.Visible = false
            tabPage.Parent = self.tabHolder

            local tPad = Instance.new("UIPadding")
            tPad.PaddingTop = UDim.new(0, 12)
            tPad.PaddingBottom = UDim.new(0, 12)
            tPad.PaddingLeft = UDim.new(0, 12)
            tPad.PaddingRight = UDim.new(0, 12)
            tPad.Parent = tabPage

            local tGrid = Instance.new("UIGridLayout")
            tGrid.SortOrder = Enum.SortOrder.LayoutOrder
            tGrid.CellSize = UDim2.new(0.5, -8, 0, 0)
            tGrid.CellPadding = UDim2.new(0, 12, 0, 12)
            tGrid.Parent = tabPage

            local tabObj = { btn = tabBtn, page = tabPage, uline = uline }
            table.insert(self.tabs, tabObj)

            tabBtn.MouseButton1Click:Connect(function()
                for _, t in pairs(self.tabs) do
                    t.btn.BackgroundTransparency = 1
                    t.btn.TextColor3 = clr.dimGray
                    t.btn.Font = Enum.Font.GothamMedium
                    t.uline.Visible = false
                    t.page.Visible = false
                end
                tabBtn.BackgroundTransparency = 0
                tabBtn.TextColor3 = clr.white
                tabBtn.Font = Enum.Font.GothamBold
                uline.Visible = true
                tabPage.Visible = true
            end)

            if #self.tabs == 1 then
                tabBtn.BackgroundTransparency = 0
                tabBtn.TextColor3 = clr.white
                tabBtn.Font = Enum.Font.GothamBold
                uline.Visible = true
                tabPage.Visible = true
            end

            -- ============ SECTION (Card) ============
            function tabObj:CreateSection(secName, masterCb)
                local card = Instance.new("Frame")
                card.BackgroundColor3 = clr.cardBg
                card.BorderSizePixel = 0
                card.AutomaticSize = Enum.AutomaticSize.Y
                card.Parent = self.page
                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

                -- Header
                local hdr = Instance.new("Frame")
                hdr.Size = UDim2.new(1, 0, 0, 44)
                hdr.BackgroundTransparency = 1
                hdr.Parent = card

                -- Purple circle bg
                local circBg = Instance.new("Frame")
                circBg.Size = UDim2.new(0, 22, 0, 22)
                circBg.Position = UDim2.new(0, 14, 0.5, -11)
                circBg.BackgroundColor3 = clr.purple
                circBg.BackgroundTransparency = 0.75
                circBg.Parent = hdr
                Instance.new("UICorner", circBg).CornerRadius = UDim.new(1, 0)

                local circIcon = Instance.new("ImageLabel")
                circIcon.Size = UDim2.new(0, 13, 0, 13)
                circIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                circIcon.BackgroundTransparency = 1
                circIcon.Image = "rbxassetid://6034287525"
                circIcon.ImageColor3 = clr.purple
                circIcon.Parent = circBg

                local hTitle = Instance.new("TextLabel")
                hTitle.Size = UDim2.new(1, -90, 1, 0)
                hTitle.Position = UDim2.new(0, 46, 0, 0)
                hTitle.BackgroundTransparency = 1
                hTitle.Text = secName
                hTitle.TextColor3 = clr.white
                hTitle.Font = Enum.Font.GothamBold
                hTitle.TextSize = 13
                hTitle.TextXAlignment = Enum.TextXAlignment.Left
                hTitle.Parent = hdr

                -- Toggle switch
                local tgBtn = Instance.new("TextButton")
                tgBtn.Size = UDim2.new(0, 36, 0, 18)
                tgBtn.Position = UDim2.new(1, -48, 0.5, -9)
                tgBtn.BackgroundColor3 = clr.toggleOff
                tgBtn.Text = ""
                tgBtn.AutoButtonColor = false
                tgBtn.Parent = hdr
                Instance.new("UICorner", tgBtn).CornerRadius = UDim.new(1, 0)

                local tgDot = Instance.new("Frame")
                tgDot.Size = UDim2.new(0, 12, 0, 12)
                tgDot.Position = UDim2.new(0, 3, 0.5, -6)
                tgDot.BackgroundColor3 = clr.dimGray
                tgDot.Parent = tgBtn
                Instance.new("UICorner", tgDot).CornerRadius = UDim.new(1, 0)

                local tgOn = false
                tgBtn.MouseButton1Click:Connect(function()
                    tgOn = not tgOn
                    TweenService:Create(tgBtn, TweenInfo.new(0.15), {
                        BackgroundColor3 = tgOn and clr.purple or clr.toggleOff
                    }):Play()
                    TweenService:Create(tgDot, TweenInfo.new(0.15), {
                        Position = tgOn and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                        BackgroundColor3 = tgOn and clr.white or clr.dimGray
                    }):Play()
                    if masterCb then masterCb(tgOn) end
                end)

                -- Divider
                local div = Instance.new("Frame")
                div.Size = UDim2.new(1, 0, 0, 1)
                div.Position = UDim2.new(0, 0, 0, 44)
                div.BackgroundColor3 = clr.line
                div.BorderSizePixel = 0
                div.Parent = card

                -- Items
                local items = Instance.new("Frame")
                items.Size = UDim2.new(1, 0, 0, 0)
                items.Position = UDim2.new(0, 0, 0, 45)
                items.BackgroundTransparency = 1
                items.AutomaticSize = Enum.AutomaticSize.Y
                items.Parent = card

                local iLay = Instance.new("UIListLayout")
                iLay.SortOrder = Enum.SortOrder.LayoutOrder
                iLay.Padding = UDim.new(0, 0)
                iLay.Parent = items

                local secObj = { items = items }

                -- Update grid cell sizing after adding items
                local function refreshCanvas()
                    task.defer(function()
                        local h = 45 + iLay.AbsoluteContentSize.Y
                        card.Size = UDim2.new(0, 0, 0, h)
                        tGrid.CellSize = UDim2.new(0.5, -8, 0, 0)
                        self.page.CanvasSize = UDim2.new(0, 0, 0, tGrid.AbsoluteContentSize.Y + 24)
                    end)
                end

                -- ======== CHECKBOX ========
                function secObj:CreateCheckbox(txt, def, cb)
                    local st = def or false
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 32)
                    row.BackgroundTransparency = 1
                    row.Parent = self.items

                    local rLbl = Instance.new("TextLabel")
                    rLbl.Size = UDim2.new(1, -50, 1, 0)
                    rLbl.Position = UDim2.new(0, 14, 0, 0)
                    rLbl.BackgroundTransparency = 1
                    rLbl.Text = txt
                    rLbl.TextColor3 = clr.white
                    rLbl.Font = Enum.Font.GothamMedium
                    rLbl.TextSize = 13
                    rLbl.TextXAlignment = Enum.TextXAlignment.Left
                    rLbl.Parent = row

                    local chk = Instance.new("TextButton")
                    chk.Size = UDim2.new(0, 16, 0, 16)
                    chk.Position = UDim2.new(1, -30, 0.5, -8)
                    chk.BackgroundColor3 = clr.checkOff
                    chk.Text = ""
                    chk.Parent = row
                    Instance.new("UICorner", chk).CornerRadius = UDim.new(0, 4)
                    local chkStroke = Instance.new("UIStroke")
                    chkStroke.Color = clr.darkGray
                    chkStroke.Thickness = 1
                    chkStroke.Parent = chk

                    local chkMark = Instance.new("ImageLabel")
                    chkMark.Size = UDim2.new(0, 10, 0, 10)
                    chkMark.Position = UDim2.new(0.5, -5, 0.5, -5)
                    chkMark.BackgroundTransparency = 1
                    chkMark.Image = "rbxassetid://6031068420"
                    chkMark.ImageColor3 = clr.white
                    chkMark.Visible = st
                    chkMark.Parent = chk

                    local function upd()
                        chk.BackgroundColor3 = st and clr.purple or clr.checkOff
                        chkStroke.Color = st and clr.purple or clr.darkGray
                        chkMark.Visible = st
                        if cb then cb(st) end
                    end
                    upd()

                    chk.MouseButton1Click:Connect(function()
                        st = not st
                        upd()
                    end)

                    refreshCanvas()
                end

                -- ======== CHECKBOX WITH COLOR SQUARE ========
                function secObj:CreateCheckboxColor(txt, def, defColor, cb, colorCb)
                    local st = def or false
                    local currentColor = defColor or clr.purple
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 32)
                    row.BackgroundTransparency = 1
                    row.Parent = self.items

                    local rLbl = Instance.new("TextLabel")
                    rLbl.Size = UDim2.new(1, -75, 1, 0)
                    rLbl.Position = UDim2.new(0, 14, 0, 0)
                    rLbl.BackgroundTransparency = 1
                    rLbl.Text = txt
                    rLbl.TextColor3 = clr.white
                    rLbl.Font = Enum.Font.GothamMedium
                    rLbl.TextSize = 13
                    rLbl.TextXAlignment = Enum.TextXAlignment.Left
                    rLbl.Parent = row

                    -- Color square
                    local colorBtn = Instance.new("TextButton")
                    colorBtn.Size = UDim2.new(0, 14, 0, 14)
                    colorBtn.Position = UDim2.new(1, -55, 0.5, -7)
                    colorBtn.BackgroundColor3 = currentColor
                    colorBtn.Text = ""
                    colorBtn.Parent = row
                    Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 3)

                    local chk = Instance.new("TextButton")
                    chk.Size = UDim2.new(0, 16, 0, 16)
                    chk.Position = UDim2.new(1, -30, 0.5, -8)
                    chk.BackgroundColor3 = clr.checkOff
                    chk.Text = ""
                    chk.Parent = row
                    Instance.new("UICorner", chk).CornerRadius = UDim.new(0, 4)
                    local chkStroke = Instance.new("UIStroke")
                    chkStroke.Color = clr.darkGray
                    chkStroke.Thickness = 1
                    chkStroke.Parent = chk

                    local chkMark = Instance.new("ImageLabel")
                    chkMark.Size = UDim2.new(0, 10, 0, 10)
                    chkMark.Position = UDim2.new(0.5, -5, 0.5, -5)
                    chkMark.BackgroundTransparency = 1
                    chkMark.Image = "rbxassetid://6031068420"
                    chkMark.ImageColor3 = clr.white
                    chkMark.Visible = st
                    chkMark.Parent = chk

                    local function upd()
                        chk.BackgroundColor3 = st and clr.purple or clr.checkOff
                        chkStroke.Color = st and clr.purple or clr.darkGray
                        chkMark.Visible = st
                        if cb then cb(st) end
                    end
                    upd()
                    chk.MouseButton1Click:Connect(function() st = not st; upd() end)
                    refreshCanvas()
                end

                -- ======== CHECKBOX WITH GEAR + COLOR ========
                function secObj:CreateCheckboxGearColor(txt, def, defColor, cb)
                    local st = def or false
                    local currentColor = defColor or clr.purple
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 32)
                    row.BackgroundTransparency = 1
                    row.Parent = self.items

                    local rLbl = Instance.new("TextLabel")
                    rLbl.Size = UDim2.new(1, -95, 1, 0)
                    rLbl.Position = UDim2.new(0, 14, 0, 0)
                    rLbl.BackgroundTransparency = 1
                    rLbl.Text = txt
                    rLbl.TextColor3 = clr.white
                    rLbl.Font = Enum.Font.GothamMedium
                    rLbl.TextSize = 13
                    rLbl.TextXAlignment = Enum.TextXAlignment.Left
                    rLbl.Parent = row

                    -- Color square
                    local cBtn = Instance.new("TextButton")
                    cBtn.Size = UDim2.new(0, 14, 0, 14)
                    cBtn.Position = UDim2.new(1, -75, 0.5, -7)
                    cBtn.BackgroundColor3 = currentColor
                    cBtn.Text = ""
                    cBtn.Parent = row
                    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 3)

                    -- Gear icon
                    local gear = Instance.new("ImageButton")
                    gear.Size = UDim2.new(0, 14, 0, 14)
                    gear.Position = UDim2.new(1, -53, 0.5, -7)
                    gear.BackgroundTransparency = 1
                    gear.Image = "rbxassetid://10734898355"
                    gear.ImageColor3 = clr.dimGray
                    gear.Parent = row

                    local chk = Instance.new("TextButton")
                    chk.Size = UDim2.new(0, 16, 0, 16)
                    chk.Position = UDim2.new(1, -30, 0.5, -8)
                    chk.BackgroundColor3 = clr.checkOff
                    chk.Text = ""
                    chk.Parent = row
                    Instance.new("UICorner", chk).CornerRadius = UDim.new(0, 4)
                    local chkStroke = Instance.new("UIStroke")
                    chkStroke.Color = clr.darkGray
                    chkStroke.Thickness = 1
                    chkStroke.Parent = chk
                    local chkMark = Instance.new("ImageLabel")
                    chkMark.Size = UDim2.new(0, 10, 0, 10)
                    chkMark.Position = UDim2.new(0.5, -5, 0.5, -5)
                    chkMark.BackgroundTransparency = 1
                    chkMark.Image = "rbxassetid://6031068420"
                    chkMark.ImageColor3 = clr.white
                    chkMark.Visible = st
                    chkMark.Parent = chk

                    local function upd()
                        chk.BackgroundColor3 = st and clr.purple or clr.checkOff
                        chkStroke.Color = st and clr.purple or clr.darkGray
                        chkMark.Visible = st
                        if cb then cb(st) end
                    end
                    upd()
                    chk.MouseButton1Click:Connect(function() st = not st; upd() end)
                    refreshCanvas()
                end

                -- ======== DROPDOWN ========
                function secObj:CreateDropdown(txt, opts, def, cb)
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 32)
                    row.BackgroundTransparency = 1
                    row.Parent = self.items

                    local rLbl = Instance.new("TextLabel")
                    rLbl.Size = UDim2.new(0, 80, 1, 0)
                    rLbl.Position = UDim2.new(0, 14, 0, 0)
                    rLbl.BackgroundTransparency = 1
                    rLbl.Text = txt
                    rLbl.TextColor3 = clr.white
                    rLbl.Font = Enum.Font.GothamMedium
                    rLbl.TextSize = 13
                    rLbl.TextXAlignment = Enum.TextXAlignment.Left
                    rLbl.Parent = row

                    local dropBtn = Instance.new("TextButton")
                    dropBtn.Size = UDim2.new(1, -105, 0, 22)
                    dropBtn.Position = UDim2.new(0, 90, 0.5, -11)
                    dropBtn.BackgroundColor3 = clr.bg
                    dropBtn.Text = ""
                    dropBtn.Parent = row
                    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 5)

                    local selLbl = Instance.new("TextLabel")
                    selLbl.Size = UDim2.new(1, -22, 1, 0)
                    selLbl.Position = UDim2.new(0, 8, 0, 0)
                    selLbl.BackgroundTransparency = 1
                    selLbl.Text = def or opts[1] or ""
                    selLbl.TextColor3 = clr.dimGray
                    selLbl.Font = Enum.Font.Gotham
                    selLbl.TextSize = 11
                    selLbl.TextXAlignment = Enum.TextXAlignment.Left
                    selLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    selLbl.Parent = dropBtn

                    local dropIcn = Instance.new("ImageLabel")
                    dropIcn.Size = UDim2.new(0, 10, 0, 10)
                    dropIcn.Position = UDim2.new(1, -16, 0.5, -5)
                    dropIcn.BackgroundTransparency = 1
                    dropIcn.Image = "rbxassetid://10709790948"
                    dropIcn.ImageColor3 = clr.dimGray
                    dropIcn.Parent = dropBtn

                    dropBtn.MouseButton1Click:Connect(function()
                        popups:ClearAllChildren()
                        local aPos = dropBtn.AbsolutePosition
                        local aSz = dropBtn.AbsoluteSize

                        local bg = Instance.new("TextButton")
                        bg.Size = UDim2.new(1, 0, 1, 0)
                        bg.BackgroundTransparency = 1
                        bg.Text = ""
                        bg.ZIndex = 91
                        bg.Parent = popups
                        bg.MouseButton1Click:Connect(function() popups:ClearAllChildren() end)

                        local pop = Instance.new("Frame")
                        pop.Size = UDim2.new(0, aSz.X, 0, math.min(#opts * 26 + 8, 180))
                        pop.Position = UDim2.new(0, aPos.X, 0, aPos.Y + aSz.Y + 4)
                        pop.BackgroundColor3 = clr.cardBg
                        pop.ZIndex = 92
                        pop.Parent = popups
                        Instance.new("UICorner", pop).CornerRadius = UDim.new(0, 6)

                        local popScroll = Instance.new("ScrollingFrame")
                        popScroll.Size = UDim2.new(1, 0, 1, -4)
                        popScroll.Position = UDim2.new(0, 0, 0, 2)
                        popScroll.BackgroundTransparency = 1
                        popScroll.ScrollBarThickness = 2
                        popScroll.ScrollBarImageColor3 = clr.darkGray
                        popScroll.ZIndex = 93
                        popScroll.Parent = pop
                        local pLay = Instance.new("UIListLayout")
                        pLay.SortOrder = Enum.SortOrder.LayoutOrder
                        pLay.Parent = popScroll

                        for _, opt in ipairs(opts) do
                            local oBtn = Instance.new("TextButton")
                            oBtn.Size = UDim2.new(1, 0, 0, 26)
                            oBtn.BackgroundTransparency = 1
                            oBtn.Text = "   " .. opt
                            oBtn.TextColor3 = (opt == selLbl.Text) and clr.purple or clr.gray
                            oBtn.Font = Enum.Font.GothamMedium
                            oBtn.TextSize = 12
                            oBtn.TextXAlignment = Enum.TextXAlignment.Left
                            oBtn.ZIndex = 94
                            oBtn.Parent = popScroll
                            oBtn.MouseButton1Click:Connect(function()
                                selLbl.Text = opt
                                if cb then cb(opt) end
                                popups:ClearAllChildren()
                            end)
                        end
                        popScroll.CanvasSize = UDim2.new(0, 0, 0, #opts * 26)
                    end)

                    refreshCanvas()
                end

                -- ======== SLIDER ========
                function secObj:CreateSlider(txt, min, max, def, cb)
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 42)
                    row.BackgroundTransparency = 1
                    row.Parent = self.items

                    local rLbl = Instance.new("TextLabel")
                    rLbl.Size = UDim2.new(1, -30, 0, 18)
                    rLbl.Position = UDim2.new(0, 14, 0, 3)
                    rLbl.BackgroundTransparency = 1
                    rLbl.Text = txt .. ": " .. tostring(def)
                    rLbl.TextColor3 = clr.gray
                    rLbl.Font = Enum.Font.GothamMedium
                    rLbl.TextSize = 13
                    rLbl.TextXAlignment = Enum.TextXAlignment.Left
                    rLbl.Parent = row

                    local sBg = Instance.new("Frame")
                    sBg.Size = UDim2.new(1, -28, 0, 5)
                    sBg.Position = UDim2.new(0, 14, 0, 28)
                    sBg.BackgroundColor3 = clr.bg
                    sBg.Parent = row
                    Instance.new("UICorner", sBg).CornerRadius = UDim.new(1, 0)

                    local sFill = Instance.new("Frame")
                    local pct = (def - min) / (max - min)
                    sFill.Size = UDim2.new(pct, 0, 1, 0)
                    sFill.BackgroundColor3 = clr.purple
                    sFill.Parent = sBg
                    Instance.new("UICorner", sFill).CornerRadius = UDim.new(1, 0)

                    local sBtn = Instance.new("TextButton")
                    sBtn.Size = UDim2.new(1, 0, 1, 12)
                    sBtn.Position = UDim2.new(0, 0, 0, -6)
                    sBtn.BackgroundTransparency = 1
                    sBtn.Text = ""
                    sBtn.Parent = sBg

                    local sliding = false
                    sBtn.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
                    end)
                    UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                    end)
                    UserInputService.InputChanged:Connect(function(i)
                        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                            local mx = i.Position.X
                            local sx = sBg.AbsolutePosition.X
                            local sw = sBg.AbsoluteSize.X
                            local p = math.clamp((mx - sx) / sw, 0, 1)
                            sFill.Size = UDim2.new(p, 0, 1, 0)
                            local v = math.floor(min + (max - min) * p)
                            rLbl.Text = txt .. ": " .. tostring(v)
                            if cb then cb(v) end
                        end
                    end)

                    refreshCanvas()
                end

                refreshCanvas()
                return secObj
            end

            return tabObj
        end

        return catObj
    end

    return winObj
end

return Library
