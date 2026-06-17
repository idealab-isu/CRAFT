$fn=64;

Lx = 0.1;
Ly = 0.1;
Lz = 0.1;

step_x = 0.03;
step_y = 0.04;

notch_depth = 0.02;
notch_width = 0.05;
notch_height = 0.06;
notch_side_thickness = 0.015;

module l_block() {
    union() {
        translate([0, 0, 0]) cube([Lx, Ly, Lz], center=false);
        translate([Lx - step_x, Ly - step_y, 0]) cube([step_x, step_y, Lz], center=false);
    }
}

module u_notch_at_x(xpos) {
    translate([xpos, (Ly - notch_width)/2, (Lz - notch_height)/2])
        cube([notch_depth, notch_width, notch_height], center=false);

    translate([xpos, (Ly - notch_width)/2, (Lz - notch_height)/2])
        cube([notch_depth, notch_side_thickness, notch_height], center=false);

    translate([xpos, (Ly + notch_width)/2 - notch_side_thickness, (Lz - notch_height)/2])
        cube([notch_depth, notch_side_thickness, notch_height], center=false);
}

module u_notch_cut(xpos) {
    union() {
        translate([xpos, (Ly - notch_width)/2 + notch_side_thickness, (Lz - notch_height)/2])
            cube([notch_depth, notch_width - 2*notch_side_thickness, notch_height], center=false);
    }
}

module part() {
    difference() {
        l_block();
        u_notch_cut(0);
        u_notch_cut(Lx - notch_depth);
    }
}

translate([-Lx/2, -Ly/2, -Lz/2]) part();