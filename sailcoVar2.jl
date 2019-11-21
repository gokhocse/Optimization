using JuMP, Clp, Printf

d = [40 60 75 25]                   # monthly demand for boats
b = [50]                            # boats made at q1
num_b = b[1]


m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, h[1:5] >= 0)             # boats held in inventory
@variable(m, c_positive[1:4] >= 0)
@variable(m, c_negative[1:4] >= 0)

@constraint(m, h[1] == 10)            #first inventory
@constraint(m,h[5]>=10)               # last inventory should be at least 10

@constraint(m, x[1] + y[1] - num_b == c_positive[1] - c_negative[1])                        #calculating relation with c
for i =2:4
    @constraint(m,x[i] + y[i] - (x[i-1] + y[i-1]) == c_positive[i] - c_negative[i])
end

for j=1:4
    @constraint(m,h[j]+x[j]+y[j]==d[j]+h[j+1])          #change in production and held 
end

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(c_positive) + 500*sum(c_negative))         # minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d \n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor:   %d %d %d %d \n",value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories:                %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("Increase production number : %d %d %d %d \n", value(c_positive[1]), value(c_positive[2]), value(c_positive[3]), value(c_positive[4]))
@printf("Decrease production number : %d %d %d %d \n", value(c_negative[1]), value(c_negative[2]), value(c_negative[3]), value(c_negative[4]))

@printf("Objective cost: %f\n", objective_value(m))
