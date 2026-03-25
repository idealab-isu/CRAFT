// T-slot / hammer nut for M3 screw
// Targets: 3.0mm screw hole, 6.0mm across flats hex, 2.75mm thick overall
// One connected solid, no floating parts, no washer ring.

$fn = 64;

// Parameters (kept from original where relevant)
screw_nominal_diameter_mm = 3;          //[1.5:6:0.1]
nut_across_flats_mm = 6;                //[3:12:0.1]
nut_thickness_mm = 2.75;                //[1.4:5.5:0.05]
thread_clearance_diameter_mm = 3.2;     //[2.8:4:0.05]
tap_drill_diameter_mm = 2.5;            //[2:3:0.05]
hole_style_select = 0;                  //[0:1:1] 0=clearance, 1=tap drill
edge_chamfer_mm = 0.2;                  //[0:1:0.05]
t_slot_nut_overall_length_mm = 10;      //[6:20:0.5]
t_slot_nut_overall_width_mm = 6.8;      //[5:12:0.1]
t_slot_neck_width_mm = 4.2;             //[3:8:0.1]
retention_lip_height_mm = 0.6;          //[0.3:1.5:0.05]
anti_rotation_rib_depth_mm = 0.4;       //[0:1.5:0.05]
anti_rotation_rib_width_mm = 1.2;       //[0.6:3:0.1]
anti_rotation_rib_height_mm = 1.2;      //[0.6:2.75:0.05]
overlap_mm = 0.25;                      //[0.2:2:0.1]

// Derived
hex_circumradius_mm = nut_across_flats_mm / sqrt(3); // across flats -> circumradius
hole_diameter_mm = (hole_style_select == 0) ? thread_clearance_diameter_mm : tap_drill_diameter_mm;

module chamfered_block(size=[10,6,2.75], chamfer=0.2, center=true) {
  // Simple 45° edge chamfer on top/bottom perimeter using hull of two offset rectangles
  // (keeps it robust and connected; avoids floating geometry)
  x = size[0]; y = size[1]; z = size[2];
  c = max(0, min(chamfer, min(x,y)/4, z/4));
  if (c <= 0) {
    cube(size, center=center);
  } else {
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
      hull() {
        translate([0,0, (z/2 - c)]) cube([x, y, 2*c], center=true);
        translate([0,0, -(z/2 - c)]) cube([x, y, 2*c], center=true);
        cube([x-2*c, y-2*c, z], center=true);
      }
  }
}

module tslot_nut() {
  difference() {
    union() {
      // Main T-slot body (rectangular hammer nut form)
      chamfered_block(
        size=[t_slot_nut_overall_length_mm, t_slot_nut_overall_width_mm, nut_thickness_mm],
        chamfer=edge_chamfer_mm,
        center=true
      );

      // Central hex boss (6mm across flats), kept within overall thickness
      // Slight overlap ensures a single connected solid.
      cylinder(r=hex_circumradius_mm, h=nut_thickness_mm + overlap_mm, center=true, $fn=6);

      // Retention lips (bottom side), connected by overlap into main body
      lip_w = (t_slot_nut_overall_width_mm - t_slot_neck_width_mm)/2;
      lip_w_eff = max(0, lip_w);
      if (lip_w_eff > 0) {
        z_lip = -nut_thickness_mm/2 + retention_lip_height_mm/2 + overlap_mm/2;
        y_off = t_slot_neck_width_mm/2 + lip_w_eff/2 - overlap_mm/2;

        translate([0,  y_off, z_lip])
          cube([t_slot_nut_overall_length_mm, lip_w_eff, retention_lip_height_mm + overlap_mm], center=true);

        translate([0, -y_off, z_lip])
          cube([t_slot_nut_overall_length_mm, lip_w_eff, retention_lip_height_mm + overlap_mm], center=true);
      }

      // Anti-rotation ribs on top face edges (optional), connected by overlap
      rib_h = min(anti_rotation_rib_height_mm, nut_thickness_mm);
      if (anti_rotation_rib_depth_mm > 0 && anti_rotation_rib_width_mm > 0 && rib_h > 0) {
        z_rib = nut_thickness_mm/2 - rib_h/2 + overlap_mm/2;
        x_rib = t_slot_nut_overall_length_mm/2 - anti_rotation_rib_width_mm/2 + overlap_mm/2;
        y_rib = t_slot_nut_overall_width_mm/2 - anti_rotation_rib_depth_mm/2 + overlap_mm/2;

        translate([ x_rib,  y_rib, z_rib])
          cube([anti_rotation_rib_width_mm + overlap_mm, anti_rotation_rib_depth_mm + overlap_mm, rib_h + overlap_mm], center=true);

        translate([-x_rib, -y_rib, z_rib])
          cube([anti_rotation_rib_width_mm + overlap_mm, anti_rotation_rib_depth_mm + overlap_mm, rib_h + overlap_mm], center=true);
      }
    }

    // Through-hole for M3 screw (clearance or tap drill)
    cylinder(d=hole_diameter_mm, h=nut_thickness_mm + 2, center=true, $fn=48);
  }
}

tslot_nut();