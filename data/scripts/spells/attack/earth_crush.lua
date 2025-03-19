local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)

function onGetFormulaValues(player, level, maglevel)
	local min = (level * 0.3) + (maglevel * 4) +10
	local max = (level * 0.45) + (maglevel * 6) + 20
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- Variável para controlar qual efeito será mostrado
local effectCounter = 0

-- Função para alternar entre os efeitos
function onTargetCreature(creature, target)
    
    -- Alterna entre os efeitos
    if effectCounter % 2 == 0 then
        combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_STONES)
    else
        combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GROUNDSHAKER)
    end
    
    -- Incrementa o contador para o próximo efeito
    effectCounter = effectCounter + 1
    
    return true
end

combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetCreature")

local area = {
	{ 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0 },
	{ 0, 0, 0, 0, 0 },
	{ 0, 1, 3, 1, 0 },
}

combat:setArea(createCombatArea(area))

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
	return combat:execute(creature, var)
end

spell:group("attack")
spell:id(264) -- ID único para a magia
spell:name("Earth Crush")
spell:words("e-crush")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:level(45)
spell:mana(180)
spell:isPremium(true)
spell:needDirection(true)
spell:cooldown(6 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("druid;true", "elder druid;true", "sorcerer;true", "master sorcerer;true")
spell:register() 