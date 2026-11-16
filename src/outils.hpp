#pragma once 
#include <iostream>
#include <vector>
#include <random>
#include <utility>
#include <numeric>
#include <string>

inline void display(int* tab, int height, int width){
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



inline int alive_cell(int *tab, int size){
    return std::accumulate(tab, tab+size, 1);
}

inline void fill_zero(int* tab, int size){
    for(int i=0; i < size; i++){
        tab[i]=0;
    }
}

inline void fill_random(int* tab, int size, int density){
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

inline void add_random_blinker(int* tab, int height, int width){
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


inline void add_random_glider(int* tab, int height, int width){
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


inline void display(std::vector<int>& tab, int width){
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

inline int alive_cell(std::vector<int>& tab, int size){
    return std::accumulate(tab.begin(), tab.end(), 1);
}

inline void fill_random(std::vector<int>& tab, int density){
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

inline void add_random_blinker(std::vector<int>& tab, int height, int width){
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


inline void add_random_glider(std::vector<int>& tab, int height, int width){
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
