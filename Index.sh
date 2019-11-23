#!/bin/bash
liste=liste_default
# stockage du nom du fichier contenant le fichier d'indexation

echo "1"
reprinc=$(readlink -f $(dirname "$0")) #chemin absolu du repertoire ou se trouve le script principal
chemin=$reprinc/$(basename "$0") #adresse du script

chemin="${chemin// /\\ }"
#chemin="${chemin//&/\\&}"

echo $(echo "$chemin" | od -c)
#  Stockage de variables pour pouvoir modifier le script facilement si nécessaire #
nb_param=$#
o=.o
execlass=listing.exe
cppclass=listing.cpp
cpphtml=html.cpp
exehtml=html.exe
fichtml=newIndex.html
###########################


choix="Q" #assignation d'une valeur par défaut

confirmation="K" #idem


echo "2"

ici=$(pwd) #stockage du chemin ou le script est lancé (comme il se relance lui-même dans les différents sous-répertoires)


###########################################
#     Fonction de vérification du md5     #
###########################################


verifmd5() 
{ local liste=$1 #stockage du chemin du fichier d'indexation
local fich=$2 #stockage du nom du fichier à vérifier
local md5=$3 #stockage de l'adresse md5 du fichier
local parcours=$4 #stockage du chemin du fichier
echo "VERIF"
liste="${liste//;/\ }"

fich="${fich//;/\ }"

parcours="${parcours//;/\ }"

local supp=0
#echo "grep : fich=$fich , parcours=$parcours , liste=$liste"
#echo "$fich\*.*\*$parcours --- $liste"
local lignefound=$(grep -an \'$parcours\*.*\*$fich\' $liste | cut -d':' -f1) #Recherche d'un numéro de ligne correspondant au fichier et au chemin recherché

	if [ "$lignefound" = "" ] #si il n'y à pas de ligne qui correspond, c'est un nouveau fichier
		then
if [ $# -ne 5 ]
then		
echo -e "  \033[32;1m>\033[0m Nouveau fichier indexé : $fich dans $liste" #on l'affiche dans la console
		 echo "$fich*$md5*$parcours*" >> "$liste" #on rentre son nom, son adresse md5 et son chemin dans le fichier d'indexation, séparés par des '*' pour pouvoir manipuler des noms de dossiers/fichiers comportant des espaces, car c'est un caractère qu'on ne peut utiliser dans un nom de dossier ou fichier
			"$reprinc"/"$execlass" "$fich" >> "$liste" #on lance le script C++ pour analyser le contenu du fichier
			
			echo "" >> "$liste"		#on saute une ligne 
fi
		else #si le fichier existe déja
		local lignecompl=$(head -$lignefound $liste | tail -1) #On récupère le contenu complet de la ligne trouvée avec son numéro
		local mdtruc=$(echo $lignecompl | cut -d"*" -f2) #On récupère l'adresse md5 qui se trouve sur cette ligne
		
			if [ "$mdtruc" = "$md5" ] #Si l'adresse trouvé correspond à l'adresse donnée en paramètre, alors le fichier est à jour.
				then

				echo -e "  \033[36;1m>\033[0m Fichier inchangé : $fich"	#le md5 est le meme on ne fait rien
                		else
			if [ $# -ne 5 ] #Si le fichier est un fichier texte
			then

				echo -e "  \033[32;1m>\033[0m Fichier actualisé : $fich" #On écrit que le fichier est actualisé dans la console
                    while [ "$lignecompl" != "" ]	#tant qu'on est pas sur une ligne vide
                    do

                    sed -i "$lignefound"d $liste	#on supprime la ligne 
 		
                    lignecompl=$(head -$lignefound $liste | tail -1) #Et on prend la ligne qui se trouve sur le même numéro

                    done
		
												

		let "supp=$lignefound - 1"		#on suprime la ligne vide en trop
			echo "liste : $liste"
                    sed -i "$supp"d $liste
			
                  echo "$fich*$md5*$parcours*" >> "$liste" #a la fin de la liste on affiche lenom du fichier, le nouveau md5,et le parcours
           	
		 "$reprinc"/"$execlass" "$fich" >> "$liste"	#on execute le C++ et on affiche le résultat en fin de liste
		
		else #Si le fichier n'est pas un document texte, on fait tout le reste sans l'analyse
		sed -i "$lignefound"d $liste
		let "supp=$lignefound - 1"
		sed -i "$supp d" $liste

		echo "$fich*$md5*$parcours*" >> "$liste"
		echo "" >> "$liste"

				fi
			fi
		fi
}





#############################
#     Fonction search()     #
#############################


search()
{ local nb_par=$# #On stocke le nombre de paramètres
echo "SEARCH"
	liste=$1 #On stocke le chemin du fichier d'indexation
	paramet=$(echo -e $@ | sed "s/^[^ ]* //g") #On récupère la liste des mots entrés en paramètres

	echo -e "
\033[36;1m - - - - - - - ->\033[0m S E A R C H \033[36;1m<- - - - - - - -\033[0m"
for mot in $paramet #Pour chaque mot en paramètre
do
echo -e "\n  \033[36;1m>\033[0m Recherche du mot \033[4;1m$mot\033[0m \033[36;1m<\033[0m \n"
mot=$(echo $mot | tr  '[[:upper:]]' '[[:lower:]]')	#les majuscules devienne minuscule


truc=$(echo `grep -i -n $mot' '  $liste`)		#truc prend les ligne, avec leur numéro, qui contienne le mot sous cette forme:  ligne:mot nombre ligne ligne 

cond=1							#on initialise cond a 1, cond sert plus tard a savoir si on rentre dans une boucle

for i in $truc
do
		
	if  [[ "$i" = *:$mot ]]			#test si i contient le mot
	then
	ligne=$i					#si test vrai, ligne prend la ligne , deux point, et le mot
	
	ligne=$(echo $ligne | cut -d: -f1)		#ligne prend le numero de ligne du mot

	marche=$(head -$ligne $liste | tail -1)		#marche prend tout la ligne du numero correspondant a ligne, soit celle ou se trouve le mot

	cond=2						#cond prend 2, ce qui permet de rentrer dans la boucle


		while [  $cond -eq 2 ]; 			
		do

			let "ligne=$ligne - 1"			#ligne prend le numero de ligne du dessus

			test=$(head -$ligne $liste | tail -1)	#test prend toute la ligne de numero de ligne

			if [ "$test" = "" ] 			#test si la ligne est vide
			then
				cond=3				#cond prend 3, ce qui permet de sortir de la boucle
			fi
	   
	 
		done
	let "ligne=$ligne + 1"				#ligne prend la ligne du dessous, soit la premiere ligne du paragraphe, qui contient le nom du fichier ect
	test=$(head -$ligne $liste | tail -1)		#test prend la toute la ligne du numero de ligne
	if [ "$test" = "$marche" ]			#si la premiere ligne est celle ou se trouve le mot
	then 
		echo -e "  \033[31;1m>\033[0m Ce mot est le nom d'un fichier."	#on indique que le mot est celui du fichier
	else
		
		fichiertr=$(echo $test| cut -d'*' -f1)	#test ne prend que le nom du fichier et son parcours
		chemtr=$(echo $test| cut -d'*' -f3)

		echo -e "  \033[36;1m>\033[0m Mot trouvé dans : $fichiertr ( $chemtr )"			#on affiche le nom et le parcour du fichier
		mottr=$(echo $marche | cut -d' ' -f1)
		occ=$(echo $marche | cut -d' ' -f2)
		lignas=$(echo -e $marche | sed "s/^[^ ]* //g")
		lignees=$(echo -e $lignas | sed "s/^[^ ]* //g" | tr " " ",")
		echo -e "    \033[32;1m>\033[0m Trouvé $mottr : \n    \033[32;1m>\033[0m Occurences : $occ \n    \033[32;1m>\033[0m Ligne(s) : $lignees\n"				#on affiche le mot, le nombre de fois ou il apparait et a quelle ligne

	fi
	
	fi


done

if [ "$cond" = "1" ]					#si cond=1, c'est qu'on est pas rentré dans la boucle donc le mot n'est pas répertorié
then
	echo -e "  \033[31;1m>\033[0m Ce mot n'est pas repertorié.
"		#on l'affiche
fi
echo -e " - - - - - - - - - - - - - - - - - - - - - - -"
done
}

#################################
#     Listages des fichiers     #
#  présents dans le repertoire  #
#################################

affliste()
{
local liste=$(ls) #On récupère la liste des fichiers présents dans le dossier du script
local cpt=1
echo "AFFLISTE"
for f in $liste #Pour chaque fichier
do
local typefic=$(file -b $f) #On récupère son "type"
	if [ "$typefic" = "UTF-8 Unicode text" ] || [ "$typefic" = "ASCII text" ] && [ "$f" != "makefile" ] #Si c'est un fichier texte et que ce n'est pas le makefile
	then
	echo -e "    \033[32;1m>\033[0m $f" #On l'affiche
	fi
done

}

#################################
#      La procédure festive     #
#################################

nowel() 
{ #Joyeux noël et bonne année ! (Oui ça nous à pris énormement (trop?) de temps, mais ça le vaut non ?)
echo -e "
                                \033[33;1m|\033[0m 
                               \033[36;1m-\033[33;1;5m*\033[0m\033[36;1m-
                               \033[36;1m'\033[33;1m|\033[36;1m'        
                               \033[32;1m*\033[33;1m:\033[32;1m*        
                              \033[32;1m* \033[37;1m.\033[0m \033[32;1m*      
                             \033[32;1m**   \033[32;1m**   
                           \033[32;1m*** \033[31;1mo   \033[32;1m***    
                            \033[32;1m*\033[36;1;5m\\\\\033[0m    \033[31;1mO \033[32;1m*            
                           \033[32;1m** \033[36;1;5m\\\ \033[0m   \033[32;1m**            
                         \033[32;1m***    \033[36;1;5m\\\  \033[0m \033[32;1m***        
                          \033[32;1m* \033[37;1mo     \033[36;1;5m\\\ \033[0m \033[32;1m*        
                         \033[32;1m**    \033[37;1mO    \033[36;1;5m\\\\\033[0m\033[32;1m**      
                       \033[32;1m***\033[36;1;5m\\\ \033[0m      \033[31;1mo  \033[36;1;5m\\\\\\033[0m\033[32;1m***     
                        \033[32;1m*   \033[36;1;5m\\\ \033[0m \033[31;1mo    \033[0m   \033[32;1m*       
                       \033[32;1m**  \033[31;1mo  \033[36;1;5m\\\ \033[0m   \033[37;1mO   \033[32;1m**       
                    \033[32;1m****        \033[36;1;5m\\\ \033[0m \033[37;1m   o \033[32;1m****      
                      \033[32;1m** \033[37;1mo     o  \033[36;1;5m\\\\\033[0m \033[31;1mo   \033[32;1m**          
                    \033[32;1m***     \033[31;1mO       \033[36;1;5m\\\ \033[0m   \033[32;1m***
                  \033[32;1m*****************************
                              \033[33;1m#####         
                              \033[33;1m##### 
                              \033[33;1m#####\033[0m     "
echo -e "\033[34;1m
   __                                          __      _            
   \\ \\  ___  _   _  ___ _   _ ___  ___  ___   / _| ___| |_ ___  ___ 
    \\ \\/ _ \\| | | |/ _ \\ | | / __|/ _ \\/ __| | |_ / _ \\ __/ _ \\/ __|
 /\\_/ / (_) | |_| |  __/ |_| \\__ \\  __/\\__ \\ |  _|  __/ ||  __/\\__ \\
 \\___/ \\___/ \\__, |\\___|\\__,_|___/\\___||___/ |_|  \\___|\\__\\___||___/
             |___\\/                                                  


"
}


###########################
#     Début du script     #
###########################


if ([ $nb_param -ne 2 ] && [ "$ici" = "$reprinc" ] && [ $1 != "--clean" ] && [ $1 != "--noel" ] && [ $1 != "--help" ]) && [ "$1" != "--search" ]  #Si le nombre de paramètres en entrée n'est pas 2 ET si le script est lancé dans son répertoire de base (= c'est l'utilisateur qui l'a lancé et non le script lui-même) ET le premier paramètre n'est pas l'option --clean
	then
		
		echo -e "
  \033[31;1m>\033[31;1m Commande erronée :/ . Usage : \033[0m
       $0 [--index|--indexhtml|--search|--clean|--noel] [fichier à indexer|mot(s) à rechercher]
"
		
		exit 1
fi
	if [ "$1" = "--index" ] || [ "$1" = "--indexhtml" ] # Si le premier paramètre est "--index"
	then
	
		if ! test -e "$2"
			then
echo "Doss : $2"
			echo -e "  \033[31;1m>\033[0m Le dossier que vous tentez d'indexer n'existe pas. Veuillez entrer un dossier valide."
			exit 1
			fi
if [ $nb_param -eq 4 ] # Si le script lancé est un script cloné 
	then
	
	chemin="${chemin//;/\\ }"
	liste=$4 # Si le script lancé est un clone alors le fichier à utiliser comme fichier d'indexation est le 4eme paramètre.
    nbcarep=$3
fi
	
	
if [ $nb_param -eq 2 ] # Si au contraire c'est un script "original" lancé par l'utilisateur
	
    then
	rep=$(readlink -f "$(dirname "$2")") #chemin absolu du repertoire ou se trouve le script principal
		nbcarep=${#rep}
    	echo -e "\033[36;1m - - - - - - - ->\033[0m I N D E X \033[36;1m<- - - - - - - -\033[0m

      \033[36;1m>\033[0m Check up... \033[36;1m<\033[0m
"
	if [ "$1" = "--indexhtml" ]
	then
		echo -e "  \033[36;1m>\033[0m Création du nouveau fichier html..."
		cp "$reprinc"/HTML/index.html "$reprinc"/HTML/$fichtml
		echo -e "  \033[32;1m>\033[0m Fichier html crée avec succès
"
	fi

	echo -e "  \033[36;1m>\033[0m Mise à jour des éxecutables."
    make listing.exe html.exe
    echo -e "  \033[36;1m>\033[0m Éxécutables correctement mis à jour.
    "
	echo -e "  \033[36;1m>\033[0m Vérification des permissions."
        permclass=$(echo `ls -l "$execlass"` | cut -d" " -f1)
        permhtml=$(echo `ls -l "$exehtml"` | cut -d" " -f1)
        
        if [ "$permclass" != "-rwxr-xr-x" ] || [ "$permhtml" != "-rwxr-xr-x" ]
        then
        echo -e "  \033[31;1m>\033[0m Vous ne disposez pas des droits nécéssaires à l'indexation des \n fichiers, le script va les modifier en conséquence. \n Le script va ensuite se relancer, si cela ne fonctionne toujours pas \n ou si vous voyez ce message à nouveau, veuillez \n modifier ces permissions manuellement."

        echo -e "  \033[33;1;5m>\033[0m Appuyez sur Entrée pour continuer... \033[33;1;5m<\033[0m"
        read confirmation
        echo -e "  \033[36;1m>\033[0m Application des modifications de permissions pour l'indexation classique ($execlass)..."
        chmod 755 $execlass
        echo -e "  \033[32;1m>\033[0m Permissions modifiées pour l'indexation classique avec succès."
        echo -e "  \033[36;1m>\033[0m Application des modifications de permissions pour l'indexation html ($exehtml)..."
        chmod 755 $exehtml
        echo -e "  \033[32;1m>\033[0m Permissions modifiées pour l'indexation html avec succès."
        echo -e "  \033[36;1m>\033[0m Relancement du script en cours..."
        bash "$chemin" "$1" "$2"
        fi
        
        if ! test -e "$liste" # Si le fichier d'indexation (= la "liste" des contenus des fichiers) n'existe pas
        then
        echo -e "  \033[31;1m>\033[0m Le fichier d'indexation n'existe pas. \n  \033[36;1m>\033[0m Souhaitez-vous que le script en crée un automatiquement ou préférez-vous en sélectionner un existant ? \033[36;1m<\033[0m

    \033[33;5;1m>\033[0m (C) - Création automatique
    \033[33;5;1m>\033[0m (S) - Sélection manuelle
" # Soit on crée un fichier d'indexation (liste_default), soit il utilise un fichier texte existant.
        until [ "$choix" = "S" ] || [ "$choix" = "s" ] || [ "$choix" = "c" ] || [ "$choix" = "C" ]
        do
        read -p $(echo -e "\033[33;5;1m>>\033[0m ") choix
        if [ "$choix" != "S" ] && [ "$choix" != "s" ] && [ "$choix" != "c" ] && [ "$choix" != "C" ]
            then
                        echo -e "  \033[31;1m>\033[0m Veuillez entrer un caractère valide."
                        fi
        done
            if [ "$choix" = "C" ] || [ "$choix" = "c" ]
                then
                > liste_default # On crée un fichier "liste_default"
                liste=liste_default #On déclare que le fichier à utilsier comme liste est celui ci.
                
                sed -i '2s/.*/liste=liste_default/' $chemin
            
            else

            echo -e  "\n  \033[36;1m>\033[0m Entrez le nom du fichier que vous souhaitez utiliser comme fichier d'indexation. \n \033[31;1m/!\\\\\033[0m Attention, le contenu de ce fichier sera écrasé. \033[31;1m/!\\\\\033[0m \n  \033[36;1m>\033[0m Fichiers utilisables présents dans le répertoire :"
            affliste
            read -p $(echo -e "\033[33;5;1m>>\033[0m ") fic
                until test -e "$fic" # On vérifie que le fichier entré existe bien.
                do
                echo -e "  \033[31;1m>\033[0m Le fichier que vous avez entré n'existe pas ou n'est pas dans $reprinc/"
                read -p $(echo -e "\033[33;5;1m>>\033[0m ") fic
                done
            echo -e "\n  \033[36;1m>\033[0m Souhaitez-vous vraiment utiliser $fic comme fichier d'indexation ? (tout contenu actuel sera éffaçé) \033[36;1m<\033[0m

    \033[33;5;1m>\033[0m (o) - Oui
    \033[33;5;1m>\033[0m (n) - Non

"
            until [ "$confirmation" = "O" -o "$confirmation" = "N" -o "$confirmation" = "o" -o "$confirmation" = "n" ]
            do
            
            read -p $(echo -e "\033[33;5;1m>>\033[0m ") confirmation
                if [ "$confirmation" != "O" -a "$confirmation" != "N" -a "$confirmation" != "o" -a "$confirmation" != "n" ]
                    then
                        echo -e "  \033[31;1m>\033[0m Veuillez entrer un caractère valide."
                fi
            
            done
                if [ "$confirmation" = "O" -o "$confirmation" = "o" ]
                    then
                    liste="$fic" # On déclare le fichier entré comme le fichier d'indexation à utiliser.
					sed -i '2s/.*/liste='$fic'/' $chemin
                    cat /dev/null > "$reprinc"/"$liste" # On vide ce fichier
                    else
                    bash $chemin $1 $2 # Si il n'a pas confirmé l'utilisation de ce fichier, on recommence.
                fi
                
                
            fi
        
		 # Si le fichier d'indexation existe on le déclare comme le fichier à utiliser.
        
        
	
    fi
	repabs=$(echo "$2"|awk -F/ '{print $NF}') 
	
        nbcarep=$(echo ${#repabs})
	echo -e "
      \033[36;1m>\033[0m Fin du check-up \033[36;1m<\033[0m

      \033[36;1m>\033[0m Début de l'indexation... \033[36;1m<\033[0m
"
fi


nom_script=$0
cd "$2" # Entrée dans le répertoire cible
for i in * # Pour chaque élément dans le répertoire
do
		type=$(file -b "$i")
        nvrep=$(readlink -f $(dirname "$i")) # On stocke le chemin de l'endroit ou on est grâce à l'emplacement de l'élément que l'on souhaite traiter.

	ficrep=$nvrep/"$i"
        
    if [[ "$type" =~ "directory" ]] # Si l'élément étudié est un répertoire
        then
        echo -e "    \033[36;1m>\033[0m Entrée dans le sous répertoire : $i"

chemin="${chemin//\\ /\ }"

echo "Commande : bash $chemin -!- $1 -!- \"$i\" -!- $nbcarep -!- \"$liste\" \n"
echo "chem = $chemin"

        bash "$chemin" $1 "$i" $nbcarep "$liste" # On lance un "clone" du script avec des paramètres en plus notamment le sous-répertoire que le clone doit analyser.
      echo "test2"
    elif [[ "$type" =~ "text" ]] # Si l'élément analysé est pas un document texte.
		then
        md5=$(echo `md5sum "$i"` | cut -d" " -f1) #On récupère son adresse md5
        #"$nvrep">zz
        
        sourep=$(echo "${nvrep:$nbcarep}") #On récupère le chemin du fichier analysé à partir de son chemin complet auquel on soustrait le nombre de caractères du 
        
        #echo $nbslash
	listedest="$reprinc"/"$liste"
        
	
        echo -e "  \033[36;1m>\033[0m Trouvé : $i"
		if ! test -s "$listedest"
		then
		echo -e "  \033[32;1m>\033[0m Nouveau fichier indexé : $i"
		 echo "$i*$md5*$sourep*" >> "$listedest"
echo "listedest = $listedest"
			"$reprinc"/"$execlass" "$ficrep" >> "$listedest"
		echo "" >> "$listedest"		#on execute et on affiche en fin de liste 

		else
		verifmd5 "$listedest" "$i" "$md5" "$sourep"
        
		fi

		
		
		if [ "$1" = "--indexhtml" ]
        then
		
	echo '<div class="marges">' >> "$reprinc"/HTML/"$fichtml"
	echo '<ul class="nav">' >> "$reprinc"/HTML/"$fichtml"
        echo "<li><b>• Fichier : $i </b><ul>" >> "$reprinc"/HTML/"$fichtml"
	echo "<li>$sourep</li></ul></li></ul>" >> "$reprinc"/HTML/"$fichtml"
        echo '<table border="1">' >> "$reprinc"/HTML/"$fichtml"
        echo "<tr>" >> "$reprinc"/HTML/"$fichtml"
        echo "<th>Mot</th>" >> "$reprinc"/HTML/"$fichtml"
        echo "<th>Occurences</th>" >> "$reprinc"/HTML/"$fichtml"
        echo "<th>Lignes</th>" >> "$reprinc"/HTML/"$fichtml"
        echo "</tr>" >> "$reprinc"/HTML/"$fichtml"
        
        "$reprinc"/$exehtml "$ficrep" >> "$reprinc"/HTML/"$fichtml"
	echo '</table>' >> "$reprinc"/HTML/"$fichtml"
	
	echo "</div>" >> "$reprinc"/HTML/"$fichtml"
		
fi
	
	
	else
        
    
		echo -e "  \033[31;1m>\033[0m Détecté : $i \033[31;1m/!\\\\\033[0m Ce fichier n'est pas un fichier texte et n'a donc pas été analysé."

		md5=$(echo `md5sum "$i"` | cut -d" " -f1)
		sourep=$(echo "${nvrep:$nbcarep}")

listedest=$reprinc"/"$liste

listedest="${listedest// /\\ }"
listedest="${listedest//&/\\&}"
listedest="${listedest//-/\\-}"
listedest="${listedest// /\;}"

i="${i// /\;}"

sourep="${sourep// /\\ }"
sourep="${sourep//&/\\&}"
sourep="${sourep//-/\\-}"
sourep="${sourep// /\;}"

type="${type// /\;}"

#echo " $listedest --- $i --- $md5 --- $sourep --- $type"
		verifmd5 $listedest $i $md5 $sourep $type
echo " arrivé"
		
		echo "" >> "$reprinc"/"$liste"
echo " arrivé 2"
    fi
    
    
    
done
	if [ "$1" = "--indexhtml" -a $nb_param -eq 2 ]
then
echo -e "
  \033[36;1m>\033[0m Finalisation du html...
"
echo "</div>" >> "$reprinc"/HTML/"$fichtml"

echo "</body>" >> "$reprinc"/HTML/"$fichtml"
echo "</html>" >> "$reprinc"/HTML/"$fichtml"

firefox "$reprinc"/HTML/"$fichtml"

fi

	elif [ $1 = "--search" ]
	then
	params=$(echo -e $@ | sed "s/^[^ ]* //g")
		search "$liste" "$params"
		

	elif [ "$1" = "--noel" ]
	then
	nowel
		
	elif [ "$1" = "--clean" ]
	then
	echo -e "
 \033[36;1m - - - - - - - ->\033[0m C L E A N \033[36;1m<- - - - - - - -\033[0m

  \033[36;1m>\033[0m Souhaitez-vous vraiment nettoyer la base d'indexation ? \033[36;1m<\033[0m

     \033[33;5;1m>\033[0m (o) - Oui
     \033[33;5;1m>\033[0m (n) - Non
"
	until [ "$confirmation" = "O" -o "$confirmation" = "N" -o "$confirmation" = "o" -o "$confirmation" = "n" ]
            do
            read -p $(echo -e "\033[33;5;1m>>\033[0m ") confirmation
                if [ "$confirmation" != "O" -a "$confirmation" != "N" -a "$confirmation" != "o" -a "$confirmation" != "n" ]
                    then
                        echo -e "  \033[31;1m>\033[0m Veuillez entrer un caractère valide."
                fi
            done
    if [ "$confirmation" = "o" -o "$confirmation" = "O" ]
    then
	cat /dev/null > "$reprinc"/"$liste"
	echo -e "  \033[36;1m>\033[0m La base d'indexation à bien été nettoyée.
"
	else
	exit 1
	fi
	
        
        
	else
	echo -e "
  \033[36;1m>\033[31;1m Commande erronée :/ . Usage : \033[0m
       $0 [--index|--indexhtml|--search|--clean|--noel] [fichier à indexer|mot(s) à rechercher]
"
	echo $0
	exit 1
	
fi

