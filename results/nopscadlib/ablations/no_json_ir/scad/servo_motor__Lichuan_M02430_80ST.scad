$fn = 128;

// Lichuan -80M02430B (approximate, simplified) — ONE connected solid
// Fixes: ensure all parts overlap/connect via dimension-based formulas (no arbitrary offsets)

motor_body_length = 50;
motor_body_width  = 40;
motor_body_height = 40;

flange_thickness  = 5;
flange_diameter   = 50;

shaft_diameter    = 8;
shaft_length      = 20;

rear_cap_length   = 10;

connector_boss_diameter = 15;
connector_boss_length   = 5;

overlap = 0.8; // guaranteed overlap for manifold union

// Z references
z_body_center = 0;
z_body_top    = z_body_center + motor_body_height/2;
z_body_bottom = z_body_center - motor_body_height/2;

// Connected stack (all center=true)
z_flange_center = z_body_top + flange_thickness/2 - overlap;
z_flange_top    = z_flange_center + flange_thickness/2;

z_shaft_center  = z_flange_top + shaft_length/2 - overlap;

z_rear_center   = z_body_bottom - rear_cap_length/2 + overlap;
z_rear_bottom   = z_rear_center - rear_cap_length/2;

z_boss_center   = z_rear_bottom - connector_boss_length/2 + overlap;

// Modules
module motor_body() {
    translate([0, 0, z_body_center])
        cube([motor_body_length, motor_body_width, motor_body_height], center=true);
}

module front_flange() {
    translate([0, 0, z_flange_center])
        cylinder(h=flange_thickness, d=flange_diameter, center=true);
}

module output_shaft() {
    translate([0, 0, z_shaft_center])
        cylinder(h=shaft_length, d=shaft_diameter, center=true);
}

module rear_cap() {
    translate([0, 0, z_rear_center])
        cube([motor_body_length, motor_body_width, rear_cap_length], center=true);
}

module cable_connector_boss() {
    translate([0, 0, z_boss_center])
        cylinder(h=connector_boss_length, d=connector_boss_diameter, center=true);
}

// Assembly (ONE connected solid)
module servo_motor() {
    union() {
        motor_body();
        front_flange();
        output_shaft();
        rear_cap();
        cable_connector_boss();
    }
}

servo_motor();