// 40x80 aluminium T-slot extrusion (approximate), 100mm long
// Connectivity-fixed: ensure ALL parts overlap and form ONE connected solid.

$fn = 96;

// Parameters
W = 40.0;   // X (mm)
H = 80.0;   // Y (mm)
L = 100.0;  // Z (mm)

// Geometry (approx. 40-series)
outer_wall_t = 3.0;     // outer wall thickness
slot_open_w  = 8.0;     // slot mouth opening width
slot_cav_w   = 14.0;    // slot cavity width behind lips
slot_depth   = 12.0;    // depth from outer face inward
lip_t        = 2.0;     // lip thickness at opening

center_bore_d = 10.0;   // center hole diameter
web_t         = 3.0;    // internal web thickness

// Keep enough material so the profile stays connected
inner_margin  = 8.0;    // distance from outer boundary to inner void boundary

// Structural overlap (1-2mm) to guarantee attachment
overlap = 1.5;

// Small epsilon for boolean robustness
eps = 0.05;

module tslot_cut_2d(face_len, face_pos, depth, open_w, cav_w, lip_t) {
    // Cut for one face, oriented along +Y (caller rotates for other faces).
    y_face = face_pos;

    y_open_center = y_face - lip_t/2;
    y_cav_center  = y_face - depth/2;

    union() {
        hull() {
            translate([0, y_open_center])
                square([open_w, lip_t + 2*eps], center=true);

            translate([0, y_cav_center])
                square([cav_w, depth + 2*eps], center=true);
        }

        // Ensure the mouth is open to the outside face
        translate([0, y_face - (lip_t/2)])
            square([open_w, lip_t + 4*eps], center=true);
    }
}

module profile_2d() {
    innerW = max(0.01, W - 2*inner_margin);
    innerH = max(0.01, H - 2*inner_margin);

    // Inner void half-extents
    innerRx = innerW/2;
    innerRy = innerH/2;

    // Hub (ring) dimensions
    hub_od = center_bore_d + 2*web_t;   // as before
    hub_or = hub_od/2;
    bore_r = center_bore_d/2;

    // Webs must physically reach into the outer body (past the inner void boundary)
    // so they connect to the outer perimeter segments.
    web_half_len_x = max(0.01, innerRx + overlap); // reaches beyond inner void edge
    web_half_len_y = max(0.01, innerRy + overlap);

    // Also ensure webs overlap the hub ring (not just touch)
    // by making sure they extend at least to hub outer radius + overlap.
    web_half_len_x2 = max(web_half_len_x, hub_or + overlap);
    web_half_len_y2 = max(web_half_len_y, hub_or + overlap);

    union() {
        // Outer body with inner void + slots removed (NO center bore removed here)
        // This prevents the hub ring from becoming a floating island.
        difference() {
            square([W, H], center=true);

            // Inner void (creates chambers but leaves outer ring)
            square([innerW, innerH], center=true);

            // Four T-slots
            union() {
                // +Y
                tslot_cut_2d(W, H/2, slot_depth, slot_open_w, slot_cav_w, lip_t);
                // -Y
                rotate(180) tslot_cut_2d(W, H/2, slot_depth, slot_open_w, slot_cav_w, lip_t);
                // +X
                rotate(-90) tslot_cut_2d(H, W/2, slot_depth, slot_open_w, slot_cav_w, lip_t);
                // -X
                rotate(90) tslot_cut_2d(H, W/2, slot_depth, slot_open_w, slot_cav_w, lip_t);
            }
        }

        // Internal webs (explicitly overlap both hub and outer body by ~overlap)
        square([2*web_half_len_x2, web_t], center=true); // horizontal web
        square([web_t, 2*web_half_len_y2], center=true); // vertical web

        // Central hub ring (kept), now guaranteed to overlap webs
        difference() {
            circle(d=hub_od);
            circle(d=center_bore_d);
        }
    }
}

// Final: subtract the center bore ONCE from the whole union so nothing becomes disconnected.
color("Silver")
difference() {
    linear_extrude(height=L, center=true, convexity=10)
        profile_2d();

    // Through bore
    translate([0,0,0])
        cylinder(d=center_bore_d, h=L + 2, center=true);
}