module u_shaped_rod() {
    rod_thickness = 2;
    rod_length = 40;
    rod_height = 20;
    boss_diameter = 6;
    boss_height = 5;
    hex_size = 3;
    hex_depth = 3;
    $fn = 64;

    // U-shaped rod
    difference() {
        union() {
            translate([-rod_length/2, 0, 0])
                cube([rod_length, rod_thickness, rod_thickness]);
            translate([-rod_length/2, 0, rod_height - rod_thickness])
                cube([rod_length, rod_thickness, rod_thickness]);
            translate([-rod_length/2, 0, rod_thickness])
                cube([rod_thickness, rod_thickness, rod_height - 2 * rod_thickness]);
            translate([rod_length/2 - rod_thickness, 0, rod_thickness])
                cube([rod_thickness, rod_thickness, rod_height - 2 * rod_thickness]);
        }
    }

    // End bosses with hex sockets
    for (i = [-1, 1]) {
        translate([i * (rod_length/2 + boss_height/2), 0, rod_height/2])
            rotate([90, 0, 0])
                difference() {
                    cylinder(h = boss_height, d = boss_diameter, $fn = $fn);
                    translate([0, 0, boss_height/2 - hex_depth/2])
                        rotate([0, 0, 0])
                            hex_socket(hex_size, hex_depth);
                }
    }
}

module hex_socket(size, depth) {
    rotate([0, 0, 30])
        linear_extrude(height = depth)
            polygon(points = [
                [size * cos(0), size * sin(0)],
                [size * cos(60), size * sin(60)],
                [size * cos(120), size * sin(120)],
                [size * cos(180), size * sin(180)],
                [size * cos(240), size * sin(240)],
                [size * cos(300), size * sin(300)]
            ]);
}

u_shaped_rod();