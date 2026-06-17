$fn = 48;

// Relay module overall PCB
pcb_length = 50.0;
pcb_width  = 26.0;
pcb_thick  = 1.6;

// Overlap to guarantee one connected solid (1–2mm as required)
overlap = 1.2;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1, center=true) {
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=center);
        sphere(r=r);
    }
}

// ---------- Parts ----------
module pcb() {
    cube([pcb_length, pcb_width, pcb_thick], center=true);
}

module relay_block() {
    // Typical Songle-style relay body (approx)
    relay_l = 19.0;
    relay_w = 15.5;
    relay_h = 15.5;
    relay_r = 1.2;

    // Place on top of PCB, near one end
    x_pos = -pcb_length/2 + 6.0 + relay_l/2;

    // Ensure physical intersection with PCB by sinking into it by 'overlap'
    z_pos = pcb_thick/2 + relay_h/2 - overlap;

    translate([x_pos, 0, z_pos])
        rounded_box([relay_l, relay_w, relay_h], r=relay_r, center=true);
}

module screw_terminal_3p() {
    // 3-position screw terminal block (approx)
    term_l = 15.0;
    term_w = 10.0;
    term_h = 12.0;

    // Along one long edge, near opposite end from relay
    x_pos = pcb_length/2 - 4.0 - term_l/2;
    y_pos = pcb_width/2 - term_w/2;

    // Sink into PCB for guaranteed attachment
    z_pos = pcb_thick/2 + term_h/2 - overlap;

    translate([x_pos, y_pos, z_pos])
        cube([term_l, term_w, term_h], center=true);
}

module pin_header_3() {
    // 3-pin header (approx)
    hdr_l = 7.6;   // 3 * 2.54
    hdr_w = 5.0;
    hdr_h = 8.0;

    // Along opposite long edge, near same end as terminal
    x_pos = pcb_length/2 - 4.0 - hdr_l/2;
    y_pos = -pcb_width/2 + hdr_w/2;

    // Sink into PCB for guaranteed attachment
    z_pos = pcb_thick/2 + hdr_h/2 - overlap;

    translate([x_pos, y_pos, z_pos])
        cube([hdr_l, hdr_w, hdr_h], center=true);
}

module led_bump() {
    // Small indicator LED lens bump (approx)
    led_r = 2.0;
    led_h = 1.8;

    x_pos = -pcb_length/2 + 6.0;
    y_pos = -pcb_width/2 + 6.0;

    // Sink into PCB for guaranteed attachment
    z_pos = pcb_thick/2 + led_h/2 - overlap;

    translate([x_pos, y_pos, z_pos])
        cylinder(h=led_h, r=led_r, center=true);
}

module standoff_bumps() {
    // Small bumps to suggest mounting holes (kept solid, not holes)
    bump_r = 2.2;
    bump_h = 1.2;

    // Sink into PCB for guaranteed attachment
    z_pos = pcb_thick/2 + bump_h/2 - overlap;

    for (sx = [-1, 1], sy = [-1, 1]) {
        x_pos = sx*(pcb_length/2 - 4.0);
        y_pos = sy*(pcb_width/2  - 4.0);
        translate([x_pos, y_pos, z_pos])
            cylinder(h=bump_h, r=bump_r, center=true);
    }
}

// --- FIX: add an explicit connector "foot" under the relay to eliminate any chance of a gap ---
// This guarantees the teal relay block is physically merged to the PCB even if rounding/minkowski
// causes a tiny separation in some slicers/viewers.
module relay_connector_foot() {
    relay_l = 19.0;
    relay_w = 15.5;

    // Slightly smaller than relay footprint, and extends into PCB by overlap
    foot_l = relay_l - 2.0;
    foot_w = relay_w - 2.0;

    // Make the foot span from slightly above PCB top down into PCB by overlap
    // Total height ensures intersection with both PCB and relay body.
    foot_h = overlap + 1.0; // within 1–2mm overlap requirement

    x_pos = -pcb_length/2 + 6.0 + relay_l/2;
    y_pos = 0;

    // Center the foot so its bottom goes into PCB by overlap
    // Bottom = (pcb_thick/2) - overlap
    // So center z = (pcb_thick/2 - overlap) + foot_h/2
    z_pos = (pcb_thick/2 - overlap) + foot_h/2;

    translate([x_pos, y_pos, z_pos])
        cube([foot_l, foot_w, foot_h], center=true);
}

// ---------- Assembly (ONE connected solid) ----------
union() {
    pcb();

    // Ensure relay is attached with a guaranteed overlapping connector
    relay_connector_foot();
    relay_block();

    screw_terminal_3p();
    pin_header_3();
    led_bump();
    standoff_bumps();
}