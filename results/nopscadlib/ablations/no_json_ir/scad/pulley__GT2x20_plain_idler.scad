// Parameters
pulley_diameter = 50;
pulley_width = 20;
bore_diameter = 10;
hub_diameter = 15;
hub_length = 25;
flange_thickness = 2;
flange_diameter = pulley_diameter + 10;
set_screw_diameter = 2;
set_screw_distance = 5;
tooth_depth = 2;
tooth_count = 20;

// Main pulley module
module pulley() {
    pulley_body();
    outer_rim();
    center_bore();
    hub();
    flanges();
    set_screw_holes();
}

// Pulley body
module pulley_body() {
    difference() {
        cylinder(d=pulley_diameter, h=pulley_width, center=true);
        if (tooth_depth > 0) {
            tooth_profile();
        }
    }
}

// Outer rim with optional teeth
module outer_rim() {
    if (tooth_depth > 0) {
        tooth_profile();
    } else {
        cylinder(d=pulley_diameter, h=pulley_width, center=true);
    }
}

// Center bore
module center_bore() {
    cylinder(d=bore_diameter, h=pulley_width + 2 * flange_thickness, center=true);
}

// Hub
module hub() {
    translate([0, 0, -hub_length / 2])
        cylinder(d=hub_diameter, h=hub_length, center=true);
}

// Flanges
module flanges() {
    translate([0, 0, pulley_width / 2])
        cylinder(d=flange_diameter, h=flange_thickness, center=true);
    translate([0, 0, -pulley_width / 2 - flange_thickness])
        cylinder(d=flange_diameter, h=flange_thickness, center=true);
}

// Set screw holes
module set_screw_holes() {
    for (angle = [0, 180]) {
        rotate([0, 0, angle])
            translate([hub_diameter / 2 + set_screw_distance, 0, 0])
                rotate([90, 0, 0])
                    cylinder(d=set_screw_diameter, h=hub_length, center=true);
    }
}

// Tooth profile
module tooth_profile() {
    for (i = [0:tooth_count - 1]) {
        rotate([0, 0, i * 360 / tooth_count])
            translate([pulley_diameter / 2, 0, 0])
                cube([tooth_depth, pulley_width, tooth_depth], center=true);
    }
}

// Render the pulley
pulley();