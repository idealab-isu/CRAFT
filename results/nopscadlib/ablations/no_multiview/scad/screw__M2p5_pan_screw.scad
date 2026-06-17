// Parameters
shaft_diameter_mm = 2.5; //[1.25:5:0.05]
shaft_radius_mm   = shaft_diameter_mm/2; //[0.625:2.5:0.05]
length_under_head_mm = 10; //[5:20:0.1]

head_diameter_mm = 4.7; //[2.35:9.4:0.05]
head_radius_mm   = head_diameter_mm/2; //[1.175:4.7:0.05]
head_height_mm   = 1.7; //[0.85:3.4:0.05]

eps_mm = 0.05; //[0.01:0.2:0.01]
overlap_mm = 1.0; // 1-2mm overlap to guarantee watertight connections

head_dome_radius_mm = 3.2; //[1.6:6.4:0.1]
recess_radius_mm = 1.4; //[0.7:2.8:0.05]
recess_depth_mm  = 0.7; //[0.3:1.4:0.05]
recess_slot_width_mm = 0.6; //[0.3:1.2:0.05]

// "Large black circular disk" (washer-like part) parameters
disk_radius_mm = 10;
disk_height_mm = 5;
disk_hub_radius_mm = 3;
disk_hub_height_mm = 10;

// Derived Z locations (all parts centered on Z axis)
disk_z = 0; // disk centered at origin
hub_z  = disk_z + (disk_height_mm/2 + disk_hub_height_mm/2 - overlap_mm);

// Shaft/bit assembly must be physically attached to the hub and to the screw.
// Make a connector shaft that runs from inside the hub up into the screw head underside.
connector_h_mm = length_under_head_mm + 2*overlap_mm;
connector_z = (hub_z + disk_hub_height_mm/2) + connector_h_mm/2 - overlap_mm;

// Place screw so its shaft overlaps into the connector by overlap_mm.
// Screw shaft top (in screw local coords) is at +overlap_mm above head underside.
// Therefore set head underside to connector top + overlap_mm.
connector_top_z = connector_z + connector_h_mm/2;
head_underside_z = connector_top_z + overlap_mm;
screw_z = head_underside_z + head_height_mm/2;

// Screw (single solid)
module screw() {
  union() {
    // Shaft: overlaps into head by overlap_mm
    translate([0, 0, -(head_height_mm/2 + length_under_head_mm/2 - overlap_mm)])
      cylinder(h=length_under_head_mm, r=shaft_radius_mm, center=true);

    // Pan head with recess
    difference() {
      union() {
        cylinder(h=head_height_mm, r=head_radius_mm, center=true);

        translate([0, 0, head_height_mm/2 - head_dome_radius_mm + eps_mm])
          sphere(r=head_dome_radius_mm, center=true);
      }

      // Recess cross
      union() {
        translate([0, 0, head_height_mm/2 - recess_depth_mm/2])
          cylinder(h=recess_depth_mm + 2*eps_mm, r=recess_radius_mm, center=true);

        translate([0, 0, head_height_mm/2 - recess_depth_mm/2])
          cube([2*recess_radius_mm + 2*eps_mm, recess_slot_width_mm, recess_depth_mm + 2*eps_mm], center=true);

        translate([0, 0, head_height_mm/2 - recess_depth_mm/2])
          cube([recess_slot_width_mm, 2*recess_radius_mm + 2*eps_mm, recess_depth_mm + 2*eps_mm], center=true);
      }
    }
  }
}

// Large disk + hub + connector shaft (single solid, physically attached)
module disk_stack() {
  union() {
    color("Black")
      translate([0, 0, disk_z])
        cylinder(h=disk_height_mm, r=disk_radius_mm, center=true);

    // Hub overlaps into disk by overlap_mm
    color("DimGray")
      translate([0, 0, hub_z])
        cylinder(h=disk_hub_height_mm, r=disk_hub_radius_mm, center=true);

    // Connector shaft overlaps into hub by overlap_mm and into screw shaft by overlap_mm
    color("DimGray")
      translate([0, 0, connector_z])
        cylinder(h=connector_h_mm, r=shaft_radius_mm, center=true);
  }
}

// Assembly: everything unioned into one connected solid
module assembly() {
  union() {
    disk_stack();

    translate([0, 0, screw_z])
      color("Silver")
        screw();
  }
}

assembly();