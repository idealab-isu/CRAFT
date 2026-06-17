// PCB: 21.0mm x 18.0mm x 1.2mm (one connected solid)

// Parameters
pcb_length = 21.0;
pcb_width  = 18.0;
pcb_thickness = 1.2;

corner_radius = 2.0;

mount_hole_diameter = 2.2;
mount_hole_edge_offset = 3.0;

pad_diameter = 1.6;
pad_thickness = 0.05;

silk_line_width = 0.4;
silk_thickness = 0.05;
silk_margin = 1.0;

finger_count = 6;
finger_width = 1.5;
finger_length = 4.0;
finger_thickness = 0.05;

feature_overlap = 0.6;   // overlap to guarantee watertight unions/differences
$fn = 64;

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded rectangle prism using linear_extrude of a 2D rounded rectangle
module rounded_rect_prism(L, W, H, R) {
  R2 = clamp(R, 0, min(L, W)/2);
  linear_extrude(height=H, center=true, convexity=10)
    offset(r=R2)
      square([L - 2*R2, W - 2*R2], center=true);
}

module mount_hole(x, y) {
  translate([x, y, 0])
    cylinder(d=mount_hole_diameter, h=pcb_thickness + 2*feature_overlap, center=true);
}

module pad(x, y) {
  // Slightly overlap into PCB so pads are connected to the main solid
  translate([x, y, pcb_thickness/2 + pad_thickness/2 - feature_overlap])
    cylinder(d=pad_diameter, h=pad_thickness + feature_overlap, center=true);
}

module silk_line(x, y, len, wid) {
  translate([x, y, pcb_thickness/2 + silk_thickness/2 - feature_overlap])
    cube([len, wid, silk_thickness + feature_overlap], center=true);
}

module finger(x, y) {
  translate([x, y, pcb_thickness/2 + finger_thickness/2 - feature_overlap])
    cube([finger_length, finger_width, finger_thickness + feature_overlap], center=true);
}

// --- Main PCB body (exact 21x18 outline, 1.2 thick) ---
module pcb_body_with_holes() {
  difference() {
    rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

    // 4 mounting holes, placed by formula from dimensions
    mount_hole(-pcb_length/2 + mount_hole_edge_offset,  pcb_width/2 - mount_hole_edge_offset);
    mount_hole( pcb_length/2 - mount_hole_edge_offset,  pcb_width/2 - mount_hole_edge_offset);
    mount_hole(-pcb_length/2 + mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset);
    mount_hole( pcb_length/2 - mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset);
  }
}

module copper_pads() {
  union() {
    pad(-pcb_length/4,  pcb_width/4);
    pad( pcb_length/4,  pcb_width/4);
    pad(-pcb_length/4, -pcb_width/4);
    pad( pcb_length/4, -pcb_width/4);
  }
}

module silkscreen_markings() {
  union() {
    // Top/bottom lines
    silk_line(0,  pcb_width/2 - silk_margin, pcb_length - 2*silk_margin, silk_line_width);
    silk_line(0, -pcb_width/2 + silk_margin, pcb_length - 2*silk_margin, silk_line_width);

    // Left/right lines (swap len/wid to make vertical bars)
    silk_line(-pcb_length/2 + silk_margin, 0, silk_line_width, pcb_width - 2*silk_margin);
    silk_line( pcb_length/2 - silk_margin, 0, silk_line_width, pcb_width - 2*silk_margin);
  }
}

module edge_connector_fingers() {
  union() {
    // Keep fingers within board width
    usable_w = pcb_width - 2*silk_margin;
    pitch = finger_width;
    total = finger_count * pitch;
    y0 = -total/2 + pitch/2;

    for (i = [0:finger_count-1]) {
      y = y0 + i*pitch;
      // Place at right edge, connected by overlap
      x = pcb_length/2 - finger_length/2;
      finger(x, y);
    }
  }
}

module pcb_complete() {
  // One connected solid: pads/silk/fingers overlap into the PCB
  union() {
    pcb_body_with_holes();
    copper_pads();
    silkscreen_markings();
    edge_connector_fingers();
  }
}

// Final Output
color([0.0, 0.4, 0.2]) pcb_complete();