require 'gtk3'
include Gtk

# Crée et renvoie le nom du jeu en taille xx-large
#
# ==== Paramètres
#
# * +label+ - le nom du jeu
def getLabel(label)
    nomJeu = Label.new()
    nomJeu.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"xx-large\"><b>#{label}</b></span>")
    return nomJeu
end

# Crée et renvoie un label de taille xx-large
#
# ==== Paramètres
#
# * +label+ - le texte du label
def getLabelXX(label)
    nomDuLabel = Label.new()
    return nomDuLabel.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"xx-large\"><b>#{label}</b></span>")
end

# Crée et renvoie un label de taille x-large
#
# ==== Paramètres
#
# * +label+ - le texte du label
def getLabelX(label, italic)
    leLabel = Label.new()
    if italic
        leLabel.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b><i>#{label}</i></b></span>")
    else
        leLabel.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"x-large\"><b>#{label}</b></span>")
    end
    return leLabel
end

# Crée et renvoie un label de taille large
#
# ==== Paramètres
#
# * +label+ - le texte du label
def getLabelLarge(label)
    leLabel = Label.new()
    return leLabel.set_markup("<span face=\"Roboto Condensed, Bold 10\" size=\"large\">#{label}</span>")
end
