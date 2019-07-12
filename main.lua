local WIDTH = 600
local HEIGHT = 800

local playerX = 0
local playerY = 0
local playerMove = 0
local playerSpeed = 0

local bullets = {}
local maxBullets = 4
local fireCooldown = 0

local enemies = {}

local score = 0

local SPRITE_DIM = 32

local spritesheet = nil
local sprites = {}

local function createSprite(kind, x, y)
    return {
        kind = kind,
        x = x,
        y = y,
        alive = true,
    }
end

function love.load()
    love.window.setMode(600, 800)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    playerY = HEIGHT - SPRITE_DIM - 10

    playerSpeed = WIDTH / 2 -- 2 seconds to traverse screen

    spritesheet = love.graphics.newImage("sprites-simple.png")
    sprites.player = love.graphics.newQuad(0, 0, 8, 8, spritesheet:getDimensions())
    sprites.alien = love.graphics.newQuad(0, 8, 8, 8, spritesheet:getDimensions())
end

function love.update(dt)
    if #enemies == 0 then
        table.insert(enemies, createSprite(
            'enemy',
            math.floor(math.random() * (WIDTH - SPRITE_DIM)),
            - SPRITE_DIM
        ));
    end

    for _, enemy in ipairs(enemies) do
        enemy.y = enemy.y + 3
        if enemy.y > HEIGHT then
            enemy.alive = false
        end
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
        if fireCooldown <= 0 and #bullets < maxBullets then
            table.insert(bullets, createSprite('bullet', playerX + SPRITE_DIM / 2, playerY))
            fireCooldown = 0.5
        end
    end
    if fireCooldown > 0 then
        fireCooldown = fireCooldown - dt
    end

    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - 800 * dt
        if bullet.y < 0 then
            bullet.alive = false
        else
            for e, enemy in ipairs(enemies) do
                if bullet.x >= enemy.x and bullet.x <= enemy.x + SPRITE_DIM and bullet.y >= enemy.y and bullet.y <= enemy.y + SPRITE_DIM then
                    score = score + 1
                    enemy.alive = false
                    bullet.alive = false
                end
            end
        end
    end
    
    local livingEnemies = {}
    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            table.insert(livingEnemies, enemy)
        end
    end
    enemies = livingEnemies

    local livingBullets = {}
    for _, bullet in ipairs(bullets) do
        if bullet.alive then
            table.insert(livingBullets, bullet)
        end
    end
    bullets = livingBullets
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(score)
    love.graphics.draw(spritesheet, sprites.player, playerX, playerY, 0, 4, 4)
    for _, bullet in ipairs(bullets) do
        love.graphics.ellipse('fill', bullet.x, bullet.y, 4)
    end

    for _, enemy in ipairs(enemies) do
        love.graphics.draw(spritesheet, sprites.alien, enemy.x, enemy.y, 0, 4, 4)
    end

end
