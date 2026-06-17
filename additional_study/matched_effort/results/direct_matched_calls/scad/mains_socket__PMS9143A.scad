$fn=96;

// Screwfix Essential unswitched (approximate) mains socket front plate + recessed socket apertures.
// This is a non-functional visual model with approximate dimensions.

plate_w = 86;
plate_h = 86;
plate_t = 3.0;

corner_r = 6;

face_bevel = 0.8;     // subtle edge bevel
inner_recess_depth = 1.2;
inner_recess_margin = 6.5;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module rounded_rect_3d(w,h,t,r){
    linear_extrude(height=t) rounded_rect_2d(w,h,r);
}

module countersunk_hole(thru_d=3.6, head_d=7.2, head_h=1.6, t=plate_t){
    // Through hole + shallow countersink on front face
    union(){
        cylinder(h=t+0.2, d=thru_d, center=false);
        translate([0,0,t-head_h]) cylinder(h=head_h+0.25, d1=head_d, d2=thru_d, center=false);
    }
}

module socket_apertures(){
    // UK BS1363 style apertures (approx)
    // Positions relative to plate center
    // Earth (top)
    earth_w = 6.2;
    earth_h = 14.0;
    earth_y = 18.0;

    // Live/Neutral (bottom)
    ln_w = 6.2;
    ln_h = 14.0;
    ln_y = -12.0;
    ln_x = 11.0;

    // Slight rounding via offset
    module slot(w,h,depth){
        linear_extrude(height=depth)
            offset(r=1.0)
                square([w-2.0, h-2.0], center=true);
    }

    // Recessed pocket around apertures (approx)
    pocket_w = 52;
    pocket_h = 46;
    pocket_r = 4;

    // Pocket
    translate([0,0,plate_t-inner_recess_depth])
        linear_extrude(height=inner_recess_depth+0.25)
            rounded_rect_2d(pocket_w, pocket_h, pocket_r);

    // Aperture cut-throughs
    // Earth
    translate([0, earth_y, -0.1]) slot(earth_w, earth_h, plate_t+0.4);
    // Neutral (left)
    translate([-ln_x, ln_y, -0.1]) slot(ln_w, ln_h, plate_t+0.4);
    // Live (right)
    translate([ ln_x, ln_y, -0.1]) slot(ln_w, ln_h, plate_t+0.4);

    // Safety shutter hint: small central notch (visual)
    translate([0, 2.0, plate_t-inner_recess_depth])
        linear_extrude(height=inner_recess_depth+0.25)
            offset(r=1.2)
                square([10, 6], center=true);
}

module embossed_text(){
    // Minimal branding text (approx placement)
    // Raised slightly on front face
    txt_h = 0.5;
    translate([0, -34, plate_t-0.01])
        linear_extrude(height=txt_h)
            text("ESSENTIAL", size=6.5, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

module plate(){
    // Base plate with subtle bevel by minkowski (kept light for renderability)
    // Use a 2D offset bevel instead of 3D minkowski for speed.
    difference(){
        // Plate body
        rounded_rect_3d(plate_w, plate_h, plate_t, corner_r);

        // Front edge bevel (shallow chamfer approximation)
        translate([0,0,plate_t-face_bevel])
            linear_extrude(height=face_bevel+0.25, scale=0.985)
                rounded_rect_2d(plate_w, plate_h, corner_r);

        // Inner shallow recess border (visual)
        translate([0,0,plate_t-inner_recess_depth])
            linear_extrude(height=inner_recess_depth+0.25)
                rounded_rect_2d(plate_w-2*inner_recess_margin, plate_h-2*inner_recess_margin, max(0,corner_r-2));

        // Screw holes (top/bottom)
        screw_y = 30;
        translate([0, screw_y, -0.1]) countersunk_hole();
        translate([0,-screw_y, -0.1]) countersunk_hole();

        // Socket apertures + pocket
        socket_apertures();
    }

    // Embossed text
    embossed_text();
}

plate();