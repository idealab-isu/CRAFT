// Relay module (approx) - 50.0mm x 26.0mm PCB, 1.6mm thick
// STRUCTURAL FIX: ensure ALL parts physically intersect the PCB (and/or each other)
// with 1–2mm overlap, and everything is combined in a single union().

$fn = 48;

// --- Core dimensions (requested) ---
length = 50.0;
width  = 26.0;
thickness = 1.6;

// --- Connectivity parameters ---
overlap = 1.5;                 // 1–2mm overlap to guarantee connectivity
corner_r = 1.2;                // PCB corner radius (visual)

// Mounting holes (typical 2-hole relay module)
hole_enable = 1;
hole_diameter = 3.0;
hole_edge_offset_x = 3.0;
hole_edge_offset_y = 3.0;

// Relay block (typical SRD-05VDC-SL-C footprint-ish)
relay_len = 19.0;
relay_wid = 15.5;
relay_h   = 15.5;

// Terminal block (3-position screw terminal)
term_len = 15.0;
term_wid = 8.5;
term_h   = 10.0;

// Pin header (3-pin)
hdr_pins = 3;
hdr_pitch = 2.54;
hdr_body_len = hdr_pitch*(hdr_pins-1) + 3.0;
hdr_body_wid = 5.0;
hdr_body_h   = 3.0;

// Small components (LED + transistor-ish bump)
led_r = 1.6;
led_h = 1.2;
ic_len = 6.0;
ic_wid = 5.0;
ic_h   = 2.0;

// ---------- Helpers ----------
module rounded_rect_prism(l, w, h, r) {
    rr = min(r, min(l, w)/2 - 0.01);
    minkowski() {
        cube([l - 2*rr, w - 2*rr, h], center=true);
        cylinder(r=rr, h=0.01, center=true);
    }
}

// Post that *bridges* PCB and component above it.
// Bottom goes into PCB by `overlap`, top goes into component by `overlap`.
module attach_post(x, y, post_xy=2.2, post_h=thickness + 2*overlap) {
    // Center so it spans from (PCB top - overlap) down into PCB and up above PCB.
    // With center=true, z_center at PCB top gives symmetric span.
    translate([x, y, thickness/2])
        cube([post_xy, post_xy, post_h], center=true);
}

// Compute a Z center for a component sitting on PCB top with guaranteed overlap.
function z_on_pcb(h) = thickness/2 + h/2 - overlap;

module pcb_board() {
    color([0.0, 0.4, 0.2])
        rounded_rect_prism(length, width, thickness, corner_r);
}

module mounting_holes_2() {
    xL = -length/2 + hole_edge_offset_x;
    xR =  length/2 - hole_edge_offset_x;
    yC = 0;

    translate([xL, yC, 0])
        cylinder(r=hole_diameter/2, h=thickness + 2*overlap, center=true);
    translate([xR, yC, 0])
        cylinder(r=hole_diameter/2, h=thickness + 2*overlap, center=true);
}

module pcb_with_holes() {
    if (hole_enable) {
        difference() {
            pcb_board();
            mounting_holes_2();
        }
    } else {
        pcb_board();
    }
}

// ---------- Components (all connected to PCB top with guaranteed overlap) ----------
module relay_block() {
    x = -length/2 + 6.0 + relay_len/2;
    y = 0;
    z = z_on_pcb(relay_h);

    // Main relay body (must intersect PCB by overlap)
    color([0.1, 0.1, 0.6])
        translate([x, y, z])
            cube([relay_len, relay_wid, relay_h], center=true);

    // Two bridging posts (guarantee fusion in side views)
    attach_post(x - relay_len*0.25, y, post_xy=2.4);
    attach_post(x + relay_len*0.25, y, post_xy=2.4);
}

module terminal_block() {
    // Keep within PCB: right edge of terminal slightly inset from PCB edge
    x = length/2 - term_len/2 - 0.5;
    y = 0;
    z = z_on_pcb(term_h);

    // Terminal body (must intersect PCB by overlap)
    color([0.0, 0.55, 0.0])
        translate([x, y, z])
            cube([term_len, term_wid, term_h], center=true);

    // Bridging posts (guarantee fusion in side views)
    attach_post(x - term_len*0.25, y, post_xy=2.2);
    attach_post(x + term_len*0.25, y, post_xy=2.2);

    // Screw bumps (3) - intersect terminal body slightly
    screw_r = 1.4;
    screw_h = 1.8;
    for (i = [0:2]) {
        xi = x - term_len/2 + (i + 0.5) * (term_len/3);
        zi = (thickness/2 + term_h) - screw_h/2 - overlap; // overlaps into terminal
        color([0.7, 0.7, 0.7])
            translate([xi, 0, zi])
                cylinder(r=screw_r, h=screw_h, center=true);
    }
}

module pin_header() {
    // Place between relay and terminal, near bottom edge, fully on PCB
    x = length/2 - term_len - 4.0 - hdr_body_len/2;
    y = -width/2 + 2.0 + hdr_body_wid/2;
    z_body = z_on_pcb(hdr_body_h);

    // Plastic body (must intersect PCB by overlap)
    color([0.05, 0.05, 0.05])
        translate([x, y, z_body])
            cube([hdr_body_len, hdr_body_wid, hdr_body_h], center=true);

    // Bridging post under header body (guarantees PCB<->header connection)
    attach_post(x, y, post_xy=2.2);

    // Pins: ensure they intersect BOTH the header body and the PCB (not just pass near)
    pin_r = 0.6;
    // Make pins long enough to go into PCB and up through header body
    pin_h = thickness + hdr_body_h + 4.0; // extra protrusion above
    // Center pins so they extend below PCB top into PCB by overlap
    // Bottom target: (PCB top - overlap - (pin_h - (hdr_body_h+2))) not needed; just ensure center is low enough:
    z_pin = thickness/2 + (hdr_body_h/2) - overlap; // guarantees intersection with header body and PCB

    for (i = [0:hdr_pins-1]) {
        xi = x - hdr_body_len/2 + 1.5 + i*hdr_pitch;

        color([0.85, 0.7, 0.2])
            translate([xi, y, z_pin])
                cylinder(r=pin_r, h=pin_h, center=true);

        // Collar that overlaps into header body to avoid tangency-only contact
        color([0.85, 0.7, 0.2])
            translate([xi, y, thickness/2 + hdr_body_h/2 - overlap])
                cylinder(r=pin_r+0.25, h=1.4, center=true);
    }
}

module small_parts() {
    // LED near right-middle
    x_led = length/2 - term_len - 6.0;
    y_led = width/2 - 5.0;
    z_led = z_on_pcb(led_h);

    color([0.9, 0.1, 0.1])
        translate([x_led, y_led, z_led])
            cylinder(r=led_r, h=led_h, center=true);

    // Bridging post for LED
    attach_post(x_led, y_led, post_xy=1.9);

    // Small IC/transistor bump
    x_ic = -length/2 + 6.0 + relay_len + 4.0 + ic_len/2;
    y_ic = -width/2 + 6.0 + ic_wid/2;
    z_ic = z_on_pcb(ic_h);

    color([0.15, 0.15, 0.15])
        translate([x_ic, y_ic, z_ic])
            cube([ic_len, ic_wid, ic_h], center=true);

    // Bridging post for IC
    attach_post(x_ic, y_ic, post_xy=2.0);
}

// ---------- Final assembly (single connected solid) ----------
module assembly() {
    union() {
        pcb_with_holes();

        // All components are unioned and have guaranteed intersection with PCB
        relay_block();
        terminal_block();
        pin_header();
        small_parts();
    }
}

assembly();