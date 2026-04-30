$fn=64;

// Dimensions for 608ZZ bearing
bearing_outer_diameter = 22;
bearing_inner_diameter = 8;
bearing_width = 7;

// Housing dimensions
housing_outer_diameter = 26;
housing_height = 10;

// Flange dimensions
flange_thickness = 2;
flange_width = 40;
flange_hole_diameter = 4;

// Create the main housing
module bearing_housing() {
    difference() {
        cylinder(d=housing_height, r=housing_outer_diameter/2, center=true);
        translate([0, 0, -housing_height/2])
            cylinder(d=housing_height, r=bearing_outer_diameter/2, center=false);
    }
}

// Create the flange with mounting holes
module flange_with_holes() {
    difference() {
        cube([flange_width, flange_width, flange_thickness], center=true);
        for (angle = [0, 90, 180, 270]) {
            rotate([0, 0, angle])
                translate([flange_width/2 - 5, 0, 0])
                    cylinder(d=flange_thickness + 1, r=flange_hole_diameter/2, center=true);
        }
    }
}

// Assemble the bearing housing with flanges
module bearing_housing_with_flanges() {
    union() {
        bearing_housing();
        translate([0, 0, housing_height/2 + flange_thickness/2])
            flange_with_holes();
        translate([0, 0, -housing_height/2 - flange_thickness/2])
            flange_with_holes();
    }
}

// Render the final design
bearing_housing_with_flanges();