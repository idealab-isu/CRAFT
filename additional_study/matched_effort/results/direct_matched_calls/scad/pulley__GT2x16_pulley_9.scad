$fn = 120;

// Timing pulley parameters
teeth = 16;
pitch_diameter = 9.65;          // mm
pitch_radius = pitch_diameter/2;

pulley_height = 12;             // mm
bore_diameter = 5;              // mm

// Tooth geometry (approximation)
tooth_height = 1.2;             // mm radial add above pitch radius
tooth_tip_width = 1.2;          // mm tangential width at tip
tooth_root_width = 2.2;         // mm tangential width at root
tooth_root_relief = 0.4;        // mm radial relief below pitch radius

// Body geometry
hub_extra_radius = 1.5;         // mm extra beyond pitch radius for core
flange_thickness = 1.2;         // mm
flange_extra_radius = 2.5;      // mm extra beyond tooth tip radius

tooth_tip_radius = pitch_radius + tooth_height;
core_radius = pitch_radius + hub_extra_radius;
flange_radius = tooth_tip_radius + flange_extra_radius;

pitch_circumference = PI * pitch_diameter;
tooth_pitch = pitch_circumference / teeth;
tooth_angle = 360 / teeth;

module tooth2d() {
    // A simple trapezoid tooth profile centered on +X axis
    // Root is slightly below pitch radius to create a valley
    r0 = pitch_radius - tooth_root_relief;
    r1 = tooth_tip_radius;

    // Convert tangential widths to angular offsets at each radius
    a0 = (tooth_root_width / r0) * 180 / PI;
    a1 = (tooth_tip_width  / r1) * 180 / PI;

    polygon(points=[
        [r0*cos(-a0/2), r0*sin(-a0/2)],
        [r1*cos(-a1/2), r1*sin(-a1/2)],
        [r1*cos( a1/2), r1*sin( a1/2)],
        [r0*cos( a0/2), r0*sin( a0/2)]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Core cylinder
            cylinder(h=pulley_height, r=core_radius);

            // Teeth
            for (i = [0:teeth-1]) {
                rotate([0,0,i*tooth_angle])
                    linear_extrude(height=pulley_height)
                        tooth2d();
            }

            // Flanges (top and bottom)
            cylinder(h=flange_thickness, r=flange_radius);
            translate([0,0,pulley_height - flange_thickness])
                cylinder(h=flange_thickness, r=flange_radius);
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(h=pulley_height+1, r=bore_diameter/2);
    }
}

pulley();