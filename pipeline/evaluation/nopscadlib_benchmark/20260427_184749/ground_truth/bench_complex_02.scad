// 5mm to 8mm Shaft Coupling
// Connects NEMA 17 (5mm) to 8mm leadscrew
shaft_5mm = 5;
shaft_8mm = 8;
coupling_od = 20;
coupling_length = 25;
set_screw_d = 3;

difference() {
    // Main body
    cylinder(d=coupling_od, h=coupling_length, center=true, $fn=64);

    // 5mm shaft bore (NEMA 17 side)
    translate([0, 0, -coupling_length/4])
        cylinder(d=shaft_5mm, h=coupling_length/2 + 1, center=true, $fn=64);

    // 8mm shaft bore (leadscrew side)
    translate([0, 0, coupling_length/4])
        cylinder(d=shaft_8mm, h=coupling_length/2 + 1, center=true, $fn=64);

    // Flexible coupling spiral cut
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
            translate([0, 0, -coupling_length/3 + i * coupling_length/6])
                rotate([0, 90, 0])
                    cylinder(d=2, h=coupling_od, center=true, $fn=32);
    }

    // Set screw for 5mm shaft
    translate([0, 0, -coupling_length/4])
        rotate([90, 0, 0])
            cylinder(d=set_screw_d, h=coupling_od, center=true, $fn=32);

    // Set screw for 8mm shaft
    translate([0, 0, coupling_length/4])
        rotate([90, 0, 90])
            cylinder(d=set_screw_d, h=coupling_od, center=true, $fn=32);
}
