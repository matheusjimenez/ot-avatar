local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICEATTACK)

-- Função para verificar se há pelo menos 5 quadrados de água próximos ao jogador
local function hasEnoughWaterTiles(position)
    local waterCount = 0
    local waterPositions = {}
    
    for x = -2, 2 do
        for y = -2, 2 do
            local checkPos = Position(position.x + x, position.y + y, position.z)
            local tile = Tile(checkPos)
            if tile then
                -- Verificar se o tile tem a propriedade de ser nadável
                if tile:hasProperty(CONST_PROP_SWIMMABLE) then
                    waterCount = waterCount + 1
                    table.insert(waterPositions, checkPos)
                    if waterCount >= 5 then
                        return true, waterPositions
                    end
                else
                    -- Verificar se o ground existe e é água
                    local ground = tile:getGround()
                    if ground then
                        local itemId = ground:getId()
                        -- Intervalo de IDs de água (ajuste conforme necessário)
                        if (itemId >= 4608 and itemId <= 4625) or -- Água normal
                           (itemId >= 4665 and itemId <= 4666) or -- Água rasa
                           (itemId >= 4820 and itemId <= 4825) then -- Água de pântano
                            waterCount = waterCount + 1
                            table.insert(waterPositions, checkPos)
                            if waterCount >= 5 then
                                return true, waterPositions
                            end
                        end
                    end
                end
            end
        end
    end
    return false, {}
end

-- Função para calcular o dano baseado no nível e habilidades do jogador
local function calculateDamage(player)
    -- Verificar se é um Game Master
    if player:getGroup():getAccess() then
        return -1000, -2000 -- Dano maior para Game Masters
    end

    local skillLevel = player:getSkillLevel(SKILL_SWORD)
    if player:getSkillLevel(SKILL_CLUB) > skillLevel then
        skillLevel = player:getSkillLevel(SKILL_CLUB)
    end
    if player:getSkillLevel(SKILL_AXE) > skillLevel then
        skillLevel = player:getSkillLevel(SKILL_AXE)
    end
    
    local level = player:getLevel()
    local min = (level / 5) + (skillLevel * 1.5) + 25
    local max = (level / 5) + (skillLevel * 2.5) + 50
    return -min, -max
end

-- Função para encontrar criaturas visíveis na tela
local function findVisibleMonsters(player, range)
    local monsters = {}
    local position = player:getPosition()
    
    -- Definir o alcance da visão do jogador (normalmente 7-8 quadrados)
    local viewRange = range or 8
    
    -- Verificar todas as posições dentro do alcance de visão
    for x = -viewRange, viewRange do
        for y = -viewRange, viewRange do
            local checkPos = Position(position.x + x, position.y + y, position.z)
            local tile = Tile(checkPos)
            
            if tile then
                local creatures = tile:getCreatures()
                if creatures then
                    for _, creature in ipairs(creatures) do
                        -- Adicionar apenas monstros (não jogadores ou NPCs)
                        if creature ~= player and creature:isMonster() and not creature:isPlayer() and not creature:isNpc() then
                            table.insert(monsters, creature)
                        end
                    end
                end
            end
        end
    end
    
    return monsters
end

-- Função para aplicar dano diretamente a uma criatura
local function doDamage(creature, target, minDamage, maxDamage)
    if not creature or not target then
        return false
    end
    
    local damage = math.random(minDamage, maxDamage)
    doTargetCombatHealth(creature:getId(), target, COMBAT_ICEDAMAGE, damage, damage, CONST_ME_ICETORNADO)
    return true
end

-- Função para disparar uma estrela congelada e causar dano
local function shootFrozenStar(cid, target, delay, minDamage, maxDamage)
    addEvent(function()
        local creature = Creature(cid)
        local targetCreature = Creature(target:getId())
        
        if creature and targetCreature then
            local creaturePos = creature:getPosition()
            local targetPos = targetCreature:getPosition()
            
            -- Enviar efeito visual da estrela congelada
            creaturePos:sendDistanceEffect(targetPos, CONST_ANI_SMALLICE)
            targetPos:sendMagicEffect(CONST_ME_ICEAREA)
            
            -- Aplicar dano ao alvo
            doDamage(creature, targetCreature, minDamage, maxDamage)
        end
    end, delay)
end

-- Função para criar efeito visual do dragão de água
local function createWaterDragonEffect(waterPositions)
    -- Escolher uma posição de água aleatória para o dragão
    local dragonPos = waterPositions[math.random(#waterPositions)]
    
    -- Efeito principal do dragão
    dragonPos:sendMagicEffect(CONST_ME_WATERSPLASH)
    
    -- Efeitos adicionais para dar forma ao dragão
    local headPos = Position(dragonPos.x, dragonPos.y, dragonPos.z)
    
    -- Verificar se as posições do corpo e cauda também estão na água
    local bodyPos1, bodyPos2, tailPos
    local validPositions = {}
    
    -- Verificar posições adjacentes e usar apenas as que estão na água
    for _, pos in ipairs(waterPositions) do
        if Position.getDistance(pos, dragonPos) == 1 then
            table.insert(validPositions, pos)
        end
    end
    
    -- Se tiver posições adjacentes válidas, usar para o corpo
    if #validPositions >= 3 then
        bodyPos1 = validPositions[1]
        bodyPos2 = validPositions[2]
        tailPos = validPositions[3]
    else
        -- Caso não tenha posições suficientes, usar apenas a posição principal
        bodyPos1 = dragonPos
        bodyPos2 = dragonPos
        tailPos = dragonPos
    end
    
    -- Enviar efeitos para formar o corpo do dragão
    headPos:sendMagicEffect(CONST_ME_WATERSPLASH)
    bodyPos1:sendMagicEffect(CONST_ME_BUBBLES)
    bodyPos2:sendMagicEffect(CONST_ME_BUBBLES)
    tailPos:sendMagicEffect(CONST_ME_WATERSPLASH)
    
    -- Efeito adicional para mostrar que o dragão está emergindo da água
    dragonPos:sendMagicEffect(CONST_ME_WATERCREATURE)
    
    return headPos
end

-- Função para invocar o dragão de água e disparar as estrelas congeladas
local function summonWaterDragon(player, waterPositions)
    -- Criar efeito visual do dragão de água dentro da água
    local dragonHeadPos = createWaterDragonEffect(waterPositions)
    
    -- Calcular dano
    local minDamage, maxDamage = calculateDamage(player)
    
    -- Encontrar monstros visíveis na tela
    local visibleMonsters = findVisibleMonsters(player)
    
    -- Se não houver monstros visíveis, apenas mostrar o efeito visual
    if #visibleMonsters == 0 then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "O dragão de água não encontrou alvos para atacar.")
    else
        -- Embaralhar a lista de monstros para selecionar alvos aleatórios
        for i = #visibleMonsters, 2, -1 do
            local j = math.random(i)
            visibleMonsters[i], visibleMonsters[j] = visibleMonsters[j], visibleMonsters[i]
        end
        
        -- Realizar 10 ataques, mesmo que seja no mesmo alvo
        for i = 1, 10 do
            -- Selecionar um alvo aleatório para cada ataque
            local targetIndex = math.random(math.min(#visibleMonsters, 5))
            local target = visibleMonsters[targetIndex]
            
            if target and target:isCreature() then
                shootFrozenStar(player:getId(), target, i * 200, minDamage / 5, maxDamage / 5)
            end
        end
    end
    
    -- Efeito de desaparecimento do dragão após 2.5 segundos
    addEvent(function()
        dragonHeadPos:sendMagicEffect(CONST_ME_POFF)
        
        -- Encontrar posições de água próximas para o efeito de submersão
        local splashPositions = {}
        for _, pos in ipairs(waterPositions) do
            if Position.getDistance(pos, dragonHeadPos) == 1 then
                table.insert(splashPositions, pos)
            end
        end
        
        -- Usar posições de água para os efeitos de splash
        if #splashPositions >= 2 then
            splashPositions[1]:sendMagicEffect(CONST_ME_WATERSPLASH)
            splashPositions[2]:sendMagicEffect(CONST_ME_WATERSPLASH)
        else
            -- Se não houver posições adjacentes, usar a posição principal
            dragonHeadPos:sendMagicEffect(CONST_ME_WATERSPLASH)
        end
    end, 2500)
    
    return true
end

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    local player = creature:getPlayer()
    if not player then
        return false
    end
    
    -- Verificar se o jogador é um knight
    local vocationId = player:getVocation():getId()
    if not player:getGroup():getAccess() and vocationId ~= 4 and vocationId ~= 8 then
        player:sendCancelMessage("Apenas Knights podem usar esta magia.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    -- Verificar se há água suficiente por perto
    local hasWater, waterPositions = hasEnoughWaterTiles(player:getPosition())
    if not hasWater then
        player:sendCancelMessage("Você precisa estar perto de pelo menos 5 quadrados de água para invocar o dragão de água.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    -- Invocar o dragão de água e disparar as estrelas congeladas
    return summonWaterDragon(player, waterPositions)
end

spell:group("attack")
spell:id(252) -- ID único para a magia
spell:name("Water Dragon")
spell:words("w-dragon")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_LARGE)
spell:level(80)
spell:mana(120)
spell:isPremium(true)
spell:cooldown(30 * 1000) -- 30 segundos de cooldown
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("knight;true", "elite knight;true")
spell:register() 