require 'gtk3'
include Gtk
Gtk.init

require_relative './Fonctions/Quitter.rb'
require_relative './Fonctions/Outils.rb'
require_relative 'Grille'
require_relative 'GestionneurTechnique'
require_relative 'Sauvegarde'
require_relative 'Partie'
require_relative 'Score'

class MenuPrincipal
    # Les éléments de cette classe sont caractérisés par :
    #
    # * @kakuro => la fenêtre du jeu
    # * @tableauCaseVide => tableau des cases jouable
    # * @combiLigne => label des combinaisons ligne
    # * @combiColonne => label de combinaisons colonne
    # * @boolCrayon => booleen pour l'activation du crayon
    # * @crayon => bouton crayon qui permettre d'écrire dans les cases
    # * @stylo => bouton style qui permettre d'écrire des brouillons dans les cases
    # * @erreur => bouton qui permet de demander l'aide des erreurs
    # * @caseCourante => reference vers une case
    # * @css_vert => css appliqué à une case selectionné
    # * @nombreDeCases => nombre de cases dans la grille
    # * @nombreDeLignes => nombre de lignes dans la grille
    # * @estNouvellePartie => retourne vrai si on est sur une nouvelle partie
    # * @partie => instance de la classe Partie
    # * @sauvegarde => instance de la classe Sauvegarde
    # * @totalScore => score du joueur
    # * @gestionneurTechnique => le gestionneur des techniques
    # * @nouvellePartie => bouton pour la nouvelle partie
    # * @recommencerPartie => bouton pour recommencer la partie
    # * @gomme => bouton pour la gomme
    # * @unDo => bouton pour le undo
    # * @reDo => bouton pour le redo

    def initialize
        @kakuro = Window.new
        @kakuro.set_title("Kakuro")
        @kakuro.border_width=50
        @kakuro.set_resizable(true)
        @kakuro.set_window_position(:center_always)
        @kakuro.resize(700,400)
        @kakuro.signal_connect('destroy'){onDestroy}

        @gestionneurTechnique = GestionneurTechnique.new

        @nombreDeCases = 0
        @nombreDeLignes = 0
        @combiLigne = Label.new()
        @combiColonne = Label.new()

        @boolCrayon = false
        @boolNom =  false

        @crayon = Button.new().set_label("CRAYON")
        @stylo = Button.new().set_label("STYLO")
        @stylo.set_sensitive(false)

        @kakuro.signal_connect('key-press-event') do |w, e|

            chaine = Gdk::Keyval.to_name(e.keyval)
            chaine = chaine.gsub("KP_","")

            if @partie != nil


                if chaine == "Escape"
                    @partie.marshal_dump(@partie.nomPartie())
                    stopChrono
                    resetChrono
                    @kakuro.remove(@conteneurPrincipal)
                    self.chargerMenuPrincipal
                end
            end

            if @boolNom
                if chaine == "Return"
                    @nomJoueur = @espaceNom.text.gsub(/\s+/, "")
                    chargerDifficulte(@pres,false)
                end
            end

            if(@caseCourante != nil)
                i = @caseCourante.ligne
                j = @caseCourante.colonne

                case chaine
                    when "Right"
                        if((j+1) < 8 && @partie.grille.tabCase[i][j+1].jouable?)
                            actionDirection(@partie.grille.tabCase[i][j+1])
                        end

                    when "Left"
                        if(@partie.grille.tabCase[i][j-1].jouable?)
                            actionDirection(@partie.grille.tabCase[i][j-1])
                        end

                    when "Up"
                        if(@partie.grille.tabCase[i-1][j].jouable?)
                            actionDirection(@partie.grille.tabCase[i-1][j])
                        end

                    when "Down"
                        if((i+1) < 8 && @partie.grille.tabCase[i+1][j].jouable?)
                            actionDirection(@partie.grille.tabCase[i+1][j])
                        end
                    else
                        if(chaine.to_i.between?(1,9))
                            if @boolCrayon == true
                                if @caseCourante.label() == nil || @caseCourante.label == ""
                                    @caseCourante.set_label(chaine)

                                elsif @caseCourante.label().include?(chaine)
                                    if @caseCourante.label().length == 1
                                        @caseCourante.set_label("")
                                    else
                                        s = @caseCourante.label()
                                        s = s.sub(chaine, "")
                                        s = s.gsub("\n", "")
                                        tabBrouillon = s.chars
                                        ch = ""
                                        tabBrouillon.each_index{ |i|
                                            if (i%3) == 0  && i != 0
                                                ch += "\n"
                                            end
                                            ch += tabBrouillon[i]
                                        }
                                        @caseCourante.set_label(ch)
                                    end
                                else
                                    taille = @caseCourante.label().length
                                    if taille == 3 || taille == 7
                                        @caseCourante.set_label(@caseCourante.label()+"\n"+chaine)
                                    else
                                        @caseCourante.set_label(@caseCourante.label()+chaine)
                                    end
                                end

                                if @caseCourante.label().length > 0
                                    @caseCourante.activeStylo = true
                                    @stylo.set_sensitive(true)
                                end
                            else
                                @partie.grille.retireCSS
                                @caseCourante.set_label(chaine)
                                @caseCourante.set_sensitive(true)
                                @caseCourante.style_context.remove_provider(@css_vert)

                                if(@partie.aideVisuelle)
                                    @caseCourante.aideVisuelle(@partie.grille.tabCase)
                                end

                                @caseCourante.activeCrayon = false
                                @caseCourante.activeStylo = false
                                @stylo.set_sensitive(false)
                                @combiColonne.set_label("")
                                @combiLigne.set_label("")
                                @gestionneurTechnique.majTechnique(@partie.grille)
                                @caseCourante = nil

                                if @partie.grille.estCorrect()
                                    stopChrono
                                    finPartie
                                end
                            end
                        end
                    @sauvegarde.majCoup(@partie.grille().tabCase)
                end
            end
        end
        @caseCourante = nil
        @css_vert = Gtk::CssProvider.new
        @css_vert.load(data: <<-CSS)
        button {
            background-color: green;
            background-image: none;
            opacity: 0.8;
        }
        CSS
    end

    # changer le menu principal
    #
    #
    # ==== Exemples
    #
    # => #Lancement du jeu
    # => mp = MenuPrincipal.new
    # => mp.chargerMenuPrincipal
    # => mp.lanceToi
    def chargerMenuPrincipal

        @estNouvellePartie = nil
        @partie = nil;
        @sauvegarde = Sauvegarde.debuter()
        @totalScore = 0
        @nombreDeCases = 0
        @nombreDeLignes = 0

        @boolCrayon = false
        @boolNom =  false

        @caseCourante = nil

        @kakuro.border_width=50
        @kakuro.resize(700,400)

        presentation = Table.new(12, 1)
        tabBouton = Table.new(4, 1, true)

        nouvellePartie = Button.new().set_label("Nouvelle Partie")
        chargerPartie = Button.new().set_label("Charger Partie")
        classement = Button.new().set_label("Classement")

        tabBoutonQuitter = Table.new(1,1)
        quitter = Button.new().set_label("Quitter")

        # Bouton Nouvelle partie
        nouvellePartie.signal_connect('clicked'){
            saisirNom(presentation)
            @estNouvellePartie = true;
        }
        # Bouton Charger Partie
        chargerPartie.signal_connect('clicked'){
            chargerSauvegarde(presentation)
            @estNouvellePartie = false;
        }
        # Bouton Classement
        classement.signal_connect('clicked'){
            chargerClassement(presentation)
        }
        # Bouton quitter
        quitter.signal_connect('clicked'){onDestroy}

        tabBouton.attach(nouvellePartie, 0, 1, 0, 1)
        tabBouton.attach(chargerPartie, 0, 1, 1, 2)
        tabBouton.attach(classement, 0, 1, 2, 3)
        tabBoutonQuitter.attach(quitter, 0, 1, 0, 1)

        presentation.attach(getLabel("Kakuro Game"), 0, 1, 0, 3)
        presentation.attach(tabBouton, 0, 1, 3, 10)
        presentation.attach(tabBoutonQuitter, 0, 1, 10, 12)

        @kakuro.add(presentation)

        @kakuro.signal_connect('delete_event'){
            @kakuro.set_sensitive(false)
            onDestroyPopUp(@kakuro)
        }
        afficheToi
    end

    # passer sur la fênetre de saisie du nom de l'utilisateur
    #
    # ==== Paramètres
    #
    # * +presentation+ - conteneur de la fenetre précedente
    #
    # ==== Exemples
    #
    # => presentation = Table.new(12, 1)
    # => nouvellePartie = Button.new().set_label("Nouvelle Partie")
    # => nouvellePartie.signal_connect('clicked'){
    #     saisirNom(presentation)
    #     @estNouvellePartie = true;
    #   }
    def saisirNom(presentation)
        @kakuro.remove(presentation)
        @kakuro.border_width=20

        presCopie = Table.new(10,2,true)
        tabBouton = Table.new(2,1)
        suivant = Button.new().set_label("Suivant").set_sensitive(false)
        retour = Button.new().set_label("Retour")

        nom = Entry.new()
        @espaceNom = nom
        nom.max_length = 10
        nom.signal_connect('changed'){
            suivant.set_sensitive(true)
            @boolNom = true
            if nom.text.gsub(/\s+/, "").length == 0
                suivant.set_sensitive(false)
                @boolNom = false
            end
        }

        labN = Label.new()
        labN.set_markup("<big> Saisir votre nom : </big>")
        boxN = Box.new(:horizontal, 2)
        boxN.pack_start(labN, :fill => true, :padding=>2)
        boxN.pack_start(nom,:expand => true, :fill => true)

        pixbuf = GdkPixbuf::Pixbuf.new(:file => './Sources/Images/wizG.png')
        imageUser = Gtk::Image.new :pixbuf => pixbuf

        presCopie.attach(getLabel("Kakuro Game"),0,2,0,2)
        presCopie.attach(imageUser,0,2,2,5)
        presCopie.attach(boxN,0,2,6,7)
        tabBouton.attach(retour,0,1,0,1)
        tabBouton.attach(suivant,1,2,0,1)
        presCopie.attach(tabBouton,0,2,8,10)
        # Pour bouton entrée à la saisie
        @pres = presCopie

        retour.signal_connect('clicked'){
            retour(presCopie,presentation)
        }
        suivant.signal_connect('clicked'){
            @nomJoueur = nom.text.gsub(/\s+/, "")
            chargerDifficulte(presCopie,false)
        }
        @kakuro.add(presCopie)
        afficheToi
    end

    # passer sur la fênetre de choix de difficulte (facile, medium, difficile)
    #
    # ==== Paramètres
    #
    # * +presentation+ - conteneur de la fenetre précedente
    # * +presentation+ - booleen indiquant si on charge les difficulte à partie de la partie en cours ou à partir d'une nouvelle partie (false par defaut)
    #
    # ==== Exemples
    #
    # => presCopie = Table.new(10,2,true)
    # => suivant = Button.new().set_label("Suivant").set_sensitive(false);
    # => suivant.signal_connect('clicked'){
    #       @nomJoueur = nom.text.gsub(/\s+/, "")
    #       chargerDifficulte(presCopie,false)
    #    }
    def chargerDifficulte(presentation, partie)
        @kakuro.border_width=50
        @kakuro.resize(700,400)
        @kakuro.remove(presentation)

        presCopie = Table.new(12, 1)
        # Création du Layout
        hauteurTableauWidget = 4
        largeurTableauWidget = 1
        tabWidget=Table.new(hauteurTableauWidget,largeurTableauWidget,true)
        tabBoutonRetour= Table.new(1,1)

        #ajout du tableau de widget à la fenetre principale
        @kakuro.add(presCopie)

        # Création des Boutons
        facile=Button.new().set_label("Facile")
        medium=Button.new().set_label("Moyen")
        difficile=Button.new().set_label("Difficile")
        retour = Button.new()

        # connexion des boutons aux signaux
        facile.signal_connect('clicked'){
          changerNiveau(presCopie,"facile")
        }
        medium.signal_connect('clicked'){
          changerNiveau(presCopie,"moyen")
        }
        difficile.signal_connect('clicked'){
          changerNiveau(presCopie,"difficile")
        }

        if partie
            retour.set_label("Retour vers la partie")
        else
            retour.set_label("Retour")
        end

        retour.signal_connect('clicked'){
            if partie && @partie.enCours
                @kakuro.border_width=5
                @kakuro.resize(1100,700)
                startChrono
            end
            retour(presCopie,presentation)
        }

        # On ajoute a la Table les widgets des boutons
        tabWidget.attach(facile,0,1,0,1)
        tabWidget.attach(medium,0,1,1,2)
        tabWidget.attach(difficile,0,1,2,3)
        tabBoutonRetour.attach(retour,0,1,0,1)

        presCopie.attach(getLabelXX("Kakuro Game"), 0, 1, 0, 3)
        presCopie.attach(tabWidget, 0, 1, 3, 10)
        presCopie.attach(tabBoutonRetour, 0, 1, 10, 12)

        afficheToi
    end

    # passer sur la fênetre de changement de niveau (1, 2, 3...)
    #
    # ==== Paramètres
    #
    # * +presentation+ - conteneur de la fenetre précedente
    # * +difficulte+ - difficulte choisie par l'utilisateur (facile, medium, difficile)
    #
    # ==== Exemples
    #
    #   presCopie = Table.new(12, 1)
    #   facile=Button.new().set_label("Facile")
    #   medium=Button.new().set_label("Moyen")
    #   difficile=Button.new().set_label("Difficile")
    #   # connexion des boutons aux signaux
    #   facile.signal_connect('clicked'){
    #       changerNiveau(presCopie,"facile")
    #   }
    #   medium.signal_connect('clicked'){
    #       changerNiveau(presCopie,"moyen")
    #   }
    #   difficile.signal_connect('clicked'){
    #       changerNiveau(presCopie,"difficile")
    #   }
    def changerNiveau(presentation,difficulte)
        # on enleve l'autre menu de la fenetre principal
        @kakuro.remove(presentation)

        presCopie = Table.new(6, 1)

        #ajout du tableau de widget à la fenetre principale
        @kakuro.add(presCopie)

        # creation du nouveau menu avec une table
        tabWidget= Gtk::Table.new(2,3,false)
        jeu1=Button.new().set_label("1")
        jeu2=Button.new().set_label("2")
        jeu3=Button.new().set_label("3")
        retour = Button.new().set_label("Retour")

        # connexion des boutons aux signaux
        jeu1.signal_connect('clicked'){
            choixAide(presCopie,"niveau 1",difficulte)
            presCopie.set_sensitive(false)
        }
        jeu2.signal_connect('clicked'){
          choixAide(presCopie,"niveau 2",difficulte)
          presCopie.set_sensitive(false)
        }
        jeu3.signal_connect('clicked'){
          choixAide(presCopie,"niveau 3",difficulte)
          presCopie.set_sensitive(false)
        }
        retour.signal_connect('clicked'){retour(presCopie,presentation)}

        # On ajoute a la Table les widgets des boutons
        tabWidget.attach(jeu1,0,1,0,1)
        tabWidget.attach(jeu2,1,2,0,1)
        tabWidget.attach(jeu3,2,3,0,1)

        presCopie.attach(getLabelXX("Kakuro Game"), 0, 1, 0, 3)
        presCopie.attach(tabWidget, 0, 1, 3, 5)

        presCopie.attach(retour, 0, 1, 5, 6)

        #on affiche tout
        afficheToi
    end

    # fenetre pop up du choix d'affichage des aides visuelles ou non
    # @return true si les aides visuelles doivent etre actives
    #
    # ==== Paramètres
    #
    # * +presCopie+ - conteneur de la fenetre précedente
    # * +difficulte+ - difficulte choisie par l'utilisateur (facile, medium, difficile)
    # * +niveau+ - numéro du niveau choisi par l'utilisateur par rapport à la difficulté
    #
    # ==== Exemples
    #   presCopie = Table.new(6, 1)
    #   jeu1=Button.new().set_label("1")
    #
    #   # connexion des boutons aux signaux
    #   jeu1.signal_connect('clicked'){
    #       choixAide(presCopie,"niveau 1",difficulte)
    #       presCopie.set_sensitive(false)
    #   }
    def choixAide(presCopie,niveau,difficulte)
        # initialisation de la fenetre
        popUpChoixAide = Window.new
        popUpChoixAide.set_title("Choix de l'aide visuelle")
        popUpChoixAide.set_window_position(:center_always)
        popUpChoixAide.border_width=10
        popUpChoixAide.set_default_size(100,100)
        popUpChoixAide.set_resizable(false)
        tableauBouton = Gtk::Table.new(3,2,true)

        # ajout du tableau à la fenetre
        popUpChoixAide.add(tableauBouton)

        # création des boutons de la fenetre pop up
        oui = Button.new().set_label("Oui")
        non = Button.new().set_label("Non")
        texte = Label.new().set_label("Voulez vous activer l'aide visuelle ?")

        # ajout des boutons au tableau
        tableauBouton.attach(texte,0,2,0,2)
        tableauBouton.attach(oui,0,1,2,3)
        tableauBouton.attach(non,1,2,2,3)

        # création de la Partie
        @partie = Partie.creer(@nomJoueur,niveau,difficulte)
        @partie.marshal_dump(@partie.nomPartie())
        @estNouvellePartie = true

        # on reinitialise les listes d'undo/redo
        @sauvegarde.reinitialisationListes()

        @combiLigne = Label.new()
        @combiColonne = Label.new()
        @boolCrayon = false
        @crayon = Button.new().set_label("CRAYON")
        @stylo = Button.new().set_label("STYLO")
        @stylo.set_sensitive(false)

        # connexion des signaux
        oui.signal_connect('clicked'){
            @partie.aideVisuelle = true
            popUpChoixAide.destroy
            lancerJeu(presCopie,@partie.nomPartie())
        }
        non.signal_connect('clicked'){
            @partie.aideVisuelle = false
            popUpChoixAide.destroy
            lancerJeu(presCopie,@partie.nomPartie())
        }

        # si on ferme la fenetre on change pas de menu et la fenetre est simplement detruite
        popUpChoixAide.signal_connect('delete_event'){
            texte.set_label("Vous devez choisir une aide visuelle ou non !")
            presCopie.set_sensitive(true)
        }

        popUpChoixAide.set_keep_above(true)
        #affichage de la fenetre pop up
        popUpChoixAide.show_all
    end

    # méthode de chargement de la liste de toutes les sauvegardes disponible, nécessite qu'une instance de sauvegarde soit déja crée au préalable
    #
    # ==== Paramètres
    #
    # * +presentation+ - conteneur de la fenetre précedente
    #
    # ==== Exemples
    #   presentation = Table.new(12, 1)
    #   @sauvegarde = Sauvegarde.charger()
    #   chargerPartie = Button.new().set_label("Charger Partie")
    #
    #   # Bouton Charger Partie
    #   chargerPartie.signal_connect('clicked'){
    #       chargerSauvegarde(presentation)
    #       @estNouvellePartie = false;
    #   }
    def chargerSauvegarde(presentation)
        @kakuro.remove(presentation)
        @combiLigne = Label.new()
        @combiColonne = Label.new()
        @boolCrayon = false
        @crayon = Button.new().set_label("CRAYON")
        @stylo = Button.new().set_label("STYLO")
        @stylo.set_sensitive(false)
        # Les données sont stockées dans un TreeStore
        presCopie = Table.new(10, 1)
        presCopie.attach(getLabelXX("Liste des sauvegardes"), 0, 1, 0, 3)

        coulissant=ScrolledWindow.new()

        tabP = Table.new(50, 4, false)

        nbLigne = 0

        pathToAllDir=File.join("Sauvegarde", "*") # Créer le chemin Dossier\*
        dirs = Dir[pathToAllDir] # Lister tous les dossier de Sauvegarde
        dirs.each { |dir|
               pathToAllFiles=File.join(dir, "*") # Créer le chemin Sauvegarde\dir\* pour chaque dir
               files = Dir[pathToAllFiles] # Lister tous les fichiers de Sauvegarde\dir\
               files.each{|file|
                    @partie = @sauvegarde.charger(file)
                    if @partie != nil then
                        tab = Table.new(1, 3, true)
                        tabBtn = Table.new(1, 2, true)

                        charger = Button.new().set_label("Charger")
                        charger.signal_connect('clicked'){
                            lancerJeu(presCopie,file)
                        }
                        supprimer = Button.new().set_label("Supprimer")
                        supprimer.signal_connect('clicked'){
                            tabP.remove(tab)  # on supprime la ligne qui correspond au fichier du tableau
                            tabP.remove(tabBtn)
                            File.unlink(file) # suppression du fichier
                        }
                        tab.attach(Label.new().set_label(@partie.joueur().capitalize), 0, 1, 0, 1)
                        tab.attach(Label.new().set_label(@partie.difficulte().capitalize + " / " + @partie.niveau().capitalize), 1, 2, 0, 1)
                        tab.attach(Label.new().set_label(@partie.date().to_s), 2, 3, 0, 1)

                        tabBtn.attach(charger, 0, 1, 0, 1)
                        tabBtn.attach(supprimer, 1, 2, 0, 1)

                        tabP.attach(tab, 0, 3, nbLigne, nbLigne+1)
                        tabP.attach(tabBtn, 3, 4, nbLigne, nbLigne+1)
                        nbLigne += 1
                     end
               }
        }

        if nbLigne != 0
            tabP.resize(nbLigne, 1)
        end
        coulissant.add(tabP)

        presCopie.attach(coulissant, 0, 1, 3, 9)

        retour = Button.new().set_label("Retour");
        retour.signal_connect('clicked'){retour(presCopie,presentation)}
        presCopie.attach(retour, 0, 1, 9, 10)

        @kakuro.add(presCopie)
        afficheToi
    end

    # méthode d'accès au classement
    #
    # ==== Paramètres
    #
    # * +presentation+ - conteneur de la fenetre précedente
    #
    # ==== Exemples
    #   presentation = Table.new(12, 1)
    #   #Bouton Classement
    #   classement = Button.new().set_label("Classement")
    #   classement.signal_connect('clicked'){
    #       chargerClassement(presentation)
    #   }
    def chargerClassement(presentation)
        @kakuro.remove(presentation)

        # Les données sont stockées dans un TreeStore
        presCopie = Table.new(10, 1)
        presCopie.attach(getLabel("Classement"), 0, 1, 0, 3)

        tableauBouton = Table.new(5,1,true)
        easy = Button.new().set_label("Facile")
        medium = Button.new().set_label("Moyen")
        hard = Button.new().set_label("Difficile")
        global = Button.new().set_label("Global")
        retour = Button.new().set_label("Retour")

        tableauBouton.attach(easy, 0, 1, 0, 1)
        tableauBouton.attach(medium, 0, 1, 1, 2)
        tableauBouton.attach(hard, 0, 1, 2, 3)
        tableauBouton.attach(global, 0, 1, 3, 4)

        presCopie.attach(tableauBouton, 0, 1, 3, 9)
        presCopie.attach(retour, 0, 1, 9, 10)

        easy.signal_connect('clicked'){
            chargerClassements(presCopie,easy.label)
        }
        medium.signal_connect('clicked'){
            chargerClassements(presCopie,medium.label)
        }
        hard.signal_connect('clicked'){
            chargerClassements(presCopie,hard.label)
        }
        global.signal_connect('clicked'){
            chargerClassements(presCopie,global.label)
        }
        retour.signal_connect('clicked'){retour(presCopie,presentation)}

        @kakuro.add(presCopie)
        afficheToi
    end

    # méthode d'accès au classement
    #
    # ==== Paramètres
    #
    # * +presentation+ - conteneur de la fenetre précedente
    #
    # ==== Exemples
    #   presCopie = Table.new(10, 1)
    #   easy = Button.new().set_label("Facile")
    #   medium = Button.new().set_label("Moyen")
    #   easy.signal_connect('clicked'){
    #       chargerClassements(presCopie,easy.label)
    #   }
    #   medium.signal_connect('clicked'){
    #       chargerClassements(presCopie,medium.label)
    #   }
    def chargerClassements(presentation,difficulte)

        @kakuro.remove(presentation)
        tab = @sauvegarde.chargerScores(difficulte.downcase)
        # Les données sont stockées dans un TreeStore
        presCopie = Table.new(10, 2, true)
        presCopie.attach(getLabelXX("Classement #{difficulte}"), 0, 2, 0, 3)
        coulissant = ScrolledWindow.new()

        tableau = Table.new(4,1,true)
        retour = Button.new().set_label("Retour")
        reinitialiser = Button.new().set_label("Reinitialiser")

        if tab.empty?
            reinitialiser.set_sensitive(false)
        end

        model = Gtk::TreeStore.new(Integer,String, String)
        rang = 1
        tab = tab.sort_by { |s| s.scan(/\d+/).last.to_i }.reverse
        tab.each{ |variable|
          root_iter = model.append(nil)
          root_iter[0] = rang
          root_iter[1] = variable.split(' ')[0].capitalize
          root_iter[2] = variable.split(' ')[1]
          rang += 1
        }

        tree = Gtk::TreeView.new(model)
        rendu = Gtk::CellRendererText.new
        colonne = Gtk::TreeViewColumn.new("Rang : ", rendu, :text => 0)
        tree.append_column(colonne)

        rendu = Gtk::CellRendererText.new
        colonne2 = Gtk::TreeViewColumn.new("Joueur : ", rendu, :text => 1)
        tree.append_column(colonne2)

        rendu = Gtk::CellRendererText.new
        colonne3 = Gtk::TreeViewColumn.new("Score : ", rendu, :text => 2)
        tree.append_column(colonne3)

        coulissant.add(tree)
        presCopie.attach(coulissant, 0, 2, 3, 9)
        presCopie.attach(reinitialiser, 0, 1, 9, 10)
        presCopie.attach(retour, 1, 2, 9, 10)

        @kakuro.add(presCopie)
        retour.signal_connect('clicked'){retour(presCopie,presentation)}
        reinitialiser.signal_connect('clicked'){
            @sauvegarde.reinitialiseScore(difficulte.downcase)
            @kakuro.remove(presCopie)
            @kakuro.add(presentation)
            chargerClassements(presentation,difficulte)
        }

        afficheToi
    end

    # méthode de lancement de jeu
    #
    # ==== Paramètres
    #
    # * +presentation+ - conteneur de la fenetre précedente
    # * +fichier+ - fichier à charger en cas de partie chargée
    #
    # ==== Exemples
    #
    #   # création de la Partie
    #   @partie = Partie.creer(@nomJoueur,niveau,difficulte)
    #   @partie.marshal_dump(@partie.nomPartie())
    #   @estNouvellePartie = true
    #
    #   # création des boutons de la fenetre pop up
    #   oui = Button.new().set_label("Oui")
    #   oui.signal_connect('clicked'){
    #       @partie.aideVisuelle = true
    #       popUpChoixAide.destroy
    #       lancerJeu(presCopie,@partie.nomPartie())
    #   }
    def lancerJeu(presentation,fichier)
        @kakuro.remove(presentation)
        @kakuro.border_width=5
        @kakuro.resize(1100,700)

        if(!@estNouvellePartie)
            @partie = @sauvegarde.charger(fichier)
            @nomJoueur = @partie.joueur
        else
            @partie.score = Score.creer(@partie.difficulte, @partie.aideVisuelle)
        end

        @nombreDeCases = 0
        @nombreDeLignes = 0

        @conteneurPrincipal = Table.new(10, 1)
        # 1 pour le haut, 6 pour le centhboxChrono.pack_start(labelChrono)re, 1 pour combis et 2 boutons
        # Option jeu
        tableNord = Table.new(3, 1)

        tableOption = Table.new(1, 3)
        @nouvellePartie = Button.new().set_label("Nouvelle partie")
        @nouvellePartie.signal_connect('clicked'){
            chargerDifficulte(@conteneurPrincipal, true)
            @partie.marshal_dump(@partie.nomPartie())
            stopChrono
            @estNouvellePartie = true

        }

        @recommencerPartie = Button.new().set_label("Recommencer la partie")

        quitter = Button.new().set_label("Menu principal")
        quitter.signal_connect('clicked'){
            @partie.marshal_dump(@partie.nomPartie())
            stopChrono
            resetChrono
            @kakuro.remove(@conteneurPrincipal)
            self.chargerMenuPrincipal
        }

        nomNiveau = getLabelX(@partie.difficulte().capitalize + "   -   " +  @partie.niveau().capitalize, false)

        tableOption.attach(@nouvellePartie, 0, 1, 0, 1)
        tableOption.attach(@recommencerPartie, 1, 2, 0, 1)
        tableOption.attach(quitter, 2, 3, 0, 1)

        tableNord.attach(tableOption, 0, 1, 0, 1)
        tableNord.attach(nomNiveau, 0, 1, 1, 3)

        @conteneurPrincipal.attach(tableNord, 0, 1, 0, 1)

        # Conteneur central
        conteneurCentral = Table.new(1, 5, true)

        # Box Chrono
        tableChrono = Table.new(10, 3, true)

        hboxChrono = Box.new(:horizontal, 2)
        labelChrono = Label.new()
        labelChrono.set_markup("<big>Chronomètre : </big>")

        hboxChrono.pack_start(labelChrono)
        @mylabel = Gtk::Label.new
        @accumulated = @partie.chrono
        startChrono
        hboxChrono.pack_start(@mylabel)

        tableChrono.attach(hboxChrono, 0, 3, 2, 4)

        numeroNiveau = @partie.niveau().split(' ')[1]

        tableDo = Table.new(1, 2)
        @unDo = Button.new().set_label("Undo")
        @reDo = Button.new().set_label("Redo")

        tableDo.attach(@unDo, 0, 1, 0, 1)
        tableDo.attach(@reDo, 1, 2, 0, 1)

        tableChrono.attach(tableDo, 0, 2, 4, 5)

        grilleGtk = Table.new(8, 8)

        @pause = Button.new().set_label('Pause')
        @pause.signal_connect('clicked'){
            conteneurCentral.remove(grilleGtk)
            focus(conteneurCentral, grilleGtk)
            @kakuro.set_sensitive(false)
            stopChrono
        }

        @recommencerPartie.signal_connect('clicked'){
            recommencerLaPartie()
            resetChrono
            startChrono
            if(@caseCourante != nil)
                @caseCourante.set_sensitive(true)
                @caseCourante.style_context.remove_provider(@css_vert)
                @caseCourante.set_label("")
                @caseCourante = nil
            end
            @sauvegarde.reinitialisationListes()
        }

        tableChrono.attach(@pause, 0, 2, 5, 6)

        conteneurCentral.attach(tableChrono,0, 1, 0, 1)

        # Grille
        if(@estNouvellePartie) then
            remplirGrille(grilleGtk,"./Sources/Grilles/#{@partie.difficulte}/grille#{numeroNiveau}")
        else
            chargerGrille(grilleGtk);
        end

        @unDo.signal_connect('clicked'){
            changementGrille(@sauvegarde.undo())
            if @partie.aideVisuelle
                @partie.grille.majAideVisuelle
            end
        }

        @reDo.signal_connect('clicked'){
            changementGrille( @sauvegarde.redo())
            if @partie.aideVisuelle
                @partie.grille.majAideVisuelle
            end
        }

        conteneurCentral.attach(grilleGtk,1, 4, 0, 1)

        # Score
        tableMalus = Table.new(10, 1,true)
        tableMalus.border_width = 5

        boxNomJ = Box.new(:horizontal,2)
        pixbuf = GdkPixbuf::Pixbuf.new(:file => './Sources/Images/wiz.png')
        imageUser = Gtk::Image.new :pixbuf => pixbuf
        nomUser = Label.new().set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b><i>#{@nomJoueur.capitalize}</i></b></span>")

        boxNomJ.pack_start(imageUser, :padding=>15)
        boxNomJ.pack_start(nomUser)

        # définition des labels
        @nomMalus = Label.new
        @malus = Label.new()

        #remplissage de tout les conteneurs
        tableMalus.attach(boxNomJ,0,1,0,2)
        tableMalus.attach(@nomMalus,0,1,2,4)
        tableMalus.attach(@malus,0,1,4,6)

        tabLeauScore = @sauvegarde.chargerScores(@partie.difficulte.downcase)
        @meilleurScore = 0
        if !tabLeauScore.empty?
            tabLeauScore = tabLeauScore.sort_by { |s| s.scan(/\d+/).last.to_i }.reverse
            @meilleurScore = tabLeauScore[0].split(' ')[1].to_i
            nomMeilleurScore = Label.new()
            nomMeilleurScore.set_markup("<big>Meilleur score : #{@meilleurScore} points</big>")
            tableMalus.attach(nomMeilleurScore,0,1,6,8)
        end

        @erreur = Button.new().set_label("Erreur")
        @erreur.signal_connect('clicked'){
            label = @mylabel.label
            label = label.gsub("<big>", "")
            label = label.gsub("</big>", "")
            @nomMalus.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b>Malus à #{label} </b></span>")
            @malus.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b>60 points perdus</b></span> <span face=\"Roboto Condensed, Bold 10\" size=\"large\">\n\n\nSuite à la demande\n\nd'affichages des erreurs</span>")
            @partie.grille.evidenceCaseErreur
            @partie.score.malusErreur
        }

        tableMalus.attach(@erreur,0,1,8,10)

        conteneurCentral.attach(tableMalus, 4, 5, 0, 1)
        @conteneurPrincipal.attach(conteneurCentral, 0, 1, 1, 8)

        # Combinaison
        tableCombinaison = Table.new(1, 10, true)
        conteneurErreur = Box.new(:horizontal,2)
        conteneurCombis = Table.new(3, 1, false)
        conteneurCombiLigne = Table.new(1, 10, true)
        conteneurCombiColonne = Table.new(1, 10, true)

        # définition des labels
        nomCombiLigne = Label.new()
        nomCombiLigne.set_markup("<big>Combinaison ligne : </big>")
        nomCombiColonne = Label.new()
        nomCombiColonne.set_markup("<big>Combinaison colonne : </big>")

        separateurHorizontal = Separator.new(:horizontal)

        # remplissage tableau astuce colonne
        conteneurCombiLigne.attach(nomCombiLigne,0,2,0,1)
        conteneurCombiLigne.attach(@combiLigne,2,10,0,1)
        # remplissage tableau astuce ligne
        conteneurCombiColonne.attach(nomCombiColonne,0,2,0,1)
        conteneurCombiColonne.attach(@combiColonne,2,10,0,1)
        # remplissage tableau astuces
        conteneurCombis.attach(conteneurCombiLigne,0,1,0,1)
        conteneurCombis.attach(separateurHorizontal,0,1,1,2)
        conteneurCombis.attach(conteneurCombiColonne,0,1,2,3)
        #remplissage de tout les conteneurs
        tableCombinaison.attach(conteneurCombis,0,10,0,1)
        @conteneurPrincipal.attach(tableCombinaison, 0, 1, 8, 9)
        # Outils
        tableOutils = Table.new(1, 7)

        @gomme = Button.new().set_label("GOMME")
        @aide = Button.new().set_label("AIDE")

        @gomme.signal_connect('clicked'){
            if(@caseCourante != nil)
                @caseCourante.set_sensitive(true)
                @caseCourante.style_context.remove_provider(@css_vert)
                @caseCourante.activeCrayon = true
                @crayon.set_sensitive(true)
                @caseCourante.set_label("")
                @gestionneurTechnique.majTechnique(@partie.grille)
                @sauvegarde.majCoup(@partie.grille().tabCase)
                if(@partie.aideVisuelle)
                    @caseCourante.aideVisuelle(@partie.grille.tabCase)
                end

                @caseCourante = nil
            end
        }

        @aide.signal_connect('clicked'){
            label = @mylabel.label
            label = label.gsub("<big>", "")
            label = label.gsub("</big>", "")
            @nomMalus.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b>Malus à #{label} </b></span>")
            @malus.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b>20 points perdus</b></span> <span face=\"Roboto Condensed, Bold 10\" size=\"large\">\n\n\nSuite à la demande d'aide\n\nde premier niveau</span>")
            @partie.grille.astucesTrouveCase
            @partie.score.malusAide1
        }

        @stylo.signal_connect('clicked'){
            @boolCrayon = false
        }

        @crayon.signal_connect('clicked'){
            if(@caseCourante != nil)
                @boolCrayon = true
            end
        }

        nbCote = 3
        @tableauChiffre = Array.new(9)
        1.upto(9) { |i|
            @tableauChiffre[i] = Button.new().set_label(i.to_s)

            @tableauChiffre[i].signal_connect('clicked'){

                if @caseCourante != nil
                    if @boolCrayon == true
                        if @caseCourante.label() == nil || @caseCourante.label == ""
                            @caseCourante.set_label(i.to_s)

                         elsif @caseCourante.label().include?(i.to_s)
                            if @caseCourante.label().length == 1
                                @caseCourante.set_label("")
                            else
                                s = @caseCourante.label()
                                s = s.sub(i.to_s, "")
                                s = s.gsub("\n", "")

                                tabBrouillon = s.chars
                                ch = ""
                                tabBrouillon.each_index{ |i|
                                    if (i%3) == 0  && i != 0
                                        ch += "\n"
                                    end
                                    ch += tabBrouillon[i]
                                }
                                @caseCourante.set_label(ch)
                            end

                        else
                            taille = @caseCourante.label().length
                            if taille == 3 || taille == 7
                                @caseCourante.set_label(@caseCourante.label()+"\n"+i.to_s)
                            else
                                @caseCourante.set_label(@caseCourante.label()+i.to_s)
                            end
                        end

                        if @caseCourante.label().length > 0
                            @caseCourante.activeStylo = true
                            @stylo.set_sensitive(true)
                        end
                    else
                        @partie.grille.retireCSS
                        @caseCourante.set_sensitive(true)
                        @caseCourante.style_context.remove_provider(@css_vert)
                        @caseCourante.set_label(i.to_s)
                        if(@partie.aideVisuelle)
                            @caseCourante.aideVisuelle(@partie.grille.tabCase)
                        end

                        @caseCourante.activeCrayon = false
                        @caseCourante.activeStylo = false
                        @stylo.set_sensitive(false)
                        @combiColonne.set_label("")
                        @combiLigne.set_label("")
                        @caseCourante = nil

                        if @partie.grille.estCorrect()
                            stopChrono
                            finPartie
                        end
                    end
                    @sauvegarde.majCoup(@partie.grille().tabCase)
                end
            }
        }

        tableNum = Table.new(3, 3)
        numLigne = 0
        numColonne = 0

        1.upto(9) { |i|
            tableNum.attach(@tableauChiffre[i], numColonne, numColonne+1, numLigne, numLigne+1)
            numColonne +=1
            if numColonne == 3
                numColonne = 0
                numLigne += 1
            end
        }

        tableOutils.attach(@crayon, 0, 1, 0, 1)
        tableOutils.attach(@stylo, 1, 2, 0, 1)
        tableOutils.attach(tableNum, 2, 5, 0, 1)
        tableOutils.attach(@gomme, 5, 6, 0, 1)
        tableOutils.attach(@aide, 6, 7, 0, 1)

        @conteneurPrincipal.attach(tableOutils, 0, 1, 9, 10)

        @kakuro.add(@conteneurPrincipal)

        afficheToi

        if @partie.grille.estCorrect()
            stopChrono
            finPartie
        end
    end

    # Méthode de focus
    #
    # ==== Paramètres
    #
    # * +conteneurCentral+ - conteneur de la fenetre de jeu
    # * +grille+ - table des widgets de la fênetre de jeu
    #
    # ==== Exemples
    #   grilleGtk = Table.new(8, 8)
    #   # Conteneur central
    #    conteneurCentral = Table.new(1, 5, true)
    #   @pause = Button.new().set_label('Pause')
    #
    #    @pause.signal_connect('clicked'){
    #       conteneurCentral.remove(grilleGtk)
    #       focus(conteneurCentral, grilleGtk)
    #       @kakuro.set_sensitive(false)
    #       stopChrono
    #    }
    def focus(conteneurCentral, grille)
        # initialisation de la fenetre
        popFocus = Window.new
        popFocus.set_title("Pause")
        popFocus.set_window_position(:center_always)
        popFocus.border_width=10
        popFocus.set_default_size(100,75)
        popFocus.set_resizable(false)
        tableauBouton = Gtk::Table.new(3,2,true)

        # ajout du tableau à la fenetre
        popFocus.add(tableauBouton)

        # création des boutons de la fenetre pop up
        retour = Button.new().set_label("Retour")
        texte = Label.new().set_label("Vous avez mis pause à la partie en cours...")

        # ajout des boutons au tableau
        tableauBouton.attach(texte,0,2,0,2)
        tableauBouton.attach(retour,1,2,2,3)

        popFocus.signal_connect('destroy'){

            conteneurCentral.attach(grille,1, 4, 0, 1)
            @kakuro.set_sensitive(true)
            popFocus.close()
            startChrono
        }
        # connexion des signaux
        retour.signal_connect('clicked'){

            conteneurCentral.attach(grille,1, 4, 0, 1)
            @kakuro.set_sensitive(true)
            popFocus.close()
            startChrono
        }

        #affichage de la fenetre pop up
        popFocus.show_all
    end # Fin de méthode

    # Méthode d'affichage
    #
    #
    # ==== Exemples
    #  #on affiche tout
    #   afficheToi()
    def afficheToi
        @kakuro.show_all
    end

    # Méthode qui permet de lancer la fenêtre
    #
    #
    # ==== Exemples
    #   #Lancement du jeu
    #   mp = MenuPrincipal.new
    #   mp.chargerMenuPrincipal
    #   mp.lanceToi
    def lanceToi
        afficheToi
        Gtk.main
    end

    # Méthode de changement de niveau d'affichage
    #
	# ==== paramètres
    #
	# * +oldTable+ - ancienne table à supprimer de l'interface
    # * +newTable+ - nouvelle table à faire afficher sur l'interface
	# ==== Exemples
	# => presentation = Table.new(12, 1)
    # => presCopie = Table.new(6,2,true)
    # => retour(presCopie,presentation)
    def retour(oldTable,newTable)
        if(oldTable != nil) then
            @kakuro.remove(oldTable)
        end
        if(newTable != nil) then
            @kakuro.add(newTable)
        end
    end

    # Méthode de lancement du chrono
    #
    #
	# ==== Exemples
	#  startChrono
    def startChrono
        @accumulated ||= 0
        @elapsed = 0
        @start = Time.now
        @timer_stopped = false
        @timer = Thread.new do
            until @timer_stopped do
                sleep(0.1)
                tick unless @timer_stopped
                if @partie != nil
                    @partie.chrono = @accumulated + @elapsed
                end
            end
        end
    end

    # Méthode d'arrêt du chrono
    #
    #
    # ==== Exemples
    #  stopChrono
    def stopChrono
        @timer_stopped = true
        @accumulated += @elapsed
        @partie.chrono = @accumulated
    end

    # Méthode de reinitialisation du chrono
    #
    # ==== Exemples
    #   resetChrono
    def resetChrono
        stopChrono
        @accumulated, @elapsed = 0, 0
        @mylabel.set_markup("<big>0:00:00.0</big>")
    end

    # coup d'horloge
    #
    # ==== Exemples
    #   tick unless @timer_stopped
    def tick
        @elapsed = Time.now - @start
        time = @accumulated + @elapsed
        h = sprintf("%02i", (time.to_i / 3600))
        m = sprintf("%02i", ((time.to_i % 3600) / 60))
        s = sprintf("%02i", (time.to_i % 60))
        mt = sprintf("%1i", ((time - time.to_i)*10).to_i)
        @mylabel.set_markup("<big>#{h}:#{m}:#{s}:#{mt}</big>")
    end

    # remplissage de la grille de jeu à partir d'une grille d'un fichier déjà existant
    #
    #
    # ==== paramètres
    #
    # * +grilleGtk+ - table à laquelle on va attacher les boutons
    #
    # ==== Exemples
    # => grille = Table.new(@nombreDeLignes,@nombreDeCases)
    # => @partie = @partie = @sauvegarde.charger("../Sauvegarde/facile/fichier_1_2020-04-11_16-50-50")
    # => chargerGrille(grille)
    def chargerGrille(grilleGtk)
        numColonne = 0
        numLigne = 0

        @sauvegarde.majCoup(@partie.grille.tabCase)

        @partie.grille.tabCase.each do |n|
            n.each do |cell|

                if cell.estCaseNombre?
                    cell.signal_connect('clicked'){
                        @kakuro.set_sensitive(false)
                        @gestionneurTechnique.donneTechnique(cell, @partie.grille.tabCase, @kakuro)
                    }

                elsif cell.jouable?  # case jouable
                    if(cell.saisieUtilisateur() != 0) then
                        cell.set_label(cell.saisieUtilisateur().to_s)
                    end

                    interBouton = cell
                    cell.signal_connect('clicked'){
                        if @caseCourante != nil
                            @caseCourante.set_sensitive(true)
                            @caseCourante.style_context.remove_provider(@css_vert)
                            @boolCrayon = false
                        end
                        @partie.grille.retireCSS
                        @partie.grille.evidenceCaseErreurNo
                        interBouton.set_sensitive(false)
                        interBouton.style_context.add_provider(@css_vert)
                        @caseCourante = interBouton
                        majBtnOutils
                        @gestionneurTechnique.majTechnique(@partie.grille)
                        @caseCourante.donneCombinaisons(@partie.grille.tabCase, self)
                      }

                end
                grilleGtk.attach(cell, numColonne, numColonne+1, numLigne, numLigne+1)
                numColonne += 1
            end
            numLigne += 1
            numColonne = 0
        end
        if @partie.aideVisuelle
            @partie.grille.majAideVisuelle
        end
        @partie.marshal_dump(@partie.nomPartie())
    end

    # remplissage de la grille de jeu à partie du fichier passé en paramètre
    #
    #
    # ==== paramètres
    #
    # * +grilleGtk+ - table à laquelle on va attacher les boutons
    # * +nomGrille+ - chemin d'accès à la grille que l'on souhaite charger, les grilles sont situées dans les dossiers (facile, moyen, difficile)
    #
    # ==== Exemples
    # => grille = Table.new(@nombreDeCases,@nombreDeCases)
    # => @partie = Partie.creer("unNom")
    # => @partie.setDifficulte("uneDifficulte")
    # => @partie.setNiveau("niveau 1")
    # => numeroNiveau = @partie.niveau().split(' ')[1]
    # => remplirGrille(grille,"#{@partie.difficulte}/grille#{numeroNiveau}")
    def remplirGrille(grilleGtk,nomGrille)
        laGrille = Grille.creer(nomGrille)
        numLigne = 0
        numColonne = 0

        #Place les CaseNombre dans le tableau @tabCaseNombre
        laGrille.tabCase.each do |n|
            n.each do |cell|
                if cell.estCaseNombre?
                    cell.signal_connect('clicked'){
                        @kakuro.set_sensitive(false)
                        @gestionneurTechnique.donneTechnique(cell, laGrille.tabCase, @kakuro)
                        label = @mylabel.label
                        label = label.gsub("<big>", "")
                        label = label.gsub("</big>", "")
                        @nomMalus.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b>Malus à #{label} </b></span>")
                        @malus.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b>40 points perdus</b></span> <span face=\"Roboto Condensed, Bold 10\" size=\"large\">\n\n\nSuite à la demande d'aide\n\nde technique</span>")
                        @partie.score.malusAide2
                    }

                elsif cell.jouable?
                    interBouton = cell
                    cell.signal_connect('clicked'){
                        if @caseCourante != nil
                            @caseCourante.set_sensitive(true)
                            @caseCourante.style_context.remove_provider(@css_vert)
                            @boolCrayon = false
                        end
                        laGrille.retireCSS
                        laGrille.evidenceCaseErreurNo
                        interBouton.set_sensitive(false)
                        interBouton.style_context.add_provider(@css_vert)
                        @caseCourante = interBouton
                        majBtnOutils
                        @gestionneurTechnique.majTechnique(laGrille)
                        @caseCourante.donneCombinaisons(laGrille.tabCase, self)
                    }
                end

                grilleGtk.attach(cell, numColonne, numColonne+1, numLigne, numLigne+1)
                numColonne+=1
            end
            numLigne+=1
            numColonne=0
        end
        @partie.grille = laGrille
        @partie.enCours = true
        @sauvegarde.majCoup(@partie.grille().tabCase)
        @partie.marshal_dump(@partie.nomPartie())
        @gestionneurTechnique.majTechnique(@partie.grille)
    end

    # Méthode pour recommencer la partie
    #
    #
    # ==== Exemples
    #   @recommencerPartie = Button.new().set_label("Recommencer la partie")
    #   @recommencerPartie.signal_connect('clicked'){
    #       recommencerLaPartie()
    #       resetChrono
    #       startChrono
    #       if(@caseCourante != nil)
    #           @caseCourante.set_sensitive(true)
    #           @caseCourante.style_context.remove_provider(@css_vert)
    #           @caseCourante.set_label("")
    #           @caseCourante = nil
    #       end
    #       @sauvegarde.reinitialisationListes()
    #   }
    def recommencerLaPartie

        @partie.grille.tabCase.each do |n|
            n.each do |cell|
                if(cell != nil && cell.jouable?)
                    cell.set_label("")
                end
            end
        end
        if @partie.aideVisuelle
            @partie.grille.majAideVisuelle
        end
        @partie.grille.evidenceCaseErreurNo()
    end

    # mise à jour des combinaisons pour une case donnée
    #
    # ==== paramètres
    #
    # * +vertical+ - booleen
    # * +horizontal+ - booleen
    #
    # ==== Exemples
    #
    #   self.majCombi(nil, true)
    def majCombi(vertical, horizontal)

        if vertical!=nil

            if vertical[0] == [0]
                @combiColonne.set_label("");
            else
                combiColonne = ""
                vertical.each{ |x|
                    x.each{ |y|
                        combiColonne += " " + y.to_s
                    }
                    combiColonne += "    "
                }
                @combiColonne.set_markup("<big>"+combiColonne+"</big>")
            end
        end

        if horizontal!=nil
            if horizontal[0] == [0]
                @combiLigne.set_label("");
            else
                combiLigne = ""
                horizontal.each{ |x|
                    x.each{ |y|
                        combiLigne += " " + y.to_s
                    }
                    combiLigne += "    "
                }
                @combiLigne.set_markup("<big>"+combiLigne+"</big>")
            end
        end
    end

    # mise à jour des outils selon que le crayon soit activé ou non
    #
    #
    # ==== Exemples
    #
    #   self.majBtnOutils
    def majBtnOutils
        if(@caseCourante.activeStylo)
            @stylo.set_sensitive(true)
        else
            @stylo.set_sensitive(false)
        end

        if(@caseCourante.activeCrayon)
            @crayon.set_sensitive(true)
        else
            @crayon.set_sensitive(false)
        end
    end

    # méthode de déplacement avec les flèches directionnelles
    #
    # ==== Paramètres
    #
    # * +nouvCaseCourante+ - instance de la classe BtnCaseJouable
    #
    # ==== Exemples
    #
    #   actionDirection(@partie.grille.tabCase[1][3])
    def actionDirection (nouvCaseCourante)
        @partie.grille.retireCSS
        @partie.grille.evidenceCaseErreurNo
        @caseCourante.set_sensitive(true)
        @caseCourante.style_context.remove_provider(@css_vert)
        @caseCourante = nouvCaseCourante
        @caseCourante.set_sensitive(false)
        @caseCourante.style_context.add_provider(@css_vert)
        @caseCourante.donneCombinaisons(@partie.grille.tabCase, self)
        majBtnOutils
        @boolCrayon = false
    end

    # PopUp de fin de partie
    #
    #
    # ==== Exemples
    #
    #   finPartie()
    def finPartie
        # initialisation de la fenetre
        popFin = Window.new
        popFin.set_title("Fin de la partie")
        popFin.set_window_position(:center_always)
        popFin.border_width=10
        popFin.set_default_size(75,75)
        popFin.set_resizable(false)
        pres = Table.new(10,2,true)
        # Désactiver les boutons
        @gomme.set_sensitive(false)
        @crayon.set_sensitive(false)
        @aide.set_sensitive(false)
        @unDo.set_sensitive(false)
        @reDo.set_sensitive(false)
        @pause.set_sensitive(false)
        @nouvellePartie.set_sensitive(false)
        @erreur.set_sensitive(false)
        @recommencerPartie.set_sensitive(false)
        1.upto(9){ |i|
            @tableauChiffre[i].set_sensitive(false)
        }

        # Désactiver la grille
        @partie.grille.tabCase.each{ |n|
            n.each{ |cell|
                cell.set_sensitive(false)
            }
        }

        if @partie.enCours
            label = @mylabel.label
            label = label.gsub("<big>", "")
            label = label.gsub("</big>", "")
            chrono = label.split(":")
            i = (chrono[0].to_i*3600) + (chrono[1].to_i*60) + chrono[2].to_i
            @partie.score.calculScoreFinal(i)
            @partie.enCours = false
            @partie.marshal_dump(@partie.nomPartie())
            @partie.finDePartie()
        end

        # création des boutons de la fenetre pop up
        voirGrille =  Button.new().set_label("Revoir la grille")
        quitter = Button.new().set_label("Quitter")
        # connexion des signaux
        voirGrille.signal_connect('clicked'){
            @kakuro.set_sensitive(true)
            popFin.close()
        }
        quitter.signal_connect('clicked'){
            onDestroy
            popFin.close()
        }
        pres.attach(getLabelX("Felicitations : vous avez terminé la partie", false), 0, 2, 1, 3)
        pres.attach(getLabelXX("Score : #{@partie.score.nb_score} point(s)"), 0, 2, 3, 6)

        if @partie.score.nb_score <= @meilleurScore
            pres.attach(getLabelLarge("Meilleur score : #{@partie.score.nb_score} point(s)"), 0, 2, 6, 7)
        else
            pres.attach(getLabelLarge("Vous avez établi le nouveau meilleur score"), 0, 2, 6, 7)
        end

        pres.attach(voirGrille, 0, 1, 8, 10)
        pres.attach(quitter, 1, 2, 8, 10)
        popFin.add(pres)
        #affichage de la fenetre pop up
        popFin.show_all
    end

    # change la grille selon que l'on fasse un undo ou un redo
    #
    # ==== paramètres
    #
    # * +uneGrille+ - une grille qui servira au undo ou au redo
    #
    # ==== Exemples
    #
    # => changementGrille(@sauvegarde.redo()) ou changementGrille(@sauvegarde.undo())
    def changementGrille(uneGrille)
        index = 0
        if(uneGrille != nil) then # verification que la grille de Bouton ne soit pas nil par précaution mais normalement la variable uneGrille n'est jamais nil
            @partie.grille.tabCase.each_index{|i|
                @partie.grille.tabCase[i].each_index{|j|
                    if( uneGrille[index].jouable?  && uneGrille[index].label() != nil )
                        @partie.grille.tabCase[i][j].set_label(uneGrille[index].label())
                    elsif(@partie.grille.tabCase[i][j].label() != nil && @partie.grille.tabCase[i][j].jouable? ) # on efface la case à undo/redo
                        @partie.grille.tabCase[i][j].set_label("")
                    end
                    index += 1
                }
            }
        end
    end
end
