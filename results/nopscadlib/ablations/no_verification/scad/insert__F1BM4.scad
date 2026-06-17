// Threaded heat-set insert (single connected solid with internal bore)
// Target: 8.2mm OD, 6.3mm length, for 4.0mm screws

$fn = 128;

// Parameters
outer_diameter_mm = 8.2;          //[4.1:16.4:0.1]
length_mm = 6.3;                  //[3.15:12.6:0.1]
screw_diameter_mm = 4.0;          //[2:8:0.1]

top_chamfer_height_mm = 0.5;      //[0.25:1:0.05]
bottom_chamfer_height_mm = 0.5;   //[0.25:1:0.05]

knurl_depth_mm = 0.3;             //[0.15:0.6:0.05]
knurl_count = 24;                 //[12:48:1]
knurl_height_mm = 5.3;            //[2.65:10.6:0.1]
knurl_ridge_width_mm = 0.6;       //[0.3:1.2:0.05]

bore_minor_diameter_mm = 3.3;     //[1.65:6.6:0.05]
bore_clearance_mm = 0.0;          //[0:0.5:0.05]

overlap_mm = 0.8;                 //[0.5:2:0.1]

// Derived
outer_r = outer_diameter_mm/2;
bore_r  = (bore_minor_diameter_mm + bore_clearance_mm)/2;

// Keep knurls within the overall OD so OD remains exactly outer_diameter_mm
knurl_radial = min(knurl_depth_mm, outer_r * 0.25);
knurl_outer_r = outer_r;                 // do not exceed OD
knurl_inner_r = outer_r - knurl_radial;  // knurl overlaps into body

// Ensure knurl band stays within insert length
knurl_h = min(knurl_height_mm, max(0, length_mm - (top_chamfer_height_mm + bottom_chamfer_height_mm)));
knurl_z = (top_chamfer_height_mm - bottom_chamfer_height_mm)/2; // centers knurl band between chamfers

module threaded_insert() {
  difference() {
    // Outer solid (body + knurls) as ONE connected solid
    union() {
      // Main body
      cylinder(r=outer_r, h=length_mm, center=true);

      // Knurl ridges (embedded so OD stays at outer_diameter_mm)
      // Place ridges so their OUTER face is at outer_r (no OD growth)
      for (i = [0:knurl_count-1]) {
        rotate([0, 0, i*360/knurl_count])
          translate([outer_r - knurl_radial/2, 0, knurl_z])
            cube([knurl_radial, knurl_ridge_width_mm, knurl_h], center=true);
      }
    }

    // Top chamfer (remove material)
    translate([0, 0, length_mm/2 - top_chamfer_height_mm/2])
      cylinder(r1=outer_r, r2=max(0.01, outer_r - top_chamfer_height_mm),
               h=top_chamfer_height_mm, center=true);

    // Bottom chamfer (remove material)
    translate([0, 0, -length_mm/2 + bottom_chamfer_height_mm/2])
      cylinder(r1=max(0.01, outer_r - bottom_chamfer_height_mm), r2=outer_r,
               h=bottom_chamfer_height_mm, center=true);

    // Internal bore (through hole)
    cylinder(r=bore_r, h=length_mm + 2*overlap_mm, center=true);
  }
}

threaded_insert();