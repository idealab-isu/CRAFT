// HDMI display 5" module (ONE connected solid)
// Spec: 121, 76, 2.85, , [0, 0, 1.9], // pcb offst
//       [[-54, -30.225], [54, 34.575, 0.5]], // aperture
//       [[-58.7, -34], [58.7, 36.25, 1]], // touch screen
//       2, // thread length
//       [[-2.5, -39], [10.5, -33]], // clearance need for the ts ribbon

// ---------------- Parameters ----------------
display_overall_width_mm  = 121;
display_overall_height_mm = 76;
display_thickness_mm      = 2.85;

pcb_offset_x_mm = 0;
pcb_offset_y_mm = 0;
pcb_offset_z_mm = 1.9;

display_aperture_min_x_mm = -54;
display_aperture_min_y_mm = -30.225;
display_aperture_max_x_mm =  54;
display_aperture_max_y_mm =  34.575;
display_aperture_depth_mm = 0.5;

touch_min_x_mm = -58.7;
touch_min_y_mm = -34;
touch_max_x_mm =  58.7;
touch_max_y_mm =  36.25;
touch_thickness_mm = 1;

thread_length_mm = 2;

ts_ribbon_min_x_mm = -2.5;
ts_ribbon_min_y_mm = -39;
ts_ribbon_max_x_mm = 10.5;
ts_ribbon_max_y_mm = -33;
ts_ribbon_clearance_depth_mm = 2.5;

pcb_interface_thickness_mm = 1.6;
pcb_interface_margin_mm    = 2;

mount_post_radius_mm   = 2.5;
mount_post_inset_x_mm  = 8;
mount_post_inset_y_mm  = 8;

hdmi_width_mm  = 14;
hdmi_height_mm = 6;
hdmi_depth_mm  = 12;
hdmi_side_offset_y_mm = 0;

knob_radius_mm = 6;
knob_height_mm = 4;

overlap_mm = 1;

// Ensure the "display module" reads as a stack (not a single thin board)
backer_thickness_mm = 3.0;   // rear housing/backer (visual mass)
bezel_thickness_mm  = 1.2;   // front bezel ring thickness (around aperture)
bezel_lip_mm         = 1.0;  // bezel overlap into aperture opening

// ---------------- Helpers ----------------
function mid(a,b)  = (a+b)/2;
function span(a,b) = (b-a);

ap_cx = mid(display_aperture_min_x_mm, display_aperture_max_x_mm);
ap_cy = mid(display_aperture_min_y_mm, display_aperture_max_y_mm);
ap_w  = span(display_aperture_min_x_mm, display_aperture_max_x_mm);
ap_h  = span(display_aperture_min_y_mm, display_aperture_max_y_mm);

ts_cx = mid(touch_min_x_mm, touch_max_x_mm);
ts_cy = mid(touch_min_y_mm, touch_max_y_mm);
ts_w  = span(touch_min_x_mm, touch_max_x_mm);
ts_h  = span(touch_min_y_mm, touch_max_y_mm);

rb_cx = mid(ts_ribbon_min_x_mm, ts_ribbon_max_x_mm);
rb_cy = mid(ts_ribbon_min_y_mm, ts_ribbon_max_y_mm);
rb_w  = span(ts_ribbon_min_x_mm, ts_ribbon_max_x_mm);
rb_h  = span(ts_ribbon_min_y_mm, ts_ribbon_max_y_mm);

// Z stack (centered assembly around Z=0)
z_display_center = 0;
z_display_top    = z_display_center + display_thickness_mm/2;
z_display_bot    = z_display_center - display_thickness_mm/2;

z_touch_center = z_display_top + touch_thickness_mm/2 - overlap_mm;
z_touch_top    = z_touch_center + touch_thickness_mm/2;

z_pcb_center = z_display_top + pcb_offset_z_mm + pcb_interface_thickness_mm/2 - overlap_mm;
z_pcb_top    = z_pcb_center + pcb_interface_thickness_mm/2;
z_pcb_bot    = z_pcb_center - pcb_interface_thickness_mm/2;

z_knob_center = z_pcb_top + knob_height_mm/2 - overlap_mm;

z_backer_center = z_display_bot - backer_thickness_mm/2 + overlap_mm;
z_backer_bot    = z_backer_center - backer_thickness_mm/2;

z_bezel_center  = z_touch_top + bezel_thickness_mm/2 - overlap_mm;

// ---------------- Geometry modules ----------------
module display_core_with_recesses() {
  // Core slab with:
  // - aperture recess on front
  // - ribbon clearance pocket on front (per spec)
  difference() {
    cube([display_overall_width_mm, display_overall_height_mm, display_thickness_mm], center=true);

    // Aperture recess (front/top face)
    translate([ap_cx, ap_cy, z_display_top - display_aperture_depth_mm/2])
      cube([ap_w, ap_h, display_aperture_depth_mm + overlap_mm], center=true);

    // Ribbon clearance pocket (front/top face, near bottom edge per spec)
    translate([rb_cx, rb_cy, z_display_top - ts_ribbon_clearance_depth_mm/2])
      cube([rb_w, rb_h, ts_ribbon_clearance_depth_mm + overlap_mm], center=true);
  }
}

module front_bezel_ring() {
  // Bezel ring around the aperture to make the "display opening" visible.
  // Outer = overall display face; Inner = aperture opening (slightly smaller to create a lip).
  inner_w = max(0.1, ap_w - 2*bezel_lip_mm);
  inner_h = max(0.1, ap_h - 2*bezel_lip_mm);

  translate([0, 0, z_bezel_center])
    difference() {
      cube([display_overall_width_mm, display_overall_height_mm, bezel_thickness_mm], center=true);
      translate([ap_cx, ap_cy, 0])
        cube([inner_w, inner_h, bezel_thickness_mm + 2*overlap_mm], center=true);
    }
}

module backer_body() {
  // Rear housing/backer to give the module thickness/recognizable body.
  // Keep it slightly inset so it reads as a back housing.
  backer_w = display_overall_width_mm - 2*1.5;
  backer_h = display_overall_height_mm - 2*1.5;

  translate([0, 0, z_backer_center])
    cube([backer_w, backer_h, backer_thickness_mm], center=true);
}

module pcb_plate() {
  translate([pcb_offset_x_mm, pcb_offset_y_mm, z_pcb_center])
    cube([display_overall_width_mm - 2*pcb_interface_margin_mm,
          display_overall_height_mm - 2*pcb_interface_margin_mm,
          pcb_interface_thickness_mm], center=true);
}

module touchscreen_glass() {
  // Touchscreen volume on top/front side (outer dimensions per spec)
  translate([ts_cx, ts_cy, z_touch_center])
    cube([ts_w, ts_h, touch_thickness_mm], center=true);
}

module hdmi_connector() {
  // Place on right edge of PCB, connected with overlap
  pcb_w = display_overall_width_mm - 2*pcb_interface_margin_mm;

  x_center = pcb_offset_x_mm + pcb_w/2 + hdmi_depth_mm/2 - overlap_mm; // protrude out from PCB edge
  y_center = pcb_offset_y_mm + hdmi_side_offset_y_mm;
  z_center = z_pcb_center + pcb_interface_thickness_mm/2 + hdmi_height_mm/2 - overlap_mm;

  translate([x_center, y_center, z_center])
    cube([hdmi_depth_mm, hdmi_width_mm, hdmi_height_mm], center=true);
}

module mounting_knobs() {
  // Four knobs/posts on top of PCB (connected)
  for (ix = [-1, 1])
    for (iy = [-1, 1]) {
      x = ix * (display_overall_width_mm/2 - mount_post_inset_x_mm);
      y = iy * (display_overall_height_mm/2 - mount_post_inset_y_mm);
      translate([x, y, z_knob_center])
        cylinder(r=knob_radius_mm, h=knob_height_mm, center=true, $fn=48);
    }
}

module thread_stubs() {
  // Small stubs under PCB at the same XY as knobs to represent thread length (connected)
  z_stub_center = z_pcb_bot - thread_length_mm/2 + overlap_mm;
  for (ix = [-1, 1])
    for (iy = [-1, 1]) {
      x = ix * (display_overall_width_mm/2 - mount_post_inset_x_mm);
      y = iy * (display_overall_height_mm/2 - mount_post_inset_y_mm);
      translate([x, y, z_stub_center])
        cylinder(r=mount_post_radius_mm, h=thread_length_mm, center=true, $fn=36);
    }
}

module keepout_bridge_to_ensure_connectivity() {
  // Ensure the bezel/touch/core/backer/pcb are all one connected solid even if
  // parameters are edited later. This is a thin internal "spine" that overlaps
  // all layers without changing the external silhouette.
  spine_w = 6;
  spine_h = 6;
  z_top = z_bezel_center + bezel_thickness_mm/2;
  z_bot = z_backer_bot;
  spine_zc = (z_top + z_bot)/2;
  spine_zh = (z_top - z_bot) + 2*overlap_mm;

  translate([0, 0, spine_zc])
    cube([spine_w, spine_h, spine_zh], center=true);
}

// ---------------- Assembly (ONE connected solid) ----------------
union() {
  display_core_with_recesses();
  front_bezel_ring();
  backer_body();
  pcb_plate();
  touchscreen_glass();
  hdmi_connector();
  mounting_knobs();
  thread_stubs();
  keepout_bridge_to_ensure_connectivity();
}