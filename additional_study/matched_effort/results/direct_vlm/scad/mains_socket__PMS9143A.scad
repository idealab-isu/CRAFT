$fn=96;

// Screwfix Essential Unswitched UK 1-gang socket (approximate model)
// Units: mm
// One connected solid, no text.

// ---------- Parameters ----------
plate_w = 86;
plate_h = 86;
plate_t = 3.2;

corner_r = 6;

face_recess_w = 70;
face_recess_h = 70;
face_recess_d = 0.9;

inner_bezel_w = 62;
inner_bezel_h = 62;
inner_bezel_d = 0.6;

screw_hole_d = 4.2;
screw_csk_d = 8.6;
screw_csk_h = 1.6;
screw_spacing = 60.3; // UK 1-gang centers

// Socket aperture group placement
ap_center_y = 2; // slight upward bias typical of sockets

// Earth (top) aperture (UK)
earth_w = 7.2;
earth_h = 4.2;
earth_r = 1.2;

// Live/Neutral apertures (UK)
ln_w = 5.4;
ln_h = 14.6;
ln_r = 1.2;
ln_spacing = 22.0; // center-to-center

// Shutter/inner cavity depth (visual)
ap_depth = plate_t + 0.8; // cut through plate

// Back body (rear housing)
back_w = 74;
back_h = 74;
back_t = 22;          // deeper to look like real socket body
back_corner_r = 4;

// Rear features (terminals + cable entry)
term_block_w = 62;
term_block_h = 26;
term_block_t = 7.5;

term_post_w = 10;
term_post_h = 18;
term_post_t = 10;

term_spacing = 18;    // L, E, N spacing across X

cable_entry_w = 22;
cable_entry_h = 12;
cable_entry_t = 6.5;

// Internal socket "insert" (front visible dark cavity)
insert_w = 52;
insert_h = 46;
insert_t = 2.2;
insert_recess = 1.8;
insert_corner_r = 3.0;

// Deeper cavity behind apertures (gives recognizable socket depth)
cavity_depth = 12.0;
cavity_clear = 2.4;

// Shutter hints (visual)
shutter_t = 0.9;
shutter_w = 7.2;
shutter_h = 6.2;
shutter_gap = 0.6;

// Connectivity overlap
ov = 0.25;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module countersunk_hole(d_through, d_csk, h_csk, t){
    union(){
        cylinder(d=d_through, h=t+0.6, center=false);
        translate([0,0,t-h_csk])
            cylinder(d1=d_csk, d2=d_through, h=h_csk+0.6, center=false);
    }
}

module socket_apertures_2d(){
    union(){
        // Earth (top)
        translate([0, 14])
            rounded_rect_2d(earth_w, earth_h, earth_r);

        // Live/Neutral (bottom left/right)
        translate([-ln_spacing/2, -10])
            rounded_rect_2d(ln_w, ln_h, ln_r);
        translate([ ln_spacing/2, -10])
            rounded_rect_2d(ln_w, ln_h, ln_r);
    }
}

module insert_opening_2d(){
    difference(){
        rounded_rect_2d(insert_w, insert_h, insert_corner_r);
        rounded_rect_2d(insert_w-3.2, insert_h-3.2, max(0.6, insert_corner_r-1.2));
    }
}

module faceplate_solid(){
    difference(){
        // main plate
        linear_extrude(height=plate_t)
            rounded_rect_2d(plate_w, plate_h, corner_r);

        // shallow recessed field
        translate([0,0,plate_t-face_recess_d])
            linear_extrude(height=face_recess_d+0.08)
                rounded_rect_2d(face_recess_w, face_recess_h, 4);

        // inner bezel recess
        translate([0,0,plate_t-inner_bezel_d])
            linear_extrude(height=inner_bezel_d+0.08)
                rounded_rect_2d(inner_bezel_w, inner_bezel_h, 3);

        // screw holes (top/bottom)
        for (sy=[-screw_spacing/2, screw_spacing/2]){
            translate([0, sy, 0])
                countersunk_hole(screw_hole_d, screw_csk_d, screw_csk_h, plate_t);
        }

        // UK 3-pin apertures (cut through)
        translate([0, ap_center_y, -0.25])
            linear_extrude(height=ap_depth+0.25)
                socket_apertures_2d();

        // central insert recess (the visible "socket insert" area)
        translate([0, ap_center_y, plate_t - insert_recess])
            linear_extrude(height=insert_recess + 0.08)
                rounded_rect_2d(insert_w, insert_h, insert_corner_r);
    }

    // subtle raised rim around plate
    translate([0,0,plate_t-0.25])
        linear_extrude(height=0.25)
            difference(){
                rounded_rect_2d(plate_w-1.2, plate_h-1.2, corner_r-1);
                rounded_rect_2d(plate_w-3.2, plate_h-3.2, corner_r-2);
            }
}

module insert_lip(){
    // thin lip just behind the faceplate, around the central opening
    translate([0, ap_center_y, plate_t - insert_recess - insert_t + ov])
        linear_extrude(height=insert_t)
            insert_opening_2d();
}

module shutter_hints(){
    // shutter hints: small raised pieces above L/N slots + a top shutter hint under earth
    z0 = plate_t - insert_recess - shutter_t + ov;

    translate([0, ap_center_y, z0])
    linear_extrude(height=shutter_t)
    union(){
        // L/N shutters (two)
        for (sx=[-ln_spacing/2, ln_spacing/2]){
            translate([sx, -2.5])
                difference(){
                    rounded_rect_2d(shutter_w, shutter_h, 1.0);
                    rounded_rect_2d(shutter_gap, shutter_h+0.2, 0.2);
                }
        }
        // Earth shutter hint (small bar just below earth slot)
        translate([0, 10.8])
            rounded_rect_2d(earth_w+2.0, 2.2, 0.8);
    }
}

module back_body_solid(){
    // rear housing with recognizable terminal/cable-entry features
    // Keep as ONE connected solid by overlapping into plate by ov.
    difference(){
        // main rear block
        translate([0,0,-back_t + ov])
            linear_extrude(height=back_t)
                rounded_rect_2d(back_w, back_h, back_corner_r);

        // deeper cavity behind apertures (starts just behind plate)
        translate([0, ap_center_y, -cavity_depth])
            linear_extrude(height=cavity_depth + 0.8)
                offset(r=cavity_clear)
                    socket_apertures_2d();

        // clearance pocket behind central insert opening
        pocket_d = 8.0;
        translate([0, ap_center_y, -pocket_d])
            linear_extrude(height=pocket_d + 0.6)
                rounded_rect_2d(insert_w-5.0, insert_h-5.0, max(1.2, insert_corner_r-1.0));

        // screw boss clearances (through rear block)
        for (sy=[-screw_spacing/2, screw_spacing/2]){
            translate([0, sy, -back_t])
                cylinder(d=8.0, h=back_t+0.8);
        }

        // rear cable entry recess (bottom center)
        // (a recessed "mouth" rather than a through hole)
        cable_y = -back_h/2 + cable_entry_h/2 + 3.0;
        translate([0, cable_y, -back_t + (cable_entry_t)])
            linear_extrude(height=back_t)  // ensure it cuts from rear face inward
                rounded_rect_2d(cable_entry_w, cable_entry_h, 2.2);
    }

    // Add raised terminal block + three terminal posts (L/E/N) on rear face
    // These are solids (not cut), connected to the rear block.
    rear_face_z = -back_t + ov; // start of rear block extrusion
    // terminal block sits on the rear face (more negative Z)
    translate([0, 10, rear_face_z - term_block_t + ov])
        linear_extrude(height=term_block_t)
            rounded_rect_2d(term_block_w, term_block_h, 2.5);

    // terminal posts protrude further back, connected to terminal block
    for (i=[-1,0,1]){
        translate([i*term_spacing, 10, rear_face_z - term_block_t - term_post_t + ov])
            linear_extrude(height=term_post_t)
                rounded_rect_2d(term_post_w, term_post_h, 2.0);
    }

    // cable clamp bulge (rear bottom), connected to rear block
    clamp_y = -back_h/2 + 16;
    clamp_w = 34;
    clamp_h = 18;
    clamp_t = 6.0;
    translate([0, clamp_y, rear_face_z - clamp_t + ov])
        linear_extrude(height=clamp_t)
            rounded_rect_2d(clamp_w, clamp_h, 3.0);
}

module screw_heads_connected(){
    // decorative screw heads (still one solid) overlapping into plate
    for (sy=[-screw_spacing/2, screw_spacing/2]){
        translate([0, sy, plate_t-0.2])
            cylinder(d=7.8, h=1.2);
        translate([0, sy, plate_t+0.9 - ov])
            cylinder(d=4.2, h=0.6);
    }
}

// ---------- Assembly (ONE connected solid) ----------
union(){
    faceplate_solid();
    insert_lip();
    shutter_hints();
    back_body_solid();
    screw_heads_connected();
}