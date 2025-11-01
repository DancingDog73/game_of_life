#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define DIM 32
#define SIZE 1024


__global__ void ksimulation(int *vec, int nb_sim){
    int idx = threadIdx.y*blockDim.y + threadIdx.x;
    int x = threadIdx.x;
    int y = threadIdx.y;
    for (int n = 0; n < nb_sim; n++){
        int somme = 0;
        for(int i=-1; i < 2; i++){
            for(int j=-1; j<2; j++){
                if(!(i == 0 && j==0)){
                    int neighbor_x = x+i;
                    int neighbor_y = y+j;
                    if((neighbor_x>=0 && neighbor_x<blockDim.x) && (neighbor_y>=0 && neighbor_y<blockDim.y)){
                        somme += vec[neighbor_y*blockDim.y + neighbor_x];
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
    __syncthreads();
        vec[idx] = next_value;
    __syncthreads();
    }
}

void fill_random(int *tab, int size){
    srand(time(NULL));
    for(int i = 0; i < size; i++){
        tab[i] = rand() % 2;
    }    
}

void simulation(int *vec, int *res, int nb_sim){
    int *d_vec;
    int bytes = SIZE * sizeof(int);
    dim3 bdim(DIM,DIM,1);

    cudaMalloc((void **) &d_vec, bytes);
    cudaMemcpy(d_vec, vec, bytes, cudaMemcpyHostToDevice);
    ksimulation<<<1, bdim>>>(d_vec, nb_sim);
    cudaMemcpy(res, d_vec, bytes, cudaMemcpyDeviceToHost);
    cudaFree(d_vec);

}


void four_o_center(int *tab, int size){
    for(int i = 0; i < size; i++){
        tab[i] = 1;
    }
    tab[15 * DIM + 15] = 0;
    tab[15 * DIM + 16] = 0;
    tab[16 * DIM + 15] = 0;
    tab[16 * DIM + 16] = 0;
}

void blinker(int *tab, int size){
    for(int i = 0; i < size; i++){
        tab[i] = 0;
    }
    //sup_gauche
    tab[1 * DIM + 1] = 1;
    tab[1 * DIM + 2] = 1;
    tab[1 * DIM + 3] = 1;

    //sup_droit
    tab[1 * DIM + 30] = 1;
    tab[1 * DIM + 29] = 1;
    tab[1 * DIM + 28] = 1;

    //inf_gauche
    tab[27 * DIM + 1] = 1;
    tab[28 * DIM + 1] = 1;
    tab[29 * DIM + 1] = 1;

    //inf_gauche
    tab[27 * DIM + 29] = 1;
    tab[28 * DIM + 29] = 1;
    tab[29 * DIM + 29] = 1;

    //l14
    tab[13 * DIM + 1] = 1;
    tab[13 * DIM + 2] = 1;
    tab[13 * DIM + 3] = 1;

    //l15
    tab[14 * DIM + 1] = 1;
    tab[14 * DIM + 2] = 1;
    tab[14 * DIM + 0] = 1;
    
}


int main(){
    int tab[SIZE];
    int res[SIZE];
    blinker(tab, SIZE);

    printf("AU DEBUT:\n");
    for (int i = 0; i < SIZE; i++) {
        printf("%d ", tab[i]);
        if((i+1)%32 == 0){
            printf("\n");
        }
    }

    simulation(tab, res, 1);    

    printf("A LA FIN:\n");
    for (int i = 0; i < SIZE; i++) {
        printf("%d ", res[i]);
        if((i+1)%32 == 0){
            printf("\n");
        }
    }

    return 0;
}