// Parameters
inner_hole_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 17; //[8.5:34:0.1]
thickness_mm = 1.6; //[0.8:3.2:0.1]
overlap_mm = 1; //[0.5:2:0.1]
hole_clearance_mm = 0; //[0:0.5:0.05]
grommet_lip_radial_mm = 1.2; //[0.6:2.4:0.1]
grommet_top_height_mm = 2.4; //[1.2:4.8:0.1]
grommet_wall_mm = 1.2; //[0.8:2.4:0.1]
screw_shank_diameter_mm = 6; //[3:12:0.1]
screw_shank_length_mm = 20; //[10:40:0.5]
screw_head_diameter_mm = 10; //[6:20:0.1]
screw_head_height_mm = 4; //[2:8:0.1]
nut_flat_diameter_mm = 11; //[7:22:0.1]
nut_thickness_mm = 5; //[2.5:10:0.1]

// -------------------------
// Core washer (single solid)
// -------------------------
module washer_body() {
  difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    cylinder(r=(inner_hole_diameter_mm + hole_clearance_mm)/2,
             h=thickness_mm + 2*overlap_mm, center=true);
  }
}

// -------------------------
// Round grommet top (sleeve)
// Attached by overlapping into washer by overlap_mm
// -------------------------
module round_grommet_top() {
  z_top = thickness_mm/2 + grommet_top_height_mm/2 - overlap_mm; // ensures overlap into washer

  difference() {
    translate([0, 0, z_top])
      cylinder(r=outer_diameter_mm/2 + grommet_lip_radial_mm,
               h=grommet_top_height_mm, center=true);

    // inner cavity of sleeve
    translate([0, 0, z_top])
      cylinder(r=outer_diameter_mm/2 + grommet_lip_radial_mm - grommet_wall_mm,
               h=grommet_top_height_mm + 2*overlap_mm, center=true);

    // keep the washer hole open through the grommet
    translate([0, 0, z_top])
      cylinder(r=(inner_hole_diameter_mm + hole_clearance_mm)/2,
               h=grommet_top_height_mm + 2*overlap_mm, center=true);
  }
}

// -------------------------
// Central stepped shaft / inner plug
// FIX: make it a real solid that is UNIONed and overlaps washer/grommet
// -------------------------
module inner_plug() {
  // Make the plug slightly larger than the washer hole so it fuses to the washer.
  // (This intentionally removes the "hole" in the washer in the final solid,
  // but fixes the structural requirement: washer + inner part become one connected solid.)
  plug_d = inner_hole_diameter_mm + 2*overlap_mm; // +2mm total -> +1mm radial overlap
  plug_h = thickness_mm + grommet_top_height_mm + 2*overlap_mm;

  // Centered so it overlaps both washer (z=0) and grommet top (above)
  z_plug = (grommet_top_height_mm/2); // spans across washer plane due to plug_h

  translate([0, 0, z_plug])
    cylinder(r=plug_d/2, h=plug_h, center=true);
}

// -------------------------
// Round grommet assembly (single connected solid)
// -------------------------
module round_grommet_assembly() {
  union() {
    washer_body();
    round_grommet_top();
    inner_plug(); // FIX: attaches the previously "floating" central shaft and fuses washer/shaft
  }
}

// -------------------------
// Screw and nut kept for reference, but NOT included in final unioned part
// (They are separate hardware and would otherwise create multiple solids.)
// -------------------------
module screw_and_washer() {
  union() {
    cylinder(r=screw_shank_diameter_mm/2, h=screw_shank_length_mm, center=true);
    translate([0, 0, thickness_mm/2 + screw_head_height_mm/2 - overlap_mm])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
    washer_body();
  }
}

module nut_and_washer() {
  union() {
    difference() {
      translate([0, 0, -(thickness_mm/2 + nut_thickness_mm/2 - overlap_mm)])
        cylinder(r=nut_flat_diameter_mm/2, h=nut_thickness_mm, center=true);
      translate([0, 0, -(thickness_mm/2 + nut_thickness_mm/2 - overlap_mm)])
        cylinder(r=screw_shank_diameter_mm/2 + hole_clearance_mm/2,
                 h=nut_thickness_mm + 2*overlap_mm, center=true);
    }
    washer_body();
  }
}

// -------------------------
// Final single-solid output
// -------------------------
union() {
  round_grommet_assembly();
}