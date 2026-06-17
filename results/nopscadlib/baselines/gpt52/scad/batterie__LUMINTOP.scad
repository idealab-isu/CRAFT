$fn=128;

cell_height = 70.7;
cell_diameter = 18.4;

module battery_cell(h, d) {
    cylinder(h=h, d=d, center=true);
}

battery_cell(cell_height, cell_diameter);