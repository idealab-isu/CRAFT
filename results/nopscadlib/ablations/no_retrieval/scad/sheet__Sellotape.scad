// A sheet: Sellotape tape (thin rectangular sheet/strip)
// Simple, single solid object, with slight overlaps for robust union

$fn = 96;

// Parameters (mm)
sheet_length = 140;          // overall length of tape sheet
sheet_width  = 60;           // overall width
sheet_thickness = 0.6;       // thin sheet thickness

// Optional subtle "folded corner" to make it recognizable as a sheet of tape
corner_fold_size = 18;       // size of folded corner square
corner_fold_lift = 1.2;      // how much the corner lifts (still connected)
corner_fold_thickness = 0.6; // same thickness as sheet

// Connectivity overlap (1-2mm)
overlap = 1.2;

// Base sheet
module tape_sheet_base() {
  cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

// Folded corner (a small wedge-like flap) - connected via overlap
module tape_sheet_folded_corner() {
  // Place at +X +Y corner of the sheet
  // Base sheet extents: X = ±sheet_length/2, Y = ±sheet_width/2
  // Fold piece centered near the corner, slightly above, but overlapping into the sheet by 'overlap'
  translate([
    sheet_length/2 - corner_fold_size/2 + overlap/2,
    sheet_width/2  - corner_fold_size/2 + overlap/2,
    sheet_thickness/2 + corner_fold_lift/2 - overlap/2
  ])
  // Create a simple ramp by hulling two thin rectangles
  hull() {
    // Attached edge (touching/overlapping the sheet)
    translate([-corner_fold_size/2 + overlap/2, -corner_fold_size/2 + overlap/2, -corner_fold_lift/2])
      cube([corner_fold_size, corner_fold_size, corner_fold_thickness], center=true);

    // Lifted tip (slightly raised)
    translate([corner_fold_size/2 - overlap/2, corner_fold_size/2 - overlap/2, corner_fold_lift/2])
      cube([corner_fold_size*0.35, corner_fold_size*0.35, corner_fold_thickness], center=true);
  }
}

// Final single solid
union() {
  tape_sheet_base();
  tape_sheet_folded_corner();
}