$fn = 128;

// PVC aquarium tubing (hollow flexible tube)
inner_d = 6;          // mm
wall_thickness = 1.5; // mm
outer_d = inner_d + 2*wall_thickness;

length = 200;         // mm

module tubing(len=200, od=9, id=6) {
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=id, center=false);
    }
}

tubing(length, outer_d, inner_d);