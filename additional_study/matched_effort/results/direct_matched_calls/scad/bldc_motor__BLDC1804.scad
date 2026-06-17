$fn=128;

// Brushless DC motor (simplified) with 23mm stator diameter and 12mm stator height

stator_d = 23.0;
stator_h = 12.0;

// Assumptions for a simple, renderable motor model
airgap = 0.4;
can_wall = 0.8;
can_overhang = 1.5;

can_d = stator_d + 2*(airgap + can_wall);
can_h = stator_h + 2*can_overhang;

base_thk = 1.2;
base_d = can_d + 2.0;

shaft_d = 3.0;
shaft_len_front = 10.0;
shaft_len_back = 2.0;

mount_hole_d = 2.0;
mount_hole_r = (base_d/2) - 3.0;

module motor() {
  union() {
    // Outer can (rotor housing)
    difference() {
      translate([0,0,base_thk])
        cylinder(d=can_d, h=can_h);
      // Hollow inside can
      translate([0,0,base_thk + 0.6])
        cylinder(d=can_d - 2*can_wall, h=can_h - 1.2);
    }

    // Base plate
    difference() {
      cylinder(d=base_d, h=base_thk);
      // Mount holes (4x)
      for (a = [0:90:270]) {
        translate([mount_hole_r*cos(a), mount_hole_r*sin(a), -0.1])
          cylinder(d=mount_hole_d, h=base_thk + 0.2);
      }
      // Center clearance
      translate([0,0,-0.1])
        cylinder(d=shaft_d + 2.0, h=base_thk + 0.2);
    }

    // Stator (inside)
    translate([0,0,base_thk + can_overhang])
      color([0.6,0.6,0.6])
        difference() {
          cylinder(d=stator_d, h=stator_h);
          // Inner bore
          cylinder(d=stator_d*0.45, h=stator_h + 0.1);
        }

    // Simple windings ring (visual)
    translate([0,0,base_thk + can_overhang + 0.5])
      color([0.8,0.4,0.1])
        difference() {
          cylinder(d=stator_d*0.98, h=stator_h-1.0);
          cylinder(d=stator_d*0.78, h=stator_h-0.9);
        }

    // Shaft (through)
    color([0.75,0.75,0.8])
      translate([0,0,base_thk + can_overhang + stator_h])
        cylinder(d=shaft_d, h=shaft_len_front);

    color([0.75,0.75,0.8])
      translate([0,0,-shaft_len_back])
        cylinder(d=shaft_d, h=shaft_len_back + base_thk + 0.2);

    // Front endcap lip
    translate([0,0,base_thk + can_h - 1.0])
      difference() {
        cylinder(d=can_d, h=1.0);
        translate([0,0,-0.1])
          cylinder(d=can_d - 2*can_wall, h=1.2);
      }
  }
}

motor();