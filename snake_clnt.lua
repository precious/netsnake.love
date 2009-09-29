love.filesystem.require( "Client.lua" )
love.filesystem.require( "Binary.lua" )

count = 20	-- Count of pieces
mscount = 1	-- Number of messages, which snake was collected
counter_s = 0
counter = 0
topborder = 20

global_counter_s = 0
global_counter_c = 0

-- Contains all pieces of the snake
pieces_x = {}
pieces_y = {}
pieces_x_server = {}
pieces_y_server = {}
-- Contains all messages, which snake is collecting
messes_x = {}
messes_y = {}

a = 1
b = 0

datafromserver = ""

-- loading >>>
    key_time = 0
    font1 = love.graphics.newFont(love.default_font, 14)
	font2 = love.graphics.newFont(love.default_font, 12)

    images = {
	love.graphics.newImage("piece.png", love.image_optimize),
	love.graphics.newImage("mess.png", love.image_optimize),
	love.graphics.newImage("piece1.png", love.image_optimize),
	love.graphics.newImage("mess1.png", love.image_optimize),
	love.graphics.newImage("mess2.png", love.image_optimize)
	     }

    x_cord = 0
    y_cord = topborder + 303
    x_cord_server = 0
    y_cord_server = topborder + 13

    for i = 1,count do		 -- creating of structure with pieces
       x_cord = x_cord + 5	 -- 5 == height and width of the piece.png
      pieces_x[i] = x_cord
      pieces_y[i] = y_cord
    end

    for i = 1,count do		 -- creating of structure with pieces
       x_cord_server = x_cord_server + 5	 -- 5 == height and width of the piece1.png
      pieces_x_server[i] = x_cord_server
      pieces_y_server[i] = y_cord_server
    end

    for i=1,mscount do -- creating of structure with messages, which snake is collecting
       messes_x[i] = 143+20*i
       messes_y[i] = 143+20*i
    end


love.graphics.setBackgroundColor( 0,0,50 )

-- end of the loading <<<


--Client part The beginning
function received_data(data)
	datafromserver = data
	first = datafromserver:sub(1, 3)
	 if first == "px_" then
	     pieces_x_server = bin:upack ( datafromserver:sub( 5, datafromserver:find("py_s") - 1 ) )
	     pieces_y_server = bin:upack ( datafromserver:sub( datafromserver:find("py_s") + 4, datafromserver:find("px_c1") - 1 ) )
	     pieces_x = bin:upack ( datafromserver:sub( datafromserver:find("px_c1") + 5, datafromserver:find("py_c1") - 1 ) )
	     pieces_y = bin:upack ( datafromserver:sub( datafromserver:find("py_c1") + 5 ) )
	 elseif first == "mes" then
	     messes_x[1] = tonumber( datafromserver:sub(4, datafromserver:find("my") - 1)  )
	     messes_y[1] = tonumber( datafromserver:sub( datafromserver:find("my") + 2, datafromserver:find("cr_s") - 1 )  )
	     counter_s = tonumber( datafromserver:sub( datafromserver:find("cr_s") + 4, datafromserver:find("cr_c1") - 1 )  )
	     counter = tonumber( datafromserver:sub( datafromserver:find("cr_c1") + 5 )  )
	 elseif first == "res" then
		key_time = - 1
		a = 1
		b = 0
	 elseif first == "glo" then
		global_counter_s = tonumber( datafromserver:sub( 9, datafromserver:find("glob_c_c1") - 1 ) )
		global_counter_c = tonumber( datafromserver:sub( datafromserver:find("glob_c_c1") + 9) )
	end
end

client:Init()
client:setHandshake("Hi")
if client:connect("192.168.137.1", 9090, false) == nil then datafromserver = "Ready"
else error("Couldn't connect") end
client:setCallback(received_data)
--Client part The end

function update(dt)
 client:update()		-- Updating
 key_time = key_time + dt

end



function keypressed(key)
 if key_time > 0.02 then
	-- Management from the keyboard:
  if key == love.key_up then
	if b == 0 then b = - 1 a= 0
	client:send("a" .. tostring(a) .. "b" .. tostring(b))
  	end
    elseif key == love.key_down then
	if b == 0 then b = 1 a= 0
	client:send("a" .. tostring(a) .. "b" .. tostring(b))
    	end
    elseif key == love.key_right then
	if a == 0 then a = 1 b=0
	client:send("a" .. tostring(a) .. "b" .. tostring(b))
    	end
    elseif key == love.key_left then
	if a == 0 then a = -1 b=0
	client:send("a" .. tostring(a) .. "b" .. tostring(b))
    	end
  end
 key_time = 0
 end

end


function draw()

    for i = 1,count do		 -- Drawing of pieces
      love.graphics.draw(images[3], pieces_x[i], pieces_y[i])
    end

    for i = 1,count do		 -- Drawing of pieces
      love.graphics.draw(images[1], pieces_x_server[i], pieces_y_server[i])
    end

	love.graphics.setColor( 0, 0, 0 )
	love.graphics.line( 0, topborder, love.graphics.getWidth(), topborder )
	love.graphics.setColor( 0, 0, 100 )
	love.graphics.rectangle( 100, 0, 0, love.graphics.getWidth(), topborder - 1 )

	 love.graphics.setFont(font2)
     love.graphics.draw(images[4], 17, 10)
     love.graphics.setColor( 153,255,153 )
     love.graphics.draw(global_counter_s, 30, 14)
	 love.graphics.draw(images[5], love.graphics.getWidth() - 17, 10)
     love.graphics.setColor( 247, 84, 225 )
     love.graphics.draw(global_counter_c, love.graphics.getWidth() - 32 - 6*string.len(tostring(global_counter_c)), 14)

-- Drawing of messages and count of collected messages
     love.graphics.draw(images[2], messes_x[1], messes_y[1])
     love.graphics.setColor( 0, 200, 0 )
     love.graphics.draw(counter_s, messes_x[1]+17, messes_y[1]+5)
     love.graphics.setColor( 200, 0, 0 )
     love.graphics.draw(counter, messes_x[1] - 17 - 9*string.len(tostring(counter)), messes_y[1]+5)

end
