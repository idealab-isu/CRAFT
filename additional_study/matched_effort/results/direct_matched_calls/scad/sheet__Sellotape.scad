$fn=96;

// Sellotape-like tape roll (ring) with slight translucency
module tape_roll(
    outer_d=110,
    inner_d=76,
    width=18,
    chamfer=0.8
){
    color([1.0, 0.95, 0.65, 0.35])  // pale amber, translucent
    difference() {
        // Outer body with subtle edge chamfers
        minkowski() {
            cylinder(d=outer_d-2*chamfer, h=width-2*chamfer, center=true);
            sphere(r=chamfer);
        }
        // Inner hole
        cylinder(d=inner_d, h=width+4, center=true);
    }
}

// Cardboard core (optional, typical Sellotape roll)
module core(
    inner_d=76,
    core_thickness=2.2,
    width=18
){
    color([0.85, 0.78, 0.65, 1.0])
    difference() {
        cylinder(d=inner_d, h=width, center=true);
        cylinder(d=inner_d-2*core_thickness, h=width+2, center=true);
    }
}

// Slightly lifted "free end" tab of tape
module tape_tab(
    outer_d=110,
    width=18,
    tab_len=28,
    tab_thickness=0.18,
    lift=6,
    angle=22
){
    // Place at outer rim
    r = outer_d/2 + tab_len/2 - 2;
    rotate([0,0,angle])
    translate([r,0,0])
    rotate([0,90,0])
    translate([0,0,width/2 - 2])
    color([1.0, 0.95, 0.65, 0.25])
    hull() {
        translate([0,0,0])
            cube([tab_len, tab_thickness, 10], center=true);
        translate([0,lift,0])
            cube([tab_len*0.85, tab_thickness, 8], center=true);
    }
}

module sellotape_tape(){
    outer_d = 110;
    inner_d = 76;
    width   = 18;

    tape_roll(outer_d=outer_d, inner_d=inner_d, width=width, chamfer=0.9);
    core(inner_d=inner_d, core_thickness=2.2, width=width);
    tape_tab(outer_d=outer_d, width=width, tab_len=30, tab_thickness=0.2, lift=7, angle=28);
}

sellotape_tape();