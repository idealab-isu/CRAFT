// HT 160 pipe, length 250 mm, with integrated end fitting (one connected solid)

$fn = 160;

module ht_pipe_segment(d=160, L=250) {
    wall = 4;          // pipe wall thickness
    fit_h = 10;        // end fitting height
    fit_extra = 10;    // OD increase of fitting vs pipe
    overlap = 1;       // ensures union overlap (connectivity)

    union() {
        ht_pipe(d, L, wall);
        integrated_end_fitting(d, L, wall, fit_h, fit_extra, overlap);
    }
}

// Hollow pipe (Z from 0..L)
module ht_pipe(d, L, wall) {
    difference() {
        cylinder(h=L, d=d, center=false);
        translate([0, 0, -1])
            cylinder(h=L + 2, d=d - 2*wall, center=false);
    }
}

// End fitting sleeve at the end of the pipe, overlapping into pipe by 'overlap'
module integrated_end_fitting(d, L, wall, fit_h, fit_extra, overlap) {
    // Sleeve spans [L-fit_h, L+overlap] so it overlaps into the pipe by fit_h
    translate([0, 0, L - fit_h])
        difference() {
            cylinder(h=fit_h + overlap, d=d + fit_extra, center=false);
            translate([0, 0, -1])
                cylinder(h=fit_h + overlap + 2, d=(d + fit_extra) - 2*wall, center=false);
        }
}

ht_pipe_segment(160, 250);