local msg_dictionary={
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
	key = "HooperJimbos",
	path = "hooperjimbos.png",
	px = 71,
	py = 95
}


-- =============== COMMONS =============== --

-- Blue Clover (Gain Chips for Played Clubs)
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
	config = { extra = { chips = 0, chip_mod = 2, suit = 'Clubs' } },
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


-- Heart of Gold (Gain Money for Discarded Hearts)
SMODS.Joker {
	key = 'gold_heart',
	loc_txt = {
		name = 'Heart of Gold',
		text = {
			"Each discarded card with",
			"{C:hearts}Heart{} suit has a {C:green}#1# in #2#{}",
			"chance to earn {C:money}$1{}"
		}
	},
	blueprint_compat = true,
	config = { extra = { } },
	rarity = 1,
	atlas = 'HooperJimbos',
	pos = { x = 1, y = 1 },
	cost = 4,
	loc_vars = function(self, info_queue, card)
		return { vars = { G.GAME.probabilities.normal, 2 } }
	end,
	calculate = function(self, card, context)
		if context.discard and not context.other_card.debuff and context.other_card:is_suit('Hearts') then
			if pseudorandom('gold_heart') < G.GAME.probabilities.normal / 2 then
				return {
					dollars = 1
				}
			end
		end
	end
}


-- Dark Magic (Create a Tarot card if exactly 2 Spades are played)
SMODS.Joker {
	key = 'dark_magic',
	loc_txt = {
		name = 'Dark Magic',
		text = {
			"If played hand scores",
			"exactly {C:attention}2{} {C:spades}Spades{},",
			"create a {C:tarot}Tarot{} card",
			"{C:inactive}(Must have room){}"
		}
	},
	blueprint_compat = true,
	config = { extra = { } },
	rarity = 1,
	atlas = 'HooperJimbos',
	pos = { x = 2, y = 1 },
	cost = 4,
	calculate = function(self, card, context)
		if context.joker_main and context.scoring_hand then
			local spades_count = 0
			for _, scoring_card in ipairs(context.scoring_hand) do
				if scoring_card:is_suit('Spades') then
					spades_count = spades_count + 1
				end
			end

			if spades_count == 2 and #G.consumeables.cards < G.consumeables.config.card_limit then
				G.E_MANAGER:add_event(Event({
					func = function()
						local tarot = create_card('Tarot', G.consumeables)
						tarot:add_to_deck()
						G.consumeables:emplace(tarot)
						return true
					end
				}))

				return {
					message = localize('k_plus_tarot'),
					colour = G.C.SECONDARY_SET.Tarot
				}
			end
		end
	end
}


-- Hidden Gem (Diamond Suit Multiplier)
local function count_remaining_diamonds()
	local diamonds_count = 0
	if G.deck then
		for _, playing_card in ipairs(G.deck.cards) do
			if playing_card:is_suit('Diamonds') then
				diamonds_count = diamonds_count + 1
			end
		end
	end
	return diamonds_count
end

SMODS.Joker {
	key = 'hidden_gem',
	loc_txt = {
		name = 'Hidden Gem',
		text = {
			"Gain {C:mult}+2{} Mult for each",
			"remaining card with",
			"{C:diamonds}Diamond{} suit in {C:attention}deck{}",
			"{C:inactive}(Currently {C:mult}+#1#{} Mult){}"
		}
	},
	blueprint_compat = true,
	config = { extra = { mult_mod = 2 } },
	rarity = 1,
	atlas = 'HooperJimbos',
	pos = { x = 4, y = 1 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { count_remaining_diamonds() * card.ability.extra.mult_mod } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				mult = count_remaining_diamonds() * card.ability.extra.mult_mod
			}
		end
	end,
}


-- Recycling (Gain Mult for Discarded 2s)
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
	pos = { x = 3, y = 1 },
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


-- =============== UNCOMMONS =============== --

-- Liquid Gold (Scaling xmult)
SMODS.Joker {
	key = 'gold_mult',
	loc_txt = {
		name = 'Liquid Gold',
		text = {
			"This Joker gains",
			"{X:mult,C:white}X#2#{} Mult when a",
			"{C:attention}Gold{} card triggers",
			"{C:inactive} (Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}"
		}
	},

	blueprint_compat = true,
	config = { extra = { xmult = 1, xmult_mod = 0.1 } },
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 0, y = 2 },
	cost = 6,

	loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_mod } }
    end,

	calculate = function(self, card, context)
		if context.end_of_round and context.individual and not context.blueprint then
			if SMODS.has_enhancement(context.other_card, 'm_gold') then
				card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
					message_card = card
				}
			end
		end

		if context.joker_main then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
	end
}


-- Side Hustle (Earn Money for Discarded Enhancements)
SMODS.Joker {
	key = 'sidehustle',
	loc_txt = {
		name = 'Side Hustle',
		text = {
			"Earn {C:money}$1{} for each",
			"discarded card that",
			"has an {C:attention}Enhancement{}",
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


-- Renovation (Destroy First Card if Full House)
SMODS.Joker {
	key = 'reno',
	loc_txt = {
		name = 'Renovation',
		text = {
			"If {C:attention}poker hand{} is",
			"{C:attention} Full House{}, destroy",
			"the first scored card"
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


-- Energy Drink (Temporary Hand and Discard Boost)
local function energy_drink_active()
	return G.GAME and G.GAME.blind and G.GAME.blind.in_blind
end

SMODS.Joker {
	key = 'energy_drink',
	loc_txt = {
		name = 'Energy Drink',
		text = {
			"Sell this card to",
			"temporarily gain {C:blue}+#1#{} hand",
			"and {C:red}+#2#{} discard"
		}
	},
	blueprint_compat = true,
	config = { extra = { hands = 1, discards = 1 } },
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 0, y = 1 },
	cost = 6,

	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra.hands,
				card.ability.extra.discards
			}
		}
	end,

	calculate = function(self, card, context)
		if context.selling_self and energy_drink_active() then
			local hands = card.ability.extra.hands
			local discards = card.ability.extra.discards

			return {
				func = function()
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.3,
						func = function()
							ease_hands_played(hands)
							ease_discard(discards)
							return true
						end
					}))
				end
			}
		end
	end
}


-- Pressure Point
SMODS.Joker {
	key = 'pressure_point',
	loc_txt = {
		name = 'Pressure Point',
		text = {
			"When {C:attention}last hand{} of round",
			"is played, give the",
			"first scored card",
			"a random {C:attention}Enhancement{}"
		}
	},
	blueprint_compat = false,
	config = { },
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 5, y = 2 },
	cost = 7,
	calculate = function(self, card, context)
		if context.before and not context.blueprint
			and G.GAME.current_round.hands_left == 0
			and context.scoring_hand and context.scoring_hand[1] then
			local scored_card = context.scoring_hand[1]
			local enhancement = SMODS.poll_enhancement({
				key = 'pressure_point',
				guaranteed = true
			})

		scored_card:set_ability(G.P_CENTERS[enhancement], nil, true)
		G.E_MANAGER:add_event(Event({
			func = function()
				scored_card:juice_up()
				return true
			end
		}))

		return {
			message = localize('k_upgrade_ex'),
			colour = G.C.MONEY
		}
		end
	end,
}


-- Flapjacks (Money on round end based on empty joker slots)
SMODS.Joker {
	key = 'flapjacks',
	loc_txt = {
		name = 'Flapjacks',
		text = {
			"Earn {C:money}$#1#{} for each",
			"empty {C:attention}Joker{} slot",
			"at end of round,",
			"reduces by {C:money}$1{} every round"
		}
	},
	blueprint_compat = false,
	config = { extra = { dollars = 3, dollars_mod = 1 } },
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 5, y = 2 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars } }
	end,
	calc_dollar_bonus = function(self, card)
		local empty_joker_slots = math.max(
			0,
			G.jokers.config.card_limit - #G.jokers.cards
		)
		local dollars_earned = empty_joker_slots * card.ability.extra.dollars

		card.ability.extra.dollars = math.max(
			0,
			card.ability.extra.dollars - card.ability.extra.dollars_mod
		)

		if card.ability.extra.dollars == 0 then
			SMODS.destroy_cards(card, nil, nil, true)
			card_eval_status_text(card, 'extra', nil, nil, nil, {
				message = localize('k_eaten_ex'),
				colour = G.C.RED
			})
		end

		if dollars_earned > 0 then
			return dollars_earned
		end
	end
}

-- Wish (Sell after 3 rounds to Upgrade most played Poker Hand)
SMODS.Joker {
	key = 'wish',
	loc_txt = {
		name = 'Wish',
		text = {
			"After {C:attention}3{} rounds,",
			"sell this card to",
			"{C:attention}Upgrade{} your most",
			"played {C:attention}poker hand{}",
			"by {C:attention}3 levels{}",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}/3){}"
		}
	},
	blueprint_compat = false,
	config = { extra = { rounds = 0 } },
	rarity = 2,
	atlas = 'HooperJimbos',
	pos = { x = 5, y = 2 },
	cost = 8,

	loc_vars = function(self, info_queue, card)
		return { vars = { math.min(card.ability.extra.rounds, 3) } }
	end,

	calculate = function(self, card, context)
		if context.end_of_round
		and not context.individual
		and not context.repetition
		and not context.blueprint then
			card.ability.extra.rounds = card.ability.extra.rounds + 1

			if card.ability.extra.rounds == 3 then
				juice_card_until(card, function(current_card)
					return not current_card.REMOVED
				end, true)
			end

			return {
				message = card.ability.extra.rounds < 3
					and (card.ability.extra.rounds .. '/3')
					or localize('k_active_ex'),
				colour = G.C.FILTER
			}
		end

		if context.selling_self and card.ability.extra.rounds >= 3 then
			local most_played_hand
			local most_plays = -1

			for _, hand in ipairs(G.handlist) do
				local played = G.GAME.hands[hand].played
				if played > most_plays then
					most_played_hand = hand
					most_plays = played
				end
			end

			if most_played_hand then
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.6,
					func = function()
						local hand_data = G.GAME.hands[most_played_hand]

						update_hand_text(
							{ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
							{
								handname = localize(most_played_hand, 'poker_hands'),
								chips = hand_data.chips,
								mult = hand_data.mult,
								level = hand_data.level
							}
						)

						level_up_hand(card, most_played_hand, nil, 3)

						update_hand_text(
							{ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
							{ mult = 0, chips = 0, handname = '', level = '' }
						)

						return true
					end
				}))

				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.CHIPS
				}
			end
		end
	end
}
-- =============== RARES =============== --

-- Binary Satellites (Retrigger Planet Cards)
SMODS.Joker {
	key = 'doubleplanet',
	loc_txt = {
		name = 'Binary Satellites',
		text = {
			"Retrigger {C:planet}Planet{} cards"
		}
	},
	blueprint_compat = true,
	config = { },
	rarity = 3,
	atlas = 'HooperJimbos',
	pos = { x = 0, y = 0 },
	cost = 8,
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


-- Counterfeit Functions
local original_get_chip_bonus = Card.get_chip_bonus
local original_get_chip_mult = Card.get_chip_mult

local function counterfeit_active()
	if not G or not G.jokers then return false end

	for _, joker in ipairs(G.jokers.cards) do
		local center = joker.config and joker.config.center
		if not joker.debuff and center and (
			center.key == 'j_hooperjokers_counterfeit'
			or center.key == 'counterfeit'
			or center.original_key == 'counterfeit'
		) then
			return true
		end
	end

	return false
end

Card.get_chip_bonus = function(self)
	if self.playing_card and counterfeit_active() then
		return 0
	end

	return original_get_chip_bonus(self)
end

Card.get_chip_mult = function(self)
	local mult = original_get_chip_mult(self)

	if self.playing_card and counterfeit_active() then
		mult = mult + original_get_chip_bonus(self)
	end

	return mult
end

-- Counterfeit (Cards give +Mult instead of Chips when scored)
SMODS.Joker {
	key = 'counterfeit',
	loc_txt = {
		name = 'Counterfeit',
		text = {
			"Scored cards give {C:mult}Mult{}",
			"instead of {C:chips}Chips{}"
		}
	},
	blueprint_compat = false,
	config = { extra = { } },
	rarity = 3,
	atlas = 'HooperJimbos',
	pos = { x = 5, y = 2 },
	cost = 8,
}

-- Jackpot (Scored 7s have a chance to scale in Xmult)
SMODS.Joker {
	key = 'jackpot',
	loc_txt = {
		name = 'Jackpot',
		text = {
			"{C:green}#1# in #2#{} chance this Joker",
			"gains {X:mult,C:white}X#3#{} Mult when",
			"each played {C:attention}7{} is scored",
			"{C:inactive}(Currently{} {X:mult,C:white}X#4#{}{C:inactive}){}"
		}
	},
	blueprint_compat = true,
	config = {
		extra = {
			xmult = 1,
			xmult_mod = 0.25,
			odds = 4
		}
	},
	rarity = 3,
	atlas = 'HooperJimbos',
	pos = { x = 5, y = 2 },
	cost = 8,

	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				G.GAME and G.GAME.probabilities.normal or 1,
				card.ability.extra.odds,
				card.ability.extra.xmult_mod,
				card.ability.extra.xmult
			}
		}
	end,

	calculate = function(self, card, context)
		if context.individual
			and context.cardarea == G.play
			and not context.blueprint
			and context.other_card:get_id() == 7
			and pseudorandom('jackpot') < G.GAME.probabilities.normal / card.ability.extra.odds then

			card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod

			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.MULT,
				message_card = card
			}
		end

		if context.joker_main then
			return {
				Xmult = card.ability.extra.xmult
			}
		end
	end
}

-- The Archives --

-- Foundation
-- SMODS.Joker {
-- 	key = 'foundation',
-- 	loc_txt = {
-- 		name = 'Foundation',
-- 		text = {
-- 			"Played {C:attention}Steel Cards{}",
-- 			"each give {X:mult,C:white}X1.5{} Mult",
-- 			"when scored"
-- 		}
-- 	},
-- 	blueprint_compat = true,
-- 	config = { extra = { xmult = 1.5 } },
-- 	rarity = 3,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 1, y = 1 },
-- 	cost = 8,

-- 	-- #1# in the description takes from the nth var in loc_vars
--     loc_vars = function(self, info_queue, card)
--         return { vars = { card.ability.extra.xmult } }
--     end,

-- 	calculate = function(self, card, context)
-- 		if context.individual and context.cardarea == G.play and
-- 		(SMODS.has_enhancement(context.other_card, 'm_steel')) then
-- 			return {
--                 xmult = card.ability.extra.xmult
--             }
-- 		end
-- 	end
-- }

-- SMODS.Joker {
-- 	key = 'shooting_star',
-- 	loc_txt = {
-- 		name = 'Shooting Star',
-- 		text = {
-- 			"Earn {C:money}$1{} every time",
-- 			"a {C:planet}Planet{} card is used"
-- 		}
-- 	},
-- 	blueprint_compat = true,
-- 	config = { extra = { dollars = 1 } },
-- 	rarity = 1,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 1, y = 1 },
-- 	cost = 4,

-- 	-- #1# in the description takes from the nth var in loc_vars
--     loc_vars = function(self, info_queue, card)
--         return { vars = { card.ability.extra.dollars } }
--     end,

-- 	calculate = function(self, card, context)
-- 		if context.using_consumeable and context.consumeable.ability.set == 'Planet' then
-- 			return{dollars = card.ability.extra.dollars}
-- 		end
-- 	end
-- }

-- Shooting Star
-- SMODS.Joker {
-- 	key = 'firstdraw_money',
-- 	loc_txt = {
-- 		name = 'Diamond Hands',
-- 		text = {
-- 			"Money per random suit"
-- 		}
-- 	},
-- 	blueprint_compat = true,
-- 	config = { extra = { dollars = 1, suit = 'Clubs' } },
-- 	rarity = 2,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 4, y = 0 },
-- 	cost = 6,

-- 	-- #1# in the description takes from the nth var in loc_vars
--     loc_vars = function(self, info_queue, card)
--         return { vars = { card.ability.extra.dollars } }
--     end,

-- 	calculate = function(self, card, context)
-- 		if context.first_hand_drawn then
-- 			local suit_amount = 0
-- 			for _, playing_card in ipairs(context.full_hand) do
-- 				if playing_card.suit == card.ability.extra.suit then
-- 					suit_amount = suit_amount + 1
-- 				end
-- 			end
-- 			return{dollars = suit_amount}
-- 		end
-- 	end
-- }

-- Hooper
-- SMODS.Joker {
-- 	key = 'legendary_hooper',
-- 	loc_txt = {
-- 		name = 'Hooper',
-- 		text = {
-- 			"Skipping a {C:attention}blind{}",
-- 			"creates a {C:red}Rare{} and",
-- 			"{C:dark_edition}Negative{} skip tag"
-- 		}
-- 	},
-- 	blueprint_compat = true,
-- 	config = { },
-- 	rarity = 4,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 5, y = 0 },
-- 	soul_pos = { x = 5, y = 1 },
-- 	cost = 20,

-- 	calculate = function(self, card, context)
-- 		if context.skip_blind then
-- 			G.E_MANAGER:add_event(Event({
--                 func = function()
--                     add_tag(Tag("tag_rare"))
-- 					add_tag(Tag("tag_negative"))
--                     return true
--                 end
--             }))
-- 			return { message = ":3", colour = HEX("A681FF") }
-- 		end
-- 	end,
-- }

-- Old Renovation
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

-- Holo Error
-- SMODS.Joker {
-- 	key = 'holoerror',
-- 	loc_txt = {
-- 		name = 'Holo Error',
-- 		text = {
-- 			"random({C:red}xmult{})"
-- 		}
-- 	},
-- 	blueprint_compat = true,
-- 	config = {extra = {max = 30, min = 10}},
-- 	rarity = 2,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 1, y = 0 },
-- 	cost = 5,
-- 	calculate = function(self, card, context)
-- 		local temp_Mult = math.random(card.ability.extra.min, card.ability.extra.max)
-- 		if context.joker_main then
-- 		return {
-- 			x_mult = temp_Mult / 10
-- 		}
-- 		end
-- 	end
-- }

-- Celery
-- SMODS.Joker {
-- 	key = 'refund',
-- 	loc_txt = {
-- 		name = 'Celery',
-- 		text = {
-- 			"Money on pack skip",
-- 		}
-- 	},
-- 	blueprint_compat = true,
-- 	config = {extra = {dollars = 2, uses = 5, uses_mod = 1}},
-- 	rarity = 1,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 1, y = 1 },
-- 	cost = 4,
-- 	calculate = function(self, card, context)
-- 		if context.skipping_booster and not context.blueprint then
-- 			if card.ability.extra.uses - card.ability.extra.uses_mod <= 0 then
-- 				G.E_MANAGER:add_event(Event({
--                     func = function()
--                         play_sound('tarot1')
--                         card.T.r = -0.2
--                         card:juice_up(0.3, 0.4)
--                         card.states.drag.is = true
--                         card.children.center.pinch.x = true
--                         G.E_MANAGER:add_event(Event({
--                             trigger = 'after',
--                             delay = 0.3,
--                             blockable = false,
--                             func = function()
--                                 G.jokers:remove_card(card)
--                                 card:remove()
--                                 card = nil
--                                 return true
--                             end
--                         }))
--                         return true
--                     end
--                 }))
--                 return {
--                     message = localize('k_eaten_ex'),
--                     colour = G.C.MONEY
--                 }
-- 			else
-- 				card.ability.extra.uses = card.ability.extra.uses - card.ability.extra.uses_mod
-- 				return {dollars = card.ability.extra.dollars}
-- 			end
-- 		end
-- 	end
-- }

-- Old Wish (Destroy a solo 7 on the first hand to create an Uncommon Joker)
-- SMODS.Joker {
-- 	key = 'wish',
-- 	loc_txt = {
-- 		name = 'Wish',
-- 		text = {
-- 			"If {C:attention}first hand{} of round is",
-- 			"a single {C:attention}7{}, destroy it",
-- 			"and create an {C:green}Uncommon{} Joker",
-- 			"{C:inactive}(Must have room){}"
-- 		}
-- 	},
-- 	blueprint_compat = false,
-- 	config = { },
-- 	rarity = 2,
-- 	atlas = 'HooperJimbos',
-- 	pos = { x = 1, y = 1 },
-- 	cost = 7,
-- 	calculate = function(self, card, context)
-- 	if context.destroy_card and not context.blueprint
-- 		and context.full_hand and #context.full_hand == 1
-- 		and context.destroy_card == context.full_hand[1]
-- 		and context.full_hand[1]:get_id() == 7
-- 		and G.GAME.current_round.hands_played == 0 then
-- 			local can_create_joker =
-- 				#G.jokers.cards + (G.GAME.joker_buffer or 0) < G.jokers.config.card_limit

-- 			if can_create_joker then
-- 				G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) + 1
-- 				G.E_MANAGER:add_event(Event({
-- 					func = function()
-- 						SMODS.add_card({
-- 							set = 'Joker',
-- 							rarity = 'Uncommon',
-- 							area = G.jokers,
-- 							key_append = 'wish'
-- 						})
-- 						play_sound('timpani')
-- 						G.GAME.joker_buffer = math.max(0, (G.GAME.joker_buffer or 0) - 1)
-- 						return true
-- 					end
-- 				}))

-- 				return {
-- 					message = localize('k_plus_joker'),
-- 					colour = G.C.RARITY[2],
-- 					remove = true
-- 				}
-- 			end

-- 			return { remove = true }
-- 		end
-- 	end,
-- }
