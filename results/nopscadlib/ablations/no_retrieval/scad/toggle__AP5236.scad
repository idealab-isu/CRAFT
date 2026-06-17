$fn = 96;

// Toggle switch (simplified) — body is EXACTLY 7.0mm diameter and 13.6mm tall
// Oriented so orthographic FRONT/RIGHT/LEFT show a side profile (body axis along X).

// Parameters
body_diameter = 7.0;   //[3.5:14.0:0.1]
body_height   = 13.6;  //[6.8:27.2:0.1]

overlap = 0.6;         //[0.2:2.0:0.1]

thread_diameter = 6.0; //[3.0:12.0:0.1]
thread_height   = 6.0; //[3.0:12.0:0.1]

nut_outer_diameter = 10.0; //[5.0:20.0:0.1]
nut_thickness      = 2.0;  //[1.0:4.0:0.1]

washer_outer_diameter = 9.0; //[4.5:18.0:0.1]
washer_thickness      = 1.0; //[0.5:2.0:0.1]

lever_diameter   = 2.0;  //[1.0:4.0:0.1]
lever_height     = 12.0; //[6.0:24.0:0.1]
lever_tip_radius = 1.2;  //[0.6:2.4:0.1]
lever_tilt_deg   = 18;   //[0:35:1]

lug_width     = 2.0; //[1.0:4.0:0.1]
lug_thickness = 0.8; //[0.4:1.6:0.1]
lug_length    = 4.0; //[2.0:8.0:0.1]
lug_spacing   = 2.6; //[1.3:5.2:0.1]

flat_depth  = 0.8; //[0.4:1.6:0.1]
flat_height = 6.0; //[3.0:12.0:0.1]

chamfer_height = 0.6; //[0.3:1.2:0.1]

// Derived
body_r   = body_diameter/2;
thread_r = thread_diameter/2;

// --- Geometry helpers (body axis is X; "up" is +Z) ---
module cylX(h, r1, r2, center=true) {
    rotate([0, 90, 0]) cylinder(h=h, r1=r1, r2=r2, center=center);
}
module cylXr(h, r, center=true) {
    cylX(h=h, r1=r, r2=r, center=center);
}

// --- Body (exact 7.0mm dia, 13.6mm long along X) ---
module body_main() {
    cylXr(h=body_height, r=body_r, center=true);
}

module anti_rotation_flat_cutter() {
    // Cut a flat on +Y side (so side views show a flat)
    // Flat plane at y = body_r - flat_depth; cutter must fully intersect body.
    translate([0, body_r - flat_depth + body_diameter/2, 0])
        cube([body_height + 2*overlap, body_diameter, flat_height], center=true);
}

module body_with_flat_and_chamfers() {
    difference() {
        union() {
            body_main();
            // Tiny overlap caps to avoid coincident faces after chamfer subtraction
            translate([ body_height/2 - overlap/2, 0, 0]) cylXr(h=overlap, r=body_r, center=true);
            translate([-body_height/2 + overlap/2, 0, 0]) cylXr(h=overlap, r=body_r, center=true);
        }

        // Flat
        anti_rotation_flat_cutter();

        // Chamfers at both ends (subtract shallow cones), keep overall length unchanged
        translate([ body_height/2 - chamfer_height/2, 0, 0])
            cylX(h=chamfer_height, r1=body_r, r2=max(body_r - chamfer_height, 0.01), center=true);

        translate([-body_height/2 + chamfer_height/2, 0, 0])
            cylX(h=chamfer_height, r1=max(body_r - chamfer_height, 0.01), r2=body_r, center=true);
    }
}

// --- Mounting stack on +X end ---
module mounting_thread() {
    translate([body_height/2 + thread_height/2 - overlap, 0, 0])
        cylXr(h=thread_height, r=thread_r, center=true);
}

module washer() {
    translate([body_height/2 + washer_thickness/2 - overlap, 0, 0])
        cylXr(h=washer_thickness, r=washer_outer_diameter/2, center=true);
}

module panel_nut() {
    translate([body_height/2 + washer_thickness + nut_thickness/2 - overlap, 0, 0])
        cylXr(h=nut_thickness, r=nut_outer_diameter/2, center=true);
}

// --- Toggle lever (tilted) emerging from +X end of thread ---
module toggle_lever_and_tip() {
    // Base point at the +X end of the thread, with slight overlap into thread
    base_x = body_height/2 + thread_height - overlap;

    // Build lever along +Z, then tilt about Y, then place at base_x
    translate([base_x, 0, 0])
        rotate([0, lever_tilt_deg, 0])
            union() {
                // Lever rod
                translate([0, 0, lever_height/2])
                    cylinder(h=lever_height, r=lever_diameter/2, center=true);

                // Tip sphere overlaps rod end
                translate([0, 0, lever_height - lever_tip_radius - overlap/2])
                    sphere(r=lever_tip_radius);
            }
}

// --- Terminal lugs on -X end ---
module terminal_lugs() {
    // Lugs extend from -X end of body; overlap into body for connectivity
    lug_x = -body_height/2 - lug_length/2 + overlap;

    for (z = [-lug_spacing, 0, lug_spacing])
        translate([lug_x, 0, z])
            cube([lug_length, lug_thickness, lug_width], center=true);
}

// --- Complete model (single connected solid) ---
module switch_complete_model() {
    union() {
        body_with_flat_and_chamfers();
        mounting_thread();
        washer();
        panel_nut();
        toggle_lever_and_tip();
        terminal_lugs();
    }
}

// Final Output
switch_complete_model();