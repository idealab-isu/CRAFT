// 3D printer control board (Melzi-like) - ONE connected solid
// Target PCB size: 203.2mm x 49.53mm x 1.6mm

$fn = 64;

// Parameters
length = 203.2;
width  = 49.53;
thickness = 1.6;

// Overlap to guarantee connectivity between parts (1-2mm as required)
ov = 1.2;

// Helpers: place components so they INTERSECT the PCB by ov in Z
module on_top(z_h) {
    translate([0, 0, thickness/2 + z_h/2 - ov]) children();
}
module on_bottom(z_h) {
    translate([0, 0, -thickness/2 - z_h/2 + ov]) children();
}

// Edge placement helpers: keep parts intersecting PCB in X/Y by ov and in Z by ov
module on_edge_xn(x_len, z_h) {
    translate([-length/2 - x_len/2 + ov, 0, thickness/2 + z_h/2 - ov]) children();
}
module on_edge_xp(x_len, z_h) {
    translate([ length/2 + x_len/2 - ov, 0, thickness/2 + z_h/2 - ov]) children();
}
module on_edge_yn(y_len, z_h) {
    translate([0, -width/2 - y_len/2 + ov, thickness/2 + z_h/2 - ov]) children();
}
module on_edge_yp(y_len, z_h) {
    translate([0,  width/2 + y_len/2 - ov, thickness/2 + z_h/2 - ov]) children();
}

// Rounded-rectangle PCB outline (solid)
module pcb_slab() {
    r = 3.0;
    linear_extrude(height=thickness, center=true)
        offset(r=r)
            square([length-2*r, width-2*r], center=true);
}

// Edge anchors: guarantee edge parts are truly merged to PCB (overlap in X/Y and Z)
module edge_anchor_x(side="xn", y=0, z=0, ax=2.0, ay=8.0, az=3.0) {
    x = (side=="xn") ? (-length/2 + ax/2) : (length/2 - ax/2);
    translate([x, y, z]) cube([ax, ay, az], center=true);
}
module edge_anchor_y(side="yn", x=0, z=0, ax=8.0, ay=2.0, az=3.0) {
    y = (side=="yn") ? (-width/2 + ay/2) : (width/2 - ay/2);
    translate([x, y, z]) cube([ax, ay, az], center=true);
}

// Standoff/peg that is physically attached to PCB (no floating)
module standoff(x, y, h=6.0, r=2.2, side="top") {
    if (side=="top")
        translate([x, y, thickness/2 + h/2 - ov]) cylinder(r=r, h=h, center=true);
    else
        translate([x, y, -thickness/2 - h/2 + ov]) cylinder(r=r, h=h, center=true);
}

// NEW: side "port/connector" helper that guarantees attachment even if the visible block
// is positioned slightly outside the PCB in X/Y. This fixes the reported floating gray blocks.
module side_port_x(side="xn", y=0, x_len=8, y_len=6, z_h=5) {
    // Visible port body (protrudes out of PCB edge, but overlaps by ov)
    if (side=="xn")
        translate([-length/2 - x_len/2 + ov, y, thickness/2 + z_h/2 - ov])
            cube([x_len, y_len, z_h], center=true);
    else
        translate([ length/2 + x_len/2 - ov, y, thickness/2 + z_h/2 - ov])
            cube([x_len, y_len, z_h], center=true);

    // Anchor "tongue" inside PCB to ensure union connectivity (extra safety)
    edge_anchor_x(
        side=side,
        y=y,
        z=thickness/2 + z_h/2 - ov,
        ax=max(2.0, ov*2), ay=y_len, az=z_h
    );
}

module side_port_y(side="yn", x=0, x_len=10, y_len=6, z_h=5) {
    if (side=="yn")
        translate([x, -width/2 - y_len/2 + ov, thickness/2 + z_h/2 - ov])
            cube([x_len, y_len, z_h], center=true);
    else
        translate([x,  width/2 + y_len/2 - ov, thickness/2 + z_h/2 - ov])
            cube([x_len, y_len, z_h], center=true);

    edge_anchor_y(
        side=side,
        x=x,
        z=thickness/2 + z_h/2 - ov,
        ax=x_len, ay=max(2.0, ov*2), az=z_h
    );
}

module control_board_connected() {
    union() {
        // PCB
        color([0.0, 0.4, 0.2]) pcb_slab();

        // --- Edge connectors / major features ---

        // USB-B connector on X- edge
        usb_x = 16; usb_y = 14; usb_z = 11;
        color("DimGray") {
            on_edge_xn(usb_x, usb_z)
                translate([0, -width*0.18, 0])
                    cube([usb_x, usb_y, usb_z], center=true);

            // Anchor to guarantee USB touches PCB edge
            edge_anchor_x(
                side="xn",
                y=-width*0.18,
                z=thickness/2 + usb_z/2 - ov,
                ax=2.0, ay=usb_y, az=usb_z
            );
        }

        // DC power terminal block on X+ edge
        pwr_x = 16; pwr_y = 13; pwr_z = 12;
        color("ForestGreen") {
            on_edge_xp(pwr_x, pwr_z)
                translate([0, width*0.18, 0])
                    cube([pwr_x, pwr_y, pwr_z], center=true);

            // Anchor to guarantee power block touches PCB edge
            edge_anchor_x(
                side="xp",
                y=width*0.18,
                z=thickness/2 + pwr_z/2 - ov,
                ax=2.0, ay=pwr_y, az=pwr_z
            );
        }

        // Long top header row on Y+ edge (endstops/IO)
        hdr_x = length*0.78; hdr_y = 6.5; hdr_z = 8.5;
        color("Black") {
            on_edge_yp(hdr_y, hdr_z)
                cube([hdr_x, hdr_y, hdr_z], center=true);

            // Anchor strip to guarantee header touches PCB edge along Y+
            edge_anchor_y(
                side="yp",
                x=0,
                z=thickness/2 + hdr_z/2 - ov,
                ax=hdr_x, ay=2.0, az=hdr_z
            );
        }

        // Bottom edge header row on Y- edge (aux/expansion)
        bhdr_x = length*0.62; bhdr_y = 6.5; bhdr_z = 8.0;
        color("Black") {
            on_edge_yn(bhdr_y, bhdr_z)
                translate([-length*0.06, 0, 0])
                    cube([bhdr_x, bhdr_y, bhdr_z], center=true);

            // Anchor strip to guarantee bottom header touches PCB edge along Y-
            edge_anchor_y(
                side="yn",
                x=-length*0.06,
                z=thickness/2 + bhdr_z/2 - ov,
                ax=bhdr_x, ay=2.0, az=bhdr_z
            );
        }

        // SD-card-ish slot on Y- edge (thin)
        sd_x = 30; sd_y = 11; sd_z = 3.6;
        color("DimGray") {
            on_edge_yn(sd_y, sd_z)
                translate([length*0.28, 0, 0])
                    cube([sd_x, sd_y, sd_z], center=true);

            // Anchor to guarantee SD slot touches PCB edge
            edge_anchor_y(
                side="yn",
                x=length*0.28,
                z=thickness/2 + sd_z/2 - ov,
                ax=sd_x, ay=2.0, az=sd_z
            );
        }

        // Regulator/heatsink block near Y- edge
        hs_x = 18; hs_y = 10.5; hs_z = 6.5;
        color("DimGray") {
            on_edge_yn(hs_y, hs_z)
                translate([-length*0.28, 0, 0])
                    cube([hs_x, hs_y, hs_z], center=true);

            // Anchor to guarantee heatsink touches PCB edge
            edge_anchor_y(
                side="yn",
                x=-length*0.28,
                z=thickness/2 + hs_z/2 - ov,
                ax=hs_x, ay=2.0, az=hs_z
            );
        }

        // --- Component population (top) ---

        // Stepper driver sockets (5 blocks)
        drv_x = 18; drv_y = 22; drv_z = 9.5;
        drv_span = length*0.52;
        color("Black")
            for (i = [0:4]) {
                x = -drv_span/2 + i*(drv_span/4);
                on_top(drv_z)
                    translate([x, width*0.10, 0])
                        cube([drv_x, drv_y, drv_z], center=true);
            }

        // Main MCU chip (TQFP-ish)
        mcu_x = 20; mcu_y = 20; mcu_z = 3.2;
        color("Black")
            on_top(mcu_z)
                translate([-length*0.12, -width*0.06, 0])
                    cube([mcu_x, mcu_y, mcu_z], center=true);

        // Driver/logic IC cluster
        ic_z = 2.2;
        color("Black")
            for (p = [
                [-length*0.02, -width*0.18, 14, 10],
                [ length*0.10, -width*0.14, 12,  9],
                [ length*0.22, -width*0.06, 16, 11],
                [-length*0.24,  width*0.18, 12,  9],
                [ length*0.30,  width*0.18, 12,  9]
            ]) {
                on_top(ic_z)
                    translate([p[0], p[1], 0])
                        cube([p[2], p[3], ic_z], center=true);
            }

        // Electrolytic capacitor near power input
        cap_r = 6.0; cap_z = 13.0;
        color("DimGray")
            on_top(cap_z)
                translate([length*0.36, -width*0.10, 0])
                    cylinder(r=cap_r, h=cap_z, center=true);

        // Reset button near USB
        btn_x = 6.5; btn_y = 6.5; btn_z = 3.2;
        color("Gray")
            on_top(btn_z)
                translate([-length*0.42, -width*0.18, 0])
                    cube([btn_x, btn_y, btn_z], center=true);

        // Crystal can near MCU
        xtal_x = 10; xtal_y = 4.5; xtal_z = 3.0;
        color("DimGray")
            on_top(xtal_z)
                translate([-length*0.06, -width*0.02, 0])
                    cube([xtal_x, xtal_y, xtal_z], center=true);

        // --- Bottom-side features (connected via on_bottom overlap) ---

        // Two underside connector blocks
        ublk_x = 18; ublk_y = 12; ublk_z = 6.0;
        color("DimGray")
            for (xpos = [-length*0.18, length*0.10]) {
                on_bottom(ublk_z)
                    translate([xpos, width*0.02, 0])
                        cube([ublk_x, ublk_y, ublk_z], center=true);
            }

        // Underside long block
        ustrip_x = length*0.46; ustrip_y = 7.0; ustrip_z = 4.0;
        color("Black")
            on_bottom(ustrip_z)
                translate([length*0.02, 0, 0])
                    cube([ustrip_x, ustrip_y, ustrip_z], center=true);

        // --- Small edge tabs / protrusions (ensure attached) ---

        // Small side tab on X- (USB shield lip)
        tab_x = 6; tab_y = 10; tab_z = 4;
        color("DimGray") {
            translate([-length/2 - tab_x/2 + ov, -width*0.18, thickness/2 + tab_z/2 - ov])
                cube([tab_x, tab_y, tab_z], center=true);

            // Anchor for X- tab
            edge_anchor_x(
                side="xn",
                y=-width*0.18,
                z=thickness/2 + tab_z/2 - ov,
                ax=2.0, ay=tab_y, az=tab_z
            );
        }

        // Small side tab on X+ (terminal latch)
        tab2_x = 6; tab2_y = 10; tab2_z = 4;
        color("ForestGreen") {
            translate([ length/2 + tab2_x/2 - ov,  width*0.18, thickness/2 + tab2_z/2 - ov])
                cube([tab2_x, tab2_y, tab2_z], center=true);

            // Anchor for X+ tab
            edge_anchor_x(
                side="xp",
                y=width*0.18,
                z=thickness/2 + tab2_z/2 - ov,
                ax=2.0, ay=tab2_y, az=tab2_z
            );
        }

        // --- Standoffs/pegs (top & bottom) ---
        peg_h = 6.0; peg_r = 2.2;
        color("DimGray") {
            // Top pegs
            standoff(-length*0.20,  width*0.22, h=peg_h, r=peg_r, side="top");
            standoff( length*0.05,  width*0.22, h=peg_h, r=peg_r, side="top");
            standoff( length*0.30, -width*0.20, h=peg_h, r=peg_r, side="top");

            // Bottom pegs
            standoff(-length*0.10, -width*0.22, h=peg_h, r=peg_r, side="bottom");
            standoff( length*0.22,  width*0.00, h=peg_h, r=peg_r, side="bottom");
        }

        // --- FIX: multiple gray connector/port-like blocks along PCB edges ---
        // Ensure they are NOT floating: each is built with a visible block + an anchor tongue.
        port_x = 8; port_y = 6; port_z = 5;
        color("DimGray") {
            // Left end (X-)
            side_port_x(side="xn", y=0, x_len=port_x, y_len=port_y, z_h=port_z);

            // Right end (X+)
            side_port_x(side="xp", y=0, x_len=port_x, y_len=port_y, z_h=port_z);

            // Additional small side ports on Y edges (common "port-like" protrusions)
            // These address the reported multiple gray blocks that looked separated in top/bottom views.
            side_port_y(side="yp", x=-length*0.34, x_len=10, y_len=6, z_h=5);
            side_port_y(side="yp", x= length*0.34, x_len=10, y_len=6, z_h=5);
            side_port_y(side="yn", x= 0,          x_len=10, y_len=6, z_h=5);
        }

        // --- Black rectangular component blocks on top/bottom faces (explicitly flush) ---
        blk_x = 26; blk_y = 10; blk_z = 3.0;
        color("Black") {
            on_top(blk_z)
                translate([ length*0.40,  width*0.02, 0])
                    cube([blk_x, blk_y, blk_z], center=true);

            on_bottom(blk_z)
                translate([-length*0.34, -width*0.02, 0])
                    cube([blk_x, blk_y, blk_z], center=true);
        }
    }
}

control_board_connected();