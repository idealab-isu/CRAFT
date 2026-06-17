$fn = 96;

// Dimensions (mm)
shaft_d = 2.0;
length = 10.0;

head_d = 3.8;
head_h = 2.0;

socket_d = 1.5;
socket_depth = 1.2;

chamfer_h = 0.25;

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(d = shaft_d, h = length);

            // Head
            translate([0, 0, length])
                cylinder(d = head_d, h = head_h);

            // Small top chamfer on head
            translate([0, 0, length + head_h - chamfer_h])
                cylinder(d1 = head_d, d2 = head_d - 2*chamfer_h, h = chamfer_h);
        }

        // Hex socket (approximated as 6-sided prism)
        translate([0, 0, length + head_h - socket_depth])
            cylinder(d = socket_d, h = socket_depth + 0.02, $fn = 6);
    }
}

socket_head_cap_screw();