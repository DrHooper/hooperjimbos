local msg_dictionary={
    -- do note that when using messages such as: 
    -- message = localize{type='variable',key='a_xmult',vars={current_xmult}},
    -- that the key 'a_xmult' will use provided values from vars={} in that order to replace #1#, #2# etc... in the localization file.

    a_chips="+#1#",
    a_chips_minus="-#1#",
    a_hands="+#1# Hands",
    a_handsize="+#1# Hand Size",
    a_handsize_minus="-#1# Hand Size",
    a_mult="+#1# Mult",
    a_mult_minus="-#1# Mult",
    a_remaining="#1# Remaining",
    a_sold_tally="#1#/#2# Sold",
    a_xmult="X#1# Mult",
    a_xmult_minus="-X#1# Mult",
}

SMODS.Atlas {
	-- Key for code to find it with
	key = "HooperJimbos",
	-- The name of the file, for the code to pull the atlas from
	path = "hooperjimbos.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Joker {
	-- How the code refers to the joker.
	key = 'doubleplanet',
	-- loc_text is the actual name and description that show in-game for the card.
	loc_txt = {
		name = 'Binary Satellites',
		text = {
			"Retrigger {C:planet}Planet{} cards"
		}
	},
	-- BP and BS compatable
	blueprint_compat = true,
	--[[
		Config sets all the variables for your card, you want to put all numbers here.
		This is really useful for scaling numbers, but should be done with static numbers -
		If you want to change the static value, you'd only change this number, instead
		of going through all your code to change each instance individually.
		]]
	config = { },
	-- loc_vars gives your loc_text variables to work with, in the format of #n#, n being the variable in order.
	-- #1# is the first variable in vars, #2# the second, #3# the third, and so on.
	-- It's also where you'd add to the info_queue, which is where things like the negative tooltip are.

    -- loc_vars = function(self, info_queue, card)
	-- 	return { vars = { } }
	-- end,

	-- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
	rarity = 3,
	-- Which atlas key to pull from.
	atlas = 'HooperJimbos',
	-- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
	pos = { x = 0, y = 0 },
	-- Cost of card in shop.
	cost = 8,
	-- The functioning part of the joker, looks at context to decide what step of scoring the game is on, and then gives a 'return' value if something activates.
	calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable.ability.set == 'Planet' then
			return {
                message = localize('k_again_ex'),
                func = function() context.consumeable:use_consumeable(context.consumeable.area or
                (context.blueprint and context.blueprint_card.area) or card.area,
                context.consumeable or (context.blueprint and context.blueprint_card) or card) end
            }
		end
	end
}

SMODS.Joker {
	key = 'holoerror',
	loc_txt = {
		name = 'Holo Error',
		text = {
			"random({C:red}xmult{})"
		}
	},
	blueprint_compat = true,
	config = {extra = {max = 30, min = 10}},
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 1, y = 0 },
	cost = 5,
	calculate = function(self, card, context)
		local temp_Mult = math.random(card.ability.extra.min, card.ability.extra.max)
		if context.joker_main then
		return {
			x_mult = temp_Mult / 10
		}
		end
	end
}

--Add edition to this joker at some point
SMODS.Joker {
	key = 'sidehustle',
	loc_txt = {
		name = 'Side Hustle',
		text = {
			"Earn {C:money}$1{} for each",
			"discarded card that",
			"has an {C:attention}enhancement{}",
		}
	},
	blueprint_compat = true,
	config = {extra = {dollars = 1}},
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 2, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.discard and not context.other_card.debuff and next(SMODS.get_enhancements(context.other_card)) then
			return{dollars = card.ability.extra.dollars}
		end
	end
}

-- SMODS.Joker {
-- 	key = 'reno',
-- 	loc_txt = {
-- 		name = 'Renovation',
-- 		text = {
-- 			"If {C:attention}poker hand{} is",
-- 			"{C:attention} Full House{},",
-- 			"the first 3 played",
-- 			"cards become {C:dark_edition}Foil{},",
-- 			"{C:dark_edition}Holographic{}, and",
-- 			"{C:dark_edition}Polychrome{}"
-- 		}
-- 	},
-- 	blueprint_compat = false,
-- 	config = { },
-- 	rarity = 3,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 3, y = 0 },
-- 	cost = 6,
-- 	calculate = function(self, card, context)
-- 		if context.before and context.main_eval and not context.blueprint and next(context.poker_hands['Full House']) then
-- 			return {
--                 message = localize('k_upgrade_ex'),
--                 colour = G.C.CHIPS,

-- 				context.scoring_hand[1]:set_edition(poll_edition("modprefix_seed", nil, true, true)),
-- 				context.scoring_hand[2]:set_edition('e_holo', nil, true, true),
-- 				context.scoring_hand[3]:set_edition('e_polychrome', nil, true, true),
-- 				G.E_MANAGER:add_event(Event({
--                     func = function()
--                         context.scoring_hand[1]:juice_up()
-- 						context.scoring_hand[2]:juice_up()
-- 						context.scoring_hand[3]:juice_up()
--                         return true
--                     end
--                 }))
--             }
-- 		end
-- 	end
-- }

SMODS.Joker {
	key = 'reno',
	loc_txt = {
		name = 'Renovation',
		text = {
			"If {C:attention}poker hand{} is",
			"{C:attention} Full House{}, destroy",
			"the first card"
		}
	},
	blueprint_compat = false,
	config = { },
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 3, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.destroy_card and not context.blueprint then
			if next(context.poker_hands['Full House']) and
			context.destroy_card == context.scoring_hand[1] then
			return {
				remove = true
            }
			end
		end
	end
}

SMODS.Joker {
	key = 'blue_clover',
	loc_txt = {
		name = 'Blue Clover',
		text = {
			"Gain {C:chips}+#2#{} Chips",
			"for each played",
			"card with {C:clubs}Club{} {C:attention}suit{}",
			"{C:inactive} (Currently{} {C:chips}+#1#{} {C:inactive}Chips){}"
		}
	},
	blueprint_compat = true,
	config = { extra = { chips = 0, chip_mod = 3, suit = 'Clubs' } },
	rarity = 1,
	atlas = 'HooperJimbos',
	pos = { x = 4, y = 0 },
	cost = 4,

	-- #1# in the description takes from the nth var in loc_vars
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
    end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and
		context.other_card:is_suit(card.ability.extra.suit) and not context.blueprint then

			card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod

			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.CHIPS,
				message_card = card
			}
		end

		if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
	end
}

SMODS.Joker {
	key = 'legendary_hooper',
	loc_txt = {
		name = 'Hooper',
		text = {
			"Skipping a {C:attention}blind{}",
			"creates a {C:red}Rare{} and",
			"{C:dark_edition}Negative{} skip tag"
		}
	},
	blueprint_compat = true,
	config = { },
	rarity = 4,
	atlas = 'HooperJimbos',
	pos = { x = 5, y = 0 },
	soul_pos = { x = 5, y = 1 },
	cost = 20,

	calculate = function(self, card, context)
		if context.skip_blind then
			G.E_MANAGER:add_event(Event({
                func = function()
                    add_tag(Tag("tag_rare"))
					add_tag(Tag("tag_negative"))
                    return true
                end
            }))
			return { message = ":3", colour = HEX("A681FF") }
		end
	end,
}

SMODS.Joker {
	key = 'recycling',
	loc_txt = {
		name = 'Recycling',
		text = {
			"Gain {C:mult}+#2#{} Mult",
			"for each discarded {C:attention}2{}",
			"{C:inactive} (Currently{} {C:mult}+#1#{} {C:inactive}Mult){}"
		}
	},
	blueprint_compat = true,
	config = { extra = { mult = 0, mult_mod = 2 } },
	rarity = 1,
	atlas = 'HooperJimbos',
	pos = { x = 4, y = 0 },
	cost = 4,

	-- #1# in the description takes from the nth var in loc_vars
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod } }
    end,

	calculate = function(self, card, context)
		if context.discard and context.other_card:get_id() == 2 and not context.other_card.debuff and not context.blueprint then

			local mult_amount = 0
			mult_amount = mult_amount + card.ability.extra.mult_mod

			card.ability.extra.mult = card.ability.extra.mult + mult_amount

			if mult_amount > 0 then
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
				}
			end
		end

		if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
	end
}

SMODS.Joker {
	key = 'energy_drink',
	loc_txt = {
		name = 'Energy Drink',
		text = {
			"Sell this card to",
			"temporarily gain {C:blue}+1{} hand"
		}
	},
	blueprint_compat = true,
	config = { extra = { hands = 1 } },
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 4, y = 0 },
	cost = 6,

	-- #1# in the description takes from the nth var in loc_vars
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands } }
    end,

	calculate = function(self, card, context)
		if context.selling_self and G.GAME.blind.in_blind then
			return {
                func = function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            ease_hands_played(card.ability.extra.hands)
                            SMODS.calculate_effect(
                                { message = localize { type = 'variable', key = 'a_hand', vars = { card.ability.extra.hands } } },
                                context.blueprint_card or card)
                            return true
                        end
                    }))
				end
			}
		end
	end
}

SMODS.Joker {
	key = 'foundation',
	loc_txt = {
		name = 'Foundation',
		text = {
			"Played {C:attention}Steel Cards{}",
			"each give {X:mult,C:white}X1.5{} Mult",
			"when scored"
		}
	},
	blueprint_compat = true,
	config = { extra = { xmult = 1.5 } },
	rarity = 3,
	atlas = 'HooperJimbos',
	pos = { x = 4, y = 0 },
	cost = 8,

	-- #1# in the description takes from the nth var in loc_vars
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and
		(SMODS.has_enhancement(context.other_card, 'm_steel')) then
			return {
                xmult = card.ability.extra.xmult
            }
		end
	end
}

SMODS.Joker {
	key = 'shooting_star',
	loc_txt = {
		name = 'Shooting Star',
		text = {
			"Earn {C:money}$1{} every time",
			"a {C:planet}Planet{} card is used"
		}
	},
	blueprint_compat = true,
	config = { extra = { dollars = 1 } },
	rarity = 1,
	atlas = 'HooperJimbos',
	pos = { x = 4, y = 0 },
	cost = 4,

	-- #1# in the description takes from the nth var in loc_vars
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

	calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable.ability.set == 'Planet' then
			return{dollars = card.ability.extra.dollars}
		end
	end
}
