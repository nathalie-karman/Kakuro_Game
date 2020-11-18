require_relative 'BtnCase'
require_relative '../Combinaison.rb'
#load ("BtnCase.rb")
#load ("../Combinaison.rb")

class BtnCaseIndication < BtnCase
    # Les objets de cette classe héritent des caractéristiques de la classe BtnCase et sont également caractérisés par :
    #
    # * @valeurV => le total que doit contenir la somme des nombres de la colonne
    #
    # * @valeurH => le total que doit contenir la somme des nombres de la ligne
    #
    # * @etatH => le booléen qui permet de savoir si la somme des nombres de la ligne est bonne
    #
    # * @etatV => le booléen qui qui permet de savoir si la somme des nombres de la colonne est bonne
    #
    # * @sommeV => la somme des valeurs saisies par l'utilisateur dans la colonne
    #
    # * @sommeH => la somme des valeurs saisies par l'utilisateur dans la ligne
    #
    # Ils sont capable de :
    #
    # * se dessiner 
    #
    # * de lancer l'aide visuelle sur la ligne et la colonne'
    #
    # * de donner les combinaisons possibles
    #
    # * se tester mathématiquement 

    private_class_method :new
    attr_reader :valeurV
    attr_reader :valeurH
    attr_accessor :etatH
    attr_accessor :etatV
    attr_accessor :sommeV
    attr_accessor :sommeH

    # Méthode de création d'un bouton case indication
    #
    # ==== Paramètres
    #
    # * +ligne+ - la ligne de la case
    # * +colonne+ - la colonne de la case
    # * +horizontal+ - la valeur à indiquer en ligne
    # * +vertical+ - la valeur à indiquer en colonne
    def BtnCaseIndication.creer(ligne, colonne, horizontal, vertical)
        new(ligne, colonne, horizontal,vertical)
    end 

    # Méthode d'initialisation d'un bouton case indication
    #
    # ==== Paramètres
    #
    # * +ligne+ - la ligne de la case
    # * +colonne+ - la colonne de la case
    # * +horizontal+ - la valeur à indiquer en ligne
    # * +vertical+ - la valeur à indiquer en colonne
    def initialize(ligne, colonne, horizontal, vertical)
        super(ligne, colonne)
        self.set_sensitive(false)
        @valeurH = horizontal.to_i
        @valeurV = vertical.to_i
        @etatH = false
        @etatV =false
        @sommeV = 0
        @sommeH = 0
        
        self.add(dessinerCase(horizontal, vertical))
        
        css_provider = Gtk::CssProvider.new
        css_provider2 = Gtk::CssProvider.new
        css_provider.load(data: <<-CSS)
        button {
            background-color: red;
            background-image: none;
        }
        CSS

        self.style_context.add_provider(css_provider)
    end

    # Méthode permettant de dessiner dans la case
    #
    # ==== Paramètres
    #
    # * +horizontal+ - la valeur à indiquer en ligne
    # * +vertical+ - la valeur à indiquer en colonne
    def dessinerCase(horizontal, vertical)
 
        darea = Gtk::DrawingArea.new
        
        darea.signal_connect "draw" do
            
            cr = darea.window.create_cairo_context
            # Couleur Police
            cr.set_source_rgba 1, 1, 1, 1
            # Taille Police
            cr.set_font_size 20

            if horizontal != "0"
                # x, y
                if horizontal.length ==  1
                    cr.move_to 55, 25
                    else
                    cr.move_to 45, 25
                end
                cr.show_text horizontal
            end
            
            if vertical != "0"
                if vertical.length ==  1
                    cr.move_to 20, 45
                    else
                    cr.move_to 10, 45
                end
                cr.show_text vertical
            end
        end

        return darea
    end
    
    # Redéfinition de la méthode estCaseNombre?
    def estCaseNombre?
        return true
    end

    # Méthode permettant d'activer l'aide visuelle
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    # * +vertical+ - le booleen permettant d'activation de l'aide dans les cases en colonne
    # * +horizontal+ - le booleen permettant d'activation de l'aide dans les cases en ligne
    def aideVisuelle(tabCase, vertical, horizontal)

        if(vertical)
            mathsBon(tabCase)
            tampLigne = @ligne + 1

            while tampLigne < 8 && tabCase[tampLigne][@colonne].jouable? do

                if @valeurV < @sommeV
                    tabCase[tampLigne][@colonne].erreurV = true
                    tabCase[tampLigne][@colonne].ajouteCSSError
                else
                    tabCase[tampLigne][@colonne].erreurV = false
                    tabCase[tampLigne][@colonne].retireCSSError
                end

                tampLigne += 1
            end
        end

        if(horizontal)
            mathsBon(tabCase)
            tampColonne = @colonne + 1

            while tampColonne < 8 && tabCase[@ligne][tampColonne].jouable?() do
                if @valeurH < @sommeH
                    tabCase[@ligne][tampColonne].erreurH = true
                    tabCase[@ligne][tampColonne].ajouteCSSError
                else
                    tabCase[@ligne][tampColonne].erreurH = false
                    tabCase[@ligne][tampColonne].retireCSSError
                end

                tampColonne += 1
            end
        end
    end

    # Méthode qui vérifie que la somme des cases de la ligne ou de la colonne est bonne
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    def mathsBon(tabCase)

        @sommeV = 0
        @sommeH = 0

        # test de la colonne
        tampLigne = @ligne + 1
        while tampLigne < 8 && tabCase[tampLigne][@colonne].jouable? do
            @sommeV += tabCase[tampLigne][@colonne].saisieUtilisateur
            tampLigne += 1
        end

        if @valeurV == @sommeV
            @etatV = true
        else
            @etatV = false
        end

        # test de la ligne
        tampColonne = @colonne + 1
        while tampColonne < 8 && tabCase[@ligne][tampColonne].jouable?() do
            @sommeH += tabCase[@ligne][tampColonne].saisieUtilisateur
            tampColonne += 1
        end

        if(@valeurH == @sommeH)
            @etatH = true
        else
            @etatH = false
        end
    end


    # Méthode servant à de donner leurs combinaisons en ligne et en colonne
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    # * +jeu+ - le jeu
    # * +bool+ - un booleen : true pour vertical, false pour horizontal
    def donneCombinaisons(tabCase, jeu, bool)
        
        tampVertical = @ligne + 1
        tampHorizontal = @colonne + 1
        nbCaseHorizontal = 0
        nbCaseVertical = 0

        tableauColonne = Array.new
        tableauLigne = Array.new

        # parcours horizontal
        while(tampHorizontal < 8 && tabCase[@ligne][tampHorizontal].jouable?()) do
            if tabCase[@ligne][tampHorizontal].label() != nil && tabCase[@ligne][tampHorizontal].label() != "" 
                tableauLigne<<tabCase[@ligne][tampHorizontal].label().to_i
            end 
            nbCaseHorizontal += 1
            tampHorizontal += 1
        end 

        # parcours vertical
        while(tampVertical < 8 && tabCase[tampVertical][colonne].jouable?()) do
            if tabCase[tampVertical][colonne].label() != nil && tabCase[tampVertical][colonne].label() != "" 
                tableauColonne<<tabCase[tampVertical][colonne].label().to_i
            end 
            nbCaseVertical += 1
            tampVertical += 1
        end    

        combiVertical = Combinaison.creer(@valeurV,nbCaseVertical)
        combiHorizontal = Combinaison.creer(@valeurH,nbCaseHorizontal)

        if(combiHorizontal.calcul(tableauLigne) !=nil && bool == false)
            combH = combiHorizontal.calcul(tableauLigne)
            jeu.majCombi(nil, combH)
        end

        if(combiVertical.calcul(tableauColonne) != nil && bool == true)
            combV = combiVertical.calcul(tableauColonne)
            jeu.majCombi(combV, nil)
        end
    end

    # Méthode qui calcule le nombre de cases en ligne à remplir
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    def nbCasesLigne(tabCase)
        tampHorizontal = @colonne + 1
        nbCaseHorizontal = 0

        while(tampHorizontal < 8 && tabCase[@ligne][tampHorizontal].jouable?()) do
            nbCaseHorizontal += 1
            tampHorizontal += 1
        end 

        return nbCaseHorizontal
    end

    # Méthode qui calcule le nombre de cases en colonne à remplir
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    def nbCasesColonne(tabCase)
        tampVertical = @ligne + 1
        nbCaseVertical = 0

        while(tampVertical < 8 && tabCase[tampVertical][colonne].jouable?()) do
            nbCaseVertical += 1
            tampVertical += 1
        end    

        return nbCaseVertical
    end

    # Méthode qui calcule le nombre de cases déjà remplies en colonne
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    def nbCasesRempliesV(tabCase)
        tampVertical = @ligne + 1
        nbCase = 0

        while(tampVertical < 8 && tabCase[tampVertical][colonne].jouable?()) do
            if tabCase[tampVertical][colonne].label() != nil && tabCase[tampVertical][colonne].label() != ""        
                nbCase += 1
            end 
            tampVertical += 1
        end    

        return nbCase
    end

    # Méthode qui calcule le nombre de cases déjà remplies en ligne
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    def nbCasesRempliesH(tabCase)
        tampHorizontal = @colonne + 1
        nbCase = 0

        while(tampHorizontal < 8 && tabCase[@ligne][tampHorizontal].jouable?()) do
            if tabCase[@ligne][tampHorizontal].label() != nil && tabCase[@ligne][tampHorizontal].label() != "" 
                nbCase += 1
            end 
            tampHorizontal += 1
        end 

        return nbCase
    end

    # Méthode qui permet de colorier la ligne ou la colonne
    #
    # ==== Paramètres
    #
    # * +tabCase+ - la grille de jeu
    # * +sens+ - le sens dans lequel colorer
    def colorerCasesFaciles(tabCase, sens)
        if(sens == false) #Horizontal
            tampLigne = @ligne + 1

            while tampLigne < 8 && tabCase[tampLigne][@colonne].jouable? do
                tabCase[tampLigne][@colonne].ajouteCSSAstuce
                tampLigne += 1
            end
        end

        if(sens == true) #Vertical
            tampColonne = @colonne + 1

            while tampColonne < 8 && tabCase[@ligne][tampColonne].jouable?() do
                tabCase[@ligne][tampColonne].ajouteCSSAstuce
                tampColonne += 1
            end
        end

    end

    # Redefinition de la fonction to_s
    def to_s
        return "Case [#{@ligne}][#{@colonne}] : vertical: #{valeurV} & horizontal: #{valeurH}"
    end

    def _dump(param)
        [self.ligne,self.colonne,self.valeurH,self.valeurV].join(':')
    end

    def self._load(serialized_user)
        new(*serialized_user.split(':'))
    end
end