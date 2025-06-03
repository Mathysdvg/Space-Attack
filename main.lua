-- SCROLLING
local scrolling = 0
local imageFond = love.graphics.newImage("source/image/fond.png")

-- SCORE
local score = 0

-- VAISSEAU
local vaisseau = {}
local imageVaisseau = love.graphics.newImage("source/image/ship.png")
local imageExplosion = love.graphics.newImage("source/image/explosion.png")

-- TIR
local tirs = {}
local imageTir = love.graphics.newImage("source/image/tir.png")

-- ENNEMIS
local imageEnnemi = love.graphics.newImage("source/image/ennemi.png")
local ennemis = {}
local timerEnnemis = 0
local frequenceEnnemis = 3 --Commence avec une soucoupe toutes les 3 secondes

-- SONS
local sonTir = love.audio.newSource("source/son/tir.wav", "static")
local sonExplosion = love.audio.newSource("source/son/explosion.wav", "static")

-- FONT
local scoreFont = love.graphics.newFont("source/font/pixelmix.ttf", 35)
love.graphics.setFont(scoreFont)

function InitJeu()
    score = 0
    vaisseau.x = 800 / 2
    vaisseau.y = 600 - imageVaisseau:getHeight()
    vaisseau.explosion = false
    tirs = {}
    ennemis = {}
end

function Tire()
    local leTir = {
        x = vaisseau.x,
        y = vaisseau.y
    }
    table.insert(tirs, leTir)
    sonTir:stop()
    sonTir:play()
end

function CreeEnnemi()
    local nouvelEnnemi = {
        x = love.math.random(0, 800),
        y = 0 - imageEnnemi:getHeight()
    }
    table.insert(ennemis, nouvelEnnemi)
end

function Distance(x1, y1, x2, y2)
    return ((x1 - x2) ^ 2 + (y1 - y2) ^ 2) ^ 0.5
end

function DrawCentre(image, x, y)
    love.graphics.draw(image, x - (image:getWidth() / 2), y - (image:getHeight() / 2))
end

function love.load()
    love.window.setTitle("Space Attack")
    InitJeu()
end

function love.update(dt)
    -- Déplacement vaisseau
    if vaisseau.explosion == false then
        if love.keyboard.isDown("left") and vaisseau.x > 0 + (imageVaisseau:getWidth() / 2) then
            vaisseau.x = vaisseau.x - 200 * dt
        end
        if love.keyboard.isDown("right") and vaisseau.x < 800 - (imageVaisseau:getWidth() / 2) then
            vaisseau.x = vaisseau.x + 200 * dt
        end
    end

    -- Code pour ajouter un ennemi toutes les x secondes
    timerEnnemis = timerEnnemis + dt
    if timerEnnemis >= frequenceEnnemis then
        CreeEnnemi()
        timerEnnemis = 0
    end

    if frequenceEnnemis > 0.5 then
        frequenceEnnemis = frequenceEnnemis - (0.01 * dt)
    end

    -- Mise à jour de l'ennemi
    for i = #ennemis, 1, -1 do
        ennemis[i].y = ennemis[i].y + 100 * dt
        if ennemis[i].y > 600 + (imageEnnemi:getHeight() / 2) then
            table.remove(ennemis, i)
        else
            if Distance(ennemis[i].x, ennemis[i].y, vaisseau.x, vaisseau.y) < imageVaisseau:getWidth() / 2 then
                vaisseau.explosion = true
                table.remove(ennemis, i)
                sonExplosion:stop()
                sonExplosion:play()
            end
        end
    end

    -- Gestion du tir
    for n = #tirs, 1, -1 do
        tirs[n].y = tirs[n].y - 400 * dt
        if tirs[n].y < 0 - (imageTir:getHeight() / 2) then
            table.remove(tirs, n)
        else -- Collision tir ennemi
            for i = #ennemis, 1, -1 do
                if Distance(ennemis[i].x, ennemis[i].y, tirs[n].x, tirs[n].y) < imageEnnemi:getWidth() / 2 then
                    score = score + 10
                    table.remove(tirs, n)
                    table.remove(ennemis, i)
                    sonExplosion:stop()
                    sonExplosion:play()
                end
            end
        end
    end

    -- Gestion du scrolling
    scrolling = scrolling + 50 * dt
    if scrolling >= imageFond:getHeight() then
        scrolling = 0
    end
end

function love.draw()
    love.graphics.draw(imageFond, 0, scrolling)
    love.graphics.draw(imageFond, 0, scrolling - imageFond:getHeight())
    for i, ennemi in ipairs(ennemis) do
        DrawCentre(imageEnnemi, ennemi.x, ennemi.y)
    end
    for n, tir in ipairs(tirs) do
        DrawCentre(imageTir, tir.x, tir.y)
    end
    if vaisseau.explosion == false then
        DrawCentre(imageVaisseau, vaisseau.x, vaisseau.y)
    else
        DrawCentre(imageExplosion, vaisseau.x, vaisseau.y)
    end
    love.graphics.print(score, 5, 5)
end

function love.keypressed(key)
    if vaisseau.explosion == false then
        if key == "space" then
            Tire()
        end
    end
    if key == "r" then
        InitJeu()
    end
end
