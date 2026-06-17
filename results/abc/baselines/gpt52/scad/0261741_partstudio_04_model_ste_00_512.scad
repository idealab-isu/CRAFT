$fn=64;

plate_w = 0.3;
plate_h = 0.3;
plate_t = 0.02;

tab_top_w = 0.10;
tab_top_d = 0.03;

tab_bottom_w = 0.10;
tab_bottom_d = 0.03;

tab_side_h = 0.10;
tab_side_d = 0.03;

module base_plate() {
    cube([plate_w, plate_h, plate_t], center=true);
}

module top_tab() {
    translate([0, plate_h/2 + tab_top_d/2, 0])
        cube([tab_top_w, tab_top_d, plate_t], center=true);
}

module bottom_tab() {
    translate([0, -(plate_h/2 + tab_bottom_d/2), 0])
        cube([tab_bottom_w, tab_bottom_d, plate_t], center=true);
}

module right_side_tab() {
    translate([plate_w/2 + tab_side_d/2, 0, 0])
        cube([tab_side_d, tab_side_h, plate_t], center=true);
}

module left_side_tab() {
    translate([-(plate_w/2 + tab_side_d/2), 0, 0])
        cube([tab_side_d, tab_side_h, plate_t], center=true);
}

union() {
    base_plate();
    top_tab();
    bottom_tab();
    right_side_tab();
    left_side_tab();
}