// 40mm Fan Mount Plate
fan_size = 40;
hole_spacing = 32;  // Standard 40mm fan hole spacing
plate_thickness = 3;
mount_hole_d = 3.2;  // M3 clearance

difference() {
    // Base plate
    translate([0, 0, plate_thickness/2])
        cube([fan_size + 6, fan_size + 6, plate_thickness], center=true);

    // Center airflow hole
    cylinder(d=fan_size - 4, h=plate_thickness + 1, center=true, $fn=64);

    // Mounting holes (4 corners)
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * hole_spacing/2, y * hole_spacing/2, 0])
                cylinder(d=mount_hole_d, h=plate_thickness + 1, center=true, $fn=32);
        }
    }
}
