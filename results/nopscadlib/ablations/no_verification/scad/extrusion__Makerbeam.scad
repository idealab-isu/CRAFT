// 10x10 aluminium extrusion profile, 100mm long (single connected solid)

$fn = 64;

// Parameters
profile_width_mm  = 10.0;
profile_height_mm = 10.0;
length_mm         = 100.0;

wall_thickness_mm        = 1.2;
slot_opening_width_mm    = 3.2;
slot_neck_depth_mm       = 1.6;
slot_cavity_width_mm     = 6.2;
slot_cavity_depth_mm     = 2.6;
center_bore_diameter_mm  = 4.2;

cornerHole               = 1;
corner_hole_diameter_mm  = 2.2;
corner_hole_offset_mm    = 2.5;

overlap_mm = 0.2; // small overlap for robust booleans

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module extrusion_10x10(len=length_mm) {
    w = profile_width_mm;
    h = profile_height_mm;

    // Keep geometry valid and visible
    t = clamp(wall_thickness_mm, 0.2, min(w, h)/2 - 0.6);

    slot_open_w = clamp(slot_opening_width_mm, 0.6, min(w, h) - 2*t - 0.6);
    neck_d      = clamp(slot_neck_depth_mm, 0.4, w/2 - t - 0.6);
    cav_w       = clamp(slot_cavity_width_mm, slot_open_w, min(w, h) - 2*t - 0.6);
    cav_d       = clamp(slot_cavity_depth_mm, 0.4, w/2 - t - neck_d - 0.6);

    bore_r = clamp(center_bore_diameter_mm/2, 0, min(w, h)/2 - t - 0.6);

    // Slot cut positions (from outer face inward)
    x_neck =  w/2 - neck_d/2;
    x_cav  =  w/2 - neck_d - cav_d/2;
    y_neck =  h/2 - neck_d/2;
    y_cav  =  h/2 - neck_d - cav_d/2;

    // Corner hole placement
    offx = w/2 - corner_hole_offset_mm;
    offy = h/2 - corner_hole_offset_mm;
    rch  = clamp(corner_hole_diameter_mm/2, 0, min(w, h)/2 - 0.6);

    // Build as a single connected solid: outer body minus internal features
    color("Silver")
    difference() {
        // Outer body (10x10 cross-section, length along Z)
        cube([w, h, len], center=true);

        // Inner void (tube) - ensure it doesn't erase everything
        cube([w - 2*t, h - 2*t, len + 2*overlap_mm], center=true);

        // T-slots (4 sides), cut through full length
        // Use explicit union to avoid any accidental separation in boolean evaluation
        union() {
            // +X side
            translate([ x_neck, 0, 0])
                cube([neck_d + 2*overlap_mm, slot_open_w, len + 2*overlap_mm], center=true);
            translate([ x_cav, 0, 0])
                cube([cav_d + 2*overlap_mm, cav_w, len + 2*overlap_mm], center=true);

            // -X side
            translate([-x_neck, 0, 0])
                cube([neck_d + 2*overlap_mm, slot_open_w, len + 2*overlap_mm], center=true);
            translate([-x_cav, 0, 0])
                cube([cav_d + 2*overlap_mm, cav_w, len + 2*overlap_mm], center=true);

            // +Y side
            translate([0,  y_neck, 0])
                cube([slot_open_w, neck_d + 2*overlap_mm, len + 2*overlap_mm], center=true);
            translate([0,  y_cav, 0])
                cube([cav_w, cav_d + 2*overlap_mm, len + 2*overlap_mm], center=true);

            // -Y side
            translate([0, -y_neck, 0])
                cube([slot_open_w, neck_d + 2*overlap_mm, len + 2*overlap_mm], center=true);
            translate([0, -y_cav, 0])
                cube([cav_w, cav_d + 2*overlap_mm, len + 2*overlap_mm], center=true);
        }

        // Center bore (through length)
        if (bore_r > 0)
            cylinder(r=bore_r, h=len + 2*overlap_mm, center=true);

        // Corner holes (optional)
        if (cornerHole && rch > 0) {
            union() {
                translate([ offx,  offy, 0]) cylinder(r=rch, h=len + 2*overlap_mm, center=true, $fn=48);
                translate([-offx,  offy, 0]) cylinder(r=rch, h=len + 2*overlap_mm, center=true, $fn=48);
                translate([-offx, -offy, 0]) cylinder(r=rch, h=len + 2*overlap_mm, center=true, $fn=48);
                translate([ offx, -offy, 0]) cylinder(r=rch, h=len + 2*overlap_mm, center=true, $fn=48);
            }
        }
    }
}

// Render
extrusion_10x10(length_mm);