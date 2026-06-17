$fn = 120;

// Timing pulley parameters
teeth = 16;
pitch_diameter = 9.75;     // mm
pitch = PI * pitch_diameter / teeth;  // derived circular pitch
pulley_width = 10;         // mm
bore_diameter = 5;         // mm

// Tooth geometry (simple trapezoidal approximation)
tooth_height = 1.2;        // mm (radial)
tooth_top_width = pitch * 0.35;
tooth_base_width = pitch * 0.75;

// Body geometry
pitch_radius = pitch_diameter / 2;
root_radius = pitch_radius - tooth_height;
hub_extra = 2.0;           // mm extra radius beyond root for strength
hub_radius = root_radius + hub_extra;

module tooth2d() {
    // Trapezoid centered on X axis, extending outward in +Y
    polygon(points=[
        [-tooth_base_width/2, 0],
        [ tooth_base_width/2, 0],
        [ tooth_top_width/2,  tooth_height],
        [-tooth_top_width/2,  tooth_height]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Main cylinder up to root radius
            cylinder(h=pulley_width, r=root_radius);

            // Add teeth around pitch circle (placed at root radius)
            for (i = [0:teeth-1]) {
                rotate([0,0, i*360/teeth])
                    translate([0, root_radius, 0])
                        linear_extrude(height=pulley_width)
                            tooth2d();
            }

            // Slight hub reinforcement (optional)
            cylinder(h=pulley_width, r=hub_radius);
        }

        // Bore
        translate([0,0,-0.5])
            cylinder(h=pulley_width+1, r=bore_diameter/2);
    }
}

pulley();