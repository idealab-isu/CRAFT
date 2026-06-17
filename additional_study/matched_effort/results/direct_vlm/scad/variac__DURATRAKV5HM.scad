$fn=96;

// DURATRAK V5HM variac (approx external model)
// Units: mm
// Single connected solid; no text/labels; all placements derived from dimensions.

eps = 0.6; // overlap to guarantee connectivity

module rounded_box(size=[100,100,50], r=6){
    x=size[0]; y=size[1]; z=size[2];
    r2=min(r, min(x,y)/2-0.01);
    minkowski(){
        cube([x-2*r2, y-2*r2, z-2*r2], center=true);
        sphere(r=r2);
    }
}

module vent_slots(area=[70,18], slot_w=3, slot_gap=3, depth=2.2){
    w=area[0]; h=area[1];
    n=max(1, floor((w+slot_gap)/(slot_w+slot_gap)));
    start=-w/2 + (w - (n*slot_w + (n-1)*slot_gap))/2 + slot_w/2;
    for(i=[0:n-1]){
        x = start + i*(slot_w+slot_gap);
        translate([x,0,0])
            cube([slot_w, h, depth], center=true);
    }
}

module knob(d=62, h=22){
    // solid knob with scallops and pointer ridge
    difference(){
        union(){
            cylinder(d=d, h=h, center=false);
            translate([0,0,h-2]) cylinder(d=d*0.92, h=2, center=false);
            translate([d*0.38,0,h-4]) cube([d*0.18, 6, 4], center=true);
        }
        for(i=[0:17]){
            rotate([0,0,i*20])
                translate([d/2-3.5,0,h/2])
                    cylinder(d=7, h=h+2, center=true);
        }
        translate([0,0,-1]) cylinder(d=6.5, h=h*0.65, center=false);
    }
}

module dial_ring(od=86, id=70, h=2.2){
    difference(){
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2, center=false);
    }
}

module panel_frame(w=110, h=34, t=2.6, lip=3.2, r=3){
    // Raised bezel-like frame (no text), connected to face
    difference(){
        rounded_box([w, t, h], r=r);
        translate([0,0,0])
            rounded_box([w-2*lip, t+0.2, h-2*lip], r=max(0.5,r-1.2));
    }
}

module variac_v5hm(){
    // Body
    body_x=165;
    body_y=135;
    body_z=95;
    corner_r=10;

    // Top panel inset
    top_inset=2.0;

    // Knob/dial
    knob_d=62;
    knob_h=22;
    dial_od=86;
    dial_id=70;
    dial_h=2.2;

    // Place knob offset toward one end (typical variac layout)
    knob_center = [0, body_y*0.18, body_z/2 - top_inset - dial_h]; // on top surface

    // Feet
    foot_d=14;
    foot_h=3.2;

    // Side carry/guard arcs (semi-rings)
    guard_od = 92;
    guard_id = 78;
    guard_th = 6;
    guard_z  = knob_center[2] - dial_h/2;

    // Rear terminal block (rear face protrusion)
    term_w=78;
    term_d=26;
    term_h=22;

    // Front panel bezel + outlet block (front face)
    front_bezel_w=118;
    front_bezel_h=38;
    front_bezel_t=3.0;

    outlet_w=96;
    outlet_h=24;
    outlet_d=12;

    // Side small bumps
    side_bump_w=10;
    side_bump_h=3;
    side_bump_d=2.2;

    // Bottom mounting boss
    boss_w=74;
    boss_d=38;
    boss_h=12;

    // Top rear cable/strain relief hump (common variac feature)
    hump_w=54;
    hump_d=26;
    hump_h=10;

    // Main connected solid
    union(){
        // Main shell
        rounded_box([body_x, body_y, body_z], r=corner_r);

        // Bottom feet (overlap into body)
        for(sx=[-1,1], sy=[-1,1]){
            translate([sx*(body_x/2-22), sy*(body_y/2-20),
                       -body_z/2 + foot_h/2 - eps])
                cylinder(d=foot_d, h=foot_h+2*eps, center=true);
        }

        // Bottom mounting boss (connected)
        translate([0, 0, -body_z/2 - boss_h/2 + eps])
            rounded_box([boss_w, boss_d, boss_h+2*eps], r=4);

        // Rear terminal block (connected to rear face)
        translate([0,
                   -body_y/2 - term_d/2 + eps,
                   body_z/2 - term_h/2 - 12])
            rounded_box([term_w, term_d+2*eps, term_h], r=3);

        // Top rear hump (connected to top surface near rear)
        translate([0,
                   -body_y/2 + hump_d/2 + 10,
                   body_z/2 - top_inset - hump_h/2 + eps])
            rounded_box([hump_w, hump_d, hump_h+2*eps], r=4);

        // Front bezel frame (connected to front face)
        translate([0,
                   body_y/2 + front_bezel_t/2 - eps,
                   -body_z/2 + 34])
            rotate([90,0,0])
                panel_frame(w=front_bezel_w, h=front_bezel_h, t=front_bezel_t+2*eps, lip=3.4, r=3);

        // Front outlet block (connected to front face, centered in bezel)
        translate([0,
                   body_y/2 + outlet_d/2 - eps,
                   -body_z/2 + 28])
            rounded_box([outlet_w, outlet_d+2*eps, outlet_h], r=2.5);

        // Dial ring (connected to top surface)
        translate([knob_center[0], knob_center[1], body_z/2 - top_inset - dial_h + eps])
            dial_ring(od=dial_od, id=dial_id, h=dial_h+eps);

        // Knob (connected)
        translate([knob_center[0], knob_center[1], body_z/2 - top_inset + eps])
            knob(d=knob_d, h=knob_h);

        // Side guard arcs (connected via overlap)
        // Left side
        translate([-body_x/2 + guard_th/2 - eps, knob_center[1], guard_z])
            rotate([0,90,0])
                difference(){
                    cylinder(d=guard_od, h=guard_th+2*eps, center=true);
                    cylinder(d=guard_id, h=guard_th+2*eps+0.2, center=true);
                    // cut to semi-arc (open toward body)
                    translate([0, -(guard_od/2), 0])
                        cube([guard_od*1.2, guard_od, guard_th*2], center=true);
                }
        // Right side
        translate([ body_x/2 - guard_th/2 + eps, knob_center[1], guard_z])
            rotate([0,90,0])
                difference(){
                    cylinder(d=guard_od, h=guard_th+2*eps, center=true);
                    cylinder(d=guard_id, h=guard_th+2*eps+0.2, center=true);
                    translate([0, (guard_od/2), 0])
                        cube([guard_od*1.2, guard_od, guard_th*2], center=true);
                }

        // Small side bumps (connected)
        for(sx=[-1,1]){
            translate([sx*(body_x/2 - side_bump_d/2 + eps), 0, body_z/2 - 6])
                rotate([0,90,0])
                    cube([side_bump_w, side_bump_h, side_bump_d+2*eps], center=true);
            translate([sx*(body_x/2 - side_bump_d/2 + eps), 0, -body_z/2 + 6])
                rotate([0,90,0])
                    cube([side_bump_w, side_bump_h, side_bump_d+2*eps], center=true);
        }

        // Dial tick bumps (raised, connected to dial ring)
        translate([knob_center[0], knob_center[1], body_z/2 - top_inset - 0.8])
            for(i=[0:30]){
                ang = -140 + i*(280/30);
                len = (i%5==0) ? 7 : 4;
                w   = (i%5==0) ? 1.2 : 0.8;
                rotate([0,0,ang])
                    translate([dial_od/2-6,0,0])
                        cube([len, w, 0.9], center=true);
            }

        // Top small indicator boss near knob (recognizable feature; connected)
        ind_d=10;
        ind_h=3.2;
        ind_off = [knob_center[0] + dial_od*0.33, knob_center[1] + dial_od*0.18, body_z/2 - top_inset - ind_h + eps];
        translate(ind_off)
            cylinder(d=ind_d, h=ind_h+2*eps, center=false);
    }
}

difference(){
    // Outer connected solid
    variac_v5hm();

    // Subtractive details (holes/vents) - do not disconnect the solid
    body_x=165; body_y=135; body_z=95; corner_r=10;
    top_inset=2.0;

    // Hollow underside cavity (leave walls)
    translate([0,0,-6])
        rounded_box([body_x-10, body_y-10, body_z-18], r=corner_r-3);

    // Bottom opening (shallower to keep strength)
    translate([0,0,-body_z/2+7])
        cube([body_x-18, body_y-18, 16], center=true);

    // Front ventilation slots (above outlet area)
    translate([0, body_y/2-4.5, -body_z/2+52])
        rotate([90,0,0])
            vent_slots(area=[112,18], slot_w=3, slot_gap=3, depth=6);

    // Side ventilation slots (left)
    translate([-body_x/2+4.5, 0, -body_z/2+48])
        rotate([0,90,0])
            vent_slots(area=[90,22], slot_w=3, slot_gap=3, depth=6);

    // Side ventilation slots (right)
    translate([body_x/2-4.5, 0, -body_z/2+48])
        rotate([0,-90,0])
            vent_slots(area=[90,22], slot_w=3, slot_gap=3, depth=6);

    // Rear terminal holes (3) through terminal block
    term_d=26;
    term_h=22;
    term_y = -body_y/2 - term_d/2;
    term_z = body_z/2 - term_h/2 - 12;
    for(i=[-1,0,1]){
        translate([i*18, term_y - 2, term_z])
            rotate([90,0,0])
                cylinder(d=7.5, h=term_d+body_y, center=true);
    }

    // Front outlet holes (2) through outlet block
    outlet_d=12;
    out_y = body_y/2 + outlet_d/2;
    out_z = -body_z/2 + 28;
    for(i=[-1,1]){
        translate([i*18, out_y + 2, out_z])
            rotate([90,0,0])
                cylinder(d=9, h=outlet_d+body_y, center=true);
    }

    // Bottom mounting screw holes (4)
    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(body_x/2-28), sy*(body_y/2-26), -body_z/2+8])
            cylinder(d=3.6, h=40, center=true);
    }

    // Top rear hump cable hole (shallow pocket, not through body)
    hump_d=26;
    hump_h=10;
    translate([0,
               -body_y/2 + hump_d/2 + 10,
               body_z/2 - top_inset - hump_h + 2])
        rotate([90,0,0])
            cylinder(d=10, h=hump_d+4, center=true);
}