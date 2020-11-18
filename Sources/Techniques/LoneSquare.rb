require 'gtk3'
include Gtk

class LoneSquare
	# Technique LoneSquare : les objets de cette classe sont caractérisés par :
	# 
	# * @nom => leur nom
	# * @description => la description de leur technique

	# Méthode d'initialisation de la classe LoneSquare
	def initialize
		@nom = "Technique : Lone Square"
	end

	# Methode qui permet de vérifier si la technique correspond au contexte de la case nombre
	#
	# ==== Paramètres
	#
	# * +caseIndication+ - la caseIndication à tester
	# * +tabCase+ - la grille du jeu
	def correspond?(caseIndication, tabCase)
		caseIndication.mathsBon(tabCase)
		if caseIndication.valeurV != 0
			if !caseIndication.etatV
				if (caseIndication.nbCasesColonne(tabCase) - caseIndication.nbCasesRempliesV(tabCase)) == 1
					if (caseIndication.sommeV < caseIndication.valeurV) && ((caseIndication.valeurV - caseIndication.sommeV) < 10)
						@description = 
						"Additionner les valeurs en colonne

Soustraire cette somme à l'indice colonne

Le résultat est la réponse pour la case restante"
						return true
					end
				end
			end
		end

		if caseIndication.valeurH != 0
			if !caseIndication.etatH
				if (caseIndication.nbCasesLigne(tabCase) - caseIndication.nbCasesRempliesH(tabCase)) == 1
					if (caseIndication.sommeH < caseIndication.valeurH) && ((caseIndication.valeurH - caseIndication.sommeH) < 10)
						@description = 
						"Additionner les valeurs en ligne

Soustraire cette somme à l'indice ligne

Le résultat est la réponse pour la case restante"
						return true
					end
				end
			end
		end

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
	    pres = Table.new(6,2,true)

	    tabDescription = Table.new(5, 1, true)
	    
	    texte = Label.new()
	    texte.set_markup("<big>#{description}</big>")

	    description = Label.new()
	    description.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"large\"><b>Description</b></span>")

	    tabDescription.attach(description, 0, 1, 0, 1)
        tabDescription.attach(texte, 0, 1, 2, 5)

	    # création des boutons de la fenetre pop up
	    retour = Button.new().set_label("Retour")
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

	    pres.attach(tabDescription, 0, 2, 0, 4)
        pres.attach(retour, 1, 2, 5, 6)
        popTechnique.add(pres)
	    #affichage de la fenetre pop up
	    popTechnique.show_all
	end # Fin de méthode
end