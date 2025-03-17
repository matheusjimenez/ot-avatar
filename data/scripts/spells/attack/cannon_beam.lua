local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_WATERSPLASH)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FISHING)

-- Definindo as áreas do raio de canhão com 7 passos
local areas = {
    [7] = {
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [6] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [5] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [4] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [3] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [2] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    },
    [1] = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 3, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0}
    }
}

-- Criando os combats para cada passo
local combats = {}
for step, area in pairs(areas) do
    local stepCombat = Combat()
    stepCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
    stepCombat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_WATERSPLASH)
    stepCombat:setArea(createCombatArea(area))
    
    -- Função para calcular o dano baseado no nível e habilidades do jogador
    function onGetFormulaValues(player, level, maglevel)
        -- Verificar se é um Game Master
        if player:getGroup():getAccess() then
            return -10, -15 -- Dano maior para Game Masters
        end

        local skillLevel = player:getSkillLevel(SKILL_SWORD)
        if player:getSkillLevel(SKILL_CLUB) > skillLevel then
            skillLevel = player:getSkillLevel(SKILL_CLUB)
        end
        if player:getSkillLevel(SKILL_AXE) > skillLevel then
            skillLevel = player:getSkillLevel(SKILL_AXE)
        end
        
        local min = (level / 4) + (skillLevel * 1.2) + 15
        local max = (level / 4) + (skillLevel * 2.0) + 30
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
    -- Verificar se é um jogador
    if creature:isPlayer() then
        local player = creature
        
        -- Game Masters sempre podem usar a magia
        if player:getGroup():getAccess() then
            -- Executar todos os passos do combate com delay
            for step = 1, 7 do
                addEvent(function()
                    if creature and creature:isCreature() then
                        combats[step]:execute(creature, var)
                    end
                end, (step * 100) - 100)
            end
            return true
        end
        
        -- Para jogadores normais, verificar vocação
        local vocationId = player:getVocation():getId()
        if vocationId == 4 or vocationId == 8 then -- Knight ou Elite Knight
            -- Executar todos os passos do combate com delay
            for step = 1, 7 do
                addEvent(function()
                    if creature and creature:isCreature() then
                        combats[step]:execute(creature, var)
                    end
                end, (step * 100) - 100)
            end
            return true
        else
            player:sendCancelMessage("Você não pode usar esta magia.")
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
    end
    
    -- Executar todos os passos do combate com delay
    for step = 1, 7 do
        addEvent(function()
            if creature and creature:isCreature() then
                combats[step]:execute(creature, var)
            end
        end, (step * 100) - 100)
    end
    return true
end

spell:group("attack")
spell:id(251) -- ID único para a magia
spell:name("Cannon Beam")
spell:words("w-cannon")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_AVALANCHE_RUNE) -- Som padrão
spell:level(60)
spell:mana(100)
spell:isPremium(true)
spell:needDirection(true)
spell:cooldown(3 * 1000) -- 3 segundos de cooldown
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("knight;true", "elite knight;true")
spell:register() 