module rounded_rectangle() {
    difference() {
        cube([0.1, 0.1, 0.1], center=true);
        for (x = [-0.05, 0.05])
            for (y = [-0.05, 0.05])
                for (z = [-0.05, 0.05])
                    translate([x, y, z])
                        sphere(r=0.02, $fn=64);
    }
}

rounded_rectangle();