module chamfered_plate(length, width, thickness, chamfer, hole_positions) {
    difference() {
        hull() {
            translate([-length/2 + chamfer, -width/2, 0])
                square([length - 2*chamfer, width], center=false);
            translate([-length/2, -width/2 + chamfer, 0])
                square([length, width - 2*chamfer], center=false);
        }
        for (pos = hole_positions) {
            translate([pos[0], pos[1], 0])
                rotate(45) square([2, 2], center=true);
        }
    }
}

module notched_strip(length, width, thickness, notch_width, notch_depth, notch_spacing) {
    difference() {
        translate([-length/2, -width/2, 0])
            cube([length, width, thickness], center=false);
        for (i = [0 : floor(length / notch_spacing) - 1]) {
            translate([-length/2 + i * notch_spacing, -width/2, 0])
                cube([notch_width, notch_depth, thickness], center=false);
        }
    }
}

module i_beam(length, width, height, flange_width, web_thickness) {
    union() {
        translate([-length/2, -flange_width/2, 0])
            cube([length, flange_width, height], center=false);
        translate([-length/2, -web_thickness/2, height/2 - web_thickness/2])
            cube([length, web_thickness, height - web_thickness], center=false);
    }
}

module assembly() {
    chamfered_plate(0.18, 0.02, 0.002, 0.005, [[-0.06, 0], [0, 0], [0.06, 0]]);
    translate([0, 0.03, 0])
        chamfered_plate(0.18, 0.02, 0.002, 0.005, [[-0.06, 0], [0, 0], [0.06, 0]]);
    translate([0, -0.03, 0])
        notched_strip(0.18, 0.02, 0.002, 0.005, 0.01, 0.02);
    translate([0, -0.06, 0])
        notched_strip(0.18, 0.02, 0.002, 0.005, 0.01, 0.02);
    translate([0, 0.06, 0])
        i_beam(0.02, 0.01, 0.002, 0.01, 0.002);
}

assembly();