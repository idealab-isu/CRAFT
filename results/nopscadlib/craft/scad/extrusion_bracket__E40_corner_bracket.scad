$fn = 64;

// Target overall bracket envelope: [40,40,35]
footprint_x = 40;                 // X size of bracket footprint
footprint_y = 40;                 // Y size of bracket footprint
height_z     = 35;                // Z height of vertical legs

plate_thickness = 6;              // base plate thickness (Z)
leg_thickness   = 4;              // thickness of each vertical leg (in Y for X-leg, in X for Y-leg)

hole_d = 5.5;                     // through hole diameter
hole_edge_margin = 10;            // distance from outer edges to hole centers
hole_z_1 = 12;                    // hole heights on legs
hole_z_2 = 26;

inner_relief_r = 3;               // inside corner relief radius

// Use a real overlap for guaranteed physical attachment (1-2mm as required)
overlap = 1.5;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module base_plate() {
    // Base plate centered at origin, spanning Z=[0..plate_thickness]
    translate([0,0,plate_thickness/2])
        linear_extrude(height=plate_thickness, center=true)
            rounded_rect_2d(footprint_x, footprint_y, 1.5);
}

module vertical_leg_along_x() {
    // Leg runs along X, located at outer -Y edge
    // Overlap into base by 'overlap' to guarantee connection
    translate([0,
               -footprint_y/2 + leg_thickness/2,
               plate_thickness + height_z/2 - overlap])
        cube([footprint_x, leg_thickness, height_z], center=true);
}

module vertical_leg_along_y() {
    // Leg runs along Y, located at outer -X edge
    // Overlap into base by 'overlap' to guarantee connection
    translate([-footprint_x/2 + leg_thickness/2,
               0,
               plate_thickness + height_z/2 - overlap])
        cube([leg_thickness, footprint_y, height_z], center=true);
}

// --- FIX: ensure the orange cylindrical pin/knob is physically attached (no air gap) ---
module pin_knob() {
    // Oriented along +X, attached to the inside corner region (-X/-Y).
    // Guarantee intersection with BOTH legs by pushing the cylinder center
    // slightly into the corner by 'overlap'.
    pin_d   = 10;
    pin_len = 14;

    // Inside faces of the legs:
    // Y-leg spans X in [-footprint_x/2 .. -footprint_x/2 + leg_thickness]
    // X-leg spans Y in [-footprint_y/2 .. -footprint_y/2 + leg_thickness]
    x_inside_face = -footprint_x/2 + leg_thickness;
    y_inside_face = -footprint_y/2 + leg_thickness;

    // Place the pin so its -X end is embedded into the Y-leg by 'overlap'
    // (i.e., x_min = x_inside_face - overlap).
    x_center = x_inside_face - overlap + pin_len/2;

    // Place the pin so it intersects the X-leg by 'overlap' in Y
    // (i.e., y_min = y_inside_face - overlap).
    y_center = y_inside_face - overlap + pin_d/2;

    // Sit on the base and intersect it slightly (avoid any Z gap)
    z_center = plate_thickness + pin_d/2 - overlap;

    translate([x_center, y_center, z_center])
        rotate([0,90,0])
            cylinder(d=pin_d, h=pin_len, center=true);
}

module bracket_solid() {
    union() {
        base_plate();
        vertical_leg_along_x();
        vertical_leg_along_y();
        pin_knob();   // attached feature (no floating)
    }
}

module inner_corner_relief() {
    // Remove a quarter-cylinder at the inside corner where the two legs meet
    translate([
        -footprint_x/2 + leg_thickness,
        -footprint_y/2 + leg_thickness,
        plate_thickness + height_z/2
    ])
    cylinder(r=inner_relief_r, h=height_z + 2*overlap, center=true);
}

module leg_holes() {
    // Two holes on each leg (4 total), centered in leg thickness, offset from outer edges
    // X-leg (at -Y): holes go through Y (rotate about X)
    for (xpos = [-footprint_x/2 + hole_edge_margin, footprint_x/2 - hole_edge_margin])
        for (zpos = [hole_z_1, hole_z_2])
            translate([xpos, -footprint_y/2 + leg_thickness/2, plate_thickness + zpos])
                rotate([90,0,0])
                    cylinder(d=hole_d, h=leg_thickness + 2*overlap, center=true);

    // Y-leg (at -X): holes go through X (rotate about Y)
    for (ypos = [-footprint_y/2 + hole_edge_margin, footprint_y/2 - hole_edge_margin])
        for (zpos = [hole_z_1, hole_z_2])
            translate([-footprint_x/2 + leg_thickness/2, ypos, plate_thickness + zpos])
                rotate([0,90,0])
                    cylinder(d=hole_d, h=leg_thickness + 2*overlap, center=true);
}

module base_holes() {
    // Two mounting holes in base plate (typical corner bracket pattern)
    for (p = [
        [ footprint_x/2 - hole_edge_margin, 0],
        [ 0, footprint_y/2 - hole_edge_margin]
    ])
        translate([p[0], p[1], plate_thickness/2])
            cylinder(d=hole_d, h=plate_thickness + 2*overlap, center=true);
}

// ---------- Final: ONE connected solid bracket ----------
difference() {
    bracket_solid();
    inner_corner_relief();
    leg_holes();
    base_holes();
}