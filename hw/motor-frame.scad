motor_d = 36;
wall_t = 2;
wall_h = 18;
base_h = 5;
base_d = 3 * motor_d;

wires_d = 8;

sucker_neck_d = 9;
sucker_slot_d = 8;
sucker_neck_h = 3.2;
sucker_head_d = 15;

sucker_pos = base_d/2 - 0.6*sucker_neck_d;

sucker_cup_h = 9;
sucker_cup_d = 42;

module oval_hole(z_off, h,d,s) {
                translate([0,0,z_off + h/2]) {
                hull() {
                    cylinder(d=d, center=true, h=h);
                    translate([ d, 0, 0]) {
                        cylinder(d=d, center=true, h=h);
                    }
                }
               
            }

        }
module sucker_hole() {
    // translate to sucker vertical axis
    translate([sucker_pos,0,0]) {
        union() {
            // space for the sucker head
            oval_hole(sucker_neck_h, base_h - sucker_neck_h, sucker_head_d, sucker_head_d);
            // sucker neck hole & slot
            // hole
            cylinder(d=sucker_neck_d, h=sucker_neck_h, center=false);
            // slot
            translate([0,-sucker_slot_d/2,0]) {
                cube(size=[100,sucker_slot_d,sucker_neck_h]);
            }
        }
    }
}

module sucker_cup() {
        cylinder(d1 = sucker_cup_d, d2=sucker_neck_d, h=sucker_cup_h);
}

module suckers() {
    for(a = [0:120:240]) {
        rotate(a=a) translate([sucker_pos,0,-sucker_cup_h]) color("lightcyan") sucker_cup();
    }
}

module base() {
    difference() {
        cylinder(h=base_h, d=base_d, $fn=6);

        for(x=[0:120:240]) {
            rotate (a=x) {
                sucker_hole();
            }
        }
    }
}

module wire_hole() {
    translate([motor_d/2 + wall_t/2,0,wall_h/2]) {
        cube(size = [wall_t, wires_d,wall_h], center = true);
    }
}

module walls() {
    wall_size = motor_d + 2*wall_t;

    translate([0,0,wall_h/2]) {
        cube(center = true,  size=[wall_size, wall_size, wall_h]);
    }    
}

module motor_hole() {
    translate([0,0,wall_h/2]) {
        cube(center = true, 
             size=[motor_d, motor_d, wall_h]);
    }        
}

difference() {
    union() {
        walls();
        base();
        //suckers();
    }
    motor_hole();
    wire_hole();
}
    

