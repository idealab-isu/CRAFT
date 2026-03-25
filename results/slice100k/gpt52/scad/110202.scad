$fn=96;

bbox_x = 96.6;
bbox_y = 19.0;
bbox_z = 123.0;

th = bbox_y;

spine_w = 14.0;
spine_z = 123.0;

boss_d = 18.0;
boss_h = 10.0;

ring_od = 18.0;
ring_id = 10.0;

diamond_w = 96.6;
diamond_h = 78.0;
diamond_cz = 62.0;

brace_w = 10.0;

module ring3d(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.6, center=true);
    }
}

module bar_between(p1, p2, w, h){
    v = [p2[0]-p1[0], p2[1]-p1[1], p2[2]-p1[2]];
    len = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
    yaw = atan2(v[1], v[0]);
    pitch = atan2(v[2], sqrt(v[0]*v[0] + v[1]*v[1]));
    translate([(p1[0]+p2[0])/2, (p1[1]+p2[1])/2, (p1[2]+p2[2])/2])
        rotate([0, -pitch, yaw])
            cube([len, w, h], center=true);
}

module diamond_frame(){
    top    = [0, 0, diamond_cz + diamond_h/2];
    right  = [diamond_w/2, 0, diamond_cz];
    bottom = [0, 0, diamond_cz - diamond_h/2];
    left   = [-diamond_w/2, 0, diamond_cz];

    union(){
        bar_between(top, right, brace_w, th);
        bar_between(right, bottom, brace_w, th);
        bar_between(bottom, left, brace_w, th);
        bar_between(left, top, brace_w, th);

        bar_between(top, bottom, brace_w, th);
        bar_between(left, right, brace_w, th);

        translate(top)    ring3d(ring_od, ring_id, th);
        translate(right)  ring3d(ring_od, ring_id, th);
        translate(bottom) ring3d(ring_od, ring_id, th);
        translate(left)   ring3d(ring_od, ring_id, th);
    }
}

module spine_with_eyelets(){
    union(){
        translate([0,0,0])
            cube([spine_w, th, spine_z], center=true);

        for (zpos = [-45, -15, 15, 45]){
            translate([0,0,zpos])
                ring3d(ring_od, ring_id, th);
        }

        translate([0,0,spine_z/2 - boss_h/2])
            cylinder(d=boss_d, h=boss_h, center=true);
    }
}

difference(){
    union(){
        spine_with_eyelets();
        diamond_frame();
    }
    translate([0,0,0])
        cube([spine_w-6.0, th+0.8, spine_z-10.0], center=true);
}