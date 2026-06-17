$fn = 96;

// UK 1-gang BS1363 unswitched socket (Screwfix Essential style) - simplified but recognisable
// Coordinate system: plate centered at origin; front face is +Z

// Faceplate
plate_w = 86;
plate_h = 86;
plate_t = 7;
edge_r  = 2.2;

// Front recessed "inner panel"
front_recess_depth  = 1.2;
front_recess_margin = 10;
front_recess_r      = 1.6;

// Raised central boss around apertures (common on budget plates)
boss_raise   = 0.9;
boss_margin  = 18;
boss_r       = 2.0;

// Screw holes (BS 4662 style)
screw_hole_d      = 3.6;
screw_cbore_d     = 7.2;
screw_cbore_depth = 2.2;
screw_spacing     = 60;   // horizontal spacing

// BS1363 aperture layout (approx)
earth_slot_w = 6.2;
earth_slot_h = 14.0;

pin_slot_w   = 6.2;
pin_slot_h   = 14.0;
pin_spacing  = 22.2;  // L-N center spacing
pin_y_offset = 12.7;  // earth center above L/N centers

// Safety shutter hint (small rectangular recesses behind L/N)
shutter_w = 10.5;
shutter_h = 8.0;
shutter_depth = 0.8;

// Rear housing (socket body)
rear_w       = 74;
rear_h       = 74;
rear_depth   = 28;
rear_corner_r = 3.0;

// Rear cavity
wall = 2.4;

// Rear terminal bulges (approx)
term_w = 18;
term_h = 16;
term_depth = 10;
term_inset_from_back = 2;

// Cable entry / strain relief bump (bottom rear)
entry_w = 26;
entry_h = 14;
entry_depth = 8;
entry_r = 2.0;

// Small overlap to ensure watertight unions
ov = 0.6;

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r = r2);
    }
}

module rounded_box(w, h, t, r, center=true) {
    // Extrude along +Z from z=0, then optionally center
    if (center)
        translate([0,0,-t/2])
            linear_extrude(height=t) rounded_rect_2d(w,h,r);
    else
        linear_extrude(height=t) rounded_rect_2d(w,h,r);
}

module slot_cut(w, h, depth) {
    // Rounded-ended slot, extruded along +Z from z=0
    linear_extrude(height = depth)
        hull() {
            translate([-(w/2 - h/2), 0]) circle(d = h);
            translate([ +(w/2 - h/2), 0]) circle(d = h);
        }
}

module faceplate_solid() {
    // Plate centered at origin
    rounded_box(plate_w, plate_h, plate_t, edge_r, center=true);
}

module front_recess_cut() {
    recess_w = plate_w - 2*front_recess_margin;
    recess_h = plate_h - 2*front_recess_margin;

    // Cut into front face
    translate([0, 0, plate_t/2 - front_recess_depth])
        linear_extrude(height = front_recess_depth + ov)
            rounded_rect_2d(recess_w, recess_h, front_recess_r);
}

module boss_solid() {
    boss_w = plate_w - 2*boss_margin;
    boss_h = plate_h - 2*boss_margin;

    // Raised boss sits on front face and overlaps slightly for union robustness
    translate([0, 0, plate_t/2 - ov/2])
        linear_extrude(height = boss_raise + ov)
            rounded_rect_2d(boss_w, boss_h, boss_r);
}

module screw_holes_cut() {
    for (sx = [-1, 1]) {
        x = sx * screw_spacing/2;

        // Through hole
        translate([x, 0, -plate_t/2 - ov/2])
            cylinder(h = plate_t + ov, d = screw_hole_d);

        // Counterbore from front
        translate([x, 0, plate_t/2 - screw_cbore_depth])
            cylinder(h = screw_cbore_depth + ov, d = screw_cbore_d);
    }
}

module bs1363_apertures_cut() {
    // Earth slot (vertical)
    translate([0, pin_y_offset, -plate_t/2 - ov/2])
        slot_cut(earth_slot_w, earth_slot_h, plate_t + ov);

    // Live and Neutral slots (vertical)
    for (sx = [-1, 1]) {
        translate([sx * pin_spacing/2, 0, -plate_t/2 - ov/2])
            slot_cut(pin_slot_w, pin_slot_h, plate_t + ov);
    }
}

module shutter_recess_cut() {
    // Small shallow recesses on the front around L/N (visual detail)
    for (sx = [-1, 1]) {
        translate([sx * pin_spacing/2, 0, plate_t/2 - shutter_depth])
            linear_extrude(height = shutter_depth + ov)
                rounded_rect_2d(shutter_w, shutter_h, 1.2);
    }
}

module rear_housing_solid() {
    // Rear body attached to back of plate; overlap into plate by ov
    z_center = -(plate_t/2 + rear_depth/2 - ov);
    translate([0, 0, z_center])
        rounded_box(rear_w, rear_h, rear_depth, rear_corner_r, center=true);
}

module rear_housing_cavity_cut() {
    inner_w = rear_w - 2*wall;
    inner_h = rear_h - 2*wall;
    inner_d = rear_depth - wall; // leave back thickness = wall

    z_center_outer = -(plate_t/2 + rear_depth/2 - ov);

    // Place inner cavity so it leaves a back wall of thickness 'wall'
    // Outer back face Z = z_center_outer - rear_depth/2
    // Inner back face Z should be outer back face + wall
    outer_back_z = z_center_outer - rear_depth/2;
    inner_back_z = outer_back_z + wall;
    inner_center_z = inner_back_z + inner_d/2;

    translate([0, 0, inner_center_z])
        rounded_box(inner_w, inner_h, inner_d + ov, max(0.1, rear_corner_r - 1.2), center=true);
}

module terminal_bulges_solid() {
    // Connected protrusions on rear, near back face
    z_center_outer = -(plate_t/2 + rear_depth/2 - ov);
    outer_back_z = z_center_outer - rear_depth/2;

    // Bulges extend outward beyond back face; ensure overlap into housing by ov
    z_center = outer_back_z - term_depth/2 + (term_inset_from_back + ov);

    // Earth terminal
    translate([0, pin_y_offset, z_center])
        rounded_box(term_w, term_h, term_depth, 1.5, center=true);

    // L and N terminals
    for (sx = [-1, 1]) {
        translate([sx * pin_spacing/2, 0, z_center])
            rounded_box(term_w, term_h, term_depth, 1.5, center=true);
    }
}

module cable_entry_bump_solid() {
    // Bottom rear bump (common on socket bodies)
    z_center_outer = -(plate_t/2 + rear_depth/2 - ov);
    outer_back_z = z_center_outer - rear_depth/2;

    // Place centered near bottom edge of rear housing, protruding from back
    y = -(rear_h/2 - entry_h/2 - 6);
    z = outer_back_z - entry_depth/2 + (2 + ov);

    translate([0, y, z])
        rounded_box(entry_w, entry_h, entry_depth, entry_r, center=true);
}

module mains_socket() {
    difference() {
        union() {
            faceplate_solid();
            boss_solid();
            rear_housing_solid();
            terminal_bulges_solid();
            cable_entry_bump_solid();
        }

        // Front details
        front_recess_cut();
        screw_holes_cut();
        shutter_recess_cut();
        bs1363_apertures_cut();

        // Rear cavity
        rear_housing_cavity_cut();
    }
}

mains_socket();