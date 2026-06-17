// Printed Circuit Board (single connected solid)
// Exact overall size: 40.0mm x 16.0mm x 1.6mm

$fn = 64;

// Parameters
pcb_L = 40.0; //[20.0:80.0:0.5]
pcb_W = 16.0; //[8.0:32.0:0.5]
pcb_T = 1.6;  //[0.8:3.2:0.1]

corner_R = 2.0; //[1.0:4.0:0.25]

hole_D = 3.2; //[2.0:5.0:0.1]
hole_edge_margin = 3.0; //[1.5:6.0:0.25]

copper_T = 0.05; //[0.02:0.2:0.01]
silk_T   = 0.05; //[0.02:0.2:0.01]

// Small overlap to guarantee connectivity (no floating skins)
feature_overlap = 0.2; //[0.05:1.0:0.05]

pad_L = 2.0; //[1.0:4.0:0.25]
pad_W = 1.2; //[0.6:3.0:0.1]
trace_W = 0.6; //[0.2:2.0:0.05]
trace_L = 18.0; //[8.0:36.0:0.5]

silk_border_inset = 1.0; //[0.5:3.0:0.25]
silk_line_W = 0.4; //[0.2:1.0:0.05]

finger_count = 8; //[4:20:1]
finger_L = 6.0; //[3.0:12.0:0.5]
finger_W = 1.2; //[0.6:2.5:0.1]
finger_gap = 0.6; //[0.3:2.0:0.05]
finger_edge_inset = 1.0; //[0.5:3.0:0.25]

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

// PCB Body with Rounded Corners (exact outer L/W, thickness pcb_T)
module pcb_body() {
  // Ensure corner radius is valid for given dimensions
  r = clamp(corner_R, 0, min(pcb_L, pcb_W)/2);

  difference() {
    // 2D rounded rectangle extruded to exact thickness
    linear_extrude(height = pcb_T, center = true, convexity = 10)
      offset(r = r)
        square([pcb_L - 2*r, pcb_W - 2*r], center = true);

    // Mounting holes (through)
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*(pcb_L/2 - hole_edge_margin),
                 sy*(pcb_W/2 - hole_edge_margin),
                 0])
        cylinder(d = hole_D, h = pcb_T + 2*feature_overlap, center = true);
    }
  }
}

// Silkscreen Markings (merged into body via overlap)
module silkscreen_markings() {
  z = pcb_T/2 - feature_overlap + silk_T/2; // overlaps into PCB
  union() {
    translate([0,  pcb_W/2 - silk_border_inset - silk_line_W/2, z])
      cube([pcb_L - 2*silk_border_inset, silk_line_W, silk_T], center=true);
    translate([0, -pcb_W/2 + silk_border_inset + silk_line_W/2, z])
      cube([pcb_L - 2*silk_border_inset, silk_line_W, silk_T], center=true);
    translate([-pcb_L/2 + silk_border_inset + silk_line_W/2, 0, z])
      cube([silk_line_W, pcb_W - 2*silk_border_inset, silk_T], center=true);
    translate([ pcb_L/2 - silk_border_inset - silk_line_W/2, 0, z])
      cube([silk_line_W, pcb_W - 2*silk_border_inset, silk_T], center=true);
  }
}

// Copper Pads and Traces (merged into body via overlap)
module copper_pads_traces() {
  z = pcb_T/2 - feature_overlap + copper_T/2; // overlaps into PCB
  union() {
    translate([-pcb_L/4, 0, z]) cube([pad_L, pad_W, copper_T], center=true);
    translate([ pcb_L/4, 0, z]) cube([pad_L, pad_W, copper_T], center=true);
    translate([0, 0, z])        cube([trace_L, trace_W, copper_T], center=true);
  }
}

// Edge Connector Fingers (merged into body via overlap)
module edge_connector_fingers() {
  z = pcb_T/2 - feature_overlap + copper_T/2; // overlaps into PCB

  // Keep fingers within board width
  usable_W = pcb_W - 2*finger_edge_inset;
  pitch = finger_W + finger_gap;
  total_span = finger_count*finger_W + (finger_count-1)*finger_gap;
  start_y = -total_span/2 + finger_W/2;

  union() {
    for (i = [0:finger_count-1]) {
      y = start_y + i*pitch;
      // Only place if within usable area (prevents accidental out-of-bounds)
      if (abs(y) <= usable_W/2 + 1e-6)
        translate([-pcb_L/2 + finger_L/2, y, z])
          cube([finger_L, finger_W, copper_T], center=true);
    }
  }
}

// Complete PCB as ONE connected solid (no separate shells)
module pcb_complete() {
  union() {
    pcb_body();
    silkscreen_markings();
    copper_pads_traces();
    edge_connector_fingers();
  }
}

pcb_complete();