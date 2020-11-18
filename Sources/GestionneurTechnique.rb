require_relative './Techniques/LoneSquare.rb'
require_relative './Techniques/CrossReference.rb'
require_relative './Techniques/CrissCross.rb'
#load("./Techniques/LoneSquare.rb")
#load("./Techniques/CrossReference.rb")

class GestionneurTechnique
	# Les éléments de cette classe sont caractérisés par @listeTechnique, la liste de techniques

	# Méthode d'initialisation de la classe GestionneurTechnique
	def initialize
		@listeTechnique = Array.new
		@listeTechnique<<CrissCross.new
		@listeTechnique<<LoneSquare.new
		@listeTechnique<<CrossReference.new
	end

	# Méthode qui donne une des techniques en fonction du contexte
	#
	# ==== Paramètres
	#
	# * +caseIndication+ - la caseIndication à tester
	# * +tabCase+ - la grille du jeu
	# * +kakuro+ - la fenêtre de présentation du jeu
	def donneTechnique(caseIndication, tabCase, kakuro)
		i = -1
		@listeTechnique.each_index { |j|  
			if @listeTechnique[j].correspond?(caseIndication, tabCase) && i == -1
				i = j
			end
		}
		if i != -1
			@listeTechnique[i].afficheTechnique(kakuro)
		end
	end

	# Méthode qui met à jour des cases indication : cliquable si des techniques correspondent au contexte, non cliquable sinon
	#
	# ==== Paramètres
	#
	# * +grille+ - l'instance grille du jeu
	def majTechnique(grille)
		grille.tabCaseNombre.each { |c|  
			corr = false
			@listeTechnique.each { |t| 
				if t.correspond?(c, grille.tabCase)
					corr = true
				end
			}
			c.set_sensitive(corr)
		}
	end
end