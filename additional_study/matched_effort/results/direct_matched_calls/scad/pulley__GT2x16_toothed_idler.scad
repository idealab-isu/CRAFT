$fn=160;

// Timing pulley parameters
teeth = 16;
pitch_diameter = 9.75;          // mm
pitch_radius = pitch_diameter/2;

pulley_height = 12;             // mm
hub_diameter = 14;              // mm (outer body diameter)
bore_diameter = 5;              // mm (shaft bore)

flange_diameter = 16;           // mm
flange_thickness = 1.2;         // mm

// Tooth geometry (simple trapezoidal approximation)
tooth_height = 1.2;             // mm (radial)
tooth_tip_width = 0.9;          // mm (tangential at tip)
tooth_root_width = 1.6;         // mm (tangential at root)

// Derived
pitch_circumference = PI * pitch_diameter;
tooth_pitch = pitch_circumference / teeth;
tooth_angle = 360 / teeth;

root_radius = pitch_radius - tooth_height*0.55;
tip_radius  = pitch_radius + tooth_height*0.45;

module tooth2d() {
    // Trapezoid centered on +X axis, extruded later
    polygon(points=[
        [root_radius, -tooth_root_width/2],
        [root_radius,  tooth_root_width/2],
        [tip_radius,   tooth_tip_width/2],
        [tip_radius,  -tooth_tip_width/2]
    ]);
}

module pulley_body() {
    // Main cylinder (hub) plus flanges
    union() {
        // central body
        cylinder(h=pulley_height, d=hub_diameter);

        // bottom flange
        translate([0,0,0])
            cylinder(h=flange_thickness, d=flange_diameter);

        // top flange
        translate([0,0,pulley_height-flange_thickness])
            cylinder(h=flange_thickness, d=flange_diameter);
    }
}

module teeth_ring() {
    // Teeth occupy the middle region between flanges
    teeth_height = pulley_height - 2*flange_thickness;
    translate([0,0,flange_thickness])
    linear_extrude(height=teeth_height)
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
    translate([0,0,-0.5])
        cylinder(h=pulley_height+1, d=bore_diameter);
}