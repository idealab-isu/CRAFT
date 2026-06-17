$fn = 128;

// HT 75 pipe 500 mm (approx. DN75)
// Typical HT pipe outer diameter ~75 mm, wall thickness ~1.8 mm
// Model: hollow cylinder (pipe)

od = 75;        // outer diameter (mm)
wall = 1.8;     // wall thickness (mm)
id = od - 2*wall;
len = 500;      // length (mm)

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.1])
            cylinder(h=len+0.2, d=id, center=false);
    }
}

ht_pipe(od, id, len);