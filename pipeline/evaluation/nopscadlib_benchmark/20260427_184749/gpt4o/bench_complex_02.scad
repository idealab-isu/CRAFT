$fn=64;

// Parameters
shaft_diameter_5mm = 5;
shaft_diameter_8mm = 8;
coupler_length = 25;
outer_diameter = 20;
flex_slot_width = 1.5;
flex_slot_depth = 8;
flex_slot_count = 6;

// Main Coupler Body
module coupler() {
    difference() {
        // Outer cylinder
        cylinder(h=coupler_length, d=outer_diameter, center=true);
        
        // Inner holes for shafts
        translate([0, 0, -coupler_length/2])
            cylinder(h=coupler_length, d=shaft_diameter_5mm, center=false);
        translate([0, 0, -coupler_length/2])
            cylinder(h=coupler_length, d=shaft_diameter_8mm, center=false);
        
        // Flex slots
        for (i = [0 : flex_slot_count-1]) {
            rotate([0, 0, i * 360 / flex_slot_count])
                translate([outer_diameter/2 - flex_slot_depth/2, 0, 0])
                    cube([flex_slot_depth, flex_slot_width, coupler_length], center=true);
        }
    }
}

// Render the coupler
coupler();