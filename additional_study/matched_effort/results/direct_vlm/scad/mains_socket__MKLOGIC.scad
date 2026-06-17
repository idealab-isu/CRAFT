$fn=96;

// Screwfix-style UK switched double socket (approximate)
// Units: mm

// ---------- Parameters ----------
plate_w = 146;
plate_h = 86;
plate_t = 3.2;

corner_r = 6;

backbox_depth = 25;
backbox_margin = 6; // inset from plate edge
backbox_w = plate_w - 2*backbox_margin;
backbox_h = plate_h - 2*backbox_margin;

face_recess = 0.8; // shallow recess for front detailing

// Two outlets
outlet_w = 56;
outlet_h = 56;
outlet_spacing = 12;
outlet_y = 0;

// Switches
switch_w = 18;
switch_h = 28;
switch_t = 2.2;
switch_offset_x = 30; // from outlet center to switch center (to the right)
switch_offset_y = 18; // above outlet center

// Screw holes
screw_hole_d = 4.2;
screw_csk_d = 8.5;
screw_csk_h = 1.6;
screw_y_offset = 28;

// Socket apertures (UK)
earth_d = 7.0;
live_d  = 7.0;
neutral_d = 7.0;

pin_depth = plate_t + 2; // cut through plate
earth_y = 10;
ln_y = -8;
ln_x = 9.5;

// Safety shutter slot (approx)
shutter_w = 22;
shutter_h = 6;
shutter_y = 2;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_box(w,h,t,r){
    linear_extrude(height=t)
        rounded_rect_2d(w,h,r);
}

module csk_hole(d_thru, d_csk, h_csk, t){
    // Through hole + countersink from front (top)
    union(){
        cylinder(d=d_thru, h=t+0.5, center=false);
        translate([0,0,t-h_csk])
            cylinder(d1=d_csk, d2=d_thru, h=h_csk+0.01, center=false);
    }
}

module uk_socket_cutout(){
    // Pin holes
    translate([0, earth_y, -0.1]) cylinder(d=earth_d, h=pin_depth+0.2);
    translate([-ln_x, ln_y, -0.1]) cylinder(d=live_d, h=pin_depth+0.2);
    translate([ ln_x, ln_y, -0.1]) cylinder(d=neutral_d, h=pin_depth+0.2);

    // Shutter slot (visual)
    translate([0, shutter_y, plate_t-face_recess-0.2])
        linear_extrude(height=face_recess+0.4)
            rounded_rect_2d(shutter_w, shutter_h, 2);
}

module outlet_frame(xc){
    // Slight recessed frame around each outlet
    translate([xc, outlet_y, plate_t-face_recess])
        linear_extrude(height=face_recess)
            difference(){
                rounded_rect_2d(outlet_w, outlet_h, 4);
                rounded_rect_2d(outlet_w-6, outlet_h-6, 3);
            }
}

module switch_rocker(xc){
    // Raised rocker
    translate([xc + switch_offset_x, outlet_y + switch_offset_y, plate_t])
        rounded_box(switch_w, switch_h, switch_t, 2.5);
}

module switch_recess(xc){
    // Recess pocket under rocker
    translate([xc + switch_offset_x, outlet_y + switch_offset_y, plate_t-face_recess])
        linear_extrude(height=face_recess+0.01)
            rounded_rect_2d(switch_w+4, switch_h+4, 3);
}

// ---------- Model ----------
module faceplate(){
    difference(){
        // Plate
        rounded_box(plate_w, plate_h, plate_t, corner_r);

        // Screw holes (top/bottom center)
        translate([0,  screw_y_offset, 0]) csk_hole(screw_hole_d, screw_csk_d, screw_csk_h, plate_t);
        translate([0, -screw_y_offset, 0]) csk_hole(screw_hole_d, screw_csk_d, screw_csk_h, plate_t);

        // Outlet cutouts
        left_x  = -(outlet_w/2 + outlet_spacing/2);
        right_x =  (outlet_w/2 + outlet_spacing/2);

        translate([left_x,  outlet_y, 0]) uk_socket_cutout();
        translate([right_x, outlet_y, 0]) uk_socket_cutout();

        // Switch recesses
        switch_recess(left_x);
        switch_recess(right_x);

        // Small brand recess (subtle)
        translate([0, -plate_h/2 + 14, plate_t-0.6])
            linear_extrude(height=0.61)
                rounded_rect_2d(34, 10, 2);
    }

    // Outlet frames (recessed)
    left_x  = -(outlet_w/2 + outlet_spacing/2);
    right_x =  (outlet_w/2 + outlet_spacing/2);
    outlet_frame(left_x);
    outlet_frame(right_x);

    // Switch rockers (raised)
    switch_rocker(left_x);
    switch_rocker(right_x);
}

module backbox(){
    // Simple rear box for context
    translate([0,0,-backbox_depth])
        difference(){
            rounded_box(backbox_w, backbox_h, backbox_depth, 3);
            translate([0,0,1.6])
                rounded_box(backbox_w-3.2, backbox_h-3.2, backbox_depth, 2.2);
        }
}

// Assemble
union(){
    faceplate();
    backbox();
}