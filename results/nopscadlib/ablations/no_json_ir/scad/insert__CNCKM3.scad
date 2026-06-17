$fn = 120;

// Threaded heat-set insert (simplified geometry)
// OD 3.0mm, length 4.6mm, for M3 screw (pilot bore approx)
od = 3.0;          // outer diameter
len = 4.6;         // overall length
bore_d = 2.5;      // pilot bore for M3 (approx)

chamfer_h = 0.5;   // end chamfer height
chamfer_d = 2.5;   // chamfer minor diameter

num_barbs = 6;
barb_d = 0.5;        // barb cylinder diameter
barb_len = 1.8;      // radial protrusion length
barb_overlap = 0.20; // overlap into body to ensure connectivity

eps = 0.02;

module threaded_insert() {
    difference() {
        heat_set_insert_body();
        internal_thread_bore();
    }
}

module heat_set_insert_body() {
    union() {
        main_body_with_chamfers();
        external_barbs();
    }
}

module main_body_with_chamfers() {
    union() {
        // main cylinder
        cylinder(h = len, d = od, center = false);

        // top chamfer (lead-in)
        translate([0, 0, len - chamfer_h])
            cylinder(h = chamfer_h, d1 = od, d2 = chamfer_d, center = false);

        // bottom chamfer (installation end)
        cylinder(h = chamfer_h, d1 = chamfer_d, d2 = od, center = false);
    }
}

module internal_thread_bore() {
    // extend beyond ends to guarantee clean subtraction
    translate([0, 0, -1])
        cylinder(h = len + 2, d = bore_d, center = false);
}

module external_barbs() {
    // Center barbs along Z so they intersect the body (connected solid)
    zc = len/2;

    // Place barb so its inner end penetrates the OD by barb_overlap
    // With center=true cylinder along X: inner end = x_center - barb_len/2
    // Want inner end = od/2 - barb_overlap  => x_center = od/2 + barb_len/2 - barb_overlap
    x_center = (od/2) + (barb_len/2) - barb_overlap;

    for (i = [0 : num_barbs - 1]) {
        rotate([0, 0, i * 360/num_barbs])
            translate([x_center, 0, zc])
                rotate([0, 90, 0])
                    cylinder(h = barb_len + eps, d = barb_d, center = true);
    }
}

threaded_insert();