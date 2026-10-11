#include <iostream>
#include <vector>
#include <random>
#include <algorithm>
#include <numeric>


void affichage(std::vector<int>& tab, int length, int width){
    std::cout << "Nouvelle sim:\n";
    for(int i = 0; i < length; i++){
        for(int j = 0; j < width; j++){
            std::cout << tab[i+j]  << " ";
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
    std::vector<int> grille_actuelle = std::vector(nb_elt, 0);
    std::vector<int> grille_future = std::vector(nb_elt, 0);

    fill_random(grille_actuelle, 512);

    affichage(grille_actuelle, length, width);

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
                            somme += grille_actuelle[neighbor_y*width + neighbor_x];
                        }
                    }
                }
            }

            int next_value;
            if(grille_actuelle[i] == 1 && (somme == 2 || somme == 3)){
                grille_future[i] = 1;
            }
            else if(grille_actuelle[i] == 0  && somme == 3 ){
                grille_future[i] = 1;
            } else {
                grille_future[i] = 0;
            }
            
        }

        std::swap(grille_actuelle, grille_future);
        
        affichage(grille_actuelle, length, width);
    }

    
    
}

int main(){
    simulation(32, 32, 3);
}