$fn=96;

// Screwfix Essential unswitched (approximate) UK 1-gang socket front plate + recessed face
// Units: mm

// ---------- Parameters ----------
plate_w = 146;
plate_h = 86;
plate_t = 8.5;

corner_r = 6;

face_recess_depth = 1.2;
face_recess_margin = 6;

inner_bevel = 1.0;

back_relief_depth = 1.0;
back_relief_margin = 5;

screw_hole_d = 4.2;          // clearance for M3.5/M4-ish
screw_csk_d = 8.5;
screw_csk_depth = 2.2;

screw_spacing = 120;         // UK 1-gang centers
screw_y = 0;

socket_window_w = 92;
socket_window_h = 52;
socket_window_r = 4;
socket_window_depth = 6.0;   // cut into plate

// UK socket apertures (approx)
earth_w = 8.0;
earth_h = 22.0;
earth_r = 1.2;

live_w = 6.5;
live_h = 18.0;
live_r = 1.2;

pin_depth = plate_t + 2;

pin_center_y = 6.0;          // slightly above center
pin_spacing_x = 22.0;        // L-N spacing
live_y = -8.0;               // L/N below earth

shutter_depth = 1.2;         // shallow shutter recess
shutter_clear = 0.6;

// subtle logo recess
logo_w = 26;
logo_h = 8;
logo_depth = 0.4;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_box(w,h,t,r){
    linear_extrude(height=t)
        rounded_rect_2d(w,h,r);
}

module csk_hole(thru_d, csk_d, csk_h, total_h){
    // through
    cylinder(d=thru_d, h=total_h+0.2, center=false);
    // countersink (conical)
    translate([0,0,total_h - csk_h])
        cylinder(d1=csk_d, d2=thru_d, h=csk_h+0.2, center=false);
}

module slot_rounded(w,h,r,depth){
    linear_extrude(height=depth)
        rounded_rect_2d(w,h,r);
}

module socket_apertures(){
    // Earth (top)
    translate([0, pin_center_y, 0])
        slot_rounded(earth_w, earth_h, earth_r, pin_depth);

    // Live/Neutral (bottom left/right)
    for (sx=[-pin_spacing_x/2, pin_spacing_x/2]){
        translate([sx, live_y, 0])
            slot_rounded(live_w, live_h, live_r, pin_depth);
    }

    // Shutter recesses (very shallow, slightly larger)
    translate([0, pin_center_y, plate_t - shutter_depth])
        slot_rounded(earth_w + 2*shutter_clear, earth_h + 2*shutter_clear, earth_r+0.6, shutter_depth+0.2);

    for (sx=[-pin_spacing_x/2, pin_spacing_x/2]){
        translate([sx, live_y, plate_t - shutter_depth])
            slot_rounded(live_w + 2*shutter_clear, live_h + 2*shutter_clear, live_r+0.6, shutter_depth+0.2);
    }
}

module logo_recess(){
    translate([0, -plate_h/2 + 14, plate_t - logo_depth])
        linear_extrude(height=logo_depth+0.2)
            rounded_rect_2d(logo_w, logo_h, 1.5);
}

// ---------- Model ----------
difference(){
    // Main plate
    rounded_box(plate_w, plate_h, plate_t, corner_r);

    // Front face recess (gives slight dish)
    translate([0,0,plate_t - face_recess_depth])
        linear_extrude(height=face_recess_depth+0.2)
            rounded_rect_2d(plate_w - 2*face_recess_margin, plate_h - 2*face_recess_margin, corner_r-1);

    // Inner bevel around recess (subtle)
    translate([0,0,plate_t - face_recess_depth - inner_bevel])
        linear_extrude(height=inner_bevel+0.2, scale=0.985)
            rounded_rect_2d(plate_w - 2*(face_recess_margin-1), plate_h - 2*(face_recess_margin-1), corner_r-1);

    // Back relief (slight hollow)
    translate([0,0,-0.1])
        linear_extrude(height=back_relief_depth+0.2)
            rounded_rect_2d(plate_w - 2*back_relief_margin, plate_h - 2*back_relief_margin, corner_r-1);

    // Screw holes (countersunk from front)
    for (x=[-screw_spacing/2, screw_spacing/2]){
        translate([x, screw_y, 0])
            csk_hole(screw_hole_d, screw_csk_d, screw_csk_depth, plate_t);
    }

    // Central socket window recess
    translate([0,0,plate_t - socket_window_depth])
        linear_extrude(height=socket_window_depth+0.2)
            rounded_rect_2d(socket_window_w, socket_window_h, socket_window_r);

    // Pin apertures through
    socket_apertures();

    // Small logo recess
    logo_recess();
}