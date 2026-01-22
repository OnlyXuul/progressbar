Fancy Progress Bar

Created mostly for geeky funs.

Depends on afmt package

See test/test.odin for example tests

Basic Usage Simulation Example:<br>
bar := pb.create_bar(.pacman_ghosts, "Bar Test:", 50)<br>
defer pb.delete_progress_bar(&bar)<br>

//	Simulate some process that loops and takes time and provides updates<br>
for percent in 0..=100 {<br>
pb.progress_bar(&bar, percent)<br>
time.sleep(time.Second / 25) // Simulation. Remove this when using for real.<br>
// test some condition that breaks loop<br>
}<br>
pb.progress_bar_exit() // Always use this when done just in case you are breaking out of progress loop<br>

I'm not a particularly good artist. Some of these could have used better color choices. They mostly serve as examples of what is possible if you wish to geek out and attempt to create your own.<br>

Basic Bars that do not allocate (the rest do)<br>
![Alt text](/screenshots/basic_bars.jpg?raw=true)

Arrow<br>
![Alt text](/screenshots/arrow.jpg?raw=true)

Ball<br>
![Alt text](/screenshots/ball.jpg?raw=true)

Random Bits<br>
![Alt text](/screenshots/bits.jpg?raw=true)

Random Bits with Random Color<br>
![Alt text](/screenshots/bits_color.jpg?raw=true)

Black Flag<br>
![Alt text](/screenshots/blackflag.jpg?raw=true)

Chain<br>
![Alt text](/screenshots/chain.jpg?raw=true)

Deathstar shoots Alderaan and it's moon(s)<br>
![Alt text](/screenshots/deathstar.jpg?raw=true)

Dracula<br>
![Alt text](/screenshots/dracula.jpg?raw=true)

Kayak<br>
![Alt text](/screenshots/kayak.jpg?raw=true)

Love<br>
![Alt text](/screenshots/love.jpg?raw=true)

Mjölnir<br>
![Alt text](/screenshots/mjölnir.jpg?raw=true)

Mouse<br>
![Alt text](/screenshots/mouse.jpg?raw=true)

Pacman<br>
![Alt text](/screenshots/pacman.jpg?raw=true)

Pacman with Ghosts<br>
![Alt text](/screenshots/pacman_ghosts.jpg?raw=true)

Queens March<br>
![Alt text](/screenshots/queens_march.jpg?raw=true)

Trout<br>
![Alt text](/screenshots/trout.jpg?raw=true)
