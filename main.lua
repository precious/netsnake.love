function load()


	font = love.graphics.newFont(love.default_font)
	love.graphics.setFont(font)
	center = {}
	center.x = love.graphics.getWidth()/2
	center.y = love.graphics.getHeight()/2
	fontd = {}
	fontd.width = font:getWidth("0")
	fontd.height = font:getHeight()
end

function update()

end

function keypressed(key)
	if key == love.key_s then
		love.filesystem.include("snake_serv.lua")
	elseif key == love.key_c then
		love.filesystem.include("snake_clnt.lua")
	end
end

function draw()
	text = "S to start server"
	love.graphics.draw(text, center.x - fontd.width*#text/2, center.y - fontd.height/2)
	text = "C to start client"
	love.graphics.draw(text, center.x - fontd.width*#text/2, center.y + fontd.height/2)
end
