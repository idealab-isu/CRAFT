// Parameters
thread_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 20; //[10:40:0.5]
outer_diameter_mm = 6; //[3.5:12:0.5]
thread_length_top_mm = 20; //[0:20:0.5]
thread_length_bottom_mm = 0; //[0:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Single standoff/pillar solid (outer body with internal clearance)
module pillar_solid() {
  difference() {
    // Outer body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

    // Internal clearance (overlapped slightly to avoid coincident faces)
    union() {
      if (thread_length_top_mm > 0)
        translate([0, 0,  length_mm/2 - (thread_length_top_mm + overlap_mm)/2])
          cylinder(h=thread_length_top_mm + overlap_mm, r=thread_diameter_mm/2, center=true);

      if (thread_length_bottom_mm > 0)
        translate([0, 0, -length_mm/2 + (thread_length_bottom_mm + overlap_mm)/2])
          cylinder(h=thread_length_bottom_mm + overlap_mm, r=thread_diameter_mm/2, center=true);
    }
  }
}

// Assembly: ensure physical attachment with 1mm overlap and union into one solid
module assembly() {
  union() {
    // Lower segment
    color("Silver") pillar_solid();

    // Upper segment: positioned to overlap by overlap_mm (no gap / no floating)
    // For center=true cylinders: required center-to-center distance = length_mm - overlap_mm
    translate([0, 0, length_mm - overlap_mm])
      color("DimGray") pillar_solid();
  }
}

assembly();