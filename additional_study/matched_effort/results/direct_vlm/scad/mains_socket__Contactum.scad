$fn=96;

// Old-style unswitched mains socket (generic)
// Units: mm

// ---------- Parameters ----------
plate_w = 86;
plate_h = 86;
plate_t = 3.2;

corner_r = 6;
face_bevel = 0.7;     // subtle edge bevel

// Raised inner surround (older look)
surround_w = 58;
surround_h = 58;
surround_r = 4.5;
surround_raise = 1.2;     // protrudes from face
surround_inset = 1.0;     // inset from plate edge (visual step)

// Central recess (where socket aperture sits)
socket_recess_w = 54;
socket_recess_h = 54;
socket_recess_depth = 1.6;
socket_corner_r = 4;

// Screw holes
screw_head_d = 8.5;
screw_shaft_d = 4.2;
screw_csk_depth = 1.6;
screw_offset_x = 0;
screw_offset_y = 28;

// Pin slots (UK-ish layout)
pin_slot_w = 6.6;
pin_slot_h = 18.5;
pin_slot_depth = 2.8;

earth_slot_w = 7.2;
earth_slot_h = 12.0;
earth_slot_depth = 2.8;

pin_spacing = 22.2;   // center-to-center between live/neutral
pin_y = -6.0;         // vertical position of live/neutral slots
earth_y = 14.0;       // vertical position of earth slot

// Shutter/guide recesses (old style visual detail)
guide_depth = 0.9;
guide_w = 12;
guide_h = 22;

// Back body
body_w = 70;
body_h = 70;
body_t = 18;
body_r = 5;
lip = 1.2;

// Terminal block features (rear detail)
term_block_w = 56;
term_block_h = 22;
term_block_t = 6;
term_block_r = 2.5;

term_post_d = 6.5;
term_post_h = 5.0;
term_post_spacing = 18.0; // L / E / N spacing
term_post_y = 10.0;       // position within backbox

cable_entry_d = 10.0;
cable_entry_h = 6.0;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module rounded_box(w,h,t,r,center=false){
    linear_extrude(height=t, center=center)
        rounded_rect_2d(w,h,r);
}

module countersunk_hole(thickness, shaft_d, head_d, csk_depth){
    // Through shaft
    translate([0,0,-0.2])
        cylinder(h=thickness+0.4, d=shaft_d);
    // Countersink from front
    translate([0,0,thickness-csk_depth])
        cylinder(h=csk_depth+0.25, d1=head_d, d2=shaft_d);
}

module slot(w,h,depth,r=1.2){
    translate([0,0,-0.2])
        linear_extrude(height=depth+0.4)
            rounded_rect_2d(w,h,r);
}

// ---------- Parts ----------
module faceplate_solid(){
    // Base plate with light bevel
    minkowski(){
        rounded_box(plate_w-2*face_bevel, plate_h-2*face_bevel, plate_t-face_bevel, corner_r-face_bevel);
        sphere(r=face_bevel);
    }
}

module surround_solid(){
    // Raised surround ring (adds recognizable face detail)
    translate([0,0,plate_t - surround_inset])
        difference(){
            rounded_box(surround_w, surround_h, surround_raise, surround_r);
            // inner opening (leave a ring)
            translate([0,0,-0.2])
                rounded_box(socket_recess_w+2.0, socket_recess_h+2.0, surround_raise+0.4, socket_corner_r);
        }
}

module faceplate_with_details(){
    difference(){
        union(){
            faceplate_solid();
            surround_solid();
        }

        // Central recess for socket body (inside surround)
        translate([0,0,plate_t-socket_recess_depth])
            linear_extrude(height=socket_recess_depth+0.25)
                rounded_rect_2d(socket_recess_w, socket_recess_h, socket_corner_r);

        // Screw holes (top and bottom)
        translate([screw_offset_x, screw_offset_y, 0])
            countersunk_hole(plate_t, screw_shaft_d, screw_head_d, screw_csk_depth);
        translate([screw_offset_x, -screw_offset_y, 0])
            countersunk_hole(plate_t, screw_shaft_d, screw_head_d, screw_csk_depth);

        // Pin slots (deeper so orthographic views show them)
        translate([ pin_spacing/2, pin_y, plate_t-pin_slot_depth])
            slot(pin_slot_w, pin_slot_h, pin_slot_depth, r=1.4);
        translate([-pin_spacing/2, pin_y, plate_t-pin_slot_depth])
            slot(pin_slot_w, pin_slot_h, pin_slot_depth, r=1.4);

        translate([0, earth_y, plate_t-earth_slot_depth])
            slot(earth_slot_w, earth_slot_h, earth_slot_depth, r=1.4);

        // Guide/shutter recesses around L/N (visual detail)
        translate([ pin_spacing/2, pin_y, plate_t-guide_depth])
            slot(guide_w, guide_h, guide_depth, r=2.0);
        translate([-pin_spacing/2, pin_y, plate_t-guide_depth])
            slot(guide_w, guide_h, guide_depth, r=2.0);

        // Earth guide recess
        translate([0, earth_y, plate_t-guide_depth])
            slot(guide_w, guide_h-6, guide_depth, r=2.0);

        // Small keying notch above earth (older style cue)
        translate([0, earth_y + (earth_slot_h/2 + 6), plate_t-1.2])
            slot(18, 2.2, 1.2, r=1.0);
    }
}

module terminal_block_connected(){
    // Rear terminal block + posts, connected to backbox interior (no floating parts)
    // Place near rear face of backbox, with slight overlap into backbox wall.
    overlap = 0.6;

    // Backbox spans z in [-body_t+overlap, overlap] approximately (see backbox module).
    // Put terminal block close to the rear (more negative z).
    z_rear_inner = -body_t + 2.0; // inside, near rear
    z_block_center = z_rear_inner + term_block_t/2;

    union(){
        // Block body
        translate([0, term_post_y, z_block_center])
            rounded_box(term_block_w, term_block_h, term_block_t, term_block_r, center=true);

        // Three terminal posts (L/E/N)
        for (x = [-term_post_spacing, 0, term_post_spacing]){
            translate([x, term_post_y, z_block_center + term_block_t/2 + term_post_h/2 - overlap/2])
                cylinder(h=term_post_h+overlap, d=term_post_d, center=true);
        }

        // Cable entry boss (rear)
        translate([0, term_post_y - term_block_h/2 - 2.0, z_rear_inner + cable_entry_h/2 - overlap/2])
            cylinder(h=cable_entry_h+overlap, d=cable_entry_d, center=true);
    }
}

module backbox_stub_connected(){
    // Back body attached to rear of plate with slight overlap for watertight union
    overlap = 0.6;

    difference(){
        // Outer body (top meets underside of plate at z=0 with overlap)
        translate([0,0,-(body_t/2) + overlap/2])
            rounded_box(body_w, body_h, body_t+overlap, body_r, center=true);

        // Hollow interior (leave walls)
        translate([0,0,-(body_t/2) + overlap/2 + lip/2])
            rounded_box(body_w-2*lip, body_h-2*lip, body_t+overlap, max(body_r-1,0.1), center=true);

        // Clearance behind pin area (cylindrical pocket)
        clear_d = 44;
        clear_h = body_t - 2.0;
        translate([0,0,-(clear_h/2) + overlap/2])
            cylinder(h=clear_h+0.4, d=clear_d, center=true);

        // Add rear "wire entry" opening (hole) to make it read like a socket back
        // Cut from rear face inward.
        entry_d = 12.0;
        entry_h = 8.0;
        z_rear = -body_t + overlap/2; // near rear face
        translate([0, -body_h/2 + 10.0, z_rear + entry_h/2])
            cylinder(h=entry_h+0.4, d=entry_d, center=true);
    }

    // Add terminal block detail as positive geometry (still one connected solid)
    terminal_block_connected();
}

// ---------- Model (ONE connected solid) ----------
module mains_socket_old_unswitched(){
    union(){
        faceplate_with_details();
        backbox_stub_connected();
    }
}

// ---------- Render ----------
mains_socket_old_unswitched();