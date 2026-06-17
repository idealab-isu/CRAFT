// Parameters
thread_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 6;          //[3:12:0.1]
outer_diameter_mm = 6;  //[3:12:0.1]
interface_length_mm = 6; //[3:12:0.1]
overlap_mm = 1;         //[0.5:2:0.1]

$fn = 64;

// Single connected pillar (no floating sections, no gaps)
module pillar() {
  // Build as three stacked sections that overlap slightly to guarantee attachment:
  // lower dark (thread), middle light (body), upper dark (body)
  lower_h  = interface_length_mm;
  middle_h = length_mm;
  upper_h  = length_mm;

  // Z positions (centered cylinders) with 1-2mm overlap at each interface
  z_lower  = 0;
  z_middle = (lower_h/2 + middle_h/2) - overlap_mm;
  z_upper  = z_middle + (middle_h/2 + upper_h/2) - overlap_mm;

  union() {
    // Lower dark cylindrical section (thread interface)
    color("DimGray")
      translate([0, 0, z_lower])
        cylinder(h=lower_h, r=thread_diameter_mm/2, center=true);

    // Middle light cylindrical section (main body)
    color("Silver")
      translate([0, 0, z_middle])
        cylinder(h=middle_h, r=outer_diameter_mm/2, center=true);

    // Upper dark cylindrical section (main body)
    color("DimGray")
      translate([0, 0, z_upper])
        cylinder(h=upper_h, r=outer_diameter_mm/2, center=true);
  }
}

pillar();