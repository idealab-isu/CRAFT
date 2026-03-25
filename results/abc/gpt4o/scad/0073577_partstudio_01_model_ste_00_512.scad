module diamond_hole(size, position) {
    rotate(45) translate(position) square(size, center=true);
}

module rectangular_slot(size, position) {
    translate(position) square(size, center=true);
}

module l_bracket() {
    base_length = 100;
    base_width = 10;
    base_thickness = 5;
    upright_height = 50;
    upright_thickness = 5;
    gusset_length = 30;
    gusset_thickness = 5;
    hole_size = [5, 5];
    slot_size = [20, 5];
    tab_size = [5, 5];
    
    // Base
    base = cube([base_length, base_width, base_thickness], center=true);
    
    // Upright
    upright = translate([0, base_width/2, base_thickness/2]) 
              rotate([90, 0, 0]) 
              cube([upright_height, base_width, upright_thickness], center=true);
    
    // Gusset
    gusset = translate([0, base_width/2, base_thickness/2]) 
             rotate([45, 0, 0]) 
             cube([gusset_length, base_width, gusset_thickness], center=true);
    
    // Diamond holes on base
    base_holes = union() {
        diamond_hole(hole_size, [-30, 0, 0]);
        diamond_hole(hole_size, [0, 0, 0]);
        diamond_hole(hole_size, [30, 0, 0]);
    };
    
    // Diamond holes on upright
    upright_holes = union() {
        diamond_hole(hole_size, [0, 0, 20]);
        diamond_hole(hole_size, [0, 0, 0]);
        diamond_hole(hole_size, [0, 0, -20]);
    };
    
    // Rectangular slot on base
    base_slot = rectangular_slot(slot_size, [0, 0, 0]);
    
    // Rectangular slot on upright
    upright_slot = rectangular_slot(slot_size, [0, 0, 0]);
    
    // Tabs on base
    base_tabs = union() {
        translate([-45, base_width/2, base_thickness/2]) cube(tab_size, center=true);
        translate([45, base_width/2, base_thickness/2]) cube(tab_size, center=true);
    };
    
    // Tabs on upright
    upright_tabs = union() {
        translate([0, base_width/2, 20]) cube(tab_size, center=true);
        translate([0, base_width/2, -20]) cube(tab_size, center=true);
    };
    
    // Assemble the bracket
    difference() {
        union() {
            base;
            upright;
            gusset;
            base_tabs;
            upright_tabs;
        }
        translate([0, 0, base_thickness/2]) base_holes;
        translate([0, base_width/2, base_thickness/2]) base_slot;
        translate([0, base_width/2, upright_height/2]) upright_holes;
        translate([0, base_width/2, upright_height/2]) upright_slot;
    }
}

l_bracket();