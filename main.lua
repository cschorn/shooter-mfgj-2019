local WIDTH = 600
local HEIGHT = 800

local playerX = 0
local playerY = 0
local playerMove = 0
local playerSpeed = 0

local bullets = {}
local maxBullets = 4
local bulletsFired = 0
local fireCooldown = 0

local enemies = {}

local score = 0

local SPRITE_DIM = 32

local function createBullet(x, y)
    return {
        x = x,
        y = y,
    }
end

local function createEnemy(x, y)
    return {
        x = x,
        y = y,
    }
end

function love.load()
    love.window.setMode(600, 800)
    playerY = HEIGHT - SPRITE_DIM - 10

    playerSpeed = WIDTH / 2 -- 2 seconds to traverse screen
end

function love.update(dt)
    if #enemies == 0 then
        table.insert(enemies, createEnemy(
            math.floor(math.random() * (WIDTH - SPRITE_DIM)),
            math.floor(math.random() * HEIGHT / 2)
        ));
    end

    if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
        playerMove = -1
    elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
        playerMove = 1
    else
        playerMove = 0
    end

    local fire = love.keyboard.isDown('space')
    

    if playerMove ~= 0 then
        local minX = 0
        local maxX = WIDTH - SPRITE_DIM

        playerX = playerX + playerMove * playerSpeed * dt
        if playerX < minX then
            playerX = 0
        end
        if playerX > maxX then
            playerX = maxX
        end
    end

    if fire then
        if fireCooldown <= 0 and bulletsFired < maxBullets then
            table.insert(bullets, createBullet(playerX + SPRITE_DIM / 2, playerY))
            bulletsFired = bulletsFired + 1
            fireCooldown = 0.5
        end
    end
    if fireCooldown > 0 then
        fireCooldown = fireCooldown - dt
    end

    local r = {}
    local re = {}
    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - 800 * dt
        if bullet.y < 0 then
            table.insert(r, i)
        end
        for e, enemy in ipairs(enemies) do
            if bullet.x >= enemy.x and bullet.x <= enemy.x + SPRITE_DIM and bullet.y >= enemy.y and bullet.y <= enemy.y + SPRITE_DIM then
                table.insert(re, e)
                score = score + 1
            end
        end
    end
    
    table.sort(r, function (a, b) return a > b end)
    for _, rp in ipairs(r) do
        table.remove(bullets, rp)
        bulletsFired = bulletsFired - 1
    end

    table.sort(re, function (a, b) return a > b end)
    for _, rep in ipairs(re) do
        table.remove(enemies, rep)
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(score)
    love.graphics.rectangle('fill', playerX, playerY, 32, 32)
    for _, bullet in ipairs(bullets) do
        love.graphics.ellipse('fill', bullet.x, bullet.y, 4)
    end

    love.graphics.setColor(1, 0, 0)
    for _, enemy in ipairs(enemies) do
        love.graphics.rectangle('fill', enemy.x, enemy.y, 32, 32)
    end

end
