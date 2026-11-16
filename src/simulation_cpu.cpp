#include <iostream>
#include <vector>
#include <random>
#include <algorithm>
#include <numeric>
#include <string>


void display(std::vector<int>& tab, int width){
    fprintf(stdout, "\033[2J");
    std::cout << "Nouvelle sim:\n";
    int w_count = 1;
    for(int a: tab){
        std::cout << a; 
        std::cout << " ";
        if(w_count%width == 0){
            std::cout << std::endl;
        }
        w_count++;
    }
    std::cout << "Appuyez sur une touche pour continuer\n";
    std::cin.ignore();
}

int alive_cell(std::vector<int>& tab, int size){
    return std::accumulate(tab.begin(), tab.end(), 1);
}

void fill_random(std::vector<int>& tab, int density){
    int nb_ones = static_cast<float>(tab.size()*density)/100.0;
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

void add_random_blinker(std::vector<int>& tab, int height, int width){
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


void add_random_glider(std::vector<int>& tab, int height, int width){
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


void simulation(int height, int width, int nb_simulations){
    int nb_elt = height * width;
    std::vector<int> grille_actuelle = std::vector(nb_elt, 0);
    std::vector<int> grille_future = std::vector(nb_elt, 0);

    fill_random(grille_actuelle, 10);
    //add_random_glider(grille_actuelle, height, width);

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