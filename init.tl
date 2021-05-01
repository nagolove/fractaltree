require "love"
require "imgui"
local gr = love.graphics
local angle = 26 * math.pi / 180
local wid, hei = gr.getWidth(), gr.getHeight()
local lineLen = 127.
local a_2, b_2 = wid / 2, hei - lineLen
local a_: number = 0
local b_: number = 0


function rotate(x: number, y: number, a: number): number, number
   local s, c = math.sin(a), math.cos(a)
   local a_tmp, b_tmp = x * c - y * s, x * s + y * c
   return a_tmp, b_tmp
end

function branches(a: number, b: number, len: number, ang: number, dir: number)
   len = len * .76

   if len < 10 then 
       return 
   end

   gr.setColor(len * 16, 255 - 2 * len, 0)

   if dir > 0 then 
       ang = ang - angle
   else 
       ang = ang + angle
   end

   local vx, vy = rotate(0, len, ang)

   vx = a + vx; vy = b - vy

   gr.line(a, b, vx, vy)

   branches(vx, vy, len, ang, 1)
   branches(vx, vy, len, ang, 0)
end

--local randGen: love.math.RandomGenerator = love.math.newRandomGenerator()
--local seedState: {{number, number}}

function createTree()
   --local a, b = wid / 2, hei - lineLen
   local a, b = a_2, b_2
   gr.setColor(160, 40, 0)
   gr.line(wid / 2, hei, a, b)

   branches(a, b, lineLen, a_, b_)
   --branches(a, b, lineLen, 0, 0)
   --branches(a, b, lineLen, 0, 1.5)
   --branches(a, b, lineLen, 0.3, 0)

   --for _ = 1, 10 do
       --branches(a, b, lineLen, randGen:random(), randGen:random())
   --end

end

local canvas: gr.Canvas

local function redrawTree()
    canvas = gr.newCanvas(wid, hei)
    gr.setCanvas(canvas)
    createTree()
    gr.setCanvas()
end

local function init()
    redrawTree()
end
local function draw()
   gr.draw(canvas as gr.Drawable)
end

local function update()
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
    --imgui.Text(string.format('at point %d, %d', pos.x, pos.y))
    print('drawui')
    imgui.End()
end

return {
   init = init,
   draw = draw,
   drawui = drawui,
   update = update,
   keypressed = keypressed,
}
