module sellotape_tape() {
    difference() {
        cylinder(h=20, r=25, $fn=64);
        translate([0, 0, -1])
            cylinder(h=22, r=20, $fn=64);
    }
}

sellotape_tape();