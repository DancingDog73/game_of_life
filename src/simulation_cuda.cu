#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define DIM 32
#define SIZE 1024


__device__ void display(int *vec, int it){
    printf("\033[H\033[J");
    printf("GRILLE A LA FIN DE  L'ITERATION NUMERO %d\n", it+1);
    for (int i = 0; i < SIZE; i++) {
        printf("%d ", vec[i]);
        if((i+1)%32 == 0){
            printf("\n");
        }
    }
}

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
        if(idx == 0){
            printf("GRILLE A LA FIN DE  L'ITERATION NUMERO %d\n", n+1);
            for (int i = 0; i < SIZE; i++) {
                printf("%d ", vec[i]);
                if((i+1)%32 == 0){
                    printf("\n");
                }
            }
        }
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


void cover_center(int *tab, int n){
    tab[15 * DIM + 15] = n;
    tab[15 * DIM + 16] = n;
    tab[16 * DIM + 15] = n;
    tab[16 * DIM + 16] = n;
}

void fill(int *tab, int size, int n){
    for(int i = 0; i < size; i++){
        tab[i] = n;
    }
}

void center_toads(int *tab){
     //l14
    tab[15 * DIM + 1] = 1;
    tab[15 * DIM + 2] = 1;
    tab[15 * DIM + 3] = 1;

    //l15
    tab[16 * DIM + 1] = 1;
    tab[16 * DIM + 2] = 1;
    tab[16 * DIM + 0] = 1;

     //l14
    tab[15 * DIM + 29] = 1;
    tab[15 * DIM + 30] = 1;
    tab[15 * DIM + 28] = 1;
    //l16
    tab[16 * DIM + 29] = 1;
    tab[16 * DIM + 28] = 1;
    tab[16 * DIM + 27] = 1;


}

void four_o_center(int *tab, int size){
    fill(tab, size, 1);
    cover_center(tab, 0);
}

void blinker(int *tab, int size){
    fill(tab, size, 0);
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

    center_toads(tab);
    
}


void glider(int *tab, int size){
    fill(tab, size, 0);
    //sup_gauche
    tab[0 * DIM + 1] = 1;
    tab[1 * DIM + 2] = 1;
    tab[2 * DIM + 2] = 1;
    tab[2 * DIM + 1] = 1;
    tab[2 * DIM + 0] = 1;

    //sup_droit
    tab[0 * DIM + 30] = 1;
    tab[1 * DIM + 29] = 1;
    tab[2 * DIM + 30] = 1;
    tab[2 * DIM + 29] = 1;
    tab[2 * DIM + 31] = 1;

    //inf gauche
    tab[28 * DIM + 1] = 1;
    tab[28 * DIM + 2] = 1;
    tab[28 * DIM + 3] = 1;
    tab[28 * DIM + 4] = 1;
    tab[29 * DIM + 0] = 1;
    tab[29 * DIM + 4] = 1;
    tab[30 * DIM + 4] = 1;
    tab[31 * DIM + 0] = 1;
    tab[31 * DIM + 3] = 1;

    //inf_droit
    tab[28 * DIM + 31] = 1;
    tab[28 * DIM + 30] = 1;
    tab[28 * DIM + 29] = 1;
    tab[28 * DIM + 28] = 1;
    tab[29 * DIM + 31] = 1;
    tab[29 * DIM + 27] = 1;
    tab[30 * DIM + 31] = 1;
    tab[31 * DIM + 30] = 1;
    tab[31 * DIM + 27] = 1;

}

void mixed(int *tab, int size){
    glider(tab, size);
    cover_center(tab, 1);
    center_toads(tab);

}


int main(){
    int tab[SIZE];
    int res[SIZE];
    mixed(tab, SIZE);

    printf("AU DEBUT:\n");
    for (int i = 0; i < SIZE; i++) {
        printf("%d ", tab[i]);
        if((i+1)%32 == 0){
            printf("\n");
        }
    }

    simulation(tab, res, 20);    

   

    return 0;
}