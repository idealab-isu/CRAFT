// Aluminium rectangular box section (RHS)
// Outer: 38.1mm x 25.4mm, wall: 1.6mm
// Length is parameterized.

outer_w = 38.1;   // mm
outer_h = 25.4;   // mm
wall    = 1.6;    // mm
length  = 100;    // mm (change as needed)

inner_w = outer_w - 2*wall;
inner_h = outer_h - 2*wall;

$fn = 64;

module box_section(len=length, ow=outer_w, oh=outer_h, t=wall) {
    iw = ow - 2*t;
    ih = oh - 2*t;
    if (iw <= 0 || ih <= 0) {
        echo("ERROR: Wall thickness too large for given outer dimensions.");
    } else {
        difference() {
            // Outer tube
            translate([-ow/2, -oh/2, 0])
                cube([ow, oh, len], center=false);

            // Inner void
            translate([-iw/2, -ih/2, -0.01])
                cube([iw, ih, len + 0.02], center=false);
        }
    }
}

box_section();