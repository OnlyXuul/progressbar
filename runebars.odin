package progressbar

import "core:math/rand"

import "shared:afmt"

//	Progress Bar enums top level union
Bar :: union {
	Basic_Bar,
	Multi_Bar,
}

//	Basic Progress Bar enums variant - does not allocate
Basic_Bar :: enum u8 {
	default,
	standard,
}

//	Basic Progress Bar enum lookup table
@(rodata)
Basic_Bar_Create := [Basic_Bar]Basic_Bar_Proc {
	.default       = runebar_basic_default,
	.standard      = runebar_basic_standard,
}

//	Multi Progress Bar enums variant
Multi_Bar :: enum u8 {
	arrow,
	blackflag,
	ball,
	bits,
	bits_color,
	chain,
	deathstar,
	dracula,
	kayak,
	love,
	mjölnir,
	mouse,
	pacman,
	pacman_ghosts,
	trout,
	queens_march,
}

//	Multi Progress Bar enum lookup table - allocates
@(rodata)
Multi_Bar_Create := [Multi_Bar]Multi_Bar_Proc {
	.arrow         = runebar_multi_arrow,
	.ball          = runebar_multi_ball,
	.bits          = runebar_multi_bits,
	.bits_color    = runebar_multi_bits_color,
	.blackflag     = runebar_multi_blackflag,
	.chain         = runebar_multi_chain,
	.deathstar     = runebar_multi_deathstar,
	.dracula       = runebar_multi_dracula,
	.kayak         = runebar_multi_kayak,
	.love          = runebar_multi_love,
	.mjölnir       = runebar_multi_mjölnir,
	.mouse         = runebar_multi_mouse,
	.pacman        = runebar_multi_pacman,
	.pacman_ghosts = runebar_multi_pacman_ghosts,
	.trout         = runebar_multi_trout,
	.queens_march  = runebar_multi_queens_march,
}

//	Proc types for creation procedures
Basic_Bar_Proc :: #type proc(title: string, width := uint(25)) -> (pb: Progress_Bar)
Multi_Bar_Proc :: #type proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar)

//	Procedure helper for creating a Progress Bar using an Bar id
create_bar :: proc(bar_id: Bar, title: string, width := uint(25), allocator := context.allocator)  -> (pb: Progress_Bar) {
	switch id in bar_id {
	case Basic_Bar:
		pb = Basic_Bar_Create[id](title, width)
	case Multi_Bar:
		pb = Multi_Bar_Create[id](title, width, allocator)
	}
	return
}

//	Procedure helper for creating a random Progress Bar
create_random_bar :: proc(title: string, width := uint(25), allocator := context.allocator)  -> (pb: Progress_Bar) {
	basic_bar_count := len(Basic_Bar_Create)
	multi_bar_count := len(Multi_Bar_Create)
	total_bar_count := basic_bar_count + multi_bar_count

	bar := rand.int_range(0, total_bar_count)
	switch bar {
	case 0..<basic_bar_count:
		pb = create_bar(rand.choice_enum(Basic_Bar), title, width)
	case basic_bar_count..<total_bar_count:
		pb = create_bar(rand.choice_enum(Multi_Bar), title, width, allocator)
	}
	return
}

//	Basic Bar - does not allocate
runebar_basic_default :: proc(title: string, width := uint(25)) -> (pb: Progress_Bar) {
	pb = {
		width    = width,
		title    = {title, nil},
		lbracket = {" [",  nil},
		rbracket = {"] ",  nil},
		percent  = {"%",   nil},
		done     = {'◼',   nil},
		undone   = {'◻',   nil},
		glyph    = Rune{'◼', nil},
	}
	return
}

//	Basic Bar - does not allocate
runebar_basic_standard :: proc(title: string, width := uint(25)) -> (pb: Progress_Bar) {
	pb = {
		width    = width,
		title    = {title, afmt.ANSI4{fg = .FG_BLUE}},
		lbracket = {" ",   nil},
		rbracket = {" ",   nil},
		percent  = {"%",   afmt.ANSI4{fg = .FG_GREEN}},
		done     = {' ',   afmt.ANSI4{bg = .BG_GREEN}},
		undone   = {' ',   afmt.ANSI4{bg = .BG_BLUE}},
		glyph    = Rune{' ', afmt.ANSI4{bg = .BG_BRIGHT_GREEN}},
	}
	return
}

/*
runebar_multi_template :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 1

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	glyph[0][0] = {' ', {}}

	return {
		width    = width,
		title    = {title, {}},
		lbracket = {" ", {}},
		rbracket = {" ", {}},
		percent  = {" ", {}},
		done     = {' ', {}},
		undone   = {' ', {}},
		glyph    = glyph
	}
}
*/

//	Mulit_Bar - allocates using provided allocator
runebar_multi_arrow :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 10

	arrow  := [runes]rune {'‧', '‧', '»', '»', '―', '―', '―', '―', '―', '►'}
	format := [runes]afmt.ANSI24 {
		{},	{},
		{fg = afmt.RGB{150, 123, 220}},
		{fg = afmt.RGB{076, 166, 138}},
		{fg = afmt.RGB{150, 111, 051}},
		{fg = afmt.RGB{150, 111, 051}},
		{fg = afmt.RGB{150, 111, 051}},
		{fg = afmt.RGB{150, 111, 051}},
		{fg = afmt.RGB{150, 111, 051}},
		{fg = afmt.RGB{120, 120, 120}},
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for r in 0..<runes {
		glyph[0][r] = { arrow[r], format[r] }
	}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{170, 140, 250}}},
		lbracket = {" ⦒", {}},
		rbracket = {"⊙ ", afmt.ANSI24{fg = afmt.RGB{250, 020, 020}}},
		percent  = {"%", {}},
		done     = {'―', {}},
		undone   = {' ', {}},
		glyph    = glyph,
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_ball :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 4
	runes  :: 1

	ball   := [states]rune {'◐', '◓', '◑', '◒'}
	format := [states]afmt.ANSI24 {
		{fg = afmt.RGB{250, 050, 100}, at = {.UNDERLINE, .OVERLINED}},
		{fg = afmt.RGB{250, 050, 100}, at = {.UNDERLINE, .OVERLINED}},
		{fg = afmt.RGB{250, 050, 100}, at = {.UNDERLINE, .OVERLINED}},
		{fg = afmt.RGB{250, 050, 100}, at = {.UNDERLINE, .OVERLINED}},
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for s in 0..<states {
		glyph[s][0] = {ball[s], format[s]}
	}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{255, 239, 029}, at = {.UNDERLINE, .OVERLINED}}},
		lbracket = {" ",   afmt.ANSI24{fg = afmt.RGB{255, 135, 033}, at = {.UNDERLINE, .OVERLINED}}},
		rbracket = {" ",   afmt.ANSI24{fg = afmt.RGB{156, 000, 214}, at = {.UNDERLINE, .OVERLINED}}},
		percent  = {"%",   afmt.ANSI24{fg = afmt.RGB{033, 092, 255}, at = {.UNDERLINE, .OVERLINED}}},
		done     = {'○',   afmt.ANSI24{fg = afmt.RGB{255, 055, 055}, at = {.UNDERLINE, .OVERLINED}}},
		undone   = {' ',   afmt.ANSI24{fg = afmt.RGB{255, 055, 055}, at = {.UNDERLINE, .OVERLINED}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_bits :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  := int(width) * 3

	glyph  := make_glyph_multi(states, runes, allocator = allocator)
	for r in 0..<runes {
		bits := []rune {'0', '1'}
		rbit := rand.choice(bits)
		glyph[0][r] = {rbit, afmt.ANSI24{fg = afmt.RGB{250, 250, 250}}}
	}
	
	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{250, 250, 250}}},
		lbracket = {" ⇾ ", afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, at = {.BOLD}}},
		rbracket = {" ⇾ ", afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, at = {.BOLD}}},
		percent  = {"%",   afmt.ANSI24{fg = afmt.RGB{250, 250, 250}}},
		done     = {'0',   {}},
		undone   = {'0',   afmt.ANSI24{fg = afmt.RGB{120, 120, 120}, at = {.FAINT}}},
		glyph    = glyph,
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_bits_color :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  := int(width) * 3

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for r in 0..<runes {
		bits   := []rune {'0', '1'}
		rbit   := rand.choice(bits)
		rgb    := afmt.RGB{u8(rand.uint_range(0, 255)), u8(rand.uint_range(0, 255)), u8(rand.uint_range(0, 255))}
		format := afmt.ANSI24{fg = rgb}
		glyph[0][r] = {rbit, format}
	}
	
	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{250, 250, 250}}},
		lbracket = {" ⇾ ", afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, at = {.BOLD}}},
		rbracket = {" ⇾ ", afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, at = {.BOLD}}},
		percent  = {"%",   afmt.ANSI24{fg = afmt.RGB{250, 250, 250}}},
		done     = {'0',   {}},
		undone   = {'0',   afmt.ANSI24{fg = afmt.RGB{120, 120, 120}, at = {.FAINT}}},
		glyph    = glyph,
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_blackflag :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 8

	flag   := [runes]rune {'▕', ' ', '𓆩', '☠', ' ', '𓆪', ' ', '▏'}
	format := [runes]afmt.ANSI24 {
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD}},
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD, .OVERLINED, .UNDERLINE}},
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD, .OVERLINED, .UNDERLINE}},
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD, .OVERLINED, .UNDERLINE}},
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD, .OVERLINED, .UNDERLINE}},
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD, .OVERLINED, .UNDERLINE}},
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD, .OVERLINED, .UNDERLINE}},
		{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}, at = {.BOLD}},
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for r in 0..<runes {
		glyph[0][r] = {flag[r], format[r]}
	}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{255, 255, 255}, bg = afmt.RGB{000, 000, 000}}},
		lbracket = {" ",   afmt.ANSI24{bg = afmt.RGB{000, 000, 000}}},
		rbracket = {" ",   afmt.ANSI24{bg = afmt.RGB{000, 000, 000}}},
		percent  = {" 🪙", afmt.ANSI24{fg = afmt.RGB{252, 209, 039}, bg = afmt.RGB{000, 000, 000}}},
		done     = {'🄯',   afmt.ANSI24{fg = afmt.RGB{100, 100, 100}, bg = afmt.RGB{000, 000, 000}}},
		undone   = {'©',   afmt.ANSI24{fg = afmt.RGB{210, 210, 210}, bg = afmt.RGB{000, 000, 000}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_chain :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 2

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	glyph[0][0] = {'⫘', afmt.ANSI24{fg = afmt.RGB{200, 200, 200}, at = {.BOLD}}}
	glyph[0][1] = {'⫘', afmt.ANSI24{fg = afmt.RGB{240, 240, 250}, at = {.BOLD}}}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{175, 175, 220}}},
		lbracket = {" ⦙",  afmt.ANSI24{fg = afmt.RGB{031, 031, 226}, at = {.BOLD}}},
		rbracket = {"⦙ ",  afmt.ANSI24{fg = afmt.RGB{031, 031, 226}, at = {.BOLD}}},
		percent  = {"%",   afmt.ANSI24{fg = afmt.RGB{175, 175, 220}}},
		done     = {'⫘',   afmt.ANSI24{fg = afmt.RGB{175, 175, 200}, at = {.BOLD}}},
		undone   = {'⫘',   afmt.ANSI24{fg = afmt.RGB{100, 100, 110}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_deathstar :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states := int(width)
	runes  := int(width)

	lazer_end := '⋗'
	lazer_line := '―'

	lazer_format := afmt.ANSI_24Bit {fg = afmt.RGB{33, 242, 45}, bg = afmt.RGB{0,0,0}}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for s in 0..<states {
		for r in 0..<runes {
			glyph[s][r] = {lazer_line, lazer_format}
			glyph[s][runes-s-1] = {lazer_end, lazer_format}
		}
	}

	alderaan := afmt.tprint(afmt.ANSI24{fg = afmt.RGB{67, 199, 238}, bg = afmt.RGB{0,0,0}}, "⚈")
	moon := afmt.tprint(afmt.ANSI24{fg = afmt.RGB{115, 158, 171}, bg = afmt.RGB{0,0,0}}, "● ")
	alderaan = afmt.tprintf("%s%s", alderaan, moon)

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{244, 71, 62}, bg = afmt.RGB{0,0,0}}},
		lbracket = {" ⚆", afmt.ANSI24{fg = afmt.RGB{166, 166, 166}, bg = afmt.RGB{0,0,0}, at = {.BOLD}}},
		rbracket = {alderaan, {}},
		percent  = {"⊛ ", afmt.ANSI24{fg = afmt.RGB{181, 98, 73}, bg = afmt.RGB{0,0,0}}},
		done     = {' ', afmt.ANSI24{bg = afmt.RGB{0,0,0}}},
		undone   = {' ', afmt.ANSI24{bg = afmt.RGB{0,0,0}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_dracula :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 4

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	glyph[0][0] = {'ᐤ', afmt.ANSI24{fg = afmt.crimson}}
	glyph[0][1] = {'ᐤ', afmt.ANSI24{fg = afmt.crimson}}
	glyph[0][2] = {'^', afmt.ANSI24{fg = afmt.white}}
	glyph[0][3] = {'^', afmt.ANSI24{fg = afmt.white}}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.crimson}},
		lbracket = {" ",  {}},
		rbracket = {" ◥ (", afmt.ANSI24{fg = afmt.steelblue, at = {.BOLD}}},
		percent  = {"%)◤", afmt.ANSI24{fg = afmt.steelblue, at = {.BOLD}}},
		done     = {'ཀ', afmt.ANSI24{fg = afmt.crimson, at = {.UNDERLINE}}},
		undone   = {'_', afmt.ANSI24{fg = afmt.pink}},
		glyph    = glyph,
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_kayak:: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 4
	runes  :: 7

	kayak  := [runes]rune  {'}', '}', '}', '⋖', ' ', '⋗', '}'}
	rower  := [states]rune {'≒', '≑', '≓', '≑'}
	format := [runes]afmt.ANSI24 {
		{fg = afmt.RGB{012, 215, 252}, at = {.FAINT, .OVERLINED, .UNDERLINE}},
		{fg = afmt.RGB{012, 215, 252}, at = {.FAINT}},
		{fg = afmt.RGB{012, 215, 252}, at = {.FAINT}},
  	{fg = afmt.RGB{241, 120, 114}, at = {.BOLD}},
		{fg = afmt.RGB{241, 120, 114}, at = {.BOLD}},
  	{fg = afmt.RGB{241, 120, 114}, at = {.BOLD}},
		{fg = afmt.RGB{012, 215, 252}, at = {.BOLD}},
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for s in 0..<states {
		for r in 0..<runes {
			if r == 4 {
				glyph[s][r] = { rower[s], format[r] }
			} else {
				glyph[s][r] = { kayak[r], format[r] }
			}
		}
	}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{033, 124, 254}}},
		lbracket = {" ∰",  afmt.ANSI24{fg = afmt.RGB{181, 243, 254}, at = {.BOLD}}},
		rbracket = {"∰ ",  afmt.ANSI24{fg = afmt.RGB{181, 243, 254}, at = {.BOLD}}},
		percent  = {"%",   afmt.ANSI24{fg = afmt.RGB{032, 216, 165}}},
		done     = {'≍',   afmt.ANSI24{fg = afmt.RGB{012, 215, 252}, at = {.FAINT, .OVERLINED, .UNDERLINE}}},
		undone   = {'≋',   afmt.ANSI24{fg = afmt.RGB{012, 215, 252}, at = {.BOLD}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_love :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 2

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	glyph[0][0] = {'♡', afmt.ANSI24{fg = afmt.RGB{255, 071, 112}, at = {.UNDERLINE}}}
	glyph[0][1] = {' ', afmt.ANSI24{fg = afmt.RGB{255, 071, 112}, at = {.UNDERLINE}}}

	return {
		width    = width,
		title    = {title,    afmt.ANSI24{fg = afmt.RGB{255, 071, 112}}},
		lbracket = {" --{@ ", afmt.ANSI24{fg = afmt.RGB{200, 000, 95}}},
		rbracket = {" @}-- ", afmt.ANSI24{fg = afmt.RGB{200, 000, 95}}},
		percent  = {"%",      afmt.ANSI24{fg = afmt.RGB{255, 071, 112}}},
		done     = {'๑',      afmt.ANSI24{fg = afmt.RGB{255, 187, 202}, at = {.UNDERLINE}}},
		undone   = {'๑',      afmt.ANSI24{fg = afmt.RGB{178, 144, 152}, at = {.UNDERLINE}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_mjölnir :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 4
	runes  :: 3
	
	mjölnir := [states][runes]rune {
		{'·', ' ', '⊤'},
		{'·', ' ', '⊣'},
		{'·', ' ', '⊥'},
		{'·', ' ', '⊢'},
	}

	format := [runes]afmt.ANSI24 {
		{fg = afmt.RGB{206, 174, 071}, at = {.BOLD, .UNDERLINE, .OVERLINED}},
		{fg = afmt.RGB{206, 174, 071}, at = {.UNDERLINE, .OVERLINED}},
		{fg = afmt.RGB{206, 174, 071}, at = {.BOLD, .UNDERLINE, .OVERLINED}},
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for s in 0..<states {
		for r in 0..<runes {
			glyph[s][r] = {mjölnir[s][r], format[r]}
		}
	}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{253, 100, 081}}},
		lbracket = {" ᚦ ", afmt.ANSI24{fg = afmt.RGB{253, 100, 081}}},
		rbracket = {" ᛟ ", afmt.ANSI24{fg = afmt.RGB{077, 188, 100}}},
		percent  = {"٪",   afmt.ANSI24{fg = afmt.RGB{111, 165, 185}}},
		done     = {'·',   afmt.ANSI24{fg = afmt.RGB{237, 209, 095}, at = {.UNDERLINE, .OVERLINED}}},
		undone   = {' ',   afmt.ANSI24{fg = afmt.RGB{168, 169, 173}, at = {.UNDERLINE, .OVERLINED}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_mouse :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 8
	mouse  := [runes]rune{'~', '~', '(', '_', '_', '^', '·', '>'}
	format := [runes]afmt.ANSI24 {
		{fg = afmt.RGB{248, 194, 218}},
		{fg = afmt.RGB{248, 194, 218}},
		{fg = afmt.RGB{240, 239, 235}},
		{fg = afmt.RGB{255, 255, 255}},
		{fg = afmt.RGB{255, 255, 255}},
		{fg = afmt.RGB{248, 194, 218}},
		{fg = afmt.RGB{244, 0, 0}},
		{fg = afmt.RGB{255, 255, 255}},
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for i in 0..<runes {
		glyph[0][i] = {mouse[i], format[i]}
	}
	
	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{115, 113, 116}}},
		lbracket = {" 🕳 ", afmt.ANSI24{fg = afmt.RGB{104, 71, 52}}},
		rbracket = {"🕳  ", afmt.ANSI24{fg = afmt.RGB{104, 71, 52}}},
		percent  = {"%", afmt.ANSI24{fg = afmt.RGB{115, 113, 116}}},
		done     = {'.', afmt.ANSI24{fg = afmt.RGB{145, 97, 69}}},
		undone   = {'▲', afmt.ANSI24{fg = afmt.RGB{254, 181, 2}}},
		glyph    = glyph
	}
}

//	Pᗣᗧ•••MᗣN
//	Mulit_Bar - allocates using provided allocator
runebar_multi_pacman :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 2
	runes  :: 1

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	glyph[0][0] = {'ᗧ', afmt.ANSI24{fg = afmt.RGB{252, 209, 39}, at = {.BOLD}}} // At the Nom
	glyph[1][0] = {'𐰗', afmt.ANSI24{fg = afmt.RGB{252, 209, 39}, at = {.BOLD}}} // Chomp

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{252, 209, 39}}},
		lbracket = {" [",  afmt.ANSI24{fg = afmt.RGB{88, 88, 229}, at = {.BOLD}}},
		rbracket = {"] ",  afmt.ANSI24{fg = afmt.RGB{88, 88, 229}, at = {.BOLD}}},
		percent  = {" 🜼",   afmt.ANSI24{fg = afmt.RGB{255, 0, 0}}},
		done     = {'◦',   afmt.ANSI24{fg = afmt.RGB{252, 209, 39}, at = {.FAINT}}},
		undone   = {'𐄙',   afmt.ANSI24{fg = afmt.RGB{252, 209, 39}}},
		glyph    = glyph,
	}
}

//	Pᗣᗧ•••MᗣN
//	Mulit_Bar - allocates using provided allocator
runebar_multi_pacman_ghosts :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 2
	runes  :: 6

	ghosts := [runes]rune  {'ᗣ', 'ᗣ', 'ᗣ', 'ᗣ', ' ', ' '}
	pacman := [states]rune {'ᗧ', '𐰗'}
	format := [runes]afmt.ANSI24 {
		{fg = afmt.RGB{252, 209, 39}, at = {.BOLD}},  // Clyde
		{fg = afmt.RGB{120, 209, 242}, at = {.BOLD}}, // Inky
		{fg = afmt.RGB{254, 139, 148}, at = {.BOLD}}, // Pinky
		{fg = afmt.RGB{253, 107, 99}, at = {.BOLD}},  // Blinky
		{}, // no format for blank space
		{fg = afmt.RGB{252, 209, 39}, at = {.BOLD}},  // Pacman
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for s in 0..<states {
		for r in 0..<runes {
			if r == 5 {
				glyph[s][r] = { pacman[s], format[r] }
			} else {
				glyph[s][r] = { ghosts[r], format[r] }
			}
		}
	}
  
	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{252, 209, 39}}},
		lbracket = {" [",  afmt.ANSI24{fg = afmt.RGB{88, 88, 229}, at = {.BOLD}}},
		rbracket = {"] ",  afmt.ANSI24{fg = afmt.RGB{88, 88, 229}, at = {.BOLD}}},
		percent  = {" 🜼",   afmt.ANSI24{fg = afmt.RGB{255, 0, 0}}},
		done     = {'◦',   afmt.ANSI24{fg = afmt.RGB{252, 209, 39}, at = {.FAINT}}},
		undone   = {'𐄙',   afmt.ANSI24{fg = afmt.RGB{252, 209, 39}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_stars :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  :: 35

	stars := [runes]rune {
		'⋆', '⁺', '₊', 'ᯓ', '𖦹',
		'⋆', '.', '⁺', '₊', ' ',
		'⊹', '˚', '⁺', '.', '☾',
		' ', '˖', '.', '⁺', ' ',
		'⟡', '˚', ' ', '⋆', '｡',
		'°', '⁺', '.', '𖥔', ' ',
		'₊', '𖦹', '⁺', '.', '⁺'
	}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	glyph[0][0] = {' ', {}}

	return {
		width    = width,
		title    = {title, {}},
		lbracket = {" ", {}},
		rbracket = {" ", {}},
		percent  = {" ", {}},
		done     = {' ', {}},
		undone   = {'\u2601', {}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_trout :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 8
	runes  :: 18

	trout := [states][runes]rune {
		{'◦', '·', '·', '·', '·', '·', '·', '·', '·', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
		{'◦', '·', '·', '·', '·', '.', '.', '.', '.', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
		{'◦', '·', '´', '¯', '`', '.', '¸', '¸', '.', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
		{'◦', '·', '·', '·', '·', '.', '.', '.', '.', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
		{'◦', '·', '·', '·', '·', '·', '·', '·', '·', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
		{'◦', '.', '.', '.', '.', '·', '·', '·', '·', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
		{'◦', '.', '¸', '¸', '.', '·', '´', '¯', '`', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
		{'◦', '.', '.', '.', '.', '·', '·', '·', '·', '·', '>', '<', '(', '(', '(', '(', 'º', '>'},
	}

	format := [runes]afmt.ANSI24 {
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{033, 161, 207}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{033, 161, 207}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{033, 161, 207}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{255, 102, 102}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{227, 061, 121}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{070, 180, 021}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{255, 189, 085}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
		{fg = afmt.RGB{070, 180, 021}, bg = afmt.RGB{116, 204, 244}, at = {.BOLD}},
	}

	// 1x1 - 1 states with 1 Rune each state
	glyph := make_glyph_multi(states, runes, allocator = allocator)
	for s in 0..<states {
		for r in 0..<runes {
			glyph[s][r] = { trout[s][r], format[r] }
		}
	}

	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{0, 0, 0}, bg = afmt.RGB{116, 204, 244}}},
		lbracket = {" ", afmt.ANSI24{bg = afmt.RGB{116, 204, 244}}},
		rbracket = {" ", afmt.ANSI24{bg = afmt.RGB{116, 204, 244}}},
		percent  = {"%", afmt.ANSI24{fg = afmt.RGB{0, 0, 0}, bg = afmt.RGB{116, 204, 244}}},
		done     = {'·', afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{116, 204, 244}}},
		undone   = {' ', afmt.ANSI24{bg = afmt.RGB{116, 204, 244}}},
		glyph    = glyph
	}
}

//	Mulit_Bar - allocates using provided allocator
runebar_multi_queens_march :: proc(title: string, width := uint(25), allocator := context.allocator) -> (pb: Progress_Bar) {
	states :: 1
	runes  := int(width)

	queen  := rune ('♕')
	pawn   := rune ('♙')
	format := afmt.ANSI24 {fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{0,0,0}}

	glyph := make_glyph_multi(states, runes, allocator = allocator)
	glyph[0][runes-1] = {' ', format}
	glyph[0][runes-2] = {queen, format}
	glyph[0][runes-3] = {' ', format}
	for r in 0..<runes-3 {
		glyph[0][r] = {pawn, format}
	}
	
	return {
		width    = width,
		title    = {title, afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{0,0,0}}},
		lbracket = {" ♔ ♖ ", afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{0,0,0}}},
		rbracket = {" ♜ ♚ ", afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{0,0,0}}},
		percent  = {"🩋 ", afmt.ANSI24{fg = afmt.RGB{250, 250, 250}, bg = afmt.RGB{0,0,0}}},
		done     = {'♙', afmt.ANSI24{fg = afmt.RGB{100, 100, 100}, bg = afmt.RGB{0,0,0}}},
		undone   = {'♙', afmt.ANSI24{fg = afmt.RGB{100, 100, 100}, bg = afmt.RGB{0,0,0}}},
		glyph    = glyph
	}
}
