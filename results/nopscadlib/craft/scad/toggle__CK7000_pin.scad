// Parameters (mm)
body_diameter_mm = 0.76; //[0.38:1.52:0.01]
overall_height_mm = 4.7; //[2.35:9.4:0.05]

// Visual proportions (kept small; overall height is enforced)
base_flange_diameter_mm = 1.00; //[0.5:2:0.01]
base_flange_thickness_mm = 0.20; //[0.1:0.4:0.01]

collar_diameter_mm = 0.92; //[0.5:1.5:0.01]
collar_height_mm   = 0.35; //[0.1:1:0.01]

lever_diameter_mm = 0.30; //[0.15:0.6:0.01]
lever_tilt_deg = 18; //[0:35:1]

tip_diameter_mm = 0.34; //[0.2:0.8:0.01]

// Structural overlap to guarantee connection (1–2mm required)
overlap_mm = 1.0; //[1:2:0.1]

$fn = 64;

// Toggle switch: ONE connected solid, centered on Z, exact overall height.
// Body diameter is exactly body_diameter_mm.
module toggle() {
    function clamp(x, a, b) = min(max(x, a), b);

    // Collar must not exceed body diameter (body diameter requirement)
    collar_d = clamp(collar_diameter_mm, body_diameter_mm, body_diameter_mm);

    tip_r = tip_diameter_mm/2;

    z_bottom = -overall_height_mm/2;
    z_top    =  overall_height_mm/2;

    flange_h = base_flange_thickness_mm;
    collar_h = collar_height_mm;

    // Ensure we always have some body height left
    body_h = max(0.01, overall_height_mm - (flange_h + collar_h + 2*tip_r));

    // Part centers (use overlap so adjacent solids intersect)
    z_flange_center = z_bottom + flange_h/2;

    // Body overlaps into flange by overlap_mm
    z_body_center   = (z_bottom + flange_h) + body_h/2 - overlap_mm;

    // Collar overlaps into body by overlap_mm
    z_collar_center = (z_bottom + flange_h + body_h) + collar_h/2 - overlap_mm;

    // Collar top plane (slightly lowered by overlap so lever starts inside collar)
    z_collar_top = (z_bottom + flange_h + body_h + collar_h) - overlap_mm;

    // Tip center must be within overall height
    z_tip_center = z_top - tip_r;

    // Lever length along its own (tilted) axis so that its end reaches the tip center in Z.
    // For a lever tilted about X, the Z component of its axis is cos(tilt).
    tilt_cos = cos(lever_tilt_deg);
    lever_h = max(0.01, (z_tip_center - z_collar_top) / max(0.001, tilt_cos));

    union() {
        // Base flange
        translate([0, 0, z_flange_center])
            cylinder(r=base_flange_diameter_mm/2, h=flange_h, center=true);

        // Main body (exact diameter)
        translate([0, 0, z_body_center])
            cylinder(r=body_diameter_mm/2, h=body_h, center=true);

        // Top collar/shoulder
        translate([0, 0, z_collar_center])
            cylinder(r=collar_d/2, h=collar_h, center=true);

        // Tilted toggle lever (start slightly inside collar for guaranteed attachment)
        translate([0, 0, z_collar_top])
            rotate([lever_tilt_deg, 0, 0])
                translate([0, 0, lever_h/2])
                    cylinder(r=lever_diameter_mm/2, h=lever_h, center=true);

        // Tip sphere: place its center at the lever end, then push it back by overlap_mm
        // so it intersects the lever (no gap / no floating).
        translate([0, 0, z_collar_top])
            rotate([lever_tilt_deg, 0, 0])
                translate([0, 0, lever_h - overlap_mm])
                    sphere(r=tip_r);
    }
}

toggle();