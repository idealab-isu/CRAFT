// Miniature linear guide rail (MGN5-style approximation)
// Overall size: 5.0mm wide (X), 3.6mm tall (Z), 100mm long (Y)

$fn = 64;

// Parameters
rail_width_mm  = 5.0;   //[2.5:10.0:0.1]
rail_height_mm = 3.6;   //[1.8:7.2:0.1]
rail_length_mm = 100.0; //[50.0:200.0:1]

// Feature parameters (kept proportional; do not change overall envelope)
edge_chamfer = min(0.35, rail_width_mm*0.12, rail_height_mm*0.18); // small bevel
groove_depth = min(0.55, rail_width_mm*0.18, rail_height_mm*0.22); // side raceway hint
groove_r     = min(0.55, rail_height_mm*0.22);                     // groove roundness

// Mounting holes (through + shallow counterbore on top)
hole_d       = 1.6;
cbore_d      = 2.8;
cbore_depth  = min(0.8, rail_height_mm*0.28);
end_margin   = 7.0;
hole_pitch   = 20.0;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rail_body_envelope(w, l, h, c) {
    // Centered in Z so subtractive features can be centered too
    // Chamfered rectangular prism via hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - c), sy*(l/2 - c), -h/2])
                cylinder(r=c, h=h, center=false);
    }
}

module MGN5_rail(w, h, l) {
    // Ensure features fit within envelope
    c  = clamp(edge_chamfer, 0.15, min(w, h)/2 - 0.05);
    gd = clamp(groove_depth, 0.2, w/2 - 0.25);
    gr = clamp(groove_r, 0.15, h/2 - 0.25);

    // Hole count based on length and pitch, with end margins
    usable = max(0, l - 2*end_margin);
    n = (usable <= 0) ? 0 : floor(usable / hole_pitch) + 1;

    difference() {
        // Main body (ONE connected solid)
        rail_body_envelope(w, l, h, c);

        // Side raceway/groove hints (subtractive), shallow and within envelope
        // Grooves run along Y, placed near side faces, centered in Z
        for (sx = [-1, 1]) {
            translate([sx*(w/2 - gd), 0, 0])
                rotate([90, 0, 0])
                    cylinder(r=gr, h=l + 0.4, center=true);
        }

        // Top center relief groove (subtractive)
        top_relief_w = clamp(w*0.45, 1.2, w - 0.6);
        top_relief_d = clamp(h*0.18, 0.25, h*0.35);
        translate([0, 0, h/2 - top_relief_d/2])
            cube([top_relief_w, l + 0.4, top_relief_d], center=true);

        // Mounting holes + counterbores (subtractive)
        for (i = [0 : max(n-1, 0)]) {
            y = -l/2 + end_margin + i*hole_pitch;

            // Through hole (centered in Z, guaranteed to cut through)
            translate([0, y, 0])
                cylinder(d=hole_d, h=h + 0.6, center=true);

            // Counterbore from top (starts slightly below top surface for robust boolean)
            translate([0, y, h/2 - cbore_depth/2 + 0.01])
                cylinder(d=cbore_d, h=cbore_depth + 0.2, center=true);
        }
    }
}

// Assembly
MGN5_rail(rail_width_mm, rail_height_mm, rail_length_mm);