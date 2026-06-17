// Threaded heat-set insert (simplified solid with bore + lead-in chamfers)
// Target: 5.8mm OD, 7.1mm length, for 5.0mm screws

$fn = 128;

// Parameters
outer_diameter_mm = 5.8; //[2.9:11.6:0.1]
length_mm = 7.1; //[3.55:14.2:0.1]
screw_nominal_diameter_mm = 5.0; //[2.5:10.0:0.1]
tolerance_outer_diameter_mm = 0.0; //[-0.3:0.3:0.05]
tolerance_length_mm = 0.0; //[-0.5:0.5:0.05]
tolerance_internal_mm = 0.2; //[0.0:0.6:0.05]
chamfer_height_mm = 0.5; //[0.0:1.5:0.05]
chamfer_angle_deg = 45; //[20:70:1]
overlap_mm = 0.8; //[0.2:2.0:0.1]

// Derived
insert_outer_d = outer_diameter_mm + tolerance_outer_diameter_mm;
insert_length  = length_mm + tolerance_length_mm;

outer_r = insert_outer_d / 2;

bore_d = screw_nominal_diameter_mm + tolerance_internal_mm;
bore_r = bore_d / 2;

// Ensure valid, visible wall thickness (prevents "blank" results from invalid subtraction)
min_wall_mm = 0.25;
bore_r_safe = min(bore_r, outer_r - min_wall_mm);

// Chamfer radius increase (OpenSCAD trig uses degrees)
chamfer_dr = chamfer_height_mm * tan(chamfer_angle_deg);

// Chamfer outer radius at the face (must stay inside outer wall)
chamfer_r_outer = min(outer_r - 0.01, bore_r_safe + chamfer_dr);

// Clamp chamfer height so it can't exceed half the length
ch_h = min(chamfer_height_mm, insert_length/2 - 0.01);

module threaded_insert() {
  color("Gold")
  difference() {
    // Outer body
    cylinder(r=outer_r, h=insert_length, center=true);

    // Through bore (longer for robust subtraction)
    cylinder(r=bore_r_safe, h=insert_length + 2*overlap_mm, center=true);

    // Top lead-in chamfer (subtract)
    translate([0, 0, insert_length/2 - ch_h/2])
      cylinder(r1=chamfer_r_outer, r2=bore_r_safe, h=ch_h + overlap_mm, center=true);

    // Bottom lead-in chamfer (subtract)
    translate([0, 0, -(insert_length/2 - ch_h/2)])
      cylinder(r1=bore_r_safe, r2=chamfer_r_outer, h=ch_h + overlap_mm, center=true);
  }
}

threaded_insert();