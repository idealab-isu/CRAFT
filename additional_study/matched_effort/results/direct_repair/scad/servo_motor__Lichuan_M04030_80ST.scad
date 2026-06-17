$fn=64;

// Lichuan -80M04030B (approximate envelope model)
// Units: mm

// ---------- Parameters ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_len = 90;

front_flange_w = 80;
front_flange_h = 80;
front_flange_th = 6;

rear_cap_th = 4;

shaft_d = 19;
shaft_len = 40;

pilot_d = 55;          // front locating boss
pilot_h = 2.5;

mount_hole_d = 6.6;    // clearance for M6
mount_hole_spacing = 63; // typical 80mm frame pattern (approx)
mount_hole_depth = front_flange_th + 2;

key_w = 6;
key_h = 3;
key_len = 25;

connector_block_w = 28;
connector_block_h = 22;
connector_block_len = 18;

cable_gland_d = 12;
cable_gland_len = 10;

foot_boss_d = 10;
foot_boss_h = 2;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=false){
    // Minkowski rounded box (renderable, heavier)
    minkowski(){
        cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
        sphere(r=r);
    }
}

module hole_pattern_80(){
    // 4 holes on square pattern
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, -0.1])
            cylinder(d=mount_hole_d, h=mount_hole_depth+0.2);
    }
}

module servo_motor(){
    // Coordinate system:
    // Z axis = motor axis (shaft points +Z)
    // Front face at Z=0, body extends to +Z
    // Centered in X/Y

    difference(){
        union(){
            // Main body
            translate([-motor_body_w/2, -motor_body_h/2, front_flange_th])
                rounded_box([motor_body_w, motor_body_h, motor_body_len-front_flange_th-rear_cap_th], r=3, center=false);

            // Front flange
            translate([-front_flange_w/2, -front_flange_h/2, 0])
                rounded_box([front_flange_w, front_flange_h, front_flange_th], r=2, center=false);

            // Rear cap
            translate([-motor_body_w/2, -motor_body_h/2, motor_body_len-rear_cap_th])
                rounded_box([motor_body_w, motor_body_h, rear_cap_th], r=2, center=false);

            // Front pilot boss
            translate([0,0,front_flange_th])
                cylinder(d=pilot_d, h=pilot_h);

            // Shaft
            translate([0,0,front_flange_th+pilot_h])
                cylinder(d=shaft_d, h=shaft_len);

            // Key on shaft
            translate([shaft_d/2 - key_h, -key_w/2, front_flange_th+pilot_h+5])
                cube([key_h, key_w, key_len], center=false);

            // Connector block on side near rear
            translate([motor_body_w/2, -connector_block_w/2, motor_body_len-connector_block_len-10])
                rotate([0,90,0])
                    rounded_box([connector_block_len, connector_block_w, connector_block_h], r=2, center=false);

            // Cable gland cylinder protruding from connector block
            translate([motor_body_w/2 + connector_block_h, 0, motor_body_len-connector_block_len-10 + connector_block_len/2])
                rotate([0,90,0])
                    cylinder(d=cable_gland_d, h=cable_gland_len);

            // Small feet/bosses on bottom edges (stylized)
            for (sx=[-1,1]){
                translate([sx*(motor_body_w/2-12), -motor_body_h/2, front_flange_th+10])
                    rotate([90,0,0])
                        cylinder(d=foot_boss_d, h=foot_boss_h);
                translate([sx*(motor_body_w/2-12), -motor_body_h/2, motor_body_len-20])
                    rotate([90,0,0])
                        cylinder(d=foot_boss_d, h=foot_boss_h);
            }
        }

        // Mounting holes through flange
        translate([0,0,0])
            hole_pattern_80();

        // Center bore relief (optional shallow)
        translate([0,0,-0.1])
            cylinder(d=22, h=front_flange_th+0.2);

        // Rear face shallow recess (stylized)
        translate([0,0,motor_body_len-rear_cap_th-0.1])
            cylinder(d=60, h=rear_cap_th+0.2);
    }
}

// ---------- Render ----------
color([0.15,0.15,0.17]) servo_motor();