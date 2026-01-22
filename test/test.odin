package test

import "core:time"
import "base:intrinsics"

import pb "../../progressbar"

@(private="file")
test_bar :: proc($T: typeid, bar: ^pb.Progress_Bar, delay: time.Duration, break_loop := false) where intrinsics.type_is_numeric(T) {
	if intrinsics.type_is_integer(T) {
		for percent in 0..=100 {
			pb.progress_bar(bar, percent)
			time.sleep(delay)
			// test some condition that breaks loop and progress bar updates
			if break_loop && percent >= 53 {
				break
			}
		}
		pb.progress_bar_exit()
	}
	if intrinsics.type_is_float(T) {
		for percent := 0.000; /* percent <= 100.000 */; percent += 0.666 {
			// check that percent is greater than 100, then set to 100 and break
			if percent > 100.00 { pb.progress_bar(bar, 100.000); break }
			pb.progress_bar(bar, percent)
			time.sleep(delay)
			// test some condition that breaks loop and progress bar updates
			if break_loop && percent >= 53 {
				break
			}
		}
		pb.progress_bar_exit()
	}
}

main :: proc() {

	pb.set_utf8_terminal()

//	Normal usage example
{
	bar := pb.create_bar(.pacman_ghosts, "Bar Test:", 50)
	defer pb.delete_progress_bar(&bar)

	//	Simulate some process that loops and takes time and provides updates
	for percent in 0..=100 {
		pb.progress_bar(&bar, percent)
		time.sleep(time.Second / 25) // Simulation. Remove this when using for real.
		// test some condition that breaks loop here
	}
	pb.progress_bar_exit() // Always use this when done just in case you are breaking out of progress loop
}

//	Test Random Bar
{
	//bar := pb.create_random_bar("Bar Test:", 50)
	//defer pb.delete_progress_bar(&bar)

	//	Test int counter
	//test_bar(int, &bar, time.Second / 20)
	//test_bar(int, &bar, time.Second / 20, break_loop = true)

	//	Test float counter
	//test_bar(f32, &bar, time.Second / 20)
	//test_bar(f32, &bar, time.Second / 20, break_loop = true)
}

//	Test specified bar
{
	//bar := pb.create_bar(.pacman_ghosts, "Bar Test:", 50)
	//defer pb.delete_progress_bar(&bar)

	//	Test int counter with created bar from above
	//test_bar(int, &bar, time.Second / 20)
	//test_bar(int, &bar, time.Second / 20, break_loop = true)

	//	Test float counter with created bar from above
	//test_bar(f32, &bar, time.Second / 20)
	//test_bar(f32, &bar, time.Second / 20, break_loop = true)
}

//	Test all Basic_Bar(s)
{
	//bar: pb.Progress_Bar
	//for id in pb.Basic_Bar {
	//	bar = pb.Basic_Bar_Create[id]("Test", 40)
	//	test_bar(int, &bar, time.Second / 50)
	//}
}

	//	Test all Multi_Bar(s)
{
	//bar: pb.Progress_Bar
	//for id in pb.Multi_Bar {
	//	bar = pb.Multi_Bar_Create[id]("Test", 40)
	//	defer pb.delete_progress_bar(&bar)
	//	test_bar(int, &bar, time.Second / 50)
	//}
}

}
