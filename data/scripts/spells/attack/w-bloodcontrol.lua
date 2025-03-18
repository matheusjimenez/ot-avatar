local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 13)

-- Definição das áreas para os pulsos do Blood Control
local areas = {
    [1] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [2] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [3] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [4] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [5] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    }
}

-- Criando os combats para cada pulso
local combats = {}
for step = 1, 5 do
    local stepCombat = Combat()
    stepCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
    stepCombat:setParameter(COMBAT_PARAM_EFFECT, 13)
    stepCombat:setArea(createCombatArea(areas[step]))
    
    -- Função para calcular o dano baseado no nível e habilidades do jogador
    function onGetFormulaValues(player, level, maglevel)
        local min = (level / 5) + (maglevel * 0.4) + 3
        local max = (level / 5) + (maglevel * 0.7) + 5
        return -min, -max
    end
    
    stepCombat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
    
    -- Função para empurrar criaturas atingidas pela magia
    function onTargetCreature(creature, target)
        if target and target:isCreature() and target ~= creature then
            push(creature, target)
        end
        return true
    end
    
    stepCombat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")
    
    combats[step] = stepCombat
end

-- Função para empurrar uma criatura
function push(creature, target)
    local direction = creature:getDirection()
    
    local x = (direction == DIRECTION_EAST and 1 or (direction == DIRECTION_WEST and -1 or 0))
    local y = (direction == DIRECTION_NORTH and -1 or (direction == DIRECTION_SOUTH and 1 or 0))
    
    local position = target:getPosition()
    position.x = position.x + x
    position.y = position.y + y
    
    if target:teleportTo(position) then
        position:sendMagicEffect(CONST_ME_POFF)
    end
end

-- Função para verificar se duas posições estão adjacentes (1 sqm de distância)
local function arePositionsAdjacent(pos1, pos2)
    local xDiff = math.abs(pos1.x - pos2.x)
    local yDiff = math.abs(pos1.y - pos2.y)
    
    -- Se estão na mesma coordenada z (mesmo andar)
    if pos1.z == pos2.z then
        -- Se estão adjacentes horizontalmente, verticalmente ou diagonalmente (1 sqm de distância)
        if (xDiff <= 1 and yDiff <= 1) and not (xDiff == 0 and yDiff == 0) then
            return true
        end
    end
    
    return false
end

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    -- Verifica se é um jogador
    if not creature:isPlayer() then
        return false
    end
    
    local player = creature:getPlayer()
    local target = player:getTarget()
    
    -- Verifica se o alvo existe
    if not target then
        player:sendCancelMessage("Você precisa selecionar um alvo.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    -- Verifica se o alvo está a 1 sqm de distância
    local playerPos = player:getPosition()
    local targetPos = target:getPosition()
    
    if not arePositionsAdjacent(playerPos, targetPos) then
        player:sendCancelMessage("Você precisa estar a 1 quadrado de distância do alvo.")
        playerPos:sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    -- Aplicar imobilização ao jogador
    -- Usando condição CONDITION_ROOTED que impede movimento, mas não paralyze
    local condition = Condition(CONDITION_ROOTED)
    condition:setParameter(CONDITION_PARAM_TICKS, 1000) -- 1.5 segundos
    player:addCondition(condition)
    
    -- Efeito visual mostrando que o jogador está travado
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
    
    -- Executar todos os pulsos do combate com delay
    for step = 1, 7 do
        addEvent(function()
            if creature and creature:isCreature() then
                combats[step]:execute(creature, var)
            end
        end, (step * 250) - 300)
    end
    
    return true
end

spell:name("Blood Control")
spell:words("w-blood")
spell:group("attack")
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(20)
spell:mana(40)
spell:isAggressive(true)
spell:needTarget(true)
spell:needLearn(false)
spell:register()