$fn = 180;

// Timing pulley (approximate GT2-like tooth form)
// User specs:
teeth = 20;
pitch_diameter = 12.22;   // mm
pitch_radius = pitch_diameter/2;

// Pulley body parameters (editable)
pulley_width = 10;        // mm
hub_diameter = 16;        // mm (outer diameter of main body)
bore_diameter = 5;        // mm (shaft hole)

// Tooth parameters (approximate)
tooth_height = 0.75;      // radial height above pitch circle
tooth_tip_width = 0.9;    // mm (circumferential width at tooth tip)
tooth_root_width = 1.6;   // mm (circumferential width at tooth root)
tooth_root_relief = 0.25; // mm (small relief below pitch circle)

// Derived
pitch_circumference = PI * pitch_diameter;
pitch = pitch_circumference / teeth;
angle_step = 360 / teeth;

// Base radii
r_pitch = pitch_radius;
r_root  = max(0.1, r_pitch - tooth_root_relief);
r_tip   = r_pitch + tooth_height;

// Ensure body radius at least covers tooth root
r_body = max(hub_diameter/2, r_root + 0.2);

module tooth2d() {
    // A simple trapezoid tooth in polar placement:
    // root at r_root, tip at r_tip, widths are chord-like approximations.
    polygon(points=[
        [r_root, -tooth_root_width/2],
        [r_tip,  -tooth_tip_width/2],
        [r_tip,   tooth_tip_width/2],
        [r_root,  tooth_root_width/2]
    ]);
}

module tooth3d() {
    // Convert the 2D trapezoid (in x=radius, y=tangential) into 3D by:
    // - translating so x is radial from origin
    // - rotating around Z for each tooth
    // - linear extruding along Z
    linear_extrude(height=pulley_width, center=true)
        // Map (radius, tangential) to (x,y) by placing radius along +X and tangential along +Y
        // Already in that coordinate system.
        tooth2d();
}

module pulley_body() {
    difference() {
        cylinder(h=pulley_width, r=r_body, center=true);
        cylinder(h=pulley_width+2, r=bore_diameter/2, center=true);
    }
}

module pulley_teeth() {
    for (i = [0:teeth-1]) {
        rotate([0,0,i*angle_step])
            translate([0,0,0])
                tooth3d();
    }
}

difference() {
    union() {
        pulley_body();
        // Teeth are positioned so their root sits near r_root; tooth2d uses x=r directly.
        // We need to rotate the tooth shape so its radial axis aligns with global X.
        // Then translate it so its root starts at r_root from origin.
        // Since tooth2d already uses x=r, we must shift it so r=0 maps to origin.
        // Achieve by translating the 2D polygon left by r_root, then translating whole tooth out by r_root.
        // Simpler: wrap tooth3d with a translate that moves it so r_root aligns at origin.
        // We'll implement by translating the 2D polygon by -r_root in X, then translating by r_root in X.
        // Net effect: none. So instead, define tooth2d in absolute radius coordinates (already).
        // Therefore, we must place it at origin with no extra translation.
        // But polygon x-coordinates are radii; that means the tooth spans from x=r_root..r_tip.
        // That is correct when origin is at pulley center.
        pulley_teeth();
    }
    // Trim anything inside the body radius to avoid internal overlaps (optional cleanup)
    // Not strictly necessary; keep as-is for renderability.
}