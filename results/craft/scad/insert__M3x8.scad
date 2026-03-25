// Parameters
screw_diameter = 3; //[1.5:6:0.1]
outer_diameter = 8; //[4:16:0.1]
length = 6; //[3:12:0.1]
thread_minor_diameter = 2.5; //[1.8:4.5:0.05]
thread_clearance = 0.15; //[0.05:0.4:0.01]
rib_count = 12; //[6:24:1]
rib_radial_height = 0.5; //[0.2:1.2:0.05]
rib_tangential_width = 1.2; //[0.6:2.4:0.05]
rib_axial_height = 4.2; //[2:10:0.1]
rib_overlap = 0.8; //[0.3:2:0.05]
entry_chamfer_height = 0.8; //[0.3:2:0.05]
lead_in_chamfer_height = 0.6; //[0.3:2:0.05]
chamfer_radial_reduction = 0.6; //[0.2:1.5:0.05]
inner_void_bottom_offset = 0.6; //[0.3:2:0.05]
eps_overlap = 0.8; //[0.2:2:0.05]

// M3x8 Insert - complete geometry
module insert() {
  color("Brass") {
    // Base cylinder
    cylinder(r=outer_diameter/2, h=length, center=true);

    // Ribs
    for (i = [0:rib_count-1]) {
      rotate([0, 0, i*360/rib_count])
      translate([outer_diameter/2 - rib_overlap + (rib_radial_height + rib_overlap)/2, 0, 0])
      cube([rib_radial_height + rib_overlap, rib_tangential_width, rib_axial_height], center=true);
    }

    // Entry chamfer
    translate([0, 0, length/2 - entry_chamfer_height/2])
    cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial_reduction, h=entry_chamfer_height, center=true);

    // Lead-in chamfer
    translate([0, 0, -length/2 + lead_in_chamfer_height/2])
    cylinder(r1=outer_diameter/2 - chamfer_radial_reduction, r2=outer_diameter/2, h=lead_in_chamfer_height, center=true);
  }
}

// Threaded Insert - complete geometry
module threaded_insert() {
  difference() {
    insert();
    // Internal thread void
    translate([0, 0, inner_void_bottom_offset])
    cylinder(r=thread_minor_diameter/2 + thread_clearance, h=length + 2*eps_overlap, center=true);
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();