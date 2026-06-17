// Parameters
outer_diameter = 30; //[15:60:0.1]
length = 22; //[11:44:0.1]
screw_diameter = 12; //[6:24:0.1]
internal_thread = 1; //[0:1:1]
internal_minor_diameter = 10.2; //[8:14:0.05]
lead_in_chamfer_height = 1; //[0.5:3:0.1]
lead_in_chamfer_angle_deg = 30; //[15:60:1]
knurl_depth = 0.6; //[0.2:1.2:0.05]
knurl_pitch = 1.5; //[0.8:3:0.1]
eps = 0.6; //[0.2:1.5:0.05]
rib_count = 60; //[20:120:1]
rib_width = 0.8; //[0.4:2:0.05]
rib_height = 18; //[8:30:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Gold") {
    // Insert Body
    cylinder(r=outer_diameter/2, h=length, center=true, $fn=100);

    // Internal Thread or Clearance Bore
    if (internal_thread == 1) {
      translate([0, 0, 0])
        cylinder(r=internal_minor_diameter/2, h=length + 2*eps, center=true, $fn=100);
    }

    // Lead-in Chamfer
    translate([0, 0, -length/2 + (lead_in_chamfer_height + eps)/2])
      cylinder(r1=outer_diameter/2 + eps, r2=0, h=lead_in_chamfer_height + eps, center=true, $fn=100);

    // Knurl Ribs
    for (i = [0:rib_count-1]) {
      rotate([0, 0, i*360/rib_count])
        translate([outer_diameter/2 - eps + (knurl_depth + eps)/2, 0, 0])
          cube([knurl_depth + eps, rib_width, rib_height], center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();