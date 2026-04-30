// 608 Bearing Housing with Flanges
// 608ZZ: OD=22mm, ID=8mm, H=7mm
bearing_od = 22;
bearing_id = 8;
bearing_h = 7;
wall = 3;
flange_width = 12;

difference() {
    union() {
        // Main housing
        cylinder(d=bearing_od + wall*2, h=bearing_h + 2, center=true, $fn=64);

        // Mounting flanges
        for (a = [0, 180]) {
            rotate([0, 0, a])
                translate([bearing_od/2 + flange_width/2, 0, 0])
                    cube([flange_width, 15, bearing_h + 2], center=true);
        }
    }

    // Bearing pocket (press fit)
    cylinder(d=bearing_od - 0.1, h=bearing_h, center=true, $fn=64);

    // Through hole
    cylinder(d=bearing_id, h=bearing_h + 10, center=true, $fn=64);

    // Flange mounting holes
    for (a = [0, 180]) {
        rotate([0, 0, a])
            translate([bearing_od/2 + flange_width/2, 0, 0])
                cylinder(d=4.2, h=bearing_h + 10, center=true, $fn=32);
    }
}
