$fn=128;

cell_h = 50.0;
cell_d = 26.2;

module battery_cell(h=cell_h, d=cell_d) {
    cylinder(h=h, d=d, center=true);
}

battery_cell();