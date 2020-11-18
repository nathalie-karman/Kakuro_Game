class Sauvegarde
    #+listeRedo+ - liste contenant les grilles qui ont été annulées au cours de la partie
	attr_accessor :listeRedo
	#+listeUndo+ - liste contenant les grilles qui peuvent être annulées (les derniers coups effectués)
	attr_accessor :listeUndo

    private_class_method :new

	#:notnew:
    def initialize()
        @listeRedo= Array.new()
		@listeUndo= Array.new()

		# fichiers des classements
        unless File.directory?('classement')
            Dir.mkdir("classement",0777)
        end
        unless File.exist?('classement/global.txt')
            File.open('classement/global.txt','w')
        end
        unless File.exist?('classement/facile.txt')
              File.open("classement/facile.txt",'w')
        end
        unless File.exist?('classement/moyen.txt')
              File.open("classement/moyen.txt",'w')
        end
        unless File.exist?('classement/difficile.txt')
              File.open("classement/difficile.txt",'w')
        end
		unless File.directory?('Sauvegarde')
				Dir.mkdir("Sauvegarde",0777)
		end
		unless File.directory?('Sauvegarde/facile')
        	Dir.mkdir('Sauvegarde/facile',0777)
        end
        unless File.directory?('Sauvegarde/moyen')
            Dir.mkdir('Sauvegarde/moyen',0777)
        end
        unless File.directory?('Sauvegarde/difficile')
            Dir.mkdir('Sauvegarde/difficile',0777)
        end

    end

	# constructeur
    def Sauvegarde.debuter()
        new()
    end

    # Méthode qui, à partir d'un nom de fichier passé en paramètre, récupère la sauvegarde correspondante et instancie un objet Partie
    # Elle renvoie une copie de l'objet instancié (un "pointeur" sur l'adresse qui contient l'objet)
	#
	# ==== paramètres
	# * +nomFichier+ - nom du fichier à aller charger dans le dossier Sauvegarde/{difficulte}/nomFichier
	#
	# ==== Exemples
	#
	# => sauv = Sauvegarde.debuter ()
	# => partie = Partie.creer("nomJoueur")
    # => partie.setNiveau("niveau 1");
    # => partie.setDifficulte("facile");
    # => partie.nomPartie = "#{partie.joueur().downcase()}_#{partie.niveau().split(' ')[1]}_#{Date.today.to_s}"
    # => partie.marshal_dump(partie.nomPartie())
	# => sauv.charger(partie.nomPartie())
    def charger(nomFichier)

        tabPartieChargee = Array.new()
		begin
	        if File.exists?(nomFichier) then
	            File.open(nomFichier){ |f|
	                tabPartieChargee = Marshal.load(f)
	            }
	            #on crée une nouvelle partie avec les objets récupérés
	            partie = Partie.creer(tabPartieChargee[0],tabPartieChargee[7],tabPartieChargee[8])
				partie.grille = tabPartieChargee[1]
	            partie.date = tabPartieChargee[2]
	            partie.score = tabPartieChargee[3]
	            partie.chrono = tabPartieChargee[4]
	            partie.grilleValide = tabPartieChargee[5]
				partie.nomPartie = tabPartieChargee[6]
	            partie.niveau = tabPartieChargee[7]
	            partie.difficulte = tabPartieChargee[8]
				partie.aideVisuelle = tabPartieChargee[9]
				partie.enCours = tabPartieChargee[10]
			end
	    rescue
            raise("\n[ERREUR]:La sauvegarde #{nomFichier} n'a pas pu être lu ou n'existe pas\n")
        end

        # renvoie un tableau "empty" si il n'a pas trouvé le nom du fichier
        return partie.dup    # retourne un "pointeur" sur l objet instancié ici,
                             # il n'y a pas de problème puisque, à priori on ne fera pas appel à "partie" (à voir si meilleure idée faire proposition...)
    end                      # incremental garbage collection/garbage collector fait son job


    # Méthode qui récupère la liste des scores et l'affiche
    # faire un algo qui fait un classement par rapport aux scores obtenus, sinon affiche dans l'ordre chronologique de sauvegarde des scores
	#
	# ==== paramètres
	# * +difficulte+ - difficulté de jeu (facile, moyen, difficile)
	#
	# ==== Exemples
	#
	# => sauv = Sauvegarde.debuter ()
	# => tab = sauv.chargerScores("facile".downcase)
    def chargerScores(difficulte)
        tableauScore = Array.new()
		begin
	        file = File.open("classement/#{difficulte}.txt")
			if(!File.zero?(file)) # si le fichier est pas vide
	        	file_data = file.readlines.map(&:chomp).pop.split(";")
	        	file_data.each {|joueurEtScore|
					tableauScore.append(joueurEtScore);
	        	}
			end
		rescue
		  raise "Erreur lecture du fichier classement \"classement/#{difficulte}.txt\""
		ensure
		  file.close
		end
        return tableauScore
    end

    # Méthode de reinitialisation des scores
    def reinitialiseScore(difficulte)
    	file = File.open("classement/#{difficulte}.txt")
		file.close
		File.unlink(file)
        File.open("classement/#{difficulte}.txt",'w')
    end

    # Met à jour le tableau des états de la grille au fur et à mesure
    # prend en paramètre la partie qui contient la grille
	#
	# ==== paramètres
	# * +lagrille+ - grille de jeu
	#
	# ==== Exemples
	#
	# => sauv = Sauvegarde.debuter ()
	# => partie = Partie.creer("unNom")
	# => sauv.majCoup(partie.grille())
    def majCoup(lagrille)
		unTableau = Array.new()
		lagrille.each_index{ |uneLigne|
			lagrille[uneLigne].each_index{ |uneColonne|
				uneCase = lagrille[uneLigne][uneColonne]
				if (uneCase != nil) then
					if(uneCase.estCaseNombre? ) then # si on a une case indication
						unTableau << BtnCaseIndication.creer(uneCase.ligne(), uneCase.colonne(), uneCase.valeurH(), uneCase.valeurV())
					elsif(uneCase.estCaseVide? )# si on a une case non jouable
						unTableau << BtnCaseNonJouable.creer(uneCase.ligne(), uneCase.colonne())
					elsif( uneCase.jouable? ) #si on a une case jouable
						uneCaseTemporaire = BtnCaseJouable.creer(uneCase.ligne(), uneCase.colonne(), uneCase.laBonneReponse(), uneCase.saisieUtilisateur())
						if(uneCase.saisieUtilisateur() != nil && uneCase.saisieUtilisateur() != 0)

							uneCaseTemporaire.set_label(uneCase.saisieUtilisateur().to_s)
						end
						unTableau << uneCaseTemporaire
					end
				end
			}
		}
		@listeUndo << unTableau
        @listeRedo.clear() # si l utilisateur écrit, on met à zéro la table des redo
    end

	 # methode de reinitialisation des tableaux de undo/redo
	 # utilisée lorsque l'on recommence la partie ou lorsque l'on lance une nouvelle partie, on efface la liste des undo/redo
	 def reinitialisationListes()
		 @listeRedo.clear()
		 @listeUndo.clear()
	 end

	# Undo : Permet de rejouer un coup vers l'arrière
 	# ==== Exemples
 	#
 	# => sauv = Sauvegarde.debuter ()
 	# => sauv.undo()
    def undo()
		if(@listeUndo.length > 1) # la liste des undo contient toujours en position .first() la grille de base du jeu
	    	@listeRedo << @listeUndo.pop()  #on ajoute au tableau redo, la grille qui vient d'être "annulée"
			return @listeUndo.last()
		end
		return @listeUndo.first()
    end

    # Redo: Permet de rejouer un coup vers l'avant
	#
	# ==== Exemples
	#
	# => sauv = Sauvegarde.debuter ()
	# => sauv.redo()
    def redo()
        if(@listeRedo.length > 0)
            @listeUndo << @listeRedo.pop()
        end
		return @listeUndo.last()
    end
end
