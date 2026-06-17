$fn=120;

// Timing pulley parameters
teeth = 16;
pitch_diameter = 9.75;          // mm
pitch_radius = pitch_diameter/2;

pulley_height = 12;             // mm
hub_diameter = 14;              // mm
bore_diameter = 5;              // mm

// Tooth geometry (simplified trapezoidal approximation)
tooth_height = 1.2;             // mm radial height above pitch circle
tooth_root_depth = 0.6;         // mm radial depth below pitch circle
tooth_tip_width = 1.2;          // mm tangential width at tip
tooth_root_width = 2.0;         // mm tangential width at root

// Derived
pitch_circumference = PI * pitch_diameter;
pitch = pitch_circumference / teeth;
tooth_angle = 360 / teeth;

r_root = pitch_radius - tooth_root_depth;
r_tip  = pitch_radius + tooth_height;

// Base body radius (to root circle)
body_radius = r_root;

// Tooth module: a trapezoid extruded along Z, placed at +X direction then rotated
module tooth_2d() {
    // Trapezoid centered on X axis, extending outward in +X
    // Coordinates in (x,y): x is radial, y is tangential
    polygon(points=[
        [r_root, -tooth_root_width/2],
        [r_root,  tooth_root_width/2],
        [r_tip,   tooth_tip_width/2],
        [r_tip,  -tooth_tip_width/2]
    ]);
}

module pulley() {
    difference() {
        union() {
            // Main cylinder up to root circle
            cylinder(h=pulley_height, r=body_radius);

            // Hub (optional, slightly larger)
            cylinder(h=pulley_height, r=hub_diameter/2);

            // Teeth
            for(i=[0:teeth-1]) {
                rotate([0,0,i*tooth_angle])
                    linear_extrude(height=pulley_height)
                        tooth_2d();
            }
        }

        // Bore
        translate([0,0,-1])
            cylinder(h=pulley_height+2, r=bore_diameter/2);
    }
}

pulley();