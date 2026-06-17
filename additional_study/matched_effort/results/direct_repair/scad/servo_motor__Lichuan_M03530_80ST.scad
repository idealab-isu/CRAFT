$fn=96;

// Lichuan -80M03530B (approximate envelope model)
// Units: mm

// ---------- Parameters ----------
body_w = 80;
body_h = 80;
body_len = 90;

front_flange_w = 80;
front_flange_h = 80;
front_flange_t = 6;

front_face_plate_t = 2;   // slight front lip
rear_cap_t = 6;

shaft_d = 19;
shaft_len = 35;
shaft_flat_depth = 1.0;   // D-flat depth
shaft_flat_len = 22;

pilot_d = 38;             // front pilot (register)
pilot_len = 2;

mount_hole_d = 6.6;       // clearance for M6
mount_hole_spacing = 63;  // typical 80mm servo pattern
mount_hole_inset = (front_flange_w - mount_hole_spacing)/2;

corner_r = 4;

connector_w = 28;
connector_h = 18;
connector_len = 18;

cable_gland_d = 12;
cable_gland_len = 10;

foot_w = 18;
foot_h = 6;
foot_len = 40;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=false){
    // Minkowski rounded rectangular prism
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*r, sy-2*r, sz-2*r], center=false);
        sphere(r=r);
    }
}

module d_shaft(d=10, len=20, flat_depth=1, flat_len=15){
    // D-flat along +Y side (cut a chord)
    difference(){
        cylinder(d=d, h=len);
        // cut flat
        translate([-d, d/2 - flat_depth, 0])
            cube([2*d, d, flat_len], center=false);
    }
}

module mount_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, -1])
            cylinder(d=mount_hole_d, h=front_flange_t+front_face_plate_t+2);
    }
}

module front_features(){
    // pilot
    translate([0,0,front_flange_t])
        cylinder(d=pilot_d, h=pilot_len);

    // shaft
    translate([0,0,front_flange_t+pilot_len])
        d_shaft(d=shaft_d, len=shaft_len, flat_depth=shaft_flat_depth, flat_len=shaft_flat_len);
}

module rear_features(){
    // rear cable gland (centered)
    translate([0,0,body_len - rear_cap_t])
        cylinder(d=cable_gland_d, h=cable_gland_len);

    // side connector block near rear
    translate([body_w/2 + connector_len/2, 0, body_len - rear_cap_t - connector_h/2])
        rotate([0,90,0])
            rounded_box([connector_len, connector_w, connector_h], r=2, center=true);
}

module servo_motor(){
    // Coordinate system:
    // Z axis along motor length, front face at z=0, rear at z=body_len
    // X/Y centered on motor axis.

    difference(){
        union(){
            // main body
            translate([-body_w/2, -body_h/2, front_flange_t])
                rounded_box([body_w, body_h, body_len-front_flange_t], r=corner_r, center=false);

            // front flange
            translate([-front_flange_w/2, -front_flange_h/2, 0])
                rounded_box([front_flange_w, front_flange_h, front_flange_t], r=corner_r, center=false);

            // slight front face plate lip
            translate([-front_flange_w/2, -front_flange_h/2, front_flange_t-0.01])
                rounded_box([front_flange_w, front_flange_h, front_face_plate_t], r=corner_r, center=false);

            // rear cap
            translate([-body_w/2, -body_h/2, body_len - rear_cap_t])
                rounded_box([body_w, body_h, rear_cap_t], r=corner_r, center=false);

            // optional small feet (bottom)
            translate([-body_w/2 + 10, -body_h/2 - foot_h, body_len*0.35])
                rounded_box([foot_len, foot_h, foot_w], r=1.5, center=false);
            translate([ body_w/2 - 10 - foot_len, -body_h/2 - foot_h, body_len*0.35])
                rounded_box([foot_len, foot_h, foot_w], r=1.5, center=false);

            // rear connector/gland
            rear_features();

            // front pilot + shaft
            front_features();
        }

        // mounting holes through flange
        translate([0,0,0]) mount_holes();

        // small chamfer-like relief on flange corners (visual)
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(front_flange_w/2-6), sy*(front_flange_h/2-6), -1])
                cylinder(d=6, h=front_flange_t+front_face_plate_t+2);
        }
    }
}

// ---------- Render ----------
servo_motor();