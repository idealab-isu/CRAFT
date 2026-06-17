$fn=96;

// Old-style unswitched mains socket faceplate (generic)
// Units: mm

plate_w = 86;
plate_h = 86;
plate_t = 6;

corner_r = 6;

backbox_relief = 1.2;   // shallow recess on back
backbox_margin = 10;

screw_hole_d = 4.2;
screw_csk_d  = 8.5;
screw_csk_h  = 2.2;

screw_offset_y = 28;    // from center

// Socket aperture (generic "old" style: two round pin holes + earth slot)
pin_hole_d = 6.5;
pin_spacing = 22;       // center-to-center
pin_y = 6;              // above center

earth_slot_w = 6.5;
earth_slot_h = 10.5;
earth_y = -10;

aperture_depth = plate_t + 0.5;

// Subtle front bevel
bevel = 0.8;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    }
}

module plate_solid(){
    // Main plate with slight front bevel via minkowski
    minkowski(){
        linear_extrude(height=plate_t - bevel)
            rounded_rect_2d(plate_w - 2*bevel, plate_h - 2*bevel, corner_r - bevel);
        cylinder(h=bevel, r=bevel);
    }
}

module screw_hole(){
    // Through hole + countersink on front
    union(){
        cylinder(h=plate_t+2, d=screw_hole_d, center=false);
        translate([0,0,plate_t - screw_csk_h])
            cylinder(h=screw_csk_h+2, d1=screw_csk_d, d2=screw_hole_d);
    }
}

module socket_apertures(){
    // Two pin holes
    translate([-pin_spacing/2, pin_y, -1]) cylinder(h=aperture_depth, d=pin_hole_d);
    translate([ pin_spacing/2, pin_y, -1]) cylinder(h=aperture_depth, d=pin_hole_d);

    // Earth slot (rounded rectangle)
    translate([0, earth_y, -1])
        linear_extrude(height=aperture_depth)
            offset(r=earth_slot_w/2)
                square([0.01, earth_slot_h - earth_slot_w], center=true);
}

module back_relief(){
    // Shallow recess on back to suggest backbox clearance
    translate([0,0,-0.01])
        linear_extrude(height=backbox_relief+0.02)
            rounded_rect_2d(plate_w - 2*backbox_margin, plate_h - 2*backbox_margin, max(1, corner_r-2));
}

module subtle_front_recess(){
    // Slight recessed area around apertures (old faceplate styling)
    recess_w = 52;
    recess_h = 52;
    recess_r = 4;
    recess_depth = 0.8;
    translate([0,0,plate_t - recess_depth])
        linear_extrude(height=recess_depth+0.01)
            rounded_rect_2d(recess_w, recess_h, recess_r);
}

difference(){
    plate_solid();

    // Front styling recess
    subtle_front_recess();

    // Socket apertures
    socket_apertures();

    // Screw holes (top and bottom)
    translate([0, screw_offset_y, -1]) screw_hole();
    translate([0,-screw_offset_y, -1]) screw_hole();

    // Back relief
    translate([0,0,0]) back_relief();
}

// Raised rim around the recessed area (very subtle)
module rim(){
    rim_w = 54;
    rim_h = 54;
    rim_r = 4.5;
    rim_t = 0.6;
    translate([0,0,plate_t - rim_t])
        linear_extrude(height=rim_t)
            difference(){
                rounded_rect_2d(rim_w, rim_h, rim_r);
                rounded_rect_2d(rim_w-2.2, rim_h-2.2, rim_r-1.1);
            }
}
rim();