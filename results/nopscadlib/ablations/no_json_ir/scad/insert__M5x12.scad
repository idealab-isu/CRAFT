$fn = 128;

// Parameters (mm)
outer_diameter = 12.0;          // OD
overall_length = 10.0;          // length
internal_diameter = 5.0;        // bore for M5 screw clearance (simple)
knurl_depth = 0.5;              // radial protrusion (ribs extend outward by this)
knurl_count = 24;               // number of knurl ribs
lead_in_chamfer_length = 1.0;   // chamfer at one end
installation_end_chamfer_length = 1.0; // chamfer at other end

// Derived
outer_r = outer_diameter/2;
core_r  = outer_r - knurl_depth;   // base cylinder radius under knurl
eps = 0.02;

// Main threaded insert
module threaded_insert() {
    difference() {
        heat_set_insert_body();
        internal_bore_M5();
    }
}

// Heat-set insert body with knurling and end chamfers
module heat_set_insert_body() {
    union() {
        // Base body (under knurl ribs)
        cylinder(r=core_r, h=overall_length, center=false);

        // Knurl ribs (connected, protrude outward)
        external_knurl_ribs();

        // End chamfers as solids (connected to body)
        end_chamfers();
    }
}

// Internal bore for M5 (simple cylindrical bore)
module internal_bore_M5() {
    translate([0, 0, -eps])
        cylinder(d=internal_diameter, h=overall_length + 2*eps, center=false);
}

// External knurl ribs (axial ribs around circumference)
module external_knurl_ribs() {
    // Tangential width of each rib
    rib_w = max(0.6, (2*PI*outer_r)/knurl_count * 0.45);

    // Radial thickness of rib (from core_r to outer_r)
    rib_t = knurl_depth;

    // Ensure ribs overlap into the core so the union is watertight
    overlap = 0.20;

    // Place ribs so inner face is slightly inside core_r, outer face reaches ~outer_r
    // cube is centered, so its radial half-thickness is rib_t/2
    rib_center_r = core_r + rib_t/2 - overlap;

    for (i = [0:knurl_count-1]) {
        rotate([0, 0, i * 360/knurl_count])
            translate([rib_center_r, 0, overall_length/2])
                cube([rib_t, rib_w, overall_length], center=true);
    }
}

// Add chamfered rings at both ends (keeps OD at 12mm at the ends)
module end_chamfers() {
    // Bottom chamfer: outer_r -> core_r over installation_end_chamfer_length
    if (installation_end_chamfer_length > 0) {
        cylinder(r1=outer_r, r2=core_r, h=installation_end_chamfer_length, center=false);
    }

    // Top chamfer: core_r -> outer_r over lead_in_chamfer_length
    if (lead_in_chamfer_length > 0) {
        translate([0, 0, overall_length - lead_in_chamfer_length])
            cylinder(r1=core_r, r2=outer_r, h=lead_in_chamfer_length, center=false);
    }
}

// Render
threaded_insert();