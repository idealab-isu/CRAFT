// Foam sponge sheet (single connected solid)

// Quality
$fn = 48;

// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150;  //[75:300:1]
sheet_thickness = 10; //[5:20:1]

edge_radius = 2; //[1:6:0.5]

// Pores (subtractive dimples)
pore_radius = 1.2; //[0.5:3:0.1]
pore_depth = 0.8;  //[0.2:2:0.1]
pore_margin = 12;  //[6:30:1]
pore_spacing_x = 30; //[15:60:1]
pore_spacing_y = 30; //[15:60:1]
pore_cols = 5; //[2:12:1]
pore_rows = 4; //[2:10:1]
pore_top_inset = 0.2; //[0.05:1:0.05]

// Small overlap to avoid coplanar artifacts
connect_overlap = 1; //[0.5:2:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded rectangular slab using hull of corner cylinders (fast, robust)
module rounded_slab(L, W, T, R) {
    R2 = clamp(R, 0.01, min(L, W)/2 - 0.01);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2), 0])
                cylinder(r=R2, h=T, center=true);
    }
}

// One pore as a spherical cap that cuts into the top surface by pore_depth
module pore_cap(r, depth) {
    // Place sphere center above the surface so only a cap intersects the slab.
    // For a sphere of radius r, cap depth d occurs when center is at z = r - d above the surface.
    translate([0, 0, r - depth])
        sphere(r=r);
}

// Pore field limited by margins; pores are connected to the slab via overlap (subtractive only)
module pore_field() {
    // Compute usable span and actual spacing so pores stay within margins
    usable_x = max(0, sheet_length - 2*pore_margin);
    usable_y = max(0, sheet_width  - 2*pore_margin);

    span_x = (pore_cols > 1) ? min(usable_x, (pore_cols-1)*pore_spacing_x) : 0;
    span_y = (pore_rows > 1) ? min(usable_y, (pore_rows-1)*pore_spacing_y) : 0;

    step_x = (pore_cols > 1) ? span_x/(pore_cols-1) : 0;
    step_y = (pore_rows > 1) ? span_y/(pore_rows-1) : 0;

    z_surface = sheet_thickness/2 - pore_top_inset;

    for (ix = [0:pore_cols-1])
        for (iy = [0:pore_rows-1])
            translate([
                -span_x/2 + ix*step_x,
                -span_y/2 + iy*step_y,
                z_surface
            ])
                pore_cap(pore_radius, pore_depth);
}

// Final model
module complete_model() {
    difference() {
        rounded_slab(sheet_length, sheet_width, sheet_thickness, edge_radius);

        // Subtract pores from the top surface only (cap intersects slab)
        // Add a tiny downward shift so subtraction always intersects (robust)
        translate([0, 0, -connect_overlap/10])
            pore_field();
    }
}

// Render
color([0.85, 0.85, 0.8])
complete_model();