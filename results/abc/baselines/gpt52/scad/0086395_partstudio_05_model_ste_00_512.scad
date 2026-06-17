$fn=64;

L = 0.1;
Wmax = 0.1;
Hmax = 0.1;

module faceted_bar(len, w, h, facet=0.012) {
    difference() {
        cube([len, w, h], center=false);
        translate([0,0,0]) rotate([0,45,0]) translate([-len*0.2, -w, -h]) cube([len*1.4, w*3, h*3], center=false);
        translate([0,0,0]) rotate([0,-45,0]) translate([-len*0.2, -w, -h]) cube([len*1.4, w*3, h*3], center=false);
        translate([0,0,0]) rotate([45,0,0]) translate([-len*0.2, -w, -h]) cube([len*1.4, w*3, h*3], center=false);
        translate([0,0,0]) rotate([-45,0,0]) translate([-len*0.2, -w, -h]) cube([len*1.4, w*3, h*3], center=false);

        translate([0,0,0]) rotate([0,0,45]) translate([-len*0.2, -w, -h]) cube([len*1.4, w*3, h*3], center=false);
        translate([0,0,0]) rotate([0,0,-45]) translate([-len*0.2, -w, -h]) cube([len*1.4, w*3, h*3], center=false);
    }
}

module nose_chamfer(len, w, h) {
    difference() {
        cube([len, w, h], center=false);
        translate([0,0,0]) rotate([0,45,0]) translate([-len, -w, -h]) cube([len*2, w*3, h*3], center=false);
        translate([0,0,0]) rotate([0,-45,0]) translate([-len, -w, -h]) cube([len*2, w*3, h*3], center=false);
        translate([0,0,0]) rotate([45,0,0]) translate([-len, -w, -h]) cube([len*2, w*3, h*3], center=false);
        translate([0,0,0]) rotate([-45,0,0]) translate([-len, -w, -h]) cube([len*2, w*3, h*3], center=false);
    }
}

module fork_slot(slot_len, slot_w, slot_h, gap, prong_thick) {
    difference() {
        cube([slot_len, slot_w, slot_h], center=false);
        translate([0, (slot_w-gap)/2, -0.01]) cube([slot_len+0.02, gap, slot_h+0.02], center=false);
        translate([slot_len*0.55, (slot_w-gap)/2, -0.01]) rotate([0,0,0]) cylinder(h=slot_h+0.02, r=gap/2, center=false);
    }
}

module three_holes(face_x, w, h, d, spacing) {
    for (i=[-1,0,1]) {
        translate([face_x, w/2 + i*spacing, h*0.65])
            rotate([0,90,0])
                cylinder(h=Wmax*2, d=d, center=true);
    }
}

module tool_arm() {
    len = L;
    w1 = Wmax;
    h1 = Hmax;

    step_len = len*0.28;
    mid_len  = len*0.44;
    nose_len = len*0.28;

    w_mid = w1*0.78;
    h_mid = h1*0.78;

    w_nose = w1*0.55;
    h_nose = h1*0.55;

    slot_len = step_len*0.75;
    slot_w = w1*0.92;
    slot_h = h1*0.92;
    gap = w1*0.34;

    hole_d = min(w1,h1)*0.12;
    hole_spacing = w1*0.18;

    difference() {
        union() {
            translate([0, -w1/2, -h1/2])
                faceted_bar(step_len, w1, h1, facet=w1*0.12);

            translate([step_len, -w_mid/2, -h_mid/2])
                faceted_bar(mid_len, w_mid, h_mid, facet=w_mid*0.12);

            translate([step_len+mid_len, -w_nose/2, -h_nose/2])
                nose_chamfer(nose_len, w_nose, h_nose);
        }

        translate([0, -slot_w/2, -slot_h/2])
            fork_slot(slot_len, slot_w, slot_h, gap, (slot_w-gap)/2);

        three_holes(face_x=step_len*0.35, w=w1, h=h1, d=hole_d, spacing=hole_spacing);
    }
}

translate([-L/2, 0, 0]) tool_arm();