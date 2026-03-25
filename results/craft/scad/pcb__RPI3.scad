// Single-board computer (RPI3-like) - 85.0mm x 56.0mm x 1.4mm PCB with connected components
// FIX: Ensure ALL parts are physically connected (no floating), side parts have joining geometry,
// and everything is fused into ONE solid via union() with 1–2mm overlaps.

$fn = 48;

// Parameters
length = 85.0;
width  = 56.0;
thickness = 1.4;

// Structural overlap to guarantee fusion (1–2mm as required)
overlap = 1.2;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_prism(l, w, h, r) {
    r2 = clamp(r, 0, min(l, w)/2);
    linear_extrude(height=h, center=true)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

// Places a part on top of PCB with guaranteed intersection into PCB by 'overlap'
module part_on_top(size=[10,10,5], pos=[0,0], z_top=0) {
    // z_top is the PCB top surface Z
    translate([pos[0], pos[1], z_top + size[2]/2 - overlap])
        cube(size, center=true);
}

module part_on_top_rr(size=[10,10,5], r=1, pos=[0,0], z_top=0) {
    translate([pos[0], pos[1], z_top + size[2]/2 - overlap])
        rounded_rect_prism(size[0], size[1], size[2], r);
}

// Adds a "solder/pin" joining block that bridges a side connector into the PCB volume.
// This fixes side-mounted blocks that otherwise only touch by proximity or extend beyond outline.
module side_joiner(x_edge, y, z_top, join_w=3.0, join_d=10.0, join_h=thickness + 4.0) {
    // Centered so it intersects PCB (down into PCB by overlap) and intersects connector body.
    // join_h spans above and into PCB to guarantee union.
    translate([x_edge, y, z_top + (join_h/2) - overlap])
        cube([join_w, join_d, join_h], center=true);
}

module RPI3_like() {
    pcb_center_z = thickness/2;     // PCB is centered at this Z
    pcb_top_z    = thickness;       // PCB top surface Z (since PCB spans 0..thickness)

    union() {
        // PCB (slightly rounded corners)
        color([0.0, 0.4, 0.2])
            translate([0,0,pcb_center_z])
                rounded_rect_prism(length, width, thickness, r=3);

        // --- Major connectors (approximate, RPI3-like) ---
        // USB stack (2x USB) on one long edge
        usb_w = 17.0;
        usb_d = 16.0;
        usb_h = 15.0;
        usb_x = length/2 - usb_w/2;
        usb_y = width/2 - usb_d/2;
        part_on_top_rr([usb_w, usb_d, usb_h], r=1.2, pos=[usb_x, usb_y], z_top=pcb_top_z);

        // Add joiner "pins/solder" into PCB for USB (ensures visible joining geometry)
        side_joiner(x_edge=length/2 - 1.0, y=usb_y, z_top=pcb_top_z, join_w=4.0, join_d=usb_d-2.0, join_h=thickness+6.0);

        // Ethernet jack next to USB
        eth_w = 21.0;
        eth_d = 16.0;
        eth_h = 14.0;
        eth_x = length/2 - eth_w/2;
        eth_y = usb_y - (usb_d/2 + eth_d/2) + 1.0;
        part_on_top_rr([eth_w, eth_d, eth_h], r=1.2, pos=[eth_x, eth_y], z_top=pcb_top_z);

        // Joiner for Ethernet
        side_joiner(x_edge=length/2 - 1.0, y=eth_y, z_top=pcb_top_z, join_w=4.0, join_d=eth_d-2.0, join_h=thickness+6.0);

        // 40-pin GPIO header along top edge
        gpio_w = 51.0;
        gpio_d = 5.5;
        gpio_h = 8.5;
        gpio_x = -length/2 + 10 + gpio_w/2;
        gpio_y = width/2 - gpio_d/2;
        part_on_top([gpio_w, gpio_d, gpio_h], pos=[gpio_x, gpio_y], z_top=pcb_top_z);

        // HDMI connector on bottom edge
        hdmi_w = 15.0;
        hdmi_d = 11.5;
        hdmi_h = 6.0;
        hdmi_x = -length/2 + 32.0;
        hdmi_y = -width/2 + hdmi_d/2;
        part_on_top_rr([hdmi_w, hdmi_d, hdmi_h], r=0.8, pos=[hdmi_x, hdmi_y], z_top=pcb_top_z);

        // Joiner for HDMI (bottom edge)
        side_joiner(x_edge=hdmi_x, y=-width/2 + 1.0, z_top=pcb_top_z, join_w=hdmi_w-4.0, join_d=4.0, join_h=thickness+5.0);

        // Micro-USB power on bottom edge (left of HDMI)
        pwr_w = 8.0;
        pwr_d = 7.0;
        pwr_h = 4.0;
        pwr_x = hdmi_x - hdmi_w/2 - pwr_w/2 - 2.0;
        pwr_y = -width/2 + pwr_d/2;
        part_on_top_rr([pwr_w, pwr_d, pwr_h], r=0.8, pos=[pwr_x, pwr_y], z_top=pcb_top_z);

        // Joiner for power
        side_joiner(x_edge=pwr_x, y=-width/2 + 1.0, z_top=pcb_top_z, join_w=pwr_w-2.0, join_d=4.0, join_h=thickness+4.5);

        // 3.5mm audio jack on bottom edge (right side)
        aud_w = 12.0;
        aud_d = 12.0;
        aud_h = 10.0;
        aud_x = length/2 - 18.0;
        aud_y = -width/2 + aud_d/2;
        part_on_top_rr([aud_w, aud_d, aud_h], r=1.0, pos=[aud_x, aud_y], z_top=pcb_top_z);

        // Joiner for audio
        side_joiner(x_edge=aud_x, y=-width/2 + 1.0, z_top=pcb_top_z, join_w=aud_w-3.0, join_d=4.0, join_h=thickness+6.0);

        // CSI camera connector (top edge, near left)
        csi_w = 22.0;
        csi_d = 5.0;
        csi_h = 3.0;
        csi_x = -length/2 + 12.0;
        csi_y = width/2 - csi_d/2 - 10.0;
        part_on_top([csi_w, csi_d, csi_h], pos=[csi_x, csi_y], z_top=pcb_top_z);

        // DSI display connector (top edge, near center-left)
        dsi_w = 22.0;
        dsi_d = 5.0;
        dsi_h = 3.0;
        dsi_x = -length/2 + 12.0;
        dsi_y = width/2 - dsi_d/2 - 18.0;
        part_on_top([dsi_w, dsi_d, dsi_h], pos=[dsi_x, dsi_y], z_top=pcb_top_z);

        // --- Main chips (approximate) ---
        // SoC
        soc_w = 14.0;
        soc_d = 14.0;
        soc_h = 2.2;
        soc_x = 5.0;
        soc_y = 2.0;
        part_on_top_rr([soc_w, soc_d, soc_h], r=0.8, pos=[soc_x, soc_y], z_top=pcb_top_z);

        // RAM
        ram_w = 12.0;
        ram_d = 12.0;
        ram_h = 1.8;
        ram_x = soc_x - soc_w/2 - ram_w/2 + 1.0;
        ram_y = soc_y;
        part_on_top_rr([ram_w, ram_d, ram_h], r=0.8, pos=[ram_x, ram_y], z_top=pcb_top_z);

        // USB/Ethernet controller
        ctrl_w = 10.0;
        ctrl_d = 10.0;
        ctrl_h = 1.6;
        ctrl_x = length/2 - 30.0;
        ctrl_y = 5.0;
        part_on_top_rr([ctrl_w, ctrl_d, ctrl_h], r=0.6, pos=[ctrl_x, ctrl_y], z_top=pcb_top_z);

        // --- Small components cluster (kept connected) ---
        cap_w = 2.2;
        cap_d = 1.6;
        cap_h = 1.2;
        for (dx = [-6, -3, 0, 3, 6]) {
            part_on_top([cap_w, cap_d, cap_h], pos=[soc_x + dx, soc_y - 10.0], z_top=pcb_top_z);
        }

        // MicroSD slot (simplified)
        sd_w = 16.0;
        sd_d = 14.0;
        sd_h = 2.0;
        sd_x = -length/2 + sd_w/2 + 2.0;
        sd_y = -width/2 + sd_d/2 + 8.0;
        part_on_top_rr([sd_w, sd_d, sd_h], r=0.8, pos=[sd_x, sd_y], z_top=pcb_top_z);

        // --- Edge/side connector blocks (fix floating/disconnected appearance) ---
        // Left long edge block: ensure it actually intersects PCB (not just "near" it)
        edge1_w = 6.0;
        edge1_d = 44.0;
        edge1_h = 9.0;

        // Place slightly INTO the PCB outline so there is guaranteed overlap in X as well.
        // (This prevents "sitting beside" the PCB when viewed from side.)
        edge1_x = -length/2 + edge1_w/2 - 0.8; // 0.8mm inboard overlap
        edge1_y = 0;
        part_on_top([edge1_w, edge1_d, edge1_h], pos=[edge1_x, edge1_y], z_top=pcb_top_z);

        // Add joiner strip along left edge to show physical attachment
        side_joiner(x_edge=-length/2 + 1.0, y=edge1_y, z_top=pcb_top_z, join_w=4.0, join_d=edge1_d-4.0, join_h=thickness+7.0);

        // Two narrow bottom-left vertical blocks
        bl_w = 5.0;
        bl_d = 18.0;
        bl_h = 8.0;
        bl_y = -width/2 + bl_d/2 + 3.0;
        bl_x1 = -length/2 + 18.0;
        bl_x2 = bl_x1 + 8.0;
        part_on_top([bl_w, bl_d, bl_h], pos=[bl_x1, bl_y], z_top=pcb_top_z);
        part_on_top([bl_w, bl_d, bl_h], pos=[bl_x2, bl_y], z_top=pcb_top_z);

        // Joiners for bottom-left blocks (ensures they are visibly fused to PCB)
        side_joiner(x_edge=bl_x1, y=-width/2 + 1.0, z_top=pcb_top_z, join_w=bl_w-1.0, join_d=4.0, join_h=thickness+5.0);
        side_joiner(x_edge=bl_x2, y=-width/2 + 1.0, z_top=pcb_top_z, join_w=bl_w-1.0, join_d=4.0, join_h=thickness+5.0);

        // Large right-side connector block
        rcon_w = 18.0;
        rcon_d = 22.0;
        rcon_h = 18.0;

        // Pull slightly INBOARD in X so it overlaps PCB outline (prevents "beyond outline" disconnect)
        rcon_x = length/2 - rcon_w/2 + 0.8; // 0.8mm inboard overlap
        rcon_y = 6.0;
        part_on_top_rr([rcon_w, rcon_d, rcon_h], r=1.2, pos=[rcon_x, rcon_y], z_top=pcb_top_z);

        // Joiner for right-side connector (pins/solder block into PCB)
        side_joiner(x_edge=length/2 - 1.0, y=rcon_y, z_top=pcb_top_z, join_w=4.0, join_d=rcon_d-4.0, join_h=thickness+10.0);

        // Small right-edge mid block
        rmid_w = 12.0;
        rmid_d = 12.0;
        rmid_h = 10.0;

        // Slightly inboard overlap in X
        rmid_x = length/2 - rmid_w/2 + 0.8;
        rmid_y = -10.0;
        part_on_top_rr([rmid_w, rmid_d, rmid_h], r=1.0, pos=[rmid_x, rmid_y], z_top=pcb_top_z);

        // Joiner for right mid block
        side_joiner(x_edge=length/2 - 1.0, y=rmid_y, z_top=pcb_top_z, join_w=4.0, join_d=rmid_d-3.0, join_h=thickness+7.0);

        // Small bottom-right block
        br_w = 10.0;
        br_d = 8.0;
        br_h = 6.0;
        br_x = length/2 - br_w/2 - 6.0;
        br_y = -width/2 + br_d/2 + 10.0;
        part_on_top([br_w, br_d, br_h], pos=[br_x, br_y], z_top=pcb_top_z);

        // Joiner for bottom-right block (bottom edge)
        side_joiner(x_edge=br_x, y=-width/2 + 1.0, z_top=pcb_top_z, join_w=br_w-2.0, join_d=4.0, join_h=thickness+4.5);
    }
}

// Assembly
RPI3_like();