$fn = 64;

// Board dimensions (must match)
length = 78.0;
width  = 47.0;
thickness = 1.6;

// Small overlap to guarantee one connected solid
overlap = 0.25;

// Helpers
module rounded_box(size=[10,10,10], r=1, center=true) {
    // Guard against invalid minkowski core sizes
    core = [
        max(0.01, size[0]-2*r),
        max(0.01, size[1]-2*r),
        max(0.01, size[2]-2*r)
    ];
    minkowski() {
        cube(core, center=center);
        sphere(r=r);
    }
}

module pcb() {
    // Slightly rounded PCB
    rounded_box([length, width, thickness], r=1.2, center=true);
}

module inductor() {
    // Large shielded inductor block
    ind_l = 18;
    ind_w = 18;
    ind_h = 10;

    // Place near top-left quadrant, sitting on PCB with overlap
    x = -length/2 + 12 + ind_l/2;
    y =  width/2 - 10 - ind_w/2;
    z =  thickness/2 + ind_h/2 - overlap;

    translate([x, y, z])
        rounded_box([ind_l, ind_w, ind_h], r=1.2, center=true);
}

module electrolytic_cap() {
    cap_r = 6;
    cap_h = 14;

    x = -length/2 + 12 + cap_r;
    y = -width/2 + 12 + cap_r;
    z =  thickness/2 + cap_h/2 - overlap;

    translate([x, y, z])
        cylinder(r=cap_r, h=cap_h, center=true);
}

module ic_chip() {
    ic_l = 12;
    ic_w = 10;
    ic_h = 2.2;

    x = 0;
    y = 0;
    z = thickness/2 + ic_h/2 - overlap;

    translate([x, y, z])
        rounded_box([ic_l, ic_w, ic_h], r=0.6, center=true);
}

module terminal_block(side="right") {
    // 2-pin terminal block on an edge, connected to PCB
    tb_l = 10;   // along X
    tb_w = 12;   // along Y
    tb_h = 10;

    // Small "foot" that overlaps onto PCB to ensure connectivity
    foot_h = 1.2;

    // Ensure the block is not flush with the PCB edge: overlap into PCB in X
    x = (side == "right")
        ? ( length/2 - tb_l/2 + overlap)
        : (-length/2 + tb_l/2 - overlap);

    y = 0;

    // Main body sits on PCB
    z_body = thickness/2 + tb_h/2 - overlap;

    // Foot overlaps into PCB
    z_foot = thickness/2 + foot_h/2 - overlap;

    union() {
        translate([x, y, z_body])
            rounded_box([tb_l, tb_w, tb_h], r=0.8, center=true);

        translate([x, y, z_foot])
            cube([tb_l, tb_w, foot_h], center=true);
    }
}

module small_caps_row() {
    // A few small SMD capacitors/resistors as low-profile blocks
    part_l = 3.2;
    part_w = 2.0;
    part_h = 1.2;

    z = thickness/2 + part_h/2 - overlap;

    for (i = [0:5]) {
        x = -length/2 + 28 + i*(part_l + 1.2);
        y =  width/2 - 8;
        translate([x, y, z])
            cube([part_l, part_w, part_h], center=true);
    }
}

module heatsink_pad() {
    // A slightly raised "metal" pad area
    pad_l = 22;
    pad_w = 16;
    pad_h = 0.8;

    x = length/2 - 18 - pad_l/2;
    y = -width/2 + 12 + pad_w/2;
    z = thickness/2 + pad_h/2 - overlap;

    translate([x, y, z])
        cube([pad_l, pad_w, pad_h], center=true);
}

module mod() {
    // One connected solid: all parts overlap slightly into PCB
    union() {
        pcb();
        inductor();
        electrolytic_cap();
        ic_chip();
        terminal_block("left");
        terminal_block("right");
        small_caps_row();
        heatsink_pad();
    }
}

mod();