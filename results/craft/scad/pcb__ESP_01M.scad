// Printed circuit board: 18.0mm x 18.0mm x 0.8mm
// Single connected solid (plain PCB slab)

length = 18.0;     // mm
width  = 18.0;     // mm
thickness = 0.8;   // mm

$fn = 64;

module pcb_board(l=length, w=width, t=thickness) {
    // Centered for unambiguous dimensions in all views
    color([0.0, 0.4, 0.2])
        cube([l, w, t], center=true);
}

pcb_board();