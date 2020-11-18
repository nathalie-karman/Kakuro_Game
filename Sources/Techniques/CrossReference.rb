require 'gtk3'
include Gtk

class CrossReference
	# Technique CrossReference : les objets de cette classe sont caractérisés par :
	# 
	# * @nom => leur nom
	# * @description => la description de leur technique

	# Méthode d'initialisation de la classe CrossReference
	def initialize
		@nom = "Technique : Cross Reference"
	end

	# Methode qui permet de vérifier si la technique correspond au contexte de la case nombre
	#
	# ==== Paramètres
	#
	# * +caseIndication+ - la caseIndication à tester
	# * +tabCase+ - la grille du jeu
	def correspond?(caseIndication, tabCase)
		if caseIndication.valeurV != 0
			if !caseIndication.etatV
				@description = 
				"Rechercher les intersections (croisement
de deux pistes) sur la colonne

Pour chaque intersection, comparer les
combinaisons des la ligne et de la colonne

Les valeurs présentes dans les combinaisons 
des deux pistes sont des solutions possible
pour l'intersection. "
				return true
			end
		end

		if caseIndication.valeurH != 0
			if !caseIndication.etatH
				@description = 
				"Rechercher les intersections (croisement
de deux pistes) sur la ligne

Pour chaque intersection, comparer les
combinaisons des la ligne et de la colonne

Les valeurs présentes dans les combinaisons 
des deux pistes sont des solutions possibles
pour l'intersection. "
				return true
			end
		end
		# Mettre à jour la direction
		return false
	end

	# Méthode d'affichage de la technique en PopUp
	def afficheTechnique(kakuro)
		affichePopUpTechnique(@nom, @description, kakuro)
	end

	# Méthode de afficheTechnique
	def affichePopUpTechnique(nom, description, kakuro)
	    # initialisation de la fenetre
	    popTechnique = Window.new
	    popTechnique.set_title(nom)
	    popTechnique.set_window_position(:center_always)
	    popTechnique.border_width=5
	    popTechnique.set_default_size(75,75)
	    popTechnique.set_resizable(false)
	    pres = Table.new(10,2,true)

	    tabDescription = Table.new(10, 5, true)
	    texte = Label.new()
	    texte.set_markup("<big>#{description}</big>")

	    description = Label.new()
	    description.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"large\"><b>Description</b></span>")
	    
	    texteExemple = Label.new()
	    texteExemple.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"large\"><b>Exemple d'intersection</b></span>")
	    
	    exemple = Table.new(5, 5)
	    tableau = Array.new(4){Array.new(4)}
	    css_provider = Gtk::CssProvider.new
        css_provider.load(data: <<-CSS)
        button {
            background-color: blue;
            background-image: none;
        }
        CSS
	   	0.upto(3){|i|
	   		if(i != 2)
		   		tableau[2][i] = Button.new
		   		tableau[2][i].set_size_request(30,30)
		   		tableau[2][i].set_sensitive(false)
		   		exemple.attach(tableau[2][i], i, i+1, 2, 3)
		   	end
	   	} 
	   	0.upto(3){|i|
	   		if(i != 2)
		   		tableau[i][2] = Button.new
		   		tableau[i][2].set_size_request(30,30)
		   		tableau[i][2].set_sensitive(false)
		   		exemple.attach(tableau[i][2], 2, 3, i, i+1)
		   	end
	   	} 
	   	tableau[2][2] = Button.new
	   	tableau[2][2].set_size_request(30,30)
        tableau[2][2].style_context.add_provider(css_provider) 
        tableau[2][2].set_sensitive(false)
        exemple.attach(tableau[2][2], 2, 3, 2, 3)

        tabDescription.attach(description, 0, 3, 1, 2)
        tabDescription.attach(texte, 0, 3, 2, 10)
        tabDescription.attach(texteExemple, 3, 5, 1, 2)
        tabDescription.attach(exemple, 3, 5, 3, 10)

        # création des boutons de la fenetre pop up
	    retour = Button.new().set_label("Retour")

	    pres.attach(tabDescription, 0, 2, 0, 8)
        pres.attach(retour, 0, 2, 9, 10)
	    # ajout du tableau à la fenetre
	    popTechnique.add(pres)

	    # ajout des boutons au tableau
	    popTechnique.signal_connect('destroy'){
	        kakuro.set_sensitive(true)
	        popTechnique.close()
	    }
	    # connexion des signaux
	    retour.signal_connect('clicked'){
	        kakuro.set_sensitive(true)
	        popTechnique.close()
	    }
	    #affichage de la fenetre pop up
	    popTechnique.show_all
	end # Fin de méthode
end