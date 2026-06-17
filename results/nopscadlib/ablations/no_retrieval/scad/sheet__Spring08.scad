// Bi-metal saw blade (single connected solid)

// ---------- Parameters ----------
blade_L = 150; //[75:300:1]
blade_W = 19;  //[10:38:1]
blade_T = 0.9; //[0.45:1.8:0.05]

tooth_pitch = 2.5; //[1.25:5:0.1]
tooth_H = 1.2;     //[0.6:2.4:0.05]
tooth_tip_angle = 60; //[30:90:1]  // visual only (triangle)

tang_L = 30; //[15:60:1]
tang_W = 12; //[6:24:1]

hole_d = 5;          //[3:10:0.5]
hole_spacing = 18;   //[10:36:1]
hole_edge_margin = 6;//[3:12:0.5]

overlap = 0.25; //[0.1:2:0.05]

tooth_count = 48; //[10:120:1]

bimetal_band_W = 3;        //[1.5:6:0.5]
bimetal_groove_depth = 0.15;//[0.05:0.3:0.01]

chamfer_size = 0.4; //[0.2:1:0.05]
tooth_set_offset = 0.15; //[0.05:0.4:0.01]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

$fn = 48;

// ---------- Core geometry ----------
module blade_blank_2d() {
    // 2D outline: main blade + reduced-width tang on the left
    // Coordinate system: X along length, Y across width
    union() {
        // Main body
        translate([0, 0])
            square([blade_L, blade_W], center=false);

        // Tang (reduced width) at left end
        translate([0, (blade_W - tang_W)/2])
            square([tang_L, tang_W], center=false);
    }
}

module blade_blank_3d() {
    // Extrude centered in Z for consistent hole cuts
    linear_extrude(height=blade_T, center=true, convexity=10)
        blade_blank_2d();
}

module mounting_holes_cut() {
    // Two holes in tang, centered on tang width
    // Ensure holes stay within tang length
    x1 = clamp(hole_edge_margin, hole_d/2 + 0.5, tang_L - hole_d/2 - 0.5);
    x2 = clamp(hole_edge_margin + hole_spacing, hole_d/2 + 0.5, tang_L - hole_d/2 - 0.5);

    for (x = [x1, x2])
        translate([x, blade_W/2, 0])
            cylinder(h=blade_T + 2*overlap, r=hole_d/2, center=true);
}

module end_chamfers_cut() {
    // Small corner chamfers on far (right) end
    // Implemented as subtracting squares from the 2D profile then extruding
    // (done in 3D difference below via extruded cutters)
    for (sy = [0, 1]) {
        y0 = sy == 0 ? 0 : blade_W - chamfer_size;
        translate([blade_L - chamfer_size, y0, 0])
            linear_extrude(height=blade_T + 2*overlap, center=true, convexity=5)
                square([chamfer_size, chamfer_size], center=false);
    }
}

module bimetal_groove_cut() {
    // Shallow groove along the tooth edge (top edge, +Y side) to suggest bi-metal band
    // Cut only on the main blade region (exclude tang)
    groove_L = blade_L - tang_L;
    translate([tang_L + groove_L/2, blade_W - bimetal_band_W/2, blade_T/2 - bimetal_groove_depth/2])
        cube([groove_L + overlap, bimetal_band_W, bimetal_groove_depth + overlap], center=true);
}

module tooth_2d() {
    // Simple triangular tooth protruding from top edge
    // Base sits on blade edge; apex points outward (+Y)
    // Width along X = tooth_pitch
    polygon(points=[
        [0, 0],
        [tooth_pitch, 0],
        [tooth_pitch/2, tooth_H]
    ]);
}

module teeth_solid() {
    // Teeth are added as solid protrusions, overlapping slightly into blade for connectivity
    // Place along main blade region starting at tang_L
    start_x = tang_L;
    usable_L = blade_L - tang_L;
    n = min(tooth_count, floor(usable_L / tooth_pitch));

    union() {
        for (i = [0 : n-1]) {
            x = start_x + i*tooth_pitch;

            // Main tooth
            translate([x, blade_W - overlap, 0])
                linear_extrude(height=blade_T, center=true, convexity=5)
                    tooth_2d();

            // Tooth set bumps (alternate Z), kept connected by overlapping into blade thickness
            bump_L = tooth_pitch * 0.6;
            bump_H = tooth_H * 0.55;
            bump_T = tooth_set_offset * 2;

            zoff = (i % 2 == 0) ? (blade_T/2 - bump_T/2 + overlap) : (-(blade_T/2 - bump_T/2 + overlap));

            translate([x + (tooth_pitch - bump_L)/2, blade_W - overlap, zoff])
                cube([bump_L, bump_H, bump_T], center=false);
        }
    }
}

// ---------- Final model ----------
module blade_with_teeth() {
    union() {
        // Blade body with cuts
        difference() {
            color("DimGray") blade_blank_3d();

            // Holes
            mounting_holes_cut();

            // End chamfers
            end_chamfers_cut();

            // Bi-metal groove
            bimetal_groove_cut();
        }

        // Teeth (connected via overlap into blade edge)
        color("Silver") teeth_solid();
    }
}

blade_with_teeth();