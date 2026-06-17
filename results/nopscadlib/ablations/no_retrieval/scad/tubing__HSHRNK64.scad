// Heatshrink sleeving: simple hollow tube (single connected solid)

// Parameters
sleeve_length   = 50;   //[25:100:1]
inner_diameter  = 6;    //[3:12:0.1]
wall_thickness  = 0.6;  //[0.3:1.2:0.05]
outer_diameter  = 7.2;  //[3.6:14.4:0.1]
chamfer_length  = 1.2;  //[0.6:2.4:0.1]
chamfer_radial  = 0.6;  //[0.3:1.2:0.05]
connect_overlap = 0.2;  //[0.05:1:0.05]

// Derived (keep consistent if user edits either OD or wall)
od = outer_diameter;
id_from_wall = od - 2*wall_thickness;
id = min(inner_diameter, id_from_wall);
id_safe = max(0.01, id);

$fn = 96;

module heatshrink_sleeve() {
  difference() {
    // Outer tube with slight end chamfers
    union() {
      // Main outer cylinder (shortened to make room for chamfers)
      cylinder(h = sleeve_length - 2*chamfer_length, r = od/2, center = true);

      // Top chamfer
      translate([0, 0, (sleeve_length/2 - chamfer_length/2)])
        cylinder(h = chamfer_length, r1 = od/2 - chamfer_radial, r2 = od/2, center = true);

      // Bottom chamfer
      translate([0, 0, -(sleeve_length/2 - chamfer_length/2)])
        cylinder(h = chamfer_length, r1 = od/2, r2 = od/2 - chamfer_radial, center = true);
    }

    // Inner bore (slightly longer to guarantee clean subtraction)
    cylinder(h = sleeve_length + 2*connect_overlap, r = id_safe/2, center = true);
  }
}

heatshrink_sleeve();