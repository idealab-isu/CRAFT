$fn = 64;

//====================
// Parameters (mm)
//====================
pcb_L = 110.0;
pcb_W = 85.0;
pcb_T = 1.6;

corner_R = 4.0;

edge_margin = 6.0;
mount_hole_d = 3.2;

silk_T = 0.2;          // raised silkscreen thickness
overlap = 0.25;        // small overlap to guarantee one connected solid

// Component heights (kept modest so PCB thickness reads correctly)
conn_H = 9.0;
chip_H = 2.2;
heatsink_base_T = 1.6;
heatsink_H = 7.0;
heatsink_fin_T = 1.0;
heatsink_fin_gap = 1.6;

//====================
// Helpers
//====================
module rounded_rect_2d(L, W, R) {
  // 2D rounded rectangle centered at origin
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R), sy*(W/2 - R)]) circle(r=R);
  }
}

module pcb_solid() {
  linear_extrude(height=pcb_T, center=true)
    rounded_rect_2d(pcb_L, pcb_W, corner_R);
}

module mounting_holes() {
  // Through-holes (cut from PCB only)
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*(pcb_L/2 - edge_margin), sy*(pcb_W/2 - edge_margin), 0])
      cylinder(d=mount_hole_d, h=pcb_T + 2, center=true);
}

// Place a component so its bottom slightly intersects the PCB top surface
module place_on_top(z_h) {
  translate([0, 0, pcb_T/2 + z_h/2 - overlap]) children();
}

// Place a component so its top slightly intersects the PCB bottom surface
module place_on_bottom(z_h) {
  translate([0, 0, -pcb_T/2 - z_h/2 + overlap]) children();
}

//====================
// Features
//====================
module connectors() {
  // Left edge: USB-like connector
  usb_L = 14; usb_W = 12; usb_H = conn_H;
  translate([-(pcb_L/2 - usb_L/2), 0, 0])
    place_on_top(usb_H)
      cube([usb_L, usb_W, usb_H], center=true);

  // Top edge: power terminal block
  pwr_L = 18; pwr_W = 12; pwr_H = conn_H;
  translate([pcb_L/2 - pwr_L/2, pcb_W/2 - pwr_W/2 - 8, 0])
    place_on_top(pwr_H)
      cube([pwr_L, pwr_W, pwr_H], center=true);

  // Bottom edge: long pin header
  hdr_L = 44; hdr_W = 7; hdr_H = 6.5;
  translate([0, -(pcb_W/2 - hdr_W/2), 0])
    place_on_top(hdr_H)
      cube([hdr_L, hdr_W, hdr_H], center=true);

  // Right edge: stepper driver sockets (3 blocks)
  sock_L = 14; sock_W = 10; sock_H = 7.5;
  sock_y = pcb_W/2 - sock_W/2 - 18;
  for (i = [-1, 0, 1]) {
    translate([pcb_L/2 - sock_L/2, sock_y + i*(sock_W + 4), 0])
      place_on_top(sock_H)
        cube([sock_L, sock_W, sock_H], center=true);
  }
}

module chips_and_passives() {
  // Main MCU
  mcu = [22, 22, chip_H];
  translate([pcb_L*0.10, 0, 0])
    place_on_top(mcu[2])
      cube(mcu, center=true);

  // Driver ICs (row)
  drv = [12, 12, chip_H];
  x0 = -pcb_L*0.18;
  y0 = -pcb_W*0.18;
  for (i = [0:3]) {
    translate([x0 + i*(drv[0] + 6), y0, 0])
      place_on_top(drv[2])
        cube(drv, center=true);
  }

  // Capacitors (cylinders)
  cap_d = 8; cap_h = 8;
  for (p = [[-pcb_L*0.30, pcb_W*0.22],
            [-pcb_L*0.22, pcb_W*0.28],
            [ pcb_L*0.28, pcb_W*0.18]]) {
    translate([p[0], p[1], 0])
      place_on_top(cap_h)
        cylinder(d=cap_d, h=cap_h, center=true);
  }

  // Small regulator block
  reg = [10, 8, 3.0];
  translate([pcb_L*0.30, -pcb_W*0.28, 0])
    place_on_top(reg[2])
      cube(reg, center=true);
}

module heatsinks() {
  // Heatsink 1 (base + fins)
  hs1_base = [18, 18, heatsink_base_T];
  hs1_finH = heatsink_H;
  hs1_x = -pcb_L*0.25;
  hs1_y = 0;

  translate([hs1_x, hs1_y, 0])
    place_on_top(hs1_base[2])
      cube(hs1_base, center=true);

  // fins sit on base; ensure overlap with base
  fin_L = hs1_base[0];
  fin_W = heatsink_fin_T;
  fin_H = hs1_finH;
  fin_z = pcb_T/2 + hs1_base[2] + fin_H/2 - overlap;

  for (k = [-1, 1]) {
    translate([hs1_x, hs1_y + k*(heatsink_fin_gap/2 + fin_W/2), fin_z])
      cube([fin_L, fin_W, fin_H], center=true);
  }

  // Heatsink 2
  hs2_base = [16, 16, heatsink_base_T];
  hs2_x = pcb_L*0.28;
  hs2_y = -pcb_W*0.18;

  translate([hs2_x, hs2_y, 0])
    place_on_top(hs2_base[2])
      cube(hs2_base, center=true);

  fin2_L = hs2_base[0];
  fin2_W = heatsink_fin_T;
  fin2_H = heatsink_H;
  fin2_z = pcb_T/2 + hs2_base[2] + fin2_H/2 - overlap;

  for (k = [-1, 1]) {
    translate([hs2_x, hs2_y + k*(heatsink_fin_gap/2 + fin2_W/2), fin2_z])
      cube([fin2_L, fin2_W, fin2_H], center=true);
  }
}

module silkscreen_plate() {
  // Slightly inset raised plate to read as silkscreen; overlaps PCB
  inset = 2*edge_margin;
  Ls = pcb_L - inset;
  Ws = pcb_W - inset;

  translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
    linear_extrude(height=silk_T, center=true)
      rounded_rect_2d(Ls, Ws, max(0.5, corner_R - 1.0));
}

module bottom_details() {
  // A few underside SMD blocks to make bottom view non-flat
  smd1 = [18, 10, 1.2];
  smd2 = [14, 8, 1.0];
  smd3 = [10, 6, 1.0];

  translate([-pcb_L*0.30, -pcb_W*0.25, 0])
    place_on_bottom(smd1[2])
      cube(smd1, center=true);

  translate([ pcb_L*0.22,  pcb_W*0.22, 0])
    place_on_bottom(smd2[2])
      cube(smd2, center=true);

  translate([ pcb_L*0.34, -pcb_W*0.05, 0])
    place_on_bottom(smd3[2])
      cube(smd3, center=true);
}

//====================
// Final assembly (ONE connected solid)
//====================
module mainboard() {
  union() {
    // PCB with holes
    difference() {
      pcb_solid();
      mounting_holes();
    }

    // Top-side features (all overlap into PCB)
    connectors();
    chips_and_passives();
    heatsinks();
    silkscreen_plate();

    // Bottom-side features (overlap into PCB)
    bottom_details();
  }
}

color([0.0, 0.4, 0.2])
mainboard();