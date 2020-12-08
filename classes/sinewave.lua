Sinewave = Class:extend('Sinewave')

function Sinewave:new(value, speed, amplitude)
    self.val       = value or 0
    self.v         = value or 0
    self.speed     = speed or 1
    self.amplitude = amplitude or 1
    self.time = 0
    self.sine = 0
    self.is_updating = true
end

function Sinewave:update(dt)
    if self.is_updating then 
        self.time = self.time + dt
        self.sine = (self.amplitude * math.sin(self.time * self.speed))
        self.val  = self.v + self.sine
    end
end

function Sinewave:value() return self.val end
function Sinewave:stop() self.is_updating = false end
function Sinewave:play() self.is_updating = true end
function Sinewave:setValue(v) self.val = v; self.v = v end
