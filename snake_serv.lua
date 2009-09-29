love.filesystem.require( "Server.lua" )
love.filesystem.require( "Binary.lua" )

count = 20	-- Count of pieces
mscount = 1	-- Number of messages, which snake was collected
sleep_time = 25	-- Delay in ms
j = 0	-- Number of the piece, which is moving now
j_client1 = 0
counter_s = 0
counter_c1 = 0
topborder = 20

global_counter_s = 0
global_counter_c1 = 0


-- Contains all pieces of the snake (server & client)
pieces_x = {}
pieces_y = {}
pieces_x_client1 = {}
pieces_y_client1 = {}
-- Contains all messages, which snake is collecting
messes_x = {}
messes_y = {}

datafromclient = {}


-- loading >>>
    key_time = 0	--Delay between pressing of keys
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
    y_cord = topborder + 13
    x_cord_client1 = 0
    y_cord_client1 = topborder + 303
    a = 1
    b = 0		-- a and b - Gain
    a_client1 = 1
    b_client1 = 0

    for i = 1,count do		 -- creating of arrays with pieces
       x_cord = x_cord + 5	 -- 5 == height and width of the piece.png
      pieces_x[i] = x_cord
      pieces_y[i] = y_cord
    end

    for i = 1,count do		 -- creating of arrays with pieces
       x_cord_client1 = x_cord_client1 + 5	 -- 5 == height and width of the piece1.png
      pieces_x_client1[i] = x_cord_client1
      pieces_y_client1[i] = y_cord_client1
    end

    for i=1,mscount do -- creating of arrays with messages, which snakes will collect
       messes_x[i] = 143+20*i
       messes_y[i] = 143+20*i
    end

    for i = 1,3 do
       table.insert(datafromclient, {data, ip, port})
    end

love.graphics.setBackgroundColor( 0,50,0 )

-- end of the loading <<<


-- Server part The beginning

function connCallback(ip, port)
	datafromclient[1].ip = ip
	datafromclient[1].port = port
end

function rcvCallback(data, ip, port)
	datafromclient[2].data = data
	datafromclient[2].ip = ip
	datafromclient[2].port = port
	if datafromclient[2].data:sub(1,1) == "a" then		--If client has sent which keys was pressed than unpack it
	   a_client1 = tonumber ( datafromclient[2].data:sub( 2, datafromclient[2].data:find("b") - 1 ) )
	   b_client1 = tonumber ( datafromclient[2].data:sub( datafromclient[2].data:find("b") + 1 ) )
	end
end

function disconnCallback(ip, port)
	datafromclient[3].ip = ip
	datafromclient[3].port = port
end

server:Init(9090)
server:setHandshake("Hi")
server:setCallback(rcvCallback, connCallback, disconnCallback)

-- Server part The end


function update(dt)
 server:update()		-- Updating

 love.timer.sleep( sleep_time )
 key_time = key_time + dt
 x_cord = x_cord+5*a
 y_cord = y_cord+5*b
 x_cord_client1 = x_cord_client1+5*a_client1
 y_cord_client1 = y_cord_client1+5*b_client1
	    server:send ("px_s" .. bin:pack(pieces_x) .. "py_s" .. bin:pack(pieces_y) .. "px_c1" .. bin:pack(pieces_x_client1) .. "py_c1" .. bin:pack(pieces_y_client1))
--Sending to client arrays which contain co-ordinates of both snakes

    id = isbordercrossed(x_cord, y_cord)	--Are snakes cross the border?
      if id~=0 then x_cord, y_cord = correctit(x_cord, y_cord,id) end		--If it so then correct it
    id=isbordercrossed(x_cord_client1, y_cord_client1)
      if id~=0 then x_cord_client1, y_cord_client1 = correctit(x_cord_client1, y_cord_client1,id) end


  j = j +1		-- Changing of the current piece (server)
  if j>count then j = 1 end
 pieces_x[j] = x_cord
 pieces_y[j] = y_cord

  j_client1 = j_client1 +1		-- Changing of the current piece (client1)
  if j_client1>count then j_client1 = 1 end
 pieces_x_client1[j] = x_cord_client1
 pieces_y_client1[j] = y_cord_client1


    if issnakeeatmessage(pieces_x,pieces_y,messes_x[1],messes_y[1]) then counter_s = counter_s + 1 ok = true
	--If snake has collect the message then incriminate counter
     elseif issnakeeatmessage(pieces_x_client1,pieces_y_client1,messes_x[1],messes_y[1]) then counter_c1 = counter_c1 + 1 ok = true
    end

	if counter_s > 4 then global_counter_s = global_counter_s + 1
		counter_s = 0
		counter_c1 = 0
		server:send("glob_c_s" .. tonumber(global_counter_s) .. "glob_c_c1" .. tonumber(global_counter_c1))
	  elseif counter_c1 > 4 then global_counter_c1 = global_counter_c1 + 1
		counter_s = 0
		counter_c1 = 0
	    server:send("glob_c_s" .. tonumber(global_counter_s) .. "glob_c_c1" .. tonumber(global_counter_c1))
	end

    if ok then		--If snake has collected the message then generate new message's co-ordinates
         repeat
           mark = 0
           messes_x[1] = math.random(52,love.graphics.getWidth() - 52)
           messes_y[1] = math.random(topborder + 9,love.graphics.getHeight() - 9)
           if issnkecrossthemess(pieces_x,pieces_y,messes_x[1],messes_y[1]) or issnkecrossthemess(pieces_x_client1,pieces_y_client1,messes_x[1],messes_y[1])
			then mark = 1
           end
         until mark == 0
       server:send("mes" .. tostring(messes_x[1]) .. "my" .. tostring(messes_y[1]) .. "cr_s" .. tostring(counter_s) .. "cr_c1" .. tostring(counter_c1))
       ok = false
    end

	if issnake1crossedsnake2(pieces_x,pieces_y,pieces_x_client1,pieces_y_client1,j,j_client1) == 2 then
		ok = true
		server:send("glob_c_s" .. tonumber(global_counter_s) .. "glob_c_c1" .. tonumber(global_counter_c1))
	  elseif issnake1crossedsnake2(pieces_x,pieces_y,pieces_x_client1,pieces_y_client1,j,j_client1) == 1 then
		global_counter_c1 = global_counter_c1 + 1
		ok = true
		server:send("glob_c_s" .. tonumber(global_counter_s) .. "glob_c_c1" .. tonumber(global_counter_c1))
	  elseif issnake1crossedsnake2(pieces_x_client1,pieces_y_client1,pieces_x,pieces_y,j_client1,j) == 1 then
		global_counter_s = global_counter_s + 1
		ok = true
		server:send("glob_c_s" .. tonumber(global_counter_s) .. "glob_c_c1" .. tonumber(global_counter_c1))
	end

	if not ok then
      if issnakecrosseditself(pieces_x,pieces_y) then
		global_counter_c1 = global_counter_c1 + 1
		ok = true
		server:send("glob_c_s" .. tonumber(global_counter_s) .. "glob_c_c1" .. tonumber(global_counter_c1))
	   elseif issnakecrosseditself(pieces_x_client1,pieces_y_client1) then
		global_counter_s = global_counter_s + 1
		ok = true
		server:send("glob_c_s" .. tonumber(global_counter_s) .. "glob_c_c1" .. tonumber(global_counter_c1))
	  end
	end

	--If snakes has crossed themselves then null all
	if ok then
		x_cord = 0
		y_cord = topborder + 13
		x_cord_client1 = 0
		y_cord_client1 = topborder + 303
		a = 1
		b = 0		-- a and b - Gain
		a_client1 = 1
		b_client1 = 0

		for i = 1,count do		 -- creating of arrays with pieces
			x_cord = x_cord + 5	 -- 5 == height and width of the piece.png
			pieces_x[i] = x_cord
			pieces_y[i] = y_cord
		end

		for i = 1,count do		 -- creating of arrays with pieces
			x_cord_client1 = x_cord_client1 + 5	 -- 5 == height and width of the piece1.png
			pieces_x_client1[i] = x_cord_client1
			pieces_y_client1[i] = y_cord_client1
		end

		j = 0
		j_client1 = 0
		counter_s = 0
		counter_c1 = 0
		server:send("mes" .. tostring(messes_x[1]) .. "my" .. tostring(messes_y[1]) .. "cr_s" .. tostring(counter_s) .. "cr_c1" .. tostring(counter_c1))
		ok = false
	end


end

-- Netsnake's own functions >>>

function inzone(x1, y1, x2, y2, xlim2, ylim2)	-- Is the point (x1,x2) in area of the point (x2,y2) with borders x2-limx2, x2+limx2, y2-limy2, y1+limy2 ?
    if (x2-xlim2<=x1) and (x1<=x2+xlim2) and (y2-ylim2<=y1) and (y1<=y2+ylim2) then
	return true
     else return false
   end
end

function isbordercrossed(x,y) 	 -- Is the border crossed?
   if x > love.graphics.getWidth() - 3 then return 1
     elseif x < 3 then return 2
     elseif y > love.graphics.getHeight() - 3 then return 3
     elseif y < topborder + 3 then return 4
   end
 return 0
end

function correctit(x,y,id)
   if id == 1 then x = 3
     elseif id == 2 then x = love.graphics.getWidth() - 3
     elseif id == 3 then y = topborder + 3
     elseif id == 4 then y = love.graphics.getHeight() - 3
   end
 return x,y
end

function issnakecrosseditself(table_x,table_y)	-- If the snake has crossed itself then return true
 for i = 1,count-1 do
   for j = i+1,count do
      if table_x[i]==table_x[j] then
	if table_y[i]==table_y[j] then
	  server:send("res")
	  love.timer.sleep( 1000 )
	  return true

	end	-- End of the 2nd if
      end		-- End of the 1st if
   end	-- End of the 2nd for
 end	-- End of the 1st for
 return false
end

function issnake1crossedsnake2(sn1x,sn1y,sn2x,sn2y,j,j2)	-- If the snake has crossed itself then return true
 if inzone(sn1x[j], sn1y[j], sn2x[j2], sn2y[j2], 5, 5) then
	  server:send("res")
	  love.timer.sleep( 1000 )
	  return 2
 end
 for i = 1,count-1 do
	if inzone(sn1x[j], sn1y[j], sn2x[i], sn2y[i], 5, 5) then
	  server:send("res")
	  love.timer.sleep( 1000 )
	  return 1
	end	-- End of the 2nd if
 end		-- End of if
 return 0
 end

function issnakeeatmessage(table_x,table_y,message_x_cord,message_y_cord)	 -- Is the snake eat a message?
   if inzone(table_x[j],table_y[j],message_x_cord,message_y_cord,15,7) then return true
	else return false
   end
end

function issnkecrossthemess(table_x,table_y,message_x_cord,message_y_cord) 	-- Is snake cross the message?
	for i = 1,count do
	   if inzone(table_x[i],table_y[i],message_x_cord,message_y_cord,15,7) then
	     return true
	   end
	end
return false
end

-- <<<


function keypressed(key)
 if key_time > 0.01 then
	-- Management from the keyboard:
  if key == love.key_up then
	if b == 0 then b = -1 a=0
  	end
    elseif key == love.key_down then
	if b == 0 then b = 1 a=0
    	end
    elseif key == love.key_right then
	if a == 0 then a = 1 b=0
    	end
    elseif key == love.key_left then
	if a == 0 then a = -1 b=0
    	end
  end
 key_time = 0
 end

end


function draw()

    for i = 1,count do		 -- Drawing of pieces
      love.graphics.draw(images[1], pieces_x[i], pieces_y[i])
    end

    for i = 1,count do		 -- Drawing of pieces
      love.graphics.draw(images[3], pieces_x_client1[i], pieces_y_client1[i])
    end

	love.graphics.setColor( 0, 0, 0 )
	love.graphics.line( 0, topborder, love.graphics.getWidth(), topborder )
	love.graphics.setColor( 0, 100, 0 )
	love.graphics.rectangle( 100, 0, 0, love.graphics.getWidth(), topborder - 1 )

	 love.graphics.setFont(font2)
     love.graphics.draw(images[4], 17, 10)
     love.graphics.setColor( 153,255,153 )
     love.graphics.draw(global_counter_s, 30, 14)
	 love.graphics.draw(images[5], love.graphics.getWidth() - 17, 10)
     love.graphics.setColor( 247, 84, 225 )
     love.graphics.draw(global_counter_c1, love.graphics.getWidth() - 32 - 6*string.len(tostring(global_counter_c1)), 14)

-- Drawing of messages and count of collected messages
     love.graphics.setFont(font1)
     love.graphics.draw(images[2], messes_x[1], messes_y[1])
     love.graphics.setColor( 0, 200, 0 )
     love.graphics.draw(counter_s, messes_x[1]+17, messes_y[1]+5)
     love.graphics.setColor( 200, 0, 0 )
     love.graphics.draw(counter_c1, messes_x[1] - 17 - 9*string.len(tostring(counter_c1)), messes_y[1]+5)

end
