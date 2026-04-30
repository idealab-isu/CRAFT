$fn=64;

plate_size = 50;
plate_thickness = 3;

fan_size = 40;
fan_hole_spacing = 32;      // typical 40mm fan
corner_hole_d = 4.3;        // clearance for M4 (adjust as needed)

center_cutout_d = 38;       // airflow opening

difference() {
    // Mount plate
    cube([plate_size, plate_size, plate_thickness], center=true);

    // Center airflow cutout
    cylinder(h=plate_thickness + 2, d=center_cutout_d, center=true);

    // 4 corner mounting holes (fan pattern)
    for (x = [-fan_hole_spacing/2, fan_hole_spacing/2])
    for (y = [-fan_hole_spacing/2, fan_hole_spacing/2])
        translate([x, y, 0])
            cylinder(h=plate_thickness + 2, d=corner_hole_d, center=true);
}