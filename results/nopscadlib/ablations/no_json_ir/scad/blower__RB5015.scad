// Parameters
volute_length = 51.3;
volute_width  = 51.0;
volute_height = 15.0;

inlet_diameter  = 20.0;
outlet_width    = 10.0;
outlet_height   = 5.0;

impeller_diameter = 40.0;
impeller_height   = 10.0;

mounting_hole_diameter = 3.0;
mounting_hole_spacing  = 45.0;

// Connectivity/robustness
overlap = 1.5;          // 1–2mm overlap to guarantee attachment
lug_d   = 5.0;          // outer lug diameter (standoff OD)

// Main assembly
module blower_fan() {
    difference() {
        union() {
            volute_casing();
            outlet_duct();      // solid feature
            mounting_lugs();    // FIXED: now guaranteed to intersect the body
        }
        inlet_bore();
        impeller_rotor();
        screw_holes();
    }
}

// Volute casing
module volute_casing() {
    translate([0, 0, volute_height/2])
        cylinder(h = volute_height, d1 = volute_width, d2 = volute_length, center = true);
}

// Inlet bore (subtracted)
module inlet_bore() {
    translate([0, 0, volute_height/2])
        cylinder(h = volute_height + 2*overlap, d = inlet_diameter, center = true);
}

// Outlet duct (solid) - overlaps into volute
module outlet_duct() {
    translate([volute_length/2 + outlet_width/2 - overlap, 0, volute_height/2])
        cube([outlet_width, volute_width, outlet_height], center = true);
}

// Impeller rotor (subtracted cavity)
module impeller_rotor() {
    translate([0, 0, volute_height/2])
        cylinder(h = impeller_height + 2*overlap, d = impeller_diameter, center = true);
}

// Mounting lugs (FIXED: attach to volute with guaranteed overlap)
// Previous approach could still miss the volute because it assumed a circular OD.
// Here we compute the volute's XY boundary at each lug angle using the ellipse
// formed by the frustum's end diameters (d2=volute_length, d1=volute_width).
module mounting_lugs() {
    a = volute_length/2;   // semi-axis in X
    b = volute_width/2;    // semi-axis in Y
    lug_r = lug_d/2;

    // Use the original "four corners" directions (45°, 135°, 225°, 315°)
    for (ang = [45, 135, 225, 315]) {
        // Ellipse radius in direction ang:
        // r(θ) = 1 / sqrt((cosθ/a)^2 + (sinθ/b)^2)
        r_dir = 1 / sqrt( pow(cos(ang)/a, 2) + pow(sin(ang)/b, 2) );

        // Place lug center so its inner edge penetrates the volute by `overlap`
        // center distance = r_dir + lug_r - overlap
        r_center = r_dir + lug_r - overlap;

        translate([r_center*cos(ang), r_center*sin(ang), volute_height/2])
            cylinder(h = volute_height + 2*overlap, d = lug_d, center = true);
    }
}

// Screw holes (subtracted) - match lug placement exactly
module screw_holes() {
    a = volute_length/2;
    b = volute_width/2;
    lug_r = lug_d/2;

    for (ang = [45, 135, 225, 315]) {
        r_dir = 1 / sqrt( pow(cos(ang)/a, 2) + pow(sin(ang)/b, 2) );
        r_center = r_dir + lug_r - overlap;

        translate([r_center*cos(ang), r_center*sin(ang), volute_height/2])
            cylinder(h = volute_height + 4*overlap, d = mounting_hole_diameter, center = true);
    }
}

// Render the blower fan
blower_fan();