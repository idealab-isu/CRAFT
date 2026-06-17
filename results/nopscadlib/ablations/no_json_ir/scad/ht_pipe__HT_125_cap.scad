$fn = 180;

// Parameters for HT 125 cap
cap_outer_diameter = 140;            // outer diameter
cap_inner_diameter = 125;            // socket ID
cap_height = 30;                     // total height
end_wall_thickness = 5;              // closed end thickness
internal_stop_shoulder_thickness = 3; // axial thickness of internal stop ring

// Small overlap to guarantee robust booleans
eps = 0.2;

module ht_125_cap() {
    // Derived dimensions
    inner_void_h = max(0, cap_height - end_wall_thickness); // depth of inner cavity from open end
    stop_h = min(internal_stop_shoulder_thickness, inner_void_h);

    // Stop ring reduces the ID by 2*radial_reduction
    radial_reduction = internal_stop_shoulder_thickness;
    stop_d = max(0.01, cap_inner_diameter - 2*radial_reduction);

    // Place stop ring at the bottom of the cavity (just above the end wall)
    stop_z = max(0, inner_void_h - stop_h);

    difference() {
        // Outer solid
        cylinder(h=cap_height, d=cap_outer_diameter, center=false);

        // Main inner cavity (open end at z=0)
        translate([0, 0, -eps])
            cylinder(h=inner_void_h + eps, d=cap_inner_diameter, center=false);

        // Internal stop shoulder: subtract a smaller cylinder only in the stop region,
        // leaving an annular ring that blocks the pipe.
        translate([0, 0, stop_z - eps])
            cylinder(h=stop_h + 2*eps, d=stop_d, center=false);
    }
}

ht_125_cap();