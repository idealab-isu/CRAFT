// Self-contained magnet (no external libraries) to avoid blank renders.
// One connected solid: a rectangular base with a cylindrical magnet bonded on top.

$fn = 96;

base_x = 40;
base_y = 20;
base_h = 6;

mag_r  = 7.5;
mag_h  = 3;

overlap = 0.6; // ensures watertight union

module magnet_component() {
    union() {
        // Base block
        cube([base_x, base_y, base_h], center=true);

        // Cylindrical magnet on top, positioned by dimensions (not arbitrary)
        translate([0, 0, base_h/2 + mag_h/2 - overlap])
            cylinder(r=mag_r, h=mag_h, center=true);
    }
}

magnet_component();