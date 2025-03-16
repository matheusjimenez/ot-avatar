local learnSpells = TalkAction("/learnspells")

function learnSpells.onSay(player, words, param)
    -- Verificar se o jogador é um Game Master
    if not player:getGroup():getAccess() then
        return true
    end

    -- Criar log
    logCommand(player, words, param)

    -- Ensinar todas as magias ao jogador
    for i = 1, 250 do
        player:learnSpell(i)
    end

    -- Ensinar especificamente a magia Water Wave
    player:learnSpell("Water Wave")

    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você aprendeu todas as magias disponíveis.")
    return true
end

learnSpells:separator(" ")
learnSpells:groupType("god")
learnSpells:register() 