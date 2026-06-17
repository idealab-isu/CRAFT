$fn = 128;

// HT 40 pipe (approx.): OD 40 mm, wall 1.8 mm, length 1500 mm
od = 40;
wall = 1.8;
id = od - 2*wall;
len = 1500;

module pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
    }
}

pipe(od, id, len);