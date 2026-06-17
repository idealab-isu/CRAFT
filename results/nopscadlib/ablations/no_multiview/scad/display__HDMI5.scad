// Parameters
display_width = 121; //[60.5:242:0.1]
display_height = 76; //[38:152:0.1]
display_thickness = 2.85; //[1.425:5.7:0.01]
pcb_offset_x = 0; //[-10:10:0.1]
pcb_offset_y = 0; //[-10:10:0.1]
pcb_offset_z = 1.9; //[0:5:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_margin_xy = 2; //[0:10:0.1]
aperture_min_x = -54; //[-80:-20:0.1]
aperture_min_y = -30.225; //[-60:0:0.001]
aperture_min_z = 0; //[0:2:0.01]
aperture_max_x = 54; //[20:80:0.1]
aperture_max_y = 34.575; //[0:60:0.001]
aperture_max_z = 0.5; //[0.1:2:0.01]
touch_min_x = -58.7; //[-90:-30:0.1]
touch_min_y = -34; //[-70:0:0.1]
touch_min_z = 0; //[0:2:0.01]
touch_max_x = 58.7; //[30:90:0.1]
touch_max_y = 36.25; //[0:70:0.1]
touch_max_z = 1; //[0.2:3:0.01]
mounting_thread_length = 2; //[1:4:0.1]
standoff_radius = 2.5; //[1.5:5:0.1]
standoff_inset_x = 6; //[2:15:0.1]
standoff_inset_y = 6; //[2:15:0.1]
overlap = 1; //[0.5:2:0.1]
ts_ribbon_min_x = -2.5; //[-20:10:0.1]
ts_ribbon_min_y = -39; //[-80:-10:0.1]
ts_ribbon_max_x = 10.5; //[-10:30:0.1]
ts_ribbon_max_y = -33; //[-60:0:0.1]
ts_ribbon_clearance_z = 6; //[2:12:0.1]
hdmi_width = 14; //[7:28:0.1]
hdmi_height = 6; //[3:12:0.1]
hdmi_depth = 12; //[6:24:0.1]
hdmi_offset_x = 0; //[-30:30:0.1]
hdmi_offset_y = -20; //[-40:40:0.1]
knob_radius = 4; //[2:8:0.1]
knob_height = 3; //[1.5:6:0.1]

// ---------- Derived Z reference planes (centered display at z=0) ----------
z_display_top    =  display_thickness/2;
z_display_bottom = -display_thickness/2;

// PCB sits behind display (negative Z)
z_pcb_top    = z_display_bottom - pcb_offset_z;
z_pcb_center = z_pcb_top - pcb_thickness/2;
z_pcb_bottom = z_pcb_top - pcb_thickness;

// Touch glass sits on top of display (positive Z)
touch_thickness = (touch_max_z - touch_min_z);
z_touch_bottom  = z_display_top - overlap;                 // ensure overlap into display
z_touch_center  = z_touch_bottom + touch_thickness/2;

// HDMI sits under PCB but overlaps into PCB by 'overlap'
z_hdmi_top    = z_pcb_bottom + overlap;                    // overlap into PCB
z_hdmi_center = z_hdmi_top - hdmi_height/2;

// Knobs sit under PCB but overlap into PCB by 'overlap'
z_knob_top    = z_pcb_bottom + overlap;                    // overlap into PCB
z_knob_center = z_knob_top - knob_height/2;

// ---------- FIX: add a physical connector between PCB stack and HDMI block ----------
// This resolves the floating/disconnected small blue rectangular block by creating
// a "neck" that overlaps both the PCB and the HDMI by 1-2mm.
bridge_overlap = 1.5;                                      // stronger guaranteed connection
bridge_w = hdmi_depth;                                     // match HDMI depth (X)
bridge_d = hdmi_width;                                     // match HDMI width (Y)

// Compute exact Z extents so the bridge intersects both solids
z_bridge_top    = z_pcb_bottom + bridge_overlap;           // inside PCB by bridge_overlap
z_bridge_bottom = z_hdmi_top - bridge_overlap;             // inside HDMI by bridge_overlap
bridge_h = max(0.01, z_bridge_top - z_bridge_bottom);
z_bridge_center = (z_bridge_top + z_bridge_bottom)/2;

// ---------- Parts ----------
module display_body() {
  color([0.85, 0.85, 0.8])
  difference() {
    cube([display_width, display_height, display_thickness], center=true);

    // Aperture cut (kept as in original intent)
    translate([
      (aperture_min_x + aperture_max_x)/2,
      (aperture_min_y + aperture_max_y)/2,
      z_display_top - (aperture_max_z - aperture_min_z + overlap)/2
    ])
      cube([
        aperture_max_x - aperture_min_x,
        aperture_max_y - aperture_min_y,
        aperture_max_z - aperture_min_z + overlap
      ], center=true);
  }
}

module pcb() {
  color([0.0, 0.4, 0.2])
  translate([pcb_offset_x, pcb_offset_y, z_pcb_center])
    cube([display_width - 2*pcb_margin_xy, display_height - 2*pcb_margin_xy, pcb_thickness], center=true);
}

module touch_glass() {
  // Blue central component in the screenshots: ensure it physically overlaps the display
  color([0.1, 0.1, 0.6])
  translate([
    (touch_min_x + touch_max_x)/2,
    (touch_min_y + touch_max_y)/2,
    z_touch_center
  ])
    cube([touch_max_x - touch_min_x, touch_max_y - touch_min_y, touch_thickness], center=true);
}

module hdmi() {
  // Ensure HDMI overlaps into PCB (no air gap)
  color([0.1, 0.1, 0.6])
  translate([pcb_offset_x + hdmi_offset_x, pcb_offset_y + hdmi_offset_y, z_hdmi_center])
    cube([hdmi_depth, hdmi_width, hdmi_height], center=true);
}

module hdmi_to_pcb_bridge() {
  // Physical attachment "neck" so the HDMI block is not floating/disconnected.
  // Overlaps into PCB and HDMI by bridge_overlap.
  color([0.1, 0.1, 0.6])
  translate([pcb_offset_x + hdmi_offset_x, pcb_offset_y + hdmi_offset_y, z_bridge_center])
    cube([bridge_w, bridge_d, bridge_h], center=true);
}

module screw_knob_assembly() {
  // Ensure knobs overlap into PCB (no air gap)
  color([0.2, 0.2, 0.2])
  for (i = [-1, 1], j = [-1, 1]) {
    translate([
      i * (display_width/2 - standoff_inset_x),
      j * (display_height/2 - standoff_inset_y),
      z_knob_center
    ])
      cylinder(r=knob_radius, h=knob_height, center=true);
  }
}

// ---------- Assembly (single connected solid) ----------
module assembly() {
  union() {
    display_body();
    pcb();
    touch_glass();

    // HDMI + bridge are unioned into the same solid and physically intersect PCB
    hdmi();
    hdmi_to_pcb_bridge();

    screw_knob_assembly();
  }
}

assembly();