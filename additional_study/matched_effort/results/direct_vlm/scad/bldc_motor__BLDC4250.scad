$fn = 160;

// Brushless DC motor (approximate) with 42.5mm stator diameter and 48.0mm height
// One connected solid; all placements derived from dimensions (no arbitrary offsets).

stator_d = 42.5;
motor_h  = 48.0;

// Outer can sized from stator + wall
can_wall = 1.2;
can_d    = stator_d + 2*can_wall;

// End features (included in motor_h)
rear_cap_t     = 2.0;
front_plate_t  = 2.0;
flange_t       = 2.5;

// Ensure total body height matches motor_h (excluding shaft protrusions)
can_h = motor_h - (rear_cap_t + front_plate_t + flange_t);

// Shaft
shaft_d         = 5.0;
shaft_len_front = 18.0;
shaft_len_rear  = 2.0;

// Flange + mounting
flange_d       = can_d + 6.0;
bolt_circle_d  = 25.0;
bolt_hole_d    = 3.2;
bolt_count     = 4;

// Visual BLDC details
vent_count    = 10;
vent_w        = 3.0;
vent_z_margin = 4.0;
vent_depth    = can_wall + 0.8;   // cut slightly deeper than wall

rib_count    = 6;
rib_w        = 2.2;
rib_h        = 0.9;               // radial protrusion
rib_len      = can_h * 0.75;

grommet_d   = 6.0;
grommet_len = 6.0;

// Keyed feature to break rotational symmetry so left/right/front/back ortho views differ
key_w   = 6.0;   // tangential width
key_h   = 1.2;   // radial protrusion
key_len = can_h * 0.55;

// Small overlap to guarantee connectivity between touching parts
overlap = 0.25;

module bolt_holes(z0, t){
    for(i=[0:bolt_count-1]){
        a = 360/bolt_count*i + 45;
        translate([ (bolt_circle_d/2)*cos(a), (bolt_circle_d/2)*sin(a), z0 ])
            cylinder(d=bolt_hole_d, h=t, center=false);
    }
}

module vents(z_can0){
    // Radial slots cut into the can wall
    z0 = z_can0 + vent_z_margin;
    z1 = z_can0 + can_h - vent_z_margin;
    slot_h = max(0.1, z1 - z0);

    for(i=[0:vent_count-1]){
        a = i * 360/vent_count;
        rotate([0,0,a])
            translate([can_d/2 - vent_depth/2, 0, z0 + slot_h/2])
                cube([vent_depth, vent_w, slot_h], center=true);
    }
}

module ribs(z_can0){
    // External ribs on the can
    z0 = z_can0 + (can_h - rib_len)/2;
    for(i=[0:rib_count-1]){
        a = i * 360/rib_count + 360/(2*rib_count);
        rotate([0,0,a])
            translate([can_d/2 + rib_h/2 - overlap, 0, z0 + rib_len/2])
                cube([rib_h, rib_w, rib_len], center=true);
    }
}

module key_flat(z_can0){
    // One-sided external key/flat to make orthographic side views distinct
    z0 = z_can0 + (can_h - key_len)/2;
    translate([can_d/2 + key_h/2 - overlap, 0, z0 + key_len/2])
        cube([key_h, key_w, key_len], center=true);
}

module motor(){
    // Z layout (base at z=0)
    z_rear0   = 0;
    z_rear1   = rear_cap_t;

    z_can0    = z_rear1 - overlap;
    z_can1    = z_can0 + can_h + overlap;

    z_front0  = z_can1 - overlap;
    z_front1  = z_front0 + front_plate_t + overlap;

    z_flange0 = z_front1 - overlap;
    z_flange1 = z_flange0 + flange_t + overlap;

    z_body_top = z_flange1; // total motor body height = motor_h

    union(){
        // Main can with hollow interior + ventilation slots
        difference(){
            // Outer can
            translate([0,0,z_can0])
                cylinder(d=can_d, h=can_h + overlap, center=false);

            // Hollow interior (leave wall thickness)
            translate([0,0,z_can0 + can_wall])
                cylinder(d=can_d - 2*can_wall, h=can_h + overlap - 2*can_wall, center=false);

            // Ventilation slots
            vents(z_can0);
        }

        // External ribs + keyed feature (breaks symmetry for ortho views)
        ribs(z_can0);
        key_flat(z_can0);

        // Rear cap with shallow recess + cable exit boss
        difference(){
            translate([0,0,z_rear0])
                cylinder(d=can_d, h=rear_cap_t + overlap, center=false);

            // Rear recess (gives back view feature)
            translate([0,0,z_rear0 + 0.6])
                cylinder(d=can_d - 6.0, h=rear_cap_t, center=false);
        }

        // Cable grommet/boss on rear cap side (connected with overlap)
        translate([can_d/2 - grommet_d/2 - overlap, 0, rear_cap_t/2])
            rotate([0,90,0])
                cylinder(d=grommet_d, h=grommet_len, center=true);

        // Front faceplate (stepped)
        difference(){
            translate([0,0,z_front0])
                cylinder(d=can_d, h=front_plate_t + overlap, center=false);

            // Front recess ring
            translate([0,0,z_front0 + 0.6])
                cylinder(d=can_d - 8.0, h=front_plate_t, center=false);
        }

        // Mounting flange ring with bolt holes
        difference(){
            translate([0,0,z_flange0])
                cylinder(d=flange_d, h=flange_t + overlap, center=false);

            // Inner clearance to can diameter
            translate([0,0,z_flange0 - overlap])
                cylinder(d=can_d, h=flange_t + 3*overlap, center=false);

            // Bolt holes through flange
            bolt_holes(z_flange0 - overlap, flange_t + 3*overlap);
        }

        // Front shaft (connected to faceplate/flange stack)
        translate([0,0,z_body_top - overlap])
            cylinder(d=shaft_d, h=shaft_len_front + overlap, center=false);

        // Rear shaft stub (connected to rear cap)
        translate([0,0,z_rear0 - shaft_len_rear])
            cylinder(d=shaft_d, h=shaft_len_rear + overlap, center=false);
    }
}

motor();