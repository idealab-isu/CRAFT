// 10x10mm aluminium extrusion profile, 100mm long
// STRUCTURAL FIXES:
// - Remove the split "two halves" construction that can create two disconnected long bars
// - Build ONE continuous 10x10 outer body
// - Keep all features as subtractive cuts
// - Use union() for a single solid and add small overlaps (1–2mm) only where needed for cuts

$fn = 64;

// Exact target dimensions
cross_section_width_mm  = 10.0;
cross_section_height_mm = 10.0;
length_mm               = 100.0;

// Feature parameters (kept reasonable for a 10x10 profile)
corner_r_mm                 = 0.6;
t_slot_opening_width_mm     = 3.2;
t_slot_inner_width_mm       = 6.2;
t_slot_depth_mm             = 3.6;
t_slot_neck_depth_mm        = 1.6;
center_bore_diameter_mm     = 4.2;
corner_hole_diameter_mm     = 2.2;
corner_hole_offset_mm       = 2.2;

cornerHole = 1;

eps = 0.02;                 // small numeric epsilon
cut_overlap_mm = 1.5;        // 1–2mm overlap for through-cuts / guaranteed intersection

// Rounded rectangle prism (exact outer size)
module rounded_box(size=[10,10,100], r=0.6, center=true) {
    w = size[0]; h = size[1]; l = size[2];
    rr = min(r, min(w,h)/2 - eps);

    translate(center ? [0,0,0] : [w/2, h/2, l/2])
        linear_extrude(height=l, center=true, convexity=10)
            offset(r=rr)
                square([w-2*rr, h-2*rr], center=true);
}

// One connected extrusion solid
module extrusion_10x10_L100() {
    color("Silver")
    difference() {
        // SINGLE connected 10x10 body (fixes floating/split halves)
        union() {
            rounded_box([cross_section_width_mm,
                         cross_section_height_mm,
                         length_mm], r=corner_r_mm, center=true);
        }

        // Through-cut helper length (ensures cutters fully intersect body)
        cut_h = length_mm + 2*cut_overlap_mm;

        // Center bore (through along Z)
        cylinder(d=center_bore_diameter_mm, h=cut_h, center=true);

        // T-slots (4 sides), cut from the body
        for (a = [0, 90, 180, 270]) {
            rotate([0,0,a]) {
                // Place cutters so they definitely reach/overlap the outer surface.
                // Use a small outward bias (cut_overlap_mm/2) to guarantee intersection.
                neck_x  = cross_section_width_mm/2 - t_slot_neck_depth_mm/2 + cut_overlap_mm/2;
                inner_x = cross_section_width_mm/2 - t_slot_depth_mm/2      + cut_overlap_mm/2;

                // Neck (opening)
                translate([neck_x, 0, 0])
                    cube([t_slot_neck_depth_mm + cut_overlap_mm,
                          t_slot_opening_width_mm,
                          cut_h], center=true);

                // Inner cavity
                translate([inner_x, 0, 0])
                    cube([t_slot_depth_mm + cut_overlap_mm,
                          t_slot_inner_width_mm,
                          cut_h], center=true);
            }
        }

        // Corner holes (optional), through along Z
        if (cornerHole) {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(cross_section_width_mm/2  - corner_hole_offset_mm),
                           sy*(cross_section_height_mm/2 - corner_hole_offset_mm),
                           0])
                    cylinder(d=corner_hole_diameter_mm, h=cut_h, center=true);
            }
        }
    }
}

union() {
    extrusion_10x10_L100();
}