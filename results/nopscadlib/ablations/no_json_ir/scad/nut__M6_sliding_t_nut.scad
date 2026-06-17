$fn = 96;

// --- Required specs ---
screw_diameter     = 6.0;   // for 6.0mm screw
hex_across_flats   = 8.0;   // 8.0mm AF hex pocket
nut_thickness      = 6.6;   // total thickness (Z)

// --- Fit/print clearances ---
hole_clearance     = 0.25;  // clearance for screw shank
hex_clearance      = 0.20;  // clearance for hex pocket
edge_chamfer       = 0.35;  // small edge break

// --- Connectivity overlap (must be 1-2mm) ---
overlap            = 1.2;   // overlap to guarantee connectivity

// --- Derived ---
hole_d = screw_diameter + hole_clearance;

// --- T-slot nut overall proportions ---
head_w = hex_across_flats * 2.0;   // wide part across X
head_l = hex_across_flats * 2.6;   // length along Y
stem_w = hex_across_flats * 1.1;   // narrower stem across X
stem_l = head_l * 0.55;            // shorter stem along Y

// Split thickness into head + stem heights (sum = nut_thickness)
stem_h = nut_thickness * 0.45;
head_h = nut_thickness - stem_h;

// Clamp overlap so it cannot exceed either section height
ov = min(overlap, stem_h*0.9, head_h*0.9);

// --- Helpers ---
module chamfered_box(size=[10,10,10], c=0.35) {
    x=size[0]; y=size[1]; z=size[2];
    c2 = min(c, x/4, y/4, z/4);
    hull() {
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1])
            translate([sx*(x/2-c2), sy*(y/2-c2), sz*(z/2-c2)])
                cube([2*c2, 2*c2, 2*c2], center=true);
    }
}

// Regular hex prism sized by across-flats (AF)
module hex_prism_af(af=8, h=5, center=true) {
    // For a regular hex, AF = 2 * apothem; circumradius R = AF / sqrt(3)
    R = af / sqrt(3);
    cylinder(r=R, h=h, $fn=6, center=center);
}

module t_slot_nut() {
    difference() {
        union() {
            // Place head and stem so they INTERSECT by 'ov' (no floating parts).
            // Head bottom plane: z = +nut_thickness/2 - head_h
            // Stem top plane:   z = -nut_thickness/2 + stem_h
            // We shift stem upward by 'ov' so: stem_top = head_bottom + ov
            head_z = +nut_thickness/2 - head_h/2;
            stem_z = -nut_thickness/2 + stem_h/2 + ov;

            // Wide head (top portion)
            translate([0, 0, head_z])
                chamfered_box([head_w, head_l, head_h], edge_chamfer);

            // Narrow stem (bottom portion), fused to head with overlap
            translate([0, 0, stem_z])
                chamfered_box([stem_w, stem_l, stem_h], edge_chamfer);
        }

        // Through clearance hole for 6mm screw
        cylinder(d=hole_d, h=nut_thickness + 2, center=true);

        // Hex pocket (8mm AF) on the TOP face
        hex_depth = min(nut_thickness*0.55, nut_thickness - 1.2);
        translate([0, 0, +nut_thickness/2 - hex_depth/2 + 0.01])
            hex_prism_af(af=hex_across_flats + hex_clearance, h=hex_depth, center=true);

        // Small lead-in chamfer for the screw hole on both faces
        cham_h = edge_chamfer * 2;
        for (s=[-1,1])
            translate([0, 0, s*(nut_thickness/2 - cham_h/2 + 0.01)])
                cylinder(d1=hole_d + 2*edge_chamfer, d2=hole_d, h=cham_h, center=true);
    }
}

t_slot_nut();