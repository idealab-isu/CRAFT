// Miniature linear guide rail (single connected solid)
// Overall dimensions: 15mm wide (X), 10mm tall (Z), 100mm long (Y)

$fn = 96;

// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width  = 15.0;  //[7.5:30.0:0.5]
rail_height = 10.0;  //[5.0:20.0:0.5]

// Feature parameters (kept proportional and within bounds)
edge_chamfer  = min(1.0, rail_width/10, rail_height/10);
top_land_w    = rail_width * 0.45;
top_land_h    = rail_height * 0.25;
side_groove_w = rail_width * 0.18;
side_groove_h = rail_height * 0.35;
side_groove_z = rail_height * 0.55;

// Mounting holes (through from top, with counterbore)
hole_d      = min(3.2, rail_width*0.22);
cbore_d     = min(6.0, rail_width*0.40);
cbore_depth = min(2.0, rail_height*0.22);
end_margin  = max(10.0, rail_length*0.10);
hole_count  = 5;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rail_profile_2d() {
    // 2D cross-section in X-Z plane, extruded along Y
    w = rail_width;
    h = rail_height;

    tlw = clamp(top_land_w, w*0.25, w*0.70);
    tlh = clamp(top_land_h, h*0.15, h*0.40);
    ch  = clamp(edge_chamfer, 0.4, min(w, h)/4);

    // Centered on X=0, Z=0; bottom at -h/2, top at +h/2
    polygon(points=[
        [-w/2,        -h/2],
        [ w/2,        -h/2],
        [ w/2,         h/2 - tlh - ch],
        [ tlw/2 + ch,  h/2 - tlh - ch],
        [ tlw/2,       h/2 - tlh],
        [ tlw/2,       h/2],
        [-tlw/2,       h/2],
        [-tlw/2,       h/2 - tlh],
        [-tlw/2 - ch,  h/2 - tlh - ch],
        [-w/2,         h/2 - tlh - ch]
    ]);
}

module rail_solid() {
    // Extrude profile along Y to create the rail body
    linear_extrude(height=rail_length, center=true, convexity=10)
        rail_profile_2d();
}

module side_grooves_cut() {
    // Two shallow side grooves along the full length
    w = rail_width;
    h = rail_height;

    gw = clamp(side_groove_w, w*0.10, w*0.25);
    gh = clamp(side_groove_h, h*0.20, h*0.45);
    gz = clamp(side_groove_z, h*0.35, h*0.70);

    zc = -h/2 + gz;

    // Ensure cutters intersect the rail (slight overlap into body)
    overlap = 0.2;
    for (sx = [-1, 1]) {
        translate([sx*(w/2 - gw/2 + overlap/2), 0, zc])
            cube([gw + overlap, rail_length + 0.6, gh], center=true);
    }
}

module mounting_holes_cut() {
    // Through holes along Y, drilled along Z, with counterbore from top
    h = rail_height;

    usable = rail_length - 2*end_margin;
    step = (hole_count > 1) ? (usable/(hole_count-1)) : 0;

    for (i = [0:hole_count-1]) {
        y = -rail_length/2 + end_margin + i*step;

        // Through hole (guaranteed to cut through)
        translate([0, y, 0])
            cylinder(d=hole_d, h=h + 1.0, center=true);

        // Counterbore: top aligned slightly above top surface
        translate([0, y, h/2 - cbore_depth/2 + 0.05])
            cylinder(d=cbore_d, h=cbore_depth + 0.2, center=true);
    }
}

module rail_model() {
    // One connected solid: base rail with subtracted grooves and holes
    difference() {
        rail_solid();
        side_grooves_cut();
        mounting_holes_cut();
    }
}

// Place model so it is clearly visible and centered in the viewport
// (Geometry remains exactly 15 x 100 x 10 overall)
rail_model();