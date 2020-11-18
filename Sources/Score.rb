class Score
	# Classe score pour le joueur

	private_class_method :new
	attr_accessor :nb_score

	# Méthode de création d'un Score
	#
	# ==== Paramètres
	#
	# *difficulte* => le niveau de difficulte
	# *aide* => booleen de l'aide visuelle
	def Score.creer(difficulte, aide)
		new(difficulte, aide)
	end

	# Méthode d'initialisation d'un Score
	#
	# ==== Paramètres
	#
	# *difficulte* => le niveau de difficulte
	# *aide* => booleen de l'aide visuelle
	def initialize(difficulte, aide)
		case difficulte
			when "facile"
				if(aide)
					@nb_score = 15000
				else
					@nb_score = 25000
				end
			when "moyen"
				if(aide)
					@nb_score = 25000
				else
					@nb_score = 35000
				end
			when "difficile"
				if(aide)
					@nb_score = 40000
				else
					@nb_score = 50000
				end
			else
				puts "Error"
			end
	end

	# Méthode de calcul d'un Score
	#
	# ==== Paramètres
	#
	# *difficulte* => le nombre de secondes pour finir la partie
	def calculScoreFinal(chrono)
		if chrono > 0
			if(chrono < @nb_score)
				@nb_score = @nb_score / chrono
			else
				@nb_score = 0
			end
		end
	end

	# Méthode pour retirer le malus du premier niveau d'aide au score
	def malusAide1
		if(@nb_score >= 20)
			@nb_score = @nb_score - 20
		else
			@nb_score = 0
		end
	end

	# Méthode pour retirer le malus de l'aide technique
	def malusAide2
		if(@nb_score >= 40)
			@nb_score = @nb_score - 40
		else
			@nb_score = 0
		end
	end

	# Méthode pour retirer le malus de l'aide technique
	def malusErreur
		if(@nb_score >= 60)
			@nb_score = @nb_score - 60
		else
			@nb_score = 0
		end
	end

end


