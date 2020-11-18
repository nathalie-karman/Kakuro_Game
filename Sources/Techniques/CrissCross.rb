require 'gtk3'
include Gtk

class CrissCross
	# Technique CrissCross : les objets de cette classe sont caractérisés par :
	# 
	# * @nom => leur nom
	# * @description => la description de leur technique

	# Méthode d'initialisation de la classe CrissCross
	def initialize
		@nom = "Technique : Criss Cross Arithmétique"
	end

	# Methode qui permet de vérifier si la technique correspond au contexte de la case nombre
	#
	# ==== Paramètres
	#
	# * +caseIndication+ - la caseIndication à tester
	# * +tabCase+ - la grille du jeu
	def correspond?(caseIndication, tabCase)
		
        xMax = 0
		yMax = 0
		xCase = 0
		yCase = 0
		tabCase.each do |n|
			yMax = 0
			n.each do |cell|
                if cell.equal?(caseIndication) then
                    xCase = xMax
					yCase = yMax
				end
                yMax = yMax + 1
            end
			xMax = xMax + 1
		end

		#xCase = xCase+1

		# puts tabCase.respond_to?(:[])
		# puts tabCase[yCase].respond_to?(:[])
		# puts yCase
		# puts xCase
		# puts tabCase[yCase][xCase]

		if xCase==0 && yCase==0 then
			puts
			puts "Erreur là"
			puts
            return false
		end
		
		descriptionCC = 
"On peut déduire la valeur de la case en dehors de la zone jouable 2x2 
avec un peu de maths.
		
Tout d'abord, on additionne les valeurs des cases indications horizontales, 
puis on soustrait l'addition des cases indications verticales.
		
Le résultat final de la valeur de la case cette case en dehors du carré 2x2 est 
la valeur absolue de ce calcul."

		if (yMax >= yCase) && ( xMax >= xCase+2 ) && ((xCase-1) >= 0) && ((yCase-3) >= 0) then
			if
				tabCase[xCase+1][yCase].jouable?() &&
				tabCase[xCase+1][yCase-1].jouable?() &&
				tabCase[xCase+1][yCase-2].jouable?() &&
				tabCase[xCase+1][yCase-3].estCaseNombre?() &&

				tabCase[xCase][yCase-1].jouable?() &&
				tabCase[xCase][yCase-2].jouable?() &&
				tabCase[xCase][yCase-3].estCaseNombre?() &&
				
				tabCase[xCase-1][yCase-1].estCaseNombre?() &&
				tabCase[xCase-1][yCase-2].estCaseNombre?() &&

				!(tabCase[xCase+2][yCase-1].jouable?()) &&
				!(tabCase[xCase+2][yCase-2].jouable?()) 
			then
                @description = descriptionCC
				return true
			elsif
				(yMax > yCase+4) && (xMax >= xCase+1) && ((xCase) >= 0) && ((yCase) >= 0)
			then
				if
					tabCase[xCase][yCase+1].jouable?() &&
					tabCase[xCase][yCase+2].jouable?() &&
					tabCase[xCase][yCase+3].jouable?() &&
					!(tabCase[xCase][yCase+4].jouable?()) &&
					tabCase[xCase+1][yCase+1].estCaseNombre?() &&
					tabCase[xCase+1][yCase+2].jouable?() &&
					tabCase[xCase+1][yCase+3].jouable?() &&
					!(tabCase[xCase+1][yCase+4].jouable?()) 
				then
					@description = descriptionCC
					return true
            	end
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
	    texteExemple.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"large\"><b>Exemple de \"Criss Cross\"</b></span>")
	    
	    exemple = Table.new(5, 5)
	    tableau = Array.new(4){Array.new(4)}
	    css_provider = Gtk::CssProvider.new
        css_provider.load(data: <<-CSS)
        button {
            background-color: red;
            background-image: none;
        }
        CSS

		tableau[0][2] = Button.new
		tableau[0][2].set_size_request(30,30)
		tableau[0][2].style_context.add_provider(css_provider)
		tableau[0][2].set_sensitive(false)
		tableau[0][2].label="\ \ \ \ \ \ \ \ \ \ \ \ 3"
		exemple.attach(tableau[0][2], 0, 1, 2, 3)

		tableau[0][3] = Button.new
		tableau[0][3].set_size_request(30,30)
		tableau[0][3].style_context.add_provider(css_provider)
		tableau[0][3].set_sensitive(false)
		tableau[0][3].label="\ \ \ \ \ \ \ \ \ \ \ \ 4"
		exemple.attach(tableau[0][3], 0, 1, 3, 4)
		
		tableau[1][1] = Button.new
	   	tableau[1][1].set_size_request(30,30)
        tableau[1][1].style_context.add_provider(css_provider) 
		tableau[1][1].set_sensitive(false)
		tableau[1][1].label="
4"
        exemple.attach(tableau[1][1], 1, 2, 1, 2)

	   	2.upto(3){|i|
		    tableau[1][i] = Button.new
		    tableau[1][i].set_size_request(30,30)
			tableau[1][i].set_sensitive(false)
			exemple.attach(tableau[1][i], 1, 2, i, i+1)
		} 
		   
	   	tableau[2][0] = Button.new
	   	tableau[2][0].set_size_request(30,30)
        tableau[2][0].style_context.add_provider(css_provider) 
		tableau[2][0].set_sensitive(false)
		tableau[2][0].label="
6"
		exemple.attach(tableau[2][0], 2, 3, 0, 1)

		
		1.upto(3){|i|
		    tableau[2][i] = Button.new
		    tableau[2][i].set_size_request(30,30)
			tableau[2][i].set_sensitive(false)
			if i==1 then
				tableau[2][1].label="(4+6)-(4+3)=3"
			end
			exemple.attach(tableau[2][i], 2, 3, i, i+1)
		} 

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
