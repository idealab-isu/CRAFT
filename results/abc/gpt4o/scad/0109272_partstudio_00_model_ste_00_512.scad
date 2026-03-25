module rounded_plate() {
    difference() {
        union() {
            // Main plate with rounded corners
            offset(r=2) {
                square([100, 50], center=true);
            }
            // Side notch
            translate([45, 0, 0])
                cube([10, 20, 1], center=true);
        }
        // Corner holes
        for (x = [-45, 45])
            for (y = [-20, 20])
                translate([x, y, 0])
                    cylinder(h=2, r=2, center=true, $fn=64);
    }
}

module text_on_plate() {
    linear_extrude(height=1, center=true) {
        text("Sleepy Pi 2", size=10, halign="center", valign="center");
    }
}

module mirrored_text() {
    union() {
        translate([0, 0, 0.5])
            text_on_plate();
        translate([0, 0, -0.5])
            mirror([0, 1, 0])
                text_on_plate();
    }
}

translate([0, 0, -0.5])
    union() {
        rounded_plate();
        mirrored_text();
    }