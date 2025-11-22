-- Add:
 -- Difficulty
 -- Change options


function clamp(a, b, n)
	if a <= b then
		if n < a then return a elseif n > b then return b else return n end
	else
		if n < b then return b elseif n > a then return a else return n end
	end
end

function max(a, b)
	if a <= b then return b else return a end
end

function min(a, b)
	if a >= b then return b else return a end
end




function evaluate(board)
    -- Check for a win, loss, or draw
    for _, player in ipairs({'x', 'o'}) do
        for row = 1, 3 do
            if board[row][1] == player and board[row][2] == player and board[row][3] == player then
                return player == ai_marker and 10 or -10
            end
        end

        for col = 1, 3 do
            if board[1][col] == player and board[2][col] == player and board[3][col] == player then
                return player == ai_marker and 10 or -10
            end
        end

        if (board[1][1] == player and board[2][2] == player and board[3][3] == player) or
           (board[1][3] == player and board[2][2] == player and board[3][1] == player) then
            return player == ai_marker and 10 or -10
        end
    end

    local is_full = true
    for row = 1, 3 do
        for col = 1, 3 do
            if board[row][col] == 'e' then
                is_full = false
                break
            end
        end
    end

    if is_full then
        return 0  -- It's a draw
    end

    return nil  -- The game is still ongoing
end

function minimax(board, depth, is_maximizing)
    local score = evaluate(board)
    -- local score = check_board(board)
    if score then
        return score
    end

    if is_maximizing then
        local best_score = -math.huge
        for row = 1, 3 do
            for col = 1, 3 do
            	-- selected_grid = {row, col}
                if board[row][col] == 'e' then
                    board[row][col] = ai_marker
                    score = minimax(board, depth + 1, false)
                    board[row][col] = 'e'
                    best_score = math.max(score, best_score)
                end
            end
        end
        return best_score
    else
        local best_score = math.huge
        for row = 1, 3 do
            for col = 1, 3 do
            	-- selected_grid = {row, col}
                if board[row][col] == 'e' then
                    board[row][col] = player_marker
                    score = minimax(board, depth + 1, true)
                    board[row][col] = 'e'
                    best_score = math.min(score, best_score)
                end
            end
        end
        return best_score
    end
end

function ai_move(board)
    local best_score = -math.huge
    local best_move = nil

    for row = 1, 3 do
        for col = 1, 3 do
            if board[row][col] == 'e' then
                board[row][col] = ai_marker
                local score = minimax(board, 0, false)
                board[row][col] = 'e'
                if score > best_score then
                    best_score = score
                    best_move = {row, col}
                end
            end
        end
    end

    if best_move then
        local row, col = best_move[1], best_move[2]
        board[row][col] = ai_marker  -- Make the AI's move
        return row, col
    else
        return nil
    end
end






function reset_game()
	board = {{'e','e','e'},
			 {'e','e','e'},
			 {'e','e','e'}}

	player_turn = 1
	winning_player = 0
	selected_grid = {1,1}
	gameState = 'playing'
end

function check_board_for_win()
	local retval = check_board(board)
	if retval == -1 then
		tie:play()
	end
	if ai then
		if retval == ai_player then
			lose:play()
		elseif retval > 0 then
			win:play()
		end
	else
		if retval == 1 then
			P1_Win:play()
		elseif retval == 2 then
			P2_Win:play()
		end
	end
	if retval ~= 0 then gameState = 'game_over' end
	winning_player = retval
end

function check_board(grid)
	for l=1,3 do
		if grid[l][1] == 'x' and grid[l][2] == 'x' and grid[l][3] == 'x' then
			return 1
		end
		if grid[1][l] == 'x' and grid[2][l] == 'x' and grid[3][l] == 'x' then
			return 1
		end
		if grid[l][1] == 'o' and grid[l][2] == 'o' and grid[l][3] == 'o' then
			return 2
		end
		if grid[1][l] == 'o' and grid[2][l] == 'o' and grid[3][l] == 'o' then
			return 2
		end
	end
	if grid[3][1] == 'x' and grid[2][2] == 'x' and grid[1][3] == 'x' then return 1 end
	if grid[1][1] == 'x' and grid[2][2] == 'x' and grid[3][3] == 'x' then return 1 end
	if grid[3][1] == 'o' and grid[2][2] == 'o' and grid[1][3] == 'o' then return 2 end
	if grid[1][1] == 'o' and grid[2][2] == 'o' and grid[3][3] == 'o' then return 2 end

	if winning_player == 0 then
		local number_of_vacancies = 0
		for i=1,3 do
			for j=1,3 do
				if grid[i][j] == 'e' then number_of_vacancies = number_of_vacancies + 1 end
			end
		end
		if number_of_vacancies == 0 then
			return -1
		end
	end
	return 0
end

function play_audio(src)
	if src == 'click' then
		local playing = false
		local idx = 1
		while idx <= #clicks and not playing do
			if not clicks[idx]:isPlaying() then
				clicks[idx]:play()
				playing = true
			end
			idx = idx + 1
		end
		if playing == false then
			if #clicks <= 10 then
				table.insert(clicks, love.audio.newSource("Audio/click.mp3", 'static'))
				-- clicks[#clicks]:setVolume(.1)
				clicks[#clicks]:play()
			end
		end
	end
end

function button(txt, x, y, fn, gs)
	table.insert(buttons, {txt=txt,x=x,y=y,w=200,h=50,fn=fn,gs=gs,hot=false,hot_timer=0,active=true,offset=0})
end

function draw_buttons()
	for i,b in ipairs(buttons) do
		-- if b.hot then
		if gameState == b.gs then
			if b.active then
				love.graphics.setColor(1,1,0.749)
				love.graphics.rectangle('line', b.x - b.offset, b.y - b.offset, b.w + 2 * b.offset, b.h + 2 * b.offset, 5, 5)
				love.graphics.rectangle('line', b.x+2 - b.offset, b.y+2 - b.offset, b.w-4 + 2 * b.offset, b.h-4 + 2 * b.offset, 5, 5)
				love.graphics.printf(b.txt, b.x+4 - b.offset, b.y+10 - b.offset, b.w-8 + 2 * b.offset, 'center')
			else
				love.graphics.setColor(.6, .6, .6, 1)
				love.graphics.rectangle('line', b.x - b.offset, b.y - b.offset, b.w + 2 * b.offset, b.h + 2 * b.offset, 5, 5)
				love.graphics.rectangle('line', b.x+2 - b.offset, b.y+2 - b.offset, b.w-4 + 2 * b.offset, b.h-4 + 2 * b.offset, 5, 5)
				love.graphics.printf(b.txt, b.x+4 - b.offset, b.y+10 - b.offset, b.w-8 + 2 * b.offset, 'center')
			end
		-- else
		-- 	love.graphics.rectangle('line', b.x, b.y, b.w, b.h, 5, 5)
		-- 	love.graphics.rectangle('line', b.x+2, b.y+2, b.w-4, b.h-4, 5, 5)
		-- 	love.graphics.printf(b.txt, b.x+4, .by+5, b.w-8, 'center')
		end
	end
end

function update_buttons(dt)
	for i,b in ipairs(buttons) do
		if gameState == b.gs and b.active then
			if mx >= b.x and mx <= b.x + b.w and my >= b.y and my <= b.y + b.h then
				if not b.hot then play_audio('click') end
				b.hot = true
			else
				b.hot = false
			end
			if b.hot then
				b.hot_timer = b.hot_timer + 5 * dt
				b.offset = math.cos(b.hot_timer)
			else
				b.offset = 0
			end
		else
			b.hot = false
		end
	end
end

function love.load()
	math.randomseed(os.time())
	love.graphics.setBackgroundColor(0,0,.3)
	love.window.setMode( 600, 600 )

	win = love.audio.newSource("Audio/win.mp3", 'static')
	tie = love.audio.newSource("Audio/tie.mp3", 'static')
	lose = love.audio.newSource("Audio/lose.mp3", 'static')
	P1_Win = love.audio.newSource("Audio/P1_Win.mp3", 'static')
	P2_Win = love.audio.newSource("Audio/P2_Win.mp3", 'static')
	menu_music = love.audio.newSource("Audio/menu_music.mp3", 'stream')
	music = love.audio.newSource("Audio/music.mp3", 'stream')
	music:setVolume(.65)

	gameState = 'menu'

	clicks = {}
	buttons = {}

	titleFont = love.graphics.newFont("rt/ft.otf", 60)
	buttonFont = love.graphics.newFont("rt/ft.otf", 32)

	bigFont = love.graphics.newFont(72)
	regFont = love.graphics.newFont(12)
	-- love.graphics.setFont(bigFont)

	x_img, o_img = love.graphics.newImage("Graphics/X.png"), love.graphics.newImage("Graphics/O.png")

	local function fn_1()
		play_audio('click')
		gameState = 'setup'
		-- menu_music:stop()
	end
	local function fn_2() love.event.quit() end
	button("PLAY", 200, 200, fn_1, 'menu')
	button("QUIT", 200, 275, fn_2, 'menu')

	ai = true
	ai_player = 2

	diff = 1

	local function fn_3()
		play_audio('click')
		ai = not ai
		if ai then
			buttons[3].txt = "AI: ON"
			buttons[4].active = true
			buttons[5].active = true
		else
			buttons[3].txt = "AI: OFF"
			buttons[4].active = false
			buttons[5].active = false
		end
	end
	local function fn_4()
		play_audio('click')
		ai_player = ai_player + 1
		if ai_player > 2 then ai_player = 1 end
		buttons[4].txt = 'AI: '..ai_player
	end
	local function fn_5()
		play_audio('click')
		diff = diff + 1
		if diff > 4 then diff = 1 end
		buttons[5].txt = "Difficulty: "..diff
	end
	local function fn_6()
		play_audio('click')
		gameState = 'playing'
		menu_music:stop()
	end
	button("AI: ON", 200, 200, fn_3, 'setup')
	button("AI: "..ai_player, 200, 275, fn_4, 'setup')
	button("Difficulty: "..diff, 200, 350, fn_5, 'setup')
	button("PLAY", 200, 425, fn_6, 'setup')

	local function fn_7()
		reset_game()
		music:stop()
		gameState = 'menu'
	end
	local function fn_8()
		reset_game()
	end
	button("MENU", 200, 475, fn_7, "game_over")
	button("RESET", 200, 400, fn_8, "game_over")

	board = {{'e','e','e'},
			 {'e','e','e'},
			 {'e','e','e'}}

	rows, cols = 3, 3
	

	-- print("First or second?")
	-- ai_player = io.read("*l") + 1
	-- if ai_player > 2 then ai_player = 1 end

	player_turn = 1

	selected_button = 1

	if ai_player == 1 then
		ai_marker = 'x'
		player_marker = 'o'
	else
		ai_marker = 'o'
		player_marker = 'x'
	end

	winning_player = 0
	selected_grid = {1,1}
end

function love.draw()
	if gameState == 'menu' then
		love.graphics.setFont(titleFont)
		love.graphics.setColor(1,1,0.749)
		love.graphics.printf("Tic-Tac-OH NO", 0, 100, 600, 'center')

		love.graphics.setFont(buttonFont)
		draw_buttons()
	elseif gameState == 'setup' then
		love.graphics.setFont(buttonFont)
		draw_buttons()
	elseif gameState == 'playing'then
		love.graphics.setFont(bigFont)
		love.graphics.setColor(1,1,0.749)
		love.graphics.line(200,0,200,600)
		love.graphics.line(400,0,400,600)

		love.graphics.line(0,200,600,200)
		love.graphics.line(0,400,600,400)

		love.graphics.setColor(1,1,1)
		for i=1,3 do
			for j=1,3 do
				if board[i][j] == 'x' then
					love.graphics.draw(x_img, (i-1) * 200, (j - 1) * 200)
				elseif board[i][j] == 'o' then
					love.graphics.draw(o_img, (i-1) * 200, (j - 1) * 200)
				end
			end
		end

		love.graphics.setColor(.4,.4,.4,.7)
		love.graphics.rectangle('fill', (selected_grid[1] - 1) * 200 + 2, (selected_grid[2] - 1) * 200 + 2, 198, 198)

		if winning_player == 0 then
			love.graphics.setColor(1,1,1,.6)
			if player_turn == 1 then
				love.graphics.draw(x_img, (selected_grid[1]-1) * 200, (selected_grid[2] - 1) * 200)
			elseif player_turn == 2 then
				love.graphics.draw(o_img, (selected_grid[1]-1) * 200, (selected_grid[2] - 1) * 200)
			end
		end


		if winning_player > 0 then
			love.graphics.setColor(0,1,0,.7)
			love.graphics.rectangle('fill', 50, 50, 500, 500, 20, 20)
			love.graphics.setColor(1,1,1,1)
			love.graphics.printf("PLAYER "..winning_player.." WINS", 50, 200, 500, 'center')
		elseif winning_player < 0 then
			love.graphics.setColor(1,0,0,.7)
			love.graphics.rectangle('fill', 50, 50, 500, 500, 20, 20)
			love.graphics.setColor(1,1,1,1)
			love.graphics.printf("ALL PLAYERS LOSE", 50, 200, 500, 'center')
		end
		-- love.graphics.setColor(1,0,0,1)
		-- love.graphics.print(selected_grid[1]..", "..selected_grid[2], 10, 10)
	elseif gameState == 'game_over' then
		love.graphics.setFont(bigFont)
		love.graphics.setColor(1,1,0.749)
		love.graphics.line(200,0,200,600)
		love.graphics.line(400,0,400,600)

		love.graphics.line(0,200,600,200)
		love.graphics.line(0,400,600,400)

		love.graphics.setColor(1,1,1)
		for i=1,3 do
			for j=1,3 do
				if board[i][j] == 'x' then
					love.graphics.draw(x_img, (i-1) * 200, (j - 1) * 200)
				elseif board[i][j] == 'o' then
					love.graphics.draw(o_img, (i-1) * 200, (j - 1) * 200)
				end
			end
		end

		love.graphics.setColor(.4,.4,.4,.7)
		love.graphics.rectangle('fill', (selected_grid[1] - 1) * 200 + 2, (selected_grid[2] - 1) * 200 + 2, 198, 198)

		if winning_player == 0 then
			love.graphics.setColor(1,1,1,.6)
			if player_turn == 1 then
				love.graphics.draw(x_img, (selected_grid[1]-1) * 200, (selected_grid[2] - 1) * 200)
			elseif player_turn == 2 then
				love.graphics.draw(o_img, (selected_grid[1]-1) * 200, (selected_grid[2] - 1) * 200)
			end
		end


		if winning_player > 0 then
			love.graphics.setColor(0,1,0,.7)
			love.graphics.rectangle('fill', 50, 50, 500, 500, 20, 20)
			love.graphics.setColor(1,1,1,1)
			love.graphics.printf("PLAYER "..winning_player.." WINS", 50, 200, 500, 'center')
		elseif winning_player < 0 then
			love.graphics.setColor(1,0,0,.7)
			love.graphics.rectangle('fill', 50, 50, 500, 500, 20, 20)
			love.graphics.setColor(1,1,1,1)
			love.graphics.printf("ALL PLAYERS LOSE", 50, 200, 500, 'center')
		end

		love.graphics.setFont(buttonFont)
		draw_buttons()
	end
end

function love.update(dt)
	mx, my = love.mouse.getPosition()
	if gameState == 'menu' or gameState == 'setup' then
		update_buttons(dt)
		if not menu_music:isPlaying() then menu_music:play() end
	elseif gameState == 'playing' then
		if mx > 0 and mx < 600 and my > 0 and my < 600 then
			if selected_grid[1] ~= math.floor(mx / 200) + 1 or selected_grid[2] ~= math.floor(my / 200) + 1 then
				play_audio('click')
			end
			selected_grid[1] = math.floor(mx / 200) + 1
			selected_grid[2] = math.floor(my / 200) + 1
		end
		if not music:isPlaying() then music:play() end
		if ai and winning_player == 0 then
			if player_turn == ai_player then
				if diff == 1 then
					local possible_moves = {}
					for i=1,3 do
						for j=1,3 do
							if board[i][j] == 'e' then table.insert(possible_moves, {i, j}) end
						end
					end
					local rng = math.random(1, #possible_moves)
					board[possible_moves[rng][1]][possible_moves[rng][2]] = ai_marker
				elseif diff == 2 then
					local ai_marker, player_marker
					if ai_player == 1 then
						ai_marker = 'x'
						player_marker = 'o'
					else
						ai_marker = 'o'
						player_marker = 'x'
					end
					local future_board = {}
					for i=1,3 do future_board[i] = {} end
					for i=1,3 do
						for j=1,3 do
							future_board[i][j] = board[i][j]
						end
					end
					local score = 0
					local has_moved = false
					local possible_moves_to_tie = {}
					for i=1,3 do
						for j=1,3 do
							if not has_moved then
								if board[i][j] == 'e' then future_board[i][j] = ai_marker end
								local future_future_board = {}
								for l=1,3 do future_future_board[l] = {} end
								for l=1,3 do
									for k=1,3 do
										future_future_board[l][k] = future_board[l][k]
									end
								end
								for l=1,3 do
									for k=1,3 do
										if future_board[l][k] == 'e' then future_future_board[l][k] = player_marker end
										if check_board(future_future_board) == ai_player then
											board[i][j] = ai_marker 
											future_board[i][j] = 'e'
											future_future_board[l][k] = 'e'
											has_moved = true
											break
										elseif check_board(future_future_board) <= 0 then table.insert(possible_moves_to_tie, {i, j})
										else future_board[i][j] = 'e' end
									end
								end
							end
						end
					end
					if not has_moved then
						local rng = math.random(1,#possible_moves_to_tie)
						board[possible_moves_to_tie[rng][1]][possible_moves_to_tie[rng][2]] = ai_marker
						has_moved = true
					end
					if not has_moved then
						local possible_moves = {}
						for i=1,3 do
							for j=1,3 do
								if board[i][j] == 'e' then table.insert(possible_moves, {i, j}) end
							end
						end
						local rng = math.random(1,#possible_moves)
						board[possible_moves[rng][1]][possible_moves[rng][2]] = ai_marker
						has_moved = true
					end

					local possible_moves = {}
					for i=1,3 do
						for j=1,3 do
							if board[i][j] == 'e' then
								table.insert(possible_moves, {i, j})
							end
						end
					end
					local rng = math.random(1,#possible_moves)
					local move = {possible_moves[rng][1], possible_moves[rng][2]}
					board[move[1]][move[2]] = 'o'
				elseif diff == 3 then
					ai_move(board)
				elseif diff == 4 then
					local has_moved = false
					if board[1][1] == 'e' or board[1][1] == player_marker then
						board[1][1] = ai_marker
						has_moved = true
					end
					if (board[2][2] == 'e' or board[2][2] == player_marker) and not has_moved then
						board[2][2] = ai_marker
						has_moved = true
					end
					if (board[3][3] == 'e' or board[3][3] == player_marker) and not has_moved then
						board[3][3] = ai_marker
						has_moved = true
					end
				end

				check_board_for_win(board)
				player_turn = player_turn + 1
				if player_turn == 3 then player_turn = 1 end
			end
		end
	elseif gameState == 'game_over' then
		update_buttons(dt)
	end
-- 	if winning_player ~= 0 and love.keyboard.isDown("any") then
-- 		reset_game()
-- 	end
end

function love.mousereleased( x, y, button )
	if button == 1 then
		if gameState == 'menu' or gameState == 'setup' or gameState == 'game_over' then
			for i,b in ipairs(buttons) do
				if b.hot then b.fn() end
			end
		elseif gameState == 'playing' then
			if board[selected_grid[1]][selected_grid[2]] == 'e' then
				if player_turn == 1 then
					board[selected_grid[1]][selected_grid[2]] = 'x'
				elseif player_turn == 2 then
					board[selected_grid[1]][selected_grid[2]] = 'o'
				end
				player_turn = player_turn + 1
				if player_turn == 3 then player_turn = 1 end

				check_board_for_win(board)
			end
		end
	end
end

function love.keypressed( key )
	if key == 'a' or key == 'left' then
		play_audio('click')
		selected_grid[1] = selected_grid[1] - 1
		if selected_grid[1] < 1 then selected_grid[1] = 3 end
	end
	if key == 'd' or key == 'right' then
		play_audio('click')
		selected_grid[1] = selected_grid[1] + 1
		if selected_grid[1] > 3 then selected_grid[1] = 1 end
	end

	if key == 'w' or key == 'up' then
		play_audio('click')
		selected_grid[2] = selected_grid[2] - 1
		if selected_grid[2] < 1 then selected_grid[2] = 3 end
	end
	if key == 's' or key == 'down' then
		play_audio('click')
		selected_grid[2] = selected_grid[2] + 1
		if selected_grid[2] > 3 then selected_grid[2] = 1 end
	end
	if key == 'escape' then love.event.quit() end
end

function love.keyreleased( key )
	-- if winning_player ~= 0 and key then
	-- 	reset_game()
	-- end
	if key == 'space' then
		if board[selected_grid[1]][selected_grid[2]] == 'e' then
			if player_turn == 1 then
				board[selected_grid[1]][selected_grid[2]] = 'x'
			elseif player_turn == 2 then
				board[selected_grid[1]][selected_grid[2]] = 'o'
			end
			player_turn = player_turn + 1
			if player_turn == 3 then player_turn = 1 end

			check_board_for_win(board)
		end
	end
end




