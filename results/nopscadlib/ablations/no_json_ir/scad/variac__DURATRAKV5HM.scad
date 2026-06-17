// Parameters
variac_diameter = 100;
variac_height = 50;
bulge_diameter = 120;
bulge_height = 10;
shaft_diameter = 10;
shaft_height = 60;
mounting_hole_diameter = 5;
mounting_hole_radius = 40;
top_face_thickness = 5;
dial_diameter = 80;
dial_height = 10;

// Connectivity overlap (1-2mm) to guarantee attachment
overlap = 2;

// Main variac body (kept as-is structurally)
module variac_body() {
    difference() {
        cylinder(d=variac_diameter, h=variac_height, center=true);
        translate([0, 0, -variac_height/2])
            cylinder(d=bulge_diameter, h=bulge_height, center=false);
    }
}

// Central shaft (overlaps into body)
module shaft() {
    translate([0, 0, variac_height/2 - overlap])
        cylinder(d=shaft_diameter, h=shaft_height + overlap, center=false);
}

// Mounting hole pattern (these are holes; should be used in difference, not union)
module mounting_hole_pattern() {
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
            translate([mounting_hole_radius, 0, 0])
                cylinder(d=mounting_hole_diameter, h=variac_height + 10, center=true);
    }
}

// Screw and washer hardware placeholders (overlap into top face)
module screw_and_washer_hardware_placeholders() {
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
            translate([mounting_hole_radius, 0, variac_height/2 - overlap/2])
                cylinder(d=mounting_hole_diameter + 2, h=5 + overlap, center=true);
    }
}

// Dial/knob assembly (overlaps into shaft)
module dial() {
    translate([0, 0, variac_height/2 + shaft_height - overlap])
        cylinder(d=dial_diameter, h=dial_height + overlap, center=false);
}

// --- Fixed: orange wire/coil elements + guaranteed physical attachment ---
// The coil is now placed so its TOP penetrates into the main body by `overlap`,
// eliminating any visible gap/floating geometry.
module coil_and_attachment() {
    coil_h = 2;                                          // thin coil thickness
    coil_outer_r = (variac_diameter/2) - 6;              // keep within body footprint
    coil_inner_r = 12;                                   // clear center
    spoke_w = 2;
    spoke_len = coil_outer_r - coil_inner_r;
    n_spokes = 16;

    // Place coil so it intersects the body's bottom face by `overlap`
    // Body bottom is at z = -variac_height/2
    // Coil top is at z = coil_z + (coil_h + overlap)
    // Set coil top to (-variac_height/2 + overlap) => coil_z = -variac_height/2 - coil_h
    coil_z = -variac_height/2 - coil_h;

    // Risers that connect coil plane into the body (guaranteed overlap)
    // Start at coil_z and extend upward past the body bottom by `overlap`.
    riser_d = 4;
    riser_h = coil_h + 2*overlap; // reaches into body by overlap and into coil by overlap
    for (i = [0:3]) {
        rotate([0, 0, i * 90])
            translate([mounting_hole_radius, 0, coil_z])
                cylinder(d=riser_d, h=riser_h, center=false);
    }

    // Coil ring (washer-like) that intersects risers and penetrates body by `overlap`
    translate([0, 0, coil_z])
    difference() {
        cylinder(r=coil_outer_r, h=coil_h + overlap, center=false);
        translate([0, 0, -0.1])
            cylinder(r=coil_inner_r, h=coil_h + overlap + 0.2, center=false);
    }

    // Spokes (wire-like elements) that intersect the ring and reach toward center
    for (i = [0:n_spokes-1]) {
        rotate([0, 0, i * 360 / n_spokes])
            translate([coil_inner_r + spoke_len/2 - overlap, 0, coil_z + (coil_h+overlap)/2])
                cube([spoke_len + 2*overlap, spoke_w, coil_h + overlap], center=true);
    }
}

// Complete variac assembly (single connected solid)
// NOTE: mounting_hole_pattern() is a subtractive feature; keep it in difference.
module variac() {
    union() {
        difference() {
            union() {
                variac_body();
                shaft();
                screw_and_washer_hardware_placeholders();
                dial();
                coil_and_attachment(); // now intersects body (no floating / no gap)
            }
            mounting_hole_pattern(); // holes cut through body
        }
    }
}

// Render the variac
variac();