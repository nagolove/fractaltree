local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local math = _tl_compat and _tl_compat.math or math; local pcall = _tl_compat and _tl_compat.pcall or pcall; local table = _tl_compat and _tl_compat.table or table; require("love")
require("imgui")

local lineLen = 127.
local gr = love.graphics
local wid, hei = gr.getWidth(), gr.getHeight()

local a_2, b_2 = wid / 2, hei - lineLen
local a_ = 0
local angle = 26 * math.pi / 180
local b_ = 0
local binds = require("binds")
local branchesIterations = 3
local cam = require("camera").new()
local magic = 0.76
local minLen = 10.
local randomVariation = 0.

local rg = love.math.newRandomGenerator()



function rotate(x, y, a)
   local s, c = math.sin(a), math.cos(a)
   local a_tmp, b_tmp = x * c - y * s, x * s + y * c
   return a_tmp, b_tmp
end

local LineCoordinateType = {}

local Line = {}






local stack = {}
local vertices = {}

local function pushBranch(
   x0,
   y0,
   x1,
   y1)

   table.insert(stack, { a = x0, b = y0, vx = x1, vy = y1 })
end




function branches(
   deep,
   a,
   b,
   len,
   ang,
   dir)

   local ok, errmsg = pcall(function()
      len = len * magic

      if len < minLen then
         return
      end


      gr.setColor(rg:random(), rg:random(), rg:random())

      if dir > 0 then
         ang = ang - angle
      else
         ang = ang + angle
      end

      local vx, vy = rotate(0, len, ang)

      vx = a + vx
      vy = b - vy





      gr.line(a, b, vx, vy)
      pushBranch(a, b, vx, vy)

      table.insert(vertices, a)
      table.insert(vertices, b)
      table.insert(vertices, vx)
      table.insert(vertices, vy)

      branches(deep, vx, vy, len, ang, 1)
      branches(deep, vx, vy, len, ang, 0)
   end)
   if not ok then
      collectgarbage("collect")
      print(errmsg)
   end
end




local DEEP = 1

function createTree()
   local a, b = a_2, b_2
   gr.setColor(160, 40, 0)
   gr.line(wid / 2, hei, a, b)

   stack = {}
   branches(DEEP, a, b, lineLen, a_, b_)
























end



local function redrawTree()




end

local function init()
   binds.bindCameraControl(cam)

   local Shortcut = KeyConfig.Shortcut

   KeyConfig.bind(
   "isdown",
   { key = "z" },
   function(sc)
      cam:zoom(1.01)
      return false, sc
   end,
   "zoom camera out",
   "zoomout")


   KeyConfig.bind(
   "isdown",
   { key = "x" },
   function(sc)
      cam:zoom(0.99)
      return false, sc
   end,
   "zoom camera in",
   "zoomin")


   redrawTree()
end

local function draw()
   cam:attach()

   createTree()
   cam:detach()
end

local function update(dt)
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

local function keypressed(key)
   if key == "space" then
      regenSeedState()
   end
end

local function defSlider(
   currentvalue,
   name,
   min,
   max)

   local res
   local stat
   res, stat = imgui.SliderFloat(
   name,
   currentvalue,
   min,
   max)

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

   imgui.Begin('dd', false, "AlwaysAutoResize")

   a_ = defSlider(a_, "a", 0, 1)
   b_ = defSlider(b_, "b", 0, 1)
   a_2 = defSlider(a_2, "a_2", 0, max_a_2)
   b_2 = defSlider(b_2, "b_2", 0, max_b_2)
   lineLen = defSlider(lineLen, "lineLen", 0, maxLineLen)
   magic = defSlider(magic, "magic", 0, 1.)
   minLen = defSlider(minLen, "min len", 1, 3)
   branchesIterations = math.ceil(defSlider(
   branchesIterations, "branches iterations", 0, 10))

   randomVariation = defSlider(randomVariation, "random variation", 0, 1)



   imgui.End()
end

return {
   init = init,
   draw = draw,
   drawui = drawui,
   update = update,
   keypressed = keypressed,
}
