#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <bits/stdc++.h> 
#include <algorithm>
#include <cctype>


using namespace std;


//classe permettant de convertir un sting pour qu'il soit en minuscule//
class Convertir
{
public:
	char operator()(char c) const
	{
		return tolower(c);
	}
};

//procédure qui retire toute les ponctuations et convertie tout en minuscule//
void Clean( std::string & mot) 
{  
	//Variables//
	char table[19] = {'.', ';', ':', '!', ',', '?', '/','$','*','+','-','&','>','#',')','(','_','%','='};				
	
	
																		//Remplace chaque ponctuation contenu dans le tableau par un ' ' (espace)//
	for(int i = 0; i < 19; i++)
	{
		std::replace( mot.begin(), mot.end(), table[i], ' '	);
	}
																		//Convertie un string en minuscule grace à la clase Convertir//
	transform(mot.begin(), mot.end(), mot.begin(), Convertir());
}
 

//fonction permettant de savoir combien de fois apparraise les mots dans le fichier//
int nbr(string remot, string adresse)
{
	//Variables//
	ifstream fichier(adresse, ios::in); 
	string mot;
	int compt = 0;
	
	while(fichier >> mot)												//Le fichier est lu mot par mot stockage dans un string//
	{
		Clean(mot);														//Appelle de la procédure Clean//
																		//Condition permettant de si on croise le mot de rajouter à son compteur + 1//
		if(remot == mot)
		{
			compt = compt + 1;
		}	
	}
	fichier.close();													//Fermeture du fichier//
	return compt;														//Renvoie du nombre de fois que le mot apparait dan le fichier//
} 

//procédure permettant de stocker les lignes correspondant au mot et de les afficher//
void lignemot(string mot, string adresse)
{
	//Variables//
	ifstream fichier(adresse, ios::in); 
	string ligne;
	int j = 0, c;
	vector<int> tabl;
	string n;
	
	while(getline(fichier, ligne))										//Tant que permettant de lire ligne par ligne le fichier et de stocker la ligne dans un string//
	{
		stringstream pmot(ligne);										//conversion du string ligne en flux, se qui va permettre de lire la ligne mot par mot//
		j = j + 1;														//Compteur permettant de savoir dans quelle ligne on est situé//
		
		while(pmot >> n)												//permet de lire un flux mot par mot//
		{
			Clean(mot);													//Appelle de la procédure Clean//
																		//Condition qui permet si le mot est croiser de stocker la ligne dans laquelle est croiser le mot//
			if (n == mot)
			{
				tabl.push_back(j);										//Ajout d'une case avec j le compteur dans cette case//
			}
		}
	}
	
	fichier.close();													//Fermeture du fichier//
	c =	tabl.size();													//c prend la taille du tableau//
	
	//Affichage//
	for(int k =0; k < c; k++)
	{
		cout << tabl[k] << " ";
	}
} 


//procédure compteur occurence//
void occurence(string adresse)		
{
	//Variables//
    ifstream fichier(adresse, ios::in);
	vector<string> tabmot;
	vector<int> tabnbr;
	string mot;
	string ligne;
	string stock;
	int c, i;
	bool t;
	
	
	if(fichier)															//Verification de fichier si il n'existe pas renvoie une erreure//
	{
			
		while(getline(fichier, ligne)) 									//Tant que permettant de lire ligne par ligne le fichier et de stocker la ligne dans un string//
		{
			Clean(ligne);												//Appelle de la procédure Clean//
			stringstream lignes(ligne); 								//conversion du string ligne en flux, se qui va permettre de lire la ligne mot par mot//
			while(lignes >> mot)										//permet de lire un flux mot par mot//
			{
				c = tabmot.size();										//c prend la taille du tableau//
				t = false;				
																		//Boucle permettant à chaque mot d'être stocker selon si il y est déjà ou non//
				for(i = 0 ; i < c; i++)
				{
					if(mot == tabmot[i])
					{
						t = true;
					}
				}
																		//Si t == false se qui veut dire si le mot n'est pas dans le tableau vector, alors il ajoute une case au vector et il y rajoute le mot//
				if( t == false)
				{
					tabmot.push_back(mot);
					tabnbr.push_back(nbr(mot, adresse));				//Stockage dans un tableau de vector int des valeurs de la fonction nbr// 
				}
			}
		}
		
																		
		fichier.close();												//fermeture du fichier//
		c = tabmot.size();  											//c prend la taille du tableau//
		//Affichage des différentes parties// 
		for(i = 0; i < c; i++)
		{
			stock = tabmot[i];
			cout << tabmot[i] << " " << tabnbr[i] << " ";
			lignemot(stock, adresse);
			cout << endl ;
		}
	}	
	
	//Renvoie "erreur" si aucun fichier// 
	else
	{
		cout << "ERREUR: Impossible d'ouvrir le fichier." << endl;
	}
	
		
	
}


int main(int argc, char *argv[])										//Appelle de l'adresse dans argv[1]//
{
	string adresse = argv[1];												//Convertion du tableau de char en string//
	
	//appelle des différent sous programmes//
    
	occurence(adresse);
}

	
