using Ipopt

# hs071
# min x1 * x4 * (x1 + x2 + x3) + x3
# st  x1 * x2 * x3 * x4 >= 25
#     x1^2 + x2^2 + x3^2 + x4^2 = 40
#     1 <= x1, x2, x3, x4 <= 5
# Start at (1,5,5,1)
# End at (1.000..., 4.743..., 3.821..., 1.379...)

function eval_f(n::Cint, x_ptr::Ptr{Float64}, new_x::Cint, obj_ptr::Ptr{Float64}, user_data::Ptr{Void})
  println("eval_f")
  # Return the value of the objective function at the point $ x$ .
  # n: (in), the number of variables in the problem (dimension of $ x$ ).
  # x: (in), the values for the primal variables, $ x$ , at which  $ f(x)$ is to be evaluated.
  # new_x: (in), false if any evaluation method was previously called with the same values in x, true otherwise.
  # obj_value: (out) the value of the objective function ($ f(x)$ ).
  
  x = pointer_to_array(x_ptr, n*1)

  new_obj = x[1] * x[4] * (x[1] + x[2] + x[3]) + x[3]

  unsafe_store!(obj_ptr, new_obj)

  return int32(1)
end

function eval_g(n::Cint, x_ptr::Ptr{Float64}, new_x::Cint, m::Cint, g::Ptr{Float64}, user_data::Ptr{Void})
  println("eval_g")
  # Return the value of the constraint function at the point $ x$ .
  # n: (in), the number of variables in the problem (dimension of $ x$ ).
  # x: (in), the values for the primal variables, $ x$ , at which the constraint functions,  $ g(x)$ , are to be evaluated.
  # new_x: (in), false if any evaluation method was previously called with the same values in x, true otherwise.
  # m: (in), the number of constraints in the problem (dimension of $ g(x)$ ).
  # g: (out) the array of constraint function values, $ g(x)$ .

  x = pointer_to_array(x_ptr, n*1)

  unsafe_store!(g, x[1] * x[2] * x[3] * x[4], 1)
  unsafe_store!(g, x[1]*x[1] + x[2]*x[2] + x[3]*x[3] + x[4]*x[4], 2)

  return int32(1)
end

function eval_grad_f(n::Cint, x_ptr::Ptr{Float64}, new_x::Cint, grad_f::Ptr{Float64}, user_data::Ptr{Void})
  println("eval_grad_f")
  # Return the gradient of the objective function at the point $ x$ .
  # n: (in), the number of variables in the problem (dimension of $ x$ ).
  # x: (in), the values for the primal variables, $ x$ , at which  $ \nabla f(x)$ is to be evaluated.
  # new_x: (in), false if any evaluation method was previously called with the same values in x, true otherwise.
  # grad_f: (out) the array of values for the gradient of the objective function ( $ \nabla f(x)$ ).
  
  x = pointer_to_array(x_ptr, (n*1,))

  unsafe_store!(grad_f, x[1] * x[4] + x[4] * (x[1] + x[2] + x[3]), 1)
  unsafe_store!(grad_f, x[1] * x[4], 2)
  unsafe_store!(grad_f, x[1] * x[4] + 1, 3)
  unsafe_store!(grad_f, x[1] * (x[1] + x[2] + x[3]), 4)
  
  return int32(1)
end

function eval_jac_g(n::Cint, x_ptr::Ptr{Float64}, new_x::Cint, m::Cint, nele_jac::Cint, iRow::Ptr{Cint}, jCol::Ptr{Cint}, values::Ptr{Float64}, user_data::Ptr{Void})
  println("eval_jac_g")
  println(nele_jac)
  # Return either the sparsity structure of the Jacobian of the constraints, or the values for the Jacobian of the constraints at the point $ x$ .
  # n: (in), the number of variables in the problem (dimension of $ x$ ).
  # x: (in), the values for the primal variables, $ x$ , at which the constraint Jacobian,  $ \nabla g(x)^T$ , is to be evaluated.
  # new_x: (in), false if any evaluation method was previously called with the same values in x, true otherwise.
  # m: (in), the number of constraints in the problem (dimension of $ g(x)$ ).
  # n_ele_jac: (in), the number of nonzero elements in the Jacobian (dimension of iRow, jCol, and values).
  # iRow: (out), the row indices of entries in the Jacobian of the constraints.
  # jCol: (out), the column indices of entries in the Jacobian of the constraints.
  # values: (out), the values of the entries in the Jacobian of the constraints.


  if values == C_NULL
    # return the structure of the Jacobian

    # this particular Jacobian is dense
    unsafe_store!(iRow, 0, 1)
    unsafe_store!(iRow, 0, 2)
    unsafe_store!(iRow, 0, 3)
    unsafe_store!(iRow, 0, 4)
    unsafe_store!(iRow, 1, 5)
    unsafe_store!(iRow, 1, 6)
    unsafe_store!(iRow, 1, 7)
    unsafe_store!(iRow, 1, 8)

    unsafe_store!(jCol, 0, 1)
    unsafe_store!(jCol, 1, 2)
    unsafe_store!(jCol, 2, 3)
    unsafe_store!(jCol, 3, 4)
    unsafe_store!(jCol, 0, 5)
    unsafe_store!(jCol, 1, 6)
    unsafe_store!(jCol, 2, 7)
    unsafe_store!(jCol, 3, 8)
  else
    x = pointer_to_array(x_ptr, int(n))
    # return the values of the Jacobian of the constraints
    unsafe_store!(values, x[2]*x[3]*x[4], 1) # 0,0
    unsafe_store!(values, x[1]*x[3]*x[4], 2) # 0,1
    unsafe_store!(values, x[1]*x[2]*x[4], 3) # 0,2
    unsafe_store!(values, x[1]*x[2]*x[3], 4) # 0,3

    unsafe_store!(values, 2*x[1], 5) # 1,0
    unsafe_store!(values, 2*x[2], 6) # 1,1
    unsafe_store!(values, 2*x[3], 7) # 1,2
    unsafe_store!(values, 2*x[4], 8) # 1,3
  end

  return int32(1)
end



function eval_h(n::Cint, x_ptr::Ptr{Float64}, new_x::Cint, obj_factor::Float64, m::Cint, lamda::Ptr{Float64}, new_lambda::Cint, nele_hess::Cint, iRow::Ptr{Cint}, jCol::Ptr{Cint}, values::Ptr{Float64}, user_data::Ptr{Void})
  println("eval h")
  # Do it later
  return int32(0)
end



n = 4
x_L = [1.0, 1.0, 1.0, 1.0]
x_U = [5.0, 5.0, 5.0, 5.0]

m = 2
g_L = [25.0, 40.0]
g_U = [2.0e19, 40.0]

prob = CreateProblem(n, x_L, x_U, m, g_L, g_U, 8, 10,
                     eval_f, eval_g, eval_grad_f, eval_jac_g, eval_h)

AddOption(prob, "hessian_approximation", "limited-memory")
prob.x = [1.0, 5.0, 5.0, 1.0]
SolveProblem(prob)

println(prob.x)
println(prob.obj_val)