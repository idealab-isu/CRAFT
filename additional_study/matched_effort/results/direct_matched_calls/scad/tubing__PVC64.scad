$fn = 128;

// PVC aquarium tubing (hollow flexible tube)
inner_d = 6;      // mm
outer_d = 10;     // mm
length  = 200;    // mm

module tubing(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5])
            cylinder(d=id, h=h+1, center=false);
    }
}

color([0.85, 0.9, 0.95, 0.35]) tubing(outer_d, inner_d, length);