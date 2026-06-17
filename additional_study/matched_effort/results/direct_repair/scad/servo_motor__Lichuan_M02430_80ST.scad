$fn=96;

// Lichuan -80M02430B servo motor (approximate parametric model)
// Units: mm

// ---------- Parameters ----------
body_w = 80;
body_h = 80;
body_l = 130;

front_flange_w = 80;
front_flange_h = 80;
front_flange_t = 6;

rear_cap_t = 4;

corner_r = 4;

shaft_d = 19;
shaft_l = 35;

pilot_d = 38;
pilot_h = 2.5;

bolt_circle_d = 65;
mount_hole_d = 6.6; // clearance for M6
mount_hole_depth = front_flange_t + 2;

key_w = 6;
key_h = 2.8;
key_l = 22;

connector_w = 28;
connector_h = 18;
connector_l = 18;
connector_offset_y = -body_h/2 + connector_h/2 + 10;
connector_offset_z = 0;

cable_d = 8;
cable_l = 35;

label_recess = 0.6;
label_w = 50;
label_h = 22;
label_offset_x = -body_l/2 + 45;
label_offset_y = body_w/2 - 0.01; // on side face
label_offset_z = 0;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, min(sx, min(sy, sz))/2);
    translate(center ? [-sx/2, -sy/2, -sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*rr, sy-2*rr, sz-2*rr], center=false);
        sphere(rr);
    }
}

module bolt_holes_on_circle(d_circle, hole_d, depth){
    for(a=[0:90:270]){
        translate([0, (d_circle/2)*cos(a), (d_circle/2)*sin(a)])
            rotate([0,90,0])
                cylinder(d=hole_d, h=depth, center=false);
    }
}

module servo(){
    difference(){
        union(){
            // Main body
            translate([0,0,0])
                rounded_box([body_l, body_w, body_h], r=corner_r, center=true);

            // Front flange
            translate([body_l/2 + front_flange_t/2, 0, 0])
                rounded_box([front_flange_t, front_flange_w, front_flange_h], r=corner_r, center=true);

            // Rear cap
            translate([-body_l/2 - rear_cap_t/2, 0, 0])
                rounded_box([rear_cap_t, body_w, body_h], r=corner_r, center=true);

            // Pilot (front register)
            translate([body_l/2 + front_flange_t + pilot_h/2, 0, 0])
                rotate([0,90,0])
                    cylinder(d=pilot_d, h=pilot_h, center=true);

            // Shaft
            translate([body_l/2 + front_flange_t + pilot_h + shaft_l/2, 0, 0])
                rotate([0,90,0])
                    cylinder(d=shaft_d, h=shaft_l, center=true);

            // Key on shaft
            translate([body_l/2 + front_flange_t + pilot_h + key_l/2 + 2, shaft_d/2 - key_h/2, 0])
                cube([key_l, key_h, key_w], center=true);

            // Connector block on side
            translate([ -body_l/2 + connector_l/2 + 18, connector_offset_y, connector_offset_z ])
                rounded_box([connector_l, connector_w, connector_h], r=2, center=true);

            // Cable stub
            translate([ -body_l/2 + 18, connector_offset_y - connector_w/2 - cable_l/2, connector_offset_z ])
                rotate([90,0,0])
                    cylinder(d=cable_d, h=cable_l, center=true);
        }

        // Mounting holes through flange (from front face inward)
        translate([body_l/2 + 0.01, 0, 0])
            bolt_holes_on_circle(bolt_circle_d, mount_hole_d, mount_hole_depth);

        // Center bore (optional shallow) on flange/pilot
        translate([body_l/2 + 0.01, 0, 0])
            rotate([0,90,0])
                cylinder(d=12, h=front_flange_t + pilot_h + 1, center=false);

        // Side label recess
        translate([label_offset_x, label_offset_y, label_offset_z])
            rotate([0,90,0])
                cube([label_recess, label_w, label_h], center=true);
    }
}

// ---------- Render ----------
servo();