$fn=64;

eps = 0.001;

// Bounding box (mm)
L = 0.1;
W = 0.1;
T = 0.01;  // flat/plate-like thickness

// Frame parameters
frame_wall = 0.02;
window_L = L - 2*frame_wall;
window_W = W - 2*frame_wall;

// End block (thicker region on one side)
end_block_L = 0.03;
end_block_extra = 0.01; // extra thickness over base plate
end_block_T = T + end_block_extra;

// Cantilever tab / hook parameters (protrudes into opening from end block side)
tab_len = 0.028;
tab_w = 0.03;
tab_t = 0.008;
tab_angle = -18; // downward into opening

// Undercut-like gap (visible from top/bottom)
gap_len = 0.018;
gap_w = 0.022;
gap_t = 0.004;

// Small step at tab tip to form latch lip
lip_len = 0.006;
lip_drop = 0.003;

module base_frame() {
  difference() {
    cube([L, W, T], center=true);
    cube([window_L, window_W, T + 2*eps], center=true);
  }
}

module end_block() {
  translate([L/2 - end_block_L/2, 0, (end_block_T - T)/2])
    cube([end_block_L, W, end_block_T], center=true);
}

module cantilever_tab() {
  // Anchor near inner edge of end block, extending into window
  anchor_x = (L/2 - end_block_L) + frame_wall/2;
  translate([anchor_x, 0, 0]) {
    // Main tab
    rotate([0, tab_angle, 0])
      translate([-tab_len/2, 0, (T/2 + tab_t/2 - 0.001)])
        cube([tab_len, tab_w, tab_t], center=true);

    // Lip/step at tip
    rotate([0, tab_angle, 0])
      translate([-tab_len + lip_len/2, 0, (T/2 + tab_t/2 - 0.001) - lip_drop])
        cube([lip_len, tab_w*0.9, tab_t], center=true);
  }
}

module undercut_gap() {
  // Carve a gap under the tab to suggest undercut-like feature
  anchor_x = (L/2 - end_block_L) + frame_wall/2;
  translate([anchor_x, 0, 0]) {
    rotate([0, tab_angle, 0])
      translate([-gap_len/2 - 0.006, 0, (T/2 + gap_t/2 - 0.001)])
        cube([gap_len, gap_w, gap_t], center=true);
  }
}

difference() {
  union() {
    base_frame();
    end_block();
    cantilever_tab();
  }
  undercut_gap();
}