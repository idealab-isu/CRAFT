$fn = 220;

// Timing pulley parameters
teeth = 16;
pitch_diameter = 9.75;          // mm (pitch circle diameter)
pitch_radius = pitch_diameter/2;

pulley_width = 12;              // mm
hub_diameter = 18;              // mm
hub_height = pulley_width;

bore_diameter = 5;              // mm

// Tooth geometry (simple trapezoid approximation)
tooth_height = 1.2;             // mm (radial)
tooth_top_width = 0.8;          // mm (tangential at tip)
tooth_base_width = 1.8;         // mm (tangential at root)

// Derived
circumference = PI * pitch_diameter;
tooth_pitch = circumference / teeth;

// Place pitch circle at mid tooth height (approx)
root_radius = pitch_radius - tooth_height/2;
tip_radius  = root_radius + tooth_height;

// Make the toothed section smaller than hub so teeth are visible
body_radius = root_radius - 0.35;   // step-in so tooth roots are exposed
overlap = 0.6;                      // tooth overlaps into body for watertight union

module tooth2d() {
    // Trapezoid centered on X, extending in +Y (radial outward after placement)
    polygon(points=[
        [-tooth_base_width/2, 0],
        [ tooth_base_width/2, 0],
        [ tooth_top_width/2,  tooth_height],
        [-tooth_top_width/2,  tooth_height]
    ]);
}

module pulley_body() {
    cylinder(h=pulley_width, r=body_radius, center=true);
}

module teeth_ring() {
    for (i = [0:teeth-1]) {
        rotate([0,0, i*360/teeth])
            // Place tooth so its root line sits at root_radius, protruding outward in +Y
            translate([0, root_radius - overlap, 0])
                linear_extrude(height=pulley_width, center=true, convexity=10)
                    tooth2d();
    }
}

module hub() {
    cylinder(h=hub_height, r=hub_diameter/2, center=true);
}

difference() {
    union() {
        hub();
        pulley_body();
        teeth_ring();
    }
    cylinder(h=hub_height + 2, r=bore_diameter/2, center=true);
}