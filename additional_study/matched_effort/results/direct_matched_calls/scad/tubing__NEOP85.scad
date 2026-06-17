$fn = 128;

// Neoprene tubing (generic): hollow cylinder
// Units: mm

inner_d = 8;      // inner diameter
outer_d = 12;     // outer diameter
length  = 120;    // tube length

module neoprene_tube(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5])
            cylinder(d=id, h=h+1, center=false);
    }
}

neoprene_tube(outer_d, inner_d, length);