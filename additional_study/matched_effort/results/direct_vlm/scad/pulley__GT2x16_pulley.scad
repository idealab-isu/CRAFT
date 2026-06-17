$fn = 220;

// Timing pulley: 16 teeth, 9.75mm pitch diameter
teeth = 16;
pitch_diameter = 9.75;                 // mm
pitch_radius   = pitch_diameter/2;

// Pulley dimensions
pulley_width   = 10;                   // mm
hub_diameter   = 14;                   // mm
hub_height     = pulley_width;         // mm
bore_diameter  = 5;                    // mm

// Tooth geometry (blocky tooth so it is clearly visible)
tooth_height     = 1.2;                // mm above pitch circle
tooth_root_depth = 0.6;                // mm below pitch circle
tooth_tip_width  = 1.0;                // mm tangential at tip
tooth_root_width = 2.0;                // mm tangential at root

// Derived radii
r_root = max(0.2, pitch_radius - tooth_root_depth);
r_tip  = pitch_radius + tooth_height;

// Ensure teeth overlap into the body for a single connected solid
tooth_overlap = 0.35;                  // mm overlap into root cylinder
r_body = r_root + tooth_overlap;

// 2D tooth profile in XY plane, centered on +X axis (radial direction)
module tooth2d() {
    x0 = r_root - tooth_overlap;       // starts inside body for connectivity
    x1 = r_tip;
    w0 = tooth_root_width;
    w1 = tooth_tip_width;

    polygon(points=[
        [x0, -w0/2],
        [x0,  w0/2],
        [x1,  w1/2],
        [x1, -w1/2]
    ]);
}

module pulley_body() {
    cylinder(h=pulley_width, r=r_body, center=false);
}

module teeth_ring() {
    for (i = [0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            linear_extrude(height=pulley_width, center=false, convexity=10)
                tooth2d();
    }
}

module hub() {
    cylinder(h=hub_height, r=hub_diameter/2, center=false);
}

module bore() {
    translate([0,0,-0.5])
        cylinder(h=pulley_width+1, r=bore_diameter/2, center=false);
}

difference() {
    union() {
        // All solids share the same Z range and overlap radially -> one connected solid
        hub();
        pulley_body();
        teeth_ring();
    }
    bore();
}