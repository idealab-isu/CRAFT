$fn=96;

// Simple UK-style switched mains socket faceplate (approximate)
// Units: mm

// ---------- Parameters ----------
plate_w = 146;
plate_h = 86;
plate_t = 6;

corner_r = 6;

backbox_recess_t = 2.0;     // shallow recess on back
backbox_recess_margin = 8;

screw_hole_d = 4.2;
screw_csk_d = 8.5;
screw_csk_h = 2.2;
screw_offset_y = 28;        // from center

// Socket apertures (approx)
socket_center_x = -22;      // left socket center
socket2_center_x = 22;      // right socket center
socket_center_y = -2;

socket_ap_w = 36;
socket_ap_h = 28;
socket_ap_r = 3;

earth_slot_w = 6.5;
earth_slot_h = 12.5;

live_slot_w = 6.0;
live_slot_h = 16.0;
live_slot_dx = 9.5;
live_slot_dy = -4.0;

earth_slot_dy = 6.0;

// Switch (right side)
switch_center_x = 52;
switch_center_y = 0;
switch_body_w = 28;
switch_body_h = 18;
switch_body_r = 3;
switch_body_t = 3.0;

rocker_w = 22;
rocker_h = 14;
rocker_t = 2.2;
rocker_tilt = 10; // degrees

neon_d = 3.0;
neon_offset_x = 10;
neon_offset_y = 7;

// Raised bezel around each socket
bezel_w = 44;
bezel_h = 36;
bezel_r = 4;
bezel_hgt = 1.2;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_box(w,h,t,r){
    linear_extrude(height=t)
        rounded_rect_2d(w,h,r);
}

module csk_hole(thru_h, d_thru, d_csk, h_csk){
    // Through hole + countersink from front
    union(){
        cylinder(h=thru_h+0.2, d=d_thru, center=false);
        translate([0,0,thru_h-h_csk])
            cylinder(h=h_csk+0.2, d1=d_csk, d2=d_thru, center=false);
    }
}

module socket_aperture(){
    // Outer rounded rectangle cut
    rounded_box(socket_ap_w, socket_ap_h, plate_t+0.5, socket_ap_r);

    // Earth slot
    translate([0, earth_slot_dy, 0])
        rounded_box(earth_slot_w, earth_slot_h, plate_t+0.5, 1.2);

    // Live/neutral slots
    translate([-live_slot_dx, live_slot_dy, 0])
        rounded_box(live_slot_w, live_slot_h, plate_t+0.5, 1.2);
    translate([ live_slot_dx, live_slot_dy, 0])
        rounded_box(live_slot_w, live_slot_h, plate_t+0.5, 1.2);
}

module bezel(){
    // A thin raised frame around socket opening
    difference(){
        rounded_box(bezel_w, bezel_h, bezel_hgt, bezel_r);
        translate([0,0,-0.1])
            rounded_box(socket_ap_w+2, socket_ap_h+2, bezel_hgt+0.3, socket_ap_r+1);
    }
}

module rocker_switch(){
    // Switch base
    color([0.95,0.95,0.95])
    rounded_box(switch_body_w, switch_body_h, switch_body_t, switch_body_r);

    // Rocker
    translate([0,0,switch_body_t])
    rotate([rocker_tilt,0,0])
    translate([0,0,0])
    color([0.98,0.98,0.98])
    rounded_box(rocker_w, rocker_h, rocker_t, 2.5);

    // Neon indicator (small lens)
    translate([neon_offset_x, neon_offset_y, switch_body_t + rocker_t*0.6])
        color([1.0,0.2,0.2])
        cylinder(h=1.2, d=neon_d, center=false);
}

module faceplate(){
    difference(){
        // Main plate
        rounded_box(plate_w, plate_h, plate_t, corner_r);

        // Back recess (to suggest backbox clearance)
        translate([0,0,-0.01])
        linear_extrude(height=backbox_recess_t+0.02)
            difference(){
                rounded_rect_2d(plate_w-2*backbox_recess_margin, plate_h-2*backbox_recess_margin, corner_r-2);
                // keep solid around screw bosses by not cutting there (simple: no extra keepouts)
            }

        // Screw holes (centered on plate)
        for (sy=[-screw_offset_y, screw_offset_y]){
            translate([0, sy, 0])
                csk_hole(plate_t, screw_hole_d, screw_csk_d, screw_csk_h);
        }

        // Socket apertures
        translate([socket_center_x, socket_center_y, 0])
            socket_aperture();
        translate([socket2_center_x, socket_center_y, 0])
            socket_aperture();

        // Switch cutout (shallow pocket so switch sits proud)
        translate([switch_center_x, switch_center_y, plate_t - 2.2])
            rounded_box(switch_body_w+2, switch_body_h+2, 2.4, switch_body_r+1);
    }

    // Raised bezels
    translate([socket_center_x, socket_center_y, plate_t])
        bezel();
    translate([socket2_center_x, socket_center_y, plate_t])
        bezel();

    // Switch assembly
    translate([switch_center_x, switch_center_y, plate_t - 0.2])
        rocker_switch();
}

// ---------- Render ----------
color([0.98,0.98,0.98])
faceplate();