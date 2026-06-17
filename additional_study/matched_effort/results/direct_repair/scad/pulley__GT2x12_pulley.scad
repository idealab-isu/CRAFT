$fn = 120;

// Timing pulley (simplified) with 12 teeth and 7.15mm pitch diameter.
// This is a generic approximation: teeth are modeled as rectangular protrusions
// around a pitch circle. Adjust parameters as needed for a specific belt profile.

teeth = 12;
pitch_diameter = 7.15;          // mm
pitch_radius = pitch_diameter/2;

pulley_height = 10;             // mm
hub_diameter = 6.0;             // mm (core cylinder diameter)
tooth_radial_height = 0.8;      // mm (tooth protrusion beyond hub)
tooth_tangential_width = 1.2;   // mm (tooth width along circumference)
tooth_root_clearance = 0.2;     // mm (hub slightly under pitch circle)

// Derived
hub_radius = max(0.1, pitch_radius - tooth_root_clearance);
outer_radius = hub_radius + tooth_radial_height;

module pulley() {
    union() {
        // Hub/body
        cylinder(h=pulley_height, r=hub_radius);

        // Teeth
        for (i = [0:teeth-1]) {
            rotate([0,0, i*360/teeth])
                translate([hub_radius, -tooth_tangential_width/2, 0])
                    cube([tooth_radial_height, tooth_tangential_width, pulley_height], center=false);
        }

        // Slight outer rounding (optional)
        // Uncomment to soften edges:
        // difference() {
        //     cylinder(h=pulley_height, r=outer_radius);
        //     cylinder(h=pulley_height, r=outer_radius-0.2);
        // }
    }
}

pulley();