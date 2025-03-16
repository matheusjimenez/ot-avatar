local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_WATERSPLASH)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ICE)

-- Definindo a área da rajada de água (formato de onda)
local area = {
    {0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0},
    {0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0}
}

combat:setArea(createCombatArea(area))

-- Função para calcular o dano baseado no nível e habilidades do jogador
function onGetFormulaValues(player, level, maglevel)
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
    
    local min = (level / 5) + (skillLevel * 0.8) + 8
    local max = (level / 5) + (skillLevel * 1.5) + 15
    return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    -- Verificar se é um jogador
    if creature:isPlayer() then
        local player = creature
        
        -- Game Masters sempre podem usar a magia
        if player:getGroup():getAccess() then
            return combat:execute(creature, var)
        end
        
        -- Para jogadores normais, verificar vocação
        local vocationId = player:getVocation():getId()
        if vocationId == 4 or vocationId == 8 then -- Knight ou Elite Knight
            return combat:execute(creature, var)
        else
            player:sendCancelMessage("Você não pode usar esta magia.")
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
    end
    
    return combat:execute(creature, var)
end

spell:group("attack")
spell:id(250) -- ID único para a magia
spell:name("Water Wave")
spell:words("w-wave")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_ENERGY_WAVE) -- Usando som de energy wave como placeholder
spell:level(50)
spell:mana(80)
spell:isPremium(true)
spell:needDirection(true)
spell:cooldown(6 * 1000) -- 6 segundos de cooldown
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("knight;true", "elite knight;true")
spell:register() 