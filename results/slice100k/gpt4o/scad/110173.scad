module frame_panel() {
    difference() {
        cube([95, 95, 9], center=true);
        translate([-42.5, -42.5, -4.5])
            cube([85, 85, 9], center=false);
    }
}

frame_panel();