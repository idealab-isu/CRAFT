module protrusion() {
    union() {
        translate([0, 0, 0.005])
            scale([0.005, 0.005, 0.005])
                rotate([0, 45, 0])
                    cylinder(h=0.01, r1=0, r2=1, $fn=4);
        translate([0, 0, 0.01])
            sphere(r=0.0025, $fn=16);
    }
}

module face_protrusions() {
    union() {
        for (x = [-0.045, 0.045])
            for (y = [-0.045, 0.045])
                translate([x, y, 0])
                    protrusion();
        translate([0, 0, 0])
            protrusion();
    }
}

module studded_cube() {
    difference() {
        cube([0.1, 0.1, 0.1], center=true);
        for (z = [-0.05, 0.05])
            translate([0, 0, z])
                face_protrusions();
        for (x = [-0.05, 0.05])
            rotate([0, 90, 0])
                translate([0, 0, x])
                    face_protrusions();
        for (y = [-0.05, 0.05])
            rotate([90, 0, 0])
                translate([0, 0, y])
                    face_protrusions();
    }
}

studded_cube();