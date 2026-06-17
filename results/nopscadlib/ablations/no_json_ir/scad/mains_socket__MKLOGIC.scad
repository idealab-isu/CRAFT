// UK 13A Mains Wall Socket Faceplate (Switched) - single connected solid
// No text/labels. One connected manifold solid.

$fn = 72;

// ---------- Parameters (approximate UK 2G switched socket proportions) ----------
faceplate_width     = 146;
faceplate_height    = 86;
faceplate_thickness = 7;

edge_radius = 3;

// Front border recess
front_recess_depth  = 0.9;
front_recess_margin = 6;

// Mounting holes
mounting_hole_diameter            = 4;
mounting_hole_countersink_diameter= 8;
mounting_hole_spacing             = 120;

// Socket layout
socket_center_spacing = 60;   // between left/right socket centers (x)
socket_y              = -6;   // sockets slightly lower than center

socket_recess_w     = 44;
socket_recess_h     = 36;
socket_recess_depth = 1.2;

// UK pin apertures
pin_slot_w     = 6.2;
pin_slot_h     = 14.5;
pin_slot_depth = 3.2;

earth_slot_w     = 7.2;
earth_slot_h     = 16.5;
earth_slot_depth = 3.2;

pin_hole_spacing = 22;  // L/N spacing
earth_pin_offset = 12;  // earth above L/N

// Switch (single central rocker above sockets)
switch_offset_x = 0;
switch_offset_y = 22;

switch_bezel_w     = 34;
switch_bezel_h     = 18;
switch_bezel_depth = 1.2;

switch_w     = 28;
switch_h     = 14;
switch_depth = 2.6;

// Small overlap for watertight unions/differences
overlap = 0.25;

// ---------- Helpers ----------
module rounded_plate(w, h, t, r) {
    linear_extrude(height = t, center = true)
        offset(r = r)
            square([max(0.01, w - 2*r), max(0.01, h - 2*r)], center = true);
}

module rounded_rect_cut(w, h, d, r) {
    linear_extrude(height = d, center = true)
        offset(r = r)
            square([max(0.01, w - 2*r), max(0.01, h - 2*r)], center = true);
}

module slot_cut(w, h, d) {
    // Capsule slot: offset a rectangle by radius = min(w,h)/2
    rr = min(w, h)/2;
    linear_extrude(height = d, center = true)
        offset(r = rr)
            square([max(0.01, w - 2*rr), max(0.01, h - 2*rr)], center = true);
}

// ---------- Main solids ----------
module faceplate_body() {
    rounded_plate(faceplate_width, faceplate_height, faceplate_thickness, edge_radius);
}

module switch_bezel_solid() {
    // Protruding bezel, connected to faceplate with slight overlap
    translate([switch_offset_x, switch_offset_y,
               faceplate_thickness/2 + switch_bezel_depth/2 - overlap/2])
        rounded_plate(switch_bezel_w, switch_bezel_h, switch_bezel_depth + overlap, 2);
}

module switch_rocker_solid() {
    // Rocker protrusion inside bezel, connected with overlap
    translate([switch_offset_x, switch_offset_y,
               faceplate_thickness/2 + switch_depth/2 - overlap/2])
        rounded_plate(switch_w, switch_h, switch_depth + overlap, 1.6);
}

// ---------- Cuts / details ----------
module front_detail_recess() {
    translate([0, 0, faceplate_thickness/2 - front_recess_depth/2 + overlap/2])
        rounded_rect_cut(faceplate_width - 2*front_recess_margin,
                         faceplate_height - 2*front_recess_margin,
                         front_recess_depth + overlap,
                         max(0.5, edge_radius - 1));
}

module mounting_holes() {
    for (x = [-mounting_hole_spacing/2, mounting_hole_spacing/2]) {
        // Through hole
        translate([x, 0, 0])
            cylinder(h = faceplate_thickness + 2*overlap,
                     d = mounting_hole_diameter, center = true);

        // Front counterbore/countersink suggestion
        translate([x, 0,
                   faceplate_thickness/2 - (faceplate_thickness/2)/2 + overlap/2])
            cylinder(h = faceplate_thickness/2 + overlap,
                     d = mounting_hole_countersink_diameter, center = true);
    }
}

module socket_recess_at(xc, yc) {
    translate([xc, yc, faceplate_thickness/2 - socket_recess_depth/2 + overlap/2])
        rounded_rect_cut(socket_recess_w, socket_recess_h,
                         socket_recess_depth + overlap, 2.2);
}

module uk_pin_apertures_at(xc, yc) {
    // L/N vertical slots
    for (sx = [-pin_hole_spacing/2, pin_hole_spacing/2]) {
        translate([xc + sx, yc,
                   faceplate_thickness/2 - pin_slot_depth/2 + overlap/2])
            slot_cut(pin_slot_w, pin_slot_h, pin_slot_depth + overlap);
    }
    // Earth slot above
    translate([xc, yc + earth_pin_offset,
               faceplate_thickness/2 - earth_slot_depth/2 + overlap/2])
        slot_cut(earth_slot_w, earth_slot_h, earth_slot_depth + overlap);
}

module switch_groove_cut() {
    // Shallow groove across rocker (horizontal line)
    groove_w = switch_w - 6;
    groove_h = 2.0;
    groove_d = 0.8;

    translate([switch_offset_x, switch_offset_y,
               faceplate_thickness/2 + switch_depth - groove_d/2])
        rounded_rect_cut(groove_w, groove_h, groove_d + overlap, 0.9);
}

module rear_cavity_cut() {
    // Rear relief: keep a rim so the part remains one connected solid
    rim = 10;
    cavity_depth = faceplate_thickness - 2.2; // leave ~2.2mm front skin
    translate([0, 0, -faceplate_thickness/2 + cavity_depth/2 - overlap/2])
        rounded_rect_cut(faceplate_width - 2*rim,
                         faceplate_height - 2*rim,
                         cavity_depth + overlap,
                         max(0.5, edge_radius - 1));
}

// ---------- Assembly ----------
module mains_socket_switched() {
    difference() {
        union() {
            faceplate_body();
            switch_bezel_solid();
            switch_rocker_solid();
        }

        // Front border recess
        front_detail_recess();

        // Two socket recesses + UK pin apertures
        for (xc = [-socket_center_spacing/2, socket_center_spacing/2]) {
            socket_recess_at(xc, socket_y);
            uk_pin_apertures_at(xc, socket_y);
        }

        // Mounting holes
        mounting_holes();

        // Switch groove detail
        switch_groove_cut();

        // Rear cavity
        rear_cavity_cut();
    }
}

mains_socket_switched();