require 'gtk3'
include Gtk

# Méthode de destruction basique de la fenêtre de jeu
def onDestroy
    puts "Fin de l'application"
    Gtk.main_quit
end

# Méthode destruction de la fenetre de jeu : demande à l'utilisateur s'il est sûr de vouloir quitter
#
# ==== Paramètres
#
# * +kakuro+ - la fenêtre de jeu
def onDestroyPopUp(kakuro)
    # initialisation de la fenetre
    popUpQuitter = Window.new
    popUpQuitter.set_title("Attention !!")
    popUpQuitter.set_window_position(:center_always)
    popUpQuitter.border_width=10
    popUpQuitter.set_default_size(100,100)
    popUpQuitter.set_resizable(false)
    tableauBouton = Gtk::Table.new(3,2,true)

    # ajout du tableau à la fenetre
    popUpQuitter.add(tableauBouton)

    # création des boutons de la fenetre pop up
    oui = Button.new().set_label("Oui")
    annuler = Button.new().set_label("Annuler")
    texte = Label.new().set_label("Voulez vous vraiment quitter ?")

    # ajout des boutons au tableau
    tableauBouton.attach(texte,0,2,0,2)
    tableauBouton.attach(oui,0,1,2,3)
    tableauBouton.attach(annuler,1,2,2,3)

    # connexion des signaux
    oui.signal_connect('clicked'){
        popUpQuitter.close()
        onDestroy()
    }

    annuler.signal_connect('clicked'){
        popUpQuitter.close()
        kakuro.set_sensitive(true)
    }

    popUpQuitter.signal_connect('destroy'){
        kakuro.set_sensitive(true)
    }

    #affichage de la fenetre pop up
    popUpQuitter.set_keep_above(true)
    popUpQuitter.show_all
end # Fin de méthode
