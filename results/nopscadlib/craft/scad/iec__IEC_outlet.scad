$fn = 96;

// =====================
// IEC inlet module (approx RS 811-7193 form factor)
// Target flange: 40.0mm x 32.0mm
// Z+: front (user side). Z-: rear (inside equipment)
// One connected solid (all parts unioned), with cutouts subtracted.
// =====================

// Parameters (mm)
flange_width_mm = 40.0;          //[20:80:0.5]
flange_height_mm = 32.0;         //[16:64:0.5]
flange_thickness_mm = 2.5;       //[1.2:5:0.1]
bezel_thickness_mm = 2.0;        //[1:4:0.1]
body_depth_mm = 28.0;            //[14:56:0.5]

corner_radius_mm = 2.5;          //[1:6:0.1]
bezel_margin_mm = 1.5;           //[0.5:4:0.1]

// Use a guaranteed physical overlap between stacked parts (1–2mm)
overlap_mm = 1.5;                //[0.5:2:0.1]

screw_hole_diameter_mm = 3.2;    //[2.4:5:0.1]
screw_hole_pitch_x_mm = 30.0;    //[20:38:0.5]
screw_hole_pitch_y_mm = 24.0;    //[16:30:0.5]

// Panel cutout (typical IEC inlet cutout)
panel_cutout_width_mm = 27.5;    //[20:35:0.1]
panel_cutout_height_mm = 20.5;   //[14:28:0.1]

// Rear body wall thickness (for hollowing)
body_wall_mm = 2.0;              //[1:4:0.1]

// IEC C14 face geometry (recognizable mouth + inner cavity)
iec_mouth_w_mm = 27.0;           // outer "mouth" opening on face (approx)
iec_mouth_h_mm = 19.0;
iec_mouth_r_mm = 2.2;

iec_inner_w_mm = 22.0;           // inner opening (deeper)
iec_inner_h_mm = 16.0;
iec_inner_r_mm = 2.0;
iec_inner_depth_mm = 14.0;       // depth of inner cavity into body

// Pin cavities (3 recesses) inside the inlet
pin_cav_r_mm = 2.2;
pin_cav_depth_mm = 10.0;
pin_pitch_x_mm = 10.0;
pin_pitch_y_mm = 6.0;

// Rear terminal spade block (simple approximation, connected)
terminal_spade_width_mm = 22.0;  //[14:30:0.5]
terminal_spade_height_mm = 12.0; //[8:20:0.5]
terminal_spade_depth_mm = 10.0;  //[6:20:0.5]

// Optional filter can (kept off by default)
filter_can_width_mm = 34.0;      //[20:60:0.5]
filter_can_height_mm = 28.0;     //[16:56:0.5]
filter_can_depth_mm = 18.0;      //[10:40:0.5]
filter_can_present = 0;          //[0:1:1]

// ---------- Helpers ----------
module rounded_rect_prism(w, h, t, r, center=true) {
  r2 = min(r, min(w, h)/2 - 0.01);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2), 0])
        cylinder(r=r2, h=t, center=center);
  }
}

// Trapezoid-ish IEC face "mouth" (slight draft) using hull of two rounded rectangles
module drafted_mouth(w, h, r, depth, draft_mm=1.2) {
  w2 = max(0.1, w - 2*draft_mm);
  h2 = max(0.1, h - 2*draft_mm);
  hull() {
    translate([0,0, depth/2]) rounded_rect_prism(w,  h,  0.2, r, center=true);
    translate([0,0,-depth/2]) rounded_rect_prism(w2, h2, 0.2, max(0.1, r-0.6), center=true);
  }
}

module iec_inlet_module() {
  // Reference: flange centered at z=0
  flange_t = flange_thickness_mm;
  bezel_t  = bezel_thickness_mm;

  // --- Z stacking with guaranteed overlap (fixes floating/gap issues) ---
  // Flange spans: [-flange_t/2, +flange_t/2]
  // Bezel sits in front and overlaps flange by overlap_mm
  bezel_center_z = (flange_t/2 + bezel_t/2) - overlap_mm;

  // Rear body sits behind flange and overlaps flange by overlap_mm
  body_w = panel_cutout_width_mm + 2*body_wall_mm + 2.0;
  body_h = panel_cutout_height_mm + 2*body_wall_mm + 2.0;
  body_center_z = (-flange_t/2 - body_depth_mm/2) + overlap_mm;

  // Terminal block behind body and overlaps body by overlap_mm
  term_center_z = (body_center_z - body_depth_mm/2 - terminal_spade_depth_mm/2) + overlap_mm;

  // Optional filter can behind terminal and overlaps terminal by overlap_mm
  filter_center_z = (term_center_z - terminal_spade_depth_mm/2 - filter_can_depth_mm/2) + overlap_mm;

  difference() {
    union() {
      // Flange (40 x 32)
      rounded_rect_prism(flange_width_mm, flange_height_mm, flange_t, corner_radius_mm, center=true);

      // Bezel (slightly larger) - overlaps flange
      translate([0, 0, bezel_center_z])
        rounded_rect_prism(
          flange_width_mm + 2*bezel_margin_mm,
          flange_height_mm + 2*bezel_margin_mm,
          bezel_t,
          corner_radius_mm + bezel_margin_mm,
          center=true
        );

      // Rear body (molded box) - overlaps flange (no gap / no floating)
      translate([0, 0, body_center_z])
        cube([body_w, body_h, body_depth_mm], center=true);

      // Terminal spade region - overlaps rear body
      translate([0, 0, term_center_z])
        cube([terminal_spade_width_mm, terminal_spade_height_mm, terminal_spade_depth_mm], center=true);

      // Optional filter can - overlaps terminal
      if (filter_can_present)
        translate([0, 0, filter_center_z])
          cube([filter_can_width_mm, filter_can_height_mm, filter_can_depth_mm], center=true);
    }

    // ----------------
    // CUTOUTS / DETAILS
    // ----------------

    // Panel cutout through bezel+flange (rectangular with small radius)
    cutout_t = flange_t + bezel_t + 2*overlap_mm + 4;
    cutout_center_z = (bezel_center_z + bezel_t/2) - (cutout_t/2 - 1.0);
    translate([0, 0, cutout_center_z])
      rounded_rect_prism(panel_cutout_width_mm, panel_cutout_height_mm, cutout_t, 1.2, center=true);

    // IEC face mouth (drafted) to create characteristic inlet shape on the front
    mouth_depth = flange_t + bezel_t + 2*overlap_mm + 1.5;
    mouth_center_z = (flange_t/2 + bezel_t/2) - overlap_mm;
    translate([0, 0, mouth_center_z])
      drafted_mouth(iec_mouth_w_mm, iec_mouth_h_mm, iec_mouth_r_mm, mouth_depth, draft_mm=1.2);

    // Inner cavity behind the mouth (deeper recess into the body)
    inner_center_z = (-flange_t/2 - iec_inner_depth_mm/2) + overlap_mm;
    translate([0, 0, inner_center_z])
      rounded_rect_prism(
        iec_inner_w_mm, iec_inner_h_mm,
        iec_inner_depth_mm + 2*overlap_mm,
        iec_inner_r_mm,
        center=true
      );

    // Pin cavities (3) inside the inner cavity, extending further back
    pin_center_z = (-flange_t/2 - pin_cav_depth_mm/2) + overlap_mm;
    for (p = [
      [-pin_pitch_x_mm/2, -pin_pitch_y_mm/2],
      [ pin_pitch_x_mm/2, -pin_pitch_y_mm/2],
      [ 0,                pin_pitch_y_mm/2]
    ])
      translate([p[0], p[1], pin_center_z])
        cylinder(r=pin_cav_r_mm, h=pin_cav_depth_mm + 2*overlap_mm, center=true);

    // Mounting screw holes through bezel+flange
    screw_h = flange_t + bezel_t + 2*overlap_mm + 2;
    // Center the drilling volume across the combined bezel+flange stack
    screw_center_z = (bezel_center_z + 0)/2;
    for (x = [-screw_hole_pitch_x_mm/2, screw_hole_pitch_x_mm/2])
      for (y = [-screw_hole_pitch_y_mm/2, screw_hole_pitch_y_mm/2])
        translate([x, y, screw_center_z])
          cylinder(r=screw_hole_diameter_mm/2, h=screw_h, center=true);

    // Rear hollow in body to avoid solid block look (keeps walls)
    inner_w = max(0.1, body_w - 2*body_wall_mm);
    inner_h = max(0.1, body_h - 2*body_wall_mm);
    inner_d = max(0.1, body_depth_mm - 2*body_wall_mm);

    // Bias hollow toward rear so front around inlet remains robust
    hollow_center_z = body_center_z - body_wall_mm/2;
    translate([0, 0, hollow_center_z])
      cube([inner_w, inner_h, inner_d], center=true);
  }
}

iec_inlet_module();