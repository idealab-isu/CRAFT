$fn = 180;

// Timing pulley (simplified GT2-like tooth form)
// User specs:
teeth = 20;
pitch_diameter = 12.22;   // mm

// Assumptions / defaults (can be edited):
pulley_width = 10;        // mm
bore_diameter = 5;        // mm
hub_diameter = 0;         // 0 = no hub
hub_height = 0;           // mm

// Tooth geometry (approximate, not manufacturer-exact):
tooth_height = 0.75;      // radial height above pitch circle (mm)
tooth_tip_width = 0.70;   // tangential width at tooth tip (mm)
tooth_root_width = 1.20;  // tangential width at tooth root (mm)
root_clearance = 0.25;    // radial clearance below pitch circle (mm)

// Derived:
pitch_radius = pitch_diameter / 2;
pitch_circumference = PI * pitch_diameter;
pitch = pitch_circumference / teeth;
tooth_angle = 360 / teeth;

// Base cylinder radii:
r_root = max(0.1, pitch_radius - root_clearance);
r_tip  = pitch_radius + tooth_height;

module tooth2d() {
    // Trapezoid centered on +X axis, extruded later
    polygon(points=[
        [r_root, -tooth_root_width/2],
        [r_root,  tooth_root_width/2],
        [r_tip,   tooth_tip_width/2],
        [r_tip,  -tooth_tip_width/2]
    ]);
}

module pulley_body() {
    union() {
        // Root cylinder
        cylinder(h=pulley_width, r=r_root);

        // Teeth
        for (i = [0:teeth-1]) {
            rotate([0,0,i*tooth_angle])
                linear_extrude(height=pulley_width)
                    tooth2d();
        }

        // Optional hub
        if (hub_diameter > 0 && hub_height > 0) {
            translate([0,0,(pulley_width - hub_height)/2])
                cylinder(h=hub_height, d=hub_diameter);
        }
    }
}

difference() {
    pulley_body();
    // Bore
    translate([0,0,-1])
        cylinder(h=pulley_width+2, d=bore_diameter);
}