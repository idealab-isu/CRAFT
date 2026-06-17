$fn=160;

// Timing pulley parameters
teeth = 20;
pitch_diameter = 12.22;          // mm
pitch_radius = pitch_diameter/2;

pulley_width = 10;               // mm
hub_diameter = 18;               // mm (outer body diameter)
bore_diameter = 5;               // mm (shaft bore)

flange_diameter = 22;            // mm
flange_thickness = 1.2;          // mm

// Tooth geometry (simple trapezoidal approximation)
tooth_height = 1.6;              // mm radial height above pitch circle
tooth_root_depth = 0.6;          // mm radial depth below pitch circle
tooth_tip_width = 1.2;           // mm tangential width at tip
tooth_root_width = 2.2;          // mm tangential width at root

// Derived
pitch_circumference = PI * pitch_diameter;
tooth_pitch = pitch_circumference / teeth;
tooth_angle = 360 / teeth;

root_radius = pitch_radius - tooth_root_depth;
tip_radius  = pitch_radius + tooth_height;

// Ensure body covers tooth root
body_radius = max(hub_diameter/2, root_radius + 0.4);

module tooth2d() {
    // Trapezoid centered on +X axis, extruded later
    // Coordinates in (x,y) where x is radial, y is tangential
    polygon(points=[
        [root_radius, -tooth_root_width/2],
        [root_radius,  tooth_root_width/2],
        [tip_radius,   tooth_tip_width/2],
        [tip_radius,  -tooth_tip_width/2]
    ]);
}

module pulley_body() {
    // Main cylinder + flanges
    union() {
        // Main body
        translate([0,0,flange_thickness])
            cylinder(h=pulley_width, r=body_radius);

        // Bottom flange
        cylinder(h=flange_thickness, r=flange_diameter/2);

        // Top flange
        translate([0,0,flange_thickness + pulley_width])
            cylinder(h=flange_thickness, r=flange_diameter/2);
    }
}

module teeth_ring() {
    // Teeth occupy the belt contact region (between flanges)
    translate([0,0,flange_thickness])
    linear_extrude(height=pulley_width)
    union() {
        for (i=[0:teeth-1]) {
            rotate(i*tooth_angle)
                tooth2d();
        }
    }
}

difference() {
    union() {
        pulley_body();
        teeth_ring();
    }

    // Bore
    translate([0,0,-1])
        cylinder(h=pulley_width + 2*flange_thickness + 2, r=bore_diameter/2);

    // Optional: lighten interior slightly (keeps hub diameter)
    // Comment out if undesired
    translate([0,0,flange_thickness+0.5])
        cylinder(h=pulley_width-1, r=max(0, body_radius-2.0));
}