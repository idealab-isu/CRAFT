$fn = 96;

module screw(d_shaft=4.0, d_head=7.0, head_h=2.4, total_l=10.0) {
    shank_h = total_l - head_h;
    overlap = 0.05; // small overlap to guarantee a single connected solid

    union() {
        // Shaft (from z=0 to z=shank_h)
        cylinder(h=shank_h + overlap, d=d_shaft, center=false);

        // Head (from z=shank_h to z=total_l)
        translate([0, 0, shank_h - overlap])
            cylinder(h=head_h + overlap, d=d_head, center=false);
    }
}

screw();