$fn = 180;

// HT pipe (approximation)
// "HT 160" interpreted as nominal OD 160 mm
// "150 mm" interpreted as pipe length

od = 160;          // outer diameter (mm)
wall = 4.7;        // typical HT wall thickness (mm), adjustable
len = 150;         // length (mm)

id = od - 2*wall;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
    }
}

ht_pipe(od, id, len);