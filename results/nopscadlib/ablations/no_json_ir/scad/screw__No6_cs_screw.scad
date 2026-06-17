$fn = 96;

module screw(shaft_d=3.5, head_d=7.0, total_len=10.0, head_h=3.0, overlap=0.2) {
    shaft_h = total_len - head_h;

    union() {
        // Shaft (below head)
        cylinder(h=shaft_h + overlap, d=shaft_d, center=false);

        // Head (on top of shaft), slightly overlapped to ensure one connected solid
        translate([0, 0, shaft_h - overlap])
            cylinder(h=head_h + overlap, d=head_d, center=false);
    }
}

screw();