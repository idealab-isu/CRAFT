// Parameters
pulley_diameter = 60;
pulley_width = 20;
bore_diameter = 10;
hub_diameter = 30;
hub_length = 25;
flange_thickness = 2;
flange_diameter = pulley_diameter + 10;
tooth_height = 2;
tooth_count = 20;
set_screw_diameter = 3;
set_screw_distance = 5;
keyway_width = 4;
keyway_depth = 2;
lightening_hole_diameter = 5;
lightening_hole_count = 6;

// Main pulley body
module pulley_body() {
    cylinder(d=pulley_diameter, h=pulley_width, center=true);
}

// Belt profile (toothed)
module belt_profile() {
    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i * 360 / tooth_count])
        translate([pulley_diameter/2, 0, 0])
        cube([tooth_height, pulley_width, tooth_height], center=true);
    }
}

// Center bore
module center_bore() {
    cylinder(d=bore_diameter, h=pulley_width + 2*flange_thickness, center=true);
}

// Hub
module hub() {
    translate([0, 0, -hub_length/2])
    cylinder(d=hub_diameter, h=hub_length, center=false);
}

// Flanges
module flanges() {
    translate([0, 0, pulley_width/2])
    cylinder(d=flange_diameter, h=flange_thickness, center=false);
    translate([0, 0, -pulley_width/2 - flange_thickness])
    cylinder(d=flange_diameter, h=flange_thickness, center=false);
}

// Set screw holes
module set_screw_holes() {
    for (i = [0:1]) {
        rotate([0, 0, i * 180])
        translate([hub_diameter/2 - set_screw_distance, 0, 0])
        rotate([90, 0, 0])
        cylinder(d=set_screw_diameter, h=hub_length, center=true);
    }
}

// Keyway or flat
module keyway_or_flat() {
    translate([-keyway_width/2, -bore_diameter/2, -pulley_width/2])
    cube([keyway_width, keyway_depth, pulley_width + 2*flange_thickness]);
}

// Lightening holes
module lightening_holes() {
    for (i = [0:lightening_hole_count-1]) {
        rotate([0, 0, i * 360 / lightening_hole_count])
        translate([pulley_diameter/4, 0, 0])
        rotate([90, 0, 0])
        cylinder(d=lightening_hole_diameter, h=pulley_width, center=true);
    }
}

// Pulley assembly
module pulley() {
    difference() {
        union() {
            pulley_body();
            belt_profile();
            hub();
            flanges();
        }
        center_bore();
        set_screw_holes();
        keyway_or_flat();
        lightening_holes();
    }
}

// Render the pulley
pulley();