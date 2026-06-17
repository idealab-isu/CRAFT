$fn=128;

module tape_roll(outer_d=100, inner_d=76, width=25) {
    difference() {
        cylinder(d=outer_d, h=width, center=true);
        cylinder(d=inner_d, h=width+2, center=true);
    }
}

module tape_sheet(length=120, width=25, thickness=0.06) {
    translate([0,0,0])
        cube([length, width, thickness], center=true);
}

module sellotape_tape() {
    union() {
        color([0.95,0.95,0.98,0.25]) tape_roll(outer_d=100, inner_d=76, width=25);
        translate([80,0,12.5-0.03])
            color([0.95,0.95,0.98,0.25]) tape_sheet(length=140, width=25, thickness=0.06);
    }
}

sellotape_tape();