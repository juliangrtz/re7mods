-- Trainer for the 21 game mode in RE7.
-- by d3sc0le

if reframework:get_game_name() ~= "re7" then
    re.msg("[21 Trainer] Only compatible with RE7!")
    return
end

-- Taken from https://residentevil.fandom.com/wiki/Trump_cards.
local trumpCards = {
    { id = 10, name = "BetUp_1p", friendly = "One-Up", desc = "Draw 1 trump card; opponent’s bet +1 while on table." },
    { id = 12, name = "BetUp_2p", friendly = "Two-Up", desc = "Draw 1 trump card; opponent’s bet +2 while on table." },
    { id = 30, name = "Draw_2", friendly = "2-Card", desc = "Draw the 2-card. If it’s no longer in the deck, nothing happens." },
    { id = 31, name = "Draw_3", friendly = "3-Card", desc = "Draw the 3-card. If it’s no longer in the deck, nothing happens." },
    { id = 32, name = "Draw_4", friendly = "4-Card", desc = "Draw the 4-card. If it’s no longer in the deck, nothing happens." },
    { id = 33, name = "Draw_5", friendly = "5-Card", desc = "Draw the 5-card. If it’s no longer in the deck, nothing happens." },
    { id = 34, name = "Draw_6", friendly = "6-Card", desc = "Draw the 6-card. If it’s no longer in the deck, nothing happens." },
    { id = 35, name = "Draw_7", friendly = "Remove", desc = "Draw the 7-card. If it’s no longer in the deck, nothing happens." },
    { id = 54, name = "Return", friendly = "Return", desc = "Return the last face-up card you drew to the deck." },
    { id = 53, name = "Exchange", friendly = "Exchange", desc = "Swap the last cards drawn by you and your opponent (face-down cannot be swapped)." },
    { id = 57, name = "Destroy_p", friendly = "Destroy+", desc = "Remove all your opponent’s trump cards from the table." },
    { id = 58, name = "Destroy_pp", friendly = "Destroy++", desc = "Remove all opponent’s trump cards; they cannot use trump cards while this card is on the table." },
    { id = 56, name = "Destroy", friendly = "Destroy", desc = "Remove your opponent’s last placed trump card from the table." },
    { id = 45, name = "PerfectDraw", friendly = "Perfect Draw", desc = "Draw the best possible card from the deck." },
    { id = 47, name = "PerfectDraw_p", friendly = "Perfect Draw+", desc = "Draw the best possible card; opponent’s bet +5 while on table." },
    { id = 80, name = "Goal_24", friendly = "Go for 24", desc = "Closest to 24 wins while card is on table; replaces other Go-For cards." },
    { id = 82, name = "Goal_17", friendly = "Go for 17", desc = "Closest to 17 wins while card is on table; replaces other Go-For cards." },
    { id = 81, name = "Goal_27", friendly = "Go for 27", desc = "Closest to 27 wins while card is on table; replaces other Go-For cards." },
    { id = 50, name = "Gift", friendly = "Love Your Enemy", desc = "Your opponent draws the best possible card for them." },
    { id = 51, name = "SPChange", friendly = "Trump Switch", desc = "Discard two trump cards at random, then draw three more cards." },
    { id = 52, name = "SPChange_p", friendly = "Trump Switch+", desc = "Discard one trump card at random, then draw four more cards." },
    -- Enemy-Exclusive Cards, these cannot be added to the inventory!
    --[[
    { id = 61, name = "ShieldAssault", friendly = "Shield Assault", desc = "Remove three Shield cards from your side; opponent’s bet +3 while on table." },
    { id = 62, name = "ShieldAssault_p", friendly = "Shield Assault+", desc = "Remove two Shield cards; opponent’s bet +5 while on table." },
    { id = 63, name = "Happiness", friendly = "Happiness", desc = "Both players draw one trump card." },
    { id = 66, name = "Desire", friendly = "Desire", desc = "Opponent’s bet +½ the number of trump cards they’re holding while on table." },
    { id = 67, name = "Desire_p", friendly = "Desire+", desc = "Opponent’s bet +number of trump cards they’re holding while on table." },
    { id = 64, name = "MindShift", friendly = "Mind Shift", desc = "Opponent loses half of their trump cards at round end; removed if they use two in one turn." },
    { id = 65, name = "MindShift_p", friendly = "Mind Shift+", desc = "Opponent loses all trump cards at round end; removed if they use three in one turn." },
    { id = 71, name = "Conjuring", friendly = "Conjure", desc = "Draw three trump cards; your bet +1 while on table." },
    { id = 72, name = "BlackMagic", friendly = "Black Magic", desc = "Discard half your trump cards and draw best number card; opponent’s bet +10 while on table." },
    { id = 68, name = "Escape", friendly = "Escape", desc = "Provided this card is still on the table, you run for your life at the end of the round." },
    { id = 70, name = "Oblivion", friendly = "Oblivion", desc = "Cancels the round and begins a new one instead." },
    { id = 69, name = "DeadSilence", friendly = "Dead Silence", desc = "Opponent cannot draw cards—even via trump effects—while this card is on the table." },
    { id = 60, name = "Desperation", friendly = "Desperation", desc = "Both players’ bets are raised by 100; opponent cannot draw cards." },
    ]]
}

local trumpCardComboValues = {}
for _, v in ipairs(trumpCards) do
    table.insert(trumpCardComboValues, v.friendly)
end
local selectedTrumpCardIdx = 1
local currentTrumpCardId = 10
local cardGameMaster
local alwaysWin = false

sdk.hook(
    sdk.find_type_definition("app.CardGameMaster"):get_method("update"),
    function(args)
        if cardGameMaster ~= nil then return end
        cardGameMaster = sdk.to_managed_object(args[2])
    end,
    function(_) end
)

local posType
sdk.hook(
    sdk.find_type_definition("app.CardGameMaster"):get_method("calcSum"),
    function(args)
        if alwaysWin then
            posType = sdk.to_int64(args[3]) & 0xFFFFFFFF
        end
    end,
    function(retval)
        if alwaysWin then
            -- 0=Stock, 1=Banker, 2=Player
            if posType == 2 then
                return sdk.to_ptr(21)
            elseif posType == 1 then
                return sdk.to_ptr(666)
            end
        end
        return retval
    end
)


local function cardGameManager()
    return sdk.get_managed_singleton("app.CardGameManager")
end

re.on_draw_ui(function()
    if imgui.tree_node("21 Trainer") then
        imgui.text("Just keep your current hand.")
        imgui.text("You will always have a score of 21.")
        local changedAlwaysWin
        changedAlwaysWin, alwaysWin = imgui.checkbox("Always win", alwaysWin)

        imgui.spacing()

        if imgui.tree_node("Trump cards") then
            local changedTrumpCard, new_index = imgui.combo("Trump card", selectedTrumpCardIdx, trumpCardComboValues)
            if changedTrumpCard then
                selectedTrumpCardIdx = new_index
                local entry = trumpCards[selectedTrumpCardIdx]
                currentTrumpCardId = entry.id
            end

            imgui.text(trumpCards[selectedTrumpCardIdx].desc)

            if imgui.button("Give selected trump card") and cardGameManager then
                cardGameManager():addPlayerHandItem(currentTrumpCardId)
            end

            imgui.tree_pop()
        end

        --[[ if imgui.tree_node("Rewards") then
            if imgui.button("Unlock all rewards") and cardGameManager then
                for i = 0, 13 do
                    cardGameMaster:setAchievementContinuous(i, true)
                end
            end

            if imgui.button("Reset all rewards") and cardGameManager then
                cardGameMaster:changeMaster(2)
            end

            imgui.tree_pop()
        end ]]


        if imgui.tree_node("Miscellaneous") then
            if imgui.button("End game") and cardGameManager then
                cardGameMaster:setResult()
            end

            imgui.tree_pop()
        end

        --[[ if imgui.tree_node("Developer Tools") then
            if imgui.button("Log trump cards") then
                local itemType = sdk.find_type_definition("app.CardGameItem.ItemType")
                local fields = itemType:get_fields()

                for _, field in ipairs(fields) do
                    if field:is_static() then
                        local name = field:get_name()
                        local value = field:get_data(nil)
                        print(string.format("%s = %s", name, tostring(value)))
                    end
                end
            end
            imgui.tree_pop()
        end ]]

        imgui.tree_pop()
    end
end)
