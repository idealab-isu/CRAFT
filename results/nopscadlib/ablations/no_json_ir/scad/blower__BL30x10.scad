// Parameters
footprint_x = 30.0;
footprint_y = 30.0;
overall_thickness = 10.1;

volute_thickness = 5.0;
impeller_diameter = 20.0;
impeller_thickness = 3.0;

outlet_width = 10.0;
outlet_height = 5.0;

inlet_diameter = 15.0;

motor_hub_diameter = 5.0;
motor_hub_height = 2.0;

mounting_hole_diameter = 2.0;
mounting_hole_offset = 2.0;

internal_clearance_gap = 0.5;   // kept as given (used for plate thickness)
attach_overlap = 1.5;           // 1–2mm overlap to guarantee connection

// Derived
plate_thickness = internal_clearance_gap;

// Main assembly
module blower_fan() {
    difference() {
        union() {
            blower_casing_volute();
            outlet_port();
            top_cover_plate();   // now overlaps volute by attach_overlap
            base_plate();        // now overlaps volute by attach_overlap
        }
        impeller_rotor();
        inlet_bore();
        mounting_screw_holes();
    }
}

// Volute casing (centered at z = volute_thickness/2, spans z=[0..volute_thickness])
module blower_casing_volute() {
    translate([0, 0, volute_thickness / 2])
        cylinder(h = volute_thickness, d = footprint_x, $fn = 100);
}

// Impeller rotor (subtracted)
module impeller_rotor() {
    translate([0, 0, volute_thickness - impeller_thickness])
        cylinder(h = impeller_thickness, d = impeller_diameter, $fn = 100);
}

// Outlet port (attached to volute side; unchanged)
module outlet_port() {
    translate([footprint_x / 2, 0, volute_thickness / 2])
        cube([outlet_width, outlet_height, volute_thickness], center = true);
}

// Inlet bore (subtracted)
module inlet_bore() {
    translate([0, 0, volute_thickness / 2])
        cylinder(h = volute_thickness, d = inlet_diameter, $fn = 100);
}

// Motor hub (unused in original assembly; left as-is)
module motor_hub() {
    translate([0, 0, volute_thickness - motor_hub_height])
        cylinder(h = motor_hub_height, d = motor_hub_diameter, $fn = 100);
}

// Mounting screw holes (subtracted)
module mounting_screw_holes() {
    for (x = [-1, 1])
        for (y = [-1, 1])
            translate([x * (footprint_x / 2 - mounting_hole_offset),
                       y * (footprint_y / 2 - mounting_hole_offset),
                       0])
                cylinder(h = overall_thickness, d = mounting_hole_diameter, $fn = 100);
}

// Top cover plate: placed so its bottom face penetrates into the volute by attach_overlap
// Volute top is at z = volute_thickness
module top_cover_plate() {
    // bottom_z = volute_thickness - attach_overlap
    // center_z = bottom_z + plate_thickness/2
    translate([0, 0, (volute_thickness - attach_overlap) + plate_thickness / 2])
        cube([footprint_x, footprint_y, plate_thickness], center = true);
}

// Base plate: placed so its top face penetrates into the volute by attach_overlap
// Volute bottom is at z = 0
module base_plate() {
    // top_z = 0 + attach_overlap
    // center_z = top_z - plate_thickness/2
    translate([0, 0, attach_overlap - plate_thickness / 2])
        cube([footprint_x, footprint_y, plate_thickness], center = true);
}

// Render the blower fan
blower_fan();