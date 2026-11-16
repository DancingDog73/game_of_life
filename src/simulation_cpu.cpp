#include <iostream>
#include <vector>
#include <random>
#include <algorithm>
#include <numeric>
#include <string>
#include "outils.hpp"




void simulation(int height, int width, int nb_simulations){
    int nb_elt = height * width;
    std::vector<int> grille_actuelle = std::vector(nb_elt, 0);
    std::vector<int> grille_future = std::vector(nb_elt, 0);

    //fill_random(grille_actuelle, 10);
    add_random_glider(grille_actuelle, height, width);

    display(grille_actuelle, width);

    for(int n=0; n<nb_simulations; n++){
        
        for(int i = 0; i < nb_elt; i++){
            int somme = 0; 
            int y = i/width;
            int x = i%width;

            for(int j=-1; j < 2; j++){
                for(int k=-1; k < 2; k++){
                    if(!(j == 0 && k==0)){
                        int neighbor_x = (x+k+width)%width;
                        int neighbor_y = (y+j+height)%height;
                        if((neighbor_x>=0 && neighbor_x<width) && (neighbor_y>=0 && neighbor_y<height)){
                            somme += grille_actuelle[neighbor_y*width + neighbor_x];
                        }
                    }
                }
            }

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
        
        display(grille_actuelle, width);
    }

    
    
}

int main(int argc, char* argv[]){

    if(argc < 4){
        std::cerr << "Usage " << argv[0] << " <height> <width> <number_of_simulation>\n";
    }

    int height = std::stoi(argv[1]);
    int width = std::stoi(argv[2]);
    int nb_sim = std::stoi(argv[3]);
    simulation(height, width, nb_sim);

    
}