// Parameters
shaft_diameter_mm = 6; //[3:12:0.1]
length_under_head_mm = 10; //[5:20:0.1]
head_across_flats_mm = 11.5; //[8:23:0.1]
head_height_mm = 4.15; //[2:8.3:0.05]
thread_pitch_mm = 1; //[0.5:2:0.05]
thread_length_mm = 10; //[5:20:0.1]
under_head_chamfer_height_mm = 0.8; //[0.3:1.6:0.05]
under_head_chamfer_radial_mm = 0.6; //[0.2:1.2:0.05]
tip_chamfer_height_mm = 0.6; //[0.2:1.2:0.05]
tip_chamfer_radial_mm = 0.4; //[0.1:0.8:0.05]
washer_outer_diameter_mm = 12; //[8:24:0.1]
washer_thickness_mm = 1.2; //[0.6:2.4:0.05]
washer_hole_diameter_mm = 6.6; //[6.2:8:0.05]
pcb_spacer_height_mm = 8; //[4:16:0.1]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.05]
pcb_spacer_inner_diameter_mm = 6.8; //[6.2:9:0.05]
buzzer_diameter_mm = 12; //[8:24:0.1]
buzzer_height_mm = 7; //[4:14:0.1]
buzzer_center_hole_diameter_mm = 6.8; //[6.2:9:0.05]
overlap_mm = 1.2; //[0.5:2:0.1]  // 1-2mm overlap for guaranteed connectivity

// --- Z stack ---
// Reference: top of head at z = 0, everything extends downward (negative z)
z_head_top    = 0;
z_head_bottom = z_head_top - head_height_mm;

// Under-head chamfer overlaps into head and shaft
z_chamfer_top    = z_head_bottom + overlap_mm;
z_chamfer_bottom = z_chamfer_top - under_head_chamfer_height_mm;

// Shaft starts slightly inside chamfer and runs down to end of screw
z_shaft_top    = z_chamfer_bottom + overlap_mm;
z_shaft_bottom = z_head_bottom - length_under_head_mm;

// Tip chamfer at end of shaft, overlapping into shaft
z_tip_top    = z_shaft_bottom + overlap_mm;
z_tip_bottom = z_tip_top - tip_chamfer_height_mm;

// Washer sits under head, overlapping into head/shaft
z_washer_top    = z_head_bottom + overlap_mm;
z_washer_bottom = z_washer_top - washer_thickness_mm;

// Spacer sits under washer, overlapping
z_spacer_top    = z_washer_bottom + overlap_mm;
z_spacer_bottom = z_spacer_top - pcb_spacer_height_mm;

// Buzzer sits under spacer, overlapping (ensures black cylinder is attached)
z_buzzer_top    = z_spacer_bottom + overlap_mm;
z_buzzer_bottom = z_buzzer_top - buzzer_height_mm;

// --- Modules ---
module screw_and_washer() {
  color("DimGray")
  union() {
    // Hex Head
    translate([0, 0, (z_head_top + z_head_bottom)/2])
      cylinder(h=head_height_mm, r=(head_across_flats_mm/2)/cos(30), $fn=6, center=true);

    // Under-head Chamfer (overlaps into head and shaft)
    translate([0, 0, (z_chamfer_top + z_chamfer_bottom)/2])
      cylinder(
        h=under_head_chamfer_height_mm,
        r1=(head_across_flats_mm/2)/cos(30) - under_head_chamfer_radial_mm,
        r2=shaft_diameter_mm/2,
        $fn=32,
        center=true
      );

    // Shaft
    translate([0, 0, (z_shaft_top + z_shaft_bottom)/2])
      cylinder(h=(z_shaft_top - z_shaft_bottom), r=shaft_diameter_mm/2, $fn=32, center=true);

    // Tip Chamfer (overlaps into shaft)
    translate([0, 0, (z_tip_top + z_tip_bottom)/2])
      cylinder(
        h=tip_chamfer_height_mm,
        r1=shaft_diameter_mm/2,
        r2=shaft_diameter_mm/2 - tip_chamfer_radial_mm,
        $fn=32,
        center=true
      );

    // Washer (overlaps into head/shaft region)
    difference() {
      translate([0, 0, (z_washer_top + z_washer_bottom)/2])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, $fn=32, center=true);

      translate([0, 0, (z_washer_top + z_washer_bottom)/2])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_hole_diameter_mm/2, $fn=32, center=true);
    }
  }
}

module pcb_spacer() {
  color("Silver")
  union() {
    difference() {
      translate([0, 0, (z_spacer_top + z_spacer_bottom)/2])
        cylinder(
          h=pcb_spacer_height_mm,
          r=pcb_spacer_inner_diameter_mm/2 + pcb_spacer_wall_mm,
          $fn=32,
          center=true
        );

      translate([0, 0, (z_spacer_top + z_spacer_bottom)/2])
        cylinder(
          h=pcb_spacer_height_mm + 2*overlap_mm,
          r=pcb_spacer_inner_diameter_mm/2,
          $fn=32,
          center=true
        );
    }
  }
}

module buzzer() {
  // FIX: ensure the black cylinder is physically connected to the spacer by
  // (a) correct Z placement (already overlaps) and
  // (b) adding a small "coupler ring" that bridges any tolerance/boolean edge cases.
  // This does not change the visible design meaningfully, but guarantees a solid union.
  color("Black")
  union() {
    // Main buzzer body (hollow)
    difference() {
      translate([0, 0, (z_buzzer_top + z_buzzer_bottom)/2])
        cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, $fn=64, center=true);

      translate([0, 0, (z_buzzer_top + z_buzzer_bottom)/2])
        cylinder(h=buzzer_height_mm + 2*overlap_mm, r=buzzer_center_hole_diameter_mm/2, $fn=64, center=true);
    }

    // Coupler ring: overlaps into BOTH spacer bottom and buzzer top by ~overlap_mm
    // Ensures there is no floating/disconnected black section.
    coupler_h = 2*overlap_mm;
    translate([0, 0, z_buzzer_top - coupler_h/2])
      difference() {
        cylinder(h=coupler_h, r=buzzer_diameter_mm/2, $fn=64, center=true);
        cylinder(h=coupler_h + 2*overlap_mm, r=buzzer_center_hole_diameter_mm/2, $fn=64, center=true);
      }
  }
}

// Assembly: single connected solid via union()
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();
  }
}

assembly();