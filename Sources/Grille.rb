require_relative './Cases/BtnCaseNonJouable.rb'
require_relative './Cases/BtnCaseIndication.rb'
require_relative './Cases/BtnCaseJouable.rb'

# Explication des fichiers texte "grille"
# - un c veut dire une case simple, donc une case "décor"
# - un v veut dire une caseVide, donc une case que l'on veut remplir durant une partie.
#  Le chiffre correspond à la bonne réponse. On sépare les 2 par un /
# - un n veut dire une caseNombre, donc une case qui contient les infos pour le joueur.
# Les chiffres correspondent à la valeur verticale et à la valeur horizontale (dans cet ordre). On les sépare par un /
#
# Il faut y a avoir exactement 8 caractère entre 2 cases, donc pour une cas simple, on écrira "c" suivit de 7 espaces.
#
# La classe Grille contient la grille (le tableau à 2 dimensions) de jeu,
# ainsi que d'une liste de caseNombre contenu dans la grille
# Elle possède les méthodes suivantes :
# - estCorrect
# - to_s

class Grille
    # Les objets de cette classe sont caractérisés par :
    #
    # * @tabCase => Une matrice de Case, la grille de jeu
    #
    # * @tabCaseNombre => Un tableau contenant toutes les cases indication de la grille
    #
    # Ils sont capable de :
    #
    # * vérifier que la grille est correcte
    #
    # * calculer le nombre d'erreur

    private_class_method :new

    attr_accessor :tabCase
    attr_accessor :tabCaseNombre

    # Méthode de création d'une grille
    #
    # ==== Paramètres
    #
    # * +strFichier+ - le nom du fichier
    def Grille.creer(strFichier)
        new(strFichier)
    end

    # Méthode d'initialisation d'une grille
    #
    # ==== Paramètres
    #
    # * +strFichier+ - le nom du fichier
    def initialize(strFichier)
        ligne = 8
        colonne = 8
        @tabCase = Array.new(ligne) { Array.new(colonne) }
        @tabCaseNombre = Array.new()

        #On ouvre le fichier
        fichier = File.open(strFichier)
        #On récupère ce qu'il y a dans le fichier
        fichier_data = fichier.readlines.map(&:chomp)

        numLigne = 0
        numColonne = 0
        i = 0

        #Création des cases dans la grille en fonction du doc .txt
        fichier_data.each do |n|
            n.split(" ").each do |cell|
                case cell[0]
                    when 'c'
                        @tabCase[numLigne][numColonne] = BtnCaseNonJouable.creer(numLigne, numColonne)
                    when 'n'
                        tab = cell.split("/")
                        @tabCase[numLigne][numColonne] = BtnCaseIndication.creer(numLigne, numColonne, tab[2], tab[1])
                    when 'v'
                        tab = cell.split("/")
                        @tabCase[numLigne][numColonne] = BtnCaseJouable.creer(numLigne, numColonne, tab[1], "0")
                        #@tabCase[numLigne][numColonne].set_label(tab[1])
                    else
                        puts "Erreur "
                end
                numColonne+=1
                i+=1
            end
            numLigne+=1
            numColonne=0
        end
        #Place les CaseNombre dans le tableau @tabCaseNombre
        @tabCase.each do |n|
            n.each do |cell|
                if cell.estCaseNombre?() then
                    @tabCaseNombre.push(cell)
                end
            end
        end

        fichier.close
    end

    # Méthode qui renvoie si la grille est correct ou non (true si correct, false sinon)
    def estCorrect()
        etat = true
        @tabCaseNombre.each do |n|
            n.mathsBon(tabCase)
            if !(n.etatH==true && n.etatV==true) then
                etat=false
            end
        end
        return etat
    end

    # Méthode qui calcule le nombre d'erreurs et demande au jeu de l'afficher
    #
    # ==== Paramètres
    #
    # * +jeu+ - le jeu
    def nbErreurs
        nbErr = 0
        @tabCase.each do |n|
            n.each do |cell|
                if cell.jouable?
                    if cell.saisieUtilisateur != 0 && !cell.contientBonneReponse?
                        nbErr += 1
                    end
                end
            end
        end
        return nbErr
    end

    # Méthode de recherche de la case la plus facile à remplir
    def astucesTrouveCase
        verticaleCase = nil
        horizontaleCase = nil

        @tabCaseNombre.each do |cell|
            # Pour les cases verticales
            if cell.valeurV != 0
                if !cell.etatV
                    if verticaleCase == nil
                        verticaleCase = cell
                    else
                        if (cell.nbCasesColonne(@tabCase) - cell.nbCasesRempliesV(@tabCase)) < (verticaleCase.nbCasesColonne(@tabCase) - verticaleCase.nbCasesRempliesV(@tabCase))
                            verticaleCase = cell
                        elsif (cell.nbCasesColonne(@tabCase) - cell.nbCasesRempliesV(@tabCase)) == (verticaleCase.nbCasesColonne(@tabCase) - verticaleCase.nbCasesRempliesV(@tabCase))
                            if cell.valeurV < verticaleCase.valeurV
                                verticaleCase = cell
                            end
                        end
                    end
                end
            end

            if cell.valeurH != 0
                if !cell.etatH
                    if horizontaleCase == nil
                        horizontaleCase = cell
                    else
                        if (cell.nbCasesLigne(@tabCase) - cell.nbCasesRempliesH(@tabCase)) < (horizontaleCase.nbCasesLigne(@tabCase) - horizontaleCase.nbCasesRempliesH(@tabCase))
                            horizontaleCase = cell
                        elsif (cell.nbCasesLigne(@tabCase) - cell.nbCasesRempliesH(@tabCase)) == (horizontaleCase.nbCasesLigne(@tabCase) - horizontaleCase.nbCasesRempliesH(@tabCase))
                            if cell.valeurH < horizontaleCase.valeurH
                                horizontaleCase = cell
                            end
                        end
                    end
                end
            end
        end

        if verticaleCase == nil || horizontaleCase == nil
            if verticaleCase != nil
                verticaleCase.colorerCasesFaciles(@tabCase, false)
            elsif horizontaleCase != nil
                horizontaleCase.colorerCasesFaciles(@tabCase, true)
            end
        else
            # Comparaison horizontale et verticale
            if verticaleCase == horizontaleCase
                verticaleCase.colorerCasesFaciles(@tabCase, false)
            else
                if (verticaleCase.nbCasesLigne(@tabCase) - verticaleCase.nbCasesRempliesV(@tabCase)) < (horizontaleCase.nbCasesColonne(@tabCase) - horizontaleCase.nbCasesRempliesH(@tabCase))
                    verticaleCase.colorerCasesFaciles(@tabCase, false)
                elsif(verticaleCase.nbCasesLigne(@tabCase) - verticaleCase.nbCasesRempliesV(@tabCase)) > (horizontaleCase.nbCasesColonne(@tabCase) - horizontaleCase.nbCasesRempliesH(@tabCase))
                    horizontaleCase.colorerCasesFaciles(@tabCase, true)
                else
                    if horizontaleCase.valeurH < verticaleCase.valeurV
                        horizontaleCase.colorerCasesFaciles(@tabCase, true)
                    else
                        verticaleCase.colorerCasesFaciles(@tabCase, false)
                    end
                end
            end
        end
    end

    # Méthode pour mettre en évidence les erreurs de la grille
    def evidenceCaseErreur
        @tabCase.each do |n|
            n.each do |cell|
                if cell.jouable?
                    if cell.saisieUtilisateur != 0 && !cell.contientBonneReponse?
                        cell.metEvidenceCaseErreur
                    end
                end
            end
        end
    end

    # Méthode pour retirer l'évidence les erreurs de la grille
    def evidenceCaseErreurNo
        @tabCase.each do |n|
            n.each do |cell|
                if cell.jouable?
                    cell.retireEvidenceCaseErreur
                end
            end
        end
    end

    # Méthode qui permet de parcourir la grille et de retirer les css d'astuces
    def retireCSS
        @tabCase.each do |n|
            n.each do |x|
                if(x.jouable?)
                    x.retireCSSAstuce
                end
            end
        end
    end

    # Méthode de mis à jour de l'aide visuelle sur la grille
    def majAideVisuelle
        @tabCase.each do |n|
            n.each do |x|
                if(x.jouable?)
                    x.aideVisuelle(@tabCase)
                end
            end
        end
    end

end #fin de la classe Grille
