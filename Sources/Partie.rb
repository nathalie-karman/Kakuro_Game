require 'date'
require 'time'
require_relative 'Sauvegarde'



#=== Classe Partie
# Une partie repose sur une grille, une date, son chrono et le score du joueur
#
# * @grille
# * @date
# * @joueur
# * @chrono
# * @score
# * @grilleValide
# * @nomPartie
# * @enCours
#
#=== Exemples
# NOMJOUEUR = "leNul"
# partie1 = Partie.creer("leMeilleurJoueur",grille2)
# partie2 = Partie.creer(NOMJOUEUR,grille1)
#
# Pour la mise à jour des objets (tests unitaires) :
# partie2.majDonnees()
#
# Pour sauvegarder la partie à chaque coup donné :
# partie2.marshal_dump(@nomPartie)
#
# Affichage des objets de la partie :
# print partie2.to_s() + "\n"
class Partie

	#+joueur+ -joueur de la partie
	attr_accessor :joueur
	#+date+ - dernière date d'accès à la partie
	attr_accessor :date
	#+score+ - le score du joueur
	attr_accessor :score
	#+grille+ - la grille
	attr_accessor :grille
	#+chrono+ - le chronomètre de la partie
	attr_accessor :chrono
	#+grilleValide+ - les dernières grilles valides (au cas où l utilisateur utilise ctrl+z et il annule son coup valide)
	attr_accessor :grilleValide
	#+nomPartie+ - le nom de la partie
	attr_accessor :nomPartie
	attr_accessor :nomGrille
	# niveau de difficulté 1, 2, 3
	attr_accessor :niveau
	# la difficulté (facile, moyen, difficile)
	attr_accessor :difficulte
	#aide visuelle
	attr_accessor :aideVisuelle
	#etat
	attr_accessor :enCours

	private_class_method :new

	def initialize(nomJoueur,niveau,difficulte)
		@joueur = nomJoueur.downcase()
		@grille
		time = Time.new().to_a
		@date = "#{time[5]}-#{time[4]}-#{time[3]}_#{time[2]}h#{time[1]}m#{time[0]}s" # year - month - day - hour - min - sec
		@score =
		@chrono = 0
		@aideVisuelle = nil #aide visuelle 
		@niveau = niveau
		@difficulte = difficulte
		@nomPartie = "#{@joueur}_#{@niveau.split(' ')[1]}_#{@date}"
	end

	# Méthode d'instance, initialise les objets qui caractérisent la partie
	#
	# ==== Paramètres
	#
	# * nomJoueur => le nom du joueur
	# * niveau * => le niveau
	# * difficulte * => la difficulte
	def Partie.creer(nomJoueur,niveau,difficulte)
		new(nomJoueur,niveau,difficulte)
	end

	# Effectue  sauvegarde de la partie avec tous ses objets
	#
	# ==== Paramètres
	#
	# * file => le fichier
	def marshal_dump(file)
		File.open("Sauvegarde/#{@difficulte}/"+file, 'w+') do |f|
			Marshal.dump([@joueur,@grille,@date, @score,@chrono,@grilleValide,@nomPartie,@niveau,@difficulte,@aideVisuelle,@enCours],f)
		end

	end

	#Sert à sauvegarder, dans l'ordre, chaque objet dans le fichier binaire de sauvegarde
	def marshal_load (tabDonnees)
		@joueur = tabDonnees[0]
		@grille = tabDonnees[1]
		@date = tabDonnees[2]
		@score = tabDonnees[3]
		@chrono = tabDonnees[4]
		@grilleValide = tabDonnees[5] #important pour les aides à l'utilisateur de garder la dernière grille correcte
		@nomPartie = tabDonnees[6]
		@niveau = tabDonnees[7]
		@difficulte = tabDonnees[8]
		@aideVisuelle = tabDonnees[9]
		@enCours = tabDonnees[10]
		return tabDonnees
	end

	# Méthode qui sauvegarde le score du joueur et son nom dans le fichier classement.txt
	def finDePartie()
		File.write("classement/global.txt", [@joueur,@score.nb_score].join(" ")+";", mode: "a")	#serialization
		File.write("classement/#{@difficulte}.txt", [@joueur,@score.nb_score].join(" ")+";", mode: "a")	#serialization
		return
	end

end # Marqueur de fin de classe
