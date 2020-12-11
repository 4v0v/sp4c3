-- Copyright (c) - 2018 - twentytwoo, tanema, 4v0v - MIT license

local Fifo, Typer, utf8, lg = {}, {}, require("utf8"), love.graphics

local function playSound(sound, pitch) if type(sound) == "userdata" then sound:setPitch(pitch or 1); sound:play() end end
local function parseSpeed(speed) if speed == "fast" then return 0.01 elseif speed == "medium" then return 0.04; elseif speed == "slow" then return 0.08 else assert(tonumber(speed), "setSpeed() - Expected number, got " .. tostring(speed)); return speed end end
function Fifo.new () return setmetatable({first=1,last=0},{__index=Fifo}) end
function Fifo:peek() return self[self.first] end
function Fifo:len() return (self.last+1)-self.first end
function Fifo:push(value) self.last = self.last + 1; self[self.last] = value end
function Fifo:pop() if self.first > self.last then return end local value = self[self.first]; self[self.first] = nil; self.first = self.first + 1; return value end

function Typer.new(msg, speed) local timeToType = parseSpeed(speed); return setmetatable({msg = msg, complete = false, paused = false,timer = timeToType, max = timeToType, position = 0, visible = ""},{__index=Typer}) end
function Typer:resume() if not self.paused then return end; self.msg = self.msg:gsub("-+", " ", 1); self.paused = false end
function Typer:finish() if self.complete then return end; self.visible = self.msg:gsub("-+", " "); self.complete = true end
function Typer:update(dt)
  local typed = false
  if self.complete then return typed end
  if not self.paused then self.timer = self.timer - dt; if self.timer <= 0 then typed = string.sub(self.msg, self.position, self.position) ~= " "; self.position = self.position + 1; self.timer = self.max end end
  self.visible  = string.sub(self.msg, 0, utf8.offset(self.msg, self.position) - 1)
  self.complete = (self.visible == self.msg)
  self.paused   = string.sub(self.msg, string.len(self.visible)+1, string.len(self.visible)+2) == "--"
  return typed
end

local TXT = {
  -- Theme
  ind_char         = ">",
  opt_char         = "-",
  padding          = 10,
  talk_sound       = nil,
  opt_sound        = nil,
  ttl_color        = {1, 1, 1},
  msg_color        = {1, 1, 1},
  bg_color         = {0, 0, 0, 0.8},
  txt_speed        = 0.01,
  font             = lg.newFont("assets/fonts/fixedsystem.ttf", 32),

  typed_not_talked = true,
  pitch_values     = {0.7, 0.8, 1.0, 1.2, 1.3},

  ind_timer        = 0,
  ind_delay        = 20,
  show_ind         = false,
  dialogs          = Fifo.new(),

  canvas =  {lg.newCanvas() ,lg.newCanvas(), lg.newCanvas(), lg.newCanvas()},

  blur_shader = lg.newShader([[
      extern vec2 direction;
      extern number radius;
      vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords) {
          vec4 c = vec4(0.0);
          for (float i = -radius; i <= radius; i += 1.0) { c += Texel(texture, uvs + i * direction); }
          return c / (2.0 * radius + 1.0) * color;
      }
  ]]),
  color_shader = lg.newShader([[
      extern vec4 colors_vec;
      vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords) {
          vec4 pixel = Texel(texture, uvs);
          pixel = pixel + colors_vec;
          return pixel * color;
      }
  ]])
}

function TXT.new(ttl, msgs, config)
    c = config or {}
    if type(msgs) ~= "table" then msgs = {msgs} end
    msgFifo = Fifo.new()
    for i=1, #msgs do msgFifo:push(Typer.new(msgs[i], c.txt_speed or TXT.txt_speed)) end
    local font = c.font or TXT.font
    -- Insert the TXT.new into its own instance (table)
    TXT.dialogs:push({
        ttl              = ttl,
        msgs             = msgFifo,
        image            = c.image,
        options          = c.options,
        onstart          = c.onstart    or function() end,
        onmsg            = c.onmsg      or function() end,
        oncomplete       = c.oncomplete or function() end,
        -- theme
        ind_char         = c.ind_char   or TXT.ind_char,
        opt_char         = c.opt_char   or TXT.opt_char,
        padding          = c.padding    or TXT.padding,
        talk_sound       = c.talk_sound or TXT.talk_sound,
        opt_sound        = c.opt_sound  or TXT.opt_sound,
        ttl_color        = c.ttl_color  or TXT.ttl_color,
        msg_color        = c.msg_color  or TXT.msg_color,
        bg_color         = c.bg_color   or TXT.bg_color,
        font             = font,
        fontHeight       = font:getHeight(" "),
        typed_not_talked = c.typed_not_talked == nil and TXT.typed_not_talked or c.typed_not_talked,
        pitch_values     = c.pitch_values or TXT.pitch_values,
        
        opt_index        = 1,
        show_opts        = function(dialog) return dialog.msgs:len() == 1 and type(dialog.options) == "table" end,
    })
    if TXT.dialogs:len() == 1 then TXT.dialogs:peek().onstart() end
end

function TXT.update(dt)
    local curr = TXT.dialogs:peek()
    if curr == nil then return end
    local curr_msg = curr.msgs:peek()

    if curr_msg.paused or curr_msg.complete then TXT.ind_timer=TXT.ind_timer+1 if TXT.ind_timer>TXT.ind_delay then TXT.show_ind=not TXT.show_ind; TXT.ind_timer=0 end else TXT.show_ind=false end

    if curr_msg:update(dt) then if curr.typed_not_talked then playSound(curr.talk_sound) elseif not curr.talk_sound:isPlaying() then local pitch = curr.pitch_values[math.random(#curr.pitch_values)]; playSound(curr.talk_sound, pitch) end end
end

function TXT.draw(func)
    local curr = TXT.dialogs:peek()
    if curr == nil then func() return end
    local curr_msg = curr.msgs:peek()
    lg.push()

    local windowWidth, windowHeight = lg.getDimensions( )
    -- msg box
    local boxW = windowWidth-(2*curr.padding)
    local boxH = (windowHeight/3)-(2*curr.padding)
    local boxX = curr.padding
    local boxY = windowHeight-(boxH+curr.padding)
    -- image
    local imgX, imgY, imgW, imgScale = boxX+curr.padding, boxY+curr.padding, 0, 0
    if curr.image ~= nil then
        imgScale = (boxH - (curr.padding * 2)) / curr.image:getHeight()
        imgW     = curr.image:getWidth() * imgScale
    end
    -- ttl box
    local ttlBoxW      = curr.font:getWidth(curr.ttl)+(2*curr.padding)
    local ttlBoxH      = curr.fontHeight+curr.padding
    local ttlBoxY      = boxY - ttlBoxH-(curr.padding/2)
    local ttlX, ttlY   = boxX + curr.padding, ttlBoxY + 2
    local txt_x, txt_y = imgX + imgW + curr.padding, boxY + 1

    
    lg.setCanvas(TXT.canvas[1])
    lg.clear()
        func()
    lg.setCanvas()
    
    lg.setCanvas(TXT.canvas[2])
    lg.clear()
    lg.setShader(TXT.blur_shader)
        TXT.blur_shader:send("direction", {0, 1/love.graphics.getHeight()})
        TXT.blur_shader:send("radius", 5)
        lg.draw(TXT.canvas[1], 0, 0)
    lg.setShader()
    lg.setCanvas()

    lg.setCanvas(TXT.canvas[3])
    lg.clear()
    lg.setShader(TXT.blur_shader)
        TXT.blur_shader:send("direction", {1/love.graphics.getWidth(), 0})
        TXT.blur_shader:send("radius", 5)
        lg.draw(TXT.canvas[2], 0, 0)
    lg.setShader()
    lg.setCanvas()

    lg.stencil(function() 
        lg.rectangle("fill", boxX, boxY, boxW, boxH) 
        lg.rectangle("fill",boxX,ttlBoxY,ttlBoxW,ttlBoxH) 
    end)
    love.graphics.setStencilTest("equal", 0)
    func()
    love.graphics.setStencilTest()
    
    lg.stencil(function() 
        lg.rectangle("fill", boxX, boxY, boxW, boxH) 
        lg.rectangle("fill",boxX,ttlBoxY,ttlBoxW,ttlBoxH) 
    end)
    love.graphics.setStencilTest("equal", 1)
    lg.setShader(TXT.color_shader)
        TXT.color_shader:send("colors_vec", {-1,0.7,-1,0})
        lg.draw(TXT.canvas[3], 0, 0)
    lg.setShader()
    love.graphics.setStencilTest()
    

    lg.setFont(curr.font); lg.setColor(curr.ttl_color);lg.print(curr.ttl,ttlX,ttlY) -- msg ttl
    lg.setColor(0, 0, 0, 0.1); lg.rectangle("fill", boxX, boxY, boxW, boxH) -- Main msg box
    if curr.image ~= nil then lg.push(); lg.setColor(255, 255, 255); lg.draw(curr.image, imgX, imgY, 0, imgScale, imgScale); lg.pop() end -- msg avatar
    lg.setColor(curr.msg_color); lg.printf(curr_msg.visible, txt_x, txt_y, boxW - imgW - (4 * curr.padding)) -- msg text
    if curr:show_opts() and curr_msg.complete then
        local optionsY = txt_y+curr.font:getHeight(curr_msg.visible)-(curr.padding/1.6)
        local optionLeftPad = curr.font:getWidth(curr.opt_char.." ")
        for k, option in pairs(curr.options) do lg.print(option[1], optionLeftPad+txt_x+curr.padding, optionsY+((k-1)*curr.fontHeight)) end
        lg.print(curr.opt_char.." ", txt_x+curr.padding, optionsY+((curr.opt_index-1)*curr.fontHeight))
    end -- msg options (when shown)
    if TXT.show_ind then lg.print(curr.ind_char, boxX+boxW-(2.5*curr.padding), boxY+boxH-curr.fontHeight) end -- Next msg/continue ind

    lg.pop()
end

function TXT.advance_msg() local curr = TXT.dialogs:peek(); if curr == nil then return end; if curr.msgs:len() == 1 then curr.oncomplete(); TXT.dialogs:pop() if TXT.dialogs:len() == 0 then TXT.clear() else TXT.dialogs:peek().onstart() end end; curr.msgs:pop(); curr.onmsg(curr.msgs:len()) end
function TXT.prev_opt() local curr = TXT.dialogs:peek(); if curr == nil or not curr:show_opts() then return end; curr.opt_index = curr.opt_index - 1; if curr.opt_index < 1 then curr.opt_index = #curr.options end; playSound(curr.opt_sound) end
function TXT.next_opt() local curr = TXT.dialogs:peek(); if curr == nil or not curr:show_opts() then return end; curr.opt_index = curr.opt_index + 1; if curr.opt_index > #curr.options then curr.opt_index = 1 end; playSound(curr.opt_sound)end
function TXT.on_action() local curr = TXT.dialogs:peek(); if curr == nil then return end; local curr_msg = curr.msgs:peek(); if curr_msg.paused then curr_msg:resume() elseif not curr_msg.complete then curr_msg:finish() else if curr:show_opts() then curr.options[curr.opt_index][2](); playSound(curr.opt_sound) end TXT.advance_msg() end end
function TXT.clear() TXT.dialogs = Fifo.new() end

return TXT
