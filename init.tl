require "love"
require "imgui"

local lineLen = 127.
local gr = love.graphics
local wid, hei = gr.getWidth(), gr.getHeight()

local a_2, b_2 = wid / 2, hei - lineLen
local a_: number = 0
local angle = 26 * math.pi / 180
local b_: number = 0
local binds = require "binds"
local branchesIterations = 3
local cam = require "camera".new()
local magic = 0.76
local minLen = 10.
local randomVariation = 0.

local rg: love.math.RandomGenerator = love.math.newRandomGenerator()

--local keyconfig = require "keyconfig"

function rotate(x: number, y: number, a: number): number, number
   local s, c = math.sin(a), math.cos(a)
   local a_tmp, b_tmp = x * c - y * s, x * s + y * c
   return a_tmp, b_tmp
end

local type LineCoordinateType = number

local record Line
    a: LineCoordinateType
    b: LineCoordinateType
    vx: LineCoordinateType
    vy: LineCoordinateType
end

local stack: {Line} = {}
local vertices: {number} = {}

local function pushBranch(
    x0: LineCoordinateType,
    y0: LineCoordinateType,
    x1: LineCoordinateType,
    y1: LineCoordinateType
)
    table.insert(stack, {a = x0, b = y0, vx = x1, vy = y1})
end

--[[ 
Нужно развернуть рекурсивный вызов `branches` на цикл `for`.
--]]
function branches(
    deep: integer, 
    a: number, 
    b: number, 
    len: number, 
    ang: number, 
    dir: number
)
    local ok, errmsg: boolean, string = pcall(function()
        len = len * magic

        if len < minLen then 
            return 
        end

        --gr.setColor(len * 16, 255 - 2 * len, 0)
        gr.setColor(rg:random(), rg:random(), rg:random())

        if dir > 0 then 
            ang = ang - angle
        else 
            ang = ang + angle
        end

        local vx, vy = rotate(0, len, ang)

        vx = a + vx
        vy = b - vy

        --[[
        Здесь должно быть формирование полигонов из граней.
        ]]--

        -- отсечение линии за пределами экрана

        --local x0, y0 = 0., 0.
        local x0, y0 = cam:cameraCoords(a, b)
        --local x1, y1 = cam:cameraCoords(vx, vy)
        --local w, h = 0., 0.
        local w, h = wid, hei
        if pointInRect(a, b, x0, y0, w, h) and pointInRect(vx, vy, x0, y0, w, h) then
            gr.line(a, b, vx, vy)
        end

        pushBranch(a, b, vx, vy)

        --table.insert(vertices, a)
        --table.insert(vertices, b)
        --table.insert(vertices, vx)
        --table.insert(vertices, vy)

        branches(deep, vx, vy, len, ang, 1)
        branches(deep, vx, vy, len, ang, 0)
    end)
    if not ok then
        collectgarbage("collect")
        print(errmsg)
    end
end

--local randGen: love.math.RandomGenerator = love.math.newRandomGenerator()
--local seedState: {{number, number}}

local DEEP = 1

function createTree()
   local a, b = a_2, b_2
   gr.setColor(160, 40, 0)
   gr.line(wid / 2, hei, a, b)

   stack = {}

   print("start", DEEP, a, b, lineLen, a_, b_)
   --error("program stop")

   branches(DEEP, a, b, lineLen, a_, b_)

   --for _ = 1, branchesIterations do
       ----branches(a, b, lineLen, a_, b_)
       --if randomVariation ~= 0.0 then
           --branches(a, b, lineLen, a_ * rg:random(0, 1), b_ * rg:random(0, 1))
       --else
           --branches(a, b, lineLen, a_, b_)
       --end
   --end

   branches(math.floor(a), math.floor(b), lineLen, 0, 0)
   branches(math.floor(a), math.floor(b), lineLen, 0, 1.5)
   branches(math.floor(a), math.floor(b), lineLen, 0.3, 0)

   --for _ = 1, 10 do
       --branches(a, b, lineLen, randGen:random(), randGen:random())
   --end

   --for _, v in ipairs(stack) do
       --gr.line(v.a, v.b, v.vx, v.vy)
   --end

   --gr.polygon("fill", vertices)

end

--local canvas: gr.Canvas

local function redrawTree()
    local canvas = gr.newCanvas(wid, hei)
    gr.setCanvas(canvas)
    createTree()
    gr.setCanvas()
end

local function init()
    binds.bindCameraControl(cam)

    local Shortcut = KeyConfig.Shortcut

    --[[
    -- TODO список хоткеев
    --]]
    KeyConfig.bind(
        "isdown",
        { key = "z" },
        function(sc: Shortcut): boolean, Shortcut
            cam:zoom(1.01)
            return false, sc
        end,
        "zoom camera out",
        "zoomout"
    )

    KeyConfig.bind(
        "isdown",
        { key = "x" },
        function(sc: Shortcut): boolean, Shortcut
            cam:zoom(0.99)
            return false, sc
        end,
        "zoom camera in",
        "zoomin"
    )

    redrawTree()
end

local function draw()
    cam:attach()
    --gr.draw(canvas as gr.Drawable)
    createTree()
    cam:detach()
end

local function update(dt: number)
    binds.cameraControlUpdate(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

local stateLen = 10

local function regenSeedState()
    for _ = 1, stateLen do

    end
end

local function keypressed(key: string)
    if key == "space" then
        regenSeedState()
    end
end

local function defSlider(
    currentvalue: number,
    name: string,
    min: number, 
    max: number
): number
    local res: number
    local stat: boolean
    res, stat = imgui.SliderFloat(
        name,
        currentvalue,
        min,
        max
    )
    if not stat then
        res = currentvalue
    else
        redrawTree()
    end
    return res
end

local maxLineLen = 2000
local max_a_2 = 2000
local max_b_2 = 2000

local function drawui()
    --imgui.Begin('info', false, "NoTitleBar|NoMove|NoResize|AlwaysAutoResize")
    imgui.Begin('dd', false, "AlwaysAutoResize")

    a_ = defSlider(a_, "a", 0, 1)
    b_ = defSlider(b_, "b", 0, 1)
    a_2 = defSlider(a_2, "a_2", 0, max_a_2)
    b_2 = defSlider(b_2, "b_2", 0, max_b_2)
    lineLen = defSlider(lineLen, "lineLen", 0, maxLineLen)
    magic = defSlider(magic, "magic", 0, 1.)
    minLen = defSlider(minLen, "min len", 1, 3)
    branchesIterations = math.ceil(defSlider(
        branchesIterations, "branches iterations", 0, 10
    ))
    randomVariation = defSlider(randomVariation, "random variation", 0, 1)

    --imgui.Text(string.format('at point %d, %d', pos.x, pos.y))
    --print('drawui')
    imgui.End()
end

return {
   init = init,
   draw = draw,
   drawui = drawui,
   update = update,
   keypressed = keypressed,
}
