// Parameters
face_width = 20; //[10:40:0.5]
body_length = 30; //[15:60:0.5]
body_width = 20; //[10:40:0.5]
body_height = 20; //[10:40:0.5]
front_face_thickness = 2; //[1:6:0.25]
rear_cap_thickness = 2; //[1:6:0.25]
shaft_diameter = 5; //[2.5:10:0.1]
shaft_length = 10; //[5:30:0.5]
boss_diameter = 11; //[6:22:0.5]
boss_thickness = 2; //[1:8:0.25]
mount_hole_spacing = 16; //[8:32:0.5]
mount_hole_diameter = 3; //[1.5:6:0.1]
mount_hole_depth = 6; //[2:20:0.5]
corner_radius = 1; //[0:4:0.25]
eps = 0.8; //[0.2:2:0.1]
ttrack_length = 18; //[10:60:1]
ttrack_pitch = 6; //[3:20:0.5]
rail_length = 18; //[10:60:1]
rail_pitch = 6; //[3:20:0.5]
aux_hole_diameter = 2.5; //[1:6:0.1]
aux_hole_depth = 4; //[1:15:0.5]
d_plug_diameter = 8; //[4:16:0.5]
d_flat_depth = 1.5; //[0.5:4:0.25]
d_plug_length = 4; //[2:12:0.5]
screw_shank_diameter = 3; //[1.5:6:0.1]
screw_length = 8; //[4:25:0.5]
washer_diameter = 6; //[3:14:0.5]
washer_thickness = 1; //[0.5:3:0.25]

// Modules
module ttrack_hole_positions() {
  color("Silver") {
    union() {
      translate([face_width/2 - aux_hole_depth/2, ttrack_pitch/2, -front_face_thickness/2 - aux_hole_depth/2 + eps])
        rotate([0, 90, 0]) cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*eps, center=true);
      translate([face_width/2 - aux_hole_depth/2, -ttrack_pitch/2, -front_face_thickness/2 - aux_hole_depth/2 + eps])
        rotate([0, 90, 0]) cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*eps, center=true);
    }
  }
}

module screw_and_washer() {
  color("DimGray") {
    union() {
      translate([mount_hole_spacing/2, mount_hole_spacing/2, -front_face_thickness/2 - screw_length/2 + eps])
        cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);
      translate([mount_hole_spacing/2, mount_hole_spacing/2, front_face_thickness/2 + washer_thickness/2 - eps])
        cylinder(r=washer_diameter/2, h=washer_thickness, center=true);
    }
  }
}

module rail_hole_positions() {
  color("Silver") {
    union() {
      translate([-face_width/2 + aux_hole_depth/2, rail_pitch/2, -front_face_thickness/2 - aux_hole_depth/2 + eps])
        rotate([0, 90, 0]) cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*eps, center=true);
      translate([-face_width/2 + aux_hole_depth/2, -rail_pitch/2, -front_face_thickness/2 - aux_hole_depth/2 + eps])
        rotate([0, 90, 0]) cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*eps, center=true);
    }
  }
}

module d_plug_D() {
  color("Silver") {
    difference() {
      translate([0, 0, -front_face_thickness/2 - body_length - rear_cap_thickness - d_plug_length/2 + eps])
        cylinder(r=d_plug_diameter/2, h=d_plug_length, center=true);
      translate([d_plug_diameter/2 - d_flat_depth, 0, -front_face_thickness/2 - body_length - rear_cap_thickness - d_plug_length/2 + eps])
        cube([d_plug_diameter, d_plug_diameter, d_plug_length + 2*eps], center=true);
    }
  }
}

module ttrack_insert_hole_positions() {
  color("Silver") {
    union() {
      translate([ttrack_pitch/2, face_width/2 - aux_hole_depth/2, -front_face_thickness/2 - aux_hole_depth/2 + eps])
        rotate([90, 0, 0]) cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*eps, center=true);
      translate([-ttrack_pitch/2, face_width/2 - aux_hole_depth/2, -front_face_thickness/2 - aux_hole_depth/2 + eps])
        rotate([90, 0, 0]) cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*eps, center=true);
    }
  }
}

module assembly() {
  color("Black") {
    union() {
      // Motor Body
      translate([0, 0, -front_face_thickness/2 - body_length/2 + eps])
        cube([body_width, body_height, body_length], center=true);
      // Front Face
      translate([0, 0, 0])
        cube([face_width, face_width, front_face_thickness], center=true);
      // Rear Cap Face
      translate([0, 0, -front_face_thickness/2 - body_length - rear_cap_thickness/2 + eps])
        cube([face_width, face_width, rear_cap_thickness], center=true);
      // Shaft Boss
      translate([0, 0, front_face_thickness/2 + boss_thickness/2 - eps])
        cylinder(r=boss_diameter/2, h=boss_thickness, center=true);
      // Output Shaft
      translate([0, 0, front_face_thickness/2 + shaft_length/2 - eps])
        cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
      // Screw and Washer
      screw_and_washer();
      // D Plug
      d_plug_D();
    }
  }
  // Holes
  difference() {
    union() {
      // Mounting Holes
      union() {
        translate([mount_hole_spacing/2, mount_hole_spacing/2, -mount_hole_depth/2])
          cylinder(r=mount_hole_diameter/2, h=front_face_thickness + mount_hole_depth + 2*eps, center=true);
        translate([-mount_hole_spacing/2, mount_hole_spacing/2, -mount_hole_depth/2])
          cylinder(r=mount_hole_diameter/2, h=front_face_thickness + mount_hole_depth + 2*eps, center=true);
        translate([mount_hole_spacing/2, -mount_hole_spacing/2, -mount_hole_depth/2])
          cylinder(r=mount_hole_diameter/2, h=front_face_thickness + mount_hole_depth + 2*eps, center=true);
        translate([-mount_hole_spacing/2, -mount_hole_spacing/2, -mount_hole_depth/2])
          cylinder(r=mount_hole_diameter/2, h=front_face_thickness + mount_hole_depth + 2*eps, center=true);
      }
      // Ttrack Hole Positions
      ttrack_hole_positions();
      // Rail Hole Positions
      rail_hole_positions();
      // Ttrack Insert Hole Positions
      ttrack_insert_hole_positions();
    }
  }
}

assembly();