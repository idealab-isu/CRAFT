$fn = 128;

// Brushless DC motor (single connected solid)
// Target: 35.0mm stator diameter, 45.0mm can length (main body height)

// -------------------- Parameters --------------------
stator_diameter = 35.0;     // requested stator OD
motor_height    = 45.0;     // requested can length

overlap = 0.6;              // overlap to guarantee watertight unions

// Outer can OD (slightly larger than stator)
can_diameter = stator_diameter + 3.0;   // 38mm OD typical for 35mm stator class

// Endbells
endbell_thickness = 2.0;
endbell_lip = 0.8;

// Shaft
shaft_diameter  = 5.0;
shaft_front_len = 16.0;
shaft_rear_len  = 6.0;

// Front boss
boss_diameter = 12.0;
boss_height   = 2.5;

// Mounting holes (front endbell)
mount_hole_diameter = 3.0;
mount_hole_bcd      = 25.0;
mount_hole_count    = 4;

// Wire exit (rear)
wire_exit_diameter = 4.0;
wire_exit_length   = 6.0;

// Outer ribs
rib_count = 12;
rib_depth = 0.8;
rib_width = 2.0;

// Internal BLDC hint geometry (kept as solid features so model remains ONE connected solid)
stator_stack_len = motor_height - 2*endbell_thickness; // inside can between endbells
stator_tooth_count = 12;
stator_ring_thickness = 2.2;  // radial thickness of stator back-iron ring
tooth_radial_len = 3.0;       // tooth protrusion inward from stator ring
tooth_tangential_w = 2.2;     // tooth width (tangential)
rotor_diameter = stator_diameter - 2*(stator_ring_thickness + tooth_radial_len) - 1.0; // clearance

// -------------------- Derived --------------------
can_r    = can_diameter/2;
stator_r = stator_diameter/2;

front_z =  motor_height/2;
rear_z  = -motor_height/2;

total_shaft_len = shaft_front_len + motor_height + shaft_rear_len;

// -------------------- Modules --------------------
module can_with_ribs() {
    union() {
        cylinder(d=can_diameter, h=motor_height, center=true);

        // Ribs protrude outward and overlap into can
        for (i = [0:rib_count-1]) {
            rotate([0,0,i*360/rib_count])
                translate([can_r + rib_depth/2 - overlap, 0, 0])
                    cube([rib_depth, rib_width, motor_height], center=true);
        }
    }
}

module endbell_front() {
    // Sits on front face, extends outward (+Z)
    translate([0,0, front_z - overlap])
        union() {
            cylinder(d=can_diameter, h=endbell_thickness, center=false);

            translate([0,0, endbell_thickness - overlap])
                cylinder(d=can_diameter - 2*endbell_lip, h=endbell_lip, center=false);

            translate([0,0, endbell_thickness - overlap])
                cylinder(d=boss_diameter, h=boss_height, center=false);
        }
}

module endbell_rear() {
    // Sits on rear face, extends outward (-Z)
    translate([0,0, rear_z - endbell_thickness + overlap])
        union() {
            cylinder(d=can_diameter, h=endbell_thickness, center=false);

            translate([0,0, -endbell_lip + overlap])
                cylinder(d=can_diameter - 2*endbell_lip, h=endbell_lip, center=false);
        }
}

module shaft() {
    // One continuous shaft through motor
    translate([0,0, (shaft_front_len - shaft_rear_len)/2])
        cylinder(d=shaft_diameter, h=total_shaft_len, center=true);
}

module wire_exit() {
    // Tangent to can, connected near rear endbell
    // Centerline placed so it intersects the can by 'overlap'
    y_center = can_r - wire_exit_diameter/2 + overlap;
    z_center = rear_z - endbell_thickness/2; // near rear endbell region
    translate([0, y_center, z_center])
        rotate([90,0,0])
            cylinder(d=wire_exit_diameter, h=wire_exit_length, center=true);
}

module mounting_holes() {
    // Through front endbell + boss
    hole_h = endbell_thickness + boss_height + 2*overlap;
    z0 = front_z + (endbell_thickness + boss_height)/2 - overlap;

    for (i = [0:mount_hole_count-1]) {
        rotate([0,0,i*360/mount_hole_count])
            translate([mount_hole_bcd/2, 0, z0])
                cylinder(d=mount_hole_diameter, h=hole_h, center=true);
    }
}

module internal_bldc_solid_hint() {
    // Solid internal stator ring + teeth + rotor cylinder.
    // This makes the stator diameter verifiable (outer of stator ring = stator_diameter).
    // Positioned inside the can between endbells, with slight overlap into endbells for connectivity.
    z_center = 0;
    h_stack  = stator_stack_len + 2*overlap;

    stator_ring_r_outer = stator_r;
    stator_ring_r_inner = stator_ring_r_outer - stator_ring_thickness;

    tooth_r_outer = stator_ring_r_inner;                 // tooth starts at inner edge of ring
    tooth_r_inner = tooth_r_outer - tooth_radial_len;    // tooth extends inward

    union() {
        // Stator back-iron ring (solid)
        translate([0,0,z_center])
            difference() {
                cylinder(r=stator_ring_r_outer, h=h_stack, center=true);
                cylinder(r=stator_ring_r_inner, h=h_stack + 2*overlap, center=true);
            }

        // Stator teeth (solid blocks) - connected to ring
        for (i = [0:stator_tooth_count-1]) {
            rotate([0,0,i*360/stator_tooth_count])
                translate([(tooth_r_outer + tooth_r_inner)/2, 0, z_center])
                    cube([tooth_r_outer - tooth_r_inner, tooth_tangential_w, h_stack], center=true);
        }

        // Rotor (solid cylinder) - connected to shaft
        // Ensure rotor is not larger than available inner diameter
        rotor_d = max(shaft_diameter + 2.0, rotor_diameter);
        translate([0,0,z_center])
            cylinder(d=rotor_d, h=h_stack, center=true);
    }
}

module front_stator_groove_detail() {
    // Shallow groove on front face to suggest boundary (subtractive)
    groove_d_outer = stator_diameter + 2.0;
    groove_d_inner = stator_diameter - 6.0;
    groove_depth   = 0.8;

    translate([0,0, front_z + endbell_thickness - groove_depth + overlap])
        difference() {
            cylinder(d=groove_d_outer, h=groove_depth, center=false);
            translate([0,0,-overlap])
                cylinder(d=groove_d_inner, h=groove_depth + 2*overlap, center=false);
        }
}

// -------------------- Assembly --------------------
module bldc_motor() {
    difference() {
        union() {
            can_with_ribs();
            endbell_front();
            endbell_rear();
            shaft();
            wire_exit();

            // Internal BLDC features as solid geometry (keeps one connected solid)
            internal_bldc_solid_hint();
        }

        // Subtractive details
        mounting_holes();
        front_stator_groove_detail();
    }
}

bldc_motor();