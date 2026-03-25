$fn = 128;

// Target dimensions (LM10LUU-style)
bore_diameter_mm  = 10.0;
outer_diameter_mm = 19.0;
length_mm         = 55.0;

// Detail parameters
chamfer_mm            = 0.8;   // small end chamfer
seal_region_length_mm = 4.0;   // visual seal band length
seal_radial_thick_mm  = 0.6;   // seal band radial thickness (visual)
groove_enabled        = 1;     // outer snap-ring grooves (visual)
groove_length_mm      = 2.2;
groove_depth_mm       = 0.5;
groove_inset_mm       = 6.0;   // distance from each end to groove center
overlap_mm            = 0.2;   // for robust booleans

bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

// Chamfered outer shell (no bore)
module chamfered_shell(r, h, c) {
    // Outer profile: cylinder with small chamfers at both ends
    union() {
        // main straight section
        translate([0,0,0])
            cylinder(r=r, h=h - 2*c, center=true);

        // end chamfers (frustums)
        translate([0,0, (h/2 - c/2)])
            cylinder(r1=r, r2=max(r - c, 0.01), h=c, center=true);

        translate([0,0, -(h/2 - c/2)])
            cylinder(r1=max(r - c, 0.01), r2=r, h=c, center=true);
    }
}

// Main bearing body with through-bore and outer grooves
module linear_bearing_body() {
    difference() {
        // Outer casing with chamfers
        chamfered_shell(outer_r, length_mm, chamfer_mm);

        // Through bore (slightly extended for clean cut)
        cylinder(r=bore_r, h=length_mm + 2*overlap_mm, center=true);

        // Outer grooves (cut into OD)
        if (groove_enabled) {
            for (z = [ (length_mm/2 - groove_inset_mm), -(length_mm/2 - groove_inset_mm) ]) {
                translate([0,0,z])
                    difference() {
                        cylinder(r=outer_r + overlap_mm, h=groove_length_mm, center=true);
                        cylinder(r=outer_r - groove_depth_mm, h=groove_length_mm + 2*overlap_mm, center=true);
                    }
            }
        }
    }
}

// Visual end seals (rings) that are connected to the body
module end_seals() {
    // Rings sit just inside the ends; they overlap the body slightly to ensure connectivity
    for (z = [ (length_mm/2 - seal_region_length_mm/2), -(length_mm/2 - seal_region_length_mm/2) ]) {
        translate([0,0,z])
            difference() {
                // outer of seal ring (slightly larger than bore)
                cylinder(r=bore_r + seal_radial_thick_mm, h=seal_region_length_mm, center=true);
                // keep bore open
                cylinder(r=bore_r, h=seal_region_length_mm + 2*overlap_mm, center=true);
            }
    }
}

// Assembly: ONE connected solid (bearing only; no side screw/rod)
union() {
    linear_bearing_body();
    end_seals();
}