$fn = 160;

// Pulley parameters (mm)
outer_d      = 40;   // overall flange diameter
groove_d     = 30;   // diameter at bottom of V-groove
width        = 18;   // total pulley width
bore_d       = 8;    // center bore diameter

hub_d        = 18;   // hub diameter
hub_len      = 12;   // hub length (centered)

flange_th    = 2.2;  // flange thickness each side
groove_angle = 60;   // included angle of V-groove (degrees)

set_screw_d  = 3;    // optional set screw hole diameter
set_screw_z  = 0;    // z position (0 = mid-plane)
set_screw_on = true;

module pulley() {
    difference() {
        union() {
            // Main pulley body with V-groove
            rotate_extrude(convexity=10)
                polygon(points = pulley_profile_points());

            // Hub (centered)
            translate([0,0,-hub_len/2])
                cylinder(d=hub_d, h=hub_len);
        }

        // Bore
        translate([0,0,-(width/2 + 2)])
            cylinder(d=bore_d, h=width + 4);

        // Set screw (radial)
        if (set_screw_on)
            translate([0,0,set_screw_z])
                rotate([0,90,0])
                    translate([0,0,-(outer_d/2 + 2)])
                        cylinder(d=set_screw_d, h=outer_d + 4);
    }
}

function pulley_profile_points() =
    let(
        R_out = outer_d/2,
        R_g   = groove_d/2,
        W     = width,
        ft    = flange_th,
        // radial run from outer edge to groove bottom per side
        dr    = max(0.01, R_out - R_g),
        // axial drop from flange inner face to groove bottom based on half-angle
        dz    = dr / tan(groove_angle/2),
        // clamp so groove doesn't exceed available half-width
        dzc   = min(dz, max(0.01, (W/2 - ft - 0.2))),
        // recompute effective groove radius if clamped
        R_eff = R_out - dzc * tan(groove_angle/2)
    )
    [
        // Start at outer radius, left face
        [R_out, -W/2],
        // Left flange inner face
        [R_out, -W/2 + ft],
        // Down slope to groove bottom
        [R_eff, -dzc],
        // Groove bottom (small flat to avoid a sharp singularity)
        [R_g, 0],
        // Up slope to right flange inner face
        [R_eff, dzc],
        // Right flange inner face
        [R_out, W/2 - ft],
        // Outer radius, right face
        [R_out, W/2]
    ];

pulley();