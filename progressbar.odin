package progressbar

import "core:fmt"
import "core:time"
import "base:intrinsics"
import win32 "core:sys/windows"

import "shared:afmt"

//	set_utf8_terminal based on OS
when ODIN_OS == .Windows {
	_set_utf8_terminal :: proc() {
		win32.SetConsoleOutputCP(.UTF8)
		win32.SetConsoleCP(.UTF8)
	}
} else {
	_set_utf8_terminal :: proc() {}
}

//	Specific Progress Bar types
String :: struct { data: string, format: afmt.ANSI }
Rune   :: struct { data: rune,   format: afmt.ANSI }
Glyph  :: union  { Rune, [][]Rune }

//	Progress Bar struct
Progress_Bar :: struct {
	width:    uint,
	title:    String,
	lbracket: String,
	rbracket: String,
	percent:  String,
	done:     Rune,
	undone:   Rune,
	glyph:    Glyph,
	state:    uint
}

//	Helper proc to make [][]Rune Glyph variant
make_glyph_multi :: proc(states, runes: int, allocator := context.allocator) -> (glyph: [][]Rune) {
	glyph = make([][]Rune, states, allocator)
	for s in 0..<states {
		glyph[s] = make([]Rune, runes, allocator)
	}
	return
}

//	Delete Progress_Bar if it is of the multi type
//	Will ignore progress bars that do not allocate, so safe to use on all of them
delete_progress_bar :: proc(bar_format: ^Progress_Bar) {
	#partial switch glyph in bar_format.glyph {
	case [][]Rune:
		for g in glyph { delete(g) }
		delete(glyph)
	}
}

//	Cursor show/hide/return
cursor_hide    :: proc(flush := true) { fmt.print("\e[?25l", flush=flush) }
cursor_show    :: proc(flush := true) { fmt.print("\e[?25h", flush=flush) }
cursor_return  :: proc(flush := true) { fmt.print("\r",      flush=flush) }
set_utf8_terminal :: proc() { _set_utf8_terminal() }

//	Use after a loop ends in case progress did not finish
progress_bar_exit :: proc() { fmt.println(flush = true); cursor_show(flush = true) }

//	Draw Progress_Bar
progress_bar :: proc(pb: ^Progress_Bar, percent: $T) where intrinsics.type_is_numeric(T) {
 
	upercent := int(abs(percent))
	width    := int(pb.width)
	done     := upercent * width / 100
	undone   := width - done
	
	//	Extract glyph slice from Progress_Bar
	glyph: []Rune
	switch g in pb.glyph {
	case Rune:
		glyph = { g }
	case [][]Rune:
		if done != 0 && (done - int(pb.state)) % 2 == 0 {
			pb.state = pb.state < len(g) - 1 ? pb.state + 1 : 0
		}
		glyph = g[pb.state][:]
	}

	//	Make room for glyph
	if upercent <= 100 {
		if len(glyph) >= done {	glyph = glyph[len(glyph)-done:] }
		done -= len(glyph)
	} else { // for animating finish
		right_index := len(glyph) - upercent + 100
		// Check if glyph is larger than bar width
		// Some bars may stylistically choose to have longer glyphs than bar width
		if len(glyph) > width {
			left_index  := len(glyph) - upercent + 100 - width
			left_index   = left_index < 0 ? 0 : left_index
			glyph = glyph[left_index:right_index]
		} else {
			glyph  = glyph[:right_index]
		}
		undone = 0
		done   = width - len(glyph)
  }

	//	Print progress bar
	cursor_return(flush = false)
	cursor_hide(flush = false)
	afmt.printf("%v", pb.title.format, pb.title.data, flush=false)
	afmt.printf("%v", pb.lbracket.format, pb.lbracket.data, flush=false)
	for _ in 0..<done { afmt.printf("%v", pb.done.format, pb.done.data, flush=false) }
	for g in glyph { afmt.printf("%r", g.format, g.data, flush=false) }
	for _ in 0..<undone { afmt.printf("%v", pb.undone.format, pb.undone.data, flush=false) }
	afmt.printf("%s", pb.rbracket.format, pb.rbracket.data, flush=false)
	if intrinsics.type_is_float(T) {
		afmt.printf("%6.2f%s", pb.percent.format, percent > 100 ? 100 : percent, pb.percent.data, flush=false)
	} else {
		afmt.printf("%3i%s", pb.percent.format, percent > 100 ? 100 : percent, pb.percent.data, flush=false)
	}

	//	Finish - animating glyph outro as needed
	if upercent >= 100 {
		if len(glyph) != 0 {
			// speed = 1 second / 2^n starting at 2^3 where n increments every 1/4 ratio of len(glyph):width
			// then mulitpled by every factor of width over 50 to increase speed for long bars
			out_speed: time.Duration
			switch f32(len(glyph)) / f32(width) {
			case 0.000..<0.250: out_speed = 8  * time.Duration(width) / 50
			case 0.250..<0.500: out_speed = 16 * time.Duration(width) / 50
			case 0.500..<0.750: out_speed = 32 * time.Duration(width) / 50
			case /* 0.750+ */ : out_speed = 64 * time.Duration(width) / 50
			}
			time.sleep(time.Second / out_speed)
			progress_bar(pb, percent + 1)
		}
	}
}
