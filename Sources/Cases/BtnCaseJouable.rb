require_relative 'BtnCase'
#load ("BtnCase.rb")

class BtnCaseJouable < BtnCase
	# Les objets de cette classe héritent des caractéristiques de la classe BtnCase et sont également caractérisés par :
	#
	# * @laBonneReponse => leur réponse correcte
	#
	# * @saisieUtilisateur => la valeur saisie par l'utilisateur (joueur) dans la case
	#
	# * @activeCrayon => le booléen qui marque ou non l'activation du bouton crayon 
	#
	# * @activeStylo => le booléen qui marque ou non l'activation du bouton stylo
	#
	# * @erreurV => le booléen qui permet de définir que la valeur que contient la case comme une erreur au niveau de sa colonne
	#
	# * @erreurH => le booléen qui permet de définir que la valeur que contient la case comme une erreur au niveau de sa ligne
	#
	# * @css_provider => le css du bouton ajouté pour l'aide visuelle
	# 
	# * @css_provider2 => le css du bouton ajouté pour l'aide de premier niveau
	#
	# * @css_provider3 => le css du bouton ajouté pour afficher les erreurs
	#
	# Ils sont capable de :
	#
	# * se tester mathématiquement 
	#
	# * demander à ses cases d'indication de lancer l'aide visuelle sur la ligne et la colonne
	#
	# * demander à ses cases d'indication de donner leurs combinaisons
	#
	# * vérifier si ils contiennent la bonne réponse
	#
	# * ajouter un css d'erreur
	#
	# * retirer un css d'erreur
	#
	# * de mettre à jour la valeur saisie

	private_class_method :new

	attr_accessor :saisieUtilisateur
	attr_accessor :activeCrayon
	attr_accessor :activeStylo
	attr_accessor :erreurV
	attr_accessor :erreurH
	attr_reader :laBonneReponse
	attr_accessor :caseFausse

	# Méthode de création d'un bouton case jouable
	#
	# ==== Paramètres
	#
	# * +ligne+ - la ligne de la case
	# * +colonne+ - la colonne de la case
	# * +valeurCorrecte+ - la bonne case de la case
	# * +saisieUtilisateur+ - la valeur sasie par l'utilisateur
	def BtnCaseJouable.creer(ligne, colonne, valeurCorrecte, saisieUtilisateur)
		new(ligne, colonne, valeurCorrecte, saisieUtilisateur)
	end 

	# Méthode d'initialisation d'un bouton case jouable
	#
	# ==== Paramètres
	#
	# * +ligne+ - la ligne de la case
	# * +colonne+ - la colonne de la case
	# * +valeurCorrecte+ - la bonne case de la case
	# * +saisieUtilisateur+ - la valeur sasie par l'utilisateur, 0 par défaut
	def initialize(ligne, colonne, valeurCorrecte, saisieUtilisateur)
		super(ligne, colonne)
		
		@laBonneReponse = valeurCorrecte
		@saisieUtilisateur = saisieUtilisateur.to_i
		@activeCrayon = true
		@activeStylo = false
		@erreurV = false
		@erreurH = false
		@cssAst = false
		@caseFausse = false
		@css_provider = Gtk::CssProvider.new
		@css_provider2 = Gtk::CssProvider.new
	    @css_provider3 = Gtk::CssProvider.new
	    @css_provider.load(data: <<-CSS)
	    button {
	        background-color: orange;
	        background-image: none;
	        opacity: 1;
	    }
	    CSS

	    @css_provider2.load(data: <<-CSS)
	    button{
	    	background-color: yellow;
	    	background-image: none;
	    	opacity: 1;
	    }
	    CSS

	    @css_provider3.load(data: <<-CSS)
	    button{
	    	background-color: aqua;
	    	background-image: none;
	    	opacity: 1;
	    }
	    CSS

	end

	# Redefinition de la méthode jouable?
	def jouable?
		return true
	end

	# Méthode qui permet de trouver les deux caseNombre associées à la case où l'utilisateur a mis son chiffre, puis à vérifier si les sommes sont correctes
	#
	# ==== Paramètres
	#
	# * +tabCase+ - la grille du jeu
    def donneMathsBon(tabCase)
    	# Recherche de la case indication au dessus 
    	tampLigne = @ligne
	    while(!(tabCase[tampLigne][@colonne].estCaseNombre?)) do
	      tampLigne -= 1
	    end
    	tabCase[tampLigne][@colonne].mathsBon(tabCase)

	    # Recherche de la case indication à gauche 
	    tampColonne = @colonne
	    while(!(tabCase[@ligne][tampColonne].estCaseNombre?)) do
	      tampColonne -= 1
	    end
    	tabCase[@ligne][tampColonne].mathsBon(tabCase)
    end

    # Méthode qui permet de demander aux cases d'indication de lancer l'aide visuelle sur la ligne et la colonne
	#
	# ==== Paramètres
	#
	# * +tabCase+ - la grille du jeu
    def aideVisuelle(tabCase)
    	# Recherche de la case indication au dessus 
    	tampLigne = @ligne
	    while(!(tabCase[tampLigne][@colonne].estCaseNombre?)) do
	      tampLigne -= 1
	    end
	    tabCase[tampLigne][@colonne].aideVisuelle(tabCase, true, false)

	    # Recherche de la case indication à gauche 
	    tampColonne = @colonne
	    while(!(tabCase[@ligne][tampColonne].estCaseNombre?)) do
	      tampColonne -= 1
	    end
    	tabCase[@ligne][tampColonne].aideVisuelle(tabCase, false, true)
    end

	# Méthode qui permet de demander aux cases d'indication de donner leurs combinaisons
	#
	# ==== Paramètres
	#
	# * +tabCase+ - la grille du jeu
	# * +jeu+ - le jeu
	def donneCombinaisons(tabCase, jeu)
  		# Recherche de la case indication au dessus
	    tampLigne = @ligne
	    while(!(tabCase[tampLigne][colonne].estCaseNombre?)) do
	      	tampLigne -= 1
	    end
	    tabCase[tampLigne][colonne].donneCombinaisons(tabCase, jeu, true)

	    # Recherche de la case indication à gauche
	    tampColonne = @colonne
	    while(!(tabCase[@ligne][tampColonne].estCaseNombre?)) do
	      	tampColonne -= 1
	    end
	    tabCase[@ligne][tampColonne].donneCombinaisons(tabCase, jeu, false)
	end

	# Méthode qui permet de vérifier si la case contient la bonne réponse
	def contientBonneReponse?
    	return @saisieUtilisateur.to_i == @laBonneReponse.to_i
	end

	# Méthode qui permet d'ajouter un css d'erreur
	def ajouteCSSError
		if (!@erreurH && @erreurV) || (!@erreurV && @erreurH)
		    self.style_context.add_provider(@css_provider) 
		end
	end

	# Méthode qui permet de retirer un css d'erreur
	def retireCSSError
		if !@erreurH && !@erreurV
			self.style_context.remove_provider(@css_provider) 
		end
	end

	# Méthode qui permet d'ajouter le css des astuces sur la ligne ou la colonne de cases jouables dans la grille
	def ajouteCSSAstuce
		@cssAst = true
		if(@saisieUtilisateur == 0)
			self.style_context.add_provider(@css_provider2)
		end
	end

	# Méthode qui permet de retirer le css des astuces sur la ligne ou la colonne de cases jouables dans la grille
	def retireCSSAstuce
		if(@cssAst)
			self.style_context.remove_provider(@css_provider2)
		end
	end

	# Méthode pour mettre en évidence les cases pas bonnes
	def metEvidenceCaseErreur
		if(!@caseFausse)
			@caseFausse = true
			self.style_context.add_provider(@css_provider3)
		end
	end

	# Méthode pour retirer les évidences des cases pas bonnes
	def retireEvidenceCaseErreur
		if(@caseFausse)
			@caseFausse = false
			self.style_context.remove_provider(@css_provider3)
		end
	end

	# Redefinition de la méthode set_label
	#
	# ==== Paramètres
	#
	# * +s+ - le label, la saisie de l'utilisateur
	def set_label(s)
		super(s)
		if(s == "")
			@saisieUtilisateur = 0
		else
			@saisieUtilisateur = s.to_i
		end
	end

	def _dump(param)
		[self.ligne(),self.colonne(),@laBonneReponse,@saisieUtilisateur].join(':')
 	end

	def self._load serialized_user
		BtnCaseJouable.creer(*serialized_user.split(':'))
	end
end