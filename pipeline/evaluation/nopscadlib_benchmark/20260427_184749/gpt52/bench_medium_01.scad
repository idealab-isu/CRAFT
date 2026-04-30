$fn=64;

plate_size = 42;
plate_thickness = 4;

hole_pattern = 31;          // center-to-center
mount_hole_d = 3.4;         // clearance for M3
center_bore_d = 22;

difference() {
    cube([plate_size, plate_size, plate_thickness], center=true);

    // Center bore
    cylinder(h=plate_thickness + 2, d=center_bore_d, center=true);

    // Four mounting holes (31mm square pattern)
    for (x = [-hole_pattern/2, hole_pattern/2])
        for (y = [-hole_pattern/2, hole_pattern/2])
            translate([x, y, 0])
                cylinder(h=plate_thickness + 2, d=mount_hole_d, center=true);
}