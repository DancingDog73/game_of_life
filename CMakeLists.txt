cmake_minimum_required(VERSION 3.15)
project(GAME_OF_LIFE VERSION 1.0 LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(SIMULATION_CPU
    src/simulation_cpu.cpp
)


set(SIMULATION_CUDA
    src/simulation_cuda.cu
)

set(SIMULATION_BOTH
    src/simulation_both_mode.cu
)

add_executable(sim_cpu ${SIMULATION_CPU})
add_executable(sim_cuda ${SIMULATION_CUDA})
add_executable(sim_both ${SIMULATION_BOTH})


set_target_properties(sim_cuda PROPERTIES CUDA_RESOLVE_DEVICE_SYMBOLS ON)