local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_STONES)

-- IDs de pedras da barreira
local stoneIds = {8633, 8634, 8635, 8636} -- IDs dos diferentes tipos de pedras
local removeTime = 10 * 1000 -- Tempo para remover as pedras em milissegundos

-- Armazenar as barreiras criadas
local barriers = {}

-- Função para criar uma pedra na posição
local function createStone(position, stoneId, creatureId)
    -- Verifica se a posição é caminhável
    if Tile(position):isWalkable() then
        local item = Game.createItem(stoneId, 1, position)
        if item then
            -- Adiciona a posição da pedra ao registro de barreiras
            if not barriers[creatureId] then
                barriers[creatureId] = {}
            end
            table.insert(barriers[creatureId], position)
            return true
        end
    end
    return false
end

-- Função para remover as pedras após o tempo determinado
local function removeStones(creatureId)
    if barriers[creatureId] then
        for _, position in ipairs(barriers[creatureId]) do
            local tile = Tile(position)
            if tile then
                for _, stoneId in ipairs(stoneIds) do
                    local item = tile:getItemById(stoneId)
                    if item then
                        item:remove()
                    end
                end
            end
        end
        barriers[creatureId] = nil
    end
end

-- Função para criar a barreira na direção em que o jogador está olhando
local function createBarrier(creature)
    if not creature:isPlayer() then
        return false
    end
    
    local creatureId = creature:getId()
    local position = creature:getPosition()
    local barrierPositions = {}
    local direction = creature:getDirection()
    
    -- Determinar posições iniciais baseadas na direção
    local startPos = {x = position.x, y = position.y, z = position.z}
    local offset = {{x = 0, y = -1}, {x = 1, y = 0}, {x = 0, y = 1}, {x = -1, y = 0}}
    
    -- Define a posição inicial da barreira baseada na direção
    startPos.x = startPos.x + offset[direction + 1].x
    startPos.y = startPos.y + offset[direction + 1].y
    
    -- Define posições laterais baseadas na direção
    local lateralOffsets = {}
    if direction == DIRECTION_NORTH or direction == DIRECTION_SOUTH then
        lateralOffsets = {{x = -1, y = 0}, {x = 0, y = 0}, {x = 1, y = 0}}
    else
        lateralOffsets = {{x = 0, y = -1}, {x = 0, y = 0}, {x = 0, y = 1}}
    end
    
    -- Cria as pedras na linha da barreira
    for _, offset in ipairs(lateralOffsets) do
        local pos = {
            x = startPos.x + offset.x,
            y = startPos.y + offset.y,
            z = startPos.z
        }
        
        local stoneId = stoneIds[math.random(1, #stoneIds)]
        createStone(Position(pos.x, pos.y, pos.z), stoneId, creatureId)
    end
    
    -- Agenda a remoção das pedras
    addEvent(removeStones, removeTime, creatureId)
    return true
end

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    local result = createBarrier(creature)
    if result then
        return combat:execute(creature, var)
    end
    return false
end

spell:group("attack")
spell:id(265) -- ID único para a magia
spell:name("Earth Barrier")
spell:words("e-barrier")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:level(25)
spell:mana(85)
spell:isPremium(true)
spell:isSelfTarget(true)
spell:cooldown(6 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("druid;true", "elder druid;true", "sorcerer;true", "master sorcerer;true")
spell:register() 