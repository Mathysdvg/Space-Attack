-- SCROLLING
local scrolling = 0
local imageFond = love.graphics.newImage("source/image/fond.png")

-- VAISSEAU
local vaisseau = {}
local imageVaisseau = love.graphics.newImage("source/image/ship.png")

-- TIR
local tirs = {}
local imageTir = love.graphics.newImage("source/image/tir.png")

-- ENNEMIS
local imageEnnemi = love.graphics.newImage("source/image/ennemi.png")
local ennemis = {}
local timerEnnemis = 0
local frequenceEnnemis = 3 --Commence avec une soucoupe toutes les 3 secondes

function InitJeu()
    vaisseau.x = 800 / 2
    vaisseau.y = 600 - imageVaisseau:getHeight()
    tirs = {}
    ennemis = {}
end

function Tire()
    local leTir = {
        x = vaisseau.x,
        y = vaisseau.y
    }
    table.insert(tirs, leTir)
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
    if love.keyboard.isDown("left") and vaisseau.x > 0 + (imageVaisseau:getWidth() / 2) then
        vaisseau.x = vaisseau.x - 200 * dt
    end
    if love.keyboard.isDown("right") and vaisseau.x < 800 - (imageVaisseau:getWidth() / 2) then
        vaisseau.x = vaisseau.x + 200 * dt
    end

    -- Code pour ajouter un ennemi toutes les x secondes
    timerEnnemis = timerEnnemis + dt
    if timerEnnemis >= frequenceEnnemis then
        local nouvelEnnemi = {
            x = love.math.random(0, 800),
            y = 0 - imageEnnemi:getHeight()
        }
        table.insert(ennemis, nouvelEnnemi)
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
        end
    end

    -- Gestion du tir
    for n = #tirs, 1, -1 do
        tirs[n].y = tirs[n].y - 400 * dt
        if tirs[n].y < 0 - (imageTir:getHeight() / 2) then
            table.remove(tirs, n)
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
    DrawCentre(imageVaisseau, vaisseau.x, vaisseau.y)
end

function love.keypressed(key)
    if key == "space" then
        Tire()
    end
end
