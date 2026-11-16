#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>
#include <string>
#include <utility>





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

    cudaMalloc((void **) &d_vec, bytes);
    cudaMalloc((void **) &d_res, bytes);
    cudaMemcpy(d_vec, vec, bytes, cudaMemcpyHostToDevice);
    for(int i=0; i < nb_sim; i++){
        
        ksimulation<<<1, bdim>>>(d_vec, d_res, nb_sim);
        cudaMemcpy(res, d_res, bytes, cudaMemcpyDeviceToHost);
        std::swap(d_vec, d_res);
        display(res, height, width);

    }
    
    delete[] vec;
    delete[] res;
    cudaFree(d_vec);
    cudaFree(d_res);

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