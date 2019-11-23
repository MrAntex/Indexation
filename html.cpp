//#!/bin/bash
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <bits/stdc++.h> 
#include <algorithm>
#include <cctype>


using namespace std;

class Convertir
{
public:
	char operator()(char c) const
	{
		return tolower(c);
	}
};



//sous programme compteur de ligne//
void cptligne(string argv)
{
    int nbLignes = 0;															//variable pour compter les lignes
    ifstream fichier(argv , ios::in);									//variable lien fichier
    string ligne;																//variable string pour pouvoir stocker la ligne
    while(getline(fichier, ligne))												//Boucle tant que qui s'arretera lors que ligne ne stockera plus
    {	
        nbLignes = nbLignes + 1;												//Compteur de ligne
    }
	fichier.close();															//fermeture du fichier
    //cout << "Le fichier contient " << nbLignes << " lignes" <<endl;				//annonce du nombre de ligne dans le fichier
}


//sous programme pour le sous programme occurence//
int nbr(string remot, string argv)
{
	ifstream fichier(argv, ios::in); 
	string mot;
	int compt = 0;
	while(fichier >> mot)
	{
		transform(mot.begin(), mot.end(), mot.begin(), Convertir());
		if(remot == mot)
		{
			compt = compt + 1;
		}	
	}
	fichier.close();
	return compt;
} 

//sous programme pour ligne//
void lignemot(string mot, string argv)
{
	ifstream fichier(argv, ios::in); 
	string ligne;
	int j = 0, c;
	vector<int> tabl;
	string n;
	while(getline(fichier, ligne))
	{
		transform(ligne.begin(), ligne.end(), ligne.begin(), Convertir());
		stringstream pmot(ligne);
		j = j + 1;
		while(pmot >> n)
		{
			if (n == mot)
			{
				tabl.push_back(j);	
			}
		}
	}
	fichier.close();
	c =	tabl.size();
    cout<<"<td>";
    /*if(c==1){
        cout<<tabl[0];
        cout<<"</td>";
        cout<<endl;
    }
    else {*/
	for(int k =0; k < c - 1; k++)
	{
		cout << tabl[k] << ", ";
	}
	cout<<tabl[c-1];
	cout<<"</td>";
    cout<<endl;
    
} 


//sous programme compteur occurence//
void occurence(string argv)		
{
	
    ifstream fichier(argv, ios::in); 
	vector<string> tabmot;
	vector<int> tabnbr;
	string mot;
	string stock;
	
	int c, i;
	bool t;
	if(fichier)
		{
		while(fichier >> mot)
		{
			transform(mot.begin(), mot.end(), mot.begin(), Convertir());
			c = tabmot.size();
			t = false;	
			for(i = 0 ; i < c; i++)
			{
				if(mot == tabmot[i])
				{
					t = true;
				}
			}
			if( t == false)
			{
				tabmot.push_back(mot);
				tabnbr.push_back(nbr(mot, argv));
			}
		}	
		
		fichier.close();
		c = tabmot.size();
		for(i = 0; i < c; i++)
		{
			stock = tabmot[i];
            cout<<"<tr>"<<endl;
			cout << "<td>" << tabmot[i] << "</td>" <<endl<< "<td>"<<tabnbr[i] << "</td>"<<endl;
			lignemot(stock, argv);
			cout <<endl<< "</tr>" ;
		}
	}	
	
	else
	{
		cout << "ERREUR: Impossible d'ouvrir le fichier." << endl;
	}
	
		
	
}

//programme pincipale//
int main(int argc, char *argv[])
{
  string adr = argv[1];
  
	//appelle des différent sous programmes//
  cptligne(adr);
	occurence(adr);
}

	
