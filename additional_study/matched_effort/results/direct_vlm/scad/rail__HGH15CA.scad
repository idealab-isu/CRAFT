$fn = 96;

// Miniature linear guide rail
// Overall envelope: 15mm wide (X) x 15mm tall (Z) x 100mm long (Y)

w = 15.0;   // width (X)
h = 15.0;   // height (Z)
L = 100.0;  // length (Y)

// Profile details (kept within 15x15 envelope)
side_step_h      = 3.0;   // bottom step height
side_step_inset  = 1.5;   // inset per side at the step
top_flat         = 9.0;   // top flat width
top_chamfer      = 1.0;   // top edge chamfer

// Raceway grooves (visual detail, shallow)
race_r = 1.2;             // groove radius
race_depth = 0.8;         // how far groove cuts into side
race_z = h*0.62;          // groove center height

// Mounting holes (through + counterbore)
hole_d = 4.2;
cbo_d  = 7.5;
cbo_h  = 2.0;
hole_pitch = 25.0;
hole_edge_offset = 12.5;  // from each end along Y

eps = 0.02;

module rail_profile_2d() {
    // X-Z polygon, centered on X=0, bottom at Z=0
    polygon(points=[
        [-w/2, 0],
        [ w/2, 0],
        [ w/2, side_step_h],
        [ w/2 - side_step_inset, side_step_h],
        [ w/2 - side_step_inset, h - top_chamfer],
        [ top_flat/2 + top_chamfer, h - top_chamfer],
        [ top_flat/2, h],
        [-top_flat/2, h],
        [-top_flat/2 - top_chamfer, h - top_chamfer],
        [-w/2 + side_step_inset, h - top_chamfer],
        [-w/2 + side_step_inset, side_step_h],
        [-w/2, side_step_h]
    ]);
}

module rail_body() {
    // Correct orientation: extrude along Y directly (no rotate that collapses/offsets)
    translate([0, 0, 0])
        linear_extrude(height=L, center=false, convexity=10)
            rail_profile_2d();
}

module hole_stack_at(ypos) {
    // Drill along Z (vertical). Rail occupies Y in [0..L], so ypos is direct.
    translate([0, ypos, 0])
    union() {
        // Through hole (slightly extended for clean boolean)
        translate([0, 0, -1])
            cylinder(d=hole_d, h=h+2, center=false);

        // Counterbore from top
        translate([0, 0, h - cbo_h])
            cylinder(d=cbo_d, h=cbo_h + 1, center=false);
    }
}

module all_holes() {
    for (ypos = [hole_edge_offset : hole_pitch : (L - hole_edge_offset + 1e-6)])
        hole_stack_at(ypos);
}

module raceways() {
    // Two shallow side grooves running full length (visual raceways)
    // Cylinder axis along Y: rotate X by 90, then place at side faces and correct Z.
    for (sx = [-1, 1]) {
        translate([ sx*(w/2 - race_depth), 0, race_z ])
            rotate([90,0,0])
                cylinder(r=race_r, h=L, center=false);
    }
}

difference() {
    rail_body();
    all_holes();
    raceways();
}