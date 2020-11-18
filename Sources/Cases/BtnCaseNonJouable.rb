require_relative 'BtnCase'
#load ("BtnCase.rb")

class BtnCaseNonJouable < BtnCase
    # Les objets de cette classe héritent des caractéristiques de la classe BtnCase

    private_class_method :new

    # Méthode de création d'un bouton case non jouable
    #
    # ==== Paramètres
    #
    # * +ligne+ - la ligne de la case
    # * +colonne+ - la colonne de la case
    def BtnCaseNonJouable.creer(ligne, colonne)
        new(ligne, colonne)
    end

    # Méthode d'initialisation d'un bouton case non jouable
    #
    # ==== Paramètres
    #
    # * +ligne+ - la ligne de la case
    # * +colonne+ - la colonne de la case
	def initialize(ligne, colonne)
		super(ligne, colonne)
		self.set_sensitive(false)
        self.margin = 0
        css_provider = Gtk::CssProvider.new
        css_provider.load(data: <<-CSS)
        button {
            background-color: darkred;
            background-image: none;
            opacity: 0.8;
        }
        
        CSS
        self.style_context.add_provider(css_provider)
	end

    # Redefinition de la méthode estCaseVide?
    def estCaseVide?
        return true
    end

    def _dump(param)
        [self.ligne,self.colonne].join(':')
    end

    def self._load(serialized_user)
        new(*serialized_user.split(':'))
    end
end
