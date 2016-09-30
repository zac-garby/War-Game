function love.conf(t)
	t.version = "0.10.1"

	t.window.title = "War Game"
	t.window.width = 800
	t.window.height = 600
	t.window.resizable = false
	t.window.msaa = 16
	t.window.highdpi = true
	t.window.vsync = true

	t.modules.audio = false
	t.modules.joystick = false
	t.modules.physics = false
	t.modules.touch = false
	t.modules.video = false
end
