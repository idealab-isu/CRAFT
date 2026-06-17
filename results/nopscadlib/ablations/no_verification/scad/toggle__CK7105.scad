// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_height_mm   = 12.7; //[6.35:25.4:0.01]
centered         = 1;    //[0:1:1]
tolerance_mm     = 0;    //[0:0.5:0.01]
face_thickness_mm= 0.6;  //[0.3:1.2:0.05]
overlap_mm       = 0.8;  //[0.5:2:0.1]
lever_diameter_mm= 2.5;  //[1.5:5:0.1]
lever_height_mm  = 8;    //[4:16:0.5]
include_toggle_lever = 1; //[0:1:1]

// Resolution
$fn = 64;

// Derived
body_r = (body_diameter_mm + tolerance_mm)/2;
body_h =  body_height_mm + tolerance_mm;

// Place body so that:
// centered=1 -> centered at Z=0
// centered=0 -> bottom at Z=0
z0 = centered ? 0 : body_h/2;

// Toggle Switch Body (main cylinder)
module toggle_switch_body() {
  color("DimGray")
    translate([0,0,z0])
      cylinder(h=body_h, r=body_r, center=true);
}

// Top/Bottom thin faces (kept connected via overlap)
module top_face() {
  color("Silver")
    translate([0,0, z0 + body_h/2 - face_thickness_mm/2 - overlap_mm/2])
      cylinder(h=face_thickness_mm, r=body_r, center=true);
}

module bottom_face() {
  color("Silver")
    translate([0,0, z0 - body_h/2 + face_thickness_mm/2 + overlap_mm/2])
      cylinder(h=face_thickness_mm, r=body_r, center=true);
}

// Toggle lever: a small shaft + a thicker knob, both connected to the body
module toggle_lever() {
  if (include_toggle_lever) {
    lever_r = lever_diameter_mm/2;
    knob_r  = lever_r*1.35;
    knob_h  = max(lever_diameter_mm*1.2, 2.0);
    shaft_h = max(lever_height_mm - knob_h, 0.01);

    // Shaft starts slightly inside the body top to guarantee connection
    shaft_center_z = z0 + body_h/2 + shaft_h/2 - overlap_mm;
    knob_center_z  = z0 + body_h/2 + shaft_h + knob_h/2 - overlap_mm;

    color("Black")
      union() {
        translate([0,0,shaft_center_z])
          cylinder(h=shaft_h, r=lever_r, center=true);

        translate([0,0,knob_center_z])
          cylinder(h=knob_h, r=knob_r, center=true);
      }
  }
}

// Assembly: ONE connected solid
union() {
  toggle_switch_body();
  top_face();
  bottom_face();
  toggle_lever();
}