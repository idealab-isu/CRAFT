$fn = 96;

// =====================
// Parameters (mm)
// =====================
body_diameter = 6.86;                 // requested body diameter
body_height   = 12.7;                 // requested body height

lever_diameter = 2.0;
lever_length = 12.0;
lever_exposed_above_body = 10.0;

flange_diameter = 9.0;
flange_thickness = 1.0;

pivot_boss_diameter = 4.0;
pivot_boss_height = 2.0;

thread_outer_diameter = 6.6;
thread_height = 6.0;

nut_flat_width = 10.0;               // across flats
nut_thickness = 2.5;

washer_diameter = 10.0;
washer_thickness = 0.8;

lug_width = 2.5;
lug_thickness = 0.8;
lug_length = 5.0;
lug_spacing = 3.0;

chamfer_height = 0.6;
chamfer_radial = 0.4;

overlap = 0.8;                       // intentional overlap to guarantee connectivity

// =====================
// Helpers
// =====================
module hex_prism(af, h, center=true) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(r=r, h=h, $fn=6, center=center);
}

// =====================
// Parts (all centered on Z=0 body)
// =====================
module switch_body() {
    cylinder(r=body_diameter/2, h=body_height, center=true);
}

module top_bushing_flange() {
    translate([0,0, body_height/2 + flange_thickness/2 - overlap])
        cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

module lever_pivot_boss() {
    translate([0,0, body_height/2 + pivot_boss_height/2 - overlap])
        cylinder(r=pivot_boss_diameter/2, h=pivot_boss_height, center=true);
}

module toggle_lever() {
    // Ensure lever intersects pivot boss by overlap
    lever_center_z = body_height/2 + lever_exposed_above_body - lever_length/2 - overlap;
    translate([0,0, lever_center_z])
        cylinder(r=lever_diameter/2, h=lever_length, center=true);
}

module thread_detail() {
    // Threaded bushing region on upper half of body; overlaps into body
    translate([0,0, body_height/2 - thread_height/2 - overlap])
        cylinder(r=thread_outer_diameter/2, h=thread_height, center=true);
}

module mounting_nut() {
    // Place nut around threaded region; overlap into thread
    nut_center_z = (body_height/2 - thread_height) + nut_thickness/2 - overlap;
    translate([0,0, nut_center_z])
        hex_prism(nut_flat_width, nut_thickness, center=true);
}

module washer() {
    // Washer just below nut; overlap into nut/thread stack
    washer_center_z = (body_height/2 - thread_height) - washer_thickness/2 - overlap;
    translate([0,0, washer_center_z])
        cylinder(r=washer_diameter/2, h=washer_thickness, center=true);
}

module terminal_lug(xoff) {
    // Lugs extend downward from bottom face; overlap into body
    lug_center_z = -body_height/2 - lug_length/2 + overlap;
    translate([xoff, 0, lug_center_z])
        cube([lug_width, lug_thickness, lug_length], center=true);
}

module terminal_lugs() {
    union() {
        terminal_lug(-lug_spacing);
        terminal_lug(0);
        terminal_lug(lug_spacing);
    }
}

module chamfer_top_ring() {
    // Small chamfer ring that overlaps into body
    translate([0,0, body_height/2 - chamfer_height/2 + overlap])
        cylinder(r1=body_diameter/2, r2=max(0.01, body_diameter/2 - chamfer_radial),
                 h=chamfer_height, center=true);
}

module chamfer_bottom_ring() {
    translate([0,0, -body_height/2 + chamfer_height/2 - overlap])
        cylinder(r1=max(0.01, body_diameter/2 - chamfer_radial), r2=body_diameter/2,
                 h=chamfer_height, center=true);
}

module fillets_chamfers() {
    union() {
        chamfer_top_ring();
        chamfer_bottom_ring();
    }
}

module engraved_markings() {
    // Subtractive pocket on side; ensure it intersects body
    // (kept shallow so it doesn't split the solid)
    pocket_depth = body_diameter * 0.25;
    pocket_w = body_diameter * 0.45;
    pocket_h = body_height * 0.25;

    translate([body_diameter/2 - pocket_depth/2 + overlap/2, 0, 0])
        cube([pocket_depth, pocket_w, pocket_h], center=true);
}

// =====================
// Assembly (single connected solid)
// =====================
module complete_model() {
    difference() {
        union() {
            switch_body();
            thread_detail();
            top_bushing_flange();
            lever_pivot_boss();
            toggle_lever();
            mounting_nut();
            washer();
            terminal_lugs();
            fillets_chamfers();
        }
        engraved_markings();
    }
}

complete_model();