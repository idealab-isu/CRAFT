// Standoff pillar (spacer body with THROUGH bore for M3 screw)
// Spec: 3.0mm thread (interpreted as M3 clearance bore), 10.0mm long, outer diameter unspecified
// Model is ONE connected solid (a hollow standoff body).

thread_diameter_mm = 3.0;   // M3 nominal -> use as through-bore diameter
length_mm = 10.0;
outer_diameter_mm = 6.0;    // reasonable default since diameter is unspecified
overlap_mm = 0.2;

$fn = 128;

module standoff_pillar() {
    body_h = length_mm;
    body_r = outer_diameter_mm/2;

    // Clearance bore for M3 (slightly larger than 3.0mm so it behaves like a standoff)
    bore_d = thread_diameter_mm + 0.3;
    bore_r = bore_d/2;

    // Small end chamfers
    chamfer_h = min(0.8, body_h/4);
    chamfer_r_drop = 0.4;

    // Ensure printable wall thickness
    min_wall = 1.0;
    body_r_safe = max(body_r, bore_r + min_wall);

    difference() {
        // Outer body with chamfered ends (single connected solid)
        union() {
            // Main cylinder
            cylinder(h=body_h, r=body_r_safe, center=true);

            // Top chamfer (overlaps into main body)
            translate([0, 0, body_h/2 - chamfer_h/2 - overlap_mm/2])
                cylinder(h=chamfer_h + overlap_mm, r1=body_r_safe, r2=max(body_r_safe - chamfer_r_drop, 0.1), center=true);

            // Bottom chamfer (overlaps into main body)
            translate([0, 0, -body_h/2 + chamfer_h/2 + overlap_mm/2])
                cylinder(h=chamfer_h + overlap_mm, r1=max(body_r_safe - chamfer_r_drop, 0.1), r2=body_r_safe, center=true);
        }

        // Through bore (slightly longer to guarantee clean cut)
        cylinder(h=body_h + 2*overlap_mm, r=bore_r, center=true);
    }
}

standoff_pillar();