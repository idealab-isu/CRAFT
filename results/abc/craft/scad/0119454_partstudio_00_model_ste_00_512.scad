// Parameters
L = 0.1; //[0.05:0.2:0.001]
W = 0.06; //[0.03:0.12:0.001]
H = 0.05; //[0.025:0.1:0.001]
slot_L = 0.055; //[0.03:0.09:0.001]
slot_W = 0.028; //[0.012:0.045:0.001]
slot_offset_from_tip = 0.0; //[0.0:0.01:0.001]
tine_wall_min = 0.016; //[0.008:0.03:0.001]
end_round_R = 0.03; //[0.015:0.06:0.001]
chamfer_L = 0.015; //[0.005:0.03:0.001]
chamfer_drop = 0.02; //[0.005:0.04:0.001]
hex_flat_AF = 0.018; //[0.01:0.03:0.001]
hex_axis_d = 0.06; //[0.03:0.12:0.001]
hex_center_x_from_rounded_end = 0.02; //[0.005:0.04:0.001]
hex_center_z = 0.025; //[0.01:0.04:0.001]
eps = 0.001; //[0.0005:0.002:0.0005]
hole_leadin_L = 0.006; //[0.002:0.012:0.001]
hole_leadin_scale = 1.25; //[1.05:1.6:0.01]
tine_tip_R = 0.008; //[0.003:0.015:0.001]
edge_fillet_R = 0.004; //[0.001:0.01:0.001]

// Main prismatic body
module main_prismatic_body() {
  cube([L, W, H], center=true);
}

// Rounded end cap
module rounded_end_cap() {
  rotate([90, 0, 0])
    translate([L/2 - min(W/2, H/2, end_round_R), 0, 0])
      cylinder(r=min(W/2, H/2, end_round_R), h=W, center=true);
}

// Rectangular through slot for two tines
module rectangular_through_slot_two_tines() {
  translate([-L/2 + slot_offset_from_tip + (slot_L + eps)/2, 0, 0])
    cube([slot_L + eps, slot_W, H + 2*eps], center=true);
}

// Chamfered tapered end
module chamfered_tapered_end() {
  translate([-L/2 + (chamfer_L + eps)/2, 0, H/2 - (chamfer_drop + eps)/2])
    cube([chamfer_L + eps, W + 2*eps, chamfer_drop + eps], center=true);
}

// Transverse hex through hole
module transverse_hex_through_hole() {
  rotate([90, 0, 0])
    translate([L/2 - min(W/2, H/2, end_round_R) - hex_center_x_from_rounded_end, 0, -H/2 + hex_center_z])
      linear_extrude(height=hex_axis_d + 2*eps, center=true)
        polygon(points=[
          [hex_flat_AF/sqrt(3), hex_flat_AF/2],
          [0, hex_flat_AF],
          [-hex_flat_AF/sqrt(3), hex_flat_AF/2],
          [-hex_flat_AF/sqrt(3), -hex_flat_AF/2],
          [0, -hex_flat_AF],
          [hex_flat_AF/sqrt(3), -hex_flat_AF/2]
        ]);
}

// Small lead-in chamfers on hole (left and right)
module small_lead_in_chamfers_on_hole_left() {
  rotate([90, 0, 0])
    translate([L/2 - min(W/2, H/2, end_round_R) - hex_center_x_from_rounded_end, -W/2 + (hole_leadin_L + eps)/2, -H/2 + hex_center_z])
      linear_extrude(height=hole_leadin_L + eps, center=true)
        polygon(points=[
          [(hex_flat_AF*hole_leadin_scale)/sqrt(3), (hex_flat_AF*hole_leadin_scale)/2],
          [0, hex_flat_AF*hole_leadin_scale],
          [-(hex_flat_AF*hole_leadin_scale)/sqrt(3), (hex_flat_AF*hole_leadin_scale)/2],
          [-(hex_flat_AF*hole_leadin_scale)/sqrt(3), -(hex_flat_AF*hole_leadin_scale)/2],
          [0, -hex_flat_AF*hole_leadin_scale],
          [(hex_flat_AF*hole_leadin_scale)/sqrt(3), -(hex_flat_AF*hole_leadin_scale)/2]
        ]);
}

module small_lead_in_chamfers_on_hole_right() {
  rotate([90, 0, 0])
    translate([L/2 - min(W/2, H/2, end_round_R) - hex_center_x_from_rounded_end, W/2 - (hole_leadin_L + eps)/2, -H/2 + hex_center_z])
      linear_extrude(height=hole_leadin_L + eps, center=true)
        polygon(points=[
          [(hex_flat_AF*hole_leadin_scale)/sqrt(3), (hex_flat_AF*hole_leadin_scale)/2],
          [0, hex_flat_AF*hole_leadin_scale],
          [-(hex_flat_AF*hole_leadin_scale)/sqrt(3), (hex_flat_AF*hole_leadin_scale)/2],
          [-(hex_flat_AF*hole_leadin_scale)/sqrt(3), -(hex_flat_AF*hole_leadin_scale)/2],
          [0, -hex_flat_AF*hole_leadin_scale],
          [(hex_flat_AF*hole_leadin_scale)/sqrt(3), -(hex_flat_AF*hole_leadin_scale)/2]
        ]);
}

// Tine tip rounding spheres
module tine_tip_rounding_left_sphere() {
  translate([-L/2 + tine_tip_R, slot_W/2 + (W - slot_W)/4, 0])
    sphere(r=tine_tip_R, center=true);
}

module tine_tip_rounding_left_sphere_back() {
  translate([-L/2 + tine_tip_R + chamfer_L/2, slot_W/2 + (W - slot_W)/4, 0])
    sphere(r=tine_tip_R, center=true);
}

module tine_tip_rounding_right_sphere() {
  translate([-L/2 + tine_tip_R, -(slot_W/2 + (W - slot_W)/4), 0])
    sphere(r=tine_tip_R, center=true);
}

module tine_tip_rounding_right_sphere_back() {
  translate([-L/2 + tine_tip_R + chamfer_L/2, -(slot_W/2 + (W - slot_W)/4), 0])
    sphere(r=tine_tip_R, center=true);
}

// Edge fillets sphere
module edge_fillets_sphere() {
  sphere(r=edge_fillet_R, center=true);
}

// Assemble the clevis/fork bracket
module clevis_fork_bracket() {
  // Body with rounded end
  union() {
    main_prismatic_body();
    rounded_end_cap();
  }
  
  // Tine tip rounding
  hull() {
    tine_tip_rounding_left_sphere();
    tine_tip_rounding_left_sphere_back();
  }
  
  hull() {
    tine_tip_rounding_right_sphere();
    tine_tip_rounding_right_sphere_back();
  }
  
  // Body with tip rounding
  union() {
    main_prismatic_body();
    rounded_end_cap();
    hull() {
      tine_tip_rounding_left_sphere();
      tine_tip_rounding_left_sphere_back();
    }
    hull() {
      tine_tip_rounding_right_sphere();
      tine_tip_rounding_right_sphere_back();
    }
  }
  
  // Body minus slot
  difference() {
    union() {
      main_prismatic_body();
      rounded_end_cap();
      hull() {
        tine_tip_rounding_left_sphere();
        tine_tip_rounding_left_sphere_back();
      }
      hull() {
        tine_tip_rounding_right_sphere();
        tine_tip_rounding_right_sphere_back();
      }
    }
    rectangular_through_slot_two_tines();
  }
  
  // Body minus slot and taper
  difference() {
    difference() {
      union() {
        main_prismatic_body();
        rounded_end_cap();
        hull() {
          tine_tip_rounding_left_sphere();
          tine_tip_rounding_left_sphere_back();
        }
        hull() {
          tine_tip_rounding_right_sphere();
          tine_tip_rounding_right_sphere_back();
        }
      }
      rectangular_through_slot_two_tines();
    }
    chamfered_tapered_end();
  }
  
  // Body minus hex main
  difference() {
    difference() {
      difference() {
        union() {
          main_prismatic_body();
          rounded_end_cap();
          hull() {
            tine_tip_rounding_left_sphere();
            tine_tip_rounding_left_sphere_back();
          }
          hull() {
            tine_tip_rounding_right_sphere();
            tine_tip_rounding_right_sphere_back();
          }
        }
        rectangular_through_slot_two_tines();
      }
      chamfered_tapered_end();
    }
    transverse_hex_through_hole();
  }
  
  // Body minus hex with lead-ins
  difference() {
    difference() {
      difference() {
        difference() {
          union() {
            main_prismatic_body();
            rounded_end_cap();
            hull() {
              tine_tip_rounding_left_sphere();
              tine_tip_rounding_left_sphere_back();
            }
            hull() {
              tine_tip_rounding_right_sphere();
              tine_tip_rounding_right_sphere_back();
            }
          }
          rectangular_through_slot_two_tines();
        }
        chamfered_tapered_end();
      }
      transverse_hex_through_hole();
    }
    small_lead_in_chamfers_on_hole_left();
    small_lead_in_chamfers_on_hole_right();
  }
  
  // Edge fillets
  minkowski() {
    difference() {
      difference() {
        difference() {
          difference() {
            union() {
              main_prismatic_body();
              rounded_end_cap();
              hull() {
                tine_tip_rounding_left_sphere();
                tine_tip_rounding_left_sphere_back();
              }
              hull() {
                tine_tip_rounding_right_sphere();
                tine_tip_rounding_right_sphere_back();
              }
            }
            rectangular_through_slot_two_tines();
          }
          chamfered_tapered_end();
        }
        transverse_hex_through_hole();
      }
      small_lead_in_chamfers_on_hole_left();
      small_lead_in_chamfers_on_hole_right();
    }
    edge_fillets_sphere();
  }
}

// Render the final clevis/fork bracket
clevis_fork_bracket();