#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>
#include <string>
#include <utility>
#include <random>
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>

#define cudaCheckError(call)                                                       \
    do {                                                                       \
        cudaError_t err = (call);                                              \
        if (err != cudaSuccess) {                                              \
            fprintf(stderr, "CUDA Error at %s:%d — %s: %s\n",                  \
                    __FILE__, __LINE__, #call, cudaGetErrorString(err));       \
            exit(EXIT_FAILURE);                                                \
        }                                                                      \
    } while (0)






void display(int* tab, int height, int width){
    fprintf(stdout, "\033[2J");
    std::cout << "Nouvelle sim:\n";
    int w_count = 1;
    for(int i=0; i < height*width; i++){
        std::cout << tab[i]; 
        std::cout << " ";
        if(w_count%width == 0){
            std::cout << std::endl;
        }
        w_count++;
    }
    std::cout << "Appuyez sur une touche pour continuer\n";
    std::cin.ignore();
}

__global__ void ksimulation(int *vec, int* d_res, int nb_sim){
    int x = threadIdx.x;
    int y = threadIdx.y;
    int idx = y * blockDim.x + x;
    
    int somme = 0;
    for(int i=-1; i < 2; i++){
        for(int j=-1; j<2; j++){
            if(!(i == 0 && j==0)){
                int neighbor_x = (x+i+blockDim.x)%blockDim.x;
                int neighbor_y = (y+j+blockDim.y)%blockDim.y;
                if((neighbor_x>=0 && neighbor_x<blockDim.x) && (neighbor_y>=0 && neighbor_y<blockDim.y)){
                    somme += vec[neighbor_y*blockDim.x + neighbor_x];
                }
            }
        }
    }
    int next_value;
    if(vec[idx] == 1 && (somme == 2 || somme == 3)){
        next_value = 1;
    }
    else if(vec[idx] == 0  && somme == 3 ){
        next_value = 1;
    } else {
        next_value = 0;
    }
    d_res[idx] = next_value;
    
}

void fill_zero(int* tab, int size){
    for(int i=0; i < size; i++){
        tab[i]=0;
    }
}

void fill_random(int* tab, int size, int density){
    int nb_ones = static_cast<float>(size*density)/100.0;
    if(nb_ones > size){nb_ones = size;}

    std::random_device rd;
    std::mt19937 gen(rd());
    
    int ones_placed = 0;
    while(ones_placed < nb_ones){
        std::uniform_int_distribution<> distr(0, size - 1);
        int r = distr(gen);

        if (tab[r] == 0) {
            tab[r] = 1;
            ones_placed++;
        }
    }

    
}

void add_random_blinker(int* tab, int height, int width){
     if(height < 3 || width < 3){
        return;
    }
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> distr(0, height - 3);
    int l = distr(gen);
    std::uniform_int_distribution<> distr1(1, width - 2);
    int w = distr1(gen);


    tab[l * width + (w)] = 1;
    tab[(l+1) * width + (w)] = 1;
    tab[(l+2) * width + (w)] = 1;


}


void add_random_glider(int* tab, int height, int width){
    if(height < 3 || width < 3){
        return;
    }
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> distr(0, height - 3);
    int l = distr(gen);
    std::uniform_int_distribution<> distr1(1, width - 2);
    int w = distr1(gen);
    
    tab[l * width + (w)] = 1;
    
    
    tab[(l+1)* width + (w+1)] = 1;
    tab[(l+2)* width + (w-1)] = 1;
    tab[(l+2)* width + (w)] = 1;
    tab[(l+2)* width + (w+1)] = 1;
}



void fill_random(int *tab, int size){
    srand(time(NULL));
    for(int i = 0; i < size; i++){
        tab[i] = rand() % 2;
    }    
}

void simulation(int height, int width, int nb_sim){
    int size  = height*width;
    int* vec = new int[height * width];
    int* res = new int[height * width];
    int *d_vec;
    int *d_res;
    int bytes = size * sizeof(int);
    dim3 bdim(width, height,1);

    fill_zero(vec, size);
    add_random_glider(vec, height, width);

    cudaCheckError(cudaMalloc((void **) &d_vec, bytes));
    cudaCheckError(cudaMalloc((void **) &d_res, bytes));
    cudaCheckError(cudaMemcpy(d_vec, vec, bytes, cudaMemcpyHostToDevice));
    for(int i=0; i < nb_sim; i++){
        
        ksimulation<<<1, bdim>>>(d_vec, d_res, nb_sim);
        cudaCheckError(cudaMemcpy(res, d_res, bytes, cudaMemcpyDeviceToHost));
        std::swap(d_vec, d_res);
        display(res, height, width);

    }
    
    delete[] vec;
    delete[] res;
    cudaCheckError(cudaFree(d_vec));
    cudaCheckError(cudaFree(d_res));

}




int main(int argc, char* argv[]){
    

    if(argc < 4){
        std::cerr << "Usage " << argv[0] << " <height> <width> <number_of_simulation>\n";
        return 1;
    }


    int height = std::stoi(argv[1]);
    int width = std::stoi(argv[2]);
    int nb_sim = std::stoi(argv[3]);
    simulation(height, width, nb_sim);    

   

    return 0;
}