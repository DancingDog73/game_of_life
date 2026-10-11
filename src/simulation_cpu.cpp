#include <iostream>
#include <vector>
#include <random>
#include <algorithm>
#include <numeric>


void affichage(std::vector<int>& tab, int length, int width){
    std::cout << "Nouvelle sim:\n";
    for(int i = 0; i < length; i++){
        for(int j = 0; j < width; j++){
            std::cout << (tab[i+j] & 1) << " ";
        }
        std::cout << std::endl;
    }
}

void fill_random(std::vector<int>& tab, int nb_ones){

    if(nb_ones > tab.size()){nb_ones = tab.size();}

    std::random_device rd;
    std::mt19937 gen(rd());
    
    int ones_placed = 0;
    while(ones_placed < nb_ones){
        std::uniform_int_distribution<> distr(0, tab.size() - 1);
        int r = distr(gen);

        if (tab[r] == 0) {
            tab[r] = 1;
            ones_placed++;
        }
    }

    
}


void simulation(int length, int width, int nb_simulations){
    int nb_elt = length * width;
    std::vector<int> tab = std::vector (nb_elt, 0);

    fill_random(tab, 512);

    affichage(tab, length, width);

    for(int n=0; n<nb_simulations; n++){
        
        for(int i = 0; i < nb_elt; i++){
            int somme = 0; 
            int y = i/width;
            int x = i%width;

            for(int j=-1; j < 2; j++){
                for(int k=-1; k < 2; k++){
                    if(!(j == 0 && k==0)){
                        int neighbor_x = x+j;
                        int neighbor_y = y+k;
                        if((neighbor_x>=0 && neighbor_x<width) && (neighbor_y>=0 && neighbor_y<length)){
                            somme += (tab[neighbor_y*width + neighbor_x] &1);
                        }
                    }
                }
            }

            int next_value;
            if(tab[i] == 1 && (somme == 2 || somme == 3)){
                next_value = 1;
            }
            else if(tab[i] == 0  && somme == 3 ){
                next_value = 1;
            } else {
                next_value = 0;
            }
            if(next_value == 1){
                tab[i] |= 2;
            }
            
        }

        for(int i = 0; i < nb_elt; i++){
            tab[i] >>= 1;
        }
        
        affichage(tab, length, width);
    }

    
    
}

int main(){
    simulation(32, 32, 3);
}