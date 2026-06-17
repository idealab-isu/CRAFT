$fn=96;

// Old-style unswitched mains socket (generic), wall-plate with recessed face and 3-pin holes.
// All dimensions in mm.

plate_w = 86;
plate_h = 86;
plate_t = 3.2;

corner_r = 6;

recess_w = 60;
recess_h = 60;
recess_d = 1.2;

face_w = 54;
face_h = 54;
face_d = 2.0;

screw_hole_d = 4.2;
screw_csk_d = 8.5;
screw_csk_h = 1.6;
screw_offset_y = 28;

pin_hole_d = 6.5;
pin_depth = 10;

earth_hole_d = 7.0;

pin_spacing = 22;          // between live and neutral centers
pin_y = -6;                // y position of live/neutral row
earth_y = 14;              // y position of earth
earth_to_row = earth_y - pin_y;

shutter_slot_w = 10;
shutter_slot_h = 3.2;
shutter_slot_depth = 1.2;

label_depth = 0.6;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module plate_body(){
    linear_extrude(height=plate_t)
        rounded_rect_2d(plate_w, plate_h, corner_r);
}

module recess_cut(){
    translate([0,0,plate_t - recess_d])
        linear_extrude(height=recess_d+0.01)
            rounded_rect_2d(recess_w, recess_h, 4);
}

module face_boss(){
    // Raised inner face (old style slightly proud)
    translate([0,0,plate_t])
        linear_extrude(height=face_d)
            rounded_rect_2d(face_w, face_h, 3);
}

module screw_hole(y){
    // Through hole + countersink on front
    translate([0,y,0])
        cylinder(h=plate_t+face_d+0.5, d=screw_hole_d, center=false);
    translate([0,y,plate_t+face_d - screw_csk_h])
        cylinder(h=screw_csk_h+0.2, d1=screw_csk_d, d2=screw_hole_d, center=false);
}

module pin_holes(){
    // Live and Neutral
    for (x=[-pin_spacing/2, pin_spacing/2]){
        translate([x,pin_y,plate_t+face_d - pin_depth])
            cylinder(h=pin_depth+0.3, d=pin_hole_d, center=false);
    }
    // Earth (top)
    translate([0,earth_y,plate_t+face_d - pin_depth])
        cylinder(h=pin_depth+0.3, d=earth_hole_d, center=false);

    // Simple shutter slots above live/neutral (old unswitched often had shutters)
    for (x=[-pin_spacing/2, pin_spacing/2]){
        translate([x, pin_y + 8, plate_t+face_d - shutter_slot_depth])
            linear_extrude(height=shutter_slot_depth+0.2)
                rounded_rect_2d(shutter_slot_w, shutter_slot_h, 1.2);
    }
}

module subtle_label(){
    // Small recessed "13A" text near bottom (optional, subtle)
    translate([0, -22, plate_t+face_d - label_depth])
        linear_extrude(height=label_depth+0.2)
            text("13A", size=6, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

difference(){
    union(){
        plate_body();
        face_boss();
    }
    recess_cut();
    screw_hole(screw_offset_y);
    screw_hole(-screw_offset_y);
    pin_holes();
    subtle_label();
}