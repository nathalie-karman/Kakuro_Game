require 'gtk3'
include Gtk

class BtnCase < Gtk::Button
	# Les objets de cette classe héritent des caractéristiques de la classe Gtk::Button et sont également caractérisés par :
	#
	# * @ligne => leur coordonnée en ligne
	#
	# * @colonne => leur coordonnée en ligne
	#
	# Ils sont capable de :
	#
	# * se tester mathématiquement 
	#
	# * vérifier s'ils sont jouables
	#
	# * vérifier s'ils sont des cases indications 

	private_class_method :new
	attr_reader :ligne
	attr_reader :colonne

	# Méthode de création d'un bouton case
	#
	# ==== Paramètres
	#
	# * +ligne+ - la ligne de la case
	# * +colonne+ - la colonne de la case
	def BtnCase.creer(ligne, colonne)
		new(ligne, colonne)
	end

	# Méthode d'initialisation d'un bouton case
	#
	# ==== Paramètres
	#
	# * +ligne+ - la ligne de la case
	# * +colonne+ - la colonne de la case
	def initialize(ligne, colonne)
		super()
		self.set_size_request(50,70)
		@ligne = ligne.to_i
		@colonne = colonne.to_i
	end

	# Méthode qui vérifie que la case est jouable
	def jouable?
		return false
	end

	# Méthode qui vérifie que la case donne des indications 
	def estCaseNombre?()
    	return false
  	end

  	# Méthode qui vérifie que la case n'est pas jouable 
  	def estCaseVide?()
  		return false
	end
end