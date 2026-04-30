$fn = 64;

face_w = 84;
face_h = 84;
height = 10.5;
wall = 3.6;

screw_pitch = 60.3;
screw_hole_d = 4.0;
screw_countersink_d = 8.0;
screw_countersink_h = 2.0;

inner_clear_w = face_w - 2*wall;
inner_clear_h = face_h - 2*wall;

round_r = 3.0;

module rounded_box(w,h,t,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2 - r), sy*(h/2 - r), 0])
                cylinder(r=r, h=t);
    }
}

module wall_socket(){
    difference(){
        // Outer body (faceplate + shallow box)
        rounded_box(face_w, face_h, height, round_r);

        // Inner cavity (open from back, leaving a front thickness)
        translate([0,0,wall])
            rounded_box(inner_clear_w, inner_clear_h, height, max(0.1, round_r-1.0));

        // Screw through holes + countersinks on front
        for (y=[-screw_pitch/2, screw_pitch/2]){
            // Through hole
            translate([0,y,-0.2])
                cylinder(d=screw_hole_d, h=height+0.4);

            // Countersink (front)
            translate([0,y,0])
                cylinder(d=screw_countersink_d, h=screw_countersink_h);
        }

        // Central aperture (representing socket opening)
        translate([0,0,0.8])
            rounded_box(48, 32, height, 2.5);
    }

    // Small rear lip (to suggest flush-mount rim)
    translate([0,0,height - 1.5])
        difference(){
            rounded_box(face_w - 2.0, face_h - 2.0, 1.5, round_r-0.5);
            translate([0,0,-0.1])
                rounded_box(face_w - 2.0 - 2*wall, face_h - 2.0 - 2*wall, 1.7, max(0.1, round_r-1.5));
        }
}

wall_socket();