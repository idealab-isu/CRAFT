// Parameters
pulley_diameter = 50;
pulley_width = 20;
bore_diameter = 10;
rim_tooth_height = 2;
rim_tooth_count = 20;
hub_diameter = 15;
hub_length = 10;
flange_thickness = 2;
set_screw_diameter = 3;
set_screw_distance = 5;

// Pulley Wheel
module pulley_wheel() {
    difference() {
        cylinder(d=pulley_diameter, h=pulley_width, center=true);
        translate([0, 0, -pulley_width/2])
            cylinder(d=bore_diameter, h=pulley_width + 2, center=false);
    }
}

// Rim Profile
module rim_profile() {
    for (i = [0:rim_tooth_count-1]) {
        rotate([0, 0, i * 360 / rim_tooth_count])
            translate([pulley_diameter/2, 0, 0])
                cube([rim_tooth_height, pulley_width, rim_tooth_height], center=true);
    }
}

// Hub
module hub() {
    translate([0, 0, -hub_length/2])
        cylinder(d=hub_diameter, h=hub_length, center=false);
}

// Flanges
module flanges() {
    translate([0, 0, pulley_width/2])
        cylinder(d=pulley_diameter + 10, h=flange_thickness, center=false);
    translate([0, 0, -pulley_width/2 - flange_thickness])
        cylinder(d=pulley_diameter + 10, h=flange_thickness, center=false);
}

// Set Screw Holes
module set_screw_holes() {
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
            translate([hub_diameter/2 + set_screw_distance, 0, 0])
                rotate([90, 0, 0])
                    cylinder(d=set_screw_diameter, h=hub_length + 2, center=true);
    }
}

// Pulley Assembly
module pulley() {
    union() {
        pulley_wheel();
        rim_profile();
        hub();
        flanges();
        set_screw_holes();
    }
}

// Render the pulley
pulley();