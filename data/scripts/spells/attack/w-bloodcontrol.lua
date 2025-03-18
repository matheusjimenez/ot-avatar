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

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    -- Executar todos os pulsos do combate com delay
    for step = 1, 5 do
        addEvent(function()
            if creature and creature:isCreature() then
                combats[step]:execute(creature, var)
            end
        end, (step * 300) - 300)
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