--  Author:         Evan Putnam
--  Description:    A LOVE graphics example for flappy bird 
--                  as a programming exersice for students in 
--                  late high school.



--Object to store bird
local bird = {
    _x = 62,
    y = 200,
    _width = 30,
    _height = 25,
    y_speed = 0
}

--Object to store barriers
local barrier_table = {
    barriers = {}
}

--Tell if we lost or not
local lost = false

--On the win screen if we tap to proceed
local tap_to_proceed_counter = 0

--Variable to keep score.
local score_incrementer = 0




--Other parameters, not to be modified.
local DELETE_X = -5
local BARRIER_START_X = 795

local OFFSET_MIN = -295
local OFFSET_MAX = 125

local SCREEN_DIMENSIONS = 600

local BARRIER_WIDTH = 20
local BARRIER_HEIGHT = 600


--Create a barrier at orientation y
local function createBarrier(x_p, y_p)
    --Crate a barrier with new coordinates
    local barrier = {
        x = x_p,
        y = y_p,
    }
    --Insert into the table
    table.insert(barrier_table.barriers, barrier)
end

--Resets the game params and creates first few barriers
local function resetGame()
    --Reset bird params
    bird.y = 200
    bird.y_speed = 0

    --Reset barriers
    barrier_table.barriers = {}

    --Reset scoring information
    lost = false
    score_incrementer = 0

    --Reset continue counter
    tap_to_proceed_counter = 0

    --Create first few barriers
    local offset = math.random(OFFSET_MIN, OFFSET_MAX)
    createBarrier(BARRIER_START_X, offset+(-300))
    offset = math.random(OFFSET_MIN, OFFSET_MAX)
    createBarrier(BARRIER_START_X+200, offset+(-300))
    offset = math.random(OFFSET_MIN, OFFSET_MAX)
    createBarrier(BARRIER_START_X+400, offset+(-300))
    offset = math.random(OFFSET_MIN, OFFSET_MAX)
    createBarrier(BARRIER_START_X+600, offset+(-300))

end




--Simple collision checking function between two squares.
local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end


--Initialize stuff here
function love.load()
    resetGame()
end

--Update each frame here
function love.update(dt)
    --If we are still in a valid state
    if lost == false then

        --Handle gravity
        if bird.y < SCREEN_DIMENSIONS - 30 then
            bird.y_speed = bird.y_speed + (500 * dt)
            bird.y = bird.y + (bird.y_speed * dt)
        else
            --We lose if we hit the floor!
            lost = true
        end

        --Move barriers to the left
        for i = 1,  table.getn(barrier_table.barriers) do
            --Move individual barrier to left
            barrier_table.barriers[i].x = barrier_table.barriers[i].x - 1

            --Check upper box
            local collision1 = checkCollision(bird._x, bird.y, bird._width, bird._height, 
                                barrier_table.barriers[i].x, barrier_table.barriers[i].y, 
                                BARRIER_WIDTH, BARRIER_HEIGHT)
            --Check lower box
            local collision2 = checkCollision(bird._x, bird.y, bird._width, bird._height, 
                                barrier_table.barriers[i].x, barrier_table.barriers[i].y + 750, 
                                BARRIER_WIDTH, BARRIER_HEIGHT)

            --If we collide we LOSE.
            if collision1 == true or collision2 == true then
                lost = true
            end

            --If barrier passes then increment score
            if barrier_table.barriers[i].x == bird._x then
                score_incrementer = score_incrementer + 1
            end
        end

        --Delete barriers when they are gone
        for i = 1,  table.getn(barrier_table.barriers) do
            --If the barrier moves past the threshold
            if barrier_table.barriers[i].x < DELETE_X then
                --Remove old barrier
                table.remove(barrier_table.barriers, 1)

                --Create new one
                local offset = math.random(OFFSET_MIN, OFFSET_MAX)
                createBarrier(BARRIER_START_X, offset+(-300))
                break
            end
        end

    end
end

--Handle key presses here
function love.keypressed(key)
    --Handle losing conditions
    if lost then
        tap_to_proceed_counter = tap_to_proceed_counter + 1
        if tap_to_proceed_counter > 4 then
            resetGame()
        end
    --Handle normal case
    else
        --If the bird is above ground then increase speed
        if bird.y > 0  then
            bird.y_speed = -160
        end
    end
end

--Draw here
function love.draw()
    --Draw background
    love.graphics.setColor(.14, .36, .46)
    love.graphics.rectangle('fill', 0, 0, SCREEN_DIMENSIONS, SCREEN_DIMENSIONS)

    --Handle lose screen
    if lost then
        --Draw score
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.print("YOU LOST! \nPress space several times to continue", SCREEN_DIMENSIONS/2, 50)

    --Handle game screen
    else

        --Draw bird
        love.graphics.setColor(.87, .84, .27)
        love.graphics.rectangle('fill', 62, bird.y, bird._width, bird._height)


        --Draw barriers
        love.graphics.setColor(0.0, 1.0, 0.0)
        for i = 1,  table.getn(barrier_table.barriers) do
            local barrier = barrier_table.barriers[i]
            love.graphics.rectangle('fill', barrier.x, barrier.y, BARRIER_WIDTH, BARRIER_HEIGHT)
            love.graphics.rectangle('fill', barrier.x, barrier.y+750, BARRIER_WIDTH, BARRIER_HEIGHT)
        end

        --Draw score
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.print(tostring(score_incrementer), SCREEN_DIMENSIONS/2, 50)
    end
end